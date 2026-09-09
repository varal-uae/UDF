// ANSA-002-A09 — State-Retaining Back Navigation & Auto-Save Form Fields.
// Provides a reusable back button that persists form inputs via local cache before popping, and a text field that automatically saves on blur/focus loss to prevent data loss.

import 'package:flutter/material.dart';

/// A back button that saves collected form data before navigating backward.
/// This ensures no data loss when users traverse previous steps.
class StateRetainingBackButton extends StatelessWidget {
  const StateRetainingBackButton({
    super.key,
    this.form,
    this.collectData,
    this.onSave,
    this.onBack,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
  });

  final FormState? form;
  final Map<String, dynamic> Function()? collectData;
  final Future<void> Function(Map<String, dynamic> data)? onSave;
  final VoidCallback? onBack;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  Future<void> _handleBack(BuildContext context) async {
    // Collect current form data via callback, if provided.
    final data = collectData?.call() ?? <String, dynamic>{};
    // Persist data using the provided save handler.
    if (onSave != null) {
      await onSave!(data);
    }
    // Navigate back using custom callback or default Navigator.
    if (onBack != null) {
      onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: () => _handleBack(context),
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
      tooltip: 'Back (data saved)',
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.transparent,
        foregroundColor: foregroundColor ?? colorScheme.onSurfaceVariant,
        padding: padding ?? const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}

/// A text form field that automatically saves its value when focus is lost.
/// This enforces the poka-yoke rule: inputs are cached on every blur event.
class AutoSaveTextFormField extends StatefulWidget {
  const AutoSaveTextFormField({
    super.key,
    required this.fieldKey,
    this.controller,
    this.initialValue,
    this.labelText,
    this.hintText,
    this.decoration,
    this.validator,
    this.onSave,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.autovalidateMode,
    this.focusNode,
    this.style,
    this.textAlign = TextAlign.start,
  });

  final String fieldKey;
  final TextEditingController? controller;
  final String? initialValue;
  final String? labelText;
  final String? hintText;
  final InputDecoration? decoration;
  final FormFieldValidator<String>? validator;
  final Future<void> Function(String key, String value)? onSave;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final AutovalidateMode? autovalidateMode;
  final FocusNode? focusNode;
  final TextStyle? style;
  final TextAlign textAlign;

  @override
  State<AutoSaveTextFormField> createState() => _AutoSaveTextFormFieldState();
}

class _AutoSaveTextFormFieldState extends State<AutoSaveTextFormField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _hasSaved = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _save();
    }
  }

  Future<void> _save() async {
    if (_hasSaved) return;
    if (widget.onSave != null) {
      await widget.onSave!(widget.fieldKey, _controller.text);
      _hasSaved = true;
    }
  }

  void _handleChanged(String value) {
    // Reset save flag so the next blur event saves the updated value.
    _hasSaved = false;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: widget.decoration ??
          InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            border: const OutlineInputBorder(),
          ),
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      maxLines: widget.maxLines,
      autovalidateMode: widget.autovalidateMode,
      style: widget.style,
      textAlign: widget.textAlign,
      onChanged: _handleChanged,
      onFieldSubmitted: (_) => _save(),
    );
  }
}