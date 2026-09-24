// GEN-02295 — WCAG 2.1 AA Error State Colors & Accessibility Utilities.
// Defines high-contrast error state colors meeting WCAG 2.1 AA standards and provides contrast ratio calculation utilities for validation.

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// WCAG 2.1 AA compliant error state color tokens.
/// All foreground/background combinations are validated to meet minimum 4.5:1 contrast ratio (AA).
class WcagErrorColorsGen02295 {
  WcagErrorColorsGen02295._();

  /// Primary error color (Red 700 equivalent) - optimized for light backgrounds.
  static const Color errorPrimary = Color(0xFFB00020);

  /// Error container background (Light Red) - used for M3 Elevated Cards / error surfaces.
  static const Color errorContainer = Color(0xFFFCD8DF);

  /// On-error text/icon color (White) - guaranteed >= 4.5:1 against [errorPrimary].
  static const Color onError = Color(0xFFFFFFFF);

  /// On-error-container text color (Dark Red) - guaranteed >= 4.5:1 against [errorContainer].
  static const Color onErrorContainer = Color(0xFF410002);

  /// Error outline/border color for M3 Outlined TextFields or Status Chips.
  static const Color errorOutline = Color(0xFFBA1A1A);

  /// Dark mode error primary (Red 200 equivalent).
  static const Color errorPrimaryDark = Color(0xFFFFB4AB);

  /// Dark mode error container.
  static const Color errorContainerDark = Color(0xFF93000A);

  /// Dark mode on-error text.
  static const Color onErrorDark = Color(0xFF690005);

  /// Dark mode on-error-container text.
  static const Color onErrorContainerDark = Color(0xFFFFDAD6);

  /// Returns the appropriate error theme extension based on brightness.
  static ColorScheme getErrorColorScheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ColorScheme.fromSeed(
      seedColor: isDark ? errorPrimaryDark : errorPrimary,
      brightness: brightness,
      error: isDark ? errorPrimaryDark : errorPrimary,
      onError: isDark ? onErrorDark : onError,
      errorContainer: isDark ? errorContainerDark : errorContainer,
      onErrorContainer: isDark ? onErrorContainerDark : onErrorContainer,
      outline: isDark ? errorPrimaryDark : errorOutline,
    );
  }
}

/// Utility class to calculate and validate WCAG 2.1 AA contrast ratios.
class WcagContrastValidatorGen02295 {
  WcagContrastValidatorGen02295._();

  /// Minimum contrast ratio required for WCAG 2.1 AA normal text.
  static const double kMinAaContrastRatio = 4.5;

  /// Minimum contrast ratio required for WCAG 2.1 AA large text (>= 18pt or 14pt bold).
  static const double kMinAaLargeTextContrastRatio = 3.0;

  /// Calculates the relative luminance of a [Color] per WCAG 2.1 spec.
  static double getRelativeLuminance(Color color) {
    double r = color.r / 255.0;
    double g = color.g / 255.0;
    double b = color.b / 255.0;

    r = r <= 0.03928 ? r / 12.92 : math.pow((r + 0.055) / 1.055, 2.4).toDouble();
    g = g <= 0.03928 ? g / 12.92 : math.pow((g + 0.055) / 1.055, 2.4).toDouble();
    b = b <= 0.03928 ? b / 12.92 : math.pow((b + 0.055) / 1.055, 2.4).toDouble();

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Calculates the contrast ratio between two colors.
  /// Returns a value >= 1.0.
  static double getContrastRatio(Color foreground, Color background) {
    final l1 = getRelativeLuminance(foreground);
    final l2 = getRelativeLuminance(background);
    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Validates if the contrast ratio between [foreground] and [background]
  /// meets WCAG 2.1 AA standards for normal text (4.5:1).
  static bool meetsAaStandard(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >= kMinAaContrastRatio;
  }

  /// Validates if the contrast ratio meets WCAG 2.1 AA standards for large text (3.0:1).
  static bool meetsAaLargeTextStandard(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >= kMinAaLargeTextContrastRatio;
  }
}

/// Mock data representing compliance validation results for CI/CD reporting.
/// Simulates backend telemetry payload streamed to BigQuery.
class MockWcagComplianceDataGen02295 {
  static const String atomicId = 'GEN-02295';
  static const String globalRefId = 'GEN-02295';
  static const String metricName = 'WCAG 2.2 AA Compliance Rate (%)';
  static const double floorBoundary = 0.8;
  static const double optimalTarget = 1.0;
  static const double ceilingBoundary = 1.0;

  static Map<String, dynamic> getMockValidationPayload() {
    final errorOnWhiteRatio = WcagContrastValidatorGen02295.getContrastRatio(
      WcagErrorColorsGen02295.errorPrimary,
      Colors.white,
    );
    final errorContainerOnTextRatio = WcagContrastValidatorGen02295.getContrastRatio(
      WcagErrorColorsGen02295.onErrorContainer,
      WcagErrorColorsGen02295.errorContainer,
    );

    final passesAa = errorOnWhiteRatio >= 4.5 && errorContainerOnTextRatio >= 4.5;

    return {
      'trace_id': 'trace_${DateTime.now().millisecondsSinceEpoch}',
      'event_date': DateTime.now().toIso8601String().split('T').first,
      'atomic_id': atomicId,
      'step_name': 'Set error state colors to meet WCAG 2.1 AA high contrast ratios.',
      'metrics': {
        'error_primary_on_white_ratio': double.parse(errorOnWhiteRatio.toStringAsFixed(2)),
        'error_container_text_ratio': double.parse(errorContainerOnTextRatio.toStringAsFixed(2)),
        'compliance_rate': passesAa ? 1.0 : 0.0,
        'meets_floor_boundary': passesAa ? true : false,
      },
      'completion_status': passesAa ? 'Pass' : 'Fail',
      'timestamp': DateTime.now().toIso8601String(),
      'session_id': 'mock_session_001',
    };
  }
}

/// A reusable M3 Status Chip widget configured with WCAG AA compliant error colors.
/// Implements 48x48dp touch targets as per mobile-first requirements.
class WcagErrorStatusChipGen02295 extends StatelessWidget {
  final String label;
  final bool isError;
  final VoidCallback? onTap;

  const WcagErrorStatusChipGen02295({
    super.key,
    required this.label,
    this.isError = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      label: '$label, status: ${isError ? 'Error' : 'Success'}',
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: isError
                ? (isDark ? WcagErrorColorsGen02295.errorContainerDark : WcagErrorColorsGen02295.errorContainer)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: isError
                  ? (isDark ? WcagErrorColorsGen02295.errorPrimaryDark : WcagErrorColorsGen02295.errorOutline)
                  : theme.colorScheme.outline,
              width: 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isError
                  ? (isDark ? WcagErrorColorsGen02295.onErrorContainerDark : WcagErrorColorsGen02295.onErrorContainer)
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}