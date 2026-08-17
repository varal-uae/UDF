import 'package:flutter/material.dart';

/// Shared Material Design 3 Density & Accessibility Tokens.
abstract class AppDensityTokens {
  /// Minimum touch target size required for accessibility (48x48dp).
  static const double minTouchTargetSize = 48.0;

  /// Density spacing floor threshold (4.0dp).
  static const double densityFloor = 4.0;

  /// Density spacing ceiling threshold (12.0dp).
  static const double densityCeiling = 12.0;

  /// Minimum spacing threshold between interactive components (4.0dp).
  static const double minComponentSpacing = 4.0;

  /// Minimum padding threshold for dense list/table items (6.0dp).
  static const double minItemPadding = 6.0;

  /// Maximum standard padding threshold for list/table cells (8.0dp).
  static const double maxItemPadding = 8.0;

  /// Compact row height threshold (32.0dp).
  static const double compactRowHeight = 32.0;

  /// Medium standard row height threshold (40.0dp).
  static const double mediumRowHeight = 40.0;

  /// Comfortable row height threshold (48.0dp).
  static const double comfortableRowHeight = 48.0;

  /// Standard padding for dense table cells (6dp top/bottom, 8dp left/right).
  static const EdgeInsets tableCellPaddingDense = EdgeInsets.symmetric(
    horizontal: maxItemPadding,
    vertical: minItemPadding,
  );

  /// VisualDensity presets.
  static const VisualDensity compactDensity = VisualDensity(horizontal: -2, vertical: -2);
  static const VisualDensity standardDensity = VisualDensity(horizontal: 0, vertical: 0);
  static const VisualDensity comfortableDensity = VisualDensity(horizontal: 2, vertical: 2);
}
