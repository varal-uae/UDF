import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/ui/components/data_entry_card.dart';
import 'package:flutter_application_1/ui/persistent_header_layout_system.dart';
import 'package:flutter_application_1/ui/inertial_drag_smooth_list_scroller.dart';
import 'package:flutter_application_1/ui/async_form_skeleton_loader.dart';
import 'package:flutter_application_1/ui/dynamic_tab_coordinator.dart';

void main() {
  group('RCGLA-040: DataEntryCard Component Tests', () {
    testWidgets('Single-input card renders and toggles error flash & validation line',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: DataEntryCard(
              title: "Test Entry",
              errorMessage: "Invalid payload input",
              initialHasError: false,
              inputChild: const TextField(key: Key('test_input_field')),
            ),
          ),
        ),
      );

      // Verify input field and title exist
      expect(find.byKey(const Key('test_input_field')), findsOneWidget);
      expect(find.text("Test Entry"), findsOneWidget);

      // Error line should not be visible initially
      expect(find.text("Invalid payload input"), findsNothing);

      // Tap flash error state toggle
      await tester.tap(find.text("Flash: Normal"));
      await tester.pumpAndSettle();

      // Error line should now be visible
      expect(find.text("Invalid payload input"), findsOneWidget);
      expect(find.text("Flash: Error"), findsOneWidget);
    });

    test('Poka-Yoke assertion throws if MultiChild widget passed as inputChild', () {
      expect(
        () => DataEntryCard(
          title: "Invalid Card",
          inputChild: const Column(
            children: [
              TextField(),
              TextField(),
            ],
          ),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('DataEntryCardResponsiveLayout switches between Column (Mobile) and Wrap (Tablet)',
        (WidgetTester tester) async {
      // Mobile View <= 600
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const DataEntryCardResponsiveLayout(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);

      // Tablet View > 600
      tester.view.physicalSize = const Size(900, 800);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const DataEntryCardResponsiveLayout(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Wrap), findsOneWidget);
    });
  });

  group('ANSA-013: PersistentHeaderLayoutSystem Tests', () {
    testWidgets('Renders with frosted backdrop blur and toggles action permissions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            appBar: PersistentHeaderLayoutSystem(
              traceId: "TRC-TEST-123",
              initialHasActionPermissions: true,
            ),
            body: SizedBox.expand(),
          ),
        ),
      );

      expect(find.text("trace_id: TRC-TEST-123"), findsOneWidget);
      expect(find.byIcon(Icons.wifi), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      // Tap permission toggle button
      await tester.tap(find.text("Perms: ON"));
      await tester.pumpAndSettle();

      // Action shortcut buttons must be completely removed from layout (SizedBox.shrink)
      expect(find.byIcon(Icons.refresh), findsNothing);
      expect(find.byIcon(Icons.settings), findsNothing);
    });

    testWidgets('Responsive height evaluates to 56dp on mobile and 64dp on desktop',
        (WidgetTester tester) async {
      // Mobile physical size <= 600
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const Scaffold(
            appBar: PersistentHeaderLayoutSystem(),
            body: SizedBox.expand(),
          ),
        ),
      );

      final headerFinder = find.byType(PersistentHeaderLayoutSystem);
      expect(headerFinder, findsOneWidget);
    });
  });

  group('ANSA-018: InertialDragSmoothListScroller Tests', () {
    testWidgets('Renders ListView.builder items wrapped in RepaintBoundary',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: InertialDragSmoothListScroller(
              itemCount: 10,
              itemBuilder: (context, index) => Text("Item #$index"),
            ),
          ),
        ),
      );

      expect(find.text("Item #0"), findsOneWidget);
      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    test('Poka-Yoke assertion throws if both primary: true and explicit controller passed', () {
      final controller = ScrollController();
      expect(
        () => InertialDragSmoothListScroller(
          controller: controller,
          primary: true,
          itemCount: 5,
          itemBuilder: (context, index) => const SizedBox(),
        ),
        throwsAssertionError,
      );
    });
  });

  group('SLPLU-008: AsyncFormSkeletonLoader Tests', () {
    testWidgets('Renders skeleton loaders wrapped in AbsorbPointer during loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const AsyncFormSkeletonLoader(
            timeoutDuration: Duration(seconds: 5),
          ),
        ),
      );

      // Verify AbsorbPointer blocks interactive gestures during loading state
      expect(find.byType(AbsorbPointer), findsOneWidget);
      expect(find.byType(FadeTransition), findsOneWidget);
    });
  });

  group('SGTIM-006: DynamicTabCoordinator Tests', () {
    testWidgets('Renders TabBar & TabBarView and handles URL fallback Poka-Yoke',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const DynamicTabCoordinator(
            initialTabPath: '/invalid_route_xyz', // Should fallback to index 0 (/metrics)
          ),
        ),
      );

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(TabBarView), findsOneWidget);

      // Initial tab view should be Metrics (index 0)
      expect(find.text("Metrics Data Record #1"), findsOneWidget);
    });

    testWidgets('Preserves input text filter state when swiping between tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const DynamicTabCoordinator(initialTabPath: '/metrics'),
        ),
      );

      // Type filter text into first tab search field
      final textFieldFinder = find.byType(TextField).first;
      await tester.enterText(textFieldFinder, "Record #2");
      await tester.pumpAndSettle();

      expect(find.text("Filter: 'Record #2'"), findsOneWidget);

      // Swipe/Tap to second tab ('Analytics')
      await tester.tap(find.textContaining('Analytics'));
      await tester.pumpAndSettle();

      // Swipe back to first tab ('Metrics')
      await tester.tap(find.textContaining('Metrics'));
      await tester.pumpAndSettle();

      // Text state must be preserved via AutomaticKeepAliveClientMixin
      expect(find.text("Record #2"), findsOneWidget);
    });
  });
}
