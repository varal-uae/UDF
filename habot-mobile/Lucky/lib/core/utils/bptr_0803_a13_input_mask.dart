// BPTR-0803-A13 — Edge-level Regex Input Masking and CDE Validation.
// Applies custom string slicing to mobile text fields, enforces required CDEs locally,
// and exposes M3 error styling before form submission.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Bptr0803A13RegexInputMaskFormatter extends TextInputFormatter {
  Bptr0803A13RegexInputMaskFormatter({
    required this.mask,
    this.maskToken = '#',
    this.allowedPattern = r'[^0-9A-Za-z]',
  });

  final String mask;
  final String maskToken;
  final String allowedPattern;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(RegExp(allowedPattern), '');
    final buffer = StringBuffer();
    var rawIndex = 0;

    for (var i = 0; i < mask.length && rawIndex < raw.length; i++) {
      final token = mask[i];
      if (token == maskToken) {
        buffer.write(raw[rawIndex]);
        rawIndex++;
      } else {
        buffer.write(token);
      }
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
      composing: TextRange.empty,
    );
  }
}

class Bptr0803A13RequiredCdeValidator {
  const Bptr0803A13RequiredCdeValidator({
    required this.requiredFields,
  });

  final List<String> requiredFields;

  String? validate(Map<String, String?> values) {
    final missing = requiredFields
        .where((key) => (values[key] ?? '').trim().isEmpty)
        .toList();
    if (missing.isEmpty) return null;
    return 'Missing CDE: ${missing.join(', ')}';
  }

  bool canSubmit(Map<String, String?> values) => validate(values) == null;
}

class Bptr0803A13MaskedTextField extends StatelessWidget {
  const Bptr0803A13MaskedTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.mask,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.autofillHints,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String mask;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      textField: true,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        inputFormatters: <TextInputFormatter>[
          Bptr0803A13RegexInputMaskFormatter(mask: mask),
          LengthLimitingTextInputFormatter(mask.length),
        ],
        validator: validator,
        onChanged: onChanged,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          label: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: label),
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: colorScheme.error),
                ),
              ],
            ),
          ),
          errorStyle: TextStyle(
            color: colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
          errorMaxLines: 2,
          constraints: const BoxConstraints(minHeight: 48),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.error, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.error, width: 2),
          ),
        ),
      ),
    );
  }
}
