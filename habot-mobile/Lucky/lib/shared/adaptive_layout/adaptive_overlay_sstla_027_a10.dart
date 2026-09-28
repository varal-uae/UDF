// SSTLA-027-A10 — Adaptive Overlay Layout Controller.
// Determines structural layout rules that automatically switch user interfaces from mobile bottom-sheets to desktop popover modals, prioritizing single-handed use and Material Design 3 standards with WCAG 2.1 AA accessibility.

import 'package:flutter/material.dart';

/// Breakpoint constants for adaptive layout switching.
class AdaptiveBreakpoints {
  static const double mobile = 600.0;
  static const double tablet = 840.0;
  static const double desktop = 1200.0;
}

/// Configuration data model for adaptive overlays matching atomic-level data fields.
class AdaptiveOverlayConfig {
  final String mobilePlatform;
  final String osVersion;
  final String deviceType;
  final Size screenDimensions;
  final Map<String, dynamic> mobileConfiguration;

  const AdaptiveOverlayConfig({
    required this.mobilePlatform,
    required this.osVersion,
    required this.deviceType,
    required this.screenDimensions,
    required this.mobileConfiguration,
  });

  /// Mock configuration for local testing without backend dependencies.
  factory AdaptiveOverlayConfig.mock() {
    return const AdaptiveOverlayConfig(
      mobilePlatform: 'Android',
      osVersion: '14',
      deviceType: 'Phone',
      screenDimensions: Size(390, 844),
      mobileConfiguration: {'isOneHandedMode': true},
    );
  }
}

/// Core utility class that handles the structural layout rules for switching
/// between mobile bottom-sheets and desktop popover modals.
class AdaptiveOverlayController {
  const AdaptiveOverlayController._();

  /// Evaluates the current [MediaQueryData] to determine if a bottom-sheet
  /// or a dialog/popover should be used.
  static bool isMobileViewport(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width < AdaptiveBreakpoints.tablet;
  }

  /// Shows an adaptive overlay. Uses [showModalBottomSheet] on mobile/tablet
  /// viewports for comfortable sliding sheets, and [showDialog] on desktop
  /// viewports for centered popover modals.
  static Future<T?> showAdaptiveOverlay<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? barrierColor,
    AdaptiveOverlayConfig? config,
  }) {
    final effectiveConfig = config ?? AdaptiveOverlayConfig.mock();
    final isMobile = isMobileViewport(context);

    if (isMobile) {
      // Mobile-first implication: Prioritizes bottom-anchored sheets that make
      // single-handed use simple and natural. Replaces jarring popups.
      return showModalBottomSheet<T>(
        context: context,
        builder: (ctx) => Semantics(
          label: 'Bottom sheet overlay for ${effectiveConfig.deviceType}',
          container: true,
          child: builder(ctx),
        ),
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
        ),
        barrierColor: barrierColor ?? Colors.black54,
        // Ensures fluid navigation and easily dismissible overlays.
        clipBehavior: Clip.antiAlias,
      );
    } else {
      // Desktop/Tablet behavior: Popover modal centered on screen.
      return showDialog<T>(
        context: context,
        barrierDismissible: isDismissible,
        barrierColor: barrierColor ?? Colors.black45,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Semantics(
            label: 'Popover modal overlay for ${effectiveConfig.deviceType}',
            container: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
              child: builder(ctx),
            ),
          ),
        ),
      );
    }
  }
}

/// A resilient wrapper widget that scales beautifully across viewports.
/// Can be used inline when a full-screen modal isn't required but layout
/// adaptation is still necessary.
class AdaptiveLayoutSwitcher extends StatelessWidget {
  final Widget mobileChild;
  final Widget desktopChild;

  const AdaptiveLayoutSwitcher({
    super.key,
    required this.mobileChild,
    required this.desktopChild,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < AdaptiveBreakpoints.tablet) {
          return mobileChild;
        }
        return desktopChild;
      },
    );
  }
}

/// Telemetry logging mock to satisfy GCP / BigQuery Alignment requirements.
/// Logs device usage patterns alongside panel actions to continually refine layout rules.
class AdaptiveOverlayTelemetry {
  static void logOverlayAction({
    required String action, // e.g., 'opened', 'closed'
    required AdaptiveOverlayConfig config,
    required bool wasMobileLayout,
  }) {
    // In production, this would stream to GCP/BigQuery.
    debugPrint(
      '[SSTLA-027-A10 Telemetry] Action: $action | '
      'Platform: ${config.mobilePlatform} | '
      'Device: ${config.deviceType} | '
      'Screen: ${config.screenDimensions} | '
      'Layout Used: ${wasMobileLayout ? 'BottomSheet' : 'Popover'}',
    );
  }
}
