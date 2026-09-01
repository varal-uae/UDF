import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/theme/app_design_tokens.dart';
import 'package:flutter_application_1/theme/app_theme.dart';
import 'package:flutter_application_1/widgets/responsive_grid_wrapper.dart';
import 'package:flutter_application_1/ui/responsive_grid_wrapper_workspace.dart';

void main() {
  group('TTMCS-003-A10 Architecture Linter & Hardcode Assassin Gate', () {
    final hexColorRegex = RegExp(r'Color\s*\(\s*0x[0-9a-fA-F]+\s*\)');
    final rawColorsRegex = RegExp(r'\bColors\.[a-zA-Z0-9_]+');

    test('Linter script accurately detects unmapped raw colors and hardcoded hex values', () {
      const sampleViolatingCode = '''
        Container(color: Color(0xFF123456));
        Text("Sample", style: TextStyle(color: Colors.red));
      ''';
      const sampleCompliantCode = '''
        Container(color: Theme.of(context).colorScheme.primary);
      ''';

      expect(hexColorRegex.hasMatch(sampleViolatingCode), isTrue);
      expect(rawColorsRegex.hasMatch(sampleViolatingCode), isTrue);

      expect(hexColorRegex.hasMatch(sampleCompliantCode), isFalse);
      expect(rawColorsRegex.hasMatch(sampleCompliantCode), isFalse);
    });

    test('New TTMCS-003-A10 source files have 100% theme token adherence (zero raw colors)', () {
      final targetFiles = [
        'lib/main.dart',
        'lib/navigation/app_router.dart',
        'lib/widgets/responsive_grid_wrapper.dart',
        'lib/ui/responsive_grid_wrapper_workspace.dart',
      ];

      final violations = <String>[];

      for (final filePath in targetFiles) {
        final file = File(filePath);
        expect(file.existsSync(), isTrue, reason: 'File $filePath must exist');

        final lines = file.readAsLinesSync();
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          final trimmed = line.trim();
          if (trimmed.startsWith('//') || trimmed.startsWith('*') || trimmed.startsWith('/*')) {
            continue;
          }

          if (hexColorRegex.hasMatch(line)) {
            violations.add('$filePath:${i + 1} - Found hardcoded Color(0x...): "$line"');
          }
          if (rawColorsRegex.hasMatch(line)) {
            violations.add('$filePath:${i + 1} - Found raw standard Colors.* constant: "$line"');
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'Hardcode Assassin Blocker Triggered!\n${violations.join('\n')}',
      );
    });
  });

  group('TTMCS-003-A10 Root MaterialApp.router & MD3 Theme Injection Tests', () {
    testWidgets('MyApp initializes with MaterialApp.router and MD3 Theme enabled', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(milliseconds: 100));

      // Find the MaterialApp.router root widget
      final materialAppFinder = find.byType(MaterialApp);
      expect(materialAppFinder, findsOneWidget);

      final materialApp = tester.widget<MaterialApp>(materialAppFinder);
      expect(materialApp.theme?.useMaterial3, isTrue);
      expect(materialApp.darkTheme?.useMaterial3, isTrue);

      // Verify tokenized colorScheme mappings (surface and onSurface representing md.sys.color.background)
      expect(materialApp.theme?.colorScheme.surface, equals(AppTheme.lightPrimary == AppDesignTokens.lightPrimary ? AppDesignTokens.lightSurface : AppDesignTokens.surface));
      expect(materialApp.theme?.colorScheme.onSurface, equals(AppDesignTokens.lightOnSurface));
      expect(materialApp.darkTheme?.colorScheme.surface, equals(AppDesignTokens.darkSurface));
      expect(materialApp.darkTheme?.colorScheme.onSurface, equals(AppDesignTokens.darkOnSurface));
    });

    testWidgets('MyApp supports theme mode toggle from context', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(milliseconds: 100));

      final myAppState = tester.state<MyAppState>(find.byType(MyApp));
      expect(myAppState.themeMode, equals(ThemeMode.light));

      myAppState.toggleThemeMode();
      await tester.pump(const Duration(milliseconds: 100));
      expect(myAppState.themeMode, equals(ThemeMode.dark));

      myAppState.toggleThemeMode();
      await tester.pump(const Duration(milliseconds: 100));
      expect(myAppState.themeMode, equals(ThemeMode.light));
    });
  });

  group('TTMCS-003-A10 Programmatic 4-to-8 Column Responsive Grid Matrix Tests', () {
    test('ResponsiveGridMetrics programmatically calculates Mobile (<= 600px) 4-column matrix', () {
      final metrics360 = ResponsiveGridMetrics.fromWidth(360.0);
      expect(metrics360.columns, equals(4));
      expect(metrics360.margin, equals(16.0));
      expect(metrics360.gutter, equals(8.0));
      // Available width = 360 - 32 = 328
      // Gutters = 3 * 8 = 24
      // Column width = (328 - 24) / 4 = 304 / 4 = 76.0
      expect(metrics360.availableWidth, equals(328.0));
      expect(metrics360.columnWidth, equals(76.0));
      expect(metrics360.widthForSpan(1), equals(76.0));
      // 2-span: (2 * 76) + 8 = 160.0
      expect(metrics360.widthForSpan(2), equals(160.0));
      // 4-span: (4 * 76) + (3 * 8) = 304 + 24 = 328.0 (Full available width)
      expect(metrics360.widthForSpan(4), equals(328.0));
    });

    test('ResponsiveGridMetrics programmatically calculates Tablet/Web (> 600px) 8-column matrix', () {
      final metrics840 = ResponsiveGridMetrics.fromWidth(840.0);
      expect(metrics840.columns, equals(8));
      expect(metrics840.margin, equals(24.0));
      expect(metrics840.gutter, equals(16.0));
      // Available width = 840 - 48 = 792.0
      // Total gutters = 7 * 16 = 112.0
      // Column width = (792 - 112) / 8 = 680 / 8 = 85.0
      expect(metrics840.availableWidth, equals(792.0));
      expect(metrics840.columnWidth, equals(85.0));
      expect(metrics840.widthForSpan(1), equals(85.0));
      // 4-span (half width): (4 * 85) + (3 * 16) = 340 + 48 = 388.0
      expect(metrics840.widthForSpan(4), equals(388.0));
      // 8-span (full width): (8 * 85) + (7 * 16) = 680 + 112 = 792.0 (Full available width)
      expect(metrics840.widthForSpan(8), equals(792.0));
    });

    testWidgets('ResponsiveGridWrapper renders 4 columns on mobile viewport (400px)', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: ResponsiveGridWrapper(
              children: List.generate(4, (index) {
                return ResponsiveGridItem(
                  span: 1,
                  child: Text('Col #$index'),
                );
              }),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Col #0'), findsOneWidget);
      expect(find.text('Col #3'), findsOneWidget);
    });

    testWidgets('ResponsiveGridWrapperWorkspace renders and operates slider controls', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const ResponsiveGridWrapperWorkspace(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('4-to-8 Column Grid Matrix (TTMCS-003-A10)'), findsOneWidget);
      expect(find.text('Live Grid Metrics Telemetry'), findsOneWidget);
      expect(find.text('360px (Mobile)'), findsOneWidget);
      expect(find.text('840px (Tablet/Web)'), findsOneWidget);

      // Tap 840px button
      await tester.tap(find.text('840px (Tablet/Web)'));
      await tester.pumpAndSettle();

      expect(find.textContaining('8 Columns (Tablet/Web)'), findsOneWidget);
    });
  });
}
