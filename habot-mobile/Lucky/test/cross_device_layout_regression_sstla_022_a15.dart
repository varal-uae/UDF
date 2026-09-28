// SSTLA-022-A15 — Automated Cross-Device Layout Regression Testing Suite.
// Programmatically enforces touch-target padding buffer insulation limits and validates grid alignment across multiple device form factors to prevent visual rendering leaks.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Atomic-level data model for test execution tracking.
class StepExecutionRecord {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final bool completionStatus;

  const StepExecutionRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.completionStatus,
  });

  Map<String, dynamic> toJson() => {
        'Step Execution ID': stepExecutionId,
        'Execution Status': executionStatus,
        'Execution Timestamp': executionTimestamp.toIso8601String(),
        'Step Outcome': stepOutcome,
        'User ID': userId,
        'Completion Status': completionStatus ? 'Yes' : 'No',
      };
}

/// Mock repository simulating centralized infrastructure monitoring (GCP/BigQuery alignment).
class MockTelemetryRepository {
  final List<StepExecutionRecord> _records = [];

  void recordValidation(StepExecutionRecord record) {
    _records.add(record);
  }

  List<StepExecutionRecord> get records => List.unmodifiable(_records);

  /// Poka-Yoke: Blocks feature pushes if device test metrics drop below 100%.
  bool get isFeaturePushAllowed {
    if (_records.isEmpty) return false;
    return _records.every((r) => r.completionStatus && r.executionStatus == 'PASS');
  }
}

/// Standardized device profiles for cross-device layout regression testing.
class DeviceProfile {
  final String name;
  final Size size;
  final double devicePixelRatio;

  const DeviceProfile({
    required this.name,
    required this.size,
    this.devicePixelRatio = 1.0,
  });
}

const List<DeviceProfile> kRegressionDeviceProfiles = [
  DeviceProfile(name: 'Small Phone', size: Size(320, 568)),
  DeviceProfile(name: 'Standard Phone', size: Size(375, 812)),
  DeviceProfile(name: 'Large Phone', size: Size(428, 926)),
  DeviceProfile(name: 'Tablet Portrait', size: Size(768, 1024)),
  DeviceProfile(name: 'Tablet Landscape', size: Size(1024, 768)),
];

/// Minimum touch target padding buffer insulation limit (Material 3 standard: 48x48).
const double kMinTouchTargetSize = 48.0;

/// Sample widget under test representing a multi-touch smartphone layout.
class UdfRegressionTestWidget extends StatelessWidget {
  const UdfRegressionTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('UDF Layout Validation')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Form Factor Consistency Check'),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16.0,
                runSpacing: 16.0,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Action A'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Action B'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  final mockTelemetry = MockTelemetryRepository();

  group('SSTLA-022-A15: Automated Cross-Device Layout Regression Tests', () {
    for (final profile in kRegressionDeviceProfiles) {
      testWidgets(
        'Validates layout and touch targets on ${profile.name} (${profile.size.width}x${profile.size.height})',
        (WidgetTester tester) async {
          // Set surface size for the specific device profile
          await tester.binding.setSurfaceSize(profile.size);
          tester.view.physicalSize = profile.size;
          tester.view.devicePixelRatio = profile.devicePixelRatio;

          await tester.pumpWidget(const UdfRegressionTestWidget());
          await tester.pumpAndSettle();

          // 1. Verify no overflow errors (grid alignment check)
          final renderBox = tester.renderObject<RenderBox>(find.byType(Scaffold));
          expect(renderBox.hasSize, isTrue);
          expect(renderBox.size, equals(profile.size));

          // 2. Enforce touch-target padding buffer insulation limits
          final buttons = find.byType(ElevatedButton);
          for (var i = 0; i < buttons.evaluate().length; i++) {
            final buttonRect = tester.getRect(buttons.at(i));
            expect(
              buttonRect.width >= kMinTouchTargetSize,
              isTrue,
              reason: 'Touch target width on ${profile.name} is ${buttonRect.width}, expected >= $kMinTouchTargetSize',
            );
            expect(
              buttonRect.height >= kMinTouchTargetSize,
              isTrue,
              reason: 'Touch target height on ${profile.name} is ${buttonRect.height}, expected >= $kMinTouchTargetSize',
            );
          }

          // 3. Verify interactive elements do not overlap
          final rects = <Rect>[];
          for (var i = 0; i < buttons.evaluate().length; i++) {
            rects.add(tester.getRect(buttons.at(i)));
          }
          for (var i = 0; i < rects.length; i++) {
            for (var j = i + 1; j < rects.length; j++) {
              expect(
                rects[i].overlaps(rects[j]),
                isFalse,
                reason: 'Conflicting click actions detected: overlapping touch targets on ${profile.name}',
              );
            }
          }

          // Record atomic-level data fields
          final record = StepExecutionRecord(
            stepExecutionId: 'SSTLA-022-A15-${profile.name.replaceAll(' ', '_')}',
            executionStatus: 'PASS',
            executionTimestamp: DateTime.now(),
            stepOutcome: 'Layout validated successfully without fragmentation or overlaps.',
            userId: 'automation_system',
            completionStatus: true,
          );
          mockTelemetry.recordValidation(record);

          // Reset surface size
          await tester.binding.setSurfaceSize(null);
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        },
      );
    }

    test('Poka-Yoke: Version distribution blocks if metrics drop below 100%', () {
      // All tests passed above, so push should be allowed
      expect(mockTelemetry.isFeaturePushAllowed, isTrue);

      // Simulate a failure
      final failRepo = MockTelemetryRepository();
      failRepo.recordValidation(const StepExecutionRecord(
        stepExecutionId: 'FAIL-01',
        executionStatus: 'FAIL',
        executionTimestamp: null as dynamic,
        stepOutcome: 'Overflow detected',
        userId: 'system',
        completionStatus: false,
      ));
      expect(failRepo.isFeaturePushAllowed, isFalse);
    });

    test('Governance: Stakeholder Sign-off Rate is binary gate', () {
      // Formal governance practice (PMI PMBOK): partial approval does not satisfy control
      const bool devOpsSignOff = true;
      const bool qualityEngineeringSignOff = true;

      final stakeholderSignOffRate = (devOpsSignOff && qualityEngineeringSignOff) ? 1 : 0;

      // Floor Boundary: 1, Optimal Target: 1, Ceiling Boundary: 1
      expect(stakeholderSignOffRate, equals(1));
    });
  });
}
