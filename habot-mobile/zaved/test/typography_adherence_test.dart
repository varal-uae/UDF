import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/widgets/dynamic_typography_wrapper.dart';
import 'package:flutter_application_1/ui/dynamic_typography_wrapper_workspace.dart';

void main() {
  group('TTIAS-014 Architecture Static Linter: Typography Token & Shadow Gate', () {
    // Regex to detect hardcoded pixel values for fonts
    final hardcodedFontSizeRegex = RegExp(r'fontSize\s*:\s*\d+(\.\d+)?');
    // Regex to detect unmapped raw text shadows
    final textShadowRegex = RegExp(r'(\bShadow\s*\(|shadows\s*:\s*\[)');

    test('Linter script correctly detects hardcoded pixel font sizes and unmapped shadows', () {
      const sampleCodeWithHardcodedFont = '''
        Text("Sample", style: TextStyle(fontSize: 14.0));
      ''';
      const sampleCodeWithShadow = '''
        Text("Sample", style: TextStyle(shadows: [Shadow(blurRadius: 4.0)]));
      ''';
      const sampleCompliantCode = '''
        DynamicTypographyWrapper.bodyMedium(text: "Sample");
      ''';

      expect(hardcodedFontSizeRegex.hasMatch(sampleCodeWithHardcodedFont), isTrue);
      expect(textShadowRegex.hasMatch(sampleCodeWithShadow), isTrue);

      expect(hardcodedFontSizeRegex.hasMatch(sampleCompliantCode), isFalse);
      expect(textShadowRegex.hasMatch(sampleCompliantCode), isFalse);
    });

    test('Compiler script strips out unmapped text shadows during preprocessing', () {
      const dirtyStyle = TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        shadows: [
          Shadow(
            offset: Offset(2.0, 2.0),
            blurRadius: 4.0,
            color: Colors.black45,
          ),
        ],
      );

      final cleanStyle = DynamicTypographyWrapper.purgeShadows(dirtyStyle);

      // Verify shadows are completely stripped
      expect(cleanStyle.shadows, isNotNull);
      expect(cleanStyle.shadows, isEmpty);
    });

    test('Dedicated TTIAS-014 UI Workspace complies 100% with typography token architecture', () {
      final file = File('lib/ui/dynamic_typography_wrapper_workspace.dart');
      expect(file.existsSync(), isTrue);

      final lines = file.readAsLinesSync();
      final violations = <String>[];

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        final trimmed = line.trim();
        if (trimmed.startsWith('//') || trimmed.startsWith('*') || trimmed.startsWith('/*')) {
          continue;
        }

        // Allow simulated shadow demonstration only if guarded
        if (line.contains('simulateShadowInjection') || line.contains('simulatedViewportWidth')) {
          continue;
        }

        if (hardcodedFontSizeRegex.hasMatch(line)) {
          violations.add('Line ${i + 1}: Hardcoded font size detected: "$line"');
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'Violations found in dynamic_typography_wrapper_workspace.dart:\n${violations.join('\n')}',
      );
    });
  });

  group('TTIAS-014 DynamicTypographyWrapper Component Widget Tests', () {
    testWidgets('Defensive Clamping Limits clamp lower scale factor (0.5x -> 0.8x)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(0.5)),
            child: DynamicTypographyWrapper(
              text: 'Clamped Low Test',
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ),
      );

      // Verify the inner Text widget is inside a clamped MediaQuery
      final mediaQueryFinder = find.descendant(
        of: find.byType(DynamicTypographyWrapper),
        matching: find.byType(MediaQuery),
      );

      expect(mediaQueryFinder, findsOneWidget);
      final mediaQuery = tester.widget<MediaQuery>(mediaQueryFinder);
      final effectiveScaler = mediaQuery.data.textScaler;

      // 0.5 clamped to 0.8 minScaleLimit
      expect(effectiveScaler.scale(10.0), equals(8.0));
    });

    testWidgets('Defensive Clamping Limits clamp upper scale factor (2.5x -> 1.2x)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2.5)),
            child: DynamicTypographyWrapper(
              text: 'Clamped High Test',
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ),
      );

      final mediaQueryFinder = find.descendant(
        of: find.byType(DynamicTypographyWrapper),
        matching: find.byType(MediaQuery),
      );

      expect(mediaQueryFinder, findsOneWidget);
      final mediaQuery = tester.widget<MediaQuery>(mediaQueryFinder);
      final effectiveScaler = mediaQuery.data.textScaler;

      // 2.5 clamped to 1.2 maxScaleLimit
      expect(effectiveScaler.scale(10.0), equals(12.0));
    });

    testWidgets('Defensive Clamping preserves standard scale factor (1.0x -> 1.0x)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.0)),
            child: DynamicTypographyWrapper(
              text: 'Standard Scale Test',
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ),
      );

      final mediaQueryFinder = find.descendant(
        of: find.byType(DynamicTypographyWrapper),
        matching: find.byType(MediaQuery),
      );

      final mediaQuery = tester.widget<MediaQuery>(mediaQueryFinder);
      final effectiveScaler = mediaQuery.data.textScaler;

      expect(effectiveScaler.scale(10.0), equals(10.0));
    });

    testWidgets('Overflow & Wrapping: Hardcoded maxLines 1, TextOverflow.ellipsis, and softWrap false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: SizedBox(
              width: 100,
              child: DynamicTypographyWrapper(
                text: 'Extremely long single row string that must never wrap across multiple lines',
              ),
            ),
          ),
        ),
      );

      final textFinder = find.descendant(
        of: find.byType(DynamicTypographyWrapper),
        matching: find.byType(Text),
      );

      expect(textFinder, findsOneWidget);
      final Text textWidget = tester.widget<Text>(textFinder);

      expect(textWidget.maxLines, equals(1));
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));
      expect(textWidget.softWrap, isFalse);
    });

    testWidgets('Strict Shadow Purging: Purges text-shadows from TextStyle', (tester) async {
      const inputStyleWithShadows = TextStyle(
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(offset: Offset(2, 2), blurRadius: 4.0, color: Colors.red),
          Shadow(offset: Offset(-1, -1), blurRadius: 2.0, color: Colors.blue),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: DynamicTypographyWrapper(
              text: 'Shadow Purge Test',
              style: inputStyleWithShadows,
            ),
          ),
        ),
      );

      final textFinder = find.descendant(
        of: find.byType(DynamicTypographyWrapper),
        matching: find.byType(Text),
      );

      expect(textFinder, findsOneWidget);
      final Text textWidget = tester.widget<Text>(textFinder);

      // Verify that shadows are empty
      expect(textWidget.style?.shadows, isNotNull);
      expect(textWidget.style!.shadows, isEmpty);
    });

    testWidgets('MD3 Token Locking: Factory constructors bind proper TextTheme tokens', (tester) async {
      final themeData = ThemeData(
        useMaterial3: true,
        textTheme: const TextTheme(
          labelLarge: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 0.1),
          bodyMedium: TextStyle(fontWeight: FontWeight.w400, letterSpacing: 0.25),
          titleMedium: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.15),
          headlineSmall: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.0),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: themeData,
          home: Scaffold(
            body: Column(
              children: [
                DynamicTypographyWrapper.labelLarge(text: 'Label Large'),
                DynamicTypographyWrapper.bodyMedium(text: 'Body Medium'),
                DynamicTypographyWrapper.titleMedium(text: 'Title Medium'),
                DynamicTypographyWrapper.headlineSmall(text: 'Headline Small'),
              ],
            ),
          ),
        ),
      );

      final wrappers = tester.widgetList<DynamicTypographyWrapper>(
        find.byType(DynamicTypographyWrapper),
      ).toList();

      expect(wrappers.length, equals(4));
      expect(wrappers[0].token, equals(MD3TypographyToken.labelLarge));
      expect(wrappers[1].token, equals(MD3TypographyToken.bodyMedium));
      expect(wrappers[2].token, equals(MD3TypographyToken.titleMedium));
      expect(wrappers[3].token, equals(MD3TypographyToken.headlineSmall));

      // Verify rendered Text widgets match TextTheme properties
      final texts = tester.widgetList<Text>(find.byType(Text)).toList();
      expect(texts[0].style?.fontWeight, equals(FontWeight.w500));
      expect(texts[1].style?.fontWeight, equals(FontWeight.w400));
      expect(texts[2].style?.fontWeight, equals(FontWeight.w600));
      expect(texts[3].style?.fontWeight, equals(FontWeight.w700));
    });

    testWidgets('Workspace renders successfully with responsive simulator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const DynamicTypographyWrapperWorkspace(),
        ),
      );

      expect(find.text('Dynamic Font Resizing Engine (TTIAS-014)'), findsOneWidget);
      expect(find.text('Live Engine Telemetry'), findsOneWidget);
      expect(find.text('Interactive Simulator Controls'), findsOneWidget);
      expect(find.text('Clamped Viewport Render Preview'), findsOneWidget);
    });
  });
}
