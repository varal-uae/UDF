// BPTR-0725-A15 — Mobile Poka-Yoke Numeric Input Masking.
// Enforces native numeric keypad, digit-only input, and focus retention when earnings value breaches configured boundaries.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

bool validateNumeric(String raw, {int? min, int? max}) {
  if (raw.isEmpty) return false;
  final value = int.tryParse(raw);
  if (value == null) return false;
  if (min != null && value < min) return false;
  if (max != null && value > max) return false;
  return true;
}

class NumericInputMaskField extends StatefulWidget {
  const NumericInputMaskField({
    super.key,
    required this.controller,
    required this.label,
    this.min,
    this.max,
    this.focusNode,
    this.onValidChanged,
    this.errorText = 'Value outside allowed boundary thresholds.',
  });

  final TextEditingController controller;
  final String label;
  final int? min;
  final int? max;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onValidChanged;
  final String errorText;

  @override
  State<NumericInputMaskField> createState() => _NumericInputMaskFieldState();
}

class _NumericInputMaskFieldState extends State<NumericInputMaskField> {
  late final FocusNode _focusNode;
  bool _ownsFocusNode = false;
  String? _validationError;
  bool _isRestoringFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  bool _validate(String raw) {
    if (raw.isEmpty) {
      _validationError = 'Required field.';
      return false;
    }
    final value = int.tryParse(raw);
    if (value == null) {
      _validationError = 'Numeric values only.';
      return false;
    }
    final min = widget.min;
    final max = widget.max;
    if (min != null && value < min) {
      _validationError = 'Value must be at least $min.';
      return false;
    }
    if (max != null && value > max) {
      _validationError = 'Value must be at most $max.';
      return false;
    }
    _validationError = null;
    return true;
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) return;
    final isValid = _validate(widget.controller.text);
    widget.onValidChanged?.call(isValid);
    if (!isValid && !_isRestoringFocus) {
      _isRestoringFocus = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _focusNode.requestFocus();
        _isRestoringFocus = false;
        setState(() {});
      });
    }
  }

  void _handleChanged(String value) {
    final isValid = _validate(value);
    widget.onValidChanged?.call(isValid);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(12),
      ],
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: _validationError,
        border: const OutlineInputBorder(),
      ),
      onChanged: _handleChanged,
    );
  }
}
