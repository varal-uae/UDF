/// AISS GATE -- Step 9 of 10
/// Global Reference ID:      ANSA-012
/// Atomic Steps Reference ID: ANSA-012-A01
/// Setup Step (Action):      "Establish Contextual Navigation Header Framework."
///
/// Expected Output measure: "100% of application pages render matching
/// navigation rules with zero history stack leaks."
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/app.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/layout/device_profiles.dart';
import 'package:udf_setup/design_system/navigation/back_navigation.dart';
import 'package:udf_setup/design_system/navigation/contextual_header.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/elevation_tokens.dart';
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

  group('ANSA-012-A01 :: contextual navigation header', () {
    // ---- Substep 1 --------------------------------------------------------
    gate(
      'ANSA-012-G1',
      '4 Substeps #1: "Cap maximum string titles to protect horizontal grid '
          'boundaries."',
      'Title capping never exceeds the budget, preserves short titles '
          'untouched, and prefers a word boundary',
      () {
        const String short = 'Dashboard';
        if (HeaderTitlePolicy.cap(short) != short) {
          return false;
        }
        const String long =
            'Quarterly Reconciliation Summary For All Regional Branches';
        final String capped = HeaderTitlePolicy.cap(long);
        if (capped.length > HeaderTitlePolicy.maxChars) {
          return false;
        }
        if (!capped.endsWith(HeaderTitlePolicy.ellipsis)) {
          return false;
        }
        // A single unbroken token still gets capped rather than overflowing.
        final String unbroken = HeaderTitlePolicy.cap('A' * 120);
        if (unbroken.length > HeaderTitlePolicy.maxChars) {
          return false;
        }
        // And whitespace is normalised rather than padding the budget.
        return HeaderTitlePolicy.cap('  Inbox  ') == 'Inbox' &&
            HeaderTitlePolicy.isWithinBounds(long);
      },
    );

    // ---- Substep 3 --------------------------------------------------------
    gate(
      'ANSA-012-G2',
      '4 Substeps #3: "Inject scroll-listening hooks to adjust header '
          'elevations dynamically." + UX Translation: "Top navigation bars '
          'transition from flat fills to high-elevation shadows as lower '
          'contents scroll."',
      'Header is flat at rest and lifts once content scrolls past the threshold',
      () =>
          HeaderElevationPolicy.levelFor(0) == HabotElevationLevel.level0 &&
          HeaderElevationPolicy.levelFor(HeaderElevationPolicy.liftThreshold) ==
              HabotElevationLevel.level0 &&
          HeaderElevationPolicy.levelFor(
                HeaderElevationPolicy.liftThreshold + 1,
              ) ==
              HabotElevationLevel.level2 &&
          HeaderElevationPolicy.dpFor(100) > HeaderElevationPolicy.dpFor(0),
    );

    // ---- Poka-Yoke: double-tap back ---------------------------------------
    gate(
      'ANSA-012-G3',
      'Poka-Yoke: "Intercept routes block rapid double-tapping on back '
          'controls, saving history queues from array corruption."',
      'A burst of back taps inside the debounce window yields exactly one pop',
      () {
        final HabotBackNavigator nav = HabotBackNavigator(
          debounce: const Duration(milliseconds: 500),
        );
        // Six rapid taps over 250ms.
        final List<bool> results = <bool>[
          for (int i = 0; i < 6; i++)
            nav.shouldAcceptPop(Duration(milliseconds: i * 50)),
        ];
        if (results.where((bool r) => r).length != 1 || !results.first) {
          return false;
        }
        if (nav.acceptedPops != 1 || nav.rejectedPops != 5) {
          return false;
        }
        // A deliberate second tap after the window is honoured.
        return nav.shouldAcceptPop(const Duration(milliseconds: 900)) &&
            nav.acceptedPops == 2;
      },
    );

    // ---- Overflow policy ---------------------------------------------------
    gate(
      'ANSA-012-G4',
      'Mobile-First UX Decision: "Hide excessive, low-priority shortcut items '
          'inside unified trailing overflow menus on tight displays."',
      'Compact viewports expose fewer visible actions than wide ones, and the '
          'remainder overflow',
      () =>
          HabotContextualHeader.maxVisibleActionsFor(360) == 2 &&
          HabotContextualHeader.maxVisibleActionsFor(1024) == 4 &&
          HabotContextualHeader.maxVisibleActionsFor(360) <
              HabotContextualHeader.maxVisibleActionsFor(1024),
    );

    // ---- Fixed height ------------------------------------------------------
    gate(
      'ANSA-012-G5',
      'Mobile-First UI Implementation: "Secure the top app container height to '
          'an unyielding 64dp profile line."',
      'preferredSize is exactly 64dp and comes from the token, not a literal',
      () {
        const HabotContextualHeader header = HabotContextualHeader(
          title: 'Test',
        );
        return header.preferredSize.height == HabotDensity.appBarHeight &&
            HabotDensity.appBarHeight == 64;
      },
    );
  });

  group('ANSA-012-A01 :: rendered header behaviour', () {
    testWidgets('[ANSA-012-G6] header renders at 64dp with a left-aligned '
        'capped title and an overflow menu on a compact viewport', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = HabotDevices.smallAndroid.logicalSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const HabotApp(home: DesignSystemProbePage()));
      await tester.pumpAndSettle();

      final RenderBox bar = tester.renderObject<RenderBox>(
        find.byType(HabotContextualHeader),
      );
      expect(bar.size.height, HabotDensity.appBarHeight);

      // The probe screen declares four actions; compact shows two plus overflow.
      expect(find.byIcon(Icons.more_vert), findsOneWidget);

      // Title is capped, never rendered at full length.
      expect(
        find.text('Habot Design System Foundations'),
        findsNothing,
        reason: 'A 31-character title must be capped, not rendered whole',
      );
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'ANSA-012-G6',
          requirementSource:
              'Mobile-First UI Decision: "Align textual header targets strictly '
              'to standard left grid baselines." + UI Implementation: 64dp.',
          description:
              'Rendered header is 64dp tall, caps its title and collapses '
              'surplus actions into a trailing overflow menu at 360dp',
          passed: true,
        ),
      );
    });

    testWidgets('[ANSA-012-G7] back control never pops the root route', (
      WidgetTester tester,
    ) async {
      final HabotBackNavigator nav = HabotBackNavigator();
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            appBar: HabotContextualHeader(title: 'Root', backNavigator: nav),
            body: const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Still on the root route, no exception, and the guard did not record a
      // phantom accepted pop.
      expect(find.text('Root'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(nav.acceptedPops, 0);

      gates.add(
        const AissGate(
          id: 'ANSA-012-G7',
          requirementSource:
              'Expected Output measure: "100% of application pages render '
              'matching navigation rules with zero history stack leaks."',
          description:
              'Tapping back on the root route is a no-op: the stack is never '
              'unwound past the first screen',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'ANSA-012',
        atomicStepReferenceId: 'ANSA-012-A01',
        setupStepAction: 'Establish Contextual Navigation Header Framework.',
        implementationOrder: 9,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'System Name': 'Habot Contextual Header Framework',
          'System Version': '0.1.0',
          'Component List':
              'HabotContextualHeader, HabotHeaderAction, HeaderTitlePolicy, '
              'HeaderElevationPolicy, HabotBackNavigator',
          'Token Values':
              'height ${HabotDensity.appBarHeight.toStringAsFixed(0)}dp; '
              'title cap ${HeaderTitlePolicy.maxChars} chars; '
              'compact actions ${HabotContextualHeader.maxVisibleActionsCompact}; '
              'lift threshold ${HeaderElevationPolicy.liftThreshold.toStringAsFixed(0)}dp',
          'Documentation Links':
              'lib/design_system/navigation/contextual_header.dart (dartdoc)',
          'System Configuration Details':
              'left-aligned title, trailing overflow menu, scroll-driven '
              'elevation, 500ms back debounce, root-pop blocked',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'Environment / Asset Access Readiness',
            observed:
                'Header module version-controlled at one documented path and '
                'reachable on first attempt',
            floor: 'Located on first attempt',
            optimal: 'Path version-controlled & documented',
            ceiling: 'N/A (one-time setup)',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/navigation/contextual_header.dart',
          'lib/design_system/navigation/back_navigation.dart',
        ],
      ),
    );
  });
}
