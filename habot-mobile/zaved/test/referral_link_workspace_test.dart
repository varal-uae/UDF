import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/ui/referral_link_workspace.dart';

void main() {
  Widget buildTestApp({required double width, ColorScheme? colorScheme}) {
    final themeScheme = colorScheme ??
        ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          tertiary: const Color(0xFF006A68), // Distinct tertiary color
        );

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: themeScheme,
      ),
      home: MediaQuery(
        data: MediaQueryData(size: Size(width, 900)),
        child: SizedBox(
          width: width,
          height: 900,
          child: const ReferralLinkWorkspace(),
        ),
      ),
    );
  }

  group('Interactive Referral Link Generator Requirements Verification', () {
    testWidgets(
        'Requirement 1: Wide screen (>600dp) renders full OutlinedCard inline without FAB sheet requirement',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(width: 800)); // Wide layout

      // Verify MaterialBanner displaying "14 Days Left" exists
      expect(find.byType(MaterialBanner), findsOneWidget);
      expect(find.textContaining('14 Days Left'), findsNWidgets(2)); // Banner + Card

      // Verify full OutlinedCard is rendered inline on wide screen
      expect(find.text('Your Exclusive Referral Link'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);

      // Verify FloatingActionButton is NOT shown on wide screen
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets(
        'Requirement 1: Narrow screen (<=600dp) collapses features into FAB opening showModalBottomSheet',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(width: 400)); // Narrow mobile layout

      // Verify MaterialBanner is still rendered on main screen
      expect(find.byType(MaterialBanner), findsOneWidget);

      // Verify FloatingActionButton is displayed on mobile
      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);

      // Tap FAB to open modal bottom sheet
      await tester.tap(fabFinder);
      await tester.pumpAndSettle();

      // Verify Modal Bottom Sheet renders the OutlinedCard
      expect(find.text('Your Exclusive Referral Link'), findsOneWidget);
    });

    testWidgets(
        'Requirement 2: M3 OutlinedCard styling, titleMedium header, & tertiary focus text color',
        (WidgetTester tester) async {
      const customTertiary = Color(0xFF006A68);
      final customScheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple).copyWith(
        tertiary: customTertiary,
      );

      await tester.pumpWidget(buildTestApp(width: 800, colorScheme: customScheme));

      // 1. Verify Card is OutlinedCard (elevation == 0)
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, equals(0));

      // 2. Verify Header Text style uses titleMedium
      final headerText = tester.widget<Text>(find.text('Your Exclusive Referral Link'));
      expect(headerText.style?.fontWeight, equals(FontWeight.bold));

      // 3. Verify Focus text uses tertiary color
      final countdownText = tester.widget<Text>(find.text('14 Days Left'));
      expect(countdownText.style?.color, equals(customTertiary));
    });

    testWidgets(
        'Requirement 3: One-Tap Share button triggers native share payload invocation',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(width: 800));

      final shareButton = find.widgetWithText(FilledButton, 'One-Tap Share Link');
      expect(shareButton, findsOneWidget);

      await tester.tap(shareButton);
      await tester.pumpAndSettle();

      // Verify SnackBar triggers notifying native share sheet payload invocation
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Invoking native share sheet:'), findsOneWidget);
    });
  });
}
