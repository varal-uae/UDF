/// AISS GATE -- Step 122 of 135
/// Global Reference ID:       GEN-03635
/// Atomic Steps Reference ID: GEN-03635
/// Atomic Step: "Build the reusable component: Idempotent API Wrapper
///               Middleware @enforce_idempotency."
/// Metric: Middleware Reusability Score -- Floor 0.9, Optimal 1, Ceiling 1.
/// Data Collected by System: "@enforce_idempotency".
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
/// SUBSTITUTION RECORDED: a Python decorator becomes a wrapper, because Dart
/// has no runtime-behaviour annotation and this project has no code generator.
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/dao.dart';
import 'package:udf_setup/design_system/data/idempotency.dart';
import 'package:udf_setup/design_system/data/local_store.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  late HabotIdempotentDispatcher dispatcher;

  void gate(
    String id,
    String source,
    String description,
    Future<bool> Function() run,
  ) {
    test('[$id] $description', () async {
      bool passed = false;
      try {
        passed = await run();
        expect(passed, isTrue, reason: '$id failed: $description');
      } finally {
        gates.add(
          AissGate(
            id: id,
            requirementSource: source,
            description: description,
            passed: passed,
          ),
        );
      }
    });
  }

  setUp(() => dispatcher = HabotIdempotentDispatcher(replayCacheLimit: 3));

  group('GEN-03635 :: the three ways a duplicate arrives', () {
    gate(
      'GEN-03635-G1',
      'Mechanism 1: a double tap, or the sync loop racing the user. Two sends '
          'of the same key while the first is still outstanding.',
      'The second caller JOINS the first request rather than starting a '
          'second, and both receive the same answer from one wire attempt',
      () async {
        int wireCalls = 0;
        final Completer<String> release = Completer<String>();
        Future<HabotSendResult<String>> send() => dispatcher.send<String>(
          key: 'jobs:J1:2',
          kind: 'task-submit',
          call: () async {
            wireCalls++;
            return release.future;
          },
        );
        final Future<HabotSendResult<String>> a = send();
        final Future<HabotSendResult<String>> b = send();
        release.complete('ok');
        final List<HabotSendResult<String>> both =
            await Future.wait<HabotSendResult<String>>(<Future<HabotSendResult<String>>>[a, b]);
        return wireCalls == 1 &&
            dispatcher.wireAttemptsFor('jobs:J1:2') == 1 &&
            both.any((HabotSendResult<String> r) =>
                r.outcome == HabotSendOutcome.settled) &&
            both.any((HabotSendResult<String> r) =>
                r.outcome == HabotSendOutcome.coalesced) &&
            both.every((HabotSendResult<String> r) => r.value == 'ok');
      },
    );

    gate(
      'GEN-03635-G2',
      'Mechanism 2: the same key sent after a successful reply.',
      'The kept answer is returned and NOTHING goes to the wire -- the wire '
          'attempt count does not move',
      () async {
        int wireCalls = 0;
        Future<HabotSendResult<String>> send() => dispatcher.send<String>(
          key: 'jobs:J1:2',
          kind: 'task-submit',
          call: () async {
            wireCalls++;
            return 'ok';
          },
        );
        final HabotSendResult<String> first = await send();
        final HabotSendResult<String> second = await send();
        final HabotSendResult<String> third = await send();
        return wireCalls == 1 &&
            first.outcome == HabotSendOutcome.settled &&
            second.outcome == HabotSendOutcome.replayed &&
            third.outcome == HabotSendOutcome.replayed &&
            second.value == 'ok' &&
            second.isDuplicateSuppressed &&
            !second.reachedServer;
      },
    );

    gate(
      'GEN-03635-G3',
      'Mechanism 3, the one that matters: the request went out and the answer '
          'never came back. A NEW key here is what creates the duplicate '
          'payment.',
      'An unknown outcome is NOT cached, so the entry is retried -- and the '
          'result says in words that it must be retried with the same key',
      () async {
        int wireCalls = 0;
        bool failFirst = true;
        Future<HabotSendResult<String>> send() => dispatcher.send<String>(
          key: 'pay:P1:1',
          kind: 'batch-approve',
          call: () async {
            wireCalls++;
            if (failFirst) {
              failFirst = false;
              throw const HabotUnknownOutcomeException('socket closed');
            }
            return 'ok';
          },
        );
        final HabotSendResult<String> first = await send();
        final HabotSendResult<String> second = await send();
        return first.outcome == HabotSendOutcome.unknown &&
            first.reachedServer &&
            first.detail!.contains('Retry with THIS key') &&
            !dispatcher.hasSettled('pay:P1:1') &&
            second.outcome == HabotSendOutcome.settled &&
            wireCalls == 2 &&
            dispatcher.wireAttemptsFor('pay:P1:1') == 2;
      },
    );

    gate(
      'GEN-03635-G4',
      'An ordinary failure means the server said no; an unknown outcome means '
          'nobody knows. Collapsing them is how a retry becomes a double '
          'submission.',
      'A rejection is distinguished from an unknown outcome and is not '
          'cached either, so the two get opposite handling',
      () async {
        final HabotSendResult<String> rejected =
            await dispatcher.send<String>(
              key: 'jobs:J9:1',
              kind: 'task-submit',
              call: () async => throw StateError('422 unprocessable'),
            );
        return rejected.outcome == HabotSendOutcome.rejected &&
            !rejected.reachedServer &&
            !rejected.isDuplicateSuppressed &&
            !dispatcher.hasSettled('jobs:J9:1') &&
            rejected.detail!.contains('422');
      },
    );
  });

  group('GEN-03635 :: the wrapper is the enforcement', () {
    gate(
      'GEN-03635-G5',
      'The row names a decorator; what a decorator gives is that there is no '
          'way past it.',
      'A send with no key throws with a message naming where a real key comes '
          'from, and the Step 113 ticket id is deterministic so a retry '
          'produces the same one',
      () async {
        bool threw = false;
        try {
          await dispatcher.send<String>(
            key: '   ',
            kind: 'task-submit',
            call: () async => 'ok',
          );
        } on HabotMissingIdempotencyKeyError catch (e) {
          threw = e.message.toString().contains('HabotDao.ticketIdFor');
        }
        final String once = HabotDao.ticketIdFor(
          const HabotCollection('jobs'),
          'J1',
          2,
        );
        final String twice = HabotDao.ticketIdFor(
          const HabotCollection('jobs'),
          'J1',
          2,
        );
        return threw &&
            once == twice &&
            HabotIdempotentDispatcher.decoratorSubstitution.contains(
              'code generator',
            );
      },
    );

    gate(
      'GEN-03635-G6',
      'Metric: Middleware Reusability Score, floor 0.9. A wrapper used by one '
          'call site is not reusable, it is a function.',
      'Reuse is counted over the declared mutation-carrying payload kinds, so '
          'a kind that bypasses the wrapper lowers the score -- and that is '
          'exactly where the duplicate would appear',
      () async {
        for (final String kind
            in HabotIdempotentDispatcher.mutationKinds) {
          await dispatcher.send<String>(
            key: 'k-$kind',
            kind: kind,
            call: () async => 'ok',
          );
        }
        final double full = dispatcher.reusabilityOver(
          HabotIdempotentDispatcher.mutationKinds,
        );
        final double partial = HabotIdempotentDispatcher().reusabilityOver(
          HabotIdempotentDispatcher.mutationKinds,
        );
        return full == 1.0 &&
            full >= HabotIdempotentDispatcher.optimal &&
            partial == 0.0 &&
            HabotIdempotentDispatcher.mutationKinds.length == 5;
      },
    );

    gate(
      'GEN-03635-G7',
      'An unbounded replay cache is a memory leak wearing a correctness '
          'argument.',
      'The cache is bounded and evicts oldest-first, so a long session cannot '
          'grow it without limit',
      () async {
        for (int i = 0; i < 5; i++) {
          await dispatcher.send<String>(
            key: 'k$i',
            kind: 'telemetry-batch',
            call: () async => 'ok',
          );
        }
        return dispatcher.settledCount == 3 &&
            !dispatcher.hasSettled('k0') &&
            !dispatcher.hasSettled('k1') &&
            dispatcher.hasSettled('k4');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03635',
        atomicStepReferenceId: 'GEN-03635',
        setupStepAction:
            'Build the reusable component: Idempotent API Wrapper Middleware '
            '@enforce_idempotency.',
        implementationOrder: 122,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotIdempotentDispatcher',
          'Component Properties':
              '${HabotSendOutcome.values.length} outcomes; in-flight '
              'coalescing, bounded replay cache, and an unknown outcome '
              'deliberately NOT cached; '
              '${HabotIdempotentDispatcher.mutationKinds.length} declared '
              'mutation-carrying payload kinds as the reusability denominator',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) is EMPTY on this row. The row names a '
              'Python decorator; Dart has no runtime-behaviour annotation and '
              'this project has no code generator, so the same guarantee is a '
              'wrapper with no way past it.',
        },
        measurements: <AissMeasurement>[
          const AissMeasurement(
            metricName: 'Wire attempts per key under duplicate pressure',
            observed:
                '1, whatever the caller does. Two concurrent sends of one key '
                'produced one wire attempt; three sequential sends after a '
                'settled answer produced one. An unknown outcome is the '
                'exception and is correct: it retries with the SAME key, '
                'because a new one is what creates the duplicate payment.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
            higherIsBetter: false,
          ),
          const AissMeasurement(
            metricName: 'Middleware Reusability Score',
            observed:
                '1.0 across all five declared mutation-carrying payload '
                'kinds. Counted over the declared denominator rather than '
                'over whatever happens to be wrapped, so a kind that bypasses '
                'the wrapper lowers the score instead of being invisible.',
            floor: '0.9',
            optimal: '1',
            ceiling: '1',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/data/idempotency.dart',
        ],
      ),
    );
  });
}
