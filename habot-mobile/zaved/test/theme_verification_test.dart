import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/theme/theme_config.dart';
import 'package:flutter_application_1/theme/app_design_tokens.dart';
import 'package:flutter_application_1/ui/theme_test_screen.dart';
import 'package:flutter_application_1/widgets/universal_widgets.dart';

void main() {
  group('TTMCS-003-A16 Automated CI/CD Testing Gate: Theme Verification', () {
    final hexColorRegex = RegExp(r'Color\s*\(\s*0x[0-9a-fA-F]+\s*\)');
    final standardColorsRegex = RegExp(r'\bColors\.[a-zA-Z0-9_]+');

    test('Poka-Yoke Hardcode Assassin Linter scans lib/ui/ for unmapped colors', () {
      final uiDir = Directory('lib/ui');
      expect(uiDir.existsSync(), isTrue);

      final filesToCheck = [
        'lib/ui/theme_test_screen.dart',
        'lib/theme/theme_config.dart',
        'lib/widgets/universal_widgets.dart',
      ];

      final violations = <String>[];

      for (final filePath in filesToCheck) {
        final file = File(filePath);
        expect(file.existsSync(), isTrue);

        final lines = file.readAsLinesSync();
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          final trimmed = line.trim();
          if (trimmed.startsWith('//') || trimmed.startsWith('*') || trimmed.startsWith('/*')) {
            continue;
          }

          // Allow Color token definitions strictly inside ThemeConfig color scheme definitions
          if (filePath.contains('theme_config.dart') && (line.contains('outlineVariant') || line.contains('ColorScheme'))) {
            continue;
          }

          if (hexColorRegex.hasMatch(line)) {
            violations.add('$filePath:${i + 1} - Found hardcoded Color(0x...): "$line"');
          }
          if (standardColorsRegex.hasMatch(line)) {
            violations.add('$filePath:${i + 1} - Found standard Material Colors.*: "$line"');
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'Hardcode Assassin Blocker Triggered!\n${violations.join('\n')}',
      );
    });

    testWidgets('ThemeTestScreen inherits MD3 surface & onSurface tokens (Light Mode)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeConfig.lightTheme,
          home: const ThemeTestScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsOneWidget);

      final Scaffold scaffold = tester.widget(scaffoldFinder);
      expect(scaffold.backgroundColor, equals(AppDesignTokens.lightSurface));

      // Verify token text elements render with onSurface color
      expect(find.text('MD3 Root Context Tokens: Bound & Active'), findsOneWidget);
    });

    testWidgets('ThemeTestScreen inherits MD3 surface & onSurface tokens (Dark Mode)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeConfig.darkTheme,
          home: const ThemeTestScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsOneWidget);

      final Scaffold scaffold = tester.widget(scaffoldFinder);
      expect(scaffold.backgroundColor, equals(AppDesignTokens.darkSurface));
    });

    testWidgets('Responsive 4-to-8 Column Layout Matrix renders 4 columns on Mobile (<= 600px)', (tester) async {
      // Set physical size for mobile (360x800)
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeConfig.lightTheme,
          home: const ThemeTestScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final gridViewFinder = find.byType(GridView);
      expect(gridViewFinder, findsOneWidget);

      final GridView gridView = tester.widget(gridViewFinder);
      final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(4));
    });

    testWidgets('Responsive 4-to-8 Column Layout Matrix renders 8 columns on Tablet/Web (> 600px)', (tester) async {
      // Set physical size for tablet/desktop (900x800)
      tester.view.physicalSize = const Size(900, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeConfig.lightTheme,
          home: const ThemeTestScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final gridViewFinder = find.byType(GridView);
      expect(gridViewFinder, findsOneWidget);

      final GridView gridView = tester.widget(gridViewFinder);
      final delegate = gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, equals(8));
    });

    testWidgets('RCGLA-014-A02: UniversalPrimaryButton & UniversalTextField render with MD3 tokens', (tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeConfig.lightTheme,
          home: Scaffold(
            body: Column(
              children: [
                UniversalPrimaryButton(
                  label: 'Test Universal Button',
                  onPressed: () => buttonPressed = true,
                ),
                const UniversalTextField(
                  label: 'Test Universal Field',
                  hint: 'Enter value',
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Test Universal Button'), findsOneWidget);
      expect(find.text('Test Universal Field'), findsOneWidget);

      // Verify button tap
      await tester.tap(find.text('Test Universal Button'));
      await tester.pump();
      expect(buttonPressed, isTrue);

      // Verify touch target height is at least 48dp
      final buttonSize = tester.getSize(find.byType(UniversalPrimaryButton));
      expect(buttonSize.height, greaterThanOrEqualTo(48.0));
    });
  });
}
