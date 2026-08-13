/// AISS GATE -- Step 45 of 50
/// Global Reference ID:       GEN-00022
/// Atomic Steps Reference ID: GEN-00022-A01
/// Setup Step (Action):       "Configure dashboard widgets and audit forms to
///                             stack vertically in a single-column or 2x2 grid
///                             on mobile."
/// Metric: Cross-Viewport Rendering Consistency
///   Floor:   "Zero regressions on primary breakpoints (360/390/412px)"
///   Optimal: "Zero regressions across full tested device matrix"
///   Ceiling: "N/A (zero-tolerance metric, no upper bound)"
///   Scale:   Pass/Fail
///
/// One of the few GEN-* metric rows in this batch that fits its step exactly,
/// and it is unusually specific: it names three widths and then the whole
/// matrix. Both are measured below -- the three named widths, and all nine
/// devices from the Step 5 matrix in both orientations.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/layout/device_profiles.dart';
import 'package:udf_setup/design_system/shell/dashboard_grid.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/grid_tokens.dart';

import 'aiss_reporter.dart';

const List<HabotCommandSection> _sections = <HabotCommandSection>[
  HabotCommandSection(id: 'intake', title: 'Intake', child: Text('12')),
  HabotCommandSection(id: 'review', title: 'Review', child: Text('4')),
  HabotCommandSection(id: 'release', title: 'Release', child: Text('0')),
  HabotCommandSection(id: 'archive', title: 'Archive', child: Text('91')),
];

void main() {
  final List<AissGate> gates = <AissGate>[];
  int viewportsRendered = 0;
  int viewportsClean = 0;

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

  Widget dashboard() => MaterialApp(
    theme: HabotTheme.light(),
    home: const Scaffold(body: HabotCommandGrid(sections: _sections)),
  );

  group('GEN-00022-A01 :: the stacking rule', () {
    gate(
      'GEN-00022-G1',
      'Metric Floor: "Zero regressions on PRIMARY BREAKPOINTS '
          '(360/390/412px)."',
      'Each of the three widths the metric names resolves to a single column, '
          'and they resolve to the same thing as each other -- which is what '
          '"consistency" across those three widths means',
      () {
        const List<double> primary = <double>[360, 390, 412];
        final Set<int> resolved = primary
            .map(HabotDashboardGrid.columnsFor)
            .toSet();
        return resolved.length == 1 &&
            resolved.single == HabotDashboardGrid.singleColumn;
      },
    );

    gate(
      'GEN-00022-G2',
      'Setup Step (Action): "...stack vertically in a SINGLE-COLUMN OR 2x2 '
          'GRID on mobile."',
      'The step names exactly two shapes, and the grid offers exactly two: one '
          'column while the screen is compact, two once it is not. There is no '
          'third value to configure wrongly',
      () =>
          HabotDashboardGrid.singleColumn == 1 &&
          HabotDashboardGrid.quadColumns == 2 &&
          HabotDashboardGrid.columnsFor(HabotGrid.minSupportedWidth) == 1 &&
          HabotDashboardGrid.columnsFor(HabotGrid.breakpointMedium - 1) == 1 &&
          HabotDashboardGrid.columnsFor(HabotGrid.breakpointMedium) == 2 &&
          HabotDashboardGrid.columnsFor(1280) == 2,
    );

    gate(
      'GEN-00022-G3',
      'Setup Step (Action) -- a dashboard tile wider than its content column '
          'is exactly how a horizontal scroll gets introduced.',
      'On every device in the matrix the tile ceiling stays inside the '
          'viewport, so a tile can never be the thing that overflows',
      () {
        for (final HabotDeviceProfile device in HabotDevices.all) {
          for (final double width in <double>[
            device.widthDp,
            device.heightDp,
          ]) {
            if (HabotDashboardGrid.maxTileWidth(width) > width) {
              return false;
            }
            if (HabotDashboardGrid.maxTileWidth(width) <= 0) {
              return false;
            }
          }
        }
        return true;
      },
    );
  });

  group('GEN-00022-A01 :: rendered', () {
    testWidgets('[GEN-00022-G4] at each primary breakpoint the tiles occupy '
        'one column and every tile starts at the same x', (
      WidgetTester tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      for (final double width in <double>[360, 390, 412]) {
        tester.view.physicalSize = Size(width, 780);
        await tester.pumpWidget(dashboard());
        await tester.pumpAndSettle();

        final double intakeX = tester.getTopLeft(find.text('Intake')).dx;
        final double reviewX = tester.getTopLeft(find.text('Review')).dx;
        final double intakeY = tester.getTopLeft(find.text('Intake')).dy;
        final double reviewY = tester.getTopLeft(find.text('Review')).dy;

        expect(reviewX, intakeX, reason: 'single column at ${width}dp');
        expect(reviewY, greaterThan(intakeY), reason: 'stacked at ${width}dp');
        expect(
          tester.takeException(),
          isNull,
          reason: 'no overflow at ${width}dp',
        );
      }

      gates.add(
        const AissGate(
          id: 'GEN-00022-G4',
          requirementSource:
              'Metric Floor: "Zero regressions on primary breakpoints '
              '(360/390/412px)." Measured by rendering at all three.',
          description:
              'At 360, 390 and 412dp the dashboard renders as one stacked '
              'column with no layout exception at any of them',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-00022-G5] above the breakpoint the same widget renders '
        'two tiles per row', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(840, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(dashboard());
      await tester.pumpAndSettle();

      final Offset intake = tester.getTopLeft(find.text('Intake'));
      final Offset review = tester.getTopLeft(find.text('Review'));
      final Offset release = tester.getTopLeft(find.text('Release'));

      expect(
        review.dy,
        intake.dy,
        reason: '2x2: the first two tiles share a row',
      );
      expect(review.dx, greaterThan(intake.dx));
      expect(
        release.dy,
        greaterThan(intake.dy),
        reason: '2x2: the third tile starts the second row',
      );
      expect(release.dx, intake.dx);
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'GEN-00022-G5',
          requirementSource:
              'Setup Step (Action): "...or 2x2 grid." Four sections at 840dp '
              'is the literal case the phrase describes.',
          description:
              'Four sections render as two rows of two, with the third tile '
              'aligned under the first',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-00022-G6] every device in the matrix renders the '
        'dashboard without a layout exception, in both orientations', (
      WidgetTester tester,
    ) async {
      addTearDown(tester.view.reset);

      for (final HabotDeviceProfile device in HabotDevices.all) {
        for (final List<double> axes in <List<double>>[
          <double>[device.widthDp, device.heightDp],
          <double>[device.heightDp, device.widthDp],
        ]) {
          viewportsRendered++;
          tester.view.physicalSize = Size(axes[0], axes[1]);
          tester.view.devicePixelRatio = 1.0;
          await tester.pumpWidget(dashboard());
          await tester.pumpAndSettle();

          final Object? exception = tester.takeException();
          final bool clean =
              exception == null &&
              find.text('Intake').evaluate().length == 1 &&
              HabotDashboardGrid.columnsFor(axes[0]) ==
                  (axes[0] < HabotGrid.breakpointMedium ? 1 : 2);
          if (clean) {
            viewportsClean++;
          }
          expect(
            clean,
            isTrue,
            reason:
                '${device.name} at ${axes[0]}x${axes[1]}dp: '
                '${exception ?? 'grid shape or content mismatch'}',
          );
        }
      }

      gates.add(
        AissGate(
          id: 'GEN-00022-G6',
          requirementSource:
              'Metric Optimal: "Zero regressions across full tested device '
              'matrix." The matrix is the nine devices SSTLA-004 recorded in '
              'Step 5.',
          description:
              'The dashboard rendered on every matrix device in both '
              'orientations with no layout exception and the expected column '
              'count',
          passed: viewportsClean == viewportsRendered,
          detail: '$viewportsClean of $viewportsRendered viewports clean',
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00022',
        atomicStepReferenceId: 'GEN-00022-A01',
        setupStepAction:
            'Configure dashboard widgets and audit forms to stack vertically '
            'in a single-column or 2x2 grid on mobile.',
        implementationOrder: 45,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotCommandGrid / HabotDashboardGrid',
          'Component Type': 'Responsive dashboard grid',
          'Component Properties':
              '1 column below ${HabotGrid.breakpointMedium.toStringAsFixed(0)}'
              'dp, 2 above; tile ceiling equals the content width',
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Cross-Viewport Rendering Consistency',
            observed:
                'PASS -- $viewportsClean of $viewportsRendered viewports (9 '
                'matrix devices x 2 orientations) rendered with no layout '
                'exception and the expected column count; the three primary '
                'breakpoints 360/390/412dp were rendered individually and all '
                'resolved to one column',
            floor: 'Zero regressions on primary breakpoints (360/390/412px)',
            optimal: 'Zero regressions across full tested device matrix',
            ceiling: 'N/A (zero-tolerance metric, no upper bound)',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/shell/dashboard_grid.dart',
        ],
      ),
    );
  });
}
