/// AISS GATE -- Step 3 of 10
/// Global Reference ID:      TTMCS-004
/// Atomic Steps Reference ID: TTMCS-004-A01
/// Setup Step (Action):      "Configure Atomic Light/Dark Adaptation Tokens"
///
/// Completion Measure from the sheet: "Automated verification confirming a
/// minimum 4.5:1 contrast ratio across all dynamic layout color pairs."
/// Metric: Material Design Density Compliance (dp) -- Floor 4dp, Optimal
/// 6-8dp padding / 32-48dp row height, Ceiling 12dp.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/app.dart';
import 'package:udf_setup/habot_shell_page.dart';
import 'package:udf_setup/design_system/a11y/contrast.dart';
import 'package:udf_setup/design_system/a11y/contrast_audit.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/theme/habot_theme_scope.dart';
import 'package:udf_setup/design_system/theme/theme_controller.dart';
import 'package:udf_setup/design_system/tokens/color_tokens.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';

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

  group('TTMCS-004-A01 :: light/dark adaptation tokens', () {
    // ---- Substep 1 --------------------------------------------------------
    gate(
      'TTMCS-004-G1',
      '4 Substeps #1: "Set up standard Material Design 3 dynamic color tokens '
          'using unified root custom properties."',
      'Both schemes define all 28 MD3 semantic roles, and every token is opaque',
      () {
        final Map<String, Color> light = HabotColors.light.roles;
        final Map<String, Color> dark = HabotColors.dark.roles;
        if (light.length != 28 || dark.length != 28) {
          return false;
        }
        if (light.keys.toSet().difference(dark.keys.toSet()).isNotEmpty) {
          return false;
        }
        for (final Color color in <Color>[...light.values, ...dark.values]) {
          if (!Contrast.isOpaque(color)) {
            return false;
          }
        }
        return true;
      },
    );

    gate(
      'TTMCS-004-G2',
      'Why This Matters: "high ambient sunlight demands high-contrast light '
          'layouts, low-light night conditions require deep dark interfaces."',
      'Light surface is genuinely light and dark surface genuinely dark',
      () {
        final double lightLum = Contrast.relativeLuminance(
          HabotColors.light.surface,
        );
        final double darkLum = Contrast.relativeLuminance(
          HabotColors.dark.surface,
        );
        return lightLum > 0.8 && darkLum < 0.05;
      },
    );

    // ---- Substep 4 (contrast) --------------------------------------------
    gate(
      'TTMCS-004-G3',
      'Completion Measures: "Automated verification confirming a minimum 4.5:1 '
          'contrast ratio across all dynamic layout color pairs."',
      'Zero contrast failures across every audited pair in both schemes',
      () => ContrastAudit.failures().isEmpty,
    );

    gate(
      'TTMCS-004-G4',
      'Mobile-First UI Decision: "Enforce primary text contrast levels checking '
          'out above WCAG AA standard mobile parameters."',
      'Primary body text pairs clear the 7:1 AAA optimum, not just the AA floor',
      () {
        final double lightBody = Contrast.ratio(
          HabotColors.light.onSurface,
          HabotColors.light.surface,
        );
        final double darkBody = Contrast.ratio(
          HabotColors.dark.onSurface,
          HabotColors.dark.surface,
        );
        return lightBody >= WcagThresholds.textOptimal &&
            darkBody >= WcagThresholds.textOptimal;
      },
    );

    // ---- Density metric ---------------------------------------------------
    gate(
      'TTMCS-004-G5',
      'Metric row: "Material Design Density Compliance (dp)" -- Floor 4dp, '
          'Optimal 6-8dp padding / 32-48dp row height, Ceiling 12dp.',
      'Shipped dense values sit inside the optimal band, never past the ceiling',
      () {
        return HabotDensity.denseRowPadding >= HabotDensity.optimalPaddingMin &&
            HabotDensity.denseRowPadding <= HabotDensity.optimalPaddingMax &&
            HabotDensity.denseRowPadding >= HabotDensity.floorPadding &&
            HabotDensity.denseRowPadding <= HabotDensity.ceilingPadding &&
            HabotDensity.denseRowHeight >= HabotDensity.optimalRowHeightMin &&
            HabotDensity.denseRowHeight <= HabotDensity.optimalRowHeightMax;
      },
    );

    // ---- Contrast implementation self-check -------------------------------
    gate(
      'TTMCS-004-G6',
      'Substep #4: "Implement explicit accessibility contrast-checking '
          'workflows mapping directly to WCAG AA mobile layout rules."',
      'Contrast engine reproduces the WCAG reference values',
      () {
        const Color black = Color(0xFF000000);
        const Color white = Color(0xFFFFFFFF);
        final double maxRatio = Contrast.ratio(black, white);
        final double selfRatio = Contrast.ratio(white, white);
        // Order independence.
        final double forward = Contrast.ratio(black, white);
        final double reverse = Contrast.ratio(white, black);
        return (maxRatio - 21.0).abs() < 0.01 &&
            (selfRatio - 1.0).abs() < 0.0001 &&
            (forward - reverse).abs() < 1e-12 &&
            (Contrast.relativeLuminance(white) - 1.0).abs() < 0.0001 &&
            Contrast.relativeLuminance(black).abs() < 0.0001;
      },
    );
  });

  // ---- Substep 2: system preference listener -----------------------------
  group('TTMCS-004-A01 :: substep 2 system preference listener', () {
    test('[TTMCS-004-G7] controller follows the OS in system mode and ignores '
        'it when the user has pinned a mode', () {
      final HabotThemeController controller = HabotThemeController();
      addTearDown(controller.dispose);

      int notifications = 0;
      controller.addListener(() => notifications++);

      controller.setMode(ThemeMode.system);
      // Pin a known starting point so the assertion below does not depend on
      // whatever brightness the host happens to report.
      controller.syncPlatformBrightness(Brightness.light);
      final int afterSetMode = notifications;

      controller.syncPlatformBrightness(Brightness.dark);
      expect(controller.effectiveBrightness, Brightness.dark);
      expect(notifications, greaterThan(afterSetMode));

      controller.syncPlatformBrightness(Brightness.light);
      expect(controller.effectiveBrightness, Brightness.light);

      // Pinned mode: the OS may flip, the painted brightness must not.
      controller.setMode(ThemeMode.light);
      final int beforeOsFlip = notifications;
      controller.syncPlatformBrightness(Brightness.dark);
      expect(controller.effectiveBrightness, Brightness.light);
      expect(
        notifications,
        beforeOsFlip,
        reason: 'A pinned mode must not churn the tree on an OS flip',
      );

      gates.add(
        const AissGate(
          id: 'TTMCS-004-G7',
          requirementSource:
              '4 Substeps #2: "Write an atomic preference hook listening '
              'directly to system dark preferences."',
          description:
              'Controller tracks OS brightness in system mode and suppresses '
              'notifications when a mode is pinned',
          passed: true,
        ),
      );
    });
  });

  // ---- Substep 3: no full reflow on theme switch -------------------------
  group('TTMCS-004-A01 :: substep 3 switch without full reflow', () {
    testWidgets(
      '[TTMCS-004-G8] toggling the theme rebuilds only subscribed widgets',
      (WidgetTester tester) async {
        int subscribedBuilds = 0;
        int unsubscribedBuilds = 0;

        final HabotThemeController controller = HabotThemeController(
          initialMode: ThemeMode.light,
        );
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          HabotThemeScope(
            notifier: controller,
            child: MaterialApp(
              home: Column(
                children: <Widget>[
                  Builder(
                    builder: (BuildContext context) {
                      // Subscribing read.
                      HabotThemeScope.of(context);
                      subscribedBuilds++;
                      return const SizedBox.shrink();
                    },
                  ),
                  Builder(
                    builder: (BuildContext context) {
                      // Reads nothing from the scope.
                      unsubscribedBuilds++;
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        );

        final int subscribedAfterFirst = subscribedBuilds;
        final int unsubscribedAfterFirst = unsubscribedBuilds;

        controller.setMode(ThemeMode.dark);
        await tester.pump();

        expect(
          subscribedBuilds,
          greaterThan(subscribedAfterFirst),
          reason: 'The subscribed widget must react to the theme change',
        );
        expect(
          unsubscribedBuilds,
          unsubscribedAfterFirst,
          reason:
              'A widget that reads nothing from the scope must NOT rebuild -- '
              'this is the "without triggering full component reflows" clause',
        );

        gates.add(
          const AissGate(
            id: 'TTMCS-004-G8',
            requirementSource:
                '4 Substeps #3: "Build a performance-optimized theme container '
                'that switches modes cleanly without triggering full component '
                'reflows."',
            description:
                'Only widgets that depend on HabotThemeScope rebuild on a '
                'theme-mode change',
            passed: true,
          ),
        );
      },
    );

    testWidgets('[TTMCS-004-G9] the app actually repaints in the new scheme', (
      WidgetTester tester,
    ) async {
      final HabotThemeController controller = HabotThemeController(
        initialMode: ThemeMode.light,
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(HabotApp(controller: controller));
      await tester.pumpAndSettle();

      // Steps 36-50 note: the app now opens on the shell rather than on a
      // probe screen, so the context under test is the shell page. The
      // requirement -- a theme switch must not reflow the whole tree -- is
      // unchanged; only the root widget it is measured on has moved.
      BuildContext ctx = tester.element(find.byType(HabotShellPage));
      expect(Theme.of(ctx).brightness, Brightness.light);

      controller.setMode(ThemeMode.dark);
      await tester.pumpAndSettle();

      ctx = tester.element(find.byType(HabotShellPage));
      expect(Theme.of(ctx).brightness, Brightness.dark);
      expect(Theme.of(ctx).colorScheme.surface, HabotColors.dark.surface);

      gates.add(
        const AissGate(
          id: 'TTMCS-004-G9',
          requirementSource:
              'User Interaction / Flow Impact: "Users experience an '
              'instantaneous, cohesive theme shift that requires zero manually '
              'triggered application configurations."',
          description:
              'End-to-end theme switch swaps the live ColorScheme to the dark '
              'brand tokens',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    final List<ContrastResult> all = ContrastAudit.auditAll();
    final double worst = all
        .map((ContrastResult r) => r.ratio)
        .reduce((double a, double b) => a < b ? a : b);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'TTMCS-004',
        atomicStepReferenceId: 'TTMCS-004-A01',
        setupStepAction: 'Configure Atomic Light/Dark Adaptation Tokens',
        implementationOrder: 3,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Color Code (HEX/RGB)': '56 tokens (28 light + 28 dark), all opaque',
          'Color Name': 'Material Design 3 semantic role names',
          'Color Scheme': 'light, dark',
          'Contrast Ratio':
              'worst audited pair ${worst.toStringAsFixed(2)}:1 '
              'across ${all.length} pairs',
          'Color Application Map':
              'lib/design_system/a11y/contrast_audit.dart :: '
              'textPairs + nonTextPairs + dark elevation ladder',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Material Design Density Compliance (dp)',
            observed:
                'dense padding ${HabotDensity.denseRowPadding.toStringAsFixed(0)}dp, '
                'dense row height ${HabotDensity.denseRowHeight.toStringAsFixed(0)}dp',
            floor: '4dp minimum spacing (Material Design accessibility floor)',
            optimal: '6-8dp padding / 32-48dp row height (dense-table optimum)',
            ceiling:
                '12dp (maximum density before readability/touch-target risk)',
          ),
          AissMeasurement(
            metricName: 'WCAG Colour Contrast Ratio (all audited pairs)',
            observed: 'worst ${worst.toStringAsFixed(2)}:1',
            floor: '4.5:1',
            optimal: '7:1',
            ceiling: 'no upper bound; avoid glare beyond 21:1',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/theme/theme_controller.dart',
          'lib/design_system/theme/habot_theme_scope.dart',
          'lib/design_system/a11y/contrast.dart',
          'lib/design_system/a11y/contrast_audit.dart',
        ],
      ),
    );
  });
}
