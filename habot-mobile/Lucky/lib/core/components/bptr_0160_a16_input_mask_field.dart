// BPTR-0160-A16 — Input Mask & Validated Text Field Component.
// Implements strict 48x48dp touch targets, contextual mobile keyboard types, regex-driven character filtering, and real-time validation for atomic CDE data fields.
// Blocks invalid characters before submission and displays inline errors to eliminate post-submit frustration.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable mobile text field enforcing 48x48dp minimum touch targets,
/// contextual keyboard behavior, and regex-based input validation.
class Bptr0160A16ValidatedTextField extends StatefulWidget {
  const Bptr0160A16ValidatedTextField({
    super.key,
    required this.labelText,
    required this.allowedInputPattern,
    this.hintText,
    this.semanticLabel,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
    this.initialValue,
    this.maxLength,
    this.autofocus = false,
    this.autocorrect = false,
    this.enableSuggestions = false,
  });

  final String labelText;
  final String? hintText;
  final String? semanticLabel;
  final RegExp allowedInputPattern;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String value)? validator;
  final ValueChanged<String>? onChanged;
  final String? initialValue;
  final int? maxLength;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;

  @override
  State<Bptr0160A16ValidatedTextField> createState() => _Bptr0160A16ValidatedTextFieldState();
}

class _Bptr0160A16ValidatedTextFieldState extends State<Bptr0160A16ValidatedTextField> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _defaultValidator(String value) {
    if (value.isEmpty) return null;
    if (!widget.allowedInputPattern.hasMatch(value)) {
      return 'Invalid format.';
    }
    return null;
  }

  void _validate() {
    final value = _controller.text;
    final error = widget.validator?.call(value) ?? _defaultValidator(value);
    setState(() {
      _errorText = error;
    });
  }

  void _handleChanged(String value) {
    widget.onChanged?.call(value);
    _validate();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel ?? widget.labelText,
      textField: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        child: TextField(
          controller: _controller,
          autofocus: widget.autofocus,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.enableSuggestions,
          inputFormatters: [
            FilteringTextInputFormatter.allow(widget.allowedInputPattern),
            if (widget.maxLength != null)
              LengthLimitingTextInputFormatter(widget.maxLength),
          ],
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            errorText: _errorText,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: _handleChanged,
          onSubmitted: (_) => _validate(),
        ),
      ),
    );
  }
}