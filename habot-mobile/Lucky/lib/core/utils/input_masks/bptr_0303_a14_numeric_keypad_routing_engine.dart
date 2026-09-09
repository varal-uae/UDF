// BPTR-0303-A14 — Master Masked Input Container for numeric keypad routing.
// Provides a numeric-only TextInputFormatter that strips grouping separators and
// exposes a raw clean payload string. Applies Material 3 underline error styling.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Formatter that only permits digits and one optional decimal separator,
/// applies grouping separators for display, and strips all formatting when
/// producing the raw storage payload.
class Bptr0303A14NumericMaskFormatter extends TextInputFormatter {
  Bptr0303A14NumericMaskFormatter({
    this.allowDecimal = true,
    this.decimalSeparator = '.',
    this.groupSeparator = ',',
  });

  final bool allowDecimal;
  final String decimalSeparator;
  final String groupSeparator;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // Strip all existing formatting to evaluate raw digits only.
    final raw = _stripFormatting(newValue.text);
    if (raw.isEmpty) return const TextEditingValue(text: '');

    // Block any character outside numeric schema; allow at most one decimal.
    final buffer = StringBuffer();
    var decimalSeen = false;
    for (final char in raw.split('')) {
      if (char == decimalSeparator) {
        if (!allowDecimal || decimalSeen) continue;
        decimalSeen = true;
        buffer.write(char);
      } else if (RegExp(r'[0-9]').hasMatch(char)) {
        buffer.write(char);
      }
      // any other char is blocked
    }

    final clean = buffer.toString();
    if (clean.isEmpty) return const TextEditingValue(text: '');

    final formatted = _applyGrouping(clean);
    final selection = TextSelection.collapsed(offset: formatted.length);
    return TextEditingValue(text: formatted, selection: selection);
  }

  /// Removes grouping separators and any non-numeric characters except decimal.
  String _stripFormatting(String value) {
    return value.replaceAll(groupSeparator, '').trim();
  }

  String _applyGrouping(String value) {
    if (!value.contains(decimalSeparator)) {
      return _groupDigits(value);
    }
    final parts = value.split(decimalSeparator);
    final integerPart = _groupDigits(parts[0]);
    final decimalPart = parts.length > 1 ? parts[1] : '';
    return '$integerPart$decimalSeparator$decimalPart';
  }

  String _groupDigits(String digits) {
    if (digits.length <= 3) return digits;
    final buffer = StringBuffer();
    final length = digits.length;
    for (var i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write(groupSeparator);
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// Returns the raw, clean payload with all display formatting removed.
  static String rawValue(String formattedValue, {String groupSeparator = ','}) {
    return formattedValue.replaceAll(groupSeparator, '');
  }
}

/// Reusable masked numeric input container with Material 3 underline and
/// validation-error outline tones.
class Bptr0303A14NumericInputContainer extends StatefulWidget {
  const Bptr0303A14NumericInputContainer({
    super.key,
    required this.label,
    this.hintText,
    this.initialValue,
    this.allowDecimal = true,
    this.onChanged,
    this.validator,
    this.controller,
  });

  final String label;
  final String? hintText;
  final String? initialValue;
  final bool allowDecimal;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;

  @override
  State<Bptr0303A14NumericInputContainer> createState() =>
      _Bptr0303A14NumericInputContainerState();
}

class _Bptr0303A14NumericInputContainerState
    extends State<Bptr0303A14NumericInputContainer> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    setState(() {
      _errorText = widget.validator?.call(value);
    });
    widget.onChanged?.call(
      Bptr0303A14NumericMaskFormatter.rawValue(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasError = _errorText != null;

    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        Bptr0303A14NumericMaskFormatter(allowDecimal: widget.allowDecimal),
      ],
      onChanged: _handleChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        errorText: _errorText,
        // Validation alerts appear beneath the text underline.
        errorStyle: TextStyle(color: colorScheme.error),
        // Distinct outline tones highlight validation errors.
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: hasError ? colorScheme.error : colorScheme.outline,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: hasError ? colorScheme.error : colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
    );
  }
}
