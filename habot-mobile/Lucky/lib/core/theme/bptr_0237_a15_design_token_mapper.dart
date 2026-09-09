// BPTR-0237-A15 — Design Token Mapping Layer for Figma-linked mobile UI layouts.
// Enforces 8dp spacing grid, tokenized color surfaces, and Material 3 styling to block hardcoded override drift.

import 'package:flutter/material.dart';

/// BPTR-0237-A15 — Central style mapper that applies Figma design tokens
/// directly to layout views and exposes spacing/color helpers.
///
/// Uses an 8dp grid for all spacing/margin properties and references
/// standardized color definitions like `tokens.color.surface`.
class Bptr0237A15DesignTokenMapper {
  const Bptr0237A15DesignTokenMapper._();

  static const double gridUnit = 8.0;

  /// Validates that a spacing value is on the 8dp grid.
  static bool isOnGrid(double value) => value % gridUnit == 0;

  /// Returns a spacing value as a multiple of the 8dp grid unit.
  /// Throws in debug mode if the resulting value is not grid-aligned.
  static double space(double factor) {
    final value = gridUnit * factor;
    assert(
      isOnGrid(value),
      'BPTR-0237-A15: spacing $value is not aligned to the 8dp grid.',
    );
    return value;
  }

  /// Builds a Material 3 ThemeData using token-driven spacing and color surfaces.
  static ThemeData buildTokenTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      visualDensity: VisualDensity.standard,
      spacing: gridUnit,
      textTheme: Typography.material2021().black.apply(
            bodyColor: colorScheme.onSurface,
            displayColor: colorScheme.onSurface,
          ),
    );
  }

  /// Standardized surface color reference (tokens.color.surface).
  static Color surfaceColor(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  /// Standardized page padding using 8dp grid tokens.
  static EdgeInsets pagePadding({
    double horizontalFactor = 2,
    double verticalFactor = 2,
  }) {
    return EdgeInsets.symmetric(
      horizontal: space(horizontalFactor),
      vertical: space(verticalFactor),
    );
  }

  /// Standardized list item spacing using tokenized values.
  static EdgeInsets listItemPadding() => EdgeInsets.all(space(1.5));
}
