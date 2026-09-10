// BPTR-0788-A07 — Masked Input Field with rigid type-level validation for tracking numbers and currency metrics.
// Applies local hardware-level form validation, native mobile keyboard configurations, and immediate error color token updates.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Bptr0788A07InputKind { trackingNumber, currency }

class Bptr0788A07MaskedInputField extends StatefulWidget {
  const Bptr0788A07MaskedInputField({
    super.key,
    required this.kind,
    required this.controller,
    required this.label,
    this.hintText,
    this.isRequired = true,
    this.onValidationChanged,
  });

  final Bptr0788A07InputKind kind;
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final bool isRequired;
  final ValueChanged<bool>? onValidationChanged;

  @override
  State<Bptr0788A07MaskedInputField> createState() => _Bptr0788A07MaskedInputFieldState();
}

class _Bptr0788A07MaskedInputFieldState extends State<Bptr0788A07MaskedInputField> {
  String? _errorText;
  bool _isValid = true;

  InputDecoration _decoration(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: widget.label,
      hintText: widget.hintText,
      border: const OutlineInputBorder(),
      errorText: _errorText,
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    );
  }

  TextInputType get _keyboardType {
    switch (widget.kind) {
      case Bptr0788A07InputKind.trackingNumber:
        return TextInputType.text;
      case Bptr0788A07InputKind.currency:
        return const TextInputType.numberWithOptions(decimal: true);
    }
  }

  List<TextInputFormatter> get _formatters {
    switch (widget.kind) {
      case Bptr0788A07InputKind.trackingNumber:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
          LengthLimitingTextInputFormatter(64),
        ];
      case Bptr0788A07InputKind.currency:
        return [
          _Bptr0788A07CurrencyTextInputFormatter(),
          LengthLimitingTextInputFormatter(16),
        ];
    }
  }

  String? _validate(String value) {
    final trimmed = value.trim();
    if (widget.isRequired && trimmed.isEmpty) {
      return 'This field is required.';
    }
    if (trimmed.isEmpty) {
      return null;
    }

    switch (widget.kind) {
      case Bptr0788A07InputKind.trackingNumber:
        final trackingPattern = RegExp(r'^[A-Za-z0-9]+(-[A-Za-z0-9]+)*$');
        if (!trackingPattern.hasMatch(trimmed)) {
          return 'Enter a valid tracking number.';
        }
        return null;
      case Bptr0788A07InputKind.currency:
        final currencyPattern = RegExp(r'^[0-9]+([.][0-9]{1,2})?$');
        if (!currencyPattern.hasMatch(trimmed)) {
          return 'Enter a valid currency amount.';
        }
        return null;
    }
  }

  void _handleChanged(String value) {
    final error = _validate(value);
    if (error != _errorText) {
      setState(() {
        _errorText = error;
        _isValid = error == null;
      });
      widget.onValidationChanged?.call(_isValid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: widget.label,
      value: widget.controller.text,
      child: TextField(
        controller: widget.controller,
        keyboardType: _keyboardType,
        inputFormatters: _formatters,
        onChanged: _handleChanged,
        decoration: _decoration(context),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class _Bptr0788A07CurrencyTextInputFormatter extends TextInputFormatter {
  static final RegExp _pattern = RegExp(r'^[0-9]*[.]?[0-9]{0,2}$');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty || _pattern.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
