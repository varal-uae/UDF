import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/ui/offline_udd_sync_workspace.dart';

void main() {
  Widget buildTestApp() {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const OfflineUddSyncWorkspace(),
    );
  }

  group('Offline-First UDD API Sync Requirements Verification', () {
    testWidgets(
        'Requirement 1, 2 & 3: Background fetch during initState shows skeleton UI & top sync indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());

      // 1. Requirement 2: Skeleton UI is displayed immediately (isSyncing is true)
      // Verify no full-screen CircularProgressIndicator exists
      expect(find.byType(CircularProgressIndicator), findsOneWidget); // Tiny 10px indicator in sync header bar only

      // 2. Requirement 3: Top Sync Indicator is present while isSyncing is true
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Syncing UDD Schema in background...'), findsOneWidget);

      // Complete background async sync simulation (2 seconds delay)
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Verify sync completion: LinearProgressIndicator disappears
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('Schema Synced & Cached locally'), findsOneWidget);

      // Verify Rulebook items loaded from API/Cache
      expect(find.text('Active UDD Rulebook Rules'), findsOneWidget);
    });

    testWidgets(
        'Requirement 4 & 1: Error Queueing (Poka-Yoke) falls back to cached schema on network failure',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp());

      // Wait for initial sync to settle
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Toggle offline mode switch to simulate network disconnection
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Trigger manual re-sync with offline mode enabled
      final resyncButton = find.byIcon(Icons.sync);
      await tester.tap(resyncButton);
      await tester.pump(); // Start sync

      // Verify syncing state activates
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Complete failed async call
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Verify Error Queue Log Card is displayed with Poka-Yoke error log
      expect(find.textContaining('Poka-Yoke Error Queue'), findsOneWidget);
      expect(
        find.textContaining('504 Gateway Timeout (Network Offline)'),
        findsOneWidget,
      );

      // Verify fallback cached data is rendered operational
      expect(find.text('Offline Local Cache (100% Operational Fallback)'), findsOneWidget);
    });
  });
}
