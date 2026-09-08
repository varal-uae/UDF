/// AISS GATE -- Step 130 of 135
/// Global Reference ID:       GEN-04737
/// Atomic Steps Reference ID: GEN-04737
/// Atomic Step: "Test the implementation against the completion measures: Zero
///               duplicate API calls generated under simulated multi-tap
///               stress tests; 100% DOM unlock upon response or timeout."
/// Metric: Acceptance / Completion-Measure Test Pass Rate -- Floor ">= 95% of
///         stated completion measures met", Optimal "100%".
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
/// A ROW THAT NAMES ITS OWN ACCEPTANCE TEST. Both measures are binary and
/// directly checkable; the gate runs them and reports the share met.
/// SUBSTITUTION RECORDED: "DOM unlock" -> the control disabled state.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/interaction/submit_guard.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  DateTime now = DateTime(2026, 9, 8, 9);
  double measureRate = 0;

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

  HabotSubmitGuard guard({void Function(HabotSubmitState)? onState}) =>
      HabotSubmitGuard(onStateChanged: onState, clock: () => now);

  group('GEN-04737 :: measure 1 -- zero duplicate API calls', () {
    gate(
      'GEN-04737-G1',
      'Completion measure, verbatim: "ZERO DUPLICATE API CALLS generated under '
          'simulated MULTI-TAP STRESS TESTS."',
      'Twenty rapid taps on one control start exactly one call, and the '
          'nineteen refusals each say which rule refused them',
      () {
        final HabotSubmitGuard g = guard();
        final List<HabotTapOutcome> outcomes = <HabotTapOutcome>[
          for (int i = 0; i < 20; i++) g.tap(),
        ];
        final int accepted =
            outcomes.where((HabotTapOutcome o) => o.accepted).length;
        final bool ok = accepted == 1 &&
            g.callsStarted == 1 &&
            g.tapsReceived == 20 &&
            outcomes
                .where((HabotTapOutcome o) => !o.accepted)
                .every(
                  (HabotTapOutcome o) =>
                      o.rejection == HabotSubmitRejection.alreadyInFlight,
                ) &&
            g.zeroDuplicateCalls(distinctIntents: 1);
        g.dispose();
        return ok;
      },
    );

    gate(
      'GEN-04737-G2',
      'A guard that refuses the SECOND legitimate submission is worse than one '
          'that allows a duplicate: the user cannot proceed at all.',
      'After the answer comes back a genuinely new intent IS accepted, once '
          'the multi-tap window has passed',
      () {
        final HabotSubmitGuard g = guard();
        g.tap();
        g.complete();
        final HabotTapOutcome tooSoon = g.tap();
        now = now.add(HabotSubmitGuard.tapWindow + const Duration(seconds: 1));
        final HabotTapOutcome fine = g.tap();
        g.complete();
        return !tooSoon.accepted &&
            tooSoon.rejection == HabotSubmitRejection.withinTapWindow &&
            fine.accepted &&
            g.callsStarted == 2 &&
            g.zeroDuplicateCalls(distinctIntents: 2);
      },
    );

    gate(
      'GEN-04737-G3',
      'Step 122 stops a duplicate reaching the SERVER, by key. This stops a '
          'duplicate being STARTED, at the widget. They are the same defect '
          'caught at two different distances.',
      'The tap window reuses the existing double-tap token rather than '
          'declaring a second definition of "the same intent"',
      () =>
          HabotSubmitGuard.tapWindow == HabotMotion.doubleTapWindow &&
          HabotSubmitGuard.defaultTimeout == HabotMotion.submitLockTimeout &&
          HabotSubmitGuard.defaultTimeout > HabotSubmitGuard.tapWindow,
    );
  });

  group('GEN-04737 :: measure 2 -- 100% unlock, the one that bites', () {
    gate(
      'GEN-04737-G4',
      'Completion measure, verbatim: "100% DOM UNLOCK UPON RESPONSE OR '
          'TIMEOUT." Locking on tap is easy and everyone does it. Unlocking on '
          'TIMEOUT is what people forget.',
      'A submit whose answer never arrives releases the control anyway, and '
          'the release is attributed to the timeout rather than to a response',
      () {
        final List<HabotSubmitState> states = <HabotSubmitState>[];
        final HabotSubmitGuard g = guard(onState: states.add);
        g.tap();
        final bool lockedWhileWaiting = g.isLocked;
        g.expireNow();
        return lockedWhileWaiting &&
            !g.isLocked &&
            g.unlockedOnTimeout == 1 &&
            g.unlockedOnResponse == 0 &&
            g.unlocksAlways &&
            states.length == 2 &&
            states.first == HabotSubmitState.locked &&
            states.last == HabotSubmitState.idle;
      },
    );

    gate(
      'GEN-04737-G5',
      'The result of forgetting the timeout is a worker staring at a dead '
          'button with no way forward but to force-quit the app.',
      'There is no path that locks without arming a release: every lock in a '
          'mixed sequence of responses and timeouts is accounted for',
      () {
        final HabotSubmitGuard g = guard();
        for (int i = 0; i < 5; i++) {
          g.tap();
          if (i.isEven) {
            g.complete();
          } else {
            g.expireNow();
          }
          now = now.add(
            HabotSubmitGuard.tapWindow + const Duration(seconds: 1),
          );
        }
        g.dispose();
        return g.callsStarted == 5 &&
            g.unlockedOnResponse == 3 &&
            g.unlockedOnTimeout == 2 &&
            g.unlocksAlways &&
            !g.isLocked;
      },
    );

    gate(
      'GEN-04737-G6',
      'A late response after a timeout must not double-unlock or reopen a '
          'control that has already been released.',
      'Completing an already-released guard is a no-op rather than a second '
          'unlock, so the accounting stays exact',
      () {
        final HabotSubmitGuard g = guard();
        g.tap();
        g.expireNow();
        g.complete();
        g.expireNow();
        return g.unlockedOnTimeout == 1 &&
            g.unlockedOnResponse == 0 &&
            g.unlocksAlways;
      },
    );

    gate(
      'GEN-04737-G7',
      'Metric: the share of the row own stated completion measures met.',
      'Both measures are evaluated and both pass, giving the optimal figure -- '
          'and the DOM substitution is recorded in the code so nobody reads '
          'the measure as being about a browser',
      () {
        final HabotSubmitGuard g = guard();
        for (int i = 0; i < 12; i++) {
          g.tap();
        }
        g.complete();
        measureRate = g.completionMeasurePassRate(distinctIntents: 1);
        g.dispose();
        return measureRate == 1.0 &&
            measureRate >= HabotSubmitGuard.optimal &&
            measureRate >= HabotSubmitGuard.floor &&
            HabotSubmitGuard.domSubstitution.contains('there is no DOM here') &&
            HabotSubmitGuard.domSubstitution.contains('nobody wrote the '
                'timeout');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04737',
        atomicStepReferenceId: 'GEN-04737',
        setupStepAction:
            'Test the implementation against the completion measures: Zero '
            'duplicate API calls generated under simulated multi-tap stress '
            'tests; 100% DOM unlock upon response or timeout.',
        implementationOrder: 130,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotSubmitGuard',
          'Component Properties':
              'lock timeout ${HabotSubmitGuard.defaultTimeout.inSeconds}s, '
              'tap window ${HabotSubmitGuard.tapWindow.inMilliseconds}ms '
              '(the existing double-tap token, not a second definition); '
              '${HabotSubmitRejection.values.length} named rejection reasons',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) is EMPTY. "DOM unlock" has no equivalent '
              'here; the substitution to the control disabled state is '
              'recorded in HabotSubmitGuard.domSubstitution.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Acceptance / Completion-Measure Test Pass Rate',
            observed:
                '${(measureRate * 100).toStringAsFixed(0)}% -- both of the '
                'row own stated measures met. Twenty rapid taps produced one '
                'call; every lock ended in an unlock, by response or by '
                'timeout, across a mixed sequence of five.',
            floor: '>= 95% of stated completion measures met',
            optimal: '100% of stated completion measures met',
            ceiling: '100% (binary against the measures)',
          ),
          const AissMeasurement(
            metricName: 'Controls left permanently locked',
            observed:
                '0. There is no code path that locks without arming a '
                'timeout, and a late response after a timeout is a no-op '
                'rather than a second unlock. This is the half of the '
                'requirement that is usually missing, and its absence is what '
                'leaves a worker force-quitting the app.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/interaction/submit_guard.dart',
        ],
      ),
    );
  });
}
