// GEN-00626 — Strict Mobile Input Masking (Poka-Yoke) with invalid-key haptics.
// Enforces allowed input patterns and max length; triggers HapticFeedback.lightImpact()
// when an invalid key press is rejected. M3-compatible and UI-independent.

import 'dart:async';

import 'package:flutter/services.dart';

/// A strict [TextInputFormatter] that rejects invalid edits and provides
/// immediate haptic feedback for invalid key press attempts.
class StrictMobileInputMasking extends TextInputFormatter {
  StrictMobileInputMasking({
    required this.allowedPattern,
    this.maxLength,
    this.invalidHaptic = true,
  }) : assert(maxLength == null || maxLength > 0);

  /// Pattern that the full resulting text must satisfy.
  final RegExp allowedPattern;

  /// Optional maximum length for the resulting text.
  final int? maxLength;

  /// Whether to invoke [HapticFeedback.lightImpact] on invalid attempts.
  final bool invalidHaptic;

  /// Digits-only masking for numeric data-entry fields.
  factory StrictMobileInputMasking.digitsOnly({
    int? maxLength,
    bool invalidHaptic = true,
  }) {
    return StrictMobileInputMasking(
      allowedPattern: RegExp(r'^[0-9]*$'),
      maxLength: maxLength,
      invalidHaptic: invalidHaptic,
    );
  }

  /// UAE mobile number masking: digits only, capped at 10 digits by default.
  factory StrictMobileInputMasking.uaePhone({
    int maxLength = 10,
    bool invalidHaptic = true,
  }) {
    return StrictMobileInputMasking(
      allowedPattern: RegExp(r'^[0-9]*$'),
      maxLength: maxLength,
      invalidHaptic: invalidHaptic,
    );
  }

  /// Alphanumeric masking for structured data-entry fields.
  factory StrictMobileInputMasking.alphanumeric({
    int? maxLength,
    bool invalidHaptic = true,
  }) {
    return StrictMobileInputMasking(
      allowedPattern: RegExp(r'^[A-Za-z0-9]*$'),
      maxLength: maxLength,
      invalidHaptic: invalidHaptic,
    );
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String candidate = newValue.text;
    final bool exceedsMaxLength =
        maxLength != null && candidate.length > maxLength!;
    final bool matchesPattern = allowedPattern.hasMatch(candidate);

    if (exceedsMaxLength || !matchesPattern) {
      if (invalidHaptic) {
        unawaited(HapticFeedback.lightImpact());
      }
      return oldValue;
    }

    return newValue;
  }
}
