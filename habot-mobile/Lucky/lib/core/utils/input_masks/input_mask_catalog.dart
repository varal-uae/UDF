import 'package:flutter/services.dart';
import 'regex_input_formatter.dart';

// RIMV-006-A01 + BPTR-0788-A01 — Input Mask Rule Catalog.
// Single centralised rule catalog for all input masking configurations.
// Spec: "Formatting configurations must look up system field specifications
// directly from a single centralized rule catalog."
// All masks operate as isolated shared filters — reusable across all forms.

// ─── NUMERIC FORMATTER ────────────────────────────────────────────────────────

/// Blocks all alphabetical and special character input.
/// Only allows digits and optional decimal point.
class NumericInputFormatter extends TextInputFormatter {
  const NumericInputFormatter({this.allowDecimal = false});
  final bool allowDecimal;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final pattern = allowDecimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9]');
    final filtered = newValue.text.split('').where((c) => pattern.hasMatch(c)).join();

    // Prevent multiple decimal points
    if (allowDecimal && filtered.split('.').length > 2) return oldValue;

    return newValue.copyWith(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

// ─── DATE FORMATTER — DD/MM/YYYY ──────────────────────────────────────────────

/// Auto-formats date input as DD/MM/YYYY while user types.
/// Blocks non-numeric input. Auto-inserts slashes at positions 2 and 4.
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip all non-digits
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 8; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ─── PHONE NUMBER FORMATTER ───────────────────────────────────────────────────

/// Formats phone numbers as user types.
/// Supports UAE (+971) and India (+91) formats per jurisdiction spec.
/// Blocks all non-numeric input except leading +.
class PhoneInputFormatter extends TextInputFormatter {
  const PhoneInputFormatter({this.countryCode = '+971'});
  final String countryCode;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow only digits and leading +
    String text = newValue.text;
    if (text.isEmpty) return newValue;

    // Strip everything except digits
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');

    String formatted;
    if (countryCode == '+971') {
      // UAE: +971 50 123 4567
      formatted = _formatUAE(digits);
    } else if (countryCode == '+91') {
      // India: +91 98765 43210
      formatted = _formatIndia(digits);
    } else {
      formatted = digits;
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatUAE(String digits) {
    // Max 9 digits after country code
    final d = digits.substring(0, digits.length.clamp(0, 9));
    final buffer = StringBuffer('+971 ');
    if (d.length >= 2) buffer.write('${d.substring(0, 2)} ');
    else { buffer.write(d); return buffer.toString(); }
    if (d.length >= 5) buffer.write('${d.substring(2, 5)} ');
    else { buffer.write(d.substring(2)); return buffer.toString(); }
    if (d.length > 5) buffer.write(d.substring(5));
    return buffer.toString().trim();
  }

  String _formatIndia(String digits) {
    // Max 10 digits after country code
    final d = digits.substring(0, digits.length.clamp(0, 10));
    final buffer = StringBuffer('+91 ');
    if (d.length >= 5) buffer.write('${d.substring(0, 5)} ');
    else { buffer.write(d); return buffer.toString(); }
    if (d.length > 5) buffer.write(d.substring(5));
    return buffer.toString().trim();
  }
}

// ─── CURRENCY FORMATTER ───────────────────────────────────────────────────────

/// Formats currency as 1,234.56 while user types.
/// Blocks all non-numeric input except decimal point.
class CurrencyInputFormatter extends TextInputFormatter {
  const CurrencyInputFormatter({this.symbol = '', this.decimalPlaces = 2});
  final String symbol;
  final int decimalPlaces;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // Strip non-numeric except decimal
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');

    // Split on decimal
    final parts = digits.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1
        ? parts[1].substring(0, parts[1].length.clamp(0, decimalPlaces))
        : null;

    // Add thousand separators
    final formatted = StringBuffer();
    if (symbol.isNotEmpty) formatted.write('$symbol ');
    formatted.write(_addThousandSeparators(intPart));
    if (decPart != null) formatted.write('.$decPart');

    final result = formatted.toString();
    return newValue.copyWith(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }

  String _addThousandSeparators(String value) {
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && (value.length - i) % 3 == 0) buffer.write(',');
      buffer.write(value[i]);
    }
    return buffer.toString();
  }
}

// ─── MASK RULE CATALOG ────────────────────────────────────────────────────────

/// Centralised rule catalog — single source of truth.
/// All masked fields look up their formatter and validator from here.
abstract class InputMaskCatalog {

  // — Formatters —
  static const numeric          = NumericInputFormatter();
  static const numericDecimal   = NumericInputFormatter(allowDecimal: true);
  static const date             = DateInputFormatter();
  static const phoneUAE         = PhoneInputFormatter(countryCode: '+971');
  static const phoneIndia       = PhoneInputFormatter(countryCode: '+91');
  static const currency         = CurrencyInputFormatter();
  static const currencyAED      = CurrencyInputFormatter(symbol: 'AED');
  static const currencyINR      = CurrencyInputFormatter(symbol: '₹');

  // BPTR-0788-A01 — International tracking number + generic regex primitives
  static const trackingNumber   = TrackingNumberFormatter();
  static final alphanumericOnly = RegexInputFormatter(allow: RegexPatterns.alphanumeric);
  static final digitsOnly       = RegexInputFormatter(allow: RegexPatterns.digitsOnly);
  static final upperAlpha       = RegexInputFormatter(allow: RegexPatterns.upperLetters);
  static final emailSafe        = RegexInputFormatter(allow: RegexPatterns.emailSafe);

  // — Keyboard types —
  static const TextInputType numericKeyboard  = TextInputType.number;
  static const TextInputType phoneKeyboard    = TextInputType.phone;
  static const TextInputType dateKeyboard     = TextInputType.number;

  // — Validators —
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) return 'Date is required';
    final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!regex.hasMatch(value)) return 'Enter date as DD/MM/YYYY';
    final parts = value.split('/');
    final day   = int.tryParse(parts[0]) ?? 0;
    final month = int.tryParse(parts[1]) ?? 0;
    final year  = int.tryParse(parts[2]) ?? 0;
    if (day < 1 || day > 31)   return 'Invalid day';
    if (month < 1 || month > 12) return 'Invalid month';
    if (year < 1900 || year > 2100) return 'Invalid year';
    return null;
  }

  static String? validatePhone(String? value, {String countryCode = '+971'}) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (countryCode == '+971' && digits.length != 12) return 'Enter a valid UAE number';
    if (countryCode == '+91'  && digits.length != 12) return 'Enter a valid India number';
    return null;
  }

  static String? validateNumeric(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) return 'This field is required';
    final number = double.tryParse(value.replaceAll(',', ''));
    if (number == null) return 'Enter a valid number';
    if (min != null && number < min) return 'Minimum value is $min';
    if (max != null && number > max) return 'Maximum value is $max';
    return null;
  }

  static String? validateCurrency(String? value) {
    if (value == null || value.isEmpty) return 'Amount is required';
    final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
    if (double.tryParse(cleaned) == null) return 'Enter a valid amount';
    return null;
  }

  // BPTR-0788-A01 — International tracking number validator
  static String? validateTrackingNumber(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) return 'Tracking number is required';
    final stripped = value.replaceAll(' ', '');
    if (stripped.length < minLength) return 'Tracking number too short';
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(stripped)) {
      return 'Only letters and numbers allowed';
    }
    return null;
  }
}
