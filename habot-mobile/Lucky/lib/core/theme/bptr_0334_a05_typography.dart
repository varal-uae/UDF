// BPTR-0334-A05 — Typographic scaling ratio design tokens and Material 3 text theme.
// Applies a fixed 1.25 Major Third scale, fluid clamp for legibility, and strips text decoration.

import 'package:flutter/material.dart';

class Bptr0334A05TypeScale {
  const Bptr0334A05TypeScale._();

  static const double baseSize = 16.0;
  static const double ratio = 1.25;

  static const double displayLarge = 48.83;
  static const double displayMedium = 39.06;
  static const double displaySmall = 31.25;
  static const double headlineLarge = 25.00;
  static const double headlineMedium = 20.00;
  static const double headlineSmall = 16.00;
  static const double titleLarge = 20.00;
  static const double titleMedium = 16.00;
  static const double titleSmall = 12.80;
  static const double bodyLarge = 16.00;
  static const double bodyMedium = 14.00;
  static const double bodySmall = 12.00;
  static const double labelLarge = 14.00;
  static const double labelMedium = 12.00;
  static const double labelSmall = 10.00;

  static double clampSize(double size, {double min = 12, double max = 48}) {
    return size.clamp(min, max).toDouble();
  }
}

class Bptr0334A05Typography {
  const Bptr0334A05Typography._();

  static TextTheme buildTextTheme({Color? color}) {
    final effectiveColor = color ?? const Color(0xFF1A1C1E);

    TextStyle style(double size, FontWeight weight) => TextStyle(
      fontSize: Bptr0334A05TypeScale.clampSize(size),
      fontWeight: weight,
      color: effectiveColor,
      decoration: TextDecoration.none,
      fontFamily: 'Roboto',
    );

    return TextTheme(
      displayLarge: style(Bptr0334A05TypeScale.displayLarge, FontWeight.w400),
      displayMedium: style(Bptr0334A05TypeScale.displayMedium, FontWeight.w400),
      displaySmall: style(Bptr0334A05TypeScale.displaySmall, FontWeight.w400),
      headlineLarge: style(Bptr0334A05TypeScale.headlineLarge, FontWeight.w400),
      headlineMedium: style(Bptr0334A05TypeScale.headlineMedium, FontWeight.w400),
      headlineSmall: style(Bptr0334A05TypeScale.headlineSmall, FontWeight.w400),
      titleLarge: style(Bptr0334A05TypeScale.titleLarge, FontWeight.w500),
      titleMedium: style(Bptr0334A05TypeScale.titleMedium, FontWeight.w500),
      titleSmall: style(Bptr0334A05TypeScale.titleSmall, FontWeight.w500),
      bodyLarge: style(Bptr0334A05TypeScale.bodyLarge, FontWeight.w400),
      bodyMedium: style(Bptr0334A05TypeScale.bodyMedium, FontWeight.w400),
      bodySmall: style(Bptr0334A05TypeScale.bodySmall, FontWeight.w400),
      labelLarge: style(Bptr0334A05TypeScale.labelLarge, FontWeight.w500),
      labelMedium: style(Bptr0334A05TypeScale.labelMedium, FontWeight.w500),
      labelSmall: style(Bptr0334A05TypeScale.labelSmall, FontWeight.w500),
    );
  }

  static const List<double> allowedFontSizes = [
    Bptr0334A05TypeScale.displayLarge,
    Bptr0334A05TypeScale.displayMedium,
    Bptr0334A05TypeScale.displaySmall,
    Bptr0334A05TypeScale.headlineLarge,
    Bptr0334A05TypeScale.headlineMedium,
    Bptr0334A05TypeScale.headlineSmall,
    Bptr0334A05TypeScale.titleLarge,
    Bptr0334A05TypeScale.titleMedium,
    Bptr0334A05TypeScale.titleSmall,
    Bptr0334A05TypeScale.bodyLarge,
    Bptr0334A05TypeScale.bodyMedium,
    Bptr0334A05TypeScale.bodySmall,
    Bptr0334A05TypeScale.labelLarge,
    Bptr0334A05TypeScale.labelMedium,
    Bptr0334A05TypeScale.labelSmall,
  ];

  static bool isAllowedFontSize(double size) =>
      allowedFontSizes.any((allowed) => (allowed - size).abs() < 0.01);
}
