/// AISS GATE -- Step 84 of 95
/// Global Reference ID:       GEN-00280
/// Atomic Steps Reference ID: GEN-00280-A01
/// Setup Step (Action):       "Scale the cropped image snippet to span 100% of
///                             the 4-column mobile grid width."
/// Metric: Cross-Viewport Rendering Consistency --
///         Floor "Zero regressions on primary breakpoints (360/390/412px)",
///         Optimal "Zero regressions across full tested device matrix",
///         Ceiling "N/A (zero-tolerance metric, no upper bound)".
///
/// ONE OF THE FEW METRICS IN THIS BATCH THAT FITS ITS STEP AND IS MEASURABLE.
/// The gate sweeps the crop across all nine devices in the Step 5 matrix, both
/// orientations, and reports the regression count it found rather than
/// asserting that there are none.
///
/// A TRADE, RECORDED. On a phone held sideways the evidence pane is under
/// 200dp tall, and a full-width snippet at this crop's aspect ratio does not
/// fit in it. The implementation reduces the width to what the pane's height
/// allows rather than clipping, because a clipped snippet hides part of the
/// evidence from a worker who has no way to know it is missing -- which is
/// precisely what MCIIM-021's completion measure forbids. So the sweep reports
/// two numbers: regressions (zero) and how many viewports rendered at full
/// content width (the portrait ones). Both are in the evidence.
library;

import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/layout/device_profiles.dart';
import 'package:udf_setup/design_system/mto/byt_isolation.dart';
import 'package:udf_setup/design_system/mto/isolation_geometry.dart';
import 'package:udf_setup/design_system/tokens/grid_tokens.dart';

import 'aiss_reporter.dart';

const HabotBoundingBox _box = HabotBoundingBox(
  left: 120,
  top: 240,
  width: 640,
  height: 180,
  sourceWidth: 2480,
  sourceHeight: 3508,
);

List<Size> _matrixBothOrientations() {
  final List<Size> sizes = <Size>[];
  for (final HabotDeviceProfile device in HabotDevices.all) {
    sizes.add(Size(device.widthDp, device.heightDp));
    sizes.add(Size(device.heightDp, device.widthDp));
  }
  return sizes;
}

void main() {
  final List<AissGate> gates = <AissGate>[];
  HabotViewportSweep? sweep;

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

  group('GEN-00280-A01 :: the scaling', () {
    gate(
      'GEN-00280-G1',
      'Setup Step (Action): "span 100% of the 4-COLUMN MOBILE GRID WIDTH." '
          'Metric Floor: "zero regressions on PRIMARY BREAKPOINTS '
          '(360/390/412px)."',
      'At each of the three primary breakpoints the snippet spans the full '
          'content width -- the viewport minus the grid\'s own margins -- on a '
          'four-column grid, with nothing clipped',
      () {
        bool ok = true;
        for (final double width in HabotIsolationGeometry.primaryBreakpoints) {
          final HabotSnippetLayout layout = HabotIsolationGeometry.resolve(
            box: _box,
            paneSize: Size(width, 400),
            viewportWidth: width,
          );
          ok =
              ok &&
              layout.fillsContentWidth &&
              !layout.clipped &&
              layout.columns == HabotGrid.compactColumns &&
              (layout.width - (width - HabotGrid.outerMargin * 2)).abs() < 0.5;
        }
        return ok && HabotIsolationGeometry.primaryBreakpoints.length == 3;
      },
    );

    gate(
      'GEN-00280-G2',
      'Metric Optimal: "zero regressions across FULL TESTED DEVICE MATRIX." '
          'Ceiling: "N/A (zero-tolerance metric, no upper bound)."',
      'The crop is swept across all nine matrix devices in both orientations '
          'and the regression count is reported: nothing clipped, nothing '
          'below the legibility floor, nothing wider than its pane',
      () {
        sweep = HabotIsolationGeometry.sweep(
          box: _box,
          viewports: _matrixBothOrientations(),
        );
        return sweep!.checked == HabotDevices.all.length * 2 &&
            sweep!.isConsistent &&
            sweep!.regressionCount == 0 &&
            sweep!.passRate == 1.0 &&
            // The portrait viewports render at full content width; the
            // landscape ones are bound by pane height, which is recorded.
            sweep!.fullWidthCount >= HabotDevices.all.length;
      },
    );

    gate(
      'GEN-00280-G3',
      'A zero-tolerance metric that cannot report a non-zero value is not a '
          'measure. Read against RCGLA-012 (Step 6), where the same '
          'discipline was applied to viewport regressions.',
      'A crop the pane genuinely cannot show at a readable size produces '
          'recorded regressions with device widths in them, so a zero on the '
          'real crop means something',
      () {
        const HabotBoundingBox unreadable = HabotBoundingBox(
          left: 0,
          top: 0,
          width: 9000,
          height: 1200,
          sourceWidth: 12000,
          sourceHeight: 12000,
        );
        final HabotViewportSweep bad = HabotIsolationGeometry.sweep(
          box: unreadable,
          viewports: _matrixBothOrientations(),
        );
        return !bad.isConsistent &&
            bad.regressionCount > 0 &&
            bad.passRate < 1.0 &&
            bad.regressions.first.contains('scale');
      },
    );
  });

  tearDownAll(() {
    final HabotViewportSweep? result = sweep;
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00280',
        atomicStepReferenceId: 'GEN-00280-A01',
        setupStepAction:
            'Scale the cropped image snippet to span 100% of the 4-column '
            'mobile grid width.',
        implementationOrder: 84,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Scale the cropped image snippet to span 100% of the 4-column grid':
              'content width = viewport - 2 x '
              '${HabotGrid.outerMargin.toStringAsFixed(0)}dp, on '
              '${HabotGrid.compactColumns} columns below '
              '${HabotGrid.breakpointMedium.toStringAsFixed(0)}dp',
          'Viewports checked': result == null
              ? 'not measured'
              : '${result.checked} (9 devices x 2 orientations)',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'GENERATED ROW -- Setup Step and Description are identical; Why '
              'This Matters, Expected Output and the four substeps are '
              'template prose; Completion Measures is CI/CD tracking. Not '
              'gated. THE METRIC ITSELF FITS AND IS USED LITERALLY. TRADE '
              'RECORDED: in landscape the evidence pane is too short for a '
              'full-width snippet, so the width is bound by the pane height '
              'instead of clipping -- clipping would hide evidence, which '
              'MCIIM-021 forbids. The sweep reports both numbers.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Cross-Viewport Rendering Consistency',
            observed: result == null
                ? 'not measured'
                : '${result.regressionCount} regressions across '
                      '${result.checked} viewports (9 devices x 2 '
                      'orientations); ${result.fullWidthCount} of them '
                      'rendered at the full 4-column content width, the rest '
                      'were bound by pane height in landscape. Pass rate '
                      '${result.passRate.toStringAsFixed(4)}.',
            floor: 'Zero regressions on primary breakpoints (360/390/412px)',
            optimal: 'Zero regressions across full tested device matrix',
            ceiling: 'N/A (zero-tolerance metric, no upper bound)',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/mto/isolation_geometry.dart',
        ],
      ),
    );
  });
}
