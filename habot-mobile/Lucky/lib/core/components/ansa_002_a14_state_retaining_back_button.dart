// ANSA-002-A14 — State-Retaining Back Button for Multi-Step Data Collection.
// Caches active form field values on blur and intercepts back navigation to preserve validated input state.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable back button that guarantees form data is preserved before
/// navigating backward through multi-step workflows.
class StateRetainingBackButton extends StatelessWidget {
  const StateRetainingBackButton({
    super.key,
    required this.onBeforeBack,
    this.tooltip = 'Back',
    this.color,
  });

  /// Called before the back navigation occurs. Return true to allow the
  /// pop, or false to cancel it. Use this to flush pending form state.
  final Future<bool> Function() onBeforeBack;
  final String tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return BackButton(
      color: color,
      onPressed: () {
        onBeforeBack().then((canPop) {
          if (canPop && context.mounted) {
            Navigator.maybePop(context);
          }
        });
      },
      tooltip: tooltip,
    );
  }
}

/// Automatically caches the value of a [TextEditingController] when its
/// focus is lost, eliminating the need for manual save clicks.
class AutoSaveOnBlurTextFormField extends StatefulWidget {
  const AutoSaveOnBlurTextFormField({
    super.key,
    required this.controller,
    required this.onBlurSave,
    this.decoration,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.validator,
  });

  final TextEditingController controller;
  final ValueChanged<String> onBlurSave;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final FormFieldValidator<String>? validator;

  @override
  State<AutoSaveOnBlurTextFormField> createState() =>
      _AutoSaveOnBlurTextFormFieldState();
}

class _AutoSaveOnBlurTextFormFieldState
    extends State<AutoSaveOnBlurTextFormField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      widget.onBlurSave(widget.controller.text);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      decoration: widget.decoration,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.obscureText,
      validator: widget.validator,
    );
  }
}
