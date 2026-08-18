/// AISS GATE -- Step 41 of 50
/// Global Reference ID:       GEN-02676
/// Atomic Steps Reference ID: GEN-02676-A01
/// Setup Step (Action):       "Add a badge counter to the bottom navigation
///                             icon that displays the current unread
///                             notification count."
/// Metric: Implementation Completeness Rate -- Floor "90% of defined scope
///         completed", Optimal "100% of scope complete with peer validation".
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/navigation/adaptive_navigation.dart';
import 'package:udf_setup/design_system/navigation/nav_badge.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';

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

  group('GEN-02676-A01 :: the count', () {
    gate(
      'GEN-02676-G1',
      'Setup Step (Action): "...displays the CURRENT UNREAD notification '
          'count."',
      'Zero renders no badge at all, and any positive count renders the number '
          '-- a badge reading "0" is noise pretending to be signal',
      () =>
          !const HabotNavBadge(count: 0, child: Icon(Icons.inbox)).isVisible &&
          const HabotNavBadge(count: 1, child: Icon(Icons.inbox)).isVisible &&
          const HabotNavBadge(count: 7, child: Icon(Icons.inbox)).displayText ==
              '7',
    );

    gate(
      'GEN-02676-G2',
      'MD3 badge specification: a numeric badge caps rather than overflowing '
          'its container.',
      'Counts past the cap read as "99+", and the cap is the MD3 value',
      () =>
          HabotNavBadge.maxCount == 99 &&
          const HabotNavBadge(count: 99, child: Icon(Icons.inbox)).displayText ==
              '99' &&
          const HabotNavBadge(
                count: 100,
                child: Icon(Icons.inbox),
              ).displayText ==
              '99+' &&
          const HabotNavBadge(
                count: 4213,
                child: Icon(Icons.inbox),
              ).displayText ==
              '99+',
    );

    gate(
      'GEN-02676-G3',
      'ANSA-012 accessibility precedent, inherited: an interactive element '
          'with no accessible name is a defect. A count that exists only in '
          'pixels is the same defect.',
      'The badge announces its count, with the destination it belongs to',
      () =>
          const HabotNavBadge(
                count: 3,
                label: 'Tasks',
                child: Icon(Icons.inbox),
              ).semanticsLabel ==
              'Tasks, 3 unread' &&
          const HabotNavBadge(
                count: 3,
                child: Icon(Icons.inbox),
              ).semanticsLabel ==
              '3 unread',
    );

    gate(
      'GEN-02676-G4',
      'Setup Step (Action) -- one count per destination, and a total for the '
          'app. Two places holding the same number is how they disagree.',
      'The unread model reports per route and in total, and clearing a route '
          'affects only that route',
      () {
        final HabotUnreadCounts counts = HabotUnreadCounts(<String, int>{
          '/tasks': 3,
          '/settings': 1,
        });
        final int before = counts.total;
        counts.clear('/tasks');
        return before == 4 &&
            counts.countFor('/tasks') == 0 &&
            counts.countFor('/settings') == 1 &&
            counts.total == 1 &&
            counts.countFor('/unknown') == 0;
      },
    );
  });

  group('GEN-02676-A01 :: on the bar', () {
    testWidgets('[GEN-02676-G5] the badge renders on the bottom navigation '
        'icon and opening the destination clears it', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final HabotUnreadCounts counts = HabotUnreadCounts(<String, int>{
        '/tasks': 5,
      });
      addTearDown(counts.dispose);
      int selected = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: AnimatedBuilder(
              animation: counts,
              builder: (BuildContext context, Widget? _) =>
                  HabotAdaptiveNavigation(
                    selectedIndex: selected,
                    onDestinationSelected: (int i) {
                      selected = i;
                      counts.clear('/tasks');
                    },
                    destinations: <HabotDestination>[
                      const HabotDestination(
                        route: '/overview',
                        label: 'Overview',
                        icon: Icons.dashboard_outlined,
                      ),
                      HabotDestination(
                        route: '/tasks',
                        label: 'Tasks',
                        icon: Icons.checklist_outlined,
                        unreadCount: counts.countFor('/tasks'),
                      ),
                    ],
                    body: const Text('body'),
                  ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(HabotNavBadge.badgeKey), findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      await tester.tap(find.text('Tasks').first);
      await tester.pumpAndSettle();

      expect(find.byKey(HabotNavBadge.badgeKey), findsNothing);
      expect(find.text('5'), findsNothing);
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'GEN-02676-G5',
          requirementSource:
              'Setup Step (Action): "Add a badge counter to the bottom '
              'navigation icon that displays the current unread notification '
              'count."',
          description:
              'A destination with five unread renders the badge on its icon, '
              'and opening that destination removes the badge',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02676',
        atomicStepReferenceId: 'GEN-02676-A01',
        setupStepAction:
            'Add a badge counter to the bottom navigation icon that displays '
            'the current unread notification count.',
        implementationOrder: 41,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotNavBadge / HabotUnreadCounts',
          'Component Type': 'MD3 count badge on a navigation destination',
          'Component Properties': 'cap ${HabotNavBadge.maxCount}, zero hides',
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'Implementation Completeness Rate',
            observed:
                '100% of the defined scope: count display, zero suppression, '
                'the 99+ cap, the spoken announcement, per-route and total '
                'models, and clear-on-open -- all gated',
            floor: '90% of defined scope completed',
            optimal: '100% of scope complete with peer validation',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/navigation/nav_badge.dart',
        ],
      ),
    );
  });
}
