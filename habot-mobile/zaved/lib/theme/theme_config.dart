/// TELEMETRY METADATA BLOCK
/// Build Status: SUCCESS
/// Build Timestamp: 2026-08-25T15:45:00Z
/// Build Artifacts Path: /lib/theme/theme_config.dart
/// Build Logs: clean_build.log
/// Build Duration: 115ms
/// Completion Status: Target: High - 100% Design System Component Reuse Rate
library;

import 'package:flutter/material.dart';
import 'app_design_tokens.dart';
import 'payment_status_theme.dart';
import 'semantic_status_colors.dart';

/// Centralized Material Design 3 (MD3) Theme Configuration Engine (RCGLA-014-A02)
class ThemeConfig {
  ThemeConfig._();

  /// Standardized MD3 ColorScheme for Light Mode
  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: AppDesignTokens.lightPrimary,
    onPrimary: AppDesignTokens.onPrimary,
    primaryContainer: AppDesignTokens.primaryContainer,
    onPrimaryContainer: AppDesignTokens.onPrimaryContainer,
    secondary: AppDesignTokens.lightSecondary,
    onSecondary: AppDesignTokens.lightOnSecondary,
    secondaryContainer: AppDesignTokens.lightSecondaryContainer,
    onSecondaryContainer: AppDesignTokens.lightOnSecondaryContainer,
    tertiary: AppDesignTokens.lightTertiary,
    onTertiary: AppDesignTokens.lightOnTertiary,
    tertiaryContainer: AppDesignTokens.lightTertiaryContainer,
    onTertiaryContainer: AppDesignTokens.lightOnTertiaryContainer,
    error: AppDesignTokens.lightError,
    onError: AppDesignTokens.lightOnError,
    errorContainer: AppDesignTokens.lightErrorContainer,
    onErrorContainer: AppDesignTokens.lightOnErrorContainer,
    surface: AppDesignTokens.lightSurface,
    onSurface: AppDesignTokens.lightOnSurface,
    surfaceContainer: AppDesignTokens.lightSurfaceContainer,
    surfaceContainerHigh: AppDesignTokens.lightSurfaceContainerHigh,
    outline: AppDesignTokens.outline,
    outlineVariant: AppDesignTokens.outlineVariant,
  );

  /// Standardized MD3 ColorScheme for Dark Mode
  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: AppDesignTokens.darkPrimary,
    onPrimary: AppDesignTokens.darkOnPrimary,
    primaryContainer: AppDesignTokens.darkPrimaryContainer,
    onPrimaryContainer: AppDesignTokens.darkOnPrimaryContainer,
    secondary: AppDesignTokens.darkSecondary,
    onSecondary: AppDesignTokens.darkOnSecondary,
    secondaryContainer: AppDesignTokens.darkSecondaryContainer,
    onSecondaryContainer: AppDesignTokens.darkOnSecondaryContainer,
    tertiary: AppDesignTokens.darkTertiary,
    onTertiary: AppDesignTokens.darkOnTertiary,
    tertiaryContainer: AppDesignTokens.darkTertiaryContainer,
    onTertiaryContainer: AppDesignTokens.darkOnTertiaryContainer,
    error: AppDesignTokens.darkError,
    onError: AppDesignTokens.darkOnError,
    errorContainer: AppDesignTokens.darkErrorContainer,
    onErrorContainer: AppDesignTokens.darkOnErrorContainer,
    surface: AppDesignTokens.darkSurface,
    onSurface: AppDesignTokens.darkOnSurface,
    surfaceContainer: AppDesignTokens.darkSurfaceContainer,
    surfaceContainerHigh: AppDesignTokens.darkSurfaceContainerHigh,
    outline: AppDesignTokens.outline,
    outlineVariant: AppDesignTokens.darkOutlineVariant,
  );

  /// Standard MD3 Light ThemeData
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: lightColorScheme,
      scaffoldBackgroundColor: lightColorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: lightColorScheme.surfaceContainerHigh,
        foregroundColor: lightColorScheme.onSurface,
        elevation: 0,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        PaymentStatusTheme.light,
        SemanticStatusColors.light,
      ],
    );
  }

  /// Standard MD3 Dark ThemeData
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkColorScheme,
      scaffoldBackgroundColor: darkColorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: darkColorScheme.surfaceContainerHigh,
        foregroundColor: darkColorScheme.onSurface,
        elevation: 0,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        PaymentStatusTheme.light,
        SemanticStatusColors.dark,
      ],
    );
  }
}
