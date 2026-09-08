/// AISS GATE -- Step 123 of 135
/// Global Reference ID:       GEN-05276
/// Atomic Steps Reference ID: GEN-05276
/// Atomic Step: "Unit-test and validate the implementation of: implement a
///               background sync subroutine (serviceWorker.sync) to transmit
///               queued entries when online."
/// Metric: Validation Test Pass Rate (Offline Data Sync Success Rate) --
///         Floor ">= 95% test pass rate, >= 80% code coverage",
///         Optimal "100% test pass rate, >= 90% code coverage".
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
/// SUBSTITUTION RECORDED: serviceWorker.sync is a browser API; the equivalent
/// is a sweep driven by the Step 47 connectivity state machine.
/// METRIC HALF PRODUCIBLE: the pass rate is real; the coverage half needs
/// `flutter test --coverage` on a machine with the toolchain.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/data/idempotency.dart';
import 'package:udf_setup/design_system/data/local_store.dart';
import 'package:udf_setup/design_system/data/outbox.dart';
import 'package:udf_setup/design_system/data/sync_loop.dart';
import 'package:udf_setup/design_system/resilience/connectivity_state.dart';
import 'package:udf_setup/design_system/resilience/reconnect_policy.dart';

import 'aiss_reporter.dart';

/// A governor that can be flipped, so the loop's dependence on the question
/// can be tested without Step 124's implementation of the answer.
class _Switch implements HabotSyncGovernor {
  _Switch({this.open = true});

  bool open;

  @override
  bool get allowsHeavyWork => open;

  @override
  String get reason => open ? 'allowed' : 'paused by the governor under test';
}

void main() {
  final List<AissGate> gates = <AissGate>[];
  late HabotMemoryStore store;
  late HabotOutbox outbox;
  late HabotConnectivityMonitor monitor;

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

  setUp(() {
    store = HabotMemoryStore();
    outbox = HabotOutbox(store: store, maxAttempts: 2);
    monitor = HabotConnectivityMonitor(poll: () async => true);
  });

  tearDown(() => monitor.dispose());

  HabotSyncLoop loop({
    required Future<void> Function(HabotOutboxEntry) transmit,
    HabotSyncGovernor governor = const HabotAlwaysAllow(),
  }) => HabotSyncLoop(
    outbox: outbox,
    dispatcher: HabotIdempotentDispatcher(),
    monitor: monitor,
    policy: HabotReconnectPolicy(),
    transmit: transmit,
    governor: governor,
  );

  Future<void> queue(List<String> ids) async {
    for (final String id in ids) {
      await outbox.enqueue(
        id: id,
        kind: 'task-submit',
        payload: <String, Object?>{'entity_id': id},
      );
    }
  }

  group('GEN-05276 :: the sweep', () {
    gate(
      'GEN-05276-G1',
      'Atomic Step: "transmit QUEUED ENTRIES WHEN ONLINE".',
      'A sweep drains the queue oldest first and removes what it sent, so the '
          'order work was done in survives the transmission',
      () async {
        await queue(<String>['a', 'b', 'c']);
        final List<String> order = <String>[];
        final HabotSyncSweep s = await loop(
          transmit: (HabotOutboxEntry e) async => order.add(e.id),
        ).sweep();
        return s.stop == HabotSyncStop.drained &&
            s.sent == 3 &&
            s.failed == 0 &&
            s.isClean &&
            order.join(',') == 'a,b,c' &&
            (await outbox.pendingCount) == 0;
      },
    );

    gate(
      'GEN-05276-G2',
      '"WHEN ONLINE" -- the Step 47 monitor decides whether to try at all.',
      'A sweep on a device with no network attempts nothing rather than '
          'burning attempts against a radio that is switched off',
      () async {
        await queue(<String>['a']);
        final HabotConnectivityMonitor dead = HabotConnectivityMonitor(
          poll: () async => false,
        );
        await dead.pollOnce();
        await dead.pollOnce();
        int transmits = 0;
        final HabotSyncSweep s = await HabotSyncLoop(
          outbox: outbox,
          dispatcher: HabotIdempotentDispatcher(),
          monitor: dead,
          policy: HabotReconnectPolicy(),
          transmit: (HabotOutboxEntry e) async => transmits++,
        ).sweep();
        dead.dispose();
        return s.stop == HabotSyncStop.offline &&
            transmits == 0 &&
            s.sent == 0 &&
            (await outbox.pendingCount) == 1;
      },
    );

    gate(
      'GEN-05276-G3',
      'From the header: "every unknown is a payload the server may have '
          'applied. Continuing would pile up ambiguity."',
      'The sweep STOPS at the first unknown outcome rather than sending the '
          'rest, the entry keeps its key, and the reason names the entry',
      () async {
        await queue(<String>['a', 'b', 'c']);
        int transmits = 0;
        final HabotSyncSweep s = await loop(
          transmit: (HabotOutboxEntry e) async {
            transmits++;
            if (e.id == 'b') {
              throw const HabotUnknownOutcomeException('socket closed');
            }
          },
        ).sweep();
        final List<HabotOutboxEntry> left = await outbox.pending();
        return s.stop == HabotSyncStop.unknownOutcome &&
            s.sent == 1 &&
            s.failed == 1 &&
            transmits == 2 &&
            s.detail.contains('"b"') &&
            left.map((HabotOutboxEntry e) => e.id).join(',') == 'b,c';
      },
    );

    gate(
      'GEN-05276-G4',
      'An entry that cannot be sent must not block the queue forever, and must '
          'not vanish either.',
      'A repeatedly rejected entry is dead-lettered and the sweep reports it '
          'by name, with the attempt count that killed it',
      () async {
        await queue(<String>['bad']);
        final HabotSyncLoop l = loop(
          transmit: (HabotOutboxEntry e) async =>
              throw StateError('422 unprocessable'),
        );
        await l.sweep();
        final HabotSyncSweep second = await l.sweep();
        return second.stop == HabotSyncStop.deadLettered &&
            second.detail.contains('"bad"') &&
            second.detail.contains('dead') &&
            (await outbox.dead()).length == 1 &&
            (await outbox.pendingCount) == 0;
      },
    );
  });

  group('GEN-05276 :: the assembly', () {
    gate(
      'GEN-05276-G5',
      'Step 122 must wrap every send the loop makes, or a reconnect duplicates '
          'exactly the work the queue was protecting.',
      'The loop sends through the idempotent dispatcher, so an entry offered '
          'twice reaches the wire once and is still removed from the queue',
      () async {
        await queue(<String>['a']);
        int wire = 0;
        final HabotIdempotentDispatcher dispatcher =
            HabotIdempotentDispatcher();
        final HabotSyncLoop l = HabotSyncLoop(
          outbox: outbox,
          dispatcher: dispatcher,
          monitor: monitor,
          policy: HabotReconnectPolicy(),
          transmit: (HabotOutboxEntry e) async => wire++,
        );
        await l.sweep();
        await outbox.enqueue(
          id: 'a',
          kind: 'task-submit',
          payload: <String, Object?>{'entity_id': 'a'},
        );
        await l.sweep();
        return wire == 1 &&
            dispatcher.wireAttemptsFor('a') == 1 &&
            dispatcher.kindsWrapped.contains('task-submit') &&
            (await outbox.pendingCount) == 0;
      },
    );

    gate(
      'GEN-05276-G6',
      'Step 124 pauses heavy work; the loop must depend on the QUESTION rather '
          'than on that implementation.',
      'A governor that refuses stops the sweep before anything is sent and the '
          'sweep reports the governor own reason, while the default governor '
          'lets it run',
      () async {
        await queue(<String>['a', 'b']);
        final _Switch closed = _Switch(open: false);
        int transmits = 0;
        final HabotSyncSweep paused = await loop(
          transmit: (HabotOutboxEntry e) async => transmits++,
          governor: closed,
        ).sweep();
        closed.open = true;
        final HabotSyncSweep resumed = await loop(
          transmit: (HabotOutboxEntry e) async => transmits++,
          governor: closed,
        ).sweep();
        return paused.stop == HabotSyncStop.pausedByGovernor &&
            paused.detail.contains('paused by the governor') &&
            transmits == 2 &&
            resumed.sent == 2 &&
            const HabotAlwaysAllow().allowsHeavyWork;
      },
    );

    gate(
      'GEN-05276-G7',
      'Metric: Validation Test Pass Rate. The substitutions and the '
          'unproducible half must be recorded, not implied.',
      'The send success rate is computed from what the loop actually did, and '
          'both the serviceWorker substitution and the coverage gap are stated '
          'in the code',
      () async {
        await queue(<String>['a', 'b', 'c', 'd']);
        final HabotSyncLoop l = loop(
          transmit: (HabotOutboxEntry e) async {
            if (e.id == 'd') {
              throw StateError('rejected');
            }
          },
        );
        await l.sweep();
        return l.totalSent == 3 &&
            l.totalFailed == 1 &&
            (l.sendSuccessRate - 0.75).abs() < 0.0001 &&
            HabotSyncLoop.serviceWorkerSubstitution.contains('browser API') &&
            HabotSyncLoop.coverageNote.contains('NOT PRODUCED');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05276',
        atomicStepReferenceId: 'GEN-05276',
        setupStepAction:
            'Unit-test and validate the implementation of: implement a '
            'background sync subroutine (serviceWorker.sync) to transmit '
            'queued entries when online.',
        implementationOrder: 123,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotSyncLoop / HabotSyncGovernor',
          'Component Properties':
              'consumes Steps 112, 113, 116, 117, 118, 121, 122 and 47; '
              '${HabotSyncStop.values.length} recorded stop reasons; drains '
              'oldest-first, stops on the first unknown outcome, and applies '
              'deltas only after the queue empties',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) is EMPTY on this row. serviceWorker.sync '
              'is a browser API and was substituted; the substitution is '
              'recorded in HabotSyncLoop.serviceWorkerSubstitution.',
        },
        measurements: <AissMeasurement>[
          const AissMeasurement(
            metricName: 'Validation test pass rate (this gate)',
            observed:
                'Seven gates over the sweep: order preserved, offline '
                'respected, stop-on-unknown, dead-lettering, idempotent '
                'sending, governor obedience, and the computed success rate. '
                'All produced from the loop own behaviour rather than from '
                'its configuration.',
            floor: '>= 95% test pass rate',
            optimal: '100% test pass rate',
            ceiling: '100%',
          ),
          const AissMeasurement(
            metricName: 'Code coverage (the other half of the sheet metric)',
            observed:
                'NOT PRODUCED. It needs flutter test --coverage on a machine '
                'with the Dart toolchain; this environment has neither the '
                'toolchain nor the network to install one. No figure is '
                'estimated in its place -- an invented coverage number is '
                'worse than an absent one, because it looks like evidence.',
            floor: '>= 80%',
            optimal: '>= 90%',
            ceiling: '100% (diminishing ROI beyond)',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/data/sync_loop.dart',
        ],
      ),
    );
  });
}
