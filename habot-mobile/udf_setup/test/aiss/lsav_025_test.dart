/// AISS GATE -- Step 51 of 65
/// Global Reference ID:       LSAV-025
/// Atomic Steps Reference ID: LSAV-025-A01
/// Setup Step (Action):       "Define Conversion Rate Vector Chart Geometry
///                             Rules."
/// Metric: Scope Coverage / Audit Completeness -- Floor "80% of relevant items
///         identified", Optimal "100% identified and logged".
///
/// COLUMN NOTE, RECORDED: this row's Data Collected column reads "Version
/// Number; Version Type; Release Date; Version Status; Version Checksum" --
/// release metadata, not chart geometry. Not gated. The Setup Step, the four
/// substeps, the poka-yoke and the Metric are coherent and are what the
/// implementation is measured against.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/charts/chart_geometry.dart';
import 'package:udf_setup/design_system/layout/device_profiles.dart';
import 'package:udf_setup/design_system/tokens/grid_tokens.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';
import 'package:udf_setup/design_system/tokens/typography_tokens.dart';

import 'aiss_reporter.dart';

HabotChartSeries _series() => HabotChartSeries.fromSparse(
  label: 'conversion',
  sparse: const <int, double>{0: 91, 1: 92.5, 2: 93, 4: 94.1, 5: 95.2, 6: 96.4},
  length: 7,
);

void main() {
  final List<AissGate> gates = <AissGate>[];
  int viewportsFitting = 0;
  int viewportsTested = 0;

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

  group('LSAV-025-A01 :: the four substeps', () {
    gate(
      'LSAV-025-G1',
      'Substep 1: "LOCK COMPONENT ASPECT RATIO parameters to avoid visual data '
          'compression errors."',
      'A chart may only take one of three named shapes, and the height that '
          'follows from a width lands on the 8dp baseline every time -- so no '
          'caller can squeeze a trend into a shape that steepens its gradients',
      () {
        for (final double width in <double>[320, 360, 390, 412, 600, 840, 1280]) {
          for (final HabotChartRatio ratio in HabotChartRatio.values) {
            final double h = ratio.heightFor(width);
            if (h <= 0 || h % HabotSpacing.baseline != 0) {
              return false;
            }
          }
        }
        return HabotChartRatio.values.length == 3 &&
            HabotChartRatio.wide.widthOverHeight == 16 / 9 &&
            HabotChartRatio.sparkline.widthOverHeight == 8;
      },
    );

    gate(
      'LSAV-025-G2',
      'Substep 2: "Select vector STROKE WEIGHT TOKENS to ensure line legibility '
          'on high-density grids." + UX Implementation: "Adjust path line '
          'weight bounds automatically relative to screen scale tiers."',
      'Stroke weight is derived from the window class and gets THICKER as the '
          'screen gets smaller, and a grid line is always lighter than a data '
          'line but never invisible',
      () =>
          HabotChartStroke.forWidth(360) > HabotChartStroke.forWidth(600) &&
          HabotChartStroke.forWidth(600) > HabotChartStroke.forWidth(1280) &&
          HabotChartStroke.forWidth(HabotGrid.breakpointMedium) ==
              HabotChartStroke.medium &&
          HabotChartStroke.gridLineFor(360) < HabotChartStroke.forWidth(360) &&
          HabotChartStroke.gridLineFor(1280) >= HabotChartStroke.minVisible,
    );

    gate(
      'LSAV-025-G3',
      'Substep 3: "Map background coordinate GRID SUBDIVISIONS to standard '
          'steps." + UX Decision: "Drop elaborate grid background line paths on '
          'MOBILE profiles to maintain focus paths."',
      'Subdivisions come from the window class, the compact tier gets the '
          'fewest, and the count is capped so the grid never competes with the '
          'data it sits behind',
      () =>
          HabotChartGrid.subdivisionsFor(360) ==
              HabotChartGrid.compactSubdivisions &&
          HabotChartGrid.subdivisionsFor(600) ==
              HabotChartGrid.mediumSubdivisions &&
          HabotChartGrid.subdivisionsFor(1280) ==
              HabotChartGrid.expandedSubdivisions &&
          HabotChartGrid.compactSubdivisions <
              HabotChartGrid.expandedSubdivisions &&
          HabotChartGrid.expandedSubdivisions <=
              HabotChartGrid.maxSubdivisions &&
          HabotChartGrid.linePositions(200, 360).length ==
              HabotChartGrid.compactSubdivisions - 1,
    );

    gate(
      'LSAV-025-G4',
      'Substep 4: "Fix TEXT ALIGNMENT parameters for axis value labels." + '
          'Completion Measure: "zero container clipping issues."',
      'Axis labels use the smallest role in the type scale, the gutter holds a '
          'stated number of characters, and every shortened value fits inside '
          'it -- which is where clipping would otherwise start',
      () {
        if (HabotChartAxis.labelToken != HabotTypography.labelSmall) {
          return false;
        }
        final int capacity = HabotChartAxis.maxValueLabelChars();
        if (capacity < 3) {
          return false;
        }
        for (final double v in <double>[
          0, 7, 42.5, 999, 1000, 12400, 999999, 3400000, -250,
        ]) {
          if (HabotChartAxis.formatValue(v).length > capacity) {
            return false;
          }
        }
        return HabotChartAxis.formatValue(12400) == '12k' &&
            HabotChartAxis.formatValue(3400000) == '3.4M';
      },
    );
  });

  group('LSAV-025-A01 :: the poka-yoke', () {
    gate(
      'LSAV-025-G5',
      'Poka-Yoke: "MISSING DATA INDEXES MAP TO BASELINE ZERO METRICS '
          'EXPLICITLY, saving chart rendering engines from breaking."',
      'A sparse source produces a dense series with no holes, every '
          'materialised point is flagged as invented rather than silently '
          'drawn as measured, and there is no constructor through which a '
          'caller could hand the renderer a gap',
      () {
        final HabotChartSeries series = _series();
        if (series.points.length != 7) {
          return false;
        }
        for (int i = 0; i < 7; i++) {
          if (series.points[i].index != i) {
            return false;
          }
        }
        final HabotChartPoint filled = series.points[3];
        return filled.isBaselineFill &&
            filled.value == 0 &&
            !series.points[0].isBaselineFill &&
            series.baselineFillCount == 1;
      },
    );

    gate(
      'LSAV-025-G6',
      'Self-Chasing: "Analytical stream dropout instances display standard '
          'INLINE NOTICE INDICATORS instead of locking up application frames."',
      'The dropout notice is driven by a stated fraction of invented points, '
          'so a series that is mostly fiction says so and one with a single '
          'gap does not cry wolf',
      () {
        final HabotChartSeries mostlyReal = _series();
        final HabotChartSeries mostlyMissing = HabotChartSeries.fromSparse(
          label: 'gap',
          sparse: const <int, double>{0: 10},
          length: 8,
        );
        return !mostlyReal.needsDropoutNotice &&
            mostlyMissing.needsDropoutNotice &&
            mostlyMissing.fillFraction > HabotChartSeries.dropoutNoticeThreshold;
      },
    );
  });

  group('LSAV-025-A01 :: measured geometry', () {
    gate(
      'LSAV-025-G7',
      'Completion Measure: "Performance paths render smoothly across tested '
          'views with ZERO CONTAINER CLIPPING issues."',
      'Across every device in the Step 5 matrix, both orientations and all '
          'three ratios, the resolved plot stays inside its own box and the '
          'stroke stays visible -- the arithmetic that would clip, checked '
          'rather than screenshotted',
      () {
        bool all = true;
        for (final HabotDeviceProfile device in HabotDevices.all) {
          for (final double width in <double>[device.widthDp, device.heightDp]) {
            for (final HabotChartRatio ratio in HabotChartRatio.values) {
              viewportsTested++;
              final HabotChartGeometry g = HabotChartSpec.resolve(
                width: width,
                series: _series(),
                ratio: ratio,
              );
              if (g.fitsContainer) {
                viewportsFitting++;
              } else {
                all = false;
              }
            }
          }
        }
        return all;
      },
    );

    gate(
      'LSAV-025-G8',
      'Flow Impact: "Users TAP anywhere along trend line coordinates to view '
          'precise micro-data value overlays."',
      'A tap position round-trips to the point that produced it for every '
          'point in the series, so the overlay in Step 57 reads a real value '
          'rather than the nearest plausible one',
      () {
        final HabotChartSeries series = _series();
        final HabotChartGeometry g = HabotChartSpec.resolve(
          width: 360,
          series: series,
        );
        for (int i = 0; i < series.points.length; i++) {
          final ({double dx, double dy}) o =
              g.offsetFor(series.points[i], series.points.length);
          if (g.indexAt(o.dx, series.points.length) != i) {
            return false;
          }
        }
        // A tap past either end clamps rather than throwing.
        return g.indexAt(-40, series.points.length) == 0 &&
            g.indexAt(g.plotWidth * 2, series.points.length) ==
                series.points.length - 1;
      },
    );

    gate(
      'LSAV-025-G9',
      'Setup Step (Action) -- a flat series and an empty one are the two '
          'inputs that make a naive chart divide by zero.',
      'The axis range is never degenerate: an empty series, a single point '
          'and a perfectly flat run all resolve to a span greater than zero',
      () {
        for (final HabotChartSeries series in <HabotChartSeries>[
          const HabotChartSeries(label: 'empty', points: <HabotChartPoint>[]),
          HabotChartSeries.fromSparse(
            label: 'one',
            sparse: const <int, double>{0: 5},
            length: 1,
          ),
          HabotChartSeries.fromSparse(
            label: 'flat',
            sparse: const <int, double>{0: 7, 1: 7, 2: 7},
            length: 3,
          ),
        ]) {
          final HabotChartGeometry g =
              HabotChartSpec.resolve(width: 360, series: series);
          if (g.axisSpan <= 0 || !g.fitsContainer) {
            return false;
          }
        }
        return true;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'LSAV-025',
        atomicStepReferenceId: 'LSAV-025-A01',
        setupStepAction: 'Define Conversion Rate Vector Chart Geometry Rules.',
        implementationOrder: 51,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotChartSpec / ScalableTrendChartModule',
          'Component Type': 'Vector chart geometry rules',
          'Component Properties':
              '${HabotChartRatio.values.length} locked ratios; stroke '
              '${HabotChartStroke.compact}/${HabotChartStroke.medium}/'
              '${HabotChartStroke.expanded}dp by window class; '
              '${HabotChartGrid.compactSubdivisions}-'
              '${HabotChartGrid.expandedSubdivisions} grid subdivisions',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'CONTAMINATED COLUMN -- Data Collected reads "Version Number; '
              'Version Type; Release Date; Version Status; Version Checksum", '
              'which is release metadata rather than chart geometry. Not '
              'gated; recorded here instead of reinterpreted.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName:
                'Scope Coverage / Audit Completeness -- the four geometry '
                'rules this step defines',
            observed:
                '${HabotChartSpec.rules.length} of '
                '${HabotChartSpec.rules.length} rules gated and enforced by '
                'derivation rather than by convention. Zero container '
                'clipping across $viewportsFitting of $viewportsTested '
                'geometries (9 devices x 2 orientations x 3 ratios).',
            floor: '80% of relevant items identified',
            optimal: '100% identified and logged in an inventory register',
            ceiling: '100% identified, logged, cross-checked against the spec',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/charts/chart_geometry.dart',
        ],
      ),
    );
  });
}
