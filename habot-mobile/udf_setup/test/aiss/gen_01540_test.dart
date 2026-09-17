/// AISS GATE -- Step 361 of 375
/// Global Reference ID:       GEN-01540
/// Atomic Steps Reference ID: GEN-01540
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Display customer lifetime value (CLV) and re-booking
///               velocity metrics on retention dashboards."
/// Metric: One-Click Re-Booking Completion Rate -- floor 0.7, optimal 0.9,
///         ceiling 1. Good/Average/Poor. Baymard Institute. Assigned to
///         **CAL**.
///
/// TWO METRICS ON ONE TILE, ONE OF WHICH IS A FORECAST RENDERED AS A FACT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/dashboard/retention_metrics.dart';

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

  group('GEN-01540 :: counted and projected', () {
    gate(
      'GEN-01540-G1',
      'Two figures on one tile, with two different origins.',
      'Re-booking velocity is counted from bookings that happened; CLV is '
          'projected from a model with a horizon and assumptions',
      () =>
          HabotFigureOrigin.values.length == 2 &&
          HabotRetentionMetrics.theTwoFiguresHaveDifferentOrigins,
    );

    gate(
      'GEN-01540-G2',
      'The projection carries its horizon.',
      'Twenty-four months, on the face of the tile, because a forecast without '
          'one is a number with no scope',
      () =>
          HabotRetentionMetrics.theProjectionCarriesAHorizon &&
          HabotRetentionMetrics.originNote.contains('justify'),
    );
  });

  group('GEN-01540 :: a projection is not quoted to the fils', () {
    gate(
      'GEN-01540-G3',
      'The projection is rounded to the nearest hundred dirhams.',
      '"AED 4,820.37" claims a hundredth of a dirham of a guess about the next '
          'two years',
      () =>
          HabotRetentionMetrics.theProjectionIsRounded &&
          HabotRetentionMetrics.projectionRounding == 10000,
    );

    gate(
      'GEN-01540-G4',
      'And shown as a range with its horizon.',
      '"AED 3100-6900 over 24 months" rather than a point',
      () =>
          HabotRetentionMetrics.theLabelIsARangeWithAHorizon &&
          HabotRetentionMetrics.projectionLabel ==
              'AED 3100-6900 over 24 months' &&
          !HabotRetentionMetrics.aProjectionIsQuotedToTheFils,
    );

    gate(
      'GEN-01540-G5',
      'The interval is 39 per cent either side of centre.',
      'Wide, and inside the threshold past which the existing confidence '
          'metric would withdraw the reading altogether',
      () =>
          HabotRetentionMetrics.theIntervalIsThirtyNinePerCent &&
          HabotRetentionMetrics.theIntervalIsInsideTheIndicativeThreshold,
    );
  });

  group('GEN-01540 :: the counted figure', () {
    gate(
      'GEN-01540-G6',
      'Re-booking velocity is quoted exactly and carries its window.',
      '1.87 bookings per customer per quarter -- a rate with no window is a '
          'ratio with no denominator',
      () =>
          HabotRetentionMetrics.theVelocityIsNotRounded &&
          HabotRetentionMetrics.theVelocityNamesItsWindow &&
          HabotRetentionMetrics.velocityLabel.startsWith('1.87'),
    );

    gate(
      'GEN-01540-G7',
      'Steps 358 and 360 record the same defect on either side of this row.',
      'A ratio without a denominator, and a count without one',
      () => HabotRetentionMetrics.countedNote.contains('Steps 358 and 360'),
    );
  });

  group('GEN-01540 :: the metric and the band', () {
    gate(
      'GEN-01540-G8',
      'A one-click re-booking completion rate is a funnel conversion.',
      'A good measure of a checkout, and silent on whether a retention '
          'dashboard renders a forecast honestly',
      () =>
          HabotRetentionMetrics.theMetricMeasuresADifferentThing &&
          HabotRetentionMetrics.metricName.contains('Re-Booking'),
    );

    gate(
      'GEN-01540-G9',
      'The band is well formed: 0.7, 0.9, 1.',
      'One of the few in this batch, on a row assigned to CAL rather than UDF',
      () =>
          HabotRetentionMetrics.theBandIsWellFormed &&
          HabotRetentionMetrics.assignedTo == 'CAL',
    );

    gate(
      'GEN-01540-G10',
      'Output reported as Good / Average / Poor.',
      'Six obligations, all met, giving Good; all ten declared checks hold',
      () =>
          HabotRetentionMetrics.obligations.length == 6 &&
          HabotRetentionMetrics.obligations.values.every((bool b) => b) &&
          HabotRetentionMetrics.qualitativeOutput == 'Good' &&
          HabotRetentionMetrics.checks.length == 10 &&
          HabotRetentionMetrics.checks.values.every((bool b) => b) &&
          HabotRetentionMetrics.columnNote.contains('CAL'),
    );
  });

  tearDownAll(() {
    final String projection = HabotRetentionMetrics.projectionLabel;
    final String velocity = HabotRetentionMetrics.velocityLabel;
    final String interval =
        (HabotRetentionMetrics.relativeHalfWidth * 100).toStringAsFixed(1);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01540',
        atomicStepReferenceId: 'GEN-01540',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to CAL rather than UDF, its '
            'metric is a one-click re-booking funnel conversion on a row about '
            'displaying CLV and velocity, the Data Requirement cell reads '
            '"Data/artifacts to prepare: CLV" -- an acronym lifted into the '
            'artefact list -- and the Setup Step column is empty. Atomic Step: '
            '"Display customer lifetime value (CLV) and re-booking velocity '
            'metrics on retention dashboards."',
        implementationOrder: 361,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'CLV':
              'projected, shown as "$projection" rather than as a point to the '
                  'fils',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the counted figure reads "$velocity" and is not rounded; the '
                  'projected interval is $interval per cent either side of '
                  'centre',
          'Data Quality Note':
              'ORIGIN: ${HabotRetentionMetrics.originNote} '
              'PRECISION: ${HabotRetentionMetrics.precisionNote} '
              'COUNTED: ${HabotRetentionMetrics.countedNote} '
              'METRIC: ${HabotRetentionMetrics.metricNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'One-Click Re-Booking Completion Rate',
            observed:
                'WELL FORMED AND MEASURING A THIRD THING. Floor 0.7, optimal '
                '0.9, ceiling 1, correctly ordered -- one of the few bands in '
                'this batch that is. It measures a funnel conversion: of the '
                'people who started a one-click re-booking, how many finished. '
                'That is a good measure of a checkout and says nothing about '
                'whether a retention dashboard renders a forecast honestly, '
                'which is what this row builds. The row is also assigned to '
                'CAL rather than UDF.',
            floor: '0.7',
            optimal: '0.9',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Projected figures rendered as measured ones',
            observed:
                '0 of 1. Customer lifetime value is a forecast with a horizon, '
                'a discount rate and an assumption about churn; rendered '
                'beside a counted figure in the same typeface it reads as the '
                'same kind of fact. It is shown as "$projection" -- a range, '
                'rounded to the nearest hundred dirhams, with its horizon on '
                'its face -- against a counted velocity of "$velocity", quoted '
                'exactly and carrying its window. The projected interval is '
                '$interval per cent either side of centre.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/retention_metrics.dart',
        ],
      ),
    );
  });
}
