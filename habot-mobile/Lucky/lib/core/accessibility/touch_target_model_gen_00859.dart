// GEN-00859 — Data models for MD3 Touch Targets, Haptic Feedback Profiles, and Accessibility Scans

import 'package:flutter/foundation.dart';

/// Standardized MD3 Haptic Type Enum
enum HapticFeedbackProfile {
  selection,
  lightImpact,
  mediumImpact,
  heavyImpact,
  success,
  error,
}

/// Audit Scan Result Status for W3C / MD3 Touch Target Compliance
enum ComplianceStatus {
  pass,
  fail,
}

/// Component Touch Target Audit Node
@immutable
class TouchTargetAuditItem {
  final String id;
  final String componentName;
  final double widthDp;
  final double heightDp;
  final bool hasHapticsEnabled;
  final ComplianceStatus status;
  final String standardRef;

  const TouchTargetAuditItem({
    required this.id,
    required this.componentName,
    required this.widthDp,
    required this.heightDp,
    required this.hasHapticsEnabled,
    required this.status,
    this.standardRef = 'W3C ACT / MD3 48x48dp',
  });

  bool get meetsMinimumTarget => widthDp >= 48.0 && heightDp >= 48.0;
}

/// Aggregate Report for CI/CD and Mobile Engineering Console
@immutable
class TouchTargetScanSummary {
  final String scanId;
  final DateTime timestamp;
  final double passRatePercentage;
  final int totalScanned;
  final int passedCount;
  final int failedCount;
  final List<TouchTargetAuditItem> items;

  const TouchTargetScanSummary({
    required this.scanId,
    required this.timestamp,
    required this.passRatePercentage,
    required this.totalScanned,
    required this.passedCount,
    required this.failedCount,
    required this.items,
  });

  bool get isCompliant => passRatePercentage >= 100.0;
}
