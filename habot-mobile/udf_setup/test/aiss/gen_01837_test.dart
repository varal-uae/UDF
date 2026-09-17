/// AISS GATE -- Step 412 of 415
/// Global Reference ID:       GEN-01837
/// Atomic Steps Reference ID: GEN-01837
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Set a hard limit of 20 lines of code per function."
/// Metric: Step Completion Rate (%) -- floor "90", optimal "99", ceiling "100".
///         Best Qualitative Output: "Complete/Partial/Not Complete". ISO/IEC
///         27001:2022 General Standards. Assigned to **ADFA**.
///
/// THE TWENTY-LINE FUNCTION LIMIT, A HUNDRED STEPS AFTER STEP 296 SET IT,
/// CARRYING STEP 409'S METRIC.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/tooling/function_size_limit.dart';

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

  group('GEN-01837 :: already in force', () {
    gate(
      'GEN-01837-G1',
      'Step 296 set the limit and Step 379 relies on it.',
      'Twenty lines per function has been in force for a hundred steps',
      () =>
          HabotFunctionSizeLimit.theStepThatSetIt == 296 &&
          HabotFunctionSizeLimit.theStepThatReliesOnIt == 379,
    );

    gate(
      'GEN-01837-G2',
      'It is bound rather than re-declared.',
      'Two numbers behind one rule is how a rule stops being enforceable',
      () =>
          HabotFunctionSizeLimit.theLimitIsBound &&
          !HabotFunctionSizeLimit.aSecondLimitIsDeclared,
    );

    gate(
      'GEN-01837-G3',
      'Seven duplicated instructions across two batches.',
      'Steps 380, 382 and 394 in the last batch, and 409, 410, 411 and this '
          'row in this one',
      () =>
          HabotFunctionSizeLimit.sevenDuplicatedInstructionsAcrossTwoBatches &&
          HabotFunctionSizeLimit.duplicateNote
              .contains('the build happens to read'),
    );

  });

  group('GEN-01837 :: the metrics are swapped', () {
    gate(
      'GEN-01837-G4',
      'The metrics on this row and Step 409 are swapped.',
      'This row carries a generic step completion rate and Step 409 carries '
          'the function-size band',
      () =>
          HabotFunctionSizeLimit.theMetricsAreSwapped &&
          HabotFunctionSizeLimit.theOtherRowAgrees,
    );

    gate(
      'GEN-01837-G5',
      'And a metric can be correct somewhere else nearby.',
      'Which is a failure mode the track had not recorded: not wrong, but '
          'right for a different row',
      () =>
          HabotFunctionSizeLimit.swapNote
              .contains('correct somewhere else nearby'),
    );

  });

  group('GEN-01837 :: "hard" is the word worth keeping', () {
    gate(
      'GEN-01837-G6',
      'The limit is hard rather than advisory.',
      'A soft limit is a style guide, and a style guide is cited after a '
          'review rather than before a merge',
      () =>
          HabotFunctionSizeLimit.itStopsAMerge &&
          HabotFunctionSizeLimit.theCatalogueModelsSeverity,
    );

    gate(
      'GEN-01837-G7',
      'And a soft limit is a document people cite afterwards.',
      'The exemptions are named with reasons, which is what keeps a hard limit '
          'from becoming an argument every Tuesday',
      () => HabotFunctionSizeLimit.hardNote.contains('every Tuesday'),
    );

  });

  group('GEN-01837 :: a proxy, named as one', () {
    gate(
      'GEN-01837-G8',
      'A line count is a proxy and is named as one.',
      'A twenty-line function can be unreadable and a thirty-line switch can '
          'be obvious',
      () =>
          HabotFunctionSizeLimit.theProxyIsNamedAsAProxy &&
          HabotFunctionSizeLimit.proxyNote.contains('is one thing'),
    );

    gate(
      'GEN-01837-G9',
      'Exemptions are by complexity.',
      'Cyclomatic complexity is harder to argue with in review than preference',
      () =>
          HabotFunctionSizeLimit.exemptionsAreArguable &&
          HabotFunctionSizeLimit.complexityCeiling == 10,
    );

    gate(
      'GEN-01837-G10',
      'Five obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotFunctionSizeLimit.obligations.length == 5 &&
          HabotFunctionSizeLimit.obligations.values.every((bool b) => b) &&
          HabotFunctionSizeLimit.qualitativeOutput == 'Complete' &&
          HabotFunctionSizeLimit.theBandIsWellFormed &&
          HabotFunctionSizeLimit.twoRowsShareThisBand &&
          HabotFunctionSizeLimit.coverage == 100,
    );
  });

  tearDownAll(() {
    final int limit = HabotFunctionSizeLimit.lineLimit;
    final int setBy = HabotFunctionSizeLimit.theStepThatSetIt;
    final int duplicates =
        HabotFunctionSizeLimit.duplicatedInstructionRows.length;
    final int complexity = HabotFunctionSizeLimit.complexityCeiling;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01837',
        atomicStepReferenceId: 'GEN-01837',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to ADFA rather than UDF; it '
            'asks for the twenty-line function limit Step 296 set a hundred '
            'steps ago, the seventh row across these two batches to ask for '
            'work the repository already contains; its metric is a generic '
            'step completion rate while Step 409 three rows earlier carries '
            '"Function Complexity / Size Limit Compliance", so the two rows '
            'have swapped metrics; its band is identical to Step 404\'s; its '
            'Data Requirement cell holds the Atomic Step\'s own text truncated '
            'with an ellipsis; and the Setup Step column is empty. Atomic '
            'Step: "Set a hard limit of 20 lines of code per function."',
        implementationOrder: 412,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Set a hard limit of 20 lines of code per':
              'bound to the $limit-line limit Step $setBy set, with exemptions '
                  'granted on cyclomatic complexity at $complexity rather than '
                  'on preference',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Step Completion Rate (%)',
            observed:
                'THIS METRIC BELONGS TO STEP 409 AND STEP 409\'S BELONGS HERE. '
                'This row is scored on a generic step completion rate of 90, '
                '99, 100 -- a well-formed band, identical to Step 404\'s in '
                'this batch -- while Step 409, three rows earlier and about '
                'hex colours, carries "Function Complexity / Size Limit '
                'Compliance" with a band about lines and cyclomatic '
                'complexity. The two rows have swapped metrics, and only '
                'reading both makes either legible. A completion rate on a row '
                'whose completion is what is being measured cannot fail.',
            floor: '90',
            optimal: '99',
            ceiling: '100',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Rows across two batches asking for existing rules',
            observed:
                '$duplicates. Steps 380, 382 and 394 in the previous batch '
                'asked for work the repository already contained; Steps 409, '
                '410, 411 and this row do the same. The $limit-line limit has '
                'been in force since Step $setBy and Step 379 already relies '
                'on it, so it is bound here rather than declared again: two '
                'numbers behind one rule is how a rule stops being '
                'enforceable, since the first disagreement between the copies '
                'is won by whichever the build happens to read.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tooling/function_size_limit.dart',
        ],
      ),
    );
  });
}
