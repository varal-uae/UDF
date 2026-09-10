// BPTR-0803-A06 — Edge-level regex input masking for mobile text fields.
// Provides a reusable Material 3 text field with real-time regex filtering,
// required-field asterisk, sticky inline error state, and 48x48dp touch target.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Bptr0803A06RegexValidator {
  const Bptr0803A06RegexValidator._();

  static String? validate({
    required String? value,
    required String pattern,
    required bool isRequired,
    bool allowEmpty = false,
  }) {
    final text = value ?? '';
    if (text.isEmpty) {
      return isRequired && !allowEmpty ? 'This field is required' : null;
    }

    final regex = RegExp(pattern);
    final match = regex.matchAsPrefix(text);
    if (match == null || match.end != text.length) {
      return 'Invalid format';
    }
    return null;
  }
}

class Bptr0803A06RegexMaskedTextField extends StatelessWidget {
  const Bptr0803A06RegexMaskedTextField({
    super.key,
    required this.label,
    required this.allowedCharacterPattern,
    this.validationPattern,
    this.controller,
    this.hintText,
    this.isRequired = true,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.errorText,
    this.allowEmpty = false,
  });

  final String label;
  final String allowedCharacterPattern;
  final String? validationPattern;
  final TextEditingController? controller;
  final String? hintText;
  final bool isRequired;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool allowEmpty;

  @override
  Widget build(BuildContext context) {
    final fullPattern = validationPattern ?? allowedCharacterPattern;

    return Semantics(
      textField: true,
      label: isRequired ? '$label, required' : label,
      hint: hintText,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(allowedCharacterPattern)),
          ],
          decoration: InputDecoration(
            labelText: isRequired ? '$label *' : label,
            hintText: hintText,
            errorText: errorText,
          ),
          validator: (value) => Bptr0803A06RegexValidator.validate(
            value: value,
            pattern: fullPattern,
            isRequired: isRequired,
            allowEmpty: allowEmpty,
          ),
        ),
      ),
    );
  }
}
