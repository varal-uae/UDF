// RCGLA-001-A03 — Global Corporate Style Token Variables & Material 3 Theme Configuration.
// Defines brand primary color (#2E86C1), enforces an 8dp baseline grid, and maps MD3 tokens for tab bars, cards, and layout spacing to prevent hardcoded styling values.

import 'package:flutter/material.dart';

/// Atomic-level data fields representing a single design token definition.
class DesignTokenDefinition {
  final String definitionId;
  final String definitionName;
  final String definitionType;
  final dynamic definitionParameters;
  final bool validationStatus;

  const DesignTokenDefinition({
    required this.definitionId,
    required this.definitionName,
    required this.definitionType,
    required this.definitionParameters,
    required this.validationStatus,
  });
}

/// Centralized style token matrix enforcing the 8dp baseline grid and MD3 standards.
abstract class UdfDesignTokens {
  UdfDesignTokens._();

  // Brand Primary Color Token: #2E86C1
  static const Color brandPrimaryColor = Color(0xFF2E86C1);

  // 8dp Baseline Grid Spacing Metrics
  static const double spacingXxs = 4.0; // Half-step exception for tight inner padding
  static const double spacingXs = 8.0;
  static const double spacingSm = 16.0;
  static const double spacingMd = 24.0;
  static const double spacingLg = 32.0;
  static const double spacingXl = 40.0;
  static const double spacingXxl = 48.0;

  // Touch Target Minimum Size (ensures tap action precision)
  static const double minTouchTargetSize = 48.0;

  // Card Elevation Scale mapping to md.sys.elevation.level1
  static const double cardElevationLevel1 = 1.0;

  // Layout Column Rules
  static const int mobileLayoutColumns = 4;
  static const double mobileLayoutMargin = 16.0;
  static const double mobileLayoutGutter = 16.0;

  /// Audited token definitions for CI verification pipelines.
  static const List<DesignTokenDefinition> tokenRegistry = [
    DesignTokenDefinition(
      definitionId: 'TOK-COLOR-001',
      definitionName: 'Brand Primary Color',
      definitionType: 'Color',
      definitionParameters: '#2E86C1',
      validationStatus: true,
    ),
    DesignTokenDefinition(
      definitionId: 'TOK-SPACE-001',
      definitionName: 'Baseline Grid Step',
      definitionType: 'Spacing',
      definitionParameters: '8dp',
      validationStatus: true,
    ),
    DesignTokenDefinition(
      definitionId: 'TOK-ELEV-001',
      definitionName: 'Card Elevation Level 1',
      definitionType: 'Elevation',
      definitionParameters: 1.0,
      validationStatus: true,
    ),
  ];

  /// Validates that a given spacing value adheres strictly to the 8dp baseline grid.
  /// Poka-Yoke: Automatically fails if layout padding variables use non-standard grid intervals.
  static bool validateGridInterval(double spacingValue) {
    return spacingValue % spacingXs == 0;
  }
}

/// Material 3 ThemeData factory utilizing exclusively standard tokens from [UdfDesignTokens].
class UdfMaterialTheme {
  static ThemeData buildTheme(Brightness brightness) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: UdfDesignTokens.brandPrimaryColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,

      // Enforce 8dp baseline grid across structural spacing metrics
      layoutMargin: const EdgeInsets.all(UdfDesignTokens.spacingSm),

      // Tab Bar Architecture enclosing performance view filters
      tabBarTheme: TabBarThemeData(
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: colorScheme.primary,
        // Unselected metrics tabs follow secondary styling tokens (md.sys.color.on-surface-variant)
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: UdfDesignTokens.spacingXxs / 2,
          ),
        ),
        // High-density metric tab bars map to scrollable top bar layout
        tabAlignment: TabAlignment.start,
      ),

      // Visual analytics grids rely on standard card elevation scales
      cardTheme: CardThemeData(
        elevation: UdfDesignTokens.cardElevationLevel1,
        margin: const EdgeInsets.only(bottom: UdfDesignTokens.spacingSm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UdfDesignTokens.spacingXs),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Explicit touch target areas guarantee tap action precision
      materialTapTargetSize: MaterialTapTargetSize.padded,

      // Navigation Bar (Bottom navigation shell layer layout)
      navigationBarTheme: NavigationBarThemeData(
        height: UdfDesignTokens.spacingXxl + UdfDesignTokens.spacingSm,
        indicatorColor: colorScheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontSize: 12,
            color: states.contains(WidgetState.selected)
                ? colorScheme.onSecondaryContainer
                : colorScheme.onSurfaceVariant,
          );
        }),
      ),

      // Disable manual style choices on individual views to protect layout integrity
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        scrolledUnderElevation: UdfDesignTokens.cardElevationLevel1,
      ),
    );
  }
}
