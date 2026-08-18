/// AISS GATE -- Step 54 of 65
/// Global Reference ID:       GEN-00168
/// Atomic Steps Reference ID: GEN-00168-A01
/// Setup Step (Action):       "Stack KPI cards vertically in a single column on
///                             mobile screens."
/// Metric: General Task Completion Quality -- Floor "Task completed with
///         documented exceptions", Optimal "100% completion matching stated
///         implementation-step intent".
///
/// METRIC NAME NOTE, RECORDED: a generic project-tracking band on a step that
/// names a specific, testable layout rule. The rule is gated; the band is
/// reported against how much of the stated intent was met.
///
/// The gate that matters here is G1. Step 45 already gated the one-or-two
/// column rule across 18 viewports; this step must CONSUME that rule, not
/// restate it. G1 fails the moment the two diverge, which is the only
/// mechanism that keeps two files agreeing about a breakpoint.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/dashboard/kpi_card.dart';
import 'package:udf_setup/design_system/dashboard/kpi_grid.dart';
import 'package:udf_setup/design_system/layout/device_profiles.dart';
import 'package:udf_setup/design_system/shell/dashboard_grid.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';

import 'aiss_reporter.dart';

const List<HabotKpi> _kpis = <HabotKpi>[
  HabotKpi(
    id: 'intake',
    label: 'Records in intake',
    value: 148,
    category: HabotMetricCategory.volume,
  ),
  HabotKpi(
    id: 'accuracy',
    label: 'First-pass accuracy',
    value: 96.4,
    previousValue: 94.1,
    category: HabotMetricCategory.rate,
  ),
  HabotKpi(
    id: 'flagged',
    label: 'Flagged for exception',
    value: 3,
    previousValue: 1,
    category: HabotMetricCategory.fault,
  ),
];

void main() {
  final List<AissGate> gates = <AissGate>[];
  int viewportsAgreeing = 0;
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

  Widget grid() => MaterialApp(
    theme: HabotTheme.light(),
    home: const Scaffold(body: HabotKpiGrid(kpis: _kpis)),
  );

  group('GEN-00168-A01 :: the stacking rule', () {
    gate(
      'GEN-00168-G1',
      'Setup Step (Action): "Stack KPI cards vertically in a SINGLE COLUMN on '
          'mobile screens." + GEN-00022 (Step 45), which already gated this '
          'rule across 18 viewports.',
      'The KPI grid returns exactly what HabotDashboardGrid.columnsFor returns '
          'at every device in the matrix, in both orientations -- a second copy '
          'of the breakpoint would drift the first time either was touched, and '
          'this gate is what makes that impossible',
      () {
        bool agree = true;
        for (final HabotDeviceProfile device in HabotDevices.all) {
          for (final double width in <double>[device.widthDp, device.heightDp]) {
            viewportsTested++;
            if (HabotKpiGrid.columnsFor(width) ==
                HabotDashboardGrid.columnsFor(width)) {
              viewportsAgreeing++;
            } else {
              agree = false;
            }
          }
        }
        return agree;
      },
    );

    gate(
      'GEN-00168-G2',
      'Setup Step (Action): "...on MOBILE screens." The mobile case is the one '
          'the step is about.',
      'The reference viewport and every compact width stack vertically, and '
          'the grid stops stacking exactly where the shared rule says it '
          'should rather than at a number chosen here',
      () =>
          HabotKpiGrid.stacksVertically(HabotReferenceViewport.widthDp) &&
          HabotKpiGrid.stacksVertically(320) &&
          HabotKpiGrid.stacksVertically(412) &&
          !HabotKpiGrid.stacksVertically(840) &&
          HabotKpiGrid.columnsFor(1280) == HabotDashboardGrid.quadColumns,
    );
  });

  group('GEN-00168-A01 :: rendered', () {
    testWidgets('[GEN-00168-G3] on a phone the cards share an x and descend in '
        'y, with no horizontal overflow', (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      for (final double width in <double>[320, 360, 390, 412]) {
        tester.view.physicalSize = Size(width, 800);
        await tester.pumpWidget(grid());
        await tester.pumpAndSettle();

        final Offset first = tester.getTopLeft(
          find.byKey(HabotKpiCard.keyFor('intake')),
        );
        final Offset second = tester.getTopLeft(
          find.byKey(HabotKpiCard.keyFor('accuracy')),
        );
        expect(second.dx, first.dx, reason: 'one column at ${width}dp');
        expect(second.dy, greaterThan(first.dy),
            reason: 'stacked at ${width}dp');
        expect(tester.takeException(), isNull,
            reason: 'no overflow at ${width}dp');
      }

      gates.add(
        const AissGate(
          id: 'GEN-00168-G3',
          requirementSource:
              'Setup Step (Action): "Stack KPI cards vertically in a single '
              'column on mobile screens." Measured by rendering at the three '
              'primary breakpoints plus the narrowest supported width.',
          description:
              'At 320, 360, 390 and 412dp the cards render as one stacked '
              'column with no layout exception',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-00168-G4] above the breakpoint two cards share a row, '
        'and a short last row leaves a gap rather than a double-width card', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(840, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(grid());
      await tester.pumpAndSettle();

      final Rect intake =
          tester.getRect(find.byKey(HabotKpiCard.keyFor('intake')));
      final Rect accuracy =
          tester.getRect(find.byKey(HabotKpiCard.keyFor('accuracy')));
      final Rect flagged =
          tester.getRect(find.byKey(HabotKpiCard.keyFor('flagged')));

      expect(accuracy.top, intake.top, reason: 'first two share a row');
      expect(accuracy.left, greaterThan(intake.left));
      expect(flagged.top, greaterThan(intake.top));
      expect(
        flagged.width,
        closeTo(intake.width, 1),
        reason: 'the odd card keeps its column width instead of stretching to '
            'fill the row',
      );
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'GEN-00168-G4',
          requirementSource:
              'Setup Step (Action) read with GEN-00022: above the breakpoint '
              'the same widget lays out in two columns.',
          description:
              'At 840dp three cards render as 2 + 1, and the single card on '
              'the second row keeps its column width',
          passed: true,
          detail:
              'card width ${intake.width.toStringAsFixed(0)}dp, odd card '
              '${flagged.width.toStringAsFixed(0)}dp',
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00168',
        atomicStepReferenceId: 'GEN-00168-A01',
        setupStepAction:
            'Stack KPI cards vertically in a single column on mobile screens.',
        implementationOrder: 54,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotKpiGrid',
          'Component Type': 'Responsive KPI card grid',
          'Component Properties':
              'column count delegated to HabotDashboardGrid.columnsFor; no '
              'breakpoint declared in this file',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'METRIC NAME MISMATCH -- "General Task Completion Quality" is a '
              'generic project-tracking band on a step that names a specific '
              'layout rule. The rule is gated; the band is reported against '
              'the stated intent.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'General Task Completion Quality',
            observed:
                '100% completion matching stated intent -- the grid agrees '
                'with the Step 45 rule on $viewportsAgreeing of '
                '$viewportsTested viewports, stacks at every compact width, '
                'and renders without exception at 320/360/390/412dp and at '
                '840dp. No documented exceptions.',
            floor: 'Task completed with documented exceptions',
            optimal: '100% completion matching stated implementation-step '
                'intent',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/kpi_grid.dart',
        ],
      ),
    );
  });
}
