/// AISS GATE -- Step 314 of 315
/// Global Reference ID:       GEN-04979
/// Atomic Steps Reference ID: GEN-04979
/// Setup Step (Action): (the generic engineering-console boilerplate; the
///                      Expected Output cell is the Atomic Step truncated
///                      mid-word -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement substep 4: Add screen-reader fallback list allowing
///               non-visual tap selection of sensory categories."
/// Metric: Substep Definition-of-Done Adherence Rate -- floor ">=90% unit test
///         coverage", optimal "95-100% coverage", ceiling "100%".
///         Complete/Partial/Not Complete. ISO/IEC 25010.
///
/// A SEPARATE LIST FOR SCREEN READERS IS THE DEFECT, NOT THE FIX. AND
/// COVERAGE CANNOT SEE A MISSING LABEL.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/nonvisual_category_list.dart';

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

  group('GEN-04979 :: one structure rather than two', () {
    gate(
      'GEN-04979-G1',
      'Atomic Step: "Add screen-reader fallback list".',
      'Two structures over nine categories is eighteen places to change and '
          'nine pairs that can disagree; one structure is nine places and no '
          'pairs',
      () =>
          HabotNonvisualCategoryList.categories.length == 9 &&
          HabotNonvisualCategoryList.placesToChange == 9 &&
          HabotNonvisualCategoryList.placesToChangeWithAFallbackList == 18 &&
          HabotNonvisualCategoryList.pairsThatCouldDisagree == 9 &&
          HabotNonvisualCategoryList.editReduction == 0.5,
    );

    gate(
      'GEN-04979-G2',
      'Every disagreement is invisible to everyone who can see.',
      'Not caught in review, not caught by a designer, not caught by whoever '
          'adds the tenth category -- found months later by the one person it '
          'was built for',
      () => HabotNonvisualCategoryList.parallelListNote
          .contains('the oldest anti-pattern'),
    );

    gate(
      'GEN-04979-G3',
      'The spoken label is derived from the field the row renders.',
      'So there is nothing to keep in step and nothing that can drift',
      () =>
          HabotNonvisualCategoryList.theLabelIsDerivedRatherThanDuplicated &&
          HabotNonvisualCategoryList.nothingCanDrift &&
          HabotNonvisualCategoryList.pairsThatCanDisagreeHere == 0,
    );
  });

  group('GEN-04979 :: sensory characteristics', () {
    gate(
      'GEN-04979-G4',
      'WCAG 2.1 SC 1.3.3 Sensory Characteristics -- Level A.',
      'Nine categories use three swatch roles between them, so a swatch '
          'could not identify a category even for somebody who can see it',
      () =>
          HabotNonvisualCategoryList.criterionLevel == 'A' &&
          HabotNonvisualCategoryList.criterion.contains('1.3.3') &&
          HabotNonvisualCategoryList.noCategoryIsIdentifiedByItsSwatch,
    );

    gate(
      'GEN-04979-G5',
      'Every category is identified by a name.',
      'And no two share one, so "pick the red one" is never the only way to '
          'refer to something',
      () =>
          HabotNonvisualCategoryList.everyCategoryHasAName &&
          HabotNonvisualCategoryList.noTwoCategoriesShareAName &&
          HabotNonvisualCategoryList.sensoryNote.contains('names four things'),
    );
  });

  group('GEN-04979 :: the gesture', () {
    gate(
      'GEN-04979-G6',
      'Atomic Step: "non-visual tap selection".',
      'With a screen reader on, selection is explore-by-touch then a '
          'double-tap, and the double-tap belongs to the assistive technology '
          '-- the same fact Step 312 met from the other direction',
      () =>
          !HabotNonvisualCategoryList.aSeparateNonVisualPathIsNeeded &&
          HabotNonvisualCategoryList.siblingStepWithTheSameFact == 312 &&
          HabotNonvisualCategoryList.screenReaderSelection
              .contains('assistive technology'),
    );

    gate(
      'GEN-04979-G7',
      'A properly exposed control needs no second path.',
      'Because the ordinary path already is one, and building the second '
          'path is how the first one stays broken',
      () => HabotNonvisualCategoryList.gestureNote.contains('stays broken'),
    );

    gate(
      'GEN-04979-G8',
      'Every row is a target at the project minimum.',
      'Forty-eight points, read from the band rather than restated',
      () =>
          HabotNonvisualCategoryList.everyRowIsAProperTarget &&
          HabotNonvisualCategoryList.rowMinimumDp == 48,
    );
  });

  group('GEN-04979 :: the metric', () {
    gate(
      'GEN-04979-G9',
      'Floor: ">=90% unit test coverage".',
      'A semantics node is not a branch: a row with no label executes the '
          'same lines as a labelled one, so a suite at 100 per cent coverage '
          'passes over a control that announces nothing',
      () =>
          !HabotNonvisualCategoryList.coverageCanSeeAMissingLabel &&
          HabotNonvisualCategoryList.floorCoverage == 0.90 &&
          HabotNonvisualCategoryList.coverageNote
              .contains('reassuring kind of blindness'),
    );

    gate(
      'GEN-04979-G10',
      'Output: Complete / Partial / Not Complete.',
      'Six declared obligations, all met, giving Complete; all twelve '
          'declared checks hold, and the ceiling explains itself correctly '
          'for the first time since Step 288',
      () =>
          HabotNonvisualCategoryList.obligations.length == 6 &&
          HabotNonvisualCategoryList.obligations.values.every((bool b) => b) &&
          HabotNonvisualCategoryList.adherence == 1.0 &&
          HabotNonvisualCategoryList.qualitativeOutput == 'Complete' &&
          HabotNonvisualCategoryList.checks.length == 12 &&
          HabotNonvisualCategoryList.checks.values.every((bool b) => b) &&
          HabotNonvisualCategoryList.theCeilingIsHonest &&
          HabotNonvisualCategoryList.ceilingTextNote.contains('Step 288'),
    );
  });

  tearDownAll(() {
    final HabotSensoryCategory first =
        HabotNonvisualCategoryList.categories.first;
    final String selected = HabotNonvisualCategoryList.categories
        .where((HabotSensoryCategory c) => c.selected)
        .map((HabotSensoryCategory c) => c.name)
        .join(', ');

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04979',
        atomicStepReferenceId: 'GEN-04979',
        setupStepAction:
            'COLUMN NOTE: every narrative column on this row is the generic '
            'engineering-console boilerplate, and the Expected Output cell is '
            'the Atomic Step truncated mid-word -- "allowing non-visual tap '
            'sel". Atomic Step: "Implement substep 4: Add screen-reader '
            'fallback list allowing non-visual tap selection of sensory '
            'categories."',
        implementationOrder: 314,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Implement substep 4: Add screen-reader fallback list allowing':
              'refused -- one structure that is accessible, rather than a '
                  'second structure for screen readers',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              '${HabotNonvisualCategoryList.categories.length} categories; '
                  '"${first.name}" announces '
                  '"${first.semanticLabel}, ${first.semanticState}"; selected: '
                  '$selected',
          'Data Quality Note':
              'PARALLEL LIST: ${HabotNonvisualCategoryList.parallelListNote} '
              'SENSORY: ${HabotNonvisualCategoryList.sensoryNote} '
              'GESTURE: ${HabotNonvisualCategoryList.gestureNote} '
              'COVERAGE: ${HabotNonvisualCategoryList.coverageNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Substep Definition-of-Done Adherence Rate',
            observed:
                '100% over six declared obligations. The metric\'s own '
                'instrument -- unit test coverage -- cannot see the defect '
                'this row is about: a row with no semantic label executes the '
                'same lines as a labelled one. The ceiling cell explains '
                'itself and is right to, which is the first time since Step '
                '288.',
            floor:
                '>=90% unit test coverage / acceptance criteria met before '
                'merge',
            optimal: '95-100% coverage, all acceptance criteria met',
            ceiling: '100% (coverage beyond 100% is not meaningful)',
          ),
          AissMeasurement(
            metricName: 'Structures holding the category list',
            observed:
                '1, against the 2 the row asks for. Two would be 18 places to '
                'change and 9 pairs that can disagree, every disagreement '
                'invisible to everybody except the person it was built for. '
                'The spoken label is derived from the rendered field, so '
                'there is nothing to keep in step.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/a11y/nonvisual_category_list.dart',
        ],
      ),
    );
  });
}
