// BPTR-0803-A15 — Edge-level regex input masking for mobile text fields.
// Provides a reusable TextInputFormatter and TextFormField wrapper that reject illegal characters before parent state processors run.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EdgeRegexInputFormatter extends TextInputFormatter {
  EdgeRegexInputFormatter({
    required this.allowedPattern,
    this.replacement = '',
  });

  final RegExp allowedPattern;
  final String replacement;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final buffer = StringBuffer();
    for (final rune in newValue.text.runes) {
      final char = String.fromCharCode(rune);
      if (allowedPattern.hasMatch(char)) {
        buffer.write(char);
      } else {
        buffer.write(replacement);
      }
    }

    final filtered = buffer.toString();
    if (filtered == newValue.text) {
      return newValue;
    }

    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
      composing: TextRange.empty,
    );
  }
}

class EdgeMaskedTextFormField extends StatelessWidget {
  const EdgeMaskedTextFormField({
    super.key,
    required this.label,
    required this.allowedPattern,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.isRequired = false,
    this.errorText,
  });

  final String label;
  final RegExp allowedPattern;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool isRequired;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: [
        EdgeRegexInputFormatter(allowedPattern: allowedPattern),
      ],
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'Required field';
        }
        return validator?.call(value);
      },
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        errorText: errorText,
        errorStyle: TextStyle(
          color: theme.colorScheme.error,
          fontWeight: FontWeight.w600,
        ),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
    );
  }
}
