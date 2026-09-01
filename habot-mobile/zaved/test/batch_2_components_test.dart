import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/ui/interactive_masked_input_form.dart';
import 'package:flutter_application_1/ui/orientation_aware_form_wrapper.dart';
import 'package:flutter_application_1/ui/supporting_pane_layout_wrapper.dart';
import 'package:flutter_application_1/ui/budget_alert_banner_dashboard.dart';
import 'package:flutter_application_1/ui/local_reconciliation_gate_form.dart';

void main() {
  group('SCTSS-008: InteractiveMaskedInputForm Tests', () {
    testWidgets('Save button is disabled by default and enables when valid formatted inputs are entered',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const InteractiveMaskedInputForm(),
        ),
      );

      // Verify save button is initially disabled (onPressed: null)
      final disabledButtonFinder = find.widgetWithText(FilledButton, 'Fix Typos to Save');
      expect(disabledButtonFinder, findsOneWidget);
      final FilledButton button = tester.widget(disabledButtonFinder);
      expect(button.onPressed, isNull);

      // Enter valid 10-digit phone and currency amount
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), '5551234567');
      await tester.enterText(textFields.at(1), '4999');
      await tester.pumpAndSettle();

      // Save button should now be active
      final enabledButtonFinder = find.widgetWithText(FilledButton, 'Save to BigQuery');
      expect(enabledButtonFinder, findsOneWidget);
    });
  });

  group('SSTLA-025: OrientationAwareFormWrapper Tests', () {
    testWidgets('Renders form fields with PageStorageKey state preservation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const OrientationAwareFormWrapper(),
        ),
      );

      expect(find.byKey(const Key('first_name_key')), findsOneWidget);
      expect(find.byKey(const Key('last_name_key')), findsOneWidget);
      expect(find.byKey(const Key('email_key')), findsOneWidget);

      // Verify submit button initially active when not rotating
      expect(find.text("Submit Registration Form"), findsOneWidget);

      // Tap rotation simulation button
      await tester.tap(find.byIcon(Icons.screen_rotation));
      await tester.pump();

      // Submit button should be disabled during 500ms rotation lock
      expect(find.text("Locked During Rotation..."), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Submit button re-enabled after 500ms
      expect(find.text("Submit Registration Form"), findsOneWidget);
    });
  });

  group('RCGLA-033: SupportingPaneLayoutWrapper Tests', () {
    testWidgets('Renders side-by-side Row on Desktop (>800px) and ExpansionTile on Mobile (<=800px)',
        (WidgetTester tester) async {
      // Desktop View > 800px
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const SupportingPaneDemoScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Row), findsWidgets);
      expect(find.text("Supporting Pane"), findsOneWidget);

      // Mobile View <= 800px
      tester.view.physicalSize = const Size(500, 800);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const SupportingPaneDemoScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ExpansionTile), findsOneWidget);
      expect(find.text("View Contextual Tips / Details"), findsOneWidget);
    });

    test('Poka-Yoke assertion throws if staticWidthOverride is passed', () {
      expect(
        () => SupportingPaneLayoutWrapper(
          staticWidthOverride: 400.0,
          primaryContent: const SizedBox(),
          supportingPane: const SizedBox(),
        ),
        throwsAssertionError,
      );
    });
  });

  group('CCBPB-011: BudgetAlertBannerDashboard Tests', () {
    testWidgets('Shows errorContainer banner and locks purchase button when over budget',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const BudgetAlertBannerDashboard(
            initialSpend: 1050.0,
            budgetLimit: 1000.0,
          ),
        ),
      );

      // Over-budget banner must be visible
      expect(find.textContaining("CRITICAL BUDGET OVERRUN DETECTED"), findsOneWidget);

      // Submit purchase button must be disabled (onPressed: null)
      final lockedButtonFinder = find.widgetWithText(FilledButton, '100% Hard Limit Lockout Active');
      expect(lockedButtonFinder, findsOneWidget);
      final FilledButton button = tester.widget(lockedButtonFinder);
      expect(button.onPressed, isNull);

      // Tap reset spend button
      await tester.tap(find.byIcon(Icons.restart_alt));
      await tester.pumpAndSettle();

      // Purchase button active again
      expect(find.textContaining("Submit New Purchase"), findsOneWidget);
    });
  });

  group('IS07-FIEVR-012-AS01: LocalReconciliationGateForm Tests', () {
    testWidgets('Shows RECONCILED checkmark when credits equal debits and blocks on mismatch',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const LocalReconciliationGateForm(),
        ),
      );

      // Initially credits (1000) equal debits (1000) -> Reconciled
      expect(find.text("RECONCILED ✓"), findsOneWidget);
      expect(find.text("Post Reconciled Entry"), findsOneWidget);

      // Change credits to create a variance
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), "1200.00");
      await tester.pumpAndSettle();

      // Should show variance and lock post button
      expect(find.textContaining("VARIANCE: \$200.00"), findsOneWidget);
      final lockedButtonFinder = find.widgetWithText(FilledButton, 'Locked (Variance: \$200.00)');
      expect(lockedButtonFinder, findsOneWidget);
      final FilledButton button = tester.widget(lockedButtonFinder);
      expect(button.onPressed, isNull);
    });
  });
}
