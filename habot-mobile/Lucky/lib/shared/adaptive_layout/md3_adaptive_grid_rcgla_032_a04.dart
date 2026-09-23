// RCGLA-032-A04 — MD3 Adaptive 4-Column Fluid Layout Token Engine.
// Configures a responsive grid system with 16px outer margins, fluid elasticity,
// and automatic wrapping to ensure zero horizontal overflow on mobile screens down to 320px width.

import 'package:flutter/material.dart';

/// Design tokens for the MD3 adaptive layout engine.
class Md3LayoutTokens {
  Md3LayoutTokens._();

  /// Standardized outer margin (16px gutter spacing alignment).
  static const double outerMargin = 16.0;

  /// Floor boundary for spacing (4dp).
  static const double spacingFloor = 4.0;

  /// Optimal target for spacing (8dp).
  static const double spacingOptimal = 8.0;

  /// Ceiling boundary for spacing (16dp).
  static const double spacingCeiling = 16.0;

  /// Maximum desktop/web columns.
  static const int maxColumns = 4;
}

/// Enum representing MD3 window size classes.
enum Md3WindowSizeClass { compact, medium, expanded }

/// Utility to determine the current window size class based on width.
Md3WindowSizeClass getWindowSizeClass(double width) {
  if (width < 600) return Md3WindowSizeClass.compact;
  if (width < 840) return Md3WindowSizeClass.medium;
  return Md3WindowSizeClass.expanded;
}

/// Returns the appropriate column count for the given window size class.
int getColumnCount(Md3WindowSizeClass windowClass) {
  switch (windowClass) {
    case Md3WindowSizeClass.compact:
      return 1; // Single functional column on mobile
    case Md3WindowSizeClass.medium:
      return 2;
    case Md3WindowSizeClass.expanded:
      return Md3LayoutTokens.maxColumns;
  }
}

/// A foundational responsive grid widget that enforces MD3 compact window-size
/// guidelines, relative percentage-based widths, and flex-wrap behavior.
/// Prevents horizontal scrolling by constraining max-width to 100vw.
class Md3AdaptiveGrid extends StatelessWidget {
  const Md3AdaptiveGrid({
    super.key,
    required this.children,
    this.spacing = Md3LayoutTokens.spacingOptimal,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
  }) : assert(spacing >= Md3LayoutTokens.spacingFloor && spacing <= Md3LayoutTokens.spacingCeiling,
            'Spacing must be within MD3 boundaries (4dp - 16dp).');

  final List<Widget> children;
  final double spacing;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Enforce max-width constraint to prevent accidental side-scrolling
        final double maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        final Md3WindowSizeClass windowClass = getWindowSizeClass(maxWidth);
        final int columnCount = getColumnCount(windowClass);

        final double effectiveCrossSpacing = crossAxisSpacing ?? spacing;
        final double effectiveMainSpacing = mainAxisSpacing ?? spacing;

        // Calculate total horizontal spacing to subtract from available width
        final double totalHorizontalSpacing =
            (columnCount - 1) * effectiveCrossSpacing + (Md3LayoutTokens.outerMargin * 2);

        // Fluid elasticity: calculate item width as a relative percentage of available space
        final double availableWidth = maxWidth - totalHorizontalSpacing;
        final double itemWidth = availableWidth / columnCount;

        return ConstrainedBox(
          // Poka-Yoke: physically impossible to exceed viewport width
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Md3LayoutTokens.outerMargin,
            ),
            child: Wrap(
              // Bind structural grid items with automatic wrapping styling parameters
              direction: Axis.horizontal,
              spacing: effectiveCrossSpacing,
              runSpacing: effectiveMainSpacing,
              children: children.map((Widget child) {
                return SizedBox(
                  width: itemWidth.clamp(0.0, maxWidth),
                  child: child,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// A wrapper shell that applies global layout margin properties and ensures
/// zero horizontal overflow across the entire application layout.
class Md3LayoutShell extends StatelessWidget {
  const Md3LayoutShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      // Hide horizontal overflow to make accidental side-scrolling physically impossible
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(Md3LayoutTokens.outerMargin),
          child: child,
        ),
      ),
    );
  }
}

/// Mock telemetry data structure for tracking layout render health.
class LayoutTelemetryMock {
  final String layoutType;
  final String layoutGridDimensions;
  final String spacingRules;
  final String alignmentSettings;
  final bool layoutValidationStatus;
  final DateTime timestamp;

  const LayoutTelemetryMock({
    required this.layoutType,
    required this.layoutGridDimensions,
    required this.spacingRules,
    required this.alignmentSettings,
    required this.layoutValidationStatus,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'layout_type': layoutType,
        'layout_grid_dimensions': layoutGridDimensions,
        'spacing_rules': spacingRules,
        'alignment_settings': alignmentSettings,
        'layout_validation_status': layoutValidationStatus ? 'Pass' : 'Fail',
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Local mock repository providing realistic layout validation data.
class LayoutValidationMockRepository {
  static List<LayoutTelemetryMock> getMockValidationData() {
    return [
      LayoutTelemetryMock(
        layoutType: 'Responsive Grid',
        layoutGridDimensions: '4-column fluid (desktop), 1-column (mobile)',
        spacingRules: '16px outer margin, 8dp optimal gutter',
        alignmentSettings: 'Top-to-bottom predictable scroll',
        layoutValidationStatus: true,
        timestamp: DateTime.now(),
      ),
      LayoutTelemetryMock(
        layoutType: 'Dashboard Stack',
        layoutGridDimensions: 'Single-column stacked charts',
        spacingRules: '16px outer margin, 8dp optimal gutter',
        alignmentSettings: 'Vertical axis thumb-scrolling',
        layoutValidationStatus: true,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }
}