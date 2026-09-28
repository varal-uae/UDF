// SSTLA-027-A02 — Adaptive Overlay Layout Switcher.
// Automatically switches between mobile bottom-sheets and desktop popover modals based on screen width thresholds (e.g., 768px).

import 'package:flutter/material.dart';

/// Defines the breakpoint threshold for switching layout strategies.
const double kDesktopBreakpoint = 768.0;

/// A utility class that provides adaptive overlay presentation logic.
/// Replaces jarring popups on mobile with standard sliding bottom sheets,
/// while maintaining centered popover dialogs on desktop/tablet viewports.
class AdaptiveOverlay {
  const AdaptiveOverlay._();

  /// Determines if the current context represents a wide (desktop/tablet) layout.
  static bool isWideLayout(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
  }

  /// Shows an adaptive overlay: BottomSheet on mobile, Dialog on desktop.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? barrierColor,
    String? semanticLabel,
  }) {
    if (isWideLayout(context)) {
      return _showDesktopPopover<T>(
        context: context,
        builder: builder,
        isDismissible: isDismissible,
        barrierColor: barrierColor,
        semanticLabel: semanticLabel,
      );
    } else {
      return _showMobileBottomSheet<T>(
        context: context,
        builder: builder,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        barrierColor: barrierColor,
      );
    }
  }

  static Future<T?> _showMobileBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    required bool isDismissible,
    required bool enableDrag,
    Color? barrierColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      builder: builder,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      barrierColor: barrierColor ?? Colors.black54,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
    );
  }

  static Future<T?> _showDesktopPopover<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    required bool isDismissible,
    Color? barrierColor,
    String? semanticLabel,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      barrierColor: barrierColor ?? Colors.black38,
      builder: (BuildContext dialogContext) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600.0,
                maxHeight: 800.0,
              ),
              child: builder(dialogContext),
            ),
          ),
        );
      },
    );
  }
}

/// A responsive wrapper widget that builds different layouts based on screen width.
/// Useful for inline structural switching rather than overlays.
class AdaptiveLayoutSwitcher extends StatelessWidget {
  final WidgetBuilder mobileBuilder;
  final WidgetBuilder desktopBuilder;
  final double breakpoint;

  const AdaptiveLayoutSwitcher({
    super.key,
    required this.mobileBuilder,
    required this.desktopBuilder,
    this.breakpoint = kDesktopBreakpoint,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth >= breakpoint) {
      return desktopBuilder(context);
    }
    return mobileBuilder(context);
  }
}

/// Mock telemetry data structure for logging device usage patterns
/// alongside panel actions to continually refine layout rules.
class AdaptiveLayoutTelemetry {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final double screenWidth;
  final String layoutUsed;

  const AdaptiveLayoutTelemetry({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.screenWidth,
    required this.layoutUsed,
  });

  Map<String, dynamic> toJson() => {
        'step_execution_id': stepExecutionId,
        'execution_status': executionStatus,
        'execution_timestamp': executionTimestamp.toIso8601String(),
        'step_outcome': stepOutcome,
        'user_id': userId,
        'screen_width': screenWidth,
        'layout_used': layoutUsed,
      };

  /// Local mock data for testing without backend connectivity.
  static List<AdaptiveLayoutTelemetry> get mockData => [
        AdaptiveLayoutTelemetry(
          stepExecutionId: 'SSTLA-027-A02-EXEC-001',
          executionStatus: 'Pass',
          executionTimestamp: DateTime.now().subtract(const Duration(hours: 2)),
          stepOutcome: 'Bottom sheet rendered successfully',
          userId: 'user_mobile_01',
          screenWidth: 390.0,
          layoutUsed: 'mobile_bottom_sheet',
        ),
        AdaptiveLayoutTelemetry(
          stepExecutionId: 'SSTLA-027-A02-EXEC-002',
          executionStatus: 'Pass',
          executionTimestamp: DateTime.now().subtract(const Duration(hours: 1)),
          stepOutcome: 'Popover modal rendered successfully',
          userId: 'user_desktop_01',
          screenWidth: 1440.0,
          layoutUsed: 'desktop_popover',
        ),
      ];
}
