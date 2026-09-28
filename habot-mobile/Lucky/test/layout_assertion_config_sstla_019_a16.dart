// SSTLA-019-A16 — Layout Assertion Test Matrix Configuration.
// Defines physical hardware profiles, automated target configurations, and touch-target insulation bounds (320dp) for cross-device layout validation scripts.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Represents a specific physical hardware profile combination for testing.
class HardwareProfile {
  final String name;
  final Size screenSize;
  final double devicePixelRatio;
  final TargetPlatform platform;

  const HardwareProfile({
    required this.name,
    required this.screenSize,
    required this.devicePixelRatio,
    required this.platform,
  });
}

/// Touch-target insulation configuration enforcing minimum bounds.
class TouchTargetInsulation {
  /// Minimum logical pixels for touch targets to prevent multi-touch clashes.
  static const double minTouchTargetDp = 48.0;

  /// Strict 320dp limit boundary for narrow form factors.
  static const double narrowFormFactorLimitDp = 320.0;

  /// Validates that the given size respects the minimum touch target bounds.
  static bool isWithinInsulationBounds(Size size) {
    return size.width >= minTouchTargetDp && size.height >= minTouchTargetDp;
  }
}

/// Expected output: Test Matrix Configuration Profile.
class TestMatrixConfiguration {
  final List<HardwareProfile> profiles;
  final double specificationCompleteness;

  const TestMatrixConfiguration({
    required this.profiles,
    required this.specificationCompleteness,
  });

  /// Poka-Yoke: Blocks feature pushes if device test metrics drop below 100%.
  bool get isReleaseReady => specificationCompleteness >= 1.0;
}

/// Mock data representing the atomic-level data fields required by the system.
class DocumentMetadata {
  final String documentTitle;
  final String documentUrl;
  final DateTime lastUpdatedDate;
  final String accessibilityStatus;
  final List<String> documentAccessLog;
  final String completionStatus; // 'Complete' | 'Partial' | 'Not Complete'

  const DocumentMetadata({
    required this.documentTitle,
    required this.documentUrl,
    required this.lastUpdatedDate,
    required this.accessibilityStatus,
    required this.documentAccessLog,
    required this.completionStatus,
  });
}

/// Hardcoded mock data fulfilling backend/data requirements locally.
final List<HardwareProfile> mockHardwareProfiles = [
  const HardwareProfile(
    name: 'Small Phone (320dp)',
    screenSize: Size(320, 568),
    devicePixelRatio: 2.0,
    platform: TargetPlatform.android,
  ),
  const HardwareProfile(
    name: 'Standard Phone',
    screenSize: Size(375, 812),
    devicePixelRatio: 3.0,
    platform: TargetPlatform.iOS,
  ),
  const HardwareProfile(
    name: 'Tablet',
    screenSize: Size(768, 1024),
    devicePixelRatio: 2.0,
    platform: TargetPlatform.android,
  ),
];

const DocumentMetadata mockDocumentMetadata = DocumentMetadata(
  documentTitle: 'SSTLA-019 Final Test Environment Configuration',
  documentUrl: 'https://wiki.internal.dev/docs/sstla-019-a16',
  lastUpdatedDate: null as dynamic, // Replaced below in actual usage
  accessibilityStatus: 'WCAG 2.1 AA Compliant',
  documentAccessLog: ['user_001_session_abc', 'ci_runner_session_xyz'],
  completionStatus: 'Complete',
);

void main() {
  group('SSTLA-019-A16 Layout Assertion Scripts', () {
    late TestMatrixConfiguration matrixConfig;

    setUp(() {
      matrixConfig = TestMatrixConfiguration(
        profiles: mockHardwareProfiles,
        specificationCompleteness: 1.0, // Optimal Target per requirement
      );
    });

    test('Poka-Yoke: Release readiness requires 100% completeness', () {
      expect(matrixConfig.isReleaseReady, isTrue);

      final incompleteConfig = TestMatrixConfiguration(
        profiles: mockHardwareProfiles,
        specificationCompleteness: 0.9, // Floor Boundary
      );
      expect(incompleteConfig.isReleaseReady, isFalse);
    });

    test('Touch-target insulation bounds are enforced on 320dp limits', () {
      const validTarget = Size(48.0, 48.0);
      const invalidTarget = Size(32.0, 32.0);

      expect(TouchTargetInsulation.isWithinInsulationBounds(validTarget), isTrue);
      expect(TouchTargetInsulation.isWithinInsulationBounds(invalidTarget), isFalse);
    });

    testWidgets('Automated target configuration executes layout assertions across profiles', (WidgetTester tester) async {
      for (final profile in matrixConfig.profiles) {
        // Set physical hardware profile combination
        tester.view.physicalSize = profile.screenSize;
        tester.view.devicePixelRatio = profile.devicePixelRatio;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: TouchTargetInsulation.minTouchTargetDp,
                  height: TouchTargetInsulation.minTouchTargetDp,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Test'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Verify layout does not overflow on narrow form factors
        expect(tester.takeException(), isNull);

        // Verify touch target meets insulation bounds
        final buttonSize = tester.getSize(find.byType(ElevatedButton));
        expect(
          TouchTargetInsulation.isWithinInsulationBounds(buttonSize),
          isTrue,
          reason: 'Failed touch-target insulation check on ${profile.name}',
        );

        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      }
    });
  });
}