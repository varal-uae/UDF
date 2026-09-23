// RCGLA-032-A12 — MD3 Adaptive 4-Column Fluid Layout Token Engine for Mobile Screens.
// Configures a Material Design 3 responsive grid system that scales multi-column desktop layouts into single-column mobile views, enforcing 16px gutters, relative widths, flex-wrap behavior, and minimum 48dp touch targets to prevent horizontal overflow.

import 'package:flutter/material.dart';

/// Configuration constants derived from MD3 compact window-size class guidelines.
class Md3GridTokens {
  Md3GridTokens._();

  /// Standardized layout margin system token parameter (16px gutter spacing alignment).
  static const double gutterSpacing = 16.0;

  /// Interactive layout targets preserve an explicit minimum dimension of 48dp.
  static const double minTouchTargetSize = 48.0;

  /// Minimum supported viewport width to guarantee zero horizontal scrollbars.
  static const double minSupportedWidth = 320.0;

  /// Compact breakpoint (mobile) - forces single column.
  static const double compactBreakpoint = 600.0;

  /// Medium breakpoint (tablet) - allows 2 columns.
  static const double mediumBreakpoint = 840.0;

  /// Expanded breakpoint (desktop) - allows up to 4 columns.
  static const double expandedBreakpoint = 1200.0;
}

/// Determines the number of columns based on available width following MD3 guidelines.
int _calculateColumnCount(double availableWidth) {
  if (availableWidth < Md3GridTokens.compactBreakpoint) return 1;
  if (availableWidth < Md3GridTokens.mediumBreakpoint) return 2;
  if (availableWidth < Md3GridTokens.expandedBreakpoint) return 3;
  return 4;
}

/// A responsive grid widget that automatically wraps structural grid items
/// using flex-wrap semantics and relative percentage-based widths.
///
/// Replaces CSS `max-width: 100vw`, `flex-wrap: wrap`, and percentage widths
/// with Flutter's [LayoutBuilder] and [Wrap] equivalents to ensure fluid
/// elasticity across diverse aspect ratios without horizontal scrolling.
class Md3AdaptiveGrid extends StatelessWidget {
  const Md3AdaptiveGrid({
    super.key,
    required this.children,
    this.spacing = Md3GridTokens.gutterSpacing,
    this.runSpacing = Md3GridTokens.gutterSpacing,
    this.padding,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Enforce max-width constraint equivalent to CSS max-width: 100vw
        final double maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        final int columnCount = _calculateColumnCount(maxWidth);

        // Calculate relative percentage width per item minus gutters
        final double totalGutterWidth = spacing * (columnCount - 1);
        final double itemWidth = (maxWidth - totalGutterWidth) / columnCount;

        final EdgeInsetsGeometry resolvedPadding = padding ??
            const EdgeInsets.symmetric(horizontal: Md3GridTokens.gutterSpacing);

        return Padding(
          padding: resolvedPadding,
          child: Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            children: children.map((Widget child) {
              return SizedBox(
                width: itemWidth.clamp(0.0, maxWidth),
                child: child,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

/// A wrapper widget ensuring any interactive target preserves an explicit
/// minimum dimension of 48dp for ease of tactile navigation.
class Md3TouchTarget extends StatelessWidget {
  const Md3TouchTarget({
    super.key,
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: Md3GridTokens.minTouchTargetSize,
        minHeight: Md3GridTokens.minTouchTargetSize,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Center(
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: child,
        ),
      ),
    );
  }
}

/// A scaffold-level wrapper that prevents accidental side-scrolling by
/// constraining content strictly within the device viewport width.
/// Equivalent to CSS `overflow-x: hidden` and `max-width: 100vw`.
class Md3ResponsiveShell extends StatelessWidget {
  const Md3ResponsiveShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth,
              minWidth: constraints.maxWidth,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// Mock telemetry data structure to track layout render health
/// across diverse mobile devices as specified in GCP/BigQuery alignment.
class LayoutTelemetryEvent {
  const LayoutTelemetryEvent({
    required this.configurationParameter,
    required this.currentSetting,
    required this.previousSetting,
    required this.changeLog,
    required this.configurationTimestamp,
    required this.completionStatus,
    required this.viewportWidth,
    required this.columnCount,
  });

  final String configurationParameter;
  final String currentSetting;
  final String previousSetting;
  final String changeLog;
  final DateTime configurationTimestamp;
  final String completionStatus; // 'Pass' or 'Fail'
  final double viewportWidth;
  final int columnCount;

  Map<String, dynamic> toJson() => {
        'configuration_parameter': configurationParameter,
        'current_setting': currentSetting,
        'previous_setting': previousSetting,
        'change_log': changeLog,
        'configuration_timestamp': configurationTimestamp.toIso8601String(),
        'completion_status': completionStatus,
        'viewport_width': viewportWidth,
        'column_count': columnCount,
      };
}

/// Generates mock telemetry events for local auditing collections.
List<LayoutTelemetryEvent> generateMockLayoutTelemetry() {
  final DateTime now = DateTime.now();
  return [
    LayoutTelemetryEvent(
      configurationParameter: 'grid_column_count',
      currentSetting: '1',
      previousSetting: '4',
      changeLog: 'Scaled down to compact window-size class',
      configurationTimestamp: now,
      completionStatus: 'Pass',
      viewportWidth: 375.0,
      columnCount: 1,
    ),
    LayoutTelemetryEvent(
      configurationParameter: 'grid_gutter_spacing',
      currentSetting: '16.0',
      previousSetting: '16.0',
      changeLog: 'Maintained standardized layout margin token',
      configurationTimestamp: now,
      completionStatus: 'Pass',
      viewportWidth: 320.0,
      columnCount: 1,
    ),
    LayoutTelemetryEvent(
      configurationParameter: 'touch_target_minimum',
      currentSetting: '48.0',
      previousSetting: '48.0',
      changeLog: 'Enforced 48dp minimum dimension',
      configurationTimestamp: now,
      completionStatus: 'Pass',
      viewportWidth: 414.0,
      columnCount: 1,
    ),
  ];
}