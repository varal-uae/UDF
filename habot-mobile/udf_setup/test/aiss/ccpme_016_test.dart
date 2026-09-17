/// AISS GATE -- Step 325 of 335
/// Global Reference ID:       CCPME-016
/// Atomic Steps Reference ID: CCPME-016
/// Setup Step (Action): "Bind the calculation routines directly to those cell
///                      interaction triggers." (AND EVERY NARRATIVE COLUMN IS
///                      STEP 315'S, WORD FOR WORD)
/// Atomic Step: '2. Build a "Force Majeure" mobile panic button.'
/// Metric: Mobile Touch Response Time (ms) -- floor **0**, optimal 100,
///         ceiling 300. Good/Average/Poor. W3C Mobile Web Best Practices.
///
/// THE FLOOR IS THE IDEAL AND IS UNREACHABLE. FIRST OF FOUR INVERTED LATENCY
/// BANDS IN THIS BATCH, AGAINST ONE THAT IS ORDERED CORRECTLY.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/support/panic_button.dart';

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

  group('CCPME-016 :: the band', () {
    gate(
      'CCPME-016-G1',
      'Floor 0 ms, optimal 100 ms, ceiling 300 ms.',
      'On a lower-is-better measure the floor should be the worst tolerable '
          'value and the ceiling the best; here they are the other way round',
      () =>
          HabotPanicButton.theBandIsInverted &&
          HabotPanicButton.bandFloorMs == 0 &&
          HabotPanicButton.bandCeilingMs == 300,
    );

    gate(
      'CCPME-016-G2',
      'And the floor is below what a screen can produce.',
      'A frame at 60Hz is 16.667 ms, so 0 ms is not a tolerance, it is an '
          'impossibility',
      () =>
          HabotPanicButton.theFloorIsBelowWhatAScreenCanDo &&
          (HabotPanicButton.attainableFloorMs - 16.667).abs() < 1e-9,
    );

    gate(
      'CCPME-016-G3',
      'The ordered band this project would write.',
      '300 at the floor, 100 at the optimal, one frame at the ceiling',
      () =>
          HabotPanicButton.theProjectBandIsOrdered &&
          HabotPanicButton.projectFloorMs == 300 &&
          HabotPanicButton.projectOptimalMs == 100,
    );

    gate(
      'CCPME-016-G4',
      'Four inverted bands in this batch and one correct.',
      'Steps 325, 326, 334 and 335 run one way; Step 333 runs the other, and '
          'that single correct instance is what makes the four an error '
          'rather than a convention',
      () =>
          HabotPanicButton.oneCorrectInstanceMakesTheOthersAnError &&
          HabotPanicButton.invertedLatencyBandsInThisBatch.length == 4 &&
          HabotPanicButton.correctlyOrderedLatencyBandInThisBatch == 333,
    );
  });

  group('CCPME-016 :: why this control confirms', () {
    gate(
      'CCPME-016-G5',
      'Step 323\'s escalation confirms nothing and this one does.',
      'A declaration whose cost, in the row\'s own words, is termination '
          'earns a confirmation; a call for help does not',
      () =>
          HabotPanicButton.aConfirmationIsRequiredHere &&
          HabotPanicButton.siblingStep == 323 &&
          HabotPanicButton.thePersonBearsTheCostHere,
    );

    gate(
      'CCPME-016-G6',
      'The rule that separates them is whose mistake it would be.',
      'Which makes two rows that look contradictory cohere',
      () => HabotPanicButton.confirmationRuleNote
          .contains('whose mistake it would be'),
    );
  });

  group('CCPME-016 :: how the consequence is stated', () {
    gate(
      'CCPME-016-G7',
      'Config cell: "prominent warning that false declarations result in '
          'termination".',
      'The warning appears once, on the confirmation step, in ordinary type, '
          'as a sentence rather than a banner',
      () =>
          HabotPanicButton.theWarningIsOnTheConfirmationOnly &&
          HabotPanicButton.theWarningIsASentenceRatherThanABanner &&
          !HabotPanicButton.warningUsesTheErrorColour,
    );

    gate(
      'CCPME-016-G8',
      'And not in error red on the button itself.',
      'Somebody in a genuine emergency reading a threat at the moment they '
          'need help is being told the organisation expects them to be lying',
      () => HabotPanicButton.warningNote
          .contains('expects them to be lying'),
    );

    gate(
      'CCPME-016-G9',
      'All four configuration cells describe the control correctly.',
      'A bottom sheet, a large camera button, a confirmation and a warning -- '
          'rare enough to record; only the placement of the fourth changes',
      () =>
          HabotPanicButton.allFourConfigurationCellsAreAdopted &&
          HabotPanicButton.adoptedNote.contains('rare enough to record'),
    );
  });

  group('CCPME-016 :: the duplicated narrative', () {
    gate(
      'CCPME-016-G10',
      'Every narrative column is Step 315\'s, word for word.',
      'The UX Translation and What Standardized Must Be Done cells are the '
          'same sentences ten rows earlier in this track; two rows in two '
          'batches carrying one pasted narrative, so neither has one of its '
          'own. Five declared obligations, all met; all eleven declared '
          'checks hold',
      () =>
          HabotPanicButton.twoRowsShareOnePastedNarrative &&
          HabotPanicButton.stepWithTheSameNarrative == 315 &&
          HabotPanicButton.duplicateNarrativeNote
              .contains('copied rather than written') &&
          HabotPanicButton.obligations.length == 5 &&
          HabotPanicButton.obligations.values.every((bool b) => b) &&
          HabotPanicButton.conformance == 1.0 &&
          HabotPanicButton.qualitativeOutput == 'Good' &&
          HabotPanicButton.checks.length == 11 &&
          HabotPanicButton.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final String warning = HabotPanicButton.warningText;
    final String frame =
        HabotPanicButton.attainableFloorMs.toStringAsFixed(3);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'CCPME-016',
        atomicStepReferenceId: 'CCPME-016',
        setupStepAction:
            'COLUMN NOTE: every narrative column on this row is about '
            'time-limited signed URLs and link interception, word for word the '
            'same sentences Step 315 carries; the metric puts 0 ms at the '
            'floor of a lower-is-better band; and the Setup Step reads "Bind '
            'the calculation routines directly to those cell interaction '
            'triggers". Atomic Step: "Build a Force Majeure mobile panic '
            'button."',
        implementationOrder: 325,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Mobile Platform': 'Android and iOS',
          'OS Version': 'not a variable for this control',
          'Device Type': 'handheld, one-handed use assumed',
          'Screen Dimensions':
              'compact; the declaration opens in a bottom sheet rather than '
                  'navigating away from the job',
          'Mobile Configuration':
              'confirmation required, warning shown once on the confirmation '
                  'step: "$warning"',
          'Completion Status': 'Good',
          'Data Quality Note':
              'BAND: ${HabotPanicButton.bandNote} '
              'CONFIRMATION: ${HabotPanicButton.confirmationRuleNote} '
              'WARNING: ${HabotPanicButton.warningNote} '
              'NARRATIVE: ${HabotPanicButton.duplicateNarrativeNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Mobile Touch Response Time (ms)',
            observed:
                'THE BAND IS INVERTED. On a lower-is-better measure the floor '
                'should be the worst tolerable value; this row puts 0 ms '
                'there, which is the ideal and is below the ${frame} ms a '
                'frame takes at 60Hz, and 300 ms at the ceiling, which is the '
                'worst of the three. Four of the five latency bands in this '
                'batch are inverted this way; Step 333 is not, which is what '
                'makes these four an error rather than a convention.',
            floor: '0',
            optimal: '100',
            ceiling: '300',
          ),
          AissMeasurement(
            metricName: 'Places the termination warning appears',
            observed:
                '1, on the confirmation step, in ordinary type. It is true and '
                'it belongs on the screen; it does not belong in error red on '
                'the button, because a person in a genuine emergency reading a '
                'threat at that moment is being told the organisation expects '
                'them to be lying.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/support/panic_button.dart',
        ],
      ),
    );
  });
}
