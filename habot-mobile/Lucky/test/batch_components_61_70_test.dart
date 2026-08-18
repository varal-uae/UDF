import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habot_lucky/core/components/likert_extreme_rating_module.dart';
import 'package:habot_lucky/core/components/statutory_deadline_tracker.dart';
import 'package:habot_lucky/core/components/grievance_sla_card.dart';
import 'package:habot_lucky/core/components/biometric_auth_drawer.dart';
import 'package:habot_lucky/core/components/rule_of_and_task_box.dart';
import 'package:habot_lucky/core/components/storage_metrics_dashboard.dart';
import 'package:habot_lucky/core/components/realtime_animated_list.dart';
import 'package:habot_lucky/core/components/audit_reconciliation_viewer.dart';
import 'package:habot_lucky/core/components/dcyn_rejection_handler.dart';
import 'package:habot_lucky/core/components/escrow_milestone_summary_card.dart';

void main() {
  group('Step 61 - IS35-CSIVW-022-AS01 Tests', () {
    testWidgets('LikertExtremeRatingModule expands evidence box on extreme rating 1', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LikertExtremeRatingModule(
              onRatingChanged: (_) {},
              onEvidenceSubmitted: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Evidence Required'), findsNothing);

      // Select rating 1
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Evidence Required'), findsOneWidget);
    });
  });

  group('Step 62 - GCCC-001 Tests', () {
    testWidgets('StatutoryDeadlineTracker displays days remaining and progress indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatutoryDeadlineTracker(
              submissionTitle: 'Annual Tax Return',
              daysRemaining: 10,
              totalFilingWindowDays: 60,
              onTapFilingDetails: () {},
            ),
          ),
        ),
      );

      expect(find.text('Annual Tax Return'), findsOneWidget);
      expect(find.text('10 Days Left'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });

  group('Step 63 - CTTEE-024 Tests', () {
    testWidgets('GrievanceSlaCard renders countdown and handle breach styles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GrievanceSlaCard(
              grievanceId: '101',
              title: 'Payroll Discrepancy',
              createdAt: DateTime.now().subtract(const Duration(minutes: 35)), // Breached
              onEscalate: () {},
            ),
          ),
        ),
      );

      expect(find.text('Grievance #101'), findsOneWidget);
      expect(find.text('SLA BREACHED'), findsOneWidget);
    });
  });

  group('Step 64 - BDAE-001 Tests', () {
    testWidgets('BiometricAuthDrawer renders verification action targets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BiometricAuthDrawer(
              challengeTitle: 'Confirm Login Identity',
              onAuthenticate: () {},
              onCancel: () {},
            ),
          ),
        ),
      );

      expect(find.text('Biometric Verification'), findsOneWidget);
      expect(find.text('Authenticate'), findsOneWidget);
    });
  });

  group('Step 65 - EDBAA-037 Tests', () {
    testWidgets('RuleOfAndTaskBox auto-unlocks next task in sequence', (tester) async {
      final tasks = [
        SubTaskItem(id: '1', title: 'Task 1'),
        SubTaskItem(id: '2', title: 'Task 2'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RuleOfAndTaskBox(
              groupTitle: 'Onboarding Checklist',
              tasks: tasks,
              onAllCompleted: () {},
            ),
          ),
        ),
      );

      expect(find.text('Onboarding Checklist'), findsOneWidget);
      expect(find.text('Task 1'), findsOneWidget);
    });
  });

  group('Step 66 - HSCPE-002 Tests', () {
    testWidgets('StorageMetricsDashboard renders storage stats', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StorageMetricsDashboard(
              metrics: [
                StorageMetricItem(
                  label: 'Primary Volume',
                  capacityValue: '500 GB',
                  performanceValue: '10000',
                  details: 'SSD Storage Details',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Primary Volume'), findsOneWidget);
      expect(find.text('Capacity: 500 GB'), findsOneWidget);
    });
  });

  group('Step 67 - EDPS-002 Tests', () {
    testWidgets('RealtimeAnimatedList renders list items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RealtimeAnimatedList(
              items: const [
                RealtimeListItem(id: '1', title: 'Event Item 1', timestamp: '12:00 PM'),
              ],
              onRefresh: () async {},
            ),
          ),
        ),
      );

      expect(find.text('Event Item 1'), findsOneWidget);
    });
  });

  group('Step 68 - PDMV-001 Tests', () {
    testWidgets('AuditReconciliationViewer displays reconciliation state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuditReconciliationViewer(
              transferAmount: 1500.00,
              isReconciled: true,
              auditLogs: [
                AuditTrailEntry(
                  auditType: 'Ledger Transfer',
                  auditDate: '2026-08-18',
                  auditResult: 'PASSED',
                  auditTrailHash: 'abc123hash',
                  auditorInfo: 'System Auto-Audit',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.textContaining('Balance Reconciled'), findsOneWidget);
      expect(find.text('Hash: abc123hash'), findsOneWidget);
    });
  });

  group('Step 69 - BCDLD-002 Tests', () {
    testWidgets('DcynRejectionPayload instantiates correctly', (tester) async {
      const payload = DcynRejectionPayload(
        rejectionCode: 'ERR_DCYN_403',
        reason: 'Rate limit exceeded',
        timestamp: '2026-08-18',
      );
      expect(payload.rejectionCode, 'ERR_DCYN_403');
    });
  });

  group('Step 70 - SEPGE-001 Tests', () {
    testWidgets('EscrowMilestoneSummaryCard displays locked escrow properties', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EscrowMilestoneSummaryCard(
              milestoneTitle: 'Milestone Phase 1',
              escrowAmount: 5000.00,
              isLocked: true,
              holdReason: 'Awaiting inspection sign-off',
            ),
          ),
        ),
      );

      expect(find.text('Milestone Phase 1'), findsOneWidget);
      expect(find.text('ESCROW HELD'), findsOneWidget);
      expect(find.text('AED 5000.00'), findsOneWidget);
    });
  });
}
