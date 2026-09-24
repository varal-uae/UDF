// GEN-02054 — Typography Configuration defining base, minimum, and maximum font sizes.
// Establishes the foundational font size constraints (14sp to 18sp) for Material 3 responsive typography scaling.

import 'package:flutter/material.dart';

/// Defines the base, minimum, and maximum font sizes for the application.
/// Ensures consistent typography scaling across mobile and desktop layouts.
class TypographyConfigGen02054 {
  const TypographyConfigGen02054._();

  /// Minimum allowed font size (14sp equivalent).
  static const double minFontSize = 14.0;

  /// Base font size used as the standard reference (16sp equivalent).
  static const double baseFontSize = 16.0;

  /// Maximum allowed font size (18sp equivalent).
  static const double maxFontSize = 18.0;

  /// Clamps any given [fontSize] between [minFontSize] and [maxFontSize].
  static double clampFontSize(double fontSize) {
    return fontSize.clamp(minFontSize, maxFontSize).toDouble();
  }

  /// Generates a scaled [TextStyle] constrained within the defined font boundaries.
  static TextStyle getScaledTextStyle({
    required TextStyle baseStyle,
    required double scaleFactor,
  }) {
    final double originalSize = baseStyle.fontSize ?? baseFontSize;
    final double scaledSize = originalSize * scaleFactor;
    final double clampedSize = clampFontSize(scaledSize);

    return baseStyle.copyWith(fontSize: clampedSize);
  }

  /// Provides a baseline M3-compliant [TextTheme] using the configured font sizes.
  static TextTheme get textTheme {
    return TextTheme(
      bodySmall: TextStyle(fontSize: minFontSize),
      bodyMedium: TextStyle(fontSize: baseFontSize),
      bodyLarge: TextStyle(fontSize: maxFontSize),
      labelSmall: TextStyle(fontSize: minFontSize),
      labelMedium: TextStyle(fontSize: baseFontSize),
      labelLarge: TextStyle(fontSize: maxFontSize),
    );
  }
}

/// Mock data representing step completion metrics for engineering console validation.
class TypographyStepMockDataGen02054 {
  const TypographyStepMockDataGen02054._();

  static const Map<String, dynamic> stepCompletionPayload = {
    'atomic_id': 'GEN-02054',
    'global_reference_id': 'GEN-02054',
    'step_name': 'Define the base, minimum, and maximum font sizes (e.g., 14sp to 18sp).',
    'completion_status': 'Complete',
    'step_completion_rate_percent': 100.0,
    'floor_boundary': 90.0,
    'optimal_target': 99.0,
    'ceiling_boundary': 100.0,
    'reference_standard': 'ISO/IEC 27001:2022 General Standards',
    'event_timestamp': '2026-09-24T12:00:00Z',
    'trace_id': 'mock-trace-gen-02054-001',
  };
}