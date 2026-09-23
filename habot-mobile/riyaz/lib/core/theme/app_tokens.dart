import 'package:flutter/material.dart';

/// Material 3 design tokens for Habot mobile UI components.
abstract final class AppTokens {
  static const double minTouchTarget = 48;
  static const double cardRadius = 16;
  static const double cardPadding = 16;
  static const double headerIconPadding = 8;
  static const double metricSpacing = 12;
  static const Duration snackBarDuration = Duration(seconds: 2);

  static ColorScheme colorScheme(Brightness brightness) {
    return ColorScheme.fromSeed(
      seedColor: const Color(0xFF0B6E4F),
      brightness: brightness,
    );
  }

  static TextTheme textTheme(ColorScheme scheme) {
    return Typography.material2021(platform: TargetPlatform.android)
        .black
        .apply(
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
        );
  }
}
