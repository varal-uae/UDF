/// AISS GATE -- Step 120 of 135
/// Global Reference ID:       GEN-00247
/// Atomic Steps Reference ID: GEN-00247
/// Atomic Step: "Pause the live stream when the app transitions to mobile
///               background state."
/// Metric: General Task Completion Quality -- a Definition-of-Done
///         placeholder. Reported as NOT PRODUCED.
///
/// CONTAMINATED COLUMN, RECORDED: Setup Step (Action) on this row reads
/// "Ensure the MasterLayout handles safe area insets -- accounts for notch,
/// status bar, and home gesture bar." That is a layout requirement owned and
/// gated by Step 8 (RCGLA-018). It is unrelated to pausing on backgrounding,
/// it is NOT gated here, and nothing was built from it.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/mto/clock_suspension.dart';
import 'package:udf_setup/design_system/resilience/lifecycle_observer.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  DateTime now = DateTime(2026, 9, 8, 9);

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

  /// A stand-in for whichever real clock a binding wraps. The three real ones
  /// are named by [HabotRunningClock]; this proves the binding mechanism.
  ({HabotSuspendedClockBinding binding, List<bool> paused}) bindingFor(
    HabotRunningClock clock,
    HabotSuspendableClock suspendable,
  ) {
    final List<bool> paused = <bool>[false];
    return (
      binding: HabotSuspendedClockBinding(
        clock: clock,
        suspendable: suspendable,
        pause: () => paused[0] = true,
        resume: () => paused[0] = false,
        isPaused: () => paused[0],
      ),
      paused: paused,
    );
  }

  group('GEN-00247 :: the clock stops', () {
    gate(
      'GEN-00247-G1',
      'Atomic Step: "PAUSE ... when the app transitions to mobile background '
          'state." In this app "the live stream" is three running clocks.',
      'A suspendable clock does not advance while the app is backgrounded, so '
          'a deadline a PERSON is expected to meet is measured against time '
          'they could actually see',
      () {
        final HabotSuspendableClock clock = HabotSuspendableClock(
          wallClock: () => now,
        );
        final DateTime before = clock.now();
        clock.onBackgrounded();
        now = now.add(const Duration(minutes: 4));
        final DateTime during = clock.now();
        clock.onForegrounded();
        now = now.add(const Duration(minutes: 1));
        final DateTime after = clock.now();
        return during == before &&
            after.difference(before) == const Duration(minutes: 1) &&
            clock.suspendedTotal == const Duration(minutes: 4) &&
            clock.visible(const Duration(minutes: 5)) ==
                const Duration(minutes: 1);
      },
    );

    gate(
      'GEN-00247-G2',
      'Wall-clock time must still be correct: a deadline the SERVER also '
          'measures cannot be moved by the client backgrounding.',
      'The suspendable clock is a separate reading, not a replacement -- the '
          'wall clock it wraps is untouched',
      () {
        final DateTime mark = now;
        final HabotSuspendableClock clock = HabotSuspendableClock(
          wallClock: () => now,
        );
        clock.onBackgrounded();
        now = now.add(const Duration(minutes: 10));
        final bool wallAdvanced =
            now.difference(mark) >= const Duration(minutes: 10);
        final bool suspendedDidNot = clock.now() == mark;
        clock.onForegrounded();
        return wallAdvanced && suspendedDidNot && !clock.isSuspended;
      },
    );
  });

  group('GEN-00247 :: all three, by name', () {
    gate(
      'GEN-00247-G3',
      'From the build order: the three running clocks are the Step 66 dispatch '
          'clock, the Step 93 interaction timer and the Step 94 reclaim '
          'window -- "all three of which currently keep running against a user '
          'who cannot see them".',
      'Each is declared individually with its owning step and the unfairness '
          'it causes, so none can be quietly dropped, and a clock left unbound '
          'is reported as unbound rather than assumed handled',
      () {
        final HabotLifecycleObserver observer = HabotLifecycleObserver(
          clock: () => now,
        );
        final HabotSuspendableClock suspendable = HabotSuspendableClock(
          wallClock: () => now,
        );
        final HabotClockSuspension suspension = HabotClockSuspension(
          observer: observer,
          clock: suspendable,
        );
        final bool startsIncomplete =
            !suspension.isComplete && suspension.unbound.length == 3;

        for (final HabotRunningClock c in HabotRunningClock.values) {
          suspension.bind(bindingFor(c, suspendable).binding);
        }
        return startsIncomplete &&
            suspension.isComplete &&
            suspension.unbound.isEmpty &&
            HabotRunningClock.values.length == 3 &&
            HabotRunningClock.values.every(
              (HabotRunningClock c) =>
                  c.owningStep.startsWith('Step ') &&
                  c.unfairnessIfUnpaused.length > 40,
            );
      },
    );

    gate(
      'GEN-00247-G4',
      'This is a FAIRNESS bug, not a performance one: a worker losing a job to '
          'a clock that ran while their phone was in their pocket has lost '
          'income to a clock nobody told them about.',
      'Backgrounding pauses every bound clock, and the unfairness each one '
          'causes is stated in the code rather than left to a reviewer memory',
      () {
        final HabotLifecycleObserver observer = HabotLifecycleObserver(
          clock: () => now,
        );
        final HabotSuspendableClock suspendable = HabotSuspendableClock(
          wallClock: () => now,
        );
        final HabotClockSuspension suspension = HabotClockSuspension(
          observer: observer,
          clock: suspendable,
        );
        final List<List<bool>> flags = <List<bool>>[];
        for (final HabotRunningClock c in HabotRunningClock.values) {
          final ({HabotSuspendedClockBinding binding, List<bool> paused}) b =
              bindingFor(c, suspendable);
          flags.add(b.paused);
          suspension.bind(b.binding);
        }
        observer.background();
        final bool allPaused = flags.every((List<bool> f) => f[0]);
        final bool noneStillRunning = suspension.stillRunning.isEmpty;
        observer.foreground();
        final bool allResumed = flags.every((List<bool> f) => !f[0]);
        return allPaused &&
            noneStillRunning &&
            allResumed &&
            HabotRunningClock.dispatchAcceptanceWindow.unfairnessIfUnpaused
                .contains('pocket');
      },
    );

    gate(
      'GEN-00247-G5',
      'A clock bound but not actually stopping is worse than one nobody bound: '
          'it looks handled.',
      'A binding whose pause does nothing is reported as still running after a '
          'backgrounding, and drags the observer release rate down with it',
      () {
        final HabotLifecycleObserver observer = HabotLifecycleObserver(
          clock: () => now,
        );
        final HabotSuspendableClock suspendable = HabotSuspendableClock(
          wallClock: () => now,
        );
        final HabotClockSuspension suspension = HabotClockSuspension(
          observer: observer,
          clock: suspendable,
        );
        suspension.bind(
          HabotSuspendedClockBinding(
            clock: HabotRunningClock.interactionTimer,
            suspendable: suspendable,
            pause: () {},
            resume: () {},
            isPaused: () => false,
          ),
        );
        final HabotLifecycleSweep sweep = observer.background();
        return suspension.stillRunning.single ==
                HabotRunningClock.interactionTimer &&
            !sweep.isClean &&
            sweep.failures.single.contains('interactionTimer') &&
            sweep.failures.single.contains('Step 93');
      },
    );

    gate(
      'GEN-00247-G6',
      'The Setup Step (Action) on this row is a layout requirement belonging '
          'to another step.',
      'The contamination is recorded in the code, so a later reader is told '
          'the column was read and rejected rather than missed',
      () =>
          HabotClockSuspension.contaminationNote.contains('safe area insets') &&
          HabotClockSuspension.contaminationNote.contains('RCGLA-018') &&
          HabotClockSuspension.contaminationNote.contains('not gated here'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00247',
        atomicStepReferenceId: 'GEN-00247',
        setupStepAction:
            'Pause the live stream when the app transitions to mobile '
            'background state.',
        implementationOrder: 120,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotSuspendableClock / HabotClockSuspension / '
              'HabotSuspendedClockBinding',
          'Component Properties':
              '${HabotRunningClock.values.length} named clocks, each with its '
              'owning step and the unfairness it causes; an unbound clock and '
              'a bound-but-still-running clock are both reported',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'CONTAMINATED COLUMN: Setup Step (Action) is a MasterLayout '
              'safe-area requirement owned by Step 8 (RCGLA-018). Not gated '
              'here; nothing was built from it. The metric is a '
              'Definition-of-Done placeholder.',
        },
        measurements: <AissMeasurement>[
          const AissMeasurement(
            metricName: 'Clocks still running against a backgrounded user',
            observed:
                '0 of 3 once bound. Each of the three the build order names '
                'is declared individually, so an unbound one is reported as '
                'unbound rather than assumed handled, and a bound one that '
                'does not actually stop is named in the sweep.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
          const AissMeasurement(
            metricName: 'General Task Completion Quality (the sheet metric)',
            observed:
                'NOT PRODUCED. A Definition-of-Done placeholder on a step that '
                'names a specific, observable behaviour. The behaviour was '
                'measured instead; no completion-quality figure is invented.',
            floor: 'Task completed with documented exceptions',
            optimal: '100% completion matching stated implementation-step '
                'intent',
            ceiling: '1',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/mto/clock_suspension.dart',
        ],
      ),
    );
  });
}
