/// AISS GATE -- Step 83 of 95
/// Global Reference ID:       GEN-00213
/// Atomic Steps Reference ID: GEN-00213-A01
/// Setup Step (Action):       "Programmatically translate bounding coordinates
///                             into fluid CSS grid containers."
/// Metric: Service Availability / Failover Recovery Time --
///         Floor "<= 30 seconds automatic rollback (RTO)",
///         Optimal "<= 1 second failover with zero session disruption",
///         Ceiling "30 seconds (maximum tolerable outage before rollback)".
///
/// METRIC MISMATCH, RECORDED. Coordinate arithmetic has no recovery time
/// objective. This is an SRE reliability measure sitting on a geometry step,
/// and it is reported as NOT PRODUCED with no substitute number invented --
/// the same treatment Steps 44, 46, 57, 72, 77, 79 and 92 received.
///
/// A GENERATED ROW, RECORDED: Setup Step and Setup Step Description are the
/// same sentence; Why This Matters is that sentence plus "is a critical
/// implementation step"; Expected Output is "Fully configured and validated
/// implementation of:" plus the sentence again; the substeps are the generic
/// four; and Completion Measures is "100% CI/CD pass rate ... committed to
/// runbook", which is project tracking. None of that is gated.
///
/// WHAT IS GATED is what the sentence itself names, and it is a real property:
/// the same box must produce the same container, every time, on every screen
/// width -- and the container must come from the grid the app already has
/// rather than from a second set of column rules.
library;

import 'dart:ui' show Rect, Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
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

void main() {
  final List<AissGate> gates = <AissGate>[];
  String widthTable = '';

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

  group('GEN-00213-A01 :: the translation', () {
    gate(
      'GEN-00213-G1',
      'Setup Step (Action): "PROGRAMMATICALLY translate bounding coordinates '
          'into fluid grid containers."',
      'The translation is pure: the same box, pane and viewport resolve to '
          'byte-identical geometry twice, so a container cannot depend on when '
          'it was asked for',
      () {
        const Size pane = Size(360, 400);
        final HabotSnippetLayout first = HabotIsolationGeometry.resolve(
          box: _box,
          paneSize: pane,
          viewportWidth: 360,
        );
        final HabotSnippetLayout second = HabotIsolationGeometry.resolve(
          box: _box,
          paneSize: pane,
          viewportWidth: 360,
        );
        return first.container == second.container &&
            first.scale == second.scale &&
            first.columns == second.columns &&
            first.container.left == HabotGrid.outerMargin;
      },
    );

    gate(
      'GEN-00213-G2',
      'Setup Step (Action): "fluid GRID containers" -- read against RCGLA-032 '
          '(Step 7), which already owns the column count, the outer margin '
          'and the breakpoints.',
      'Container width and column count are derived from the existing grid '
          'tokens at six widths from 320dp to 840dp, so this step consumes the '
          'grid rather than declaring a second one',
      () {
        final List<String> rows = <String>[];
        bool ok = true;
        for (final double width in <double>[320, 360, 390, 412, 600, 840]) {
          final HabotSnippetLayout layout = HabotIsolationGeometry.resolve(
            box: _box,
            paneSize: Size(width, 400),
            viewportWidth: width,
          );
          final double expected = width - (HabotGrid.outerMargin * 2);
          final int expectedColumns = width >= HabotGrid.breakpointExpanded
              ? HabotGrid.expandedColumns
              : width >= HabotGrid.breakpointMedium
              ? HabotGrid.mediumColumns
              : HabotGrid.compactColumns;
          rows.add(
            '${width.toStringAsFixed(0)}dp:'
            '${layout.width.toStringAsFixed(0)}dp/'
            '${layout.columns}col',
          );
          ok =
              ok &&
              (layout.width - expected).abs() < 0.5 &&
              layout.columns == expectedColumns;
        }
        widthTable = rows.join('  ');
        return ok &&
            HabotIsolationGeometry.contentWidthFor(360) == 328 &&
            HabotIsolationGeometry.columnsFor(360) == HabotGrid.compactColumns;
      },
    );

    gate(
      'GEN-00213-G3',
      'Setup Step (Action): a container is a rectangle IN A PANE. The '
          'translation must not produce one that does not fit -- MCIIM-021\'s '
          'completion measure fails if part of the evidence is off-screen.',
      'A container never exceeds the pane it was given in either dimension, '
          'and an impossible box (zero height) resolves to an explicitly '
          'clipped, zero-scale layout rather than a NaN',
      () {
        const Size pane = Size(360, 200);
        final HabotSnippetLayout layout = HabotIsolationGeometry.resolve(
          box: _box,
          paneSize: pane,
          viewportWidth: 360,
        );
        const HabotBoundingBox degenerate = HabotBoundingBox(
          left: 0,
          top: 0,
          width: 100,
          height: 0,
          sourceWidth: 500,
          sourceHeight: 500,
        );
        final HabotSnippetLayout bad = HabotIsolationGeometry.resolve(
          box: degenerate,
          paneSize: pane,
          viewportWidth: 360,
        );
        return layout.width <= pane.width &&
            layout.height <= pane.height + 0.5 &&
            !layout.clipped &&
            bad.scale == 0 &&
            bad.clipped &&
            !bad.height.isNaN &&
            bad.container != Rect.zero;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00213',
        atomicStepReferenceId: 'GEN-00213-A01',
        setupStepAction:
            'Programmatically translate bounding coordinates into fluid CSS '
            'grid containers.',
        implementationOrder: 83,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Programmatically translate bounding coordinates into fluid grid '
                  'containers':
              'HabotIsolationGeometry.resolve -- pure, grid-sourced, and '
              'bounded by the pane it is given.',
          'Resolved widths': widthTable.isEmpty ? 'not measured' : widthTable,
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'METRIC MISMATCH -- "Service Availability / Failover Recovery '
              'Time" is an SRE measure on a coordinate-translation step. '
              'Recorded as NOT PRODUCED, no substitute number invented. '
              'GENERATED ROW -- Setup Step and Description are the same '
              'sentence; Why This Matters, Expected Output and the four '
              'substeps are template prose; Completion Measures is CI/CD '
              'tracking. None gated. TRANSLATION RECORDED: "CSS grid '
              'containers" is expressed as rects resolved against HabotGrid.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Service Availability / Failover Recovery Time',
            observed:
                'NOT PRODUCED -- a recovery time objective belongs to a '
                'service, not to the arithmetic that turns four coordinates '
                'into a rectangle. What was measured instead: determinism, '
                'grid-sourced widths at six viewport widths, and containment '
                'inside the pane.',
            floor: '<= 30 seconds automatic rollback (RTO)',
            optimal: '<= 1 second failover with zero session disruption',
            ceiling: '30 seconds (maximum tolerable outage before rollback)',
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
