// BPTR-0633-A10 — Bank account format input field with numeric keypad, input masking, inline validation, and save gating.
// Restricts input to digits and IBAN-style spacing, rejects alphabetic keystrokes, and disables Save until valid.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BankValidationResult {
  const BankValidationResult({
    required this.rawValue,
    required this.isValid,
    required this.message,
  });

  final String rawValue;
  final bool isValid;
  final String message;
}

List<BankValidationResult> validateBankFormatting(Iterable<String> values) {
  return values.map((value) {
    final raw = value.replaceAll(RegExp(r'\s+'), '');
    final valid = raw.isNotEmpty && RegExp(r'^\d{8,34}$').hasMatch(raw);
    return BankValidationResult(
      rawValue: value,
      isValid: valid,
      message: valid
          ? 'Valid bank format'
          : 'Enter a valid bank account number using digits only.',
    );
  }).toList(growable: false);
}

class BankFormatField extends StatefulWidget {
  const BankFormatField({
    super.key,
    required this.controller,
    required this.onValidChanged,
    this.label = 'Bank account number',
    this.helperText = 'Enter the account number exactly as it appears on your bank statement.',
    this.maxDigits = 34,
  });

  final TextEditingController controller;
  final ValueChanged<bool> onValidChanged;
  final String label;
  final String helperText;
  final int maxDigits;

  @override
  State<BankFormatField> createState() => _BankFormatFieldState();
}

class _BankFormatFieldState extends State<BankFormatField> {
  bool _isValid = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _validate();
    });
  }

  @override
  void didUpdateWidget(covariant BankFormatField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_validate);
      widget.controller.addListener(_validate);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _validate();
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validate);
    super.dispose();
  }

  void _validate() {
    final raw = widget.controller.text.replaceAll(RegExp(r'\s+'), '');
    final valid = raw.isNotEmpty &&
        raw.length >= 8 &&
        raw.length <= widget.maxDigits &&
        RegExp(r'^\d+$').hasMatch(raw);
    final error = raw.isEmpty
        ? null
        : valid
            ? null
            : 'Enter a valid bank account number using digits only.';
    if (!mounted) return;
    setState(() {
      _isValid = valid;
      _errorText = error;
    });
    widget.onValidChanged(valid);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      textField: true,
      label: widget.label,
      value: widget.controller.text,
      hint: widget.helperText,
      child: TextField(
        controller: widget.controller,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
          LengthLimitingTextInputFormatter(widget.maxDigits + (widget.maxDigits ~/ 4)),
          const _IbanGroupingFormatter(),
        ],
        decoration: InputDecoration(
          labelText: widget.label,
          helperText: widget.helperText,
          errorText: _errorText,
          suffixIcon: _isValid
              ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
              : null,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _IbanGroupingFormatter extends TextInputFormatter {
  const _IbanGroupingFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\s+'), '');
    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class BankFormatSection extends StatefulWidget {
  const BankFormatSection({
    super.key,
    this.onSubmit,
  });

  final ValueChanged<String>? onSubmit;

  @override
  State<BankFormatSection> createState() => _BankFormatSectionState();
}

class _BankFormatSectionState extends State<BankFormatSection> {
  final _controller = TextEditingController();
  bool _isValid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _controller.text.replaceAll(RegExp(r'\s+'), '');
    widget.onSubmit?.call(raw);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        BankFormatField(
          controller: _controller,
          onValidChanged: (valid) {
            if (!mounted) return;
            setState(() => _isValid = valid);
          },
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _isValid ? _submit : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
