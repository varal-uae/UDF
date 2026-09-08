/// AISS GATE -- Step 121 of 135
/// Global Reference ID:       GEN-02731
/// Atomic Steps Reference ID: GEN-02731
/// Atomic Step: "Write the reconnection logic with exponential backoff that
///               activates when the WebSocket connection is dropped."
/// Metric: Real-Time Event Delivery Latency -- Floor sub-500ms, Optimal
///         sub-200ms, Ceiling "latency exceeding 1 second degrades real-time
///         UX significantly".
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
/// METRIC NOT PRODUCIBLE: needs a live socket and a server. What is gated is
/// the shape of the retry schedule, which is fully determined.
library;

import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/resilience/connectivity_state.dart';
import 'package:udf_setup/design_system/resilience/reconnect_policy.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];

  void gate(String id, String source, String description, bool Function() run) {
    test('[$id] $description', () {
      bool passed = false;
      try {
        passed = run();
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

  void asyncGate(
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

  /// Deterministic, so the jitter can be checked without knowing a seed.
  HabotReconnectPolicy policy({
    HabotConnectivityMonitor? monitor,
    int seed = 7,
  }) => HabotReconnectPolicy(
    monitor: monitor,
    random: math.Random(seed),
  );

  group('GEN-02731 :: the shape of the schedule', () {
    gate(
      'GEN-02731-G1',
      'Atomic Step: "reconnection logic with EXPONENTIAL BACKOFF".',
      'The un-jittered window doubles from the base and then stops at the '
          'ceiling -- growth that is checked against the declared tokens '
          'rather than against numbers written into the test',
      () {
        final Duration base = HabotReconnectPolicy.base;
        return HabotReconnectPolicy.windowFor(1) == base &&
            HabotReconnectPolicy.windowFor(2) == base * 2 &&
            HabotReconnectPolicy.windowFor(3) == base * 4 &&
            HabotReconnectPolicy.windowFor(4) == base * 8 &&
            HabotReconnectPolicy.windowFor(0) == Duration.zero &&
            HabotReconnectPolicy.windowFor(99) == HabotReconnectPolicy.ceiling;
      },
    );

    gate(
      'GEN-02731-G2',
      'The cap on the DELAY is what protects the battery. Waiting longer than '
          'the Step 47 poll interval buys nothing, because the connectivity '
          'monitor is already checking at least that often.',
      'The window reaches the ceiling and never exceeds it, and the attempt at '
          'which it does is derived rather than written down',
      () {
        final int n = HabotReconnectPolicy.attemptsToCeiling;
        return HabotReconnectPolicy.ceiling ==
                HabotConnectivityPolicy.pollInterval &&
            HabotReconnectPolicy.windowFor(n) ==
                HabotReconnectPolicy.ceiling &&
            HabotReconnectPolicy.windowFor(n - 1) <
                HabotReconnectPolicy.ceiling &&
            List<int>.generate(30, (int i) => i + 1).every(
              (int a) =>
                  HabotReconnectPolicy.windowFor(a) <=
                  HabotReconnectPolicy.ceiling,
            );
      },
    );

    gate(
      'GEN-02731-G3',
      'Without jitter every device that lost the same tower reconnects at the '
          'same instant, and the server that just came back falls over again.',
      'Every delay is drawn from across the WHOLE window rather than wobbling '
          'around it, and the spread over many draws covers both halves of the '
          'window -- which a small wobble would not',
      () {
        bool sawLowHalf = false;
        bool sawHighHalf = false;
        bool everInsideWindow = true;
        for (int seed = 0; seed < 40; seed++) {
          final HabotReconnectPolicy p = policy(seed: seed);
          p.onDropped();
          for (int i = 0; i < 5; i++) {
            final HabotBackoffStep s = p.nextDelay();
            if (s.delay > s.ceiling) {
              everInsideWindow = false;
            }
            if (s.delay.inMilliseconds < s.ceiling.inMilliseconds * 0.5) {
              sawLowHalf = true;
            }
            if (s.delay.inMilliseconds > s.ceiling.inMilliseconds * 0.5) {
              sawHighHalf = true;
            }
          }
        }
        return everInsideWindow && sawLowHalf && sawHighHalf;
      },
    );
  });

  group('GEN-02731 :: when to stop, and when not to start', () {
    gate(
      'GEN-02731-G4',
      'A field worker on rural connectivity is offline for hours, not seconds. '
          'A client that gives up permanently needs restarting to work again.',
      'There is no attempt limit, stated as a property rather than left for a '
          'reader to notice, and the policy keeps producing delays past the '
          'point any sensible limit would have been',
      () {
        final HabotReconnectPolicy p = policy();
        p.onDropped();
        for (int i = 0; i < 200; i++) {
          p.nextDelay();
        }
        return HabotReconnectPolicy.givesUpEventually == false &&
            p.attempt == 200 &&
            p.history.length == 200 &&
            p.history.last.regime == HabotBackoffRegime.capped;
      },
    );

    asyncGate(
      'GEN-02731-G5',
      'Backoff is for a server that will not answer, not for a radio that is '
          'switched off.',
      'While the Step 47 monitor reports no network the policy idles at the '
          'poll interval instead of climbing, and the attempt counter does not '
          'advance -- so the first real retry after the radio returns starts '
          'from the bottom',
      () async {
        final HabotConnectivityMonitor monitor = HabotConnectivityMonitor(
          poll: () async => false,
        );
        // Two consecutive failures is the Step 47 threshold for offline.
        await monitor.pollOnce();
        await monitor.pollOnce();
        final HabotReconnectPolicy p = policy(monitor: monitor);
        p.onDropped();
        final HabotBackoffStep idle = p.nextDelay();
        final bool idledNotClimbed =
            idle.regime == HabotBackoffRegime.offlineIdle &&
            idle.delay == HabotReconnectPolicy.offlineIdle &&
            p.attempt == 0;

        // The radio comes back: the policy climbs again, from the bottom.
        final HabotConnectivityMonitor online = HabotConnectivityMonitor(
          poll: () async => true,
        );
        await online.pollOnce();
        final HabotReconnectPolicy q = policy(monitor: online);
        q.onDropped();
        final HabotBackoffStep first = q.nextDelay();

        monitor.dispose();
        online.dispose();
        return monitor.isOffline &&
            idledNotClimbed &&
            !online.isOffline &&
            first.regime == HabotBackoffRegime.initial &&
            first.ceiling == HabotReconnectPolicy.base;
      },
    );

    gate(
      'GEN-02731-G6',
      'The next drop must start from the bottom rather than from wherever the '
          'last outage ended.',
      'A successful connection resets the attempt counter and the '
          'down-for clock; a further failure does not',
      () {
        final HabotReconnectPolicy p = policy();
        p.onDropped();
        p.nextDelay();
        p.nextDelay();
        p.nextDelay();
        final bool climbed = p.attempt == 3;
        p.onDropped();
        final bool notResetByAnotherDrop = p.attempt == 3;
        p.onConnected();
        final bool resetBySuccess = p.attempt == 0 && p.downFor == null;
        final HabotBackoffStep next = p.nextDelay();
        return climbed &&
            notResetByAnotherDrop &&
            resetBySuccess &&
            next.regime == HabotBackoffRegime.initial &&
            next.ceiling == HabotReconnectPolicy.base;
      },
    );

    gate(
      'GEN-02731-G7',
      'The metric names an event delivery latency this suite cannot produce.',
      'That is recorded in the code, so nobody reads the schedule figures as a '
          'latency measurement',
      () =>
          HabotReconnectPolicy.metricNote.contains('NOT PRODUCED') &&
          HabotReconnectPolicy.metricNote.contains('live socket'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02731',
        atomicStepReferenceId: 'GEN-02731',
        setupStepAction:
            'Write the reconnection logic with exponential backoff that '
            'activates when the WebSocket connection is dropped.',
        implementationOrder: 121,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotReconnectPolicy / HabotBackoffStep',
          'Component Properties':
              'base ${HabotReconnectPolicy.base.inMilliseconds}ms, doubling, '
              'capped at ${HabotReconnectPolicy.ceiling.inSeconds}s '
              '(reached at attempt ${HabotReconnectPolicy.attemptsToCeiling}); '
              'full jitter; ${HabotBackoffRegime.values.length} recorded '
              'regimes; no attempt limit',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) is EMPTY on this row.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Retry schedule shape',
            observed:
                'Windows double from ${HabotReconnectPolicy.base.inMilliseconds}ms '
                'and cap at ${HabotReconnectPolicy.ceiling.inSeconds}s at '
                'attempt ${HabotReconnectPolicy.attemptsToCeiling}. Over 200 '
                'draws across 40 seeds every delay fell inside its window and '
                'the spread covered both halves of it, which is full jitter '
                'rather than a wobble. No attempt limit exists.',
            floor: 'bounded delay',
            optimal: 'bounded delay with full jitter',
            ceiling: 'bounded delay with full jitter',
          ),
          const AissMeasurement(
            metricName: 'Real-Time Event Delivery Latency (the sheet metric)',
            observed:
                'NOT PRODUCED. It needs a live socket and a server on the '
                'other end of it; this suite has neither and no number is '
                'invented. Step 127 measures a real round trip against a '
                'transport, which is the closest thing a client can produce.',
            floor: 'sub-500ms',
            optimal: 'sub-200ms',
            ceiling: 'over 1s degrades real-time UX significantly',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/resilience/reconnect_policy.dart',
        ],
      ),
    );
  });
}
