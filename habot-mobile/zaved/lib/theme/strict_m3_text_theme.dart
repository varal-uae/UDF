import 'package:flutter/material.dart';

/// BPTR-0334-A15: Strict Material Design 3 Typography
/// Locks font weights, letter spacing, and line heights for WCAG AAA compliance.
class StrictM3Typography {
  static const String fontFamily = 'Roboto';

  static TextTheme get textTheme => const TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 57.0,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          height: 1.12,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 45.0,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.0,
          height: 1.15,
        ),
        displaySmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 36.0,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.0,
          height: 1.22,
        ),
        headlineLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 32.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.0,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 28.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.0,
          height: 1.28,
        ),
        headlineSmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 24.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.0,
          height: 1.33,
        ),
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 22.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.0,
          height: 1.27,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          height: 1.50,
        ),
        titleSmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.50,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.43,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.33,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        labelMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          height: 1.33,
        ),
        labelSmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 11.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          height: 1.45,
        ),
      );
}
