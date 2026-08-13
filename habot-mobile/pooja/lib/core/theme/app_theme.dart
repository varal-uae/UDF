import 'package:flutter/material.dart';
import '../tokens/color_scheme_builder.dart';
import '../tokens/typography_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/density_tokens.dart';
import '../tokens/elevation_tokens.dart';

abstract class AppTheme {
  static ThemeData light({ColorScheme? dynamicLight}) {
    final scheme = AppColorSchemeBuilder.buildLightScheme(dynamicLight: dynamicLight);
    return _buildTheme(scheme);
  }

  static ThemeData dark({ColorScheme? dynamicDark}) {
    final scheme = AppColorSchemeBuilder.buildDarkScheme(dynamicDark: dynamicDark);
    return _buildTheme(scheme);
  }

  static ThemeData _buildTheme(ColorScheme scheme) {
    final textTheme = AppTypographyTokens.createTextTheme(scheme.onSurface);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      visualDensity: AppDensityTokens.standardDensity,
      scaffoldBackgroundColor: scheme.surface,
      
      cardTheme: CardThemeData(
        elevation: AppElevationTokens.level1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacingTokens.mdSm),
          side: BorderSide(color: scheme.outlineVariant, width: 1.0),
        ),
        color: scheme.surfaceContainerLow,
        margin: EdgeInsets.zero,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(AppDensityTokens.minTouchTargetSize, AppDensityTokens.minTouchTargetSize),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.lg,
            vertical: AppSpacingTokens.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacingTokens.mdSm),
          ),
          textStyle: AppTypographyTokens.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(AppDensityTokens.minTouchTargetSize, AppDensityTokens.minTouchTargetSize),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.lg,
            vertical: AppSpacingTokens.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacingTokens.mdSm),
          ),
          side: BorderSide(color: scheme.outline),
          textStyle: AppTypographyTokens.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AppDensityTokens.minTouchTargetSize, AppDensityTokens.minTouchTargetSize),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.md,
            vertical: AppSpacingTokens.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacingTokens.sm),
          ),
          textStyle: AppTypographyTokens.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.md,
          vertical: AppSpacingTokens.mdSm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacingTokens.sm),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacingTokens.sm),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacingTokens.sm),
          borderSide: BorderSide(color: scheme.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacingTokens.sm),
          borderSide: BorderSide(color: scheme.error),
        ),
        labelStyle: AppTypographyTokens.bodyMedium.copyWith(color: scheme.onSurfaceVariant),
        hintStyle: AppTypographyTokens.bodyMedium.copyWith(color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: AppElevationTokens.level0,
        scrolledUnderElevation: AppElevationTokens.level2,
        centerTitle: false,
        titleTextStyle: AppTypographyTokens.titleLarge.copyWith(color: scheme.onSurface),
      ),

      dataTableTheme: DataTableThemeData(
        dataRowMinHeight: AppDensityTokens.compactRowHeight,
        dataRowMaxHeight: AppDensityTokens.comfortableRowHeight,
        headingRowHeight: AppDensityTokens.comfortableRowHeight,
        headingRowColor: WidgetStateProperty.all(scheme.surfaceContainerHighest),
        headingTextStyle: AppTypographyTokens.titleSmall.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
        dataTextStyle: AppTypographyTokens.bodyMedium.copyWith(color: scheme.onSurface),
        horizontalMargin: AppSpacingTokens.md,
        columnSpacing: AppSpacingTokens.md,
      ),
    );
  }
}
