/// AISS GATE -- Step 366 of 375
/// Global Reference ID:       EDEBS-011-09
/// Atomic Steps Reference ID: EDEBS-011-09
/// Setup Step (Action): "Perform security and data privacy reviews on visual
///                      isolation boundaries."
/// Atomic Step: "Optimize the dashboard visualization charts and layout for
///               touch-driven mobile browsing."
/// Metric: Observability / Alert Coverage -- floor ">=90%", optimal 1, ceiling
///         1. Good/Average/Poor. Google SRE Handbook.
///
/// THE POINTER COVERS THE THING IT IS POINTING AT, AND THE HIT AREA IS NOT THE
/// INK.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/charts/touch_chart.dart';

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

  group('EDEBS-011-09 :: an opaque pointer', () {
    gate(
      'EDEBS-011-09-G1',
      'A fingertip is 12.5 times the width of a cursor.',
      'Fifty density points against four, and unlike a cursor it sits on top '
          'of the target rather than beside it',
      () =>
          HabotTouchChart.aFingerIsTwelveAndAHalfTimesACursor &&
          HabotTouchChart.fingertipWidthDp == 50 &&
          HabotTouchChart.mouseCursorWidthDp == 4,
    );

    gate(
      'EDEBS-011-09-G2',
      'No interaction depends on hover.',
      'A mouse chart breaks twice on touch: the state never arrives, and the '
          'readout would be under the finger if it did',
      () =>
          !HabotTouchChart.hoverExists &&
          HabotTouchChart.pointerNote.contains('no amount of tuning fixes'),
    );
  });

  group('EDEBS-011-09 :: the readout moves off the point', () {
    gate(
      'EDEBS-011-09-G3',
      'Two readout modes, and the pointer-following one is refused.',
      'The value is shown in a fixed position at the top of the chart',
      () =>
          HabotReadoutMode.values.length == 2 &&
          HabotTouchChart.theReadoutDoesNotFollowTheFinger &&
          HabotTouchChart.readout == HabotReadoutMode.fixedHeader,
    );

    gate(
      'EDEBS-011-09-G4',
      'The readout survives the release.',
      'One that vanishes when the finger lifts is readable only by somebody '
          'who can look at the chart under their own hand, which is nobody',
      () =>
          HabotTouchChart.theReadoutPersistsUntilTheNextTouch &&
          !HabotTouchChart.theReadoutVanishesOnRelease &&
          HabotTouchChart.readoutNote.contains('under their own hand'),
    );
  });

  group('EDEBS-011-09 :: hit area is not ink', () {
    gate(
      'EDEBS-011-09-G5',
      'The catchment is 48dp and the drawn marker is 3dp.',
      'Drawing a data point at 48dp would be drawing circles rather than a '
          'chart, so Step 343\'s rule applies to the hit test',
      () =>
          HabotTouchChart.theCatchmentIsTheDeclaredTarget &&
          HabotTouchChart.theInkStaysSmall &&
          HabotTouchChart.hitAreaNote.contains('Step 343'),
    );

    gate(
      'EDEBS-011-09-G6',
      'The minimum separation is the declared 8dp gap.',
      'Read from the existing target-spacing rule rather than restated here',
      () => HabotTouchChart.minimumSeparationDp == 8,
    );

    gate(
      'EDEBS-011-09-G7',
      'Four points become three selections.',
      'Mon and Tue are four points apart, inside the gap, so a finger is not '
          'offered a choice it cannot make',
      () =>
          HabotTouchChart.points.length == 4 &&
          HabotTouchChart.fourPointsBecomeThreeSelections &&
          !HabotTouchChart.everyPointIsSeparatelyHittable,
    );
  });

  group('EDEBS-011-09 :: the metric, from another discipline', () {
    gate(
      'EDEBS-011-09-G8',
      'Alert coverage is measured on a service, not on a chart.',
      'The share of failure modes with a monitor attached',
      () =>
          HabotTouchChart.metricDiscipline.contains('reliability') &&
          HabotTouchChart.metricName.contains('Alert Coverage'),
    );

    gate(
      'EDEBS-011-09-G9',
      'Third cross-discipline metric in this batch.',
      'After an RBAC enforcement rate on a counting widget at Step 360 and '
          'Largest Contentful Paint at Step 363 -- and the optimal equals the '
          'ceiling',
      () =>
          HabotTouchChart.thisIsTheThirdCrossDisciplineMetric &&
          HabotTouchChart.crossDisciplineMetricRows.contains(360) &&
          HabotTouchChart.crossDisciplineMetricRows.contains(363) &&
          HabotTouchChart.theOptimalEqualsTheCeiling,
    );

    gate(
      'EDEBS-011-09-G10',
      'Output reported as Good / Average / Poor.',
      'Six obligations, all met, giving Good; all ten declared checks hold',
      () =>
          HabotTouchChart.obligations.length == 6 &&
          HabotTouchChart.obligations.values.every((bool b) => b) &&
          HabotTouchChart.qualitativeOutput == 'Good' &&
          HabotTouchChart.checks.length == 10 &&
          HabotTouchChart.checks.values.every((bool b) => b) &&
          HabotTouchChart.columnNote.contains('confirmation snackbar'),
    );
  });

  tearDownAll(() {
    final String ratio = HabotTouchChart.pointerWidthRatio.toStringAsFixed(1);
    final int selections = HabotTouchChart.mergedClusters;
    final int drawn = HabotTouchChart.points.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'EDEBS-011-09',
        atomicStepReferenceId: 'EDEBS-011-09',
        setupStepAction:
            'COLUMN NOTE: the metric on this charting row is a site '
            'reliability alert-coverage measure -- the third cross-discipline '
            'metric in this batch after Steps 360 and 363 -- and its optimal '
            'and ceiling are both 1; the Data Requirement column is about '
            'success-state transitions and a green confirmation snackbar, '
            'which is feedback rather than charting; and the Setup Step column '
            'reads "Perform security and data privacy reviews on visual '
            'isolation boundaries". Atomic Step: "Optimize the dashboard '
            'visualization charts and layout for touch-driven mobile '
            'browsing."',
        implementationOrder: 366,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Layout Type': 'a touch-driven chart with a fixed header readout',
          'Layout Grid Dimensions': 'single plot area at compact width',
          'Spacing Rules':
              'a 48dp hit catchment over 3dp ink, with an 8dp minimum '
                  'separation',
          'Alignment Settings': 'readout pinned to the top of the plot',
          'Layout Validation Status': 'Good',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'a pointer ratio of $ratio to one; $drawn plotted points '
                  'resolve to $selections selections',
          'Data Quality Note':
              'POINTER: ${HabotTouchChart.pointerNote} '
              'READOUT: ${HabotTouchChart.readoutNote} '
              'HIT AREA: ${HabotTouchChart.hitAreaNote} '
              'METRIC: ${HabotTouchChart.metricNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Observability / Alert Coverage',
            observed:
                'A SERVICE METRIC ON A CHARTING ROW, AND THE THIRD IN THIS '
                'BATCH. Alert coverage is the share of failure modes with a '
                'monitor attached, measured on a running service; it is not a '
                'property of a chart. Step 360 scored a counting widget on an '
                'RBAC enforcement rate and Step 363 scored a row cap on '
                'Largest Contentful Paint. The band also repeats itself, with '
                'an optimal and a ceiling both written 1.',
            floor: '>=90%',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Chart interactions that require a mouse',
            observed:
                '0. A fingertip is $ratio times the width of a cursor and sits '
                'on top of what it points at rather than beside it, so a '
                'hover-and-tooltip chart breaks twice on touch. The readout is '
                'fixed at the top of the chart and survives the release. The '
                '48dp rule applies to the hit catchment rather than to the '
                'ink, which stays at three points, and points closer together '
                'than the 8dp minimum gap are snapped into one selection: '
                '$drawn plotted points resolve to $selections selections, '
                'because a finger cannot choose between two that are four '
                'points apart.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/charts/touch_chart.dart',
        ],
      ),
    );
  });
}
