import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/ui/payload_upload_widget.dart';

void main() {
  Widget buildTestWidget({ColorScheme? customColorScheme}) {
    final colorScheme = customColorScheme ??
        ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          errorContainer: const Color(0xFFFFDDAD), // Custom test errorContainer
          onErrorContainer: const Color(0xFF3E1200), // Custom test onErrorContainer
        );

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
      ),
      home: const Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: PayloadUploadWidget(),
          ),
        ),
      ),
    );
  }

  group('PayloadUploadWidget Requirements Verification', () {
    testWidgets(
        'Requirement 1 & 2: Atomic State Lock disables button and shows CircularProgressIndicator while processing',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Verify upload button initially exists
      final buttonFinder = find.widgetWithText(FilledButton, 'Upload Payload to Gateway');
      expect(buttonFinder, findsOneWidget);

      // Tap button to trigger upload process
      await tester.tap(buttonFinder);
      await tester.pump(); // Trigger setState for _isProcessing = true

      // Verify CircularProgressIndicator is displayed
      expect(find.byType(CircularProgressIndicator), findsNWidgets(2));

      // Verify button is disabled while processing
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);

      // Complete async simulation
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets(
        'Requirement 3 & 4: Payload over limit triggers SnackBar and AlertDialog with exact error text & M3 error tokens',
        (WidgetTester tester) async {
      const testErrorContainer = Color(0xFFFFD2D2);
      const testOnErrorContainer = Color(0xFF680003);

      final customScheme = ColorScheme.fromSeed(seedColor: Colors.blue).copyWith(
        errorContainer: testErrorContainer,
        onErrorContainer: testOnErrorContainer,
      );

      await tester.pumpWidget(buildTestWidget(customColorScheme: customScheme));

      // Tap upload button
      await tester.tap(find.widgetWithText(FilledButton, 'Upload Payload to Gateway'));
      await tester.pump();

      // Wait for network simulation to trigger errors
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();

      // 1. Verify SnackBar exact error message
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Sending failed: payload over limit'), findsNWidgets(2)); // 1 in SnackBar, 1 in AlertDialog

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, equals(testErrorContainer));

      // 2. Verify AlertDialog display and M3 tokens
      expect(find.byType(AlertDialog), findsOneWidget);
      final alertDialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
      expect(alertDialog.backgroundColor, equals(testErrorContainer));
    });

    testWidgets(
        'Requirement 5: Displays Material Card with 16dp padding and KPI Table for Dropped Packets',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Verify Card and DataTable presence
      expect(find.byType(Card), findsNWidgets(2));
      expect(find.byType(DataTable), findsOneWidget);

      // Verify 'Dropped Packets' KPI metric text
      expect(find.text('Dropped Packets'), findsOneWidget);

      // Verify 8dp grid system (16.0 padding) on Card
      final cardPaddings = tester.widgetList<Padding>(find.descendant(
        of: find.byType(Card),
        matching: find.byType(Padding),
      ));

      final has16dpPadding = cardPaddings.any((padding) => padding.padding == const EdgeInsets.all(16.0));
      expect(has16dpPadding, isTrue);
    });
  });
}
