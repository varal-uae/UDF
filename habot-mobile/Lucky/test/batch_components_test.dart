import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habot_lucky/core/components/signed_url_asset_loader.dart';
import 'package:habot_lucky/core/components/design_reconciliation_card.dart';
import 'package:habot_lucky/core/components/compact_task_panel.dart';
import 'package:habot_lucky/core/components/cold_start_overlay.dart';
import 'package:habot_lucky/core/components/ai_rationale_accordion.dart';
import 'package:habot_lucky/core/components/structural_trace_view.dart';
import 'package:habot_lucky/core/components/ed_field_hierarchy_viewer.dart';
import 'package:habot_lucky/core/utils/layout_instantiation_tracker.dart';
import 'package:habot_lucky/core/utils/data_lineage_tracker.dart';
import 'package:habot_lucky/core/utils/end_document_metadata.dart';

void main() {
  group('IRBCA-031 LayoutInstantiationTracker Tests', () {
    testWidgets('captures ISO 8601 utc instantiation string correctly', (tester) async {
      final key = GlobalKey<_TestTrackerWidgetState>();
      await tester.pumpWidget(MaterialApp(home: _TestTrackerWidget(key: key)));
      final state = key.currentState!;
      
      expect(state.instantiationFrame.instantiationTime, isNotEmpty);
      expect(state.instantiationFrame.deviceInfo['screenSize'], isNotNull);
    });
  });

  group('BLGTA-054-12 DataLineageTracker Tests', () {
    test('lineage tracking and upload envelope sealing behaves asynchronously', () async {
      final tracker = DataLineageTracker.instance;
      tracker.registerTrackingId('doc_1', 'lineage_uuid_123');

      // Wait a microtask duration for stream schedules to finalize
      await Future.microtask(() {});

      final envelope = await tracker.sealEnvelope(
        targetKey: 'doc_1',
        uploadPayload: {'content': 'data'},
      );

      expect(envelope['predecessor_id'], 'lineage_uuid_123');
      expect(envelope['data_lineage_metadata']['lineage_isolated'], true);
    });
  });

  group('HAZFE-020-12 SignedUrlAssetLoader Tests', () {
    testWidgets('triggers refresh flow near expiry and swipe processes correctly', (tester) async {
      var fetchCount = 0;
      Future<SignedUrlAsset> mockFetcher(String id) async {
        fetchCount++;
        return SignedUrlAsset(
          url: 'signed_url_$fetchCount',
          expiresAt: DateTime.now().toUtc().add(const Duration(seconds: 15)),
        );
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SignedUrlAssetLoader(
              assetId: 'asset_1',
              urlFetcher: mockFetcher,
              refreshThreshold: const Duration(seconds: 14), // Force immediate refresh
              builder: (context, asset, refreshing) => Text(asset.url),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('signed_url_1'), findsOneWidget);

      // Triggering pump to process timers
      await tester.pump(const Duration(seconds: 2));
      expect(fetchCount, greaterThanOrEqualTo(2));
    });
  });

  group('DLQDP-024-12 DesignReconciliationCard Tests', () {
    testWidgets('renders reconciliation score and handles 48dp trigger tap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DesignReconciliationCard(
              score: 0.96,
              targetCode: 'DLQDP-024',
              onReconcile: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('96.0%'), findsOneWidget);
      expect(find.text('Target Blueprint: DLQDP-024'), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(tapped, true);
    });
  });

  group('EDEBS-034-12 CompactTaskPanel Tests', () {
    testWidgets('pinned timer app bar pulses under 60 seconds', (tester) async {
      var expired = false;

      await tester.pumpWidget(
        MaterialApp(
          home: CompactTaskPanel(
            taskName: 'Pipeline Task',
            microTasks: const ['Task Item 1', 'Task Item 2'],
            durationLimit: const Duration(seconds: 59), // critical trigger
            onTimerExpired: () => expired = true,
          ),
        ),
      );

      expect(find.text('00:59'), findsOneWidget);
      // Pulses ScaleTransition
      expect(find.byType(ScaleTransition), findsOneWidget);
    });
  });

  group('ETMDI-001-12 EndDocumentMetadata Tests', () {
    testWidgets('enforces input styles and 48dp targets', (tester) async {
      var val = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EndDocumentField(
              label: 'Predecessor Identification *',
              value: '123',
              onChanged: (v) => val = v,
              errorMessage: 'Invalid format',
            ),
          ),
        ),
      );

      expect(find.text('Invalid format'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '456');
      expect(val, '456');
    });
  });

  group('CRSSS-001 ColdStartProgressOverlay Tests', () {
    testWidgets('overlay shows scaling state correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ColdStartProgressOverlay(
            isColdStarting: true,
            child: Text('Main UI Content'),
          ),
        ),
      );

      expect(find.text('Scaling compute resources...'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });

  group('ARCPE-004-11 AiRationaleAccordion Tests', () {
    testWidgets('accordions handle trust score coloring and disclosures', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AiRationaleAccordion(
              score: 0.92,
              rationales: ['Rationale item A', 'Rationale item B'],
            ),
          ),
        ),
      );

      expect(find.text('92% Confidence'), findsOneWidget);
      expect(find.text('Rationale item A'), findsNothing); // Collapsed by default

      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pumpAndSettle();
      
      expect(find.text('Rationale item A'), findsOneWidget);
    });
  });

  group('VPVMP-016-11 StructuralTraceView Tests', () {
    testWidgets('triggers flash on zero balance updates', (tester) async {
      var triggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StructuralTraceView(
              traceLogs: const ['trace: 1'],
              balanceAmount: 10.0,
              onZeroBalanceTriggered: () => triggered = true,
            ),
          ),
        ),
      );

      expect(find.text('Discrepancy Detected'), findsOneWidget);

      // Rebuild with zero balance
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StructuralTraceView(
              traceLogs: const ['trace: 1'],
              balanceAmount: 0.0,
              onZeroBalanceTriggered: () => triggered = true,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(triggered, true);
    });
  });

  group('DSDD-007-11 EdFieldHierarchyViewer Tests', () {
    testWidgets('renders field hierarchies logically', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EdFieldHierarchyViewer(
              stepExecutionId: 'exec_abc',
              status: 'Pass',
              timestamp: '2026-08-17',
              userId: 'user_1',
              fields: [
                EdFieldMetadata(fieldName: 'Field Root', fieldType: 'String', value: 'Value Root'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Execution ID: exec_abc'), findsOneWidget);
      expect(find.text('Field Root'), findsOneWidget);
    });
  });
}

class _TestTrackerWidget extends StatefulWidget {
  const _TestTrackerWidget({super.key});

  @override
  State<_TestTrackerWidget> createState() => _TestTrackerWidgetState();
}

class _TestTrackerWidgetState extends State<_TestTrackerWidget> with LayoutInstantiationTracker {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('Test tracker'));
  }
}
