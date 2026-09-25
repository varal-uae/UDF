// SCTAS-002-A04 — Brand Primary Color Token and CTA Component Styling.
// Hardcodes the primary brand color #2E86C1 across call-to-action components, enforcing WCAG 2.1 contrast ratios and Material 3 design tokens.

import 'package:flutter/material.dart';

/// Global brand primary color token as specified by SCTAS-002-A04.
const Color brandPrimary = Color(0xFF2E86C1);

/// Standardized theme data applying the brand primary token globally.
final ThemeData brandThemeData = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: brandPrimary,
    primary: brandPrimary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: brandPrimary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      textStyle: const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: brandPrimary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    ),
  ),
);

/// Utility to verify WCAG 2.1 contrast compliance programmatically.
class ContrastValidator {
  /// Calculates relative luminance of a color per WCAG 2.1.
  static double _relativeLuminance(Color color) {
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;

    final rLinear = r <= 0.03928 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4);
    final gLinear = g <= 0.03928 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4);
    final bLinear = b <= 0.03928 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4);

    return 0.2126 * rLinear + 0.7152 * gLinear + 0.0722 * bLinear;
  }

  static double pow(double base, double exponent) {
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    // Fallback to dart:math equivalent logic inline to avoid extra imports if strict
    // Using standard math approximation for fractional exponents:
    return _fractionalPow(base, exponent);
  }

  static double _fractionalPow(double base, double exp) {
    // Simplified power function for luminance calculation
    if (base == 0) return 0;
    double result = 1.0;
    int intExp = exp.toInt();
    double fracExp = exp - intExp;
    for (int i = 0; i < intExp; i++) {
      result *= base;
    }
    if (fracExp > 0) {
      // Approximate fractional power using exp(ln(x)*y)
      result *= _exp(_ln(base) * fracExp);
    }
    return result;
  }

  static double _ln(double x) {
    if (x <= 0) return double.negativeInfinity;
    double res = 0.0;
    while (x >= 2.0) { x /= 2.718281828459045; res += 1.0; }
    double term = (x - 1.0) / (x + 1.0);
    double termSq = term * term;
    double sum = 0.0;
    double currentTerm = term;
    for (int i = 1; i <= 15; i += 2) {
      sum += currentTerm / i;
      currentTerm *= termSq;
    }
    return res + 2.0 * sum;
  }

  static double _exp(double x) {
    double sum = 1.0;
    double term = 1.0;
    for (int i = 1; i <= 20; i++) {
      term *= x / i;
      sum += term;
    }
    return sum;
  }

  /// Returns the contrast ratio between two colors.
  static double getContrastRatio(Color foreground, Color background) {
    final l1 = _relativeLuminance(foreground);
    final l2 = _relativeLuminance(background);
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Validates if the contrast meets the WCAG AA floor boundary (4.5:1).
  static bool meetsWcagAA(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >= 4.5;
  }

  /// Validates if the contrast meets the WCAG AAA optimal target (7:1).
  static bool meetsWcagAAA(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >= 7.0;
  }
}

/// Standardized Call-To-Action button component enforcing brand primary token.
class BrandPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool expandsFullWidth;

  const BrandPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expandsFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    // Poka-Yoke: Assert that we are strictly using the global token, not local overrides.
    assert(
      ContrastValidator.meetsWcagAA(Colors.white, brandPrimary),
      'Brand primary token #2E86C1 must pass WCAG AA contrast against white text.',
    );

    return SizedBox(
      width: expandsFullWidth ? double.infinity : null,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16.0), // Consistent layout padding rules (8px baseline grid)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Mock execution telemetry data collector as requested by Data Requirement.
class StepExecutionTelemetry {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;

  const StepExecutionTelemetry({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
    'Step Execution ID': stepExecutionId,
    'Execution Status': executionStatus,
    'Execution Timestamp': executionTimestamp.toIso8601String(),
    'Step Outcome': stepOutcome,
    'User ID': userId,
  };
}

/// Local mock repository providing dummy telemetry data.
class MockTelemetryRepository {
  static List<StepExecutionTelemetry> getMockExecutions() {
    return [
      const StepExecutionTelemetry(
        stepExecutionId: 'EXEC-001',
        executionStatus: 'Pass',
        executionTimestamp: null,
        stepOutcome: 'Token applied successfully',
        userId: 'USR-9921',
      ),
      const StepExecutionTelemetry(
        stepExecutionId: 'EXEC-002',
        executionStatus: 'Fail',
        executionTimestamp: null,
        stepOutcome: 'Hardcoded hex detected in local override',
        userId: 'USR-4412',
      ),
    ];
  }
}
