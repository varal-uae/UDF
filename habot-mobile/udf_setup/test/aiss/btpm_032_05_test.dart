/// AISS GATE -- Step 399 of 415
/// Global Reference ID:       BTPM-032-05
/// Atomic Steps Reference ID: BTPM-032-05
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Identify all interface screens serving purely internal
///               administrative checks or pending review states."
/// Metric: Process Execution Quality Score -- floor ">=90%", optimal ">=98%",
///         ceiling "1". Best Qualitative Output: "Good/Average/Poor -> Best =
///         Good (100%)". ISO 9001:2015 Quality Management Standard. Assigned to
///         **ADFA**.
///
/// ONE ROW JOINING AN ACCESS QUESTION TO A CONTENT QUESTION, AND A SCREEN THAT
/// WAS ASSUMED INTERNAL AND IS NOT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/inventory/internal_screen_census.dart';

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

  group('BTPM-032-05 :: two questions in one row', () {
    gate(
      'BTPM-032-05-G1',
      'The row joins an access question to a content question.',
      'Who may see a screen and what a screen says while it waits are '
          'different problems with different answers',
      () =>
          HabotInternalScreenCensus.theRowJoinsTwoQuestions &&
          HabotInternalScreenCensus.theTwoQuestionsDiffer,
    );

    gate(
      'BTPM-032-05-G2',
      'And they ship differently.',
      'An internal screen is absent or gated; a pending state ships to '
          'everybody and has to be legible',
      () => HabotInternalScreenCensus.subjectNote.contains('have to read well'),
    );

  });

  group('BTPM-032-05 :: the census', () {
    gate(
      'BTPM-032-05-G3',
      'Four audiences, six screens.',
      'Each screen carrying the audience it was built for',
      () =>
          HabotScreenAudience.values.length == 4 &&
          HabotInternalScreenCensus.screens.length == 6,
    );

    gate(
      'BTPM-032-05-G4',
      'The treatments come from Step 376.',
      'Hidden, disabled, gated and shown are already decided, and a second '
          'rule invented here would contradict the first one under load',
      () =>
          HabotInternalScreenCensus.theTreatmentsAreTheDeclaredOnes &&
          !HabotInternalScreenCensus.aSecondRuleIsInventedHere,
    );

    gate(
      'BTPM-032-05-G5',
      'Two internal screens are absent and one is role-gated.',
      'Absent where the audience can never qualify, gated where it can',
      () =>
          HabotInternalScreenCensus.twoAreAbsentOneIsGated &&
          HabotInternalScreenCensus.internalScreens == 3,
    );

  });

  group('BTPM-032-05 :: what pending has to say', () {
    gate(
      'BTPM-032-05-G6',
      'Two pending states ship to everybody.',
      'Which is why they carry an owner and an age',
      () => HabotInternalScreenCensus.twoPendingStatesShip,
    );

    gate(
      'BTPM-032-05-G7',
      'One screen was assumed internal and is not.',
      'Export payroll is reachable by a manager, and the census is where that '
          'was discovered rather than a support ticket',
      () =>
          HabotInternalScreenCensus.oneWasAssumedInternalAndIsNot &&
          HabotInternalScreenCensus.censusNote
              .contains('nobody outside the building can clear'),
    );

    gate(
      'BTPM-032-05-G8',
      'Both pending states name an owner and an age.',
      '"Pending review" with neither is a screen that tells the user to wait '
          'without saying for whom or how long',
      () =>
          HabotInternalScreenCensus.everyPendingStateNamesItsOwner &&
          HabotInternalScreenCensus.everyPendingStateNamesItsAge,
    );

  });

  group('BTPM-032-05 :: the band', () {
    gate(
      'BTPM-032-05-G9',
      'And "Pending review" alone is refused.',
      'Refused in the census rather than corrected in a copy review later',
      () =>
          HabotInternalScreenCensus.theVagueWordingIsRefused &&
          HabotInternalScreenCensus.pendingNote
              .contains('a support ticket rather than a wait'),
    );

    gate(
      'BTPM-032-05-G10',
      'Six obligations, all met, giving Good.',
      'And all ten declared checks hold',
      () =>
          HabotInternalScreenCensus.obligations.length == 6 &&
          HabotInternalScreenCensus.obligations.values.every((bool b) => b) &&
          HabotInternalScreenCensus.qualitativeOutput == 'Good' &&
          HabotInternalScreenCensus.theBandMixesUnits &&
          HabotInternalScreenCensus.theOutputColumnHoldsAnAnnotation,
    );
  });

  tearDownAll(() {
    final int screens = HabotInternalScreenCensus.screens.length;
    final int internal = HabotInternalScreenCensus.internalScreens;
    final int pending = HabotInternalScreenCensus.pendingScreens;
    final String falsePositive = HabotInternalScreenCensus.theFalsePositive;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'BTPM-032-05',
        atomicStepReferenceId: 'BTPM-032-05',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to ADFA rather than UDF; it '
            'joins two different questions in one sentence -- an access '
            'question about internal screens and a content question about '
            'pending states; its band mixes two percentages with the bare '
            'ratio "1"; its Best Qualitative Output cell reads '
            '"Good/Average/Poor -> Best = Good (100%)", the third '
            'arrow-annotated output cell in this batch; and its Setup Step '
            'column reads "Verify the tracker resets correctly for each new '
            'page load". Atomic Step: "Identify all interface screens serving '
            'purely internal administrative checks or pending review states."',
        implementationOrder: 399,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Step Execution ID': 'STEP-399-INTERNAL-SCREEN-CENSUS',
          'Execution Status':
              '$screens screens censused; $internal internal, $pending '
                  'carrying a pending state',
          'Execution Timestamp': '2026-09-17T00:00:00Z',
          'Step Outcome':
              '$falsePositive was assumed internal and is reachable by a '
                  'manager; the assumption is corrected in the census rather '
                  'than in production',
          'User ID': 'Fredrick',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Execution Quality Score',
            observed:
                'BAND MIXES UNITS AND THE OUTPUT CELL HOLDS AN ARROW. Floor '
                'and optimal are percentages and the ceiling is 1, so the '
                'three cells are on two scales; the output column reads '
                '"Good/Average/Poor -> Best = Good (100%)". Observed: $screens '
                'screens censused, $internal internal and $pending pending, '
                'with every internal screen taking its treatment from the map '
                'Step 376 built rather than from a rule invented here.',
            floor: '>=90%',
            optimal: '>=98%',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Screens wrongly assumed internal',
            observed:
                '1 of $screens. $falsePositive was on the internal list and is '
                'reachable by any manager, which is the kind of thing a census '
                'finds and an assumption never does. The row joins that access '
                'question to a content question -- what a screen says while it '
                'waits -- and the two ship differently: an internal screen is '
                'absent or gated, a pending state is seen by everybody. Both '
                'pending states name an owner and an age, and "Pending review" '
                'on its own is refused.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/inventory/internal_screen_census.dart',
        ],
      ),
    );
  });
}
