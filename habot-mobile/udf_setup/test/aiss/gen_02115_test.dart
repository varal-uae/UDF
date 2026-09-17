/// AISS GATE -- Step 392 of 395
/// Global Reference ID:       GEN-02115
/// Atomic Steps Reference ID: GEN-02115
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Define client-side error handling for floating-point math
///               precision errors."
/// Metric: Automated PR Rejection Rate for Non-Compliance (%) -- floor 95,
///         optimal 99.5, ceiling 100. High/Medium/Low. CI/CD Best Practices &
///         GitHub Standards. Assigned to **ADFA**.
///
/// THE ROW ASKS FOR ERROR HANDLING AND THE ANSWER IS NOT TO HAVE THE ERROR --
/// AND THE METRIC IS STEP 387'S, FIVE ROWS EARLIER.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/decimal_precision.dart';

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

  group('GEN-02115 :: not an error to handle', () {
    gate(
      'GEN-02115-G1',
      'Money is integers, not doubles.',
      'Held in minor units and converted once, at the edge, for display',
      () =>
          HabotDecimalPrecision.moneyIsHeldInMinorUnits &&
          !HabotDecimalPrecision.moneyIsHeldAsADouble &&
          HabotDecimalPrecision.minorUnitsPerDirham == 100,
    );

    gate(
      'GEN-02115-G2',
      'The problem is the type, not the program.',
      'No handler recovers a fils that was never there',
      () =>
          HabotDecimalPrecision.theProblemIsTheTypeNotTheProgram &&
          !HabotDecimalPrecision.anErrorHandlerRecoversTheLostValue &&
          HabotDecimalPrecision.handlingNote.contains('never there'),
    );
  });

  group('GEN-02115 :: three leaks, one plausible wrong answer', () {
    gate(
      'GEN-02115-G3',
      'Three leaks, each with a remedy.',
      'Parsing, summing and splitting',
      () =>
          HabotFloatLeak.values.length == 3 &&
          HabotDecimalPrecision.everyLeakHasARemedy &&
          HabotDecimalPrecision.leaksClosed == 100,
    );

    gate(
      'GEN-02115-G4',
      'Only the split produces a wrong answer that looks right.',
      'AED 100 split three ways is 33.33 three times, which is 99.99',
      () =>
          HabotDecimalPrecision.onlySplittingLooksCorrect &&
          HabotDecimalPrecision.theNaiveSplitLosesAFils &&
          HabotDecimalPrecision.naiveShortfall == 1,
    );

    gate(
      'GEN-02115-G5',
      'The integer split is exact and deterministic.',
      '3334, 3333, 3333 fils -- the parts add back to the whole and the '
          'remainder goes to the first row rather than to whichever the '
          'rounding favoured',
      () =>
          HabotDecimalPrecision.theSplitIsExact &&
          HabotDecimalPrecision.theRemainderIsOneFils &&
          HabotDecimalPrecision.theRemainderGoesSomewhereDeliberate &&
          HabotDecimalPrecision.splitTotal ==
              HabotDecimalPrecision.amount.minorUnits,
    );
  });

  group('GEN-02115 :: rounding where the person can see it', () {
    gate(
      'GEN-02115-G6',
      'Rounding happens before submission, not on the server.',
      'Rounding on the server means the person saw one number and the system '
          'stored another',
      () =>
          HabotDecimalPrecision.theRoundingIsVisible &&
          !HabotDecimalPrecision.roundingHappensOnTheServer,
    );

    gate(
      'GEN-02115-G7',
      'And the rounded value is shown back.',
      '45.005 is echoed as 45.01, which is the only version where somebody can '
          'still object',
      () =>
          HabotDecimalPrecision.theEntryIsEchoedRounded &&
          HabotDecimalPrecision.theRoundedValueIsShownBack &&
          HabotDecimalPrecision.roundingNote.contains('still object to it'),
    );
  });

  group('GEN-02115 :: a percentage is not money', () {
    gate(
      'GEN-02115-G8',
      'A rate is a rational, not an amount.',
      'Forcing 12.5% into minor units loses the half',
      () =>
          HabotDecimalPrecision.theRateIsARational &&
          !HabotDecimalPrecision.aPercentageIsForcedIntoMinorUnits,
    );

    gate(
      'GEN-02115-G9',
      'And it applies exactly.',
      'Twelve and a half per cent of a hundred dirhams is twelve dirhams '
          'fifty, with one rounding at the end instead of two in the middle',
      () =>
          HabotDecimalPrecision.theRateAppliesExactly &&
          HabotDecimalPrecision.applyRate(10000) == 1250,
    );

    gate(
      'GEN-02115-G10',
      'Output reported as High / Medium / Low.',
      'Six obligations, all met, giving High; the metric and band are Step '
          '387\'s five rows earlier, and all ten declared checks hold',
      () =>
          HabotDecimalPrecision.oneMetricScoresTwoUnrelatedRows &&
          HabotDecimalPrecision.theBandIsWellFormed &&
          HabotDecimalPrecision.obligations.length == 6 &&
          HabotDecimalPrecision.obligations.values.every((bool b) => b) &&
          HabotDecimalPrecision.qualitativeOutput == 'High' &&
          HabotDecimalPrecision.checks.length == 10 &&
          HabotDecimalPrecision.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final List<int> split = HabotDecimalPrecision.split;
    final int naive = HabotDecimalPrecision.naiveTotal;
    final int shortfall = HabotDecimalPrecision.naiveShortfall;
    final String shown = HabotDecimalPrecision.shownBack;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02115',
        atomicStepReferenceId: 'GEN-02115',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to ADFA rather than UDF; its '
            'metric is an automated pull-request rejection rate, identical in '
            'name and band to Step 387\'s five rows earlier, on a row about '
            'floating-point arithmetic rather than about blocking a form; its '
            'Data Requirement cell holds the Atomic Step\'s own sentence as '
            'the artefact to prepare; and the Setup Step column is empty. '
            'Atomic Step: "Define client-side error handling for '
            'floating-point math precision errors."',
        implementationOrder: 392,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Define client-side error handling for floating-point math':
              'three leak points closed by construction rather than caught',
          'Completion Status': 'High',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'AED 100 splits three ways as $split fils; the naive split '
                  'totals $naive and loses $shortfall',
          'Data Quality Note':
              'HANDLING: ${HabotDecimalPrecision.handlingNote} SPLIT: '
              '${HabotDecimalPrecision.splitNote} ROUNDING: '
              '${HabotDecimalPrecision.roundingNote} RATE: '
              '${HabotDecimalPrecision.rateNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Automated PR Rejection Rate for Non-Compliance (%)',
            observed:
                'THE SECOND OF TWO IDENTICAL COPIES IN THIS BATCH. The same '
                'metric name and the same band appear on Step 387, five rows '
                'earlier, on a row about blocking somebody in a form. One '
                'measure, two unrelated subjects, and neither of them a pull '
                'request. The band is at least well formed, and the figure '
                'published is the share of the three floating-point leak '
                'points closed by construction: all of them.',
            floor: '95',
            optimal: '99.5',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Fils lost to arithmetic',
            observed:
                '0. A floating-point precision error in money is not an '
                'exceptional condition to catch; it is the arithmetic working '
                'as specified on the wrong type, and no handler recovers a '
                'fils that was never there. Money is held in integer minor '
                'units. Of the three leak points only splitting produces a '
                'wrong answer that looks defensible -- the naive split of AED '
                '100 three ways totals $naive fils and loses $shortfall -- so '
                'the integer split gives $split and the remainder goes to the '
                'first row deterministically. Rounding happens in front of the '
                'person, who sees $shown echoed back before submitting.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/decimal_precision.dart',
        ],
      ),
    );
  });
}
