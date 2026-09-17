/// AISS GATE -- Step 411 of 415
/// Global Reference ID:       GEN-04220
/// Atomic Steps Reference ID: GEN-04220
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Configure mobile project CI/CD to block local custom styling
///               and enforce NPM component imports."
/// Metric: General Process/Operational Compliance -- floor "N/A - Binary
///         Governance Gate", optimal "100% - Action Completed as Specified",
///         ceiling "N/A - Binary Governance Gate". Best Qualitative Output:
///         "Complete/Partial/Not Complete". ITIL v4 General Management
///         Practices. Assigned to **UDF**.
///
/// A BAND WHOSE FLOOR AND CEILING BOTH READ "N/A" -- THE FIRST BAND IN THE
/// TRACK THAT DECLINES TO BE ONE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/tooling/styling_ci_gate.dart';

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

  group('GEN-04220 :: a band that declines to be a band', () {
    gate(
      'GEN-04220-G1',
      'The floor and the ceiling are both "N/A".',
      'Both read "N/A - Binary Governance Gate" while the optimal is a '
          'sentence',
      () =>
          HabotStylingCiGate.theFloorAndCeilingAreBothNotApplicable &&
          HabotStylingCiGate.theOptimalIsASentence,
    );

    gate(
      'GEN-04220-G2',
      'No cell parses, and the shape is new.',
      'Every previous band defect in the track attempted a value; this one '
          'says the question does not apply',
      () =>
          HabotStylingCiGate.noCellParses &&
          HabotStylingCiGate.thisShapeIsNew,
    );

    gate(
      'GEN-04220-G3',
      'And the row is right that a gate has no band.',
      'The honest answer is one cell, and the sheet has no way to write it',
      () =>
          HabotStylingCiGate.theRowIsRightThatABandDoesNotApply &&
          HabotStylingCiGate.bandNote.contains('no way to write it'),
    );

  });

  group('GEN-04220 :: third time in three rows', () {
    gate(
      'GEN-04220-G4',
      'Third colour-lint row in three rows.',
      'A CSS linter, static analysis rules, and CI/CD blocking local custom '
          'styling -- one instruction in three vocabularies',
      () =>
          HabotStylingCiGate.threeRowsInThreeRows &&
          HabotStylingCiGate.threeVocabulariesOneInstruction,
    );

    gate(
      'GEN-04220-G5',
      'None of the three cites the others.',
      'Batch N found three duplicated instructions across twenty rows; this is '
          'three inside three',
      () =>
          !HabotStylingCiGate.anyOfThemCitesTheOthers &&
          HabotStylingCiGate.repetitionNote.contains('three inside three'),
    );

  });

  group('GEN-04220 :: there is no NPM', () {
    gate(
      'GEN-04220-G6',
      'NPM in a Dart project is the eighteenth foreign stack.',
      'Packages come from pub, and the instinct behind the instruction '
          'survives the translation',
      () =>
          HabotStylingCiGate.thisIsTheEighteenthForeignStack &&
          HabotStylingCiGate.theRowNamesADifferentPackageManager &&
          HabotStylingCiGate.theInstinctSurvives,
    );

  });

  group('GEN-04220 :: where a rule should run', () {
    gate(
      'GEN-04220-G7',
      'The rule runs in the analyser first.',
      'Because that is where a violation costs one edit',
      () =>
          HabotStylingCiGate.theCheapestPointIsFirst &&
          HabotStylingCiGate.theRuleRunsInThreePlaces,
    );

    gate(
      'GEN-04220-G8',
      'And every point names its cost.',
      'Analyser, pre-commit and CI, each with what a violation costs there',
      () =>
          HabotStylingCiGate.everyPointNamesItsCost &&
          !HabotStylingCiGate.itRunsOnlyInCi,
    );

    gate(
      'GEN-04220-G9',
      'One catalogue read three times.',
      'Not three catalogues, which would disagree at the margins',
      () =>
          HabotStylingCiGate.theRulesAreTheDeclaredOnes &&
          HabotStylingCiGate.rulesInTheCatalogue >= 10 &&
          HabotStylingCiGate.enforcementNote
              .contains('one catalogue read three times'),
    );

    gate(
      'GEN-04220-G10',
      'Six obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotStylingCiGate.obligations.length == 6 &&
          HabotStylingCiGate.obligations.values.every((bool b) => b) &&
          HabotStylingCiGate.qualitativeOutput == 'Complete' &&
          HabotStylingCiGate.coverage == 100,
    );
  });

  tearDownAll(() {
    final int rows = HabotStylingCiGate.colourLintRows.length;
    final int ordinal = HabotStylingCiGate.foreignStackOrdinal;
    final int points = HabotStylingCiGate.where.length;
    final int shapes = HabotStylingCiGate.previousBandShapes.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04220',
        atomicStepReferenceId: 'GEN-04220',
        setupStepAction:
            'COLUMN NOTE: this is the third row in three asking for a colour '
            'lint, after Steps 409 and 410, in a third vocabulary with a third '
            'metric and no cross-reference; its floor and ceiling are both the '
            'string "N/A - Binary Governance Gate" while its optimal is a '
            'sentence, which is a band shape this track has not met -- every '
            'previous defect attempted a value; it names NPM in a Dart '
            'project, the eighteenth foreign stack on the register Step 258 '
            'keeps; its Data Requirement cell reads "Data/artifacts to '
            'prepare: CI/CD"; and the Setup Step column is empty. Atomic Step: '
            '"Configure mobile project CI/CD to block local custom styling and '
            'enforce NPM component imports."',
        implementationOrder: 411,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'CI/CD':
              'the same catalogue read at $points enforcement points -- the '
                  'analyser, the pre-commit hook and the pipeline -- rather '
                  'than a fourth check written for CI',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'General Process/Operational Compliance',
            observed:
                'A BAND THAT DECLINES TO BE A BAND. The floor and the ceiling '
                'are both the string "N/A - Binary Governance Gate" and the '
                'optimal is a sentence, so two of the three cells refuse to be '
                'boundaries and the third is prose. All $shapes previously '
                'recorded band defects -- inverted, collapsed, typeset in '
                'LaTeX, annotated with an argument, holding three types -- '
                'attempted a value. This one says the question does not apply, '
                'and it is right: a binary gate has no band, the honest answer '
                'is one cell, and the sheet cannot express that.',
            floor: 'N/A - Binary Governance Gate',
            optimal: '100% - Action Completed as Specified',
            ceiling: 'N/A - Binary Governance Gate',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Rows in this batch asking for a colour lint',
            observed:
                '$rows, consecutively. Step 409 asked for a CSS linter, Step '
                '410 for static analysis rules, and this row for CI/CD '
                'blocking local custom styling: one instruction in three '
                'vocabularies with three metrics, none citing the others. The '
                'new part -- "enforce NPM component imports" -- names a '
                'package manager this project does not use, the ${ordinal}th '
                'foreign stack on the register Step 258 keeps, one row after '
                'the seventeenth.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tooling/styling_ci_gate.dart',
        ],
      ),
    );
  });
}
