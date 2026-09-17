/// AISS GATE -- Step 358 of 375
/// Global Reference ID:       GEN-01407
/// Atomic Steps Reference ID: GEN-01407
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Display verified safety account ratios on security
///               monitoring dashboards."
/// Metric: Dashboard Data Refresh Latency -- floor "<1 hour", optimal
///         "<5 minutes", ceiling "<24 hours". Good/Average/Poor. Modern Data
///         Stack SLA Benchmark (dbt/Fivetran).
///
/// THE BATCH'S HEADLINE: ONE BAND, SIX ROWS. THE SAME THREE CELLS ON STEPS
/// 358, 362, 374 AND 375, AND ALREADY TOKENISED BY STEPS 163 AND 175.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/badges/safety_ratio_panel.dart';

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

  group('GEN-01407 :: one band, six rows', () {
    gate(
      'GEN-01407-G1',
      'Ceiling 24 hours against a floor of 1 hour.',
      'Twenty-four times the floor, and read as every other latency band in '
          'this sheet is read it says a day-old dashboard is ideal',
      () =>
          HabotSafetyRatioPanel.theBandIsInverted &&
          HabotSafetyRatioPanel.theCeilingIsTwentyFourTimesTheFloor,
    );

    gate(
      'GEN-01407-G2',
      'Six rows carry these identical three cells.',
      'Steps 163 and 175, which tokenised them, and Steps 358, 362, 374 and '
          '375 of this batch',
      () =>
          HabotSafetyRatioPanel.sixRowsShareOneBand &&
          HabotSafetyRatioPanel.newInThisBatch.length == 4 &&
          HabotSafetyRatioPanel.rowsSharingThisBand.contains(163),
    );

    gate(
      'GEN-01407-G3',
      'The band was already tokenised in this repository.',
      'dashboardRefreshFloor, dashboardRefreshOptimal and '
          'dashboardRefreshCeiling, read here rather than restated',
      () => HabotSafetyRatioPanel.theBandWasAlreadyTokenised,
    );

    gate(
      'GEN-01407-G4',
      'Every inversion recorded before this was a single cell.',
      'Six identical copies is a template, which puts the defect in whatever '
          'produced the rows -- and takes the track\'s count to ten',
      () =>
          HabotSafetyRatioPanel.theCountReachesTen &&
          HabotSafetyRatioPanel.inversionsBeforeThisBatch == 6 &&
          HabotSafetyRatioPanel.bandNote.contains('a template'),
    );
  });

  group('GEN-01407 :: a ratio needs a denominator', () {
    gate(
      'GEN-01407-G5',
      'Every label carries the population it was computed over.',
      '98% of 3,000 and 98% of 30 are different facts on a security dashboard',
      () =>
          HabotSafetyRatioPanel.everyLabelCarriesTheDenominator &&
          HabotSafetyRatioPanel.denominatorNote.contains('decides'),
    );

    gate(
      'GEN-01407-G6',
      'A ratio below thirty is published as a count.',
      'Two of three is not sixty-seven per cent in any sense a reader can use',
      () =>
          HabotSafetyRatioPanel.twoOfThreeArePublishableAsPercentages &&
          HabotSafetyRatioPanel.minimumPopulation == 30 &&
          HabotSafetyRatioPanel.labelFor(HabotSafetyRatioPanel.ratios.last) ==
              '2 of 3',
    );
  });

  group('GEN-01407 :: verified against what', () {
    gate(
      'GEN-01407-G7',
      'Three bases, kept apart.',
      'An identity document, a background check and a bank record are three '
          'processes at three different times',
      () =>
          HabotSafetyRatioPanel.everyRatioNamesItsBasis &&
          !HabotSafetyRatioPanel.theRatiosAreCombinedIntoOne &&
          HabotSafetyBasis.values.length == 3,
    );

    gate(
      'GEN-01407-G8',
      'The widest gap between two bases is 28 points.',
      '98.0 per cent on documents against 70.0 per cent on background checks '
          '-- the number a combined ratio would have averaged away',
      () =>
          HabotSafetyRatioPanel.theGapIsTwentyEightPoints &&
          HabotSafetyRatioPanel.basisNote
              .contains('three different processes'),
    );
  });

  group('GEN-01407 :: the panel labels its own age', () {
    gate(
      'GEN-01407-G9',
      'An hour-old panel is labelled Delayed.',
      'The panel does not adopt the row\'s band -- adopting it would mean '
          'treating a day-old security dashboard as ideal',
      () =>
          HabotSafetyRatioPanel.anHourOldPanelIsLabelledDelayed &&
          HabotSafetyRatioPanel.theFreshnessVocabularyIsAlreadyDeclared &&
          HabotSafetyRatioPanel.freshnessNote.contains('Step 129'),
    );

    gate(
      'GEN-01407-G10',
      'Output reported as Good / Average / Poor.',
      'Five obligations, all met, giving Good; all ten declared checks hold',
      () =>
          HabotSafetyRatioPanel.obligations.length == 5 &&
          HabotSafetyRatioPanel.obligations.values.every((bool b) => b) &&
          HabotSafetyRatioPanel.qualitativeOutput == 'Good' &&
          HabotSafetyRatioPanel.checks.length == 10 &&
          HabotSafetyRatioPanel.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final int sharing = HabotSafetyRatioPanel.rowsSharingThisBand.length;
    final int total = HabotSafetyRatioPanel.inversionsAfterThisBatch;
    final String small =
        HabotSafetyRatioPanel.labelFor(HabotSafetyRatioPanel.ratios.last);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01407',
        atomicStepReferenceId: 'GEN-01407',
        setupStepAction:
            'COLUMN NOTE: the band on this row sets a ceiling of 24 hours '
            'against a floor of 1 hour on a lower-is-better measure, and the '
            'same three cells appear verbatim on Steps 362, 374 and 375 of '
            'this batch and on Steps 163 and 175, which tokenised them; the '
            'Data Requirement cell holds the Atomic Step\'s own text as the '
            'artefact to prepare; and the Setup Step column is empty. Atomic '
            'Step: "Display verified safety account ratios on security '
            'monitoring dashboards."',
        implementationOrder: 358,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Display verified safety account ratios on security monitoring '
                  'dashboards.':
              '3 ratios against 3 named bases, none averaged; the smallest '
                  'population is published as "$small"',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the panel labels its own age from the Step 129 policy rather '
                  'than adopting the row\'s band',
          'Data Quality Note':
              'BAND: ${HabotSafetyRatioPanel.bandNote} '
              'DENOMINATOR: ${HabotSafetyRatioPanel.denominatorNote} '
              'BASIS: ${HabotSafetyRatioPanel.basisNote} '
              'FRESHNESS: ${HabotSafetyRatioPanel.freshnessNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Dashboard Data Refresh Latency',
            observed:
                'ONE BAND, $sharing ROWS. A ceiling of 24 hours against a '
                'floor of 1 hour is twenty-four times the floor in the wrong '
                'direction, and the same three cells appear character for '
                'character on Steps 358, 362, 374 and 375 of this batch and on '
                'Steps 163 and 175, which already tokenised them as '
                'dashboardRefreshFloor, dashboardRefreshOptimal and '
                'dashboardRefreshCeiling. Those earlier steps read the ceiling '
                'as the worst bound, which is sensible and is the opposite of '
                'how every other latency band in this sheet uses its ceiling. '
                'Every inversion recorded before this was one cell somebody '
                'got wrong; $sharing identical copies is a template, and the '
                'track\'s inversion count reaches $total.',
            floor: '<1 hour',
            optimal: '<5 minutes',
            ceiling: '<24 hours',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Ratios published without their denominator',
            observed:
                '0 of 3. Every label carries the population it was computed '
                'over, and a ratio over fewer than thirty is published as a '
                'count instead -- "$small" rather than a percentage -- because '
                'two of three is not sixty-seven per cent in any sense a '
                'reader can use. The three bases are kept apart rather than '
                'averaged, and the 28-point gap between identity documents and '
                'background checks is the figure a combined ratio would have '
                'hidden.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/badges/safety_ratio_panel.dart',
        ],
      ),
    );
  });
}
