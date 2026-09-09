// BCDLD-007-A16 — Enforce Binary Yes/No Input Masks.
// Reusable Material 3 form field that restricts input to binary digit '0' or '1', strips non-digit characters on paste, and displays Yes/No labels.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A [TextInputFormatter] that enforces a binary Yes/No input mask.
/// Only digits 0 and 1 are accepted. Any other characters are stripped,
/// including characters pasted from the clipboard. If more than one digit
/// is present, only the first digit is retained.
class BinaryYesNoInputFormatter extends TextInputFormatter {
  const BinaryYesNoInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final filtered = newValue.text.replaceAll(RegExp(r'[^01]'), '');
    if (filtered.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
    // Keep only the first character to preserve a single binary digit.
    final first = filtered[0];
    return TextEditingValue(
      text: first,
      selection: TextSelection.collapsed(offset: first.length),
    );
  }
}

/// A reusable [TextFormField] that enforces a binary Yes/No input mask.
///
/// The field accepts only a single digit: 0 (No) or 1 (Yes).
/// Clipboard paste events are intercepted by [BinaryYesNoInputFormatter],
/// which strips any character outside the allowed [01] pattern.
/// A suffix label maps the raw digit to its Yes/No equivalent.
class BinaryYesNoInputMask extends StatefulWidget {
  const BinaryYesNoInputMask({
    super.key,
    this.controller,
    this.initialValue,
    this.labelText = 'Binary Yes/No',
    this.helperText,
    this.onChanged,
    this.validator,
    this.decoration,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String labelText;
  final String? helperText;
  final ValueChanged<bool?>? onChanged;
  final FormFieldValidator<String>? validator;
  final InputDecoration? decoration;

  @override
  State<BinaryYesNoInputMask> createState() => _BinaryYesNoInputMaskState();
}

class _BinaryYesNoInputMaskState extends State<BinaryYesNoInputMask> {
  late final TextEditingController _controller;
  late String _currentRaw;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        TextEditingController(text: widget.initialValue ?? '');
    _currentRaw = _controller.text;
    _controller.addListener(_handleControllerChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChange);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleControllerChange() {
    setState(() {
      _currentRaw = _controller.text;
    });
  }

  String _yesNoSuffix(String rawValue) {
    return switch (rawValue) {
      '1' => 'Yes',
      '0' => 'No',
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final baseDecoration = widget.decoration ?? const InputDecoration();
    return TextFormField(
      controller: _controller,
      keyboardType: TextInputType.number,
      inputFormatters: const [BinaryYesNoInputFormatter()],
      decoration: baseDecoration.copyWith(
        labelText: widget.labelText,
        helperText: widget.helperText,
        suffixText: _yesNoSuffix(_currentRaw),
        counterText: '',
      ),
      onChanged: (value) {
        final bool? result = switch (value) {
          '1' => true,
          '0' => false,
          _ => null,
        };
        widget.onChanged?.call(result);
      },
      validator: widget.validator,
    );
  }
}
