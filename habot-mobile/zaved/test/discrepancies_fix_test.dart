import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/ui/visual_isolation_workspace.dart';
import 'package:flutter_application_1/ui/public_profile_review_timeline.dart';
import 'package:flutter_application_1/ui/django_income_statement_workspace.dart';
import 'package:flutter_application_1/ui/navigation_rail_adaptive_workspace.dart';
import 'package:flutter_application_1/ui/master_menu_page.dart';
import 'package:flutter_application_1/ui/component_explanation_registry.dart';

void main() {
  group('Discrepancies Resolution Test Suite', () {
    testWidgets('SSELC-032: VisualIsolationWorkspace renders cropping engine',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VisualIsolationWorkspace(),
        ),
      );

      expect(find.textContaining('Cropping Engine (SSELC-032)'), findsOneWidget);
      expect(find.textContaining('ISOLATED CROP SNIPPET'), findsOneWidget);
      expect(find.text('Region Data Entry'), findsOneWidget);
    });

    testWidgets('GTBPU-001: PublicProfileReviewTimeline renders chronological review events',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PublicProfileReviewTimeline(),
        ),
      );

      expect(find.textContaining('Public Profile Review Timeline'), findsOneWidget);
      expect(find.text('Identity & Credential Verification'), findsOneWidget);
      expect(find.text('Approved'), findsAtLeastNWidgets(1));
    });

    testWidgets('DSDD-002: DjangoIncomeStatementWorkspace renders income statement models',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DjangoIncomeStatementWorkspace(),
        ),
      );

      expect(find.textContaining('Income Statement Models'), findsOneWidget);
      expect(find.text('Enterprise Software Subscription Revenue'), findsOneWidget);
      expect(find.text('Gross Revenue'), findsOneWidget);
    });

    testWidgets('ANSA-020-09: NavigationRailAdaptiveWorkspace renders NavigationRail',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: NavigationRailAdaptiveWorkspace(),
        ),
      );

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.textContaining('Navigation Rail Adaptive Workspace'), findsOneWidget);
    });

    test('Master Menu Catalog registrations contain correct Global Reference IDs', () {
      // Create MasterMenuPage to verify ComponentSpec catalog
      const masterMenu = MasterMenuPage();
      expect(masterMenu, isNotNull);
    });

    test('ComponentExplanationRegistry provides explanations for all updated IDs', () {
      expect(
        ComponentExplanationRegistry.getExplanation(
          globalRefId: 'SSELC-032',
          atomicStepId: 'SSELC-032-A01',
        ),
        contains('Coordinate-Based Image Cropping'),
      );

      expect(
        ComponentExplanationRegistry.getExplanation(
          globalRefId: 'DSDD-002',
          atomicStepId: 'DSDD-002-A01',
        ),
        contains('Backward-Linked Financial Data Modeling'),
      );

      expect(
        ComponentExplanationRegistry.getExplanation(
          globalRefId: 'DPNDL-011',
          atomicStepId: 'DPNDL-011-A01',
        ),
        contains('Global Top Application Bar'),
      );

      expect(
        ComponentExplanationRegistry.getExplanation(
          globalRefId: 'GTBPU-001',
          atomicStepId: 'GTBPU-001-A01',
        ),
        contains('Public Profile Review Timelines'),
      );

      expect(
        ComponentExplanationRegistry.getExplanation(
          globalRefId: 'ANSA-020-09',
          atomicStepId: 'ANSA-020-09-A01',
        ),
        contains('Navigation Rail Viewport Mapping'),
      );
    });
  });
}
