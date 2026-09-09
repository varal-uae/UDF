// BPTR-0303-A04 — Input-Mask Numeric Keypad Routing Engine & Semantic Dark Mode Theme Variants.
// Provides a reusable masked input formatter that routes numeric keypads and blocks invalid characters, plus dark-mode theme extension for consistent validation states.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum MaskType { currency, decimal, integer, phone, custom }

/// Core engine that configures input formatters and keyboard routing
/// for numeric keypad fields based on schema requirements.
class InputMaskNumericKeypadRoutingEngine {
  final MaskType maskType;
  final String? customPattern;
  final int? decimalPlaces;

  const InputMaskNumericKeypadRoutingEngine({
    required this.maskType,
    this.customPattern,
    this.decimalPlaces,
  });

  /// Returns the appropriate [TextInputFormatter] that applies the mask
  /// and blocks characters outside the field definition.
  TextInputFormatter get formatter {
    switch (maskType) {
      case MaskType.currency:
        return const _CurrencyInputFormatter();
      case MaskType.decimal:
        return _DecimalInputFormatter(decimalPlaces ?? 2);
      case MaskType.integer:
        return FilteringTextInputFormatter.digitsOnly;
      case MaskType.phone:
        return const _PhoneInputFormatter();
      case MaskType.custom:
        return _CustomMaskInputFormatter(customPattern ?? '');
      default:
        return FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'));
    }
  }

  /// Routes the device keypad to match the field schema.
  TextInputType get keyboardType {
    switch (maskType) {
      case MaskType.currency:
      case MaskType.decimal:
        return const TextInputType.numberWithOptions(decimal: true);
      case MaskType.integer:
        return TextInputType.number;
      case MaskType.phone:
        return TextInputType.phone;
      case MaskType.custom:
        return TextInputType.number;
      default:
        return TextInputType.number;
    }
  }
}

// ------------------ Formatters ------------------

/// Formats input as currency with automatic grouping and two decimals.
class _CurrencyInputFormatter extends TextInputFormatter {
  const _CurrencyInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');
    final doubleValue = double.parse(digitsOnly) / 100;
    final formatted = _formatCurrency(doubleValue);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatCurrency(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
    }
    return '\$${buffer.toString()}.$decPart';
  }
}

/// Formats decimal input with a fixed number of decimal places.
class _DecimalInputFormatter extends TextInputFormatter {
  final int decimalPlaces;
  _DecimalInputFormatter(this.decimalPlaces);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final sanitized = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
    if (sanitized.isEmpty) return const TextEditingValue(text: '');
    final parts = sanitized.split('.');
    final intPart = parts[0];
    var decPart = parts.length > 1 ? parts[1] : '';
    if (decPart.length > decimalPlaces) {
      decPart = decPart.substring(0, decimalPlaces);
    }
    final result = decPart.isEmpty ? intPart : '$intPart.$decPart';
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

/// Formats phone number in (XXX) XXX-XXXX pattern.
class _PhoneInputFormatter extends TextInputFormatter {
  const _PhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 10) {
      return oldValue;
    }
    final buffer = StringBuffer();
    if (digits.length >= 1) buffer.write('(');
    for (int i = 0; i < digits.length; i++) {
      if (i == 3) buffer.write(') ');
      if (i == 6) buffer.write('-');
      buffer.write(digits[i]);
    }
    if (digits.length > 3) buffer.write(')');
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Applies a custom mask pattern where '#' represents a digit and other chars are literals.
class _CustomMaskInputFormatter extends TextInputFormatter {
  final String pattern;
  _CustomMaskInputFormatter(this.pattern);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    int digitIndex = 0;
    for (int i = 0; i < pattern.length && digitIndex < digits.length; i++) {
      if (pattern[i] == '#') {
        buffer.write(digits[digitIndex]);
        digitIndex++;
      } else {
        buffer.write(pattern[i]);
      }
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ------------------ Semantic Dark Mode Theme Variants ------------------

/// Generates semantic dark mode theme variants aligned with Material 3
/// design tokens, focusing on distinct validation error outlines and
/// alert text placed beneath the underline.
class SemanticDarkModeThemeVariants {
  const SemanticDarkModeThemeVariants._();

  /// Returns a [ThemeData] for dark mode based on system settings.
  static ThemeData buildDarkTheme() {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6750A4),
        brightness: Brightness.dark,
      ),
    );

    return base.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        errorStyle: const TextStyle(
          color: Color(0xFFFFB4AB),
          fontSize: 12,
          height: 1.5,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFFFB4AB), width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFFFB4AB), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFD0BCFF), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF938F99), width: 1),
        ),
      ),
    );
  }
}
