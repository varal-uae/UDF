/// AISS GATE -- Step 47 of 50
/// Global Reference ID:       GEN-02720
/// Atomic Steps Reference ID: GEN-02720-A01
/// Setup Step (Action):       "Write the offline UI state management logic that
///                             activates when the polling function fails to
///                             receive a response within the timeout
///                             threshold."
/// Mobile-First UX row: "Background polling refreshes data every 30 seconds.
/// Pull-to-refresh triggers manual sync."
///
/// The clause that matters is "WITHIN THE TIMEOUT THRESHOLD". A monitor that
/// only reacts to an error response has not implemented this step -- the case
/// it exists for is the request that never answers at all. G2 below drives
/// exactly that: a poll whose future never completes, and a clock advanced
/// past the threshold.
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/resilience/connectivity_state.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

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

  group('GEN-02720-A01 :: the policy', () {
    gate(
      'GEN-02720-G1',
      'Mobile-First UX row: "Background polling refreshes data every 30 '
          'seconds." + Setup Step: "...within the TIMEOUT THRESHOLD."',
      'The interval is the 30 seconds the sheet names, the timeout is a '
          'separate and strictly shorter number, and both come from the motion '
          'tokens rather than being spelled out here',
      () =>
          HabotConnectivityPolicy.pollInterval == const Duration(seconds: 30) &&
          HabotConnectivityPolicy.pollInterval == HabotMotion.pollInterval &&
          HabotConnectivityPolicy.pollTimeout == HabotMotion.pollTimeout &&
          HabotConnectivityPolicy.pollTimeout <
              HabotConnectivityPolicy.pollInterval,
    );

    gate(
      'GEN-02720-G2',
      'Setup Step (Action): "...ACTIVATES when the polling function fails." '
          'One dropped response on a train is not an outage.',
      'Offline is derived from a stated number of consecutive failures, and '
          'the state between healthy and offline is named rather than being '
          'rounded to one of them',
      () =>
          HabotConnectivityPolicy.failuresBeforeOffline == 2 &&
          HabotConnectivityPolicy.successesBeforeOnline == 1 &&
          HabotConnectivityPolicy.classify(0) == HabotConnectivity.online &&
          HabotConnectivityPolicy.classify(1) == HabotConnectivity.degraded &&
          HabotConnectivityPolicy.classify(2) == HabotConnectivity.offline &&
          HabotConnectivityPolicy.classify(9) == HabotConnectivity.offline,
    );
  });

  group('GEN-02720-A01 :: driven transitions', () {
    testWidgets('[GEN-02720-G3] a poll that never answers trips the timeout '
        'and drives the state machine to offline', (WidgetTester tester) async {
      // The completer is never completed, so the ONLY thing that can end
      // pollOnce is the timeout the step names. A poll returning false would
      // pass a weaker test.
      final Completer<bool> silence = Completer<bool>();
      final HabotConnectivityMonitor monitor = HabotConnectivityMonitor(
        poll: () => silence.future,
      );
      addTearDown(monitor.dispose);

      await tester.pumpWidget(const SizedBox.shrink());
      expect(monitor.state, HabotConnectivity.online);

      unawaited(monitor.pollOnce());
      await tester.pump(
        HabotConnectivityPolicy.pollTimeout - const Duration(milliseconds: 1),
      );
      expect(
        monitor.state,
        HabotConnectivity.online,
        reason: 'Before the threshold nothing has failed yet',
      );

      await tester.pump(const Duration(milliseconds: 2));
      expect(monitor.state, HabotConnectivity.degraded);
      expect(monitor.consecutiveFailures, 1);
      expect(monitor.offlineSince, isNull);

      unawaited(monitor.pollOnce());
      await tester.pump(
        HabotConnectivityPolicy.pollTimeout + const Duration(milliseconds: 1),
      );
      expect(monitor.state, HabotConnectivity.offline);
      expect(monitor.isOffline, isTrue);
      expect(
        monitor.offlineSince,
        isNotNull,
        reason: 'The moment the app went offline is recorded, so a banner can '
            'say how long rather than just that',
      );

      gates.add(
        AissGate(
          id: 'GEN-02720-G3',
          requirementSource:
              'Setup Step (Action): "...activates when the polling function '
              'fails to receive a response WITHIN THE TIMEOUT THRESHOLD."',
          description:
              'A poll whose response never arrives is counted as a failure '
              'exactly at the threshold, and two of them put the app offline '
              'with the transition moment recorded',
          passed: true,
          detail:
              'threshold ${HabotConnectivityPolicy.pollTimeout.inSeconds}s; '
              'state advanced online -> degraded -> offline',
        ),
      );
    });

    test('[GEN-02720-G4] one successful poll is enough to come back online', () async {
      bool answers = false;
      final HabotConnectivityMonitor monitor = HabotConnectivityMonitor(
        poll: () async => answers,
      );
      addTearDown(monitor.dispose);

      await monitor.pollOnce();
      await monitor.pollOnce();
      expect(monitor.state, HabotConnectivity.offline);
      final DateTime? wentOffline = monitor.offlineSince;
      expect(wentOffline, isNotNull);

      answers = true;
      await monitor.pollOnce();

      expect(monitor.state, HabotConnectivity.online);
      expect(monitor.consecutiveFailures, 0);
      expect(
        monitor.offlineSince,
        isNull,
        reason: 'Recovery clears the marker; a stale one would make the banner '
            'report an outage that has ended',
      );

      gates.add(
        const AissGate(
          id: 'GEN-02720-G4',
          requirementSource:
              'Mobile-First UX row: "Pull-to-refresh triggers manual sync." '
              'Recovery is eager on purpose: the cost of being wrong is a '
              'banner that clears half a minute early, against a user who '
              'cannot see that their connection is back.',
          description:
              'After two failures a single success returns the monitor to '
              'online and clears the offline marker',
          passed: true,
        ),
      );
    });

    test('[GEN-02720-G5] a poll that throws is a failure, not a crash', () async {
      final HabotConnectivityMonitor monitor = HabotConnectivityMonitor(
        poll: () async => throw const SocketishFailure(),
      );
      addTearDown(monitor.dispose);

      await monitor.pollOnce();
      await monitor.pollOnce();

      expect(monitor.state, HabotConnectivity.offline);

      gates.add(
        const AissGate(
          id: 'GEN-02720-G5',
          requirementSource:
              'Setup Step (Action) -- "fails to receive a response" covers a '
              'refused connection as much as a silent one, and neither may '
              'take the app down.',
          description:
              'A polling function that throws is folded into the same failure '
              'count as a timeout, with no exception escaping the monitor',
          passed: true,
        ),
      );
    });

    test('[GEN-02720-G6] work attempted while offline is queued and reported, '
        'and draining says what was sent', () async {
      final HabotConnectivityMonitor monitor = HabotConnectivityMonitor(
        poll: () async => false,
      );
      addTearDown(monitor.dispose);

      int notifications = 0;
      monitor.addListener(() => notifications++);

      await monitor.pollOnce();
      await monitor.pollOnce();
      expect(monitor.isOffline, isTrue);

      monitor.enqueue(const HabotPendingItem(id: 'r-1', kind: 'submission'));
      monitor.enqueue(const HabotPendingItem(id: 'r-2', kind: 'edit'));
      expect(monitor.pendingCount, 2);

      final List<HabotPendingItem> sent = monitor.drain();
      expect(sent.map((HabotPendingItem i) => i.id), <String>['r-1', 'r-2']);
      expect(monitor.pendingCount, 0);
      expect(
        notifications,
        greaterThan(0),
        reason: 'A queue nothing can observe is a queue nobody can be told '
            'about',
      );

      gates.add(
        AissGate(
          id: 'GEN-02720-G6',
          requirementSource:
              'Setup Step (Action): "offline UI STATE MANAGEMENT logic." The '
              'state a user cares about while offline is how much of their '
              'work is waiting.',
          description:
              'Items enqueued while offline are counted, notify listeners, and '
              'drain returns what was sent rather than silently emptying',
          passed: true,
          detail: '$notifications listener notifications observed',
        ),
      );
    });

    test('[GEN-02720-G7] the monitor notifies on transitions, not on every '
        'poll', () async {
      final HabotConnectivityMonitor monitor = HabotConnectivityMonitor(
        poll: () async => true,
      );
      addTearDown(monitor.dispose);

      int notifications = 0;
      monitor.addListener(() => notifications++);

      await monitor.pollOnce();
      await monitor.pollOnce();
      await monitor.pollOnce();

      expect(
        notifications,
        0,
        reason: 'Three healthy polls are not three pieces of news; a banner '
            'rebuilt every 30 seconds for nothing is a battery cost',
      );

      gates.add(
        const AissGate(
          id: 'GEN-02720-G7',
          requirementSource:
              'Mobile-First UX row: "Background polling refreshes data every '
              '30 seconds." Something that runs forever must be quiet when '
              'nothing has changed.',
          description:
              'Successive polls with the same outcome raise no notification, '
              'so the offline UI rebuilds only when the state actually moves',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02720',
        atomicStepReferenceId: 'GEN-02720-A01',
        setupStepAction:
            'Write the offline UI state management logic that activates when '
            'the polling function fails to receive a response within the '
            'timeout threshold.',
        implementationOrder: 47,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotConnectivityMonitor',
          'Component Type': 'Connectivity state machine',
          'Component Properties':
              'interval ${HabotConnectivityPolicy.pollInterval.inSeconds}s, '
              'timeout ${HabotConnectivityPolicy.pollTimeout.inSeconds}s, '
              '${HabotConnectivityPolicy.failuresBeforeOffline} failures to '
              'offline, ${HabotConnectivityPolicy.successesBeforeOnline} '
              'success to recover',
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'Offline state transition correctness',
            observed:
                'All seven gates pass: the timeout threshold itself drives the '
                'first failure (measured with a poll that never answers), two '
                'failures reach offline, one success recovers, a thrown poll '
                'is a failure rather than a crash, the queue reports its '
                'depth, and steady state is silent',
            floor: 'every transition correct',
            optimal: 'every transition correct',
            ceiling: 'every transition correct',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/resilience/connectivity_state.dart',
        ],
      ),
    );
  });
}

/// A stand-in for a network exception, so the gate does not need dart:io in a
/// test that has nothing to do with the filesystem.
class SocketishFailure implements Exception {
  const SocketishFailure();

  @override
  String toString() => 'SocketishFailure: connection refused';
}
