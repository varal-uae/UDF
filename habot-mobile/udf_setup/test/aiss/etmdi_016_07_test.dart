/// AISS GATE -- Step 397 of 415
/// Global Reference ID:       ETMDI-016-07
/// Atomic Steps Reference ID: ETMDI-016-07
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Assign exactly one atomic, singular system transaction to each
///               newly separated screen."
/// Metric: Task Atomicity / Single-Action Granularity Rate -- floor ">=90%",
///         optimal "1", ceiling "1". Best Qualitative Output:
///         "Good/Average/Poor -> Best = Good (100%)". Lean Six Sigma Process
///         Decomposition Standard. Assigned to **UDF**.
///
/// THREE WORDS FOR ONE RULE -- "EXACTLY ONE", "ATOMIC" AND "SINGULAR" -- DOING
/// THREE DIFFERENT JOBS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/inventory/one_transaction_per_screen.dart';

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

  group('ETMDI-016-07 :: three words, three jobs', () {
    gate(
      'ETMDI-016-07-G1',
      'Three words, three different jobs.',
      '"Exactly one" counts, "atomic" describes how a write fails, and '
          '"singular" describes what the screen is about',
      () =>
          HabotOneTransactionPerScreen.theThreeWordsAreDistinguished &&
          (HabotOneTransactionPerScreen.theRowsWords['atomic'] ?? '')
              .contains('none of it did'),
    );

    gate(
      'ETMDI-016-07-G2',
      'One transaction can be three writes.',
      'Approving overtime writes an approval, an audit entry and a payroll '
          'adjustment, and it is still one transaction',
      () =>
          HabotOneTransactionPerScreen.oneTransactionIsNotOneWrite &&
          HabotOneTransactionPerScreen.wordsNote.contains('three writes'),
    );

  });

  group('ETMDI-016-07 :: applied to Step 396\'s inventory', () {
    gate(
      'ETMDI-016-07-G3',
      'Every screen in Step 396\'s inventory is classified.',
      'The inventory is imported rather than restated, so the two rows cannot '
          'drift apart',
      () =>
          HabotOneTransactionPerScreen.everyScreenIsClassified &&
          HabotOneTransactionPerScreen.inventory.length == 5,
    );

    gate(
      'ETMDI-016-07-G4',
      'Two screens have more than one action and one splits.',
      'The other keeps both actions because they answer the same question',
      () =>
          HabotOneTransactionPerScreen.oneOfTwoSplits &&
          HabotOneTransactionPerScreen.screensThatSplit == 1,
    );

    gate(
      'ETMDI-016-07-G5',
      'Five screens become six.',
      'The count rises by exactly one, and the split is named with its reason',
      () => HabotOneTransactionPerScreen.theCountRisesByOne,
    );

  });

  group('ETMDI-016-07 :: what does not split', () {
    gate(
      'ETMDI-016-07-G6',
      'Approve and decline stay together.',
      'Splitting them would put the two answers to one question on two screens '
          'and make declining the harder path',
      () =>
          HabotOneTransactionPerScreen.theTestIsTheQuestionNotTheWrite &&
          HabotOneTransactionPerScreen.decisionNote.contains('gets skipped'),
    );

    gate(
      'ETMDI-016-07-G7',
      'Atomicity is Step 19\'s rollback boundary.',
      'Rather than a second definition invented on this row',
      () =>
          HabotOneTransactionPerScreen.atomicityIsBoundToTheExistingBoundary &&
          HabotOneTransactionPerScreen.atomicNote.contains('two answers'),
    );

    gate(
      'ETMDI-016-07-G8',
      'The band mixes units.',
      'A floor written as a percentage against an optimal and a ceiling '
          'written as 1',
      () =>
          HabotOneTransactionPerScreen.theBandMixesUnits &&
          HabotOneTransactionPerScreen.theOptimalEqualsTheCeiling,
    );

  });

  group('ETMDI-016-07 :: the band and the arrow', () {
    gate(
      'ETMDI-016-07-G9',
      'The output cell carries an arrow.',
      '"Good/Average/Poor -> Best = Good (100%)" -- an output column that '
          'states its own answer',
      () => HabotOneTransactionPerScreen.theOutputColumnHoldsAnAnnotation,
    );

    gate(
      'ETMDI-016-07-G10',
      'Five obligations, all met, giving Good.',
      'And all ten declared checks hold',
      () =>
          HabotOneTransactionPerScreen.obligations.length == 5 &&
          HabotOneTransactionPerScreen.obligations.values
              .every((bool b) => b) &&
          HabotOneTransactionPerScreen.qualitativeOutput == 'Good' &&
          HabotOneTransactionPerScreen.atomicityRate == 80,
    );
  });

  tearDownAll(() {
    final int before = HabotOneTransactionPerScreen.inventory.length;
    final int after = HabotOneTransactionPerScreen.screensAfterTheSplit;
    final int splits = HabotOneTransactionPerScreen.screensThatSplit;
    final int writes =
        HabotOneTransactionPerScreen.writesWhenOvertimeIsApproved;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'ETMDI-016-07',
        atomicStepReferenceId: 'ETMDI-016-07',
        setupStepAction:
            'COLUMN NOTE: the Best Qualitative Output cell on this row reads '
            '"Good/Average/Poor -> Best = Good (100%)", the second '
            'arrow-annotated output cell in this batch; the band mixes ">=90%" '
            'with an optimal and a ceiling both written 1; the Data '
            'Requirement column holds step-execution fields beside Jetpack '
            'Compose layout advice identical to Step 396\'s; and the Setup '
            'Step column reads "Save the single-column stacking rules style '
            'assets to the central layout codebase". Atomic Step: "Assign '
            'exactly one atomic, singular system transaction to each newly '
            'separated screen."',
        implementationOrder: 397,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Step Execution ID': 'STEP-397-ONE-TRANSACTION-PER-SCREEN',
          'Execution Status':
              '$before screens classified, $splits split, $after screens after '
                  'the split',
          'Execution Timestamp': '2026-09-17T00:00:00Z',
          'Step Outcome':
              'one transaction per screen, where one transaction is $writes '
                  'writes on the overtime screen and still one decision',
          'User ID': 'Fredrick',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Task Atomicity / Single-Action Granularity Rate',
            observed:
                'BAND MIXES UNITS AND THE OUTPUT CELL HOLDS AN ARROW. Floor as '
                'a percentage, optimal and ceiling both 1, and an output '
                'column reading "Good/Average/Poor -> Best = Good (100%)". '
                'Observed: $after screens each carrying exactly one '
                'transaction, after $splits of $before split. The row uses '
                'three words for the rule and they are not synonyms: "exactly '
                'one" counts, "atomic" describes how a write fails, and '
                '"singular" describes what the screen is about -- and a screen '
                'can satisfy any one of the three while failing the others.',
            floor: '>=90%',
            optimal: '1',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Screens split for the metric rather than for the user',
            observed:
                '0 of $before. The approval screen keeps approve and decline '
                'together: they are two answers to one question, and splitting '
                'them would satisfy a single-action count while making '
                'declining the longer path. The screen that did split had two '
                'unrelated transactions behind one title, which is the case '
                'the rule exists for. Atomicity is bound to the rollback '
                'boundary Step 19 built rather than redefined here, so a '
                'partial write cannot report success.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/inventory/one_transaction_per_screen.dart',
        ],
      ),
    );
  });
}
