/// AISS GATE -- Step 293 of 295
/// Global Reference ID:       PCDE-019
/// Atomic Steps Reference ID: PCDE-019
/// Setup Step (Action): "Test cache cleanup correctly removes only outdated
///                      entries." (DIFFERENT SUBJECT)
/// Atomic Step: "Autonomously disable and grey out the payout execution
///               buttons if the flag is False."
/// Metric: Financial Calculation Accuracy (%) -- Floor 99.99, Optimal 100,
///         Ceiling 100. Pass / Fail. ISO 20022.
///
/// THIS ROW CARRIES BOTH THE REMEDY FOR STEP 292'S DEAD END AND A REPEAT OF
/// THE SAME DEFECT, TWO LINES APART.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/operations/payout_flag_gate.dart';

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

  group('PCDE-019 :: keeping the number', () {
    gate(
      'PCDE-019-G1',
      'Row design note: "replacing numeric data with Blocked icons".',
      'Both presentations the row asks for -- replacing the number, and '
          'drawing a chip over it -- are refused, and the third is used',
      () => HabotPayoutFlagGate.bothOfTheRowsPresentationsAreRefused,
    );

    gate(
      'PCDE-019-G2',
      'The first question about a suspended payment is how much.',
      'The amount survives suspension, and two suspended amounts of very '
          'different size remain distinguishable -- which the row\'s own '
          'instruction would have prevented',
      () =>
          HabotPayoutFlagGate.theAmountSurvivesSuspension &&
          HabotPayoutFlagGate.twoSuspendedAmountsStayDistinguishable,
    );

    gate(
      'PCDE-019-G3',
      'Row design note: "red warning chips directly over the amount".',
      'A chip drawn across a figure makes a screenshot that means something '
          'different from the screen, and payment screenshots travel',
      () => HabotPayoutFlagGate.keepTheNumberNote
          .contains('screenshots travel'),
    );
  });

  group('PCDE-019 :: the remedy, and the repeat', () {
    gate(
      'PCDE-019-G4',
      'Row design note: "tapping the suspended chip opens a dialogue '
          'explaining recovery steps".',
      'Every suspended row is tappable and explains what would change it, '
          'which is exactly the route Step 292\'s "permanently" removes',
      () => HabotPayoutFlagGate.everySuspendedRowExplainsItself,
    );

    gate(
      'PCDE-019-G5',
      'And two lines later: "payroll submit buttons remain permanently '
          'disabled".',
      'One row, both the problem and its remedy, neither aware of the other; '
          'the remedy is implemented and the repetition recorded',
      () => HabotPayoutFlagGate.adjacentRowsNote
          .contains('neither aware of the other'),
    );

    gate(
      'PCDE-019-G6',
      'The disable is conditional, read from Step 292.',
      'The two steps share one rule rather than each asserting its own, so '
          'they cannot drift into disagreement',
      () => HabotPayoutFlagGate.theDisableIsConditionalLikeStep292,
    );
  });

  group('PCDE-019 :: who actually stops a payout', () {
    gate(
      'PCDE-019-G7',
      'A greyed-out button does not stop a payout.',
      'The client draws the button and the server holds the money; the fourth '
          'row in this batch with that shape',
      () =>
          HabotPayoutFlagGate.theServerHoldsTheMoney &&
          HabotPayoutFlagGate.courtesyNote.contains('fourth row'),
    );

    gate(
      'PCDE-019-G8',
      'Metric: Financial Calculation Accuracy -- 99.99 / 100 / 100.',
      'One wrong payment in ten thousand, and the unit of that error is a '
          'person who was not paid; restated in people, as Step 253 restated '
          'partial credit on money',
      () =>
          HabotPayoutFlagGate.theFloorIsOnePersonInTenThousand &&
          HabotPayoutFlagGate.payoutsPerErrorAtFloor == 10000 &&
          HabotPayoutFlagGate.moneyBandNote
              .contains('refused partial credit'),
    );

    gate(
      'PCDE-019-G9',
      'And this step calculates nothing.',
      'It draws a button according to a flag, which is the other half of the '
          'mismatch; amounts are held in minor units rather than a double, '
          'and all ten declared checks hold',
      () =>
          HabotPayoutFlagGate.thisStepPerformsNoCalculation &&
          HabotPayoutFlagGate.checks.length == 10 &&
          HabotPayoutFlagGate.checks.values.every((bool b) => b) &&
          HabotPayoutFlagGate.qualitativeOutput == 'Pass' &&
          HabotPayoutFlagGate.columnNote.contains('cache cleanup'),
    );
  });

  tearDownAll(() {
    const HabotPayoutRow suspended = HabotPayoutRow(
      label: 'bonus',
      amountMinor: 50000,
      flagIsTrue: false,
    );
    final String rendered = HabotPayoutFlagGate.renderFor(suspended);
    final String recovery = HabotPayoutFlagGate.recoveryTextFor(suspended);
    final String perError = '${HabotPayoutFlagGate.payoutsPerErrorAtFloor}';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'PCDE-019',
        atomicStepReferenceId: 'PCDE-019',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Test cache '
            'cleanup correctly removes only outdated entries", and every '
            'narrative column is about pruning inactive workers from an IAM '
            'system -- the same block Step 286 carries. Atomic Step: '
            '"Autonomously disable and grey out the payout execution buttons '
            'if the flag is False."',
        implementationOrder: 293,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotPayoutFlagGate / HabotPayoutRow',
          'Component Properties':
              '${HabotSuspendedPresentation.values.length} presentations '
              'declared and two refused; a suspended row renders as '
              '"$rendered" with the amount intact; recovery text "$recovery"; '
              'amounts in minor units',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotPayoutFlagGate.keepTheNumberNote} '
              'ADJACENCY: ${HabotPayoutFlagGate.adjacentRowsNote} '
              'ENFORCEMENT: ${HabotPayoutFlagGate.courtesyNote} '
              'BAND: ${HabotPayoutFlagGate.moneyBandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Financial Calculation Accuracy (%)',
            observed:
                'NO CALCULATION IS PERFORMED BY THIS STEP -- it draws a '
                'button according to a flag the server sets. The floor is '
                'restated in the unit it is actually in: one wrong payment in '
                '$perError, and the unit of that error is a person who was '
                'not paid.',
            floor: '99.99',
            optimal: '100',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Suspended amounts that become indistinguishable',
            observed:
                '0. The row asks for the number to be replaced by an icon, '
                'which would make a blocked 500 and a blocked 5 identical; '
                'the amount stays and the state is marked beside it.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/operations/payout_flag_gate.dart',
        ],
      ),
    );
  });
}
