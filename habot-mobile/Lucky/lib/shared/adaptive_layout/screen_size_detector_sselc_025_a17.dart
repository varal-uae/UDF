// SSELC-025-A17 — Screen Size Detection Engine for Adaptive Layouts.
// Deploys screen size detection scripts across app layout layers, enforcing compact 4-column viewport initialization and fluid scaling based on Material Design responsive grid specifications.

import 'package:flutter/material.dart';

/// Represents the detected screen size category following Material Design breakpoints.
enum ScreenSizeCategory {
  compact,
  medium,
  expanded,
}

/// Immutable data class holding the current screen metrics.
class ScreenMetrics {
  final double width;
  final double height;
  final ScreenSizeCategory category;
  final int gridColumns;
  final EdgeInsets padding;

  const ScreenMetrics({
    required this.width,
    required this.height,
    required this.category,
    required this.gridColumns,
    required this.padding,
  });

  /// Poka-Yoke: Falls back to secure compact structures when dimension details are unclear.
  factory ScreenMetrics.fallback() {
    return const ScreenMetrics(
      width: 360.0,
      height: 640.0,
      category: ScreenSizeCategory.compact,
      gridColumns: 4,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
    );
  }
}

/// InheritedWidget that provides active size listening engines guiding app component rendering paths.
class ScreenSizeDetector extends InheritedWidget {
  final ScreenMetrics metrics;

  const ScreenSizeDetector({
    super.key,
    required this.metrics,
    required super.child,
  });

  static ScreenSizeDetector? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ScreenSizeDetector>();
  }

  static ScreenSizeDetector of(BuildContext context) {
    final detector = maybeOf(context);
    assert(detector != null, 'No ScreenSizeDetector found in context');
    return detector!;
  }

  static ScreenMetrics metricsOf(BuildContext context) {
    return of(context).metrics;
  }

  @override
  bool updateShouldNotify(ScreenSizeDetector oldWidget) {
    return metrics.width != oldWidget.metrics.width ||
        metrics.height != oldWidget.metrics.height ||
        metrics.category != oldWidget.metrics.category;
  }
}

/// Core engine that computes [ScreenMetrics] from available constraints.
/// Focuses initialization layouts strictly on the compact 4-column viewport.
class ScreenSizeEngine {
  ScreenSizeEngine._();

  /// Computes screen metrics based on the provided [BoxConstraints].
  /// Applies distinct, high-visibility style guidelines and standard structured navigation blocks.
  static ScreenMetrics compute(BoxConstraints constraints) {
    if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
      // Poka-Yoke: Fallback to safe compact structure
      return ScreenMetrics.fallback();
    }

    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    if (width < 600) {
      // Compact: Strictly 4-column viewport for mobile-first optimization
      return ScreenMetrics(
        width: width,
        height: height,
        category: ScreenSizeCategory.compact,
        gridColumns: 4,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
      );
    } else if (width < 840) {
      // Medium: 8-column grid
      return ScreenMetrics(
        width: width,
        height: height,
        category: ScreenSizeCategory.medium,
        gridColumns: 8,
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
      );
    } else {
      // Expanded: 12-column grid
      return ScreenMetrics(
        width: width,
        height: height,
        category: ScreenSizeCategory.expanded,
        gridColumns: 12,
        padding: const EdgeInsets.symmetric(horizontal: 48.0),
      );
    }
  }
}

/// A wrapper widget that deploys the screen size detection script across the layout layer.
/// Screens adjust fluidly when users activate split-screen modes or change orientations.
class ScreenSizeDetectorWrapper extends StatelessWidget {
  final Widget child;

  const ScreenSizeDetectorWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = ScreenSizeEngine.compute(constraints);
        return ScreenSizeDetector(
          metrics: metrics,
          child: child,
        );
      },
    );
  }
}

/// Responsive builder widget that scales elements fluidly based on available device screen space.
class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenMetrics metrics) builder;

  const ResponsiveLayoutBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = ScreenSizeDetector.metricsOf(context);
    return builder(context, metrics);
  }
}

/// Mock telemetry logger to log user device sizes cleanly to analytical datasets.
/// Aligns with GCP / BigQuery logging requirements.
class ScreenTelemetryLogger {
  ScreenTelemetryLogger._();

  static void logScreenMetrics(ScreenMetrics metrics, String userId) {
    // Mock data collection matching atomic-level data fields requirement:
    // Step Execution ID; Execution Status; Execution Timestamp; Step Outcome; User ID
    final mockLogEntry = {
      'step_execution_id': 'SSELC-025-A17-EXEC-${DateTime.now().millisecondsSinceEpoch}',
      'execution_status': 'Pass',
      'execution_timestamp': DateTime.now().toIso8601String(),
      'step_outcome': 'Layout rendered successfully',
      'user_id': userId,
      'screen_width': metrics.width,
      'screen_height': metrics.height,
      'category': metrics.category.name,
      'grid_columns': metrics.gridColumns,
      'completion_status': 'Pass/Fail',
    };

    debugPrint('[ScreenTelemetryLogger] Device Metrics Logged: $mockLogEntry');
  }
}

/// Explanatory subtext widget instructing user how to recover state without losing data.
class StateRecoveryBanner extends StatelessWidget {
  const StateRecoveryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      color: theme.colorScheme.primaryContainer,
      child: Text(
        'Your screen layout has adjusted automatically. Your data and form progress are safely preserved.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}