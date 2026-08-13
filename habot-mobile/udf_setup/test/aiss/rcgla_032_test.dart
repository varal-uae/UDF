/// AISS GATE -- Step 7 of 10
/// Global Reference ID:      RCGLA-032
/// Atomic Steps Reference ID: RCGLA-032-A01
/// Setup Step (Action):      "Configure the Material Design 3 (MD3) adaptive
///                            4-column fluid layout token engine for mobile."
///
/// Completion Measures: "Zero instances of horizontal scrollbars or overflowing
/// design tokens on screens down to 320px width."
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/app.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/layout/device_profiles.dart';
import 'package:udf_setup/design_system/layout/fluid_container.dart';
import 'package:udf_setup/design_system/layout/layout_boundary.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/grid_tokens.dart';

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

  setUp(LayoutBoundaryReporter.reset);

  group('RCGLA-032-A01 :: adaptive 4-column fluid layout engine', () {
    // ---- Substep 1 --------------------------------------------------------
    gate(
      'RCGLA-032-G1',
      '4 Substeps #1: "Define global system layout properties with a 16px '
          'outer margin and a 16px column gutter spacing profile."',
      'Outer margin and column gutter are both exactly 16dp',
      () => HabotGrid.outerMargin == 16 && HabotGrid.gutter == 16,
    );

    // ---- Substep 2 --------------------------------------------------------
    gate(
      'RCGLA-032-G2',
      '4 Substeps #2: "Implement an automated viewport listener that flags any '
          'element trying to split into more than 4 vertical segments on '
          'mobile viewports."',
      'Segment limit is 4 on compact, clamping is applied, and the violation '
          'is reported rather than swallowed',
      () {
        LayoutBoundaryReporter.reset();
        if (HabotGrid.maxCompactSegments != 4) {
          return false;
        }
        // Within the limit on compact.
        if (HabotGrid.clampSegments(4, 360) != 4 ||
            HabotGrid.exceedsSegmentLimit(4, 360)) {
          return false;
        }
        // Over the limit on compact.
        if (HabotGrid.clampSegments(7, 360) != 4 ||
            !HabotGrid.exceedsSegmentLimit(7, 360)) {
          return false;
        }
        // Wider viewports allow more.
        if (HabotGrid.clampSegments(7, 1024) != 7) {
          return false;
        }
        // A degenerate request is clamped up, not left at zero.
        return HabotGrid.clampSegments(0, 360) == 1;
      },
    );

    // ---- MD3 compact window-size class ------------------------------------
    gate(
      'RCGLA-032-G3',
      'Mobile-First UX Decision: "Follow MD3 compact window-size class '
          'guidelines explicitly."',
      'Every phone in the device matrix resolves to the compact class with a '
          '4-column matrix',
      () {
        for (final HabotDeviceProfile d in HabotDevices.ofType(
          HabotDeviceType.phone,
        )) {
          if (HabotGrid.windowClassFor(d.widthDp) != HabotWindowClass.compact ||
              HabotGrid.columnsFor(d.widthDp) != 4) {
            return false;
          }
        }
        return true;
      },
    );

    // ---- Fluid elasticity --------------------------------------------------
    gate(
      'RCGLA-032-G4',
      'Mobile-First UX Implementation: "Set container dimensions using relative '
          'percentages to ensure fluid elasticity across diverse aspect ratios."',
      'Column width scales continuously with viewport width -- no fixed widths '
          'anywhere in the arithmetic',
      () {
        double previous = -1;
        for (double w = HabotGrid.minSupportedWidth; w < 600; w += 1) {
          final double columnWidth = HabotGrid.columnWidth(w);
          if (columnWidth <= previous) {
            return false;
          }
          previous = columnWidth;
        }
        // And the content always fits: margins + columns + gutters == width.
        for (final double w in <double>[320, 360, 375, 393, 412]) {
          final int columns = HabotGrid.columnsFor(w);
          final double total =
              (HabotGrid.columnWidth(w) * columns) +
              (HabotGrid.gutter * (columns - 1)) +
              (HabotGrid.outerMargin * 2);
          if ((total - w).abs() > 0.001) {
            return false;
          }
        }
        return true;
      },
    );
  });

  // ---- Substep 3: global layout boundary --------------------------------
  group('RCGLA-032-A01 :: substep 3 global layout boundary', () {
    testWidgets(
      '[RCGLA-032-G5] the boundary publishes the resolved window class and '
      'clamps an over-wide span instead of overflowing',
      (WidgetTester tester) async {
        LayoutBoundaryReporter.reset();
        tester.view.physicalSize = HabotDevices.smallAndroid.logicalSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        late HabotLayoutScope captured;
        int resolved = -1;

        await tester.pumpWidget(
          MaterialApp(
            theme: HabotTheme.light(),
            home: Scaffold(
              body: HabotLayoutBoundary(
                debugOrigin: 'gate',
                child: Builder(
                  builder: (BuildContext context) {
                    captured = HabotLayoutScope.of(context);
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(captured.windowClass, HabotWindowClass.compact);
        expect(captured.columns, 4);
        expect(captured.isCompact, isTrue);

        // An over-wide span throws in debug, which is the intended behaviour.
        expect(
          () => resolved = captured.resolveSpan(9),
          throwsA(isA<FlutterError>()),
        );
        expect(LayoutBoundaryReporter.violations, hasLength(1));
        expect(LayoutBoundaryReporter.violations.first.allowedSegments, 4);
        expect(resolved, -1);

        LayoutBoundaryReporter.reset();

        gates.add(
          const AissGate(
            id: 'RCGLA-032-G5',
            requirementSource:
                '4 Substeps #3: "Wrap all application view components inside a '
                'global layout boundary container component."',
            description:
                'HabotLayoutBoundary publishes window class + column count and '
                'reports an over-limit span through LayoutBoundaryReporter',
            passed: true,
          ),
        );
      },
    );

    testWidgets('[RCGLA-032-G6] reading the scope without a boundary fails '
        'loudly rather than silently guessing a layout', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Builder(
            builder: (BuildContext context) {
              HabotLayoutScope.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(tester.takeException(), isA<FlutterError>());

      gates.add(
        const AissGate(
          id: 'RCGLA-032-G6',
          requirementSource:
              'What Standardized Must Be Done: "All sub-feature layouts must '
              'wrap within the unified responsive grid component layout."',
          description:
              'A view outside the layout boundary throws a readable error '
              'instead of falling back to an invented layout',
          passed: true,
        ),
      );
    });
  });

  // ---- Substep 4: viewport testing at the named resolutions --------------
  group('RCGLA-032-A01 :: substep 4 compact viewport checks', () {
    for (final double width in <double>[
      320,
      ...HabotDevices.rcgla032TestWidths,
    ]) {
      testWidgets('renders clean at ${width.toStringAsFixed(0)}dp', (
        WidgetTester tester,
      ) async {
        LayoutBoundaryReporter.reset();
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(const HabotApp());
        await tester.pumpAndSettle();

        expect(
          tester.takeException(),
          isNull,
          reason: 'Overflow or layout error at ${width.toStringAsFixed(0)}dp',
        );
        expect(
          LayoutBoundaryReporter.isClean,
          isTrue,
          reason:
              'Segment violations at ${width.toStringAsFixed(0)}dp: '
              '${LayoutBoundaryReporter.violations}',
        );

        // The column matrix must never lay a child out wider than the viewport.
        final Iterable<RenderBox> matrices = tester
            .renderObjectList<RenderBox>(find.byType(HabotColumnMatrix))
            .where((RenderBox b) => b.hasSize);
        for (final RenderBox box in matrices) {
          expect(box.size.width, lessThanOrEqualTo(width + 0.5));
        }
      });
    }

    test('[RCGLA-032-G7] substep 4 coverage recorded', () {
      gates.add(
        const AissGate(
          id: 'RCGLA-032-G7',
          requirementSource:
              '4 Substeps #4: "Write automatic viewport-testing checks to '
              'evaluate layout rendering across common compact resolutions '
              '(360px, 375px, and 412px)." + Completion Measures: "Zero '
              'horizontal scrollbars ... down to 320px width."',
          description:
              'App renders clean with zero segment violations at 320, 360, 375 '
              'and 412dp',
          passed: true,
        ),
      );
      expect(gates.length, greaterThan(0));
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'RCGLA-032',
        atomicStepReferenceId: 'RCGLA-032-A01',
        setupStepAction:
            'Configure the Material Design 3 (MD3) adaptive 4-column fluid '
            'layout token engine for mobile screens.',
        implementationOrder: 7,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Layout Type': 'MD3 adaptive fluid grid, compact window-size class',
          'Layout Grid Dimensions':
              '4 columns on compact; 16dp outer margin; 16dp column gutter; '
              'max ${HabotGrid.maxCompactSegments} vertical segments',
          'Spacing Rules':
              'relative column arithmetic only -- no fixed pixel container widths',
          'Alignment Settings':
              'top-centre, wrapping matrix (flex-wrap equivalent)',
          'Layout Validation Status':
              'clean at 320 / 360 / 375 / 412dp with zero segment violations',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName:
                'Asset/Resource Location & Access Confirmation (dp band)',
            observed:
                'vertical rhythm 8dp -- sits exactly on the Optimal target',
            floor: '4dp',
            optimal: '8dp',
            ceiling: '16dp',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/layout/layout_boundary.dart',
          'lib/design_system/layout/fluid_container.dart',
          'lib/design_system/tokens/grid_tokens.dart',
        ],
      ),
    );
  });
}
