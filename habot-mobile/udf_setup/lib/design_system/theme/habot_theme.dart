/// AISS: TTMCS-001-A01 -- substep 2 "Instantiate the global theme configuration
/// adapter at the layout layer."
///
/// This is the single place a `ThemeData` may be constructed. Every colour it
/// uses comes from [HabotColors]; every metric from the token files. Nothing
/// downstream is permitted to build its own ThemeData.
library;

import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';
import '../tokens/elevation_tokens.dart';
import '../tokens/shape_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'habot_theme_extension.dart';

class HabotTheme {
  const HabotTheme._();

  /// Library identity, recorded as AISS evidence for TTMCS-001
  /// (Library Name / Library Version / Library Location Path).
  static const String libraryName = 'habot_design_system';
  static const String libraryVersion = '0.1.0';
  static const String libraryLocationPath = 'lib/design_system';

  static ColorScheme _colorScheme(
    HabotColorScheme tokens,
    Brightness brightness,
  ) {
    // Start from the MD3 tonal algorithm so any role we do not pin is still a
    // valid Material scheme, then override every audited role with the exact
    // brand token. Pinning is what makes the contrast audit deterministic.
    return ColorScheme.fromSeed(
      seedColor: HabotColors.seedPrimary,
      brightness: brightness,
    ).copyWith(
      primary: tokens.primary,
      onPrimary: tokens.onPrimary,
      primaryContainer: tokens.primaryContainer,
      onPrimaryContainer: tokens.onPrimaryContainer,
      secondary: tokens.secondary,
      onSecondary: tokens.onSecondary,
      secondaryContainer: tokens.secondaryContainer,
      onSecondaryContainer: tokens.onSecondaryContainer,
      tertiary: tokens.tertiary,
      onTertiary: tokens.onTertiary,
      tertiaryContainer: tokens.tertiaryContainer,
      onTertiaryContainer: tokens.onTertiaryContainer,
      error: tokens.error,
      onError: tokens.onError,
      errorContainer: tokens.errorContainer,
      onErrorContainer: tokens.onErrorContainer,
      surface: tokens.surface,
      onSurface: tokens.onSurface,
      onSurfaceVariant: tokens.onSurfaceVariant,
      surfaceContainerLowest: tokens.surfaceContainerLowest,
      surfaceContainerLow: tokens.surfaceContainerLow,
      surfaceContainer: tokens.surfaceContainer,
      surfaceContainerHigh: tokens.surfaceContainerHigh,
      surfaceContainerHighest: tokens.surfaceContainerHighest,
      outline: tokens.outline,
      outlineVariant: tokens.outlineVariant,
      inverseSurface: tokens.inverseSurface,
      onInverseSurface: tokens.onInverseSurface,
    );
  }

  static ThemeData _build(HabotColorScheme tokens, Brightness brightness) {
    final ColorScheme scheme = _colorScheme(tokens, brightness);
    final bool isDark = brightness == Brightness.dark;

    return ThemeData(
      // Material 3 is mandatory for this codebase.
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: HabotTypography.textTheme(),
      fontFamily: HabotTypography.fontName,
      scaffoldBackgroundColor: scheme.surface,

      // TTMCS-004 UX decision: in dark mode, layering is expressed with
      // structural elevation overlays rather than deep drop shadows. Setting
      // the shadow to transparent forces components onto the surface-tint
      // ladder instead.
      shadowColor: isDark ? Colors.transparent : scheme.shadow,
      applyElevationOverlayColor: isDark,

      // Density: MD3 standard. The dense-table values live in HabotDensity and
      // are applied per-component, not globally, so ordinary controls keep
      // their 48dp targets.
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,

      cardTheme: CardThemeData(
        elevation: HabotElevation.level1,
        margin: const EdgeInsets.all(HabotSpacing.xs),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HabotShape.md),
        ),
      ),

      appBarTheme: AppBarThemeData(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: scheme.surfaceTint,
        elevation: HabotElevation.level0,
        scrolledUnderElevation: HabotElevation.level2,
        centerTitle: false,
      ),

      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: HabotSpacing.md,
          vertical: HabotSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HabotShape.xs),
          borderSide: BorderSide(
            color: scheme.outline,
            width: HabotShape.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(HabotShape.xs),
          borderSide: BorderSide(
            color: scheme.primary,
            width: HabotShape.focusBorderWidth,
          ),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: HabotShape.borderWidth,
        space: HabotSpacing.md,
      ),

      // Tokens that have no ThemeData slot travel as a typed extension, so a
      // widget reads them with Theme.of(context).extension<HabotTokens>().
      extensions: <ThemeExtension<dynamic>>[
        HabotTokens.forBrightness(brightness),
      ],
    );
  }

  static ThemeData light() => _build(HabotColors.light, Brightness.light);

  static ThemeData dark() => _build(HabotColors.dark, Brightness.dark);
}
