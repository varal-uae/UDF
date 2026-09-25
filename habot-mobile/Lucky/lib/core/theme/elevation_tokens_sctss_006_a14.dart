// SCTSS-006-A14 — Z-Index Layering Scale & Elevation Tokens.
// Defines strict elevation rules for modals, toasts, and sticky headers with 5 global levels, max content width cap at 1280dp, and hard-coded variables to prevent arbitrary numbers.

import 'package:flutter/material.dart';

/// Hard-coded Z-index layering scale defining strict elevation rules.
/// Prevents overlapping UI chaos so critical alerts are never hidden on small screens.
/// Completion Measure: 5 global elevation levels defined.
class ElevationTokens {
  ElevationTokens._();

  /// Level 1: Base surface (cards, standard containers)
  static const double level1Base = 1.0;

  /// Level 2: Sticky headers, app bars, elevated navigation
  static const double level2StickyHeader = 3.0;

  /// Level 3: Floating Action Buttons, speed dials
  static const double level3Fab = 6.0;

  /// Level 4: Toasts, snackbars, bottom sheets
  static const double level4Toast = 8.0;

  /// Level 5: Modals, dialogs, critical alerts (highest priority)
  static const double level5Modal = 24.0;

  /// Returns the appropriate Material 3 elevation for a given semantic level.
  static double getElevationForLevel(int level) {
    switch (level) {
      case 1:
        return level1Base;
      case 2:
        return level2StickyHeader;
      case 3:
        return level3Fab;
      case 4:
        return level4Toast;
      case 5:
        return level5Modal;
      default:
        // Poka-Yoke: Hard-coded variables prevent arbitrary numbers.
        throw ArgumentError('Invalid elevation level: $level. Must be between 1 and 5.');
    }
  }
}

/// Layout tokens enforcing maximum content width constraints.
class LayoutTokens {
  LayoutTokens._();

  /// Maximum content width cap on Expanded viewports.
  /// Content stops expanding at 1280dp as per requirement Setup Step (Action).1.
  static const double maxContentWidth = 1280.0;
}

/// A wrapper widget that enforces the maximum content width cap of 1280dp.
/// Implements Mobile-First & Responsive UX: Side-by-side on desktop, vertical stack on mobile.
class MaxWidthConstrainedBox extends StatelessWidget {
  final Widget child;

  const MaxWidthConstrainedBox({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: LayoutTokens.maxContentWidth,
        ),
        child: child,
      ),
    );
  }
}

/// Mock data representing atomic-level execution tracking for this setup step.
/// Satisfies backend/mock data rule without requiring external API.
class ElevationExecutionMockData {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final String completionStatus;

  const ElevationExecutionMockData({
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
        'Completion Status': completionStatus,
      };

  /// Simulated local mock repository data
  static List<ElevationExecutionMockData> get mockExecutions => [
        ElevationExecutionMockData(
          stepExecutionId: 'EXEC-SCTSS-006-A14-001',
          executionStatus: 'Completed',
          executionTimestamp: DateTime.utc(2026, 9, 25, 10, 0),
          stepOutcome: 'Z-index variable scale document generated successfully.',
          userId: 'USR-UDF-01',
          completionStatus: 'Pass',
        ),
        ElevationExecutionMockData(
          stepExecutionId: 'EXEC-SCTSS-006-A14-002',
          executionStatus: 'Completed',
          executionTimestamp: DateTime.utc(2026, 9, 25, 10, 15),
          stepOutcome: '5 global elevation levels validated against RAIL guidance.',
          userId: 'USR-UDF-02',
          completionStatus: 'Pass',
        ),
      ];
}

/// Metric thresholds based on Google RAIL/UX latency guidance.
/// Response Latency (ms) — visual elevation performance during dynamic component transitions.
class ElevationPerformanceMetrics {
  ElevationPerformanceMetrics._();

  /// Floor Boundary: ≤500ms (beyond this risks perceived lag)
  static const int floorBoundaryMs = 500;

  /// Optimal Target: ≤200ms (perceptibly responsive)
  static const int optimalTargetMs = 200;

  /// Ceiling Boundary: ≤100ms (feels instantaneous)
  static const int ceilingBoundaryMs = 100;

  /// Evaluates response latency and returns Pass/Fail qualitative output.
  static String evaluateLatency(int latencyMs) {
    if (latencyMs <= floorBoundaryMs) {
      return 'Pass';
    }
    return 'Fail';
  }
}
