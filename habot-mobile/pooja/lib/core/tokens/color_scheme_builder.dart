import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'color_palette.dart';

abstract class AppColorSchemeBuilder {
  static ColorScheme get lightColorScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: AppColorPalette.lightPrimary,
        onPrimary: AppColorPalette.lightOnPrimary,
        primaryContainer: AppColorPalette.lightPrimaryContainer,
        onPrimaryContainer: AppColorPalette.lightOnPrimaryContainer,
        secondary: AppColorPalette.lightSecondary,
        onSecondary: AppColorPalette.lightOnSecondary,
        secondaryContainer: AppColorPalette.lightSecondaryContainer,
        onSecondaryContainer: AppColorPalette.lightOnSecondaryContainer,
        tertiary: AppColorPalette.lightTertiary,
        onTertiary: AppColorPalette.lightOnTertiary,
        tertiaryContainer: AppColorPalette.lightTertiaryContainer,
        onTertiaryContainer: AppColorPalette.lightOnTertiaryContainer,
        error: AppColorPalette.lightError,
        onError: AppColorPalette.lightOnError,
        errorContainer: AppColorPalette.lightErrorContainer,
        onErrorContainer: AppColorPalette.lightOnErrorContainer,
        surface: AppColorPalette.lightSurface,
        onSurface: AppColorPalette.lightOnSurface,
        surfaceContainerHighest: AppColorPalette.lightSurfaceVariant,
        onSurfaceVariant: AppColorPalette.lightOnSurfaceVariant,
        outline: AppColorPalette.lightOutline,
        outlineVariant: AppColorPalette.lightOutlineVariant,
      );

  static ColorScheme get darkColorScheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColorPalette.darkPrimary,
        onPrimary: AppColorPalette.darkOnPrimary,
        primaryContainer: AppColorPalette.darkPrimaryContainer,
        onPrimaryContainer: AppColorPalette.darkOnPrimaryContainer,
        secondary: AppColorPalette.darkSecondary,
        onSecondary: AppColorPalette.darkOnSecondary,
        secondaryContainer: AppColorPalette.darkSecondaryContainer,
        onSecondaryContainer: AppColorPalette.darkOnSecondaryContainer,
        tertiary: AppColorPalette.darkTertiary,
        onTertiary: AppColorPalette.darkOnTertiary,
        tertiaryContainer: AppColorPalette.darkTertiaryContainer,
        onTertiaryContainer: AppColorPalette.darkOnTertiaryContainer,
        error: AppColorPalette.darkError,
        onError: AppColorPalette.darkOnError,
        errorContainer: AppColorPalette.darkErrorContainer,
        onErrorContainer: AppColorPalette.darkOnErrorContainer,
        surface: AppColorPalette.darkSurface,
        onSurface: AppColorPalette.darkOnSurface,
        surfaceContainerHighest: AppColorPalette.darkSurfaceVariant,
        onSurfaceVariant: AppColorPalette.darkOnSurfaceVariant,
        outline: AppColorPalette.darkOutline,
        outlineVariant: AppColorPalette.darkOutlineVariant,
      );

  static ColorScheme buildLightScheme({ColorScheme? dynamicLight}) {
    if (dynamicLight != null) {
      return dynamicLight.harmonized();
    }
    return ColorScheme.fromSeed(
      seedColor: AppColorPalette.primarySeed,
      brightness: Brightness.light,
    );
  }

  static ColorScheme buildDarkScheme({ColorScheme? dynamicDark}) {
    if (dynamicDark != null) {
      return dynamicDark.harmonized();
    }
    return ColorScheme.fromSeed(
      seedColor: AppColorPalette.primarySeed,
      brightness: Brightness.dark,
    );
  }
}
