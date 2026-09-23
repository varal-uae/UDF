// ONLSC-008-15 — Material 3 Touch Target Size Compliance Validator.
// Enforces WCAG 2.2 SC 2.5.8 and Material Design 3 touch target guidelines with floor (44dp), optimal (48dp), and ceiling (56dp+) boundaries, including an execution interceptor for dirty data entries.

import 'package:flutter/material.dart';

/// Enum representing the qualitative outcome of the touch target compliance check.
enum ComplianceOutcome {
  pass,
  fail,
}

/// Data class capturing atomic-level execution fields as required by ONLSC-008-15.
class StepExecutionRecord {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final ComplianceOutcome stepOutcome;
  final String userId;
  final String completionStatus;
  final DateTime actionTimestamp;
  final String sessionId;

  const StepExecutionRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.completionStatus,
    required this.actionTimestamp,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() => {
        'Step Execution ID': stepExecutionId,
        'Execution Status': executionStatus,
        'Execution Timestamp': executionTimestamp.toIso8601String(),
        'Step Outcome': stepOutcome.name,
        'User ID': userId,
        'Completion Status': completionStatus,
        'Action/Event Timestamp': actionTimestamp.toIso8601String(),
        'User/Session ID': sessionId,
      };
}

/// Interceptor listener that captures user un-synchronized (dirty) data typing entries.
class DirtyDataInterceptorListener {
  final List<Map<String, dynamic>> _dirtyEntries = [];

  void captureDirtyEntry(String fieldId, dynamic rawValue) {
    _dirtyEntries.add({
      'fieldId': fieldId,
      'rawValue': rawValue,
      'timestamp': DateTime.now().toIso8601String(),
      'synced': false,
    });
  }

  List<Map<String, dynamic>> get pendingEntries => List.unmodifiable(_dirtyEntries);

  void clearSynced() {
    _dirtyEntries.removeWhere((entry) => entry['synced'] == true);
  }
}

/// Core validator enforcing Material 3 and WCAG 2.2 SC 2.5.8 touch target constraints.
class TouchTargetComplianceValidator {
  /// Floor boundary: 44dp minimum
  static const double floorBoundaryDp = 44.0;

  /// Optimal target: 48dp
  static const double optimalTargetDp = 48.0;

  /// Ceiling boundary: 56dp+
  static const double ceilingBoundaryDp = 56.0;

  final DirtyDataInterceptorListener interceptor;

  TouchTargetComplianceValidator({required this.interceptor});

  /// Evaluates a given touch target size in logical pixels (dp).
  /// Returns [ComplianceOutcome.pass] if >= 48dp, else [ComplianceOutcome.fail].
  ComplianceOutcome evaluate(double sizeDp) {
    if (sizeDp >= optimalTargetDp) {
      return ComplianceOutcome.pass;
    }
    return ComplianceOutcome.fail;
  }

  /// Generates a detailed execution record for telemetry and pipeline reconciliation.
  StepExecutionRecord generateExecutionRecord({
    required String stepExecutionId,
    required String userId,
    required String sessionId,
    required double evaluatedSizeDp,
  }) {
    final outcome = evaluate(evaluatedSizeDp);
    final now = DateTime.now();

    // Capture unsynchronized dirty data if validation fails
    if (outcome == ComplianceOutcome.fail) {
      interceptor.captureDirtyEntry(stepExecutionId, evaluatedSizeDp);
    }

    return StepExecutionRecord(
      stepExecutionId: stepExecutionId,
      executionStatus: 'COMPLETED',
      executionTimestamp: now,
      stepOutcome: outcome,
      userId: userId,
      completionStatus: outcome == ComplianceOutcome.pass
          ? 'Pass/Fail → Best = Pass (≥48dp)'
          : 'Pass/Fail → Fail (<48dp)',
      actionTimestamp: now,
      sessionId: sessionId,
    );
  }
}

/// A reusable widget wrapper that enforces minimum touch target sizes
/// aligned to Material 3 specifications.
class CompliantTouchTarget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double minSize;

  const CompliantTouchTarget({
    super.key,
    required this.child,
    this.onTap,
    this.minSize = TouchTargetComplianceValidator.optimalTargetDp,
  }) : assert(minSize >= TouchTargetComplianceValidator.floorBoundaryDp,
            'Touch target must be at least ${TouchTargetComplianceValidator.floorBoundaryDp}dp');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: minSize,
      height: minSize,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Center(child: child),
      ),
    );
  }
}

/// Mock repository supplying local test data for backend-independent validation.
class MockComplianceRepository {
  static List<StepExecutionRecord> fetchMockRecords() {
    final validator = TouchTargetComplianceValidator(
      interceptor: DirtyDataInterceptorListener(),
    );

    return [
      validator.generateExecutionRecord(
        stepExecutionId: 'EXEC-001',
        userId: 'USER-99',
        sessionId: 'SESS-ABC',
        evaluatedSizeDp: 48.0, // Pass
      ),
      validator.generateExecutionRecord(
        stepExecutionId: 'EXEC-002',
        userId: 'USER-99',
        sessionId: 'SESS-ABC',
        evaluatedSizeDp: 40.0, // Fail
      ),
      validator.generateExecutionRecord(
        stepExecutionId: 'EXEC-003',
        userId: 'USER-100',
        sessionId: 'SESS-DEF',
        evaluatedSizeDp: 56.0, // Pass
      ),
    ];
  }
}
