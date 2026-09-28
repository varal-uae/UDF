// SSTLA-026-A08 — Responsive Breakpoint Layout Grid Configuration.
// Defines layout breakpoint values and grid settings to transition screens between phone displays and large tablet form factors seamlessly using Material 3 adaptive standards.

import 'package:flutter/material.dart';

/// Atomic-level data fields for layout configuration.
class LayoutConfig {
  final String layoutType;
  final Size layoutGridDimensions;
  final EdgeInsets spacingRules;
  final AlignmentDirectional alignmentSettings;
  final bool layoutValidationStatus;

  const LayoutConfig({
    required this.layoutType,
    required this.layoutGridDimensions,
    required this.spacingRules,
    required this.alignmentSettings,
    required this.layoutValidationStatus,
  });
}

/// Standardized 8dp baseline grid spacing rules per Material Design 3.
class BaselineGrid {
  static const double unit = 8.0;
  static const double x1 = unit * 1; // 8
  static const double x2 = unit * 2; // 16
  static const double x3 = unit * 3; // 24
  static const double x4 = unit * 4; // 32
  static const double x6 = unit * 6; // 48
}

/// Breakpoint definitions based on Material Design 3 adaptive layout norms.
class AdaptiveBreakpoints {
  static const double compact = 600.0; // Phone
  static const double medium = 840.0; // Tablet portrait / small tablet
  static const double expanded = 1200.0; // Large tablet / desktop
}

/// Enum representing the current layout window class.
enum WindowClass { compact, medium, expanded }

/// Determines the current window class based on screen width.
WindowClass getWindowClass(double width) {
  if (width < AdaptiveBreakpoints.compact) return WindowClass.compact;
  if (width < AdaptiveBreakpoints.medium) return WindowClass.medium;
  return WindowClass.expanded;
}

/// Returns standardized layout configuration mapped across varying hardware display sizes.
LayoutConfig getLayoutConfig(BuildContext context) {
  final double width = MediaQuery.sizeOf(context).width;
  final WindowClass windowClass = getWindowClass(width);

  switch (windowClass) {
    case WindowClass.compact:
      return const LayoutConfig(
        layoutType: 'single_column_vertical_scroll',
        layoutGridDimensions: Size(1, double.infinity),
        spacingRules: EdgeInsets.symmetric(
          horizontal: BaselineGrid.x2,
          vertical: BaselineGrid.x1,
        ),
        alignmentSettings: AlignmentDirectional.topStart,
        layoutValidationStatus: true,
      );
    case WindowClass.medium:
      return const LayoutConfig(
        layoutType: 'dual_panel_display',
        layoutGridDimensions: Size(2, double.infinity),
        spacingRules: EdgeInsets.all(BaselineGrid.x3),
        alignmentSettings: AlignmentDirectional.topStart,
        layoutValidationStatus: true,
      );
    case WindowClass.expanded:
      return const LayoutConfig(
        layoutType: 'dual_panel_wide_display',
        layoutGridDimensions: Size(3, double.infinity),
        spacingRules: EdgeInsets.all(BaselineGrid.x4),
        alignmentSettings: AlignmentDirectional.centerStart,
        layoutValidationStatus: true,
      );
  }
}

/// A breakpoint-aware layout grid component that organizes dense, wide data grids
/// into single-column vertical scrolls on phones, while expanding to dual-panel
/// displays on tablet devices.
class ResponsiveBreakpointGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const ResponsiveBreakpointGrid({
    super.key,
    required this.children,
    this.spacing = BaselineGrid.x2,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxWidth = constraints.maxWidth;
        final WindowClass windowClass = getWindowClass(maxWidth);
        final LayoutConfig config = getLayoutConfig(context);

        int crossAxisCount;
        switch (windowClass) {
          case WindowClass.compact:
            crossAxisCount = 1;
            break;
          case WindowClass.medium:
            crossAxisCount = 2;
            break;
          case WindowClass.expanded:
            crossAxisCount = 3;
            break;
        }

        return GridView.builder(
          padding: config.spacingRules,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: windowClass == WindowClass.compact ? 1.5 : 1.2,
          ),
          itemCount: children.length,
          itemBuilder: (BuildContext context, int index) {
            return children[index];
          },
        );
      },
    );
  }
}

/// Poka-Yoke (Mistake-Proofing) wrapper widget that ensures text fields
/// automatically wrap onto new lines rather than cutting them off,
/// keeping important labels visible at all times.
class SafeTextWrapper extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  const SafeTextWrapper({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style ?? Theme.of(context).textTheme.bodyMedium,
      textAlign: textAlign,
      softWrap: true,
      overflow: TextOverflow.visible,
      maxLines: null,
    );
  }
}

/// Mock data representing pre-summarized data summaries from BigQuery tables
/// to minimize mobile loading lag.
class MockOperationsData {
  static const List<Map<String, dynamic>> dashboardItems = [
    {'id': '1', 'title': 'Real-Time Operations', 'metric': '98.5%', 'trend': 'up'},
    {'id': '2', 'title': 'Supervisor Alerts', 'metric': '12', 'trend': 'down'},
    {'id': '3', 'title': 'Hardware Status', 'metric': 'Active', 'trend': 'stable'},
    {'id': '4', 'title': 'Network Latency', 'metric': '45ms', 'trend': 'down'},
    {'id': '5', 'title': 'Data Sync Rate', 'metric': '100%', 'trend': 'up'},
    {'id': '6', 'title': 'User Sessions', 'metric': '342', 'trend': 'up'},
  ];
}

/// Metric evaluation for Responsive Layout Fidelity (%).
/// Validates layouts render correctly across at least 95% of the target device/viewport matrix.
class LayoutFidelityMetric {
  static const double floorBoundary = 0.95;
  static const double optimalTarget = 1.0;
  static const double ceilingBoundary = 1.0;

  /// Evaluates if the given fidelity percentage passes the QA threshold.
  static String evaluate(double fidelityPercentage) {
    if (fidelityPercentage >= floorBoundary && fidelityPercentage <= ceilingBoundary) {
      return 'Pass';
    }
    return 'Fail';
  }
}
