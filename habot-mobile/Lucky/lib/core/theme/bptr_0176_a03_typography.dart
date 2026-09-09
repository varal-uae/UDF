// BPTR-0176-A03 — Lightweight Mobile Font Optimization & Asset Pipeline.
// Defines Material 3 typography with variable font weights, fluid scaling, fallback fonts, and performance budget checks to reduce mobile font load time.

import 'package:flutter/material.dart';

/// Hard performance budgets for font assets.
class Bptr0176A03FontBudget {
  static const double maxTotalPayloadKb = 30.0;
  static const double hardMaxAssetWeightKb = 40.0;
  static const int goodFontLoadTimeMs = 300;
}

/// Primary and fallback font families.
const String kPrimaryFontFamily = 'Roboto';
const String kFallbackFontFamily = 'sans-serif';

TextTheme buildBptr0176A03TextTheme({Color? textColor}) {
  final baseColor = textColor ?? Colors.black87;
  return TextTheme(
    displayLarge: TextStyle(fontFamily: kPrimaryFontFamily, fontSize: 40, fontWeight: FontWeight.w700, height: 1.2, color: baseColor),
    displayMedium: TextStyle(fontFamily: kPrimaryFontFamily, fontSize: 34, fontWeight: FontWeight.w700, height: 1.2, color: baseColor),
    displaySmall: TextStyle(fontFamily: kPrimaryFontFamily, fontSize: 28, fontWeight: FontWeight.w600, height: 1.2, color: baseColor),
    headlineLarge: TextStyle(fontFamily: kPrimaryFontFamily, fontSize: 24, fontWeight: FontWeight.w600, height: 1.3, color: baseColor),
    headlineMedium: TextStyle(fontFamily: kPrimaryFontFamily, fontSize: 20, fontWeight: FontWeight.w600, height: 1.3, color: baseColor),
    headlineSmall: TextStyle(fontFamily: kPrimaryFontFamily, fontSize: 18, fontWeight: FontWeight.w600, height: 1.3, color: baseColor),
    titleLarge: TextStyle(fontFamily: kPrimaryFontFamily, fontSize: 16, fontWeight: FontWeight.w600, height: 1.5, color: baseColor),
    titleMedium: TextStyle(fontFamily: kPrimaryFontFamily, fontSize: 15, fontWeight: FontWeight.w500, height: 1.5, color: baseColor),
    titleSmall: TextStyle(fontFamily: kPrimaryFontFamily, fontSize: 14, fontWeight: FontWeight.w500, height: 1.5, color: baseColor),
    bodyLarge: TextStyle(fontFamily: kPrimaryFontFamily, fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, letterSpacing: 0.15, color: baseColor),
    bodyMedium: TextStyle(fontFamily: kPrimaryFontFamily, fontSize: 15, fontWeight: FontWeight.w400, height: 1.5, letterSpacing: 0.1, color: baseColor),
    bodySmall: TextStyle(fontFamily: kPrimaryFontFamily, fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, letterSpacing: 0.1, color: baseColor),
    labelLarge: TextStyle(fontFamily: kPrimaryFontFamily, fontSize: 14, fontWeight: FontWeight.w500, height: 1.5, color: baseColor),
    labelMedium: TextStyle(fontFamily: kPrimaryFontFamily, fontSize: 13, fontWeight: FontWeight.w500, height: 1.5, color: baseColor),
    labelSmall: TextStyle(fontFamily: kPrimaryFontFamily, fontSize: 12, fontWeight: FontWeight.w400, height: 1.5, color: baseColor),
  );
}

double bptr0176A03FluidHeaderSize(double viewportWidth, {double min = 18, double max = 28}) {
  final clampedWidth = viewportWidth.clamp(320.0, 1280.0).toDouble();
  final t = (clampedWidth - 320.0) / (1280.0 - 320.0);
  return min + (max - min) * t;
}

bool bptr0176A03ValidateFontBudget(Map<String, int> fontAssetBytes) {
  final totalBytes = fontAssetBytes.values.fold<int>(0, (sum, bytes) => sum + bytes);
  final totalKb = totalBytes / 1024.0;
  final exceedsTotal = totalKb > Bptr0176A03FontBudget.maxTotalPayloadKb;
  final exceedsHard = fontAssetBytes.values.any((bytes) => (bytes / 1024.0) > Bptr0176A03FontBudget.hardMaxAssetWeightKb);
  return !exceedsTotal && !exceedsHard;
}