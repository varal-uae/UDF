// AWCV-002-01 — Programmatic Length Metrics & Design System Adherence Validator.
// Enforces string length, text line constraints, and design-system adherence metrics across UI components.

class DesignLengthMetricsValidator {
  DesignLengthMetricsValidator._();

  /// Validates if microcopy string length stays within design system bounds (e.g. max 60 chars for titles).
  static bool validateMicrocopyLength(String text, {int maxChars = 60}) {
    return text.trim().length <= maxChars;
  }

  /// Calculates design-system adherence rate based on valid vs invalid UI properties.
  static double calculateAdherenceRate({
    required int totalCheckedProperties,
    required int validProperties,
  }) {
    if (totalCheckedProperties == 0) return 1.0;
    return (validProperties / totalCheckedProperties).clamp(0.0, 1.0);
  }

  /// Checks if adherence rate meets Material Design 3 guidelines (Floor: 85%, Optimal: 95%).
  static bool meetsAdherenceFloor(double rate, {double floor = 0.85}) {
    return rate >= floor;
  }
}
