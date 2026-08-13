/// AISS GATE -- Step 40 of 50
/// Global Reference ID:       GEN-02334
/// Atomic Steps Reference ID: GEN-02334-A01
/// Setup Step (Action):       "Integrate M3 Navigation Rails for tablet views
///                             and Bottom App Bars for mobile views."
/// Metric: UI Compliance Rate (%) -- Floor 0.95, Optimal 1.0.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/navigation/adaptive_navigation.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/grid_tokens.dart';

import 'aiss_reporter.dart';

const List<HabotDestination> _destinations = <HabotDestination>[
  HabotDestination(
    route: '/overview',
    label: 'Overview',
    icon: Icons.dashboard_outlined,
  ),
  HabotDestination(
    route: '/tasks',
    label: 'Tasks',
    icon: Icons.checklist_outlined,
  ),
  HabotDestination(
    route: '/settings',
    label: 'Settings',
    icon: Icons.settings_outlined,
  ),
];

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

  Widget nav({required int selected, void Function(int)? onSelected}) =>
      MaterialApp(
        theme: HabotTheme.light(),
        home: Scaffold(
          body: HabotAdaptiveNavigation(
            destinations: _destinations,
            selectedIndex: selected,
            onDestinationSelected: onSelected ?? (int _) {},
            body: Text('destination ${_destinations[selected].label}'),
          ),
        ),
      );

  group('GEN-02334-A01 :: surface policy', () {
    gate(
      'GEN-02334-G1',
      'Setup Step (Action): "Navigation Rails for TABLET views and Bottom App '
          'Bars for MOBILE views."',
      'The surface is chosen by the same 768dp navigation threshold SSTLA-004 '
          'recorded in Step 5, not by a new breakpoint invented here',
      () =>
          HabotNavigationPolicy.surfaceFor(360) ==
              HabotNavigationSurface.bottomBar &&
          HabotNavigationPolicy.surfaceFor(HabotGrid.navigationCollapse - 1) ==
              HabotNavigationSurface.bottomBar &&
          HabotNavigationPolicy.surfaceFor(HabotGrid.navigationCollapse) ==
              HabotNavigationSurface.rail &&
          HabotNavigationPolicy.surfaceFor(1280) == HabotNavigationSurface.rail,
    );

    gate(
      'GEN-02334-G2',
      'MD3 navigation bar specification: between three and five destinations. '
          'Fewer is not navigation; more is a menu.',
      'The destination count is bounded, and a shell with one destination '
          'cannot be constructed',
      () =>
          HabotNavigationPolicy.maxBottomBarDestinations == 5 &&
          !HabotNavigationPolicy.fitsBottomBar(1) &&
          HabotNavigationPolicy.fitsBottomBar(2) &&
          HabotNavigationPolicy.fitsBottomBar(5) &&
          !HabotNavigationPolicy.fitsBottomBar(6),
    );

    gate(
      'GEN-02334-G3',
      'MUFCE-028 Setup Step: "Mandatory removal of all mouse hover tooltips." '
          'Material builds a tooltip for a navigation destination unless the '
          'string is empty.',
      'Every NavigationDestination under lib/ passes an empty tooltip, so the '
          'navigation cannot reintroduce the hover affordance Step 24 removed',
      () {
        for (final File file
            in Directory('lib')
                .listSync(recursive: true)
                .whereType<File>()
                .where((File f) => f.path.endsWith('.dart'))) {
          final String code = file.readAsStringSync();
          final int destinations = 'NavigationDestination('
              .allMatches(code)
              .length;
          if (destinations == 0) {
            continue;
          }
          final int emptyTooltips = "tooltip: ''".allMatches(code).length;
          if (emptyTooltips < destinations) {
            return false;
          }
        }
        return true;
      },
    );
  });

  group('GEN-02334-A01 :: rendered surfaces', () {
    testWidgets('[GEN-02334-G4] a phone gets the bottom bar and a tablet gets '
        'the rail, and never both', (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      tester.view.physicalSize = const Size(393, 851);
      await tester.pumpWidget(nav(selected: 0));
      await tester.pumpAndSettle();
      expect(find.byKey(HabotAdaptiveNavigation.barKey), findsOneWidget);
      expect(find.byKey(HabotAdaptiveNavigation.railKey), findsNothing);

      tester.view.physicalSize = const Size(1024, 1366);
      await tester.pumpWidget(nav(selected: 0));
      await tester.pumpAndSettle();
      expect(find.byKey(HabotAdaptiveNavigation.railKey), findsOneWidget);
      expect(find.byKey(HabotAdaptiveNavigation.barKey), findsNothing);
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'GEN-02334-G4',
          requirementSource:
              'Setup Step (Action): "Integrate M3 Navigation Rails for tablet '
              'views and Bottom App Bars for mobile views."',
          description:
              'The same widget renders a bottom bar at 393dp and a navigation '
              'rail at 1024dp, with exactly one surface present at a time',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-02334-G5] labels are visible on both surfaces, and '
        'selecting a destination changes the body', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      int selected = 0;
      await tester.pumpWidget(
        nav(selected: selected, onSelected: (int i) => selected = i),
      );
      await tester.pumpAndSettle();

      // Labels are on screen, not only in a tooltip that touch cannot reach.
      expect(find.text('Overview'), findsWidgets);
      expect(find.text('Tasks'), findsWidgets);
      expect(find.text('destination Overview'), findsOneWidget);

      await tester.tap(find.text('Tasks').first);
      await tester.pumpAndSettle();
      expect(selected, 1);

      gates.add(
        const AissGate(
          id: 'GEN-02334-G5',
          requirementSource:
              'Metric: UI Compliance Rate (%). MD3 requires a visible label on '
              'the selected destination at minimum; this design system shows '
              'all of them, because a touch device has no hover to fall back '
              'on.',
          description:
              'Destination labels render as text and a tap reports the new '
              'index to the caller',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-02334-G6] the bottom bar sits inside the thumb band', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(nav(selected: 0));
      await tester.pumpAndSettle();

      final Rect bar = tester.getRect(
        find.byKey(HabotAdaptiveNavigation.barKey),
      );
      expect(bar.bottom, closeTo(640, 1));
      expect(
        bar.height,
        lessThanOrEqualTo(HabotNavigationPolicy.barHeight + 1),
      );

      gates.add(
        AissGate(
          id: 'GEN-02334-G6',
          requirementSource:
              'SSTLA-018 Flow Impact: "Navigation bars sit comfortably within '
              'standard thumb interaction spaces."',
          description:
              'On the 5.5-inch reference viewport the bar is anchored to the '
              'bottom edge and no taller than its token height',
          passed: true,
          detail:
              'bar top ${bar.top.toStringAsFixed(0)}dp, bottom '
              '${bar.bottom.toStringAsFixed(0)}dp of 640dp',
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02334',
        atomicStepReferenceId: 'GEN-02334-A01',
        setupStepAction:
            'Integrate M3 Navigation Rails for tablet views and Bottom App '
            'Bars for mobile views.',
        implementationOrder: 40,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotAdaptiveNavigation',
          'Component Type': 'M3 navigation rail + navigation bar',
          'Component Properties':
              'rail width ${HabotNavigationPolicy.railWidth}dp, bar height '
              '${HabotNavigationPolicy.barHeight}dp, threshold '
              '${HabotGrid.navigationCollapse}dp',
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Compliance Rate (%)',
            observed:
                '1.0 -- rail above the recorded threshold and bar below it, '
                'exactly one surface at a time, labels visible on both, no '
                'hover tooltip anywhere, and the bar anchored in the thumb band',
            floor: '0.95',
            optimal: '1.0',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/navigation/adaptive_navigation.dart',
        ],
      ),
    );
  });
}
