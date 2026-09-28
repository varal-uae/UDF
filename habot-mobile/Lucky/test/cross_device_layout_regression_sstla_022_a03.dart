// SSTLA-022-A03 — Automated Cross-Device Layout Regression Testing Suite.
// Enforces touch-target padding buffer insulation limits and validates grid alignment across device form factors to prevent visual rendering leaks.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Atomic-level data fields required for test validation outcomes.
class InstallationRecord {
  final String installationId;
  final String installationStatus;
  final DateTime installationTimestamp;
  final Map<String, dynamic> configurationDetails;
  final String systemPath;
  final String completionStatus; // 'Pass' or 'Fail'
  final DateTime actionTimestamp;
  final String userSessionId;

  const InstallationRecord({
    required this.installationId,
    required this.installationStatus,
    required this.installationTimestamp,
    required this.configurationDetails,
    required this.systemPath,
    required this.completionStatus,
    required this.actionTimestamp,
    required this.userSessionId,
  });

  Map<String, dynamic> toJson() => {
        'installation_id': installationId,
        'installation_status': installationStatus,
        'installation_timestamp': installationTimestamp.toIso8601String(),
        'configuration_details': configurationDetails,
        'system_path': systemPath,
        'completion_status': completionStatus,
        'action_timestamp': actionTimestamp.toIso8601String(),
        'user_session_id': userSessionId,
      };
}

/// Mock repository supplying realistic local data for layout regression testing.
class MockLayoutValidationRepository {
  static const double kConfigurationAccuracyFloor = 0.98;
  static const double kConfigurationAccuracyOptimal = 1.0;
  static const double kMinimumTouchTargetPadding = 8.0;

  static List<InstallationRecord> getMockRecords() {
    return [
      InstallationRecord(
        installationId: 'INST-001',
        installationStatus: 'ACTIVE',
        installationTimestamp: DateTime(2026, 9, 28, 10, 0),
        configurationDetails: {'device_type': 'smartphone', 'os': 'android'},
        systemPath: '/udf/presentation/screens/main',
        completionStatus: 'Pass',
        actionTimestamp: DateTime(2026, 9, 28, 10, 5),
        userSessionId: 'SESS-999',
      ),
      InstallationRecord(
        installationId: 'INST-002',
        installationStatus: 'ACTIVE',
        installationTimestamp: DateTime(2026, 9, 28, 10, 10),
        configurationDetails: {'device_type': 'tablet', 'os': 'ios'},
        systemPath: '/udf/presentation/screens/detail',
        completionStatus: 'Pass',
        actionTimestamp: DateTime(2026, 9, 28, 10, 15),
        userSessionId: 'SESS-999',
      ),
    ];
  }

  /// Calculates configuration accuracy rate against the ITIL CMDB floor target.
  static double calculateConfigurationAccuracy(List<InstallationRecord> records) {
    if (records.isEmpty) return 0.0;
    final int passedCount = records.where((r) => r.completionStatus == 'Pass').length;
    return passedCount / records.length;
  }

  /// Poka-Yoke: Blocks feature pushes if metrics drop below 100% optimal target.
  static bool isFeaturePushAllowed(double accuracyRate) {
    return accuracyRate >= kConfigurationAccuracyOptimal;
  }
}

/// Test widget simulating a multi-touch smartphone layout with strict padding buffers.
class LayoutRegressionTestWidget extends StatelessWidget {
  const LayoutRegressionTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(MockLayoutValidationRepository.kMinimumTouchTargetPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('UDF Layout Regression Target', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: MockLayoutValidationRepository.kMinimumTouchTargetPadding,
                  runSpacing: MockLayoutValidationRepository.kMinimumTouchTargetPadding,
                  children: [
                    ElevatedButton(
                      key: const Key('touch_target_1'),
                      onPressed: () {},
                      child: const Text('Action 1'),
                    ),
                    ElevatedButton(
                      key: const Key('touch_target_2'),
                      onPressed: () {},
                      child: const Text('Action 2'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  group('SSTLA-022-A03 Automated Cross-Device Layout Regression Tests', () {
    testWidgets('Enforces touch-target padding buffer insulation limits', (WidgetTester tester) async {
      await tester.pumpWidget(const LayoutRegressionTestWidget());

      final Rect rect1 = tester.getRect(find.byKey(const Key('touch_target_1')));
      final Rect rect2 = tester.getRect(find.byKey(const Key('touch_target_2')));

      // Verify that interactive elements never overlap
      expect(rect1.overlaps(rect2), isFalse, reason: 'Touch targets must not overlap to prevent conflicting click actions.');

      // Verify minimum padding buffer between elements
      if (rect1.right < rect2.left) {
        final double horizontalGap = rect2.left - rect1.right;
        expect(horizontalGap, greaterThanOrEqualTo(MockLayoutValidationRepository.kMinimumTouchTargetPadding));
      }
    });

    testWidgets('Validates layout renders cleanly across constrained form factors', (WidgetTester tester) async {
      // Simulate small smartphone screen
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const LayoutRegressionTestWidget());

      expect(find.text('UDF Layout Regression Target'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNWidgets(2));
      expect(tester.takeException(), isNull, reason: 'No overflow or rendering exceptions should occur.');
    });

    test('Configuration Accuracy Rate meets ITIL CMDB floor boundary (>= 0.98)', () {
      final records = MockLayoutValidationRepository.getMockRecords();
      final accuracy = MockLayoutValidationRepository.calculateConfigurationAccuracy(records);

      expect(accuracy, greaterThanOrEqualTo(MockLayoutValidationRepository.kConfigurationAccuracyFloor));
    });

    test('Poka-Yoke version distribution blocks feature push if metrics are suboptimal', () {
      expect(MockLayoutValidationRepository.isFeaturePushAllowed(1.0), isTrue);
      expect(MockLayoutValidationRepository.isFeaturePushAllowed(0.99), isFalse);
      expect(MockLayoutValidationRepository.isFeaturePushAllowed(0.95), isFalse);
    });

    test('Atomic-level data fields serialize correctly for BigQuery routing', () {
      final records = MockLayoutValidationRepository.getMockRecords();
      final jsonOutput = records.first.toJson();

      expect(jsonOutput.containsKey('installation_id'), isTrue);
      expect(jsonOutput.containsKey('installation_status'), isTrue);
      expect(jsonOutput.containsKey('installation_timestamp'), isTrue);
      expect(jsonOutput.containsKey('configuration_details'), isTrue);
      expect(jsonOutput.containsKey('system_path'), isTrue);
      expect(jsonOutput.containsKey('completion_status'), isTrue);
      expect(jsonOutput['completion_status'], isIn(['Pass', 'Fail']));
    });
  });
}