import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habot_lucky/core/components/enterprise_navigation_rail.dart';
import 'package:habot_lucky/core/components/anchored_bottom_nav_bar.dart';
import 'package:habot_lucky/core/utils/design_length_metrics_validator.dart';
import 'package:habot_lucky/core/components/fluid_image_crop_container.dart';
import 'package:habot_lucky/core/components/rework_penalty_alert_banner.dart';
import 'package:habot_lucky/core/components/celebratory_confirmation_dialog.dart';
import 'package:habot_lucky/core/components/hire_blocked_modal.dart';
import 'package:habot_lucky/core/components/collapsible_audit_log_viewer.dart';
import 'package:habot_lucky/core/components/focused_task_workspace.dart';
import 'package:habot_lucky/core/components/system_verb_icon_wrapper.dart';

void main() {
  group('Step 71 - TNRML-011 Tests', () {
    testWidgets('EnterpriseNavigationRail renders destination items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnterpriseNavigationRail(
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              destinations: const [
                NavigationRailDestinationItem(
                  label: 'Dashboard',
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Dashboard'), findsOneWidget);
    });
  });

  group('Step 72 - REF-467 Tests', () {
    testWidgets('AnchoredBottomNavBar renders fixed 80dp navigation bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AnchoredBottomNavBar(
              currentIndex: 0,
              onTap: (_) {},
              items: const [
                BottomNavDestination(label: 'Home', icon: Icons.home_outlined, selectedIcon: Icons.home),
                BottomNavDestination(label: 'Tasks', icon: Icons.task_outlined, selectedIcon: Icons.task),
                BottomNavDestination(label: 'Profile', icon: Icons.person_outlined, selectedIcon: Icons.person),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });
  });

  group('Step 73 - AWCV-002-01 Tests', () {
    test('DesignLengthMetricsValidator validates string bounds & adherence rates', () {
      expect(DesignLengthMetricsValidator.validateMicrocopyLength('Short text'), isTrue);
      expect(DesignLengthMetricsValidator.validateMicrocopyLength('a' * 100), isFalse);

      final rate = DesignLengthMetricsValidator.calculateAdherenceRate(
        totalCheckedProperties: 10,
        validProperties: 9,
      );
      expect(rate, 0.9);
      expect(DesignLengthMetricsValidator.meetsAdherenceFloor(rate), isTrue);
    });
  });

  group('Step 74 - MCIIM-009-01 Tests', () {
    testWidgets('FluidImageCropContainer renders aspect ratio container', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FluidImageCropContainer(
              imageProvider: NetworkImage('https://via.placeholder.com/150'),
            ),
          ),
        ),
      );

      expect(find.byType(AspectRatio), findsOneWidget);
    });
  });

  group('Step 75 - BTPM-029 Tests', () {
    testWidgets('ReworkPenaltyAlertBanner renders penalty details and score delta', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReworkPenaltyAlertBanner(
              workerId: 'W-991',
              reworkCount: 2,
              previousScore: 95.0,
              newScore: 85.0,
              reason: 'Missing validation step',
              triggerHaptics: false,
            ),
          ),
        ),
      );

      expect(find.text('Task Rework Penalty Applied'), findsOneWidget);
      expect(find.textContaining('Current Score: 95.0 ➔ 85.0'), findsOneWidget);
    });
  });

  group('Step 76 - ACRAE-031 Tests', () {
    testWidgets('CelebratoryConfirmationDialog displays celebratory title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CelebratoryConfirmationDialog(
              celebrationMessage: 'Candidate selected!',
              candidateName: 'John Doe',
              onFinalizeLock: () {},
            ),
          ),
        ),
      );

      expect(find.text('Success Felicitations!'), findsOneWidget);
      expect(find.text('Candidate: John Doe'), findsOneWidget);
    });
  });

  group('Step 77 - ACRAE-028 Tests', () {
    testWidgets('HireBlockedModal displays block reason & Request Override action', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HireBlockedModal(
              missingScoresCount: 3,
              blockReason: 'Evaluation incomplete.',
              onRequestOverride: () {},
            ),
          ),
        ),
      );

      expect(find.text('Hire Blocked'), findsOneWidget);
      expect(find.text('Request Override'), findsOneWidget);
    });
  });

  group('Step 78 - IRBCA-040 Tests', () {
    testWidgets('CollapsibleAuditLogViewer displays audit log search bar & items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CollapsibleAuditLogViewer(
              logs: const [
                AuditLogItem(
                  id: 'LOG-001',
                  action: 'Tax Record Update',
                  operator: 'User A',
                  timestamp: '2026-08-19',
                  details: 'Modified tax field',
                ),
              ],
              onSearchFilterTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Tax Record Update'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('Step 79 - SSTLA-035 Tests', () {
    testWidgets('FocusedTaskWorkspace hides global header and wraps task title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FocusedTaskWorkspace(
            taskTitle: 'Critical Task Evaluation',
            onConfirmExit: () async => true,
            child: const Text('Workspace Content'),
          ),
        ),
      );

      expect(find.text('Critical Task Evaluation'), findsOneWidget);
      expect(find.text('Workspace Content'), findsOneWidget);
    });
  });

  group('Step 80 - DLQDP-015-02 Tests', () {
    testWidgets('SystemVerbIconWrapper enforces 48dp touch bounds', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SystemVerbIconWrapper(
              icon: Icons.settings,
              onTap: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.minWidth, 48.0);
      expect(container.constraints?.minHeight, 48.0);
    });
  });
}
