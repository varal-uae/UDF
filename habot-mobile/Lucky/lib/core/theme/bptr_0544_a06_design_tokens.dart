// BPTR-0544-A06 — Standardized Material Design Typography and Colors.
// Central design tokens for font tiers, line heights, weights, and high-contrast input colors.
// Enforces unalterable brand rules and blocks invalid local styling variations.

import 'package:flutter/material.dart';

class Bptr0544A06DesignTokens {
  Bptr0544A06DesignTokens._();

  // Color tokens (Material 3 baseline)
  static const Color primary = Color(0xFF0057B8);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFD6E3FF);
  static const Color onPrimaryContainer = Color(0xFF001B3F);
  static const Color secondary = Color(0xFF565E71);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFDAE2F9);
  static const Color onSecondaryContainer = Color(0xFF131C2B);
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);
  static const Color background = Color(0xFFFDFBFF);
  static const Color onBackground = Color(0xFF1A1B20);
  static const Color surface = Color(0xFFFDFBFF);
  static const Color onSurface = Color(0xFF1A1B20);
  static const Color surfaceVariant = Color(0xFFE0E2EC);
  static const Color onSurfaceVariant = Color(0xFF44474F);
  static const Color outline = Color(0xFF74777F);
  static const Color outlineVariant = Color(0xFFC4C6D0);
  static const Color inputFill = Color(0xFFF3F6FF);
  static const Color inputBorder = Color(0xFF0057B8);
  static const Color chartPrimary = Color(0xFF0057B8);
  static const Color chartSecondary = Color(0xFF565E71);
  static const Color chartTertiary = Color(0xFF3E6B4F);

  // Typography token metadata: Font Name, Size, Line Height, Weight, File Path
  static const String fontFamilyRoboto = 'Roboto';
  static const String fontFamilyRobotoMono = 'RobotoMono';
  static const String fontFamilyFilePath = 'assets/fonts/Roboto/Roboto-Regular.ttf';
  static const String fontFamilyMonoFilePath = 'assets/fonts/RobotoMono/RobotoMono-Regular.ttf';

  // Display Large: 57px font, 64px line height -> factor 64/57
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamilyRoboto,
    fontSize: 57,
    height: 64 / 57,
    fontWeight: FontWeight.w400,
  );
  // Display Medium: 45px font, 52px line height
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamilyRoboto,
    fontSize: 45,
    height: 52 / 45,
    fontWeight: FontWeight.w400,
  );
  // Display Small: 36px font, 44px line height
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamilyRoboto,
    fontSize: 36,
    height: 44 / 36,
    fontWeight: FontWeight.w400,
  );
  // Headline Large: 32px font, 40px line height
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamilyRoboto,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w600,
  );
  // Headline Medium: 28px font, 36px line height
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamilyRoboto,
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w600,
  );
  // Headline Small: 24px font, 32px line height
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamilyRoboto,
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
  );
  // Title Large: 22px font, 28px line height
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamilyRoboto,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w500,
  );
  // Title Medium: 16px font, 24px line height
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamilyRoboto,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500,
  );
  // Title Small: 14px font, 20px line height
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamilyRoboto,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
  );
  // Body Large: 16px font, 24px line height
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamilyRoboto,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );
  // Body Medium: 14px font, 20px line height
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilyRoboto,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );
  // Body Small: 12px font, 16px line height
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamilyRoboto,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
  );
  // Label Large: 14px font, 20px line height
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamilyRoboto,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
  );
  // Label Medium: 12px font, 16px line height
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamilyRoboto,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
  );
  // Label Small: 11px font, 16px line height
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamilyRoboto,
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w600,
  );

  static const TextTheme materialTextTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );

  static const TextStyle inputHintStyle = TextStyle(
    fontFamily: fontFamilyRoboto,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: onSurfaceVariant,
  );

  static const TextStyle inputErrorStyle = TextStyle(
    fontFamily: fontFamilyRoboto,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    color: error,
  );

  static const InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: inputFill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: inputBorder, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: inputBorder, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: inputBorder, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: error, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: error, width: 2),
    ),
    labelStyle: labelLarge,
    hintStyle: inputHintStyle,
    errorStyle: inputErrorStyle,
  );
}
