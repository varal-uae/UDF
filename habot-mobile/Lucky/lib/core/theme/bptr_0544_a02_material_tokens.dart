// BPTR-0544-A02 — Material Design state color tokens and typography foundation.
// Provides immutable active/on and inactive/off color assignments plus Material 3 typography tokens to eliminate visual drift.

import 'package:flutter/material.dart';

/// Centralized Material Design token assignments for BPTR-0544-A02.
@immutable
class Bptr0544A02MaterialTokens extends ThemeExtension<Bptr0544A02MaterialTokens> {
  const Bptr0544A02MaterialTokens({
    required this.activeOnColor,
    required this.inactiveOffColor,
    required this.activeOnTextColor,
    required this.inactiveOffTextColor,
    required this.highContrastBorderColor,
    this.typography,
  });

  final Color activeOnColor;
  final Color inactiveOffColor;
  final Color activeOnTextColor;
  final Color inactiveOffTextColor;
  final Color highContrastBorderColor;
  final TextTheme? typography;

  static const Color defaultActiveOnColor = Color(0xFF006C4C);
  static const Color defaultInactiveOffColor = Color(0xFFE0E0E0);
  static const Color defaultActiveOnTextColor = Color(0xFFFFFFFF);
  static const Color defaultInactiveOffTextColor = Color(0xFF1C1B1F);
  static const Color defaultHighContrastBorderColor = Color(0xFF49454F);

  static final Bptr0544A02MaterialTokens light = Bptr0544A02MaterialTokens(
    activeOnColor: defaultActiveOnColor,
    inactiveOffColor: defaultInactiveOffColor,
    activeOnTextColor: defaultActiveOnTextColor,
    inactiveOffTextColor: defaultInactiveOffTextColor,
    highContrastBorderColor: defaultHighContrastBorderColor,
    typography: Typography.material2021().black,
  );

  @override
  Bptr0544A02MaterialTokens copyWith({
    Color? activeOnColor,
    Color? inactiveOffColor,
    Color? activeOnTextColor,
    Color? inactiveOffTextColor,
    Color? highContrastBorderColor,
    TextTheme? typography,
  }) {
    return Bptr0544A02MaterialTokens(
      activeOnColor: activeOnColor ?? this.activeOnColor,
      inactiveOffColor: inactiveOffColor ?? this.inactiveOffColor,
      activeOnTextColor: activeOnTextColor ?? this.activeOnTextColor,
      inactiveOffTextColor: inactiveOffTextColor ?? this.inactiveOffTextColor,
      highContrastBorderColor: highContrastBorderColor ?? this.highContrastBorderColor,
      typography: typography ?? this.typography,
    );
  }

  @override
  Bptr0544A02MaterialTokens lerp(ThemeExtension<Bptr0544A02MaterialTokens>? other, double t) {
    if (other is! Bptr0544A02MaterialTokens) return this;
    return Bptr0544A02MaterialTokens(
      activeOnColor: Color.lerp(activeOnColor, other.activeOnColor, t)!,
      inactiveOffColor: Color.lerp(inactiveOffColor, other.inactiveOffColor, t)!,
      activeOnTextColor: Color.lerp(activeOnTextColor, other.activeOnTextColor, t)!,
      inactiveOffTextColor: Color.lerp(inactiveOffTextColor, other.inactiveOffTextColor, t)!,
      highContrastBorderColor: Color.lerp(highContrastBorderColor, other.highContrastBorderColor, t)!,
      typography: TextTheme.lerp(typography, other.typography, t),
    );
  }
}