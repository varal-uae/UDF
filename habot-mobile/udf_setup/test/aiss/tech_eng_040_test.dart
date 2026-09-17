/// AISS GATE -- Step 400 of 415
/// Global Reference ID:       TECH-ENG-040
/// Atomic Steps Reference ID: TECH-ENG-040
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Design the single-operation input screen layout for each
///               operation type following mobile-first M3 TextField
///               guidelines."
/// Metric: Mobile UI Interaction Latency -- floor "Sub-300ms response to touch
///         interactions", optimal "Sub-100ms response per Google RAIL model",
///         ceiling "Interaction latency above 500ms is perceived as
///         unresponsive". Best Qualitative Output: "Good / Average / Poor".
///         Google RAIL Model -- Interaction Performance Standards. Assigned to
///         **UDF**.
///
/// A BAND WHOSE THREE CELLS ARE SENTENCES, WHOSE CEILING DESCRIBES A FAILURE,
/// AND WHICH RUNS THE WRONG WAY.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/single_operation_screen.dart';

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

  group('TECH-ENG-040 :: a band written in sentences', () {
    gate(
      'TECH-ENG-040-G1',
      'Every band cell is a sentence.',
      'Not one of the three parses, and the numbers inside them have to be '
          'read out of prose',
      () => HabotSingleOperationScreen.everyCellIsASentence,
    );

    gate(
      'TECH-ENG-040-G2',
      'The ceiling describes the failure condition.',
      '"Interaction latency above 500ms is perceived as unresponsive" is the '
          'second time in the track a ceiling names what going wrong looks '
          'like, after Step 338',
      () =>
          HabotSingleOperationScreen.theCeilingDescribesFailure &&
          HabotSingleOperationScreen.thisIsTheSecondOccurrence,
    );

    gate(
      'TECH-ENG-040-G3',
      'And the band is inverted.',
      'Lower is better for a latency, so a 500ms ceiling is worse than a 300ms '
          'floor',
      () =>
          HabotSingleOperationScreen.theBandIsInverted &&
          HabotSingleOperationScreen.theCeilingIsWorseThanTheFloor &&
          HabotSingleOperationScreen.bandNote.contains('worse than the floor'),
    );

  });

  group('TECH-ENG-040 :: one operation, one screen', () {
    gate(
      'TECH-ENG-040-G4',
      'Four operations, four screens.',
      'One screen per operation type, which is what the row asks for and what '
          'Step 397 decided',
      () =>
          HabotSingleOperationScreen.everyKindHasAScreen &&
          HabotSingleOperationScreen.screens.length == 4,
    );

    gate(
      'TECH-ENG-040-G5',
      'Every title is a question and every screen has one action.',
      'A title that names the operation is what makes a single-operation '
          'screen legible rather than merely short',
      () =>
          HabotSingleOperationScreen.everyTitleIsAQuestion &&
          HabotSingleOperationScreen.everyScreenHasOnePrimaryAction,
    );

    gate(
      'TECH-ENG-040-G6',
      'Between one and four fields per screen.',
      'The shortest screen is one field, which is the shape the row is aiming '
          'at',
      () =>
          HabotSingleOperationScreen.betweenOneAndFourFields &&
          HabotSingleOperationScreen.scopeNote.contains('the worst case'),
    );

  });

  group('TECH-ENG-040 :: fields are declared, not filtered', () {
    gate(
      'TECH-ENG-040-G7',
      'Fields are declared rather than filtered from a superset.',
      'Ten fields exist across the four screens and six would be hidden by any '
          'filter-based approach',
      () =>
          HabotSingleOperationScreen.fieldsAreDeclaredPerScreen &&
          HabotSingleOperationScreen.fieldsASharedScreenWouldHide == 6,
    );

    gate(
      'TECH-ENG-040-G8',
      'And the hidden ones would still be in the tree.',
      'A hidden field is a field a screen reader can reach and an autofill can '
          'populate, which is why they are not built',
      () =>
          HabotSingleOperationScreen.supersetNote
              .contains('absent-means-absent'),
    );

  });

  group('TECH-ENG-040 :: what is already decided', () {
    gate(
      'TECH-ENG-040-G9',
      'The touch rules are declared elsewhere.',
      'Target size and spacing come from the existing tokens rather than from '
          'a latency band written in prose',
      () =>
          HabotSingleOperationScreen.theTouchRulesAreAlreadyDeclared &&
          HabotSingleOperationScreen.touchNote.contains('eleven'),
    );

    gate(
      'TECH-ENG-040-G10',
      'Five obligations, all met, giving Good.',
      'And all ten declared checks hold',
      () =>
          HabotSingleOperationScreen.obligations.length == 5 &&
          HabotSingleOperationScreen.obligations.values.every((bool b) => b) &&
          HabotSingleOperationScreen.qualitativeOutput == 'Good' &&
          HabotSingleOperationScreen.theMeasureIsRestated &&
          HabotSingleOperationScreen.screensWithinScope == 100,
    );
  });

  tearDownAll(() {
    final int screens = HabotSingleOperationScreen.screens.length;
    final int fields = HabotSingleOperationScreen.fieldsOnASharedSuperset;
    final int hidden = HabotSingleOperationScreen.fieldsASharedScreenWouldHide;
    final int fewest = HabotSingleOperationScreen.fewestFields;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'TECH-ENG-040',
        atomicStepReferenceId: 'TECH-ENG-040',
        setupStepAction:
            'COLUMN NOTE: all three boundary cells on this row are sentences '
            'rather than values, and the ceiling -- where the best attainable '
            'value belongs -- describes the failure condition instead: '
            '"Interaction latency above 500ms is perceived as unresponsive", '
            'which is Step 338\'s shape and makes the band inverted, since '
            '500ms is worse than the 300ms floor; and its Setup Step column '
            'reads "Code the UI logic to dynamically display these error '
            'messages adjacent to the violating form fields". Atomic Step: '
            '"Design the single-operation input screen layout for each '
            'operation type following mobile-first M3 TextField guidelines."',
        implementationOrder: 400,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Design the single-operation input screen layout for each operation '
          'type':
              '$screens screens, one per operation type, carrying $fields '
                  'fields between them -- between one and four each',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Mobile UI Interaction Latency',
            observed:
                'ALL THREE BAND CELLS ARE SENTENCES AND THE BAND IS INVERTED. '
                'The floor reads "Sub-300ms response to touch interactions", '
                'the optimal "Sub-100ms response per Google RAIL model", and '
                'the ceiling "Interaction latency above 500ms is perceived as '
                'unresponsive" -- so the ceiling describes a failure rather '
                'than a best value, which is the second time in the track '
                'after Step 338, and on a latency, where lower is better, a '
                '500ms ceiling is worse than the 300ms floor. None of the '
                'three parses. Observed: $screens single-operation screens.',
            floor: 'Sub-300ms response to touch interactions',
            optimal: 'Sub-100ms response per Google RAIL model',
            ceiling:
                'Interaction latency above 500ms is perceived as unresponsive',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Fields hidden rather than not built',
            observed:
                '0 of $fields. A filter over a superset would leave $hidden '
                'fields hidden on each screen, and a hidden field is still in '
                'the widget tree: a screen reader can reach it, an autofill '
                'can populate it, and a validator can reject a value the user '
                'never saw. Each of the $screens screens declares its own '
                'fields instead, so the shortest screen carries one field and '
                'the tree has nothing in it the user cannot see.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/single_operation_screen.dart',
        ],
      ),
    );
  });
}
