/// AISS GATE -- Step 226 of 235
/// Global Reference ID:       GEN-02356
/// Atomic Steps Reference ID: GEN-02356
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement swipe-to-dismiss functionality for the snackbars."
/// Metric: Process Completion Rate -- Floor 0, Optimal "95-100%", Ceiling 1.
///         Complete/Partial/Not Complete.
///
/// MECHANICAL SHEET DEFECT: three bounds in three units -- a count, a
/// percentage range and a fraction. No ordering survives all three readings.
/// And a snackbar that can be swiped away can take its action with it, which is
/// Step 193's rule applied to a surface even easier to lose than a FAB.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/feedback/snackbar_dismissal.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double completion = 0;

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

  group('GEN-02356 :: the gesture, and what it can take with it', () {
    gate(
      'GEN-02356-G1',
      'Atomic Step: "Implement swipe-to-dismiss functionality for the '
          'snackbars."',
      'Every declared snackbar may be swiped away, including the ones carrying '
          'an action -- refusing the gesture on the ones that matter most is '
          'how a gesture becomes unpredictable',
      () =>
          HabotSnackbarDismissal.declaredSnackbars
              .every(HabotSnackbarDismissal.maySwipe) &&
          HabotSnackbarDismissal.declaredSnackbars.length == 4 &&
          HabotSnackbarDismissal.dismissThreshold == 0.4,
    );

    gate(
      'GEN-02356-G2',
      'Step 68 gives an error snackbar a retry, and '
          'snackbarDisplayWithAction is two seconds longer than the plain '
          'duration for exactly that reason.',
      'The two durations come from the declared tokens and the extra window an '
          'action buys is measured at two seconds -- which is the window a '
          'swipe hands back in one motion',
      () =>
          HabotSnackbarDismissal.durationFor(
                HabotSnackbarDismissal.declaredSnackbars[1],
              ) ==
              HabotMotion.snackbarDisplayWithAction &&
          HabotSnackbarDismissal.durationFor(
                HabotSnackbarDismissal.declaredSnackbars[0],
              ) ==
              HabotMotion.snackbarDisplay &&
          HabotSnackbarDismissal.actionGraceWindow.inSeconds == 2 &&
          HabotSnackbarDismissal.swipeIsFasterThanReadingNote
              .contains('faster than reading'),
    );

    gate(
      'GEN-02356-G3',
      'Step 193: "the FAB is never the only route to its action." A snackbar '
          'is easier to lose than a FAB.',
      'A snackbar whose action exists nowhere else is refused before it is '
          'shown, and the refusal names what a swipe would cost -- while every '
          'snackbar this product actually declares passes, because each one '
          'with an action has another route to it',
      () {
        final HabotSnackbarPayload bad =
            HabotSnackbarDismissal.malformedExample;
        return !HabotSnackbarDismissal.isWellFormed(bad) &&
            HabotSnackbarDismissal.swipeLosesTheAction(bad) &&
            HabotSnackbarDismissal.malformedReason(bad)
                .contains('only route to it') &&
            HabotSnackbarDismissal.malformedReason(bad)
                .contains('Retry upload') &&
            HabotSnackbarDismissal.declaredSnackbars
                .every(HabotSnackbarDismissal.isWellFormed) &&
            HabotSnackbarDismissal.malformedReason(
              HabotSnackbarDismissal.declaredSnackbars[1],
            ).isEmpty;
      },
    );

    gate(
      'GEN-02356-G4',
      'Step 225 makes its gesture direction-aware. This one deliberately does '
          'not.',
      'A snackbar is a notification rather than a navigation surface, so '
          'dismissing it is not a directional act and MD3 accepts a horizontal '
          'swipe either way -- said out loud, because one gesture being '
          'direction-aware and another not otherwise reads as an oversight',
      () =>
          !HabotSnackbarDismissal.isDirectional &&
          HabotSnackbarDismissal.directionNote
              .contains('not a directional act') &&
          HabotSnackbarDismissal.directionNote.contains('decision'),
    );
  });

  group('GEN-02356 :: the band, and what was measured', () {
    gate(
      'GEN-02356-G5',
      'Metric bounds: Floor 0, Optimal "95-100%", Ceiling 1.',
      'Three bounds in three units -- a count, a percentage range and a '
          'fraction -- so no ordering survives all three readings. The '
          'fractional reading is used because two of the three already are '
          'fractions, and the choice is recorded rather than made silently',
      () =>
          HabotSnackbarDismissal.rowFloor == '0' &&
          HabotSnackbarDismissal.rowOptimal == '95-100%' &&
          HabotSnackbarDismissal.rowCeiling == '1' &&
          HabotSnackbarDismissal.bandUnitsNote.contains('three units') &&
          HabotSnackbarDismissal.bandUnitsNote
              .contains('admits every value') &&
          HabotSnackbarDismissal.floor == 0.95 &&
          HabotSnackbarDismissal.ceiling == 1.0,
    );

    gate(
      'GEN-02356-G6',
      '"A snackbar swiped away at 400ms and one that timed out at four seconds '
          'are different signals about the same message."',
      'Four exit reasons are declared and each is attributable, so a counter '
          'cannot merge a dismissal with a timeout and report that the '
          'snackbar was shown',
      () =>
          HabotSnackbarExit.values.length == 4 &&
          HabotSnackbarExit.values
              .every(HabotSnackbarDismissal.exitIsAttributable) &&
          HabotSnackbarDismissal.attributionNote
              .contains('nothing about whether it was read'),
    );

    gate(
      'GEN-02356-G7',
      'Metric: Process Completion Rate -- under the recorded reading, floor '
          '0.95.',
      'All four declared snackbars are well formed, giving 1.0 and a Complete, '
          'and all nine checks hold -- with the malformed example kept beside '
          'them as the shape the rule exists to refuse rather than as part of '
          'the population',
      () {
        completion = HabotSnackbarDismissal.completionRate;
        return completion == 1.0 &&
            completion >= HabotSnackbarDismissal.floor &&
            HabotSnackbarDismissal.qualitativeOutput == 'Complete' &&
            HabotSnackbarDismissal.checks.length == 9 &&
            HabotSnackbarDismissal.checks.values.every((bool b) => b) &&
            HabotSnackbarDismissal.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02356',
        atomicStepReferenceId: 'GEN-02356',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Implement swipe-to-dismiss functionality for the '
            'snackbars."',
        implementationOrder: 226,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotSnackbarDismissal / HabotSnackbarPayload',
          'Component Properties':
              '${HabotSnackbarDismissal.declaredSnackbars.length} declared '
              'snackbars, every one swipeable; horizontal either way with a '
              '${(HabotSnackbarDismissal.dismissThreshold * 100)'
              '.toStringAsFixed(0)}% threshold; '
              '${HabotSnackbarExit.values.length} attributable exit reasons; '
              'durations from the declared tokens, '
              '${HabotSnackbarDismissal.actionGraceWindow.inSeconds}s longer '
              'when an action is carried',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'MECHANICAL SHEET DEFECT: the three metric bounds are in three '
              'units -- Floor 0 is a count, Optimal "95-100%" is a percentage '
              'range, Ceiling 1 is a fraction. Read as fractions the band '
              'admits every value; read as percentages the optimal is a range '
              'and the other two are not. No ordering survives all three '
              'readings. The fractional reading is used because two of the '
              'three already are fractions, and the choice is recorded rather '
              'than made silently. FINDING: a snackbar that can be swiped away '
              'can take its action with it. Step 68 gives an error snackbar a '
              'retry, and snackbarDisplayWithAction is two seconds longer than '
              'the plain duration precisely because a user needs time to reach '
              'the action -- a swipe hands those two seconds back in one '
              'motion, before the message has been read. The rule that '
              'survives is Step 193\'s: the snackbar is never the only route '
              'to its action, and a payload that breaks it is refused before '
              'it is shown. DELIBERATE DIFFERENCE FROM STEP 225: that gesture '
              'is direction-aware and this one is not, because a snackbar is a '
              'notification rather than a navigation surface. Said out loud so '
              'the difference reads as a decision.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Completion Rate',
            observed:
                '${completion.toStringAsFixed(2)} -- all '
                '${HabotSnackbarDismissal.declaredSnackbars.length} declared '
                'snackbars are well formed, meaning every one carrying an '
                'action has another route to that action. Reported under the '
                'fractional reading of a band whose three bounds are in three '
                'different units.',
            floor: '0.95 (fractional reading; the row says 0)',
            optimal: '1.0 (the row says "95-100%")',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Actions reachable only from a swipeable surface',
            observed:
                '0. The malformed example -- an upload failure whose only '
                'retry is on the snackbar -- is kept beside the declared set '
                'as the shape the rule exists to refuse, and is refused with a '
                'reason naming what a swipe would cost.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/feedback/snackbar_dismissal.dart',
        ],
      ),
    );
  });
}
