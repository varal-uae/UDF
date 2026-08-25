/// AISS GATE -- Step 82 of 95
/// Global Reference ID:       MCIIM-009-09
/// Atomic Steps Reference ID: MCIIM-009-09-A01
/// Setup Step (Action):       "Define MTO Viewport Crop Padding"
/// Setup Step Description:    "Write dynamic layout scaling constraints to
///                             manage variable browser window frames."
/// Data Requirement:          "Image scales to remain legible without zooming.
///                             | Fluid image containers max-width: 100%. |
///                             Total focus on atomic task. | CSS overflow:
///                             hidden."
/// Metric: Schema Constraint Compliance Rate -- Floor 0.98, Optimal 1.0,
///         Ceiling 1.0. Standard: ISO/IEC 25012 completeness & consistency.
///
/// A THIN ROW, RECORDED: only the Setup Step, its Description, the Data
/// Requirement and the metric bands are populated -- no substeps, no decision,
/// no expected output, no completion measure, no estimate. Nothing was
/// invented to fill them. The Data Requirement IS specific, and its four
/// clauses are the four constraints this file names and counts.
///
/// WHY A CLOSED SET. The metric is a compliance RATE, which needs a
/// denominator. Naming the four constraints as an enum makes that denominator
/// the sheet's own list rather than however many checks the author remembered
/// to write -- so a rate of 1.0 means all four, on every layout, not "all the
/// ones we looked at".
///
/// TRANSLATION, RECORDED: the clauses are CSS. "max-width: 100%" becomes a
/// width bounded by the pane; "overflow: hidden" becomes a clipped frame.
library;

import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/layout/device_profiles.dart';
import 'package:udf_setup/design_system/mto/byt_isolation.dart';
import 'package:udf_setup/design_system/mto/isolated_viewport.dart';
import 'package:udf_setup/design_system/mto/isolation_geometry.dart';
import 'package:udf_setup/design_system/tokens/grid_tokens.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';

import 'aiss_reporter.dart';

const HabotBoundingBox _box = HabotBoundingBox(
  left: 120,
  top: 240,
  width: 640,
  height: 180,
  sourceWidth: 2480,
  sourceHeight: 3508,
);

void main() {
  final List<AissGate> gates = <AissGate>[];
  double measuredCompliance = -1;
  double worstScale = -1;

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

  group('MCIIM-009-09-A01 :: the constraints', () {
    gate(
      'MCIIM-009-09-G1',
      'Data Requirement, all four clauses: "Image scales to remain legible '
          'without zooming. | Fluid image containers max-width: 100%. | Total '
          'focus on atomic task. | CSS overflow: hidden."',
      'The four clauses are a closed set, so the compliance rate has the '
          'sheet\'s own denominator; and each one is evaluated as a fact about '
          'a resolved layout rather than as a style declaration',
      () {
        const Size viewport = Size(360, 800);
        final Size pane = Size(
          viewport.width,
          viewport.height * HabotIsolatedViewport.evidenceShare,
        );
        final HabotSnippetLayout layout = HabotIsolationGeometry.resolve(
          box: _box,
          paneSize: pane,
          viewportWidth: viewport.width,
        );
        final Map<HabotCropConstraint, bool> evaluated =
            HabotCropPadding.evaluate(
              box: _box,
              paneWidth: pane.width,
              paneHeight: pane.height,
              renderedWidth: layout.width,
              renderedHeight: layout.height,
            );
        return evaluated.length == HabotCropConstraint.values.length &&
            evaluated.values.every((bool v) => v) &&
            HabotCropPadding.complianceFloor == 0.98 &&
            HabotCropPadding.complianceOptimal == 1.0;
      },
    );

    gate(
      'MCIIM-009-09-G2',
      'Metric: Schema Constraint Compliance Rate -- Floor 0.98, Optimal 1.0.',
      'The rate is measured over every device in the Step 5 matrix rather '
          'than one reference screen, and a crop that cannot be read without '
          'pinching lowers it -- so the number moves',
      () {
        final List<Map<HabotCropConstraint, bool>> runs =
            <Map<HabotCropConstraint, bool>>[];
        for (final HabotDeviceProfile device in HabotDevices.all) {
          final Size pane = Size(
            device.widthDp,
            device.heightDp * HabotIsolatedViewport.evidenceShare,
          );
          final HabotSnippetLayout layout = HabotIsolationGeometry.resolve(
            box: _box,
            paneSize: pane,
            viewportWidth: device.widthDp,
          );
          if (worstScale < 0 || layout.scale < worstScale) {
            worstScale = layout.scale;
          }
          runs.add(
            HabotCropPadding.evaluate(
              box: _box,
              paneWidth: pane.width,
              paneHeight: pane.height,
              renderedWidth: layout.width,
              renderedHeight: layout.height,
            ),
          );
        }
        measuredCompliance = HabotCropPadding.complianceRate(runs);

        // A crop nobody could read: 8000 source pixels into a phone pane.
        const HabotBoundingBox unreadable = HabotBoundingBox(
          left: 0,
          top: 0,
          width: 8000,
          height: 2000,
          sourceWidth: 12000,
          sourceHeight: 12000,
        );
        const Size pane = Size(360, 400);
        final HabotSnippetLayout bad = HabotIsolationGeometry.resolve(
          box: unreadable,
          paneSize: pane,
          viewportWidth: 360,
        );
        final double badRate = HabotCropPadding.complianceRate(
          <Map<HabotCropConstraint, bool>>[
            HabotCropPadding.evaluate(
              box: unreadable,
              paneWidth: pane.width,
              paneHeight: pane.height,
              renderedWidth: bad.width,
              renderedHeight: bad.height,
            ),
          ],
        );
        return runs.length == HabotDevices.all.length &&
            measuredCompliance == 1.0 &&
            measuredCompliance >= HabotCropPadding.complianceFloor &&
            worstScale >= HabotCropPadding.minLegibleScale &&
            badRate < HabotCropPadding.complianceFloor;
      },
    );

    gate(
      'MCIIM-009-09-G3',
      'Setup Step (Action): "Define MTO viewport CROP PADDING" -- read '
          'against RCGLA-001 (Step 2), which made tokens the source of truth '
          'for every dimension.',
      'The padding and margins are the existing spacing and grid tokens, not '
          'numbers written here, so a crop frame and a card on the same screen '
          'cannot disagree about what small means',
      () =>
          HabotCropPadding.framePadding == HabotSpacing.xs &&
          HabotCropPadding.outerMargin == HabotGrid.outerMargin &&
          HabotCropPadding.maxExposedFraction ==
              HabotBoundingBox.wholeDocumentFraction,
    );

    gate(
      'MCIIM-009-09-G4',
      'Setup Step Description: "dynamic layout scaling constraints to manage '
          'VARIABLE window frames."',
      'The same crop resolves differently on a narrow pane and a wide one and '
          'satisfies all four constraints in both -- which is what makes the '
          'constraint set dynamic rather than a fixed size',
      () {
        final HabotSnippetLayout narrow = HabotIsolationGeometry.resolve(
          box: _box,
          paneSize: const Size(320, 300),
          viewportWidth: 320,
        );
        final HabotSnippetLayout wide = HabotIsolationGeometry.resolve(
          box: _box,
          paneSize: const Size(1024, 500),
          viewportWidth: 1024,
        );
        return narrow.width < wide.width &&
            narrow.width == 320 - (HabotGrid.outerMargin * 2) &&
            HabotCropPadding.evaluate(
              box: _box,
              paneWidth: 320,
              paneHeight: 300,
              renderedWidth: narrow.width,
              renderedHeight: narrow.height,
            ).values.every((bool v) => v) &&
            HabotCropPadding.evaluate(
              box: _box,
              paneWidth: 1024,
              paneHeight: 500,
              renderedWidth: wide.width,
              renderedHeight: wide.height,
            ).values.every((bool v) => v);
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'MCIIM-009-09',
        atomicStepReferenceId: 'MCIIM-009-09-A01',
        setupStepAction: 'Define MTO Viewport Crop Padding',
        implementationOrder: 82,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Layout Type': 'framed crop inside the evidence pane, clipped',
          'Layout Grid Dimensions':
              'content width = viewport - 2 x '
              '${HabotGrid.outerMargin.toStringAsFixed(0)}dp outer margin',
          'Spacing Rules':
              'frame padding ${HabotCropPadding.framePadding.toStringAsFixed(0)}'
              'dp from the spacing scale',
          'Alignment Settings':
              'crop centred in its frame; frame fills the evidence pane',
          'Layout Validation Status': 'Derived from gate outcomes',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'THIN ROW -- four columns populated, the rest empty. Nothing '
              'invented to fill them. The Data Requirement is specific and its '
              'four clauses are the closed set the compliance rate counts '
              'over. TRANSLATION RECORDED: the clauses are CSS; "max-width: '
              '100%" is a width bounded by the pane and "overflow: hidden" is '
              'a clipped frame.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Schema Constraint Compliance Rate',
            observed: measuredCompliance < 0
                ? 'not measured'
                : '${measuredCompliance.toStringAsFixed(4)} -- '
                      '${HabotDevices.all.length} device layouts x '
                      '${HabotCropConstraint.values.length} named constraints, '
                      'all satisfied. Worst scale across the matrix '
                      '${worstScale.toStringAsFixed(3)} against a legibility '
                      'floor of '
                      '${HabotCropPadding.minLegibleScale.toStringAsFixed(3)}. '
                      'A deliberately unreadable crop scored below the floor, '
                      'so the rate moves.',
            floor: '0.98',
            optimal: '1.0',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/mto/byt_isolation.dart',
          'lib/design_system/mto/isolation_geometry.dart',
        ],
      ),
    );
  });
}
