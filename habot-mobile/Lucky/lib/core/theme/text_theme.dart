import 'package:flutter/material.dart';
import 'design_tokens.dart';

// BPTR-0237-A01 — Text theme definition.
// All 15 MD3 type styles sourced exclusively from HabotFontSize,
// HabotFontWeight, and HabotFontFamily tokens.

final TextTheme habotTextTheme = TextTheme(
  displayLarge: TextStyle(
    fontFamily: HabotFontFamily.display,
    fontSize:   HabotFontSize.displayLarge,
    fontWeight: FontWeight.values.firstWhere(
      (w) => w.index == HabotFontWeight.regular,
      orElse: () => FontWeight.w400,
    ),
  ),
  displayMedium: TextStyle(
    fontFamily: HabotFontFamily.display,
    fontSize:   HabotFontSize.displayMedium,
    fontWeight: FontWeight.w400,
  ),
  displaySmall: TextStyle(
    fontFamily: HabotFontFamily.display,
    fontSize:   HabotFontSize.displaySmall,
    fontWeight: FontWeight.w400,
  ),

  headlineLarge: TextStyle(
    fontFamily: HabotFontFamily.headline,
    fontSize:   HabotFontSize.headlineLarge,
    fontWeight: FontWeight.w600,
  ),
  headlineMedium: TextStyle(
    fontFamily: HabotFontFamily.headline,
    fontSize:   HabotFontSize.headlineMedium,
    fontWeight: FontWeight.w600,
  ),
  headlineSmall: TextStyle(
    fontFamily: HabotFontFamily.headline,
    fontSize:   HabotFontSize.headlineSmall,
    fontWeight: FontWeight.w600,
  ),

  titleLarge: TextStyle(
    fontFamily: HabotFontFamily.title,
    fontSize:   HabotFontSize.titleLarge,
    fontWeight: FontWeight.w500,
  ),
  titleMedium: TextStyle(
    fontFamily: HabotFontFamily.body,
    fontSize:   HabotFontSize.titleMedium,
    fontWeight: FontWeight.w500,
  ),
  titleSmall: TextStyle(
    fontFamily: HabotFontFamily.body,
    fontSize:   HabotFontSize.titleSmall,
    fontWeight: FontWeight.w500,
  ),

  bodyLarge: TextStyle(
    fontFamily: HabotFontFamily.body,
    fontSize:   HabotFontSize.bodyLarge,
    fontWeight: FontWeight.w400,
  ),
  bodyMedium: TextStyle(
    fontFamily: HabotFontFamily.body,
    fontSize:   HabotFontSize.bodyMedium,
    fontWeight: FontWeight.w400,
  ),
  bodySmall: TextStyle(
    fontFamily: HabotFontFamily.body,
    fontSize:   HabotFontSize.bodySmall,
    fontWeight: FontWeight.w400,
  ),

  labelLarge: TextStyle(
    fontFamily: HabotFontFamily.label,
    fontSize:   HabotFontSize.labelLarge,
    fontWeight: FontWeight.w500,
  ),
  labelMedium: TextStyle(
    fontFamily: HabotFontFamily.label,
    fontSize:   HabotFontSize.labelMedium,
    fontWeight: FontWeight.w500,
  ),
  labelSmall: TextStyle(
    fontFamily: HabotFontFamily.label,
    fontSize:   HabotFontSize.labelSmall,
    fontWeight: FontWeight.w500,
  ),
);
