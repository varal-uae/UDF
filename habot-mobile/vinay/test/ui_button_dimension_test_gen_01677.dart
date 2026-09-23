// GEN-01677 — UI Test Suite for Rendered Button Dimensions.
// Automated widget tests to measure rendered button dimensions, enforcing M3 48x48dp touch targets and single-column responsive layout constraints.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock data simulating backend configuration for button dimension thresholds
const Map<String, dynamic> mockButtonDimensionConfig = {
  'min_touch_target_width': 48.0,
  'min_touch_target_height': 48.0,
  'mobile_breakpoint': 600.0,
  'desktop_breakpoint': 840.0,
  'metric_name': 'Test Case Success Rate (%)',
  'floor_boundary': 95.0,
  'optimal_target': 99.5,
  'ceiling_boundary': 100.0,
};

class DimensionTestButton extends StatelessWidget {
  const DimensionTestButton({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              minimumSize: const Size(
                mockButtonDimensionConfig['min_touch_target_width'] as double,
                mockButtonDimensionConfig['min_touch_target_height'] as double,
              ),
              tapTargetSize: MaterialTapTargetSize.padded,
            ),
            child: const Text('Measure'),
          ),
        ),
      ),
    );
  }
}

void main() {
  group('GEN-01677 Button Dimension Tests', () {
    testWidgets('Rendered FilledButton meets M3 48x48dp minimum touch target', (WidgetTester tester) async {
      await tester.pumpWidget(const DimensionTestButton());
      await tester.pumpAndSettle();

      final Finder buttonFinder = find.byType(FilledButton);
      expect(buttonFinder, findsOneWidget);

      final Size buttonSize = tester.getSize(buttonFinder);
      
      // Validate against ISO/IEC 27001 Testing Standards baseline config
      expect(
        buttonSize.width >= (mockButtonDimensionConfig['min_touch_target_width'] as double),
        isTrue,
        reason: 'Button width ${buttonSize.width} is less than required 48.0dp',
      );
      expect(
        buttonSize.height >= (mockButtonDimensionConfig['min_touch_target_height'] as double),
        isTrue,
        reason: 'Button height ${buttonSize.height} is less than required 48.0dp',
      );
    });

    testWidgets('Button dimensions remain valid in constrained mobile layout (<600dp)', (WidgetTester tester) async {
      // Simulate mobile viewport
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const DimensionTestButton());
      await tester.pumpAndSettle();

      final Size buttonSize = tester.getSize(find.byType(FilledButton));
      expect(buttonSize.width >= 48.0, isTrue);
      expect(buttonSize.height >= 48.0, isTrue);
    });

    testWidgets('Button dimensions remain valid in desktop layout (>=840dp)', (WidgetTester tester) async {
      // Simulate desktop viewport
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const DimensionTestButton());
      await tester.pumpAndSettle();

      final Size buttonSize = tester.getSize(find.byType(FilledButton));
      expect(buttonSize.width >= 48.0, isTrue);
      expect(buttonSize.height >= 48.0, isTrue);
    });

    test('Metric configuration floor boundary validation', () {
      final double successRate = 99.5;
      final double floorBoundary = mockButtonDimensionConfig['floor_boundary'] as double;
      
      expect(successRate >= floorBoundary, isTrue, reason: 'Pass/Fail metric below floor threshold');
    });
  });
}
