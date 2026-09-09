// BPTR-0334-A09 — Mobile typography token library with Material Design Type Scale and fluid scaling.
// Provides restricted, decoration-free text styles that scale fluidly by viewport width to preserve readability without zoom.
import 'package:flutter/material.dart';

/// BPTR-0334-A09: Typography tokens generated from a modular type scale.
abstract final class Bptr0334A09Typography {
  Bptr0334A09Typography._();

  static const double baseFontSize = 16.0;
  static const double scaleRatio = 1.250;
  static const double minScaleWidth = 320.0;
  static const double maxScaleWidth = 1440.0;

  static double fluidSize(
    BuildContext context, {
    required double min,
    required double preferred,
    required double max,
  }) {
    final double width = MediaQuery.sizeOf(context).width;
    final double t = ((width - minScaleWidth) / (maxScaleWidth - minScaleWidth))
        .clamp(0.0, 1.0)
        .toDouble();
    return (min + ((preferred - min) * t)).clamp(min, max).toDouble();
  }

  static TextTheme textTheme(BuildContext context) {
    return TextTheme(
      displayLarge: _style(context, 57, 64, 0.0, FontWeight.w400),
      displayMedium: _style(context, 45, 52, 0.0, FontWeight.w400),
      displaySmall: _style(context, 36, 44, 0.0, FontWeight.w400),
      headlineLarge: _style(context, 32, 40, 0.0, FontWeight.w400),
      headlineMedium: _style(context, 28, 36, 0.0, FontWeight.w400),
      headlineSmall: _style(context, 24, 32, 0.0, FontWeight.w400),
      titleLarge: _style(context, 22, 28, 0.0, FontWeight.w500),
      titleMedium: _style(context, 16, 24, 0.15, FontWeight.w500),
      titleSmall: _style(context, 14, 20, 0.1, FontWeight.w500),
      bodyLarge: _style(context, 16, 24, 0.5, FontWeight.w400),
      bodyMedium: _style(context, 14, 20, 0.25, FontWeight.w400),
      bodySmall: _style(context, 12, 16, 0.4, FontWeight.w400),
      labelLarge: _style(context, 14, 20, 0.1, FontWeight.w500),
      labelMedium: _style(context, 12, 16, 0.5, FontWeight.w500),
      labelSmall: _style(context, 11, 16, 0.5, FontWeight.w500),
    );
  }

  static TextStyle _style(
    BuildContext context,
    double minSize,
    double preferredSize,
    double letterSpacing,
    FontWeight weight,
  ) {
    final double maxSize = preferredSize * scaleRatio;
    return TextStyle(
      fontSize: fluidSize(
        context,
        min: minSize * 0.8,
        preferred: preferredSize,
        max: maxSize,
      ),
      fontWeight: weight,
      letterSpacing: letterSpacing,
      height: 1.2,
      decoration: TextDecoration.none,
      fontStyle: FontStyle.normal,
    );
  }
}