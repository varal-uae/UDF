// SSTLA-027-A16 — Adaptive Overlay Component for Mobile Bottom-Sheets and Desktop Popover Modals.
// Automatically switches between a bottom-sheet on mobile and a centered dialog/popover on tablet/desktop viewports following Material 3 guidelines.

import 'package:flutter/material.dart';

/// Breakpoint constants for adaptive layout decisions.
class AdaptiveOverlayBreakpoints {
  static const double mobile = 600.0;
  static const double tablet = 840.0;
}

/// A structural overlay component that publishes responsive modal behavior
/// to the core UI library. Replaces off-center popups on mobile with
/// standard sliding bottom-sheets, while retaining centered dialogs on desktop.
class AdaptiveOverlay extends StatelessWidget {
  final Widget child;
  final String title;
  final bool isDismissible;
  final bool enableDrag;
  final Color? backgroundColor;
  final ShapeBorder? shape;

  const AdaptiveOverlay({
    super.key,
    required this.child,
    this.title = '',
    this.isDismissible = true,
    this.enableDrag = true,
    this.backgroundColor,
    this.shape,
  });

  /// Determines if the current viewport width qualifies as mobile.
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AdaptiveOverlayBreakpoints.mobile;
  }

  /// Shows the adaptive overlay using the appropriate route based on screen size.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String title = '',
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    ShapeBorder? shape,
  }) {
    final isMobile = MediaQuery.of(context).size.width < AdaptiveOverlayBreakpoints.mobile;

    if (isMobile) {
      return showModalBottomSheet<T>(
        context: context,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
        shape: shape ??
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
            ),
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              Flexible(child: child),
            ],
          ),
        ),
      );
    } else {
      return showDialog<T>(
        context: context,
        barrierDismissible: isDismissible,
        builder: (context) => Dialog(
          backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
          shape: shape ??
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28.0),
              ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560.0),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  Flexible(child: child),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // When used directly as a widget in a tree rather than via .show()
    if (_isMobile(context)) {
      return Container(
        decoration: ShapeDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          shape: shape ??
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
              ),
        ),
        child: child,
      );
    }
    return Container(
      decoration: ShapeDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        shape: shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28.0),
            ),
      ),
      constraints: const BoxConstraints(maxWidth: 560.0),
      child: child,
    );
  }
}

/// Mock telemetry data model to satisfy logging device usage patterns
/// alongside panel actions to continually refine layout rules.
class OverlayTelemetryEvent {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final String completionStatus;
  final String actionTimestamp;
  final String sessionId;
  final String deviceType;

  const OverlayTelemetryEvent({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.completionStatus,
    required this.actionTimestamp,
    required this.sessionId,
    required this.deviceType,
  });

  Map<String, dynamic> toJson() => {
        'step_execution_id': stepExecutionId,
        'execution_status': executionStatus,
        'execution_timestamp': executionTimestamp.toIso8601String(),
        'step_outcome': stepOutcome,
        'user_id': userId,
        'completion_status': completionStatus,
        'action_timestamp': actionTimestamp,
        'session_id': sessionId,
        'device_type': deviceType,
      };
}

/// Mock repository for local testing without backend dependencies.
class MockOverlayTelemetryRepository {
  static final List<OverlayTelemetryEvent> _mockEvents = [
    OverlayTelemetryEvent(
      stepExecutionId: 'SSTLA-027-A16-EXEC-001',
      executionStatus: 'Success',
      executionTimestamp: DateTime.now().subtract(const Duration(hours: 2)),
      stepOutcome: 'Rendered bottom-sheet on mobile viewport',
      userId: 'user_mock_01',
      completionStatus: 'Pass',
      actionTimestamp: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      sessionId: 'session_mock_01',
      deviceType: 'mobile',
    ),
    OverlayTelemetryEvent(
      stepExecutionId: 'SSTLA-027-A16-EXEC-002',
      executionStatus: 'Success',
      executionTimestamp: DateTime.now().subtract(const Duration(hours: 1)),
      stepOutcome: 'Rendered popover dialog on desktop viewport',
      userId: 'user_mock_02',
      completionStatus: 'Pass',
      actionTimestamp: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      sessionId: 'session_mock_02',
      deviceType: 'desktop',
    ),
  ];

  Future<List<OverlayTelemetryEvent>> getEvents() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_mockEvents);
  }

  Future<void> logEvent(OverlayTelemetryEvent event) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _mockEvents.add(event);
  }
}