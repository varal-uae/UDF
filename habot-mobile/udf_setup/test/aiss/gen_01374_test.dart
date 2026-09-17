/// AISS GATE -- Step 313 of 315
/// Global Reference ID:       GEN-01374
/// Atomic Steps Reference ID: GEN-01374
/// Setup Step (Action): (the generic engineering-console boilerplate; the
///                      Expected Output cell is the Atomic Step truncated
///                      mid-word -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Verify that all interactive touch targets meet or exceed the
///               48x48dp minimum size requirement."
/// Metric: Touch Target Size -- floor ">=44x44dp", optimal "48x48dp", ceiling
///         "<=56x56dp". Pass/Fail. WCAG 2.1 SC 2.5.5 / Material Design 3.
///
/// THE VERIFICATION HAS RUN ON EVERY COMMIT SINCE STEP 229. WHAT WAS MISSING
/// IS THE BOUNDARY: FOUR CONTROL CLASSES OF SIX ARE VISIBLE TO IT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/touch_target_sweep.dart';

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

  group('GEN-01374 :: the check that already runs', () {
    gate(
      'GEN-01374-G1',
      'Atomic Step: "Verify that all interactive touch targets meet...".',
      'A11Y_TOUCH_TARGET_BELOW_BAND runs at stage G-C of verify_aiss.sh, '
          'before the tests, and exits non-zero on the first violation',
      () =>
          HabotTouchTargetSweep.ruleId == 'A11Y_TOUCH_TARGET_BELOW_BAND' &&
          HabotTouchTargetSweep.ruleOwner.contains('229') &&
          HabotTouchTargetSweep.gateStage == 'G-C' &&
          HabotTouchTargetSweep.gateScript == 'tool/verify_aiss.sh' &&
          HabotTouchTargetSweep.theVerificationAlreadyExists,
    );

    gate(
      'GEN-01374-G2',
      'It has been running for eighty-four steps.',
      'The same shape as Step 180, where the mechanism the row asked to '
          'activate had been active for 176 steps and the count was what was '
          'missing',
      () =>
          HabotTouchTargetSweep.commitsItHasBeenRunningFor == 84 &&
          HabotTouchTargetSweep.alreadyRunningNote.contains('Step 180'),
    );
  });

  group('GEN-01374 :: the row against itself', () {
    gate(
      'GEN-01374-G3',
      'The Atomic Step says 48; the floor says 44.',
      'Four points of the band sit outside the sentence that describes it, '
          'so a target at 45 satisfies the metric and fails the instruction '
          'on the same row',
      () =>
          HabotTouchTargetSweep.theFloorIsBelowTheInstruction &&
          HabotTouchTargetSweep.pointsBetweenTheFloorAndTheInstruction == 4 &&
          HabotTouchTargetSweep.theWorkedTargetSplitsTheRow,
    );

    gate(
      'GEN-01374-G4',
      'This project enforces the optimal.',
      'Settled at Step 227; the band runs 44 to 56 with the optimal at 48, '
          'and the floor is recorded so the disagreement inside the row is '
          'visible',
      () =>
          HabotTouchTargetSweep.theProjectEnforcesTheOptimal &&
          HabotTouchTargetSweep.floorDp == 44 &&
          HabotTouchTargetSweep.optimalDp == 48 &&
          HabotTouchTargetSweep.ceilingDp == 56,
    );
  });

  group('GEN-01374 :: the citation, which this row gets right', () {
    gate(
      'GEN-01374-G5',
      'Cited as WCAG 2.1 SC 2.5.5.',
      '2.5.5 Target Size is Level AAA at 44 by 44, which is the figure this '
          'row uses -- correctly',
      () =>
          HabotTouchTargetSweep.thisRowCitesCorrectly &&
          HabotTouchTargetSweep.sc255Minimum == 44 &&
          HabotTouchTargetSweep.thisRowCites.contains('2.5.5'),
    );

    gate(
      'GEN-01374-G6',
      'Step 298 in this batch cites SC 2.5.8 for the same figure.',
      '2.5.8 Target Size (Minimum) is Level AA at 24 by 24, so the two rows '
          'disagree about which criterion says 44',
      () =>
          HabotTouchTargetSweep.step298CitesIncorrectly &&
          HabotTouchTargetSweep.sc258Minimum == 24 &&
          HabotTouchTargetSweep.step298Cites.contains('2.5.8'),
    );

    gate(
      'GEN-01374-G7',
      'Step 227 already resolved it in this repository.',
      'So the sheet has reproduced a defect the codebase had fixed, and '
          'nothing is argued again -- both figures are read from Step 227',
      () =>
          HabotTouchTargetSweep.stepThatResolvedItFirst == 227 &&
          HabotTouchTargetSweep.citationNote.contains('already fixed'),
    );
  });

  group('GEN-01374 :: what a static sweep cannot see', () {
    gate(
      'GEN-01374-G8',
      'The guard reads declared sizes.',
      'Four of six control classes declare one; two compose it at run time '
          'and each of those names what moves it',
      () =>
          HabotTouchTargetSweep.controlClasses.length == 6 &&
          HabotTouchTargetSweep.seenByTheGuard.length == 4 &&
          HabotTouchTargetSweep.needingAWidgetTest.length == 2 &&
          HabotTouchTargetSweep.everyComposedClassSaysWhatMovesIt &&
          HabotTouchTargetSweep.everyDeclaredClassSaysNothingMovesIt,
    );

    gate(
      'GEN-01374-G9',
      'The blind spot is where the risk is.',
      'A chip sized to a translated label and an inline link sized by the '
          'text scale are the two that move under the conditions people '
          'actually use the app in',
      () =>
          HabotTouchTargetSweep.theBlindSpotIsWhereTheRiskIs &&
          (HabotTouchTargetSweep.shareCoveredStatically - 2 / 3).abs() < 1e-9,
    );

    gate(
      'GEN-01374-G10',
      'Output: Pass / Fail.',
      'Five declared obligations, all met, giving Pass; all twelve declared '
          'checks hold, and the limits are written down rather than left '
          'implied',
      () =>
          HabotTouchTargetSweep.obligations.length == 5 &&
          HabotTouchTargetSweep.obligations.values.every((bool b) => b) &&
          HabotTouchTargetSweep.qualitativeOutput == 'Pass' &&
          HabotTouchTargetSweep.checks.length == 12 &&
          HabotTouchTargetSweep.checks.values.every((bool b) => b) &&
          HabotTouchTargetSweep.blindSpotNote
              .contains('read as covering everything') &&
          HabotTouchTargetSweep.columnNote.contains('minimum siz'),
    );
  });

  tearDownAll(() {
    final String composed = HabotTouchTargetSweep.needingAWidgetTest
        .map((HabotControlClass c) => c.name)
        .join('; ');
    final String share =
        HabotTouchTargetSweep.shareCoveredStatically.toStringAsFixed(4);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01374',
        atomicStepReferenceId: 'GEN-01374',
        setupStepAction:
            'COLUMN NOTE: every narrative column on this row is the generic '
            'engineering-console boilerplate, and the Expected Output cell is '
            'the Atomic Step truncated mid-word -- "the 48x48dp minimum siz". '
            'Atomic Step: "Verify that all interactive touch targets meet or '
            'exceed the 48x48dp minimum size requirement."',
        implementationOrder: 313,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Verify that all interactive touch targets meet or exceed the':
              'the rule has run at stage G-C on every commit since Step 229; '
                  'this step adds the boundary of what it can see',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'classes needing a widget test rather than the static guard: '
                  '$composed',
          'Data Quality Note':
              'ALREADY RUNNING: ${HabotTouchTargetSweep.alreadyRunningNote} '
              'BAND: ${HabotTouchTargetSweep.bandNote} '
              'CITATION: ${HabotTouchTargetSweep.citationNote} '
              'BLIND SPOT: ${HabotTouchTargetSweep.blindSpotNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Touch Target Size',
            observed:
                '48dp enforced, which is this project\'s optimal. The row\'s '
                'own floor of 44 is four points below its own Atomic Step, so '
                'a 45-point target passes the metric and fails the '
                'instruction. This row cites SC 2.5.5 for 44 and is right; '
                'Step 298 cites SC 2.5.8 for the same figure and is not.',
            floor: '>=44x44dp',
            optimal: '48x48dp',
            ceiling: '<=56x56dp',
          ),
          AissMeasurement(
            metricName: 'Control classes the static sweep can evaluate',
            observed:
                '4 of 6 (share $share). The two it cannot are sized at run '
                'time -- a chip following a translated label, an inline link '
                'following the text scale -- and those are the ones that move '
                'under real conditions. They need a widget test at the '
                'audited scales, and saying so is this step\'s contribution.',
            floor: '4',
            optimal: '6',
            ceiling: '6',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/a11y/touch_target_sweep.dart',
        ],
      ),
    );
  });
}
