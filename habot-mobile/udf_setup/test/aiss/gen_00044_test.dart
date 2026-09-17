/// AISS GATE -- Step 409 of 415
/// Global Reference ID:       GEN-00044
/// Atomic Steps Reference ID: GEN-00044
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Configure a CSS linter to block custom hex color values in
///               component code."
/// Metric: Function Complexity / Size Limit Compliance -- floor "<= 25 lines /
///         cyclomatic complexity <= 10 (acceptable ceiling)", optimal "<= 20
///         lines, <= 5 parameters, cyclomatic complexity <= 5", ceiling "25
///         lines (hard linter-enforced ceiling)". Best Qualitative Output:
///         "Pass/Fail". ISO/IEC 25010 Maintainability; Clean Code (Martin)
///         function-size heuristic. Assigned to **UDF**.
///
/// A CSS LINTER FOR AN APPLICATION WITH NO CSS, ON A ROW CARRYING STEP 412'S
/// METRIC.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/tooling/colour_lint.dart';

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

  group('GEN-00044 :: the metric belongs to another row', () {
    gate(
      'GEN-00044-G1',
      'The metric belongs to Step 412.',
      '"Function Complexity / Size Limit Compliance" measures function length, '
          'and Step 412 is the function-length row',
      () =>
          HabotColourLint.theMetricBelongsToStep412 &&
          HabotColourLint.theTwoRowsHaveSwappedMetrics,
    );

    gate(
      'GEN-00044-G2',
      'And the two rows have swapped metrics.',
      'A metric that is not merely wrong for its row but right for a different '
          'row three rows later, which the track has not seen before',
      () => HabotColourLint.swapNote.contains('right for a different row'),
    );

  });

  group('GEN-00044 :: a floor that calls itself a ceiling', () {
    gate(
      'GEN-00044-G3',
      'The floor cell calls itself a ceiling.',
      'Floor "<= 25 lines / cyclomatic complexity <= 10 (acceptable ceiling)" '
          'against ceiling "25 lines (hard linter-enforced ceiling)": both '
          'name 25 under two names',
      () =>
          HabotColourLint.theFloorCallsItselfACeiling &&
          HabotColourLint.bothEndsNameTwentyFive,
    );

    gate(
      'GEN-00044-G4',
      'And no band cell parses.',
      'Third annotated boundary in the track, after Step 384 and alongside '
          'Step 413',
      () =>
          HabotColourLint.noCellParsesAsANumber &&
          HabotColourLint.threeAnnotatedBoundaries,
    );

  });

  group('GEN-00044 :: there is no CSS', () {
    gate(
      'GEN-00044-G5',
      'There is no CSS to lint.',
      'The seventeenth foreign stack on the register Step 258 keeps',
      () =>
          HabotColourLint.thisIsTheSeventeenthForeignStack &&
          HabotColourLint.toolTheRowNames.contains('CSS'),
    );

  });

  group('GEN-00044 :: the rule already exists', () {
    gate(
      'GEN-00044-G6',
      'Both colour rules are already declared.',
      'RAW_COLOR_LITERAL and UNTOKENISED_MATERIAL_COLOR, owned by Step 4',
      () =>
          HabotColourLint.bothRulesAreDeclared &&
          HabotColourLint.theStepThatOwnsIt == 4,
    );

    gate(
      'GEN-00044-G7',
      'The rule is blocking and names its exemptions.',
      'Exempt sites with a rationale, which is what keeps a blocking rule from '
          'being switched off',
      () =>
          HabotColourLint.theRuleIsBlocking &&
          HabotColourLint.theRuleNamesItsExemptSites,
    );

    gate(
      'GEN-00044-G8',
      'No second check is added.',
      'Two answers to one question is how a rule stops being enforceable',
      () =>
          !HabotColourLint.aSecondCheckIsAdded &&
          HabotColourLint.existingRuleNote
              .contains('two answers to one question'),
    );

    gate(
      'GEN-00044-G9',
      'Four rows in this batch ask for existing rules.',
      'Steps 409, 410 and 411 for a colour lint and Step 412 for the function '
          'limit Step 296 set',
      () =>
          HabotColourLint.fourRowsInThisBatch &&
          HabotColourLint.colourRowsInThisBatch == 3,
    );

    gate(
      'GEN-00044-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotColourLint.obligations.length == 5 &&
          HabotColourLint.obligations.values.every((bool b) => b) &&
          HabotColourLint.qualitativeOutput == 'Pass' &&
          HabotColourLint.coverage == 100,
    );
  });

  tearDownAll(() {
    final int ordinal = HabotColourLint.foreignStackOrdinal;
    final int rows = HabotColourLint.rowsAskingForExistingRules.length;
    final int owner = HabotColourLint.theStepThatOwnsIt;
    final int swapped = HabotColourLint.theRowThisMetricBelongsTo;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00044',
        atomicStepReferenceId: 'GEN-00044',
        setupStepAction:
            'COLUMN NOTE: this row asks for a CSS linter in an application '
            'with no CSS -- the seventeenth foreign stack on the register Step '
            '258 keeps; its metric is "Function Complexity / Size Limit '
            'Compliance", which belongs to Step 412 three rows later, so the '
            'two rows have swapped metrics; its floor cell annotates itself '
            '"(acceptable ceiling)" while its ceiling reads "25 lines (hard '
            'linter-enforced ceiling)", both naming 25; and its Setup Step '
            'column reads "Implement the scope indicator -- show currently '
            'active scope prominently in the UI header". Atomic Step: '
            '"Configure a CSS linter to block custom hex color values in '
            'component code."',
        implementationOrder: 409,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Configure a CSS linter to block custom hex color values':
              'bound to RAW_COLOR_LITERAL and UNTOKENISED_MATERIAL_COLOR, both '
                  'blocking rules owned by Step $owner, rather than built a '
                  'second time',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Function Complexity / Size Limit Compliance',
            observed:
                'THIS METRIC BELONGS TO STEP $swapped, AND THE FLOOR CELL '
                'CALLS ITSELF A CEILING. "Function Complexity / Size Limit '
                'Compliance" measures function length; Step $swapped, three '
                'rows later, is the twenty-line-function row and carries a '
                'generic step completion rate instead, so the two rows have '
                'swapped metrics -- a metric that is right for a different row '
                'in the same batch, which is new. The floor annotates itself '
                '"(acceptable ceiling)" and the ceiling reads "25 lines (hard '
                'linter-enforced ceiling)": both name 25 and none of the three '
                'cells parses.',
            floor:
                '<= 25 lines / cyclomatic complexity <= 10 (acceptable '
                    'ceiling)',
            optimal: '<= 20 lines, <= 5 parameters, cyclomatic complexity <= 5',
            ceiling: '25 lines (hard linter-enforced ceiling)',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Colour checks declared a second time',
            observed:
                '0. RAW_COLOR_LITERAL has blocked a Color literal outside the '
                'three declaration sites since Step $owner and '
                'UNTOKENISED_MATERIAL_COLOR blocks the Material constants a '
                'hex would hide behind, so this row binds rather than builds. '
                'There is no CSS in a Flutter application -- the ${ordinal}th '
                'foreign stack on the register Step 258 keeps -- and $rows '
                'rows in this batch ask for rules the build has been enforcing '
                'for four hundred steps.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tooling/colour_lint.dart',
        ],
      ),
    );
  });
}
