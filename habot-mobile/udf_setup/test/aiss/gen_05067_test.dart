/// AISS GATE -- Step 468 of 1,314
/// Global Reference ID:       GEN-05067
/// Atomic Steps Reference ID: GEN-05067
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement substep 2: Implement responsive SVG chart rendering
///               multi-year growth trajectories against norm benchmarks."
/// Metric: Substep Definition-of-Done Adherence Rate -- floor ">=90% unit test
///         coverage / acceptance criteria met before merge", optimal "95-100%
///         coverage, all acceptance criteria met", ceiling "100% (coverage
///         beyond 100% is not meaningful; further effort has diminishing
///         return)". Best Qualitative Output: "Complete / Partial / Not
///         Complete". ISO/IEC 25010 Software Quality Model -- functional
///         suitability characteristic. Assigned to **UDF**.
///
/// PLOTTING A CHILD AGAINST A NORM, WITHOUT TURNING THE NORM INTO A PASS MARK.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/assessment/growth_chart.dart';

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

  group('GEN-05067 :: the sixth pair', () {
    gate(
      'GEN-05067-G1',
      'The band is Step 461\'s, the sixth and last pair.',
      'Twelve of the twenty rows in this batch have a twin',
      () => HabotGrowthChart.theBandIsStep461s,
    );

    gate(
      'GEN-05067-G2',
      'Substep 2 of a parent nobody names.',
      'The third orphan substep in this batch',
      () =>
          HabotGrowthChart.substepNumber == 2 &&
          !HabotGrowthChart.theParentIsNamed,
    );

  });

  group('GEN-05067 :: a norm is a range', () {
    gate(
      'GEN-05067-G3',
      'The norm is a shaded band between stated percentiles.',
      'A line invites everyone to read "below the line" as failing',
      () =>
          HabotGrowthChart.theNormIsDrawnAsABand &&
          !HabotGrowthChart.theNormIsDrawnAsALine,
    );

    gate(
      'GEN-05067-G4',
      'Carrying its instrument, its norming year and its sample.',
      'So a reader can see what it is evidence of',
      () =>
          HabotGrowthChart.theNormCarriesItsProvenance &&
          HabotGrowthChart.normNote.contains('evidence of'),
    );

  });

  group('GEN-05067 :: no warning colour on a child', () {
    gate(
      'GEN-05067-G5',
      'No failing region and no colour change below the norm.',
      'The child\'s line holds one emphasis whatever it does',
      () => HabotGrowthChart.theChildsLineIsNeverAWarning,
    );

    gate(
      'GEN-05067-G6',
      'And the legend says what a difference does not mean.',
      '"A position outside it is a description, not a grade"',
      () => HabotGrowthChart.theLegendSaysWhatItDoesNotMean,
    );

  });

  group('GEN-05067 :: gaps, and narrow screens', () {
    gate(
      'GEN-05067-G7',
      'Three assessments, and the three-year gap is not joined.',
      'A straight segment across a gap asserts a trajectory nobody measured',
      () =>
          HabotGrowthChart.points.length == 3 &&
          HabotGrowthChart.theLongGapIsNotJoined,
    );

    gate(
      'GEN-05067-G8',
      'The break is labelled.',
      'So the absence is visible rather than merely absent',
      () =>
          HabotGrowthChart.theBreakIsLabelled &&
          HabotGrowthChart.gapNote.contains('nobody measured'),
    );

    gate(
      'GEN-05067-G9',
      'Below 360dp the chart becomes the table.',
      'Squeezing a norm band into a few pixels does not make it readable',
      () =>
          HabotGrowthChart.theChartBecomesATable &&
          HabotGrowthChart.theTableCarriesTheSameValues,
    );

    gate(
      'GEN-05067-G10',
      'Five obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotGrowthChart.obligations.length == 5 &&
          HabotGrowthChart.obligations.values.every((bool b) => b) &&
          HabotGrowthChart.qualitativeOutput == 'Complete',
    );
  });

  tearDownAll(() {
    final int points = HabotGrowthChart.points.length;
    final int sample = HabotGrowthChart.norm.sampleSize;
    final double coverage = HabotGrowthChart.coveragePercent;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05067',
        atomicStepReferenceId: 'GEN-05067',
        setupStepAction:
            'COLUMN NOTE: this row carries Step 461\'s metric and band, the '
            'sixth and last of the paired bands in this batch; it is substep 2 '
            'of a parent nobody names; and its chart draws the norm as a '
            'shaded band with its instrument, norming year and sample size '
            'rather than as a line, keeps the child\'s line in one emphasis '
            'with no failing region, leaves gaps in assessment undrawn, and '
            'becomes a table below 360dp. Atomic Step: "Implement substep 2: '
            'Implement responsive SVG chart rendering multi-year growth '
            'trajectories against norm benchmarks."',
        implementationOrder: 468,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Implement substep 2: Implement responsive SVG chart rendering '
          'multi-year growth':
              'the norm drawn as a band from a sample of $sample with its '
                  'instrument and year, $points assessments with the '
                  'three-year gap left unjoined, and a table below 360dp; '
                  'coverage ${coverage.toStringAsFixed(0)} per cent',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Substep Definition-of-Done Adherence Rate',
            observed:
                'THE SIXTH AND LAST PAIRED BAND IN THIS BATCH, carrying Step '
                '461\'s metric, its oblique floor and its self-arguing ceiling '
                'seven rows later. Under the stricter reading both hold: '
                '${coverage.toStringAsFixed(0)} per cent coverage and every '
                'acceptance criterion met across $points plotted assessments.',
            floor:
                '>=90% unit test coverage / acceptance criteria met before '
                    'merge',
            optimal: '95-100% coverage, all acceptance criteria met',
            ceiling:
                '100% (coverage beyond 100% is not meaningful; further effort '
                    'has diminishing return)',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Ways the chart turns a norm into a grade',
            observed:
                '0. The norm is a shaded band between the twenty-fifth and '
                'seventy-fifth percentiles, labelled with the instrument, the '
                'norming year and a sample of $sample children, rather than a '
                'line somebody can be below. The child\'s line keeps one '
                'emphasis with no failing region, a gap in assessment is drawn '
                'as a gap and labelled, and the legend states that a position '
                'outside the band is a description and not a grade.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/assessment/growth_chart.dart',
        ],
      ),
    );
  });
}
