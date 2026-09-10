// BPTR-0725-A16 — Numeric Poka-Yoke Input Masking Component.
// Enforces native numeric keyboard entry, blocks non-numeric keystrokes, and shows inline validation errors below the field.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Bptr0725A16NumericInputMask extends StatefulWidget {
  const Bptr0725A16NumericInputMask({
    super.key,
    required this.controller,
    this.label = 'Numeric value',
    this.hint = 'Enter numbers only',
    this.errorText,
    this.maxLength,
    this.min,
    this.max,
    this.onChanged,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? errorText;
  final int? maxLength;
  final num? min;
  final num? max;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  State<Bptr0725A16NumericInputMask> createState() => _Bptr0725A16NumericInputMaskState();
}

class _Bptr0725A16NumericInputMaskState extends State<Bptr0725A16NumericInputMask> {
  String? _internalError;

  @override
  void initState() {
    super.initState();
    _internalError = _validate(widget.controller.text);
  }

  @override
  void didUpdateWidget(covariant Bptr0725A16NumericInputMask oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _internalError = _validate(widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveError = widget.errorText ?? _internalError;

    return TextField(
      controller: widget.controller,
      enabled: widget.enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
      textInputAction: TextInputAction.done,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        if (widget.maxLength != null) LengthLimitingTextInputFormatter(widget.maxLength),
      ],
      onChanged: (value) {
        setState(() {
          _internalError = _validate(value);
        });
        widget.onChanged?.call(value);
      },
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: effectiveError,
        border: const OutlineInputBorder(),
      ),
      style: theme.textTheme.bodyLarge,
    );
  }

  String? _validate(String value) {
    if (value.isEmpty) return null;
    final parsed = num.tryParse(value);
    if (parsed == null) return 'Only numeric values are allowed.';
    if (widget.min != null && parsed < widget.min!) return 'Value must be at least ${widget.min}.';
    if (widget.max != null && parsed > widget.max!) return 'Value must be at most ${widget.max}.';
    return null;
  }
}
