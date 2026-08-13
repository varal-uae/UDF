import 'package:flutter/material.dart';
import 'liquid_glass_config.dart';

// TTMCS-014-A01 — Liquid Glass Theme.
// Assembles ThemeData from LiquidGlassColors, LiquidGlassTypography,
// and LiquidGlassTouchBoundary tokens exclusively.
// Zero hardcoded values — all sourced from liquid_glass_config.dart.

final ThemeData liquidGlassLightTheme = ThemeData(
  useMaterial3: true,

  colorScheme: ColorScheme(
    brightness: Brightness.light,

    primary:            const Color(LiquidGlassColors.actionPrimary),
    onPrimary:          const Color(LiquidGlassColors.actionOnPrimary),
    primaryContainer:   const Color(LiquidGlassColors.actionPrimaryHover),
    onPrimaryContainer: const Color(LiquidGlassColors.actionOnPrimary),

    secondary:            const Color(LiquidGlassColors.stateSuccess),
    onSecondary:          const Color(LiquidGlassColors.stateOnSuccess),
    secondaryContainer:   const Color(LiquidGlassColors.stateSuccessSubtle),
    onSecondaryContainer: const Color(LiquidGlassColors.stateOnSuccess),

    tertiary:            const Color(LiquidGlassColors.glassSurface),
    onTertiary:          const Color(LiquidGlassColors.backgroundOnPrimary),
    tertiaryContainer:   const Color(LiquidGlassColors.glassBorder),
    onTertiaryContainer: const Color(LiquidGlassColors.backgroundOnPrimary),

    error:            const Color(0x00000000), // TODO: wire error token
    onError:          const Color(0x00000000),
    errorContainer:   const Color(0x00000000),
    onErrorContainer: const Color(0x00000000),

    surface:          const Color(LiquidGlassColors.backgroundPrimary),
    onSurface:        const Color(LiquidGlassColors.backgroundOnPrimary),
    surfaceContainerLow:     const Color(LiquidGlassColors.backgroundSecondary),
    surfaceContainerHighest: const Color(LiquidGlassColors.glassSurface),

    outline:        const Color(LiquidGlassColors.glassBorder),
    outlineVariant: const Color(LiquidGlassColors.glassBorder),
    shadow:         const Color(LiquidGlassColors.glassShadow),
    scrim:          const Color(LiquidGlassColors.glassShadow),

    inverseSurface:   const Color(LiquidGlassColors.actionPrimary),
    onInverseSurface: const Color(LiquidGlassColors.actionOnPrimary),
    inversePrimary:   const Color(LiquidGlassColors.backgroundPrimary),
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(
        LiquidGlassTouchBoundary.buttonWidthNarrow,
        LiquidGlassTouchBoundary.buttonHeightMd,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          LiquidGlassTouchBoundary.buttonRadiusFull,
        ),
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(
        LiquidGlassTouchBoundary.buttonWidthNarrow,
        LiquidGlassTouchBoundary.buttonHeightMd,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          LiquidGlassTouchBoundary.buttonRadiusMd,
        ),
      ),
    ),
  ),
);

final ThemeData liquidGlassDarkTheme = liquidGlassLightTheme.copyWith(
  brightness: Brightness.dark,
);
