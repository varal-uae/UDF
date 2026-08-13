import 'package:flutter/services.dart';

// BPTR-0788-A01 — General-purpose regex keystroke binding.
// Spec: "Bind immediate regex-matching logic to device keystroke listener states."
//       "The UI engine physically drops alpha keystrokes at runtime when entered
//        in numerical locations."
//
// Use this as a primitive for any field that needs a custom allow/block pattern.
// InputMaskCatalog pre-builds common patterns — use RegexInputFormatter directly
// for one-off or domain-specific formats (e.g. tracking numbers, postal codes).

class RegexInputFormatter extends TextInputFormatter {
  const RegexInputFormatter({
    required this.allow,
    this.maxLength,
  });

  /// Only characters matching this pattern are allowed through.
  /// Spec: drops non-matching keystrokes at runtime — never reaches the field.
  final RegExp allow;

  /// Optional hard cap on character count.
  final int? maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Drop every character that doesn't match the allow pattern
    final filtered = newValue.text
        .split('')
        .where((char) => allow.hasMatch(char))
        .join();

    // Apply max length cap
    final capped = maxLength != null && filtered.length > maxLength!
        ? filtered.substring(0, maxLength!)
        : filtered;

    if (capped == newValue.text) return newValue;

    return newValue.copyWith(
      text: capped,
      selection: TextSelection.collapsed(offset: capped.length),
    );
  }
}

// ─── TRACKING NUMBER FORMATTER ────────────────────────────────────────────────

/// International shipment / tracking number formatter.
/// Spec: "the specific format standard required for international tracking numbers"
///
/// Formats: IATA-style alphanumeric, auto-uppercases, groups in blocks of 4.
/// e.g. "1Z9999999999999999" → "1Z99 9999 9999 9999 99"
/// Blocks special characters and lowercase (auto-converts).
class TrackingNumberFormatter extends TextInputFormatter {
  const TrackingNumberFormatter({this.blockSize = 4, this.maxDigits = 20});

  final int blockSize;
  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow alphanumeric only, uppercase
    final raw = newValue.text
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '')
        .substring(0, newValue.text.length.clamp(0, maxDigits));

    if (raw.isEmpty) return newValue.copyWith(text: '');

    // Group into blocks
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      if (i > 0 && i % blockSize == 0) buffer.write(' ');
      buffer.write(raw[i]);
    }

    final result = buffer.toString();
    return newValue.copyWith(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

// ─── PRESET REGEX PATTERNS ────────────────────────────────────────────────────

/// Pre-built allow patterns for common field types.
/// Usage: RegexInputFormatter(allow: RegexPatterns.alphanumeric)
abstract class RegexPatterns {
  /// Digits only — no decimal, no alpha
  static final digitsOnly = RegExp(r'[0-9]');

  /// Digits + one decimal point
  static final decimal = RegExp(r'[0-9.]');

  /// Uppercase alphanumeric — tracking numbers, codes
  static final alphanumericUpper = RegExp(r'[A-Z0-9]');

  /// Alphanumeric (any case)
  static final alphanumeric = RegExp(r'[a-zA-Z0-9]');

  /// Letters only — no digits
  static final lettersOnly = RegExp(r'[a-zA-Z]');

  /// Uppercase letters only
  static final upperLetters = RegExp(r'[A-Z]');

  /// Hex characters — for color codes, IDs
  static final hex = RegExp(r'[0-9a-fA-F]');

  /// Email-safe characters
  static final emailSafe = RegExp(r'[a-zA-Z0-9@._+\-]');

  /// Postal / ZIP code characters
  static final postalCode = RegExp(r'[a-zA-Z0-9\- ]');
}
