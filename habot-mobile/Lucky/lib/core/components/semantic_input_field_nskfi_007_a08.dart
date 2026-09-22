// NSKFI-007-A08 — Semantic Input Field with Hardcoded Keyboard Optimization.
// Provides a universal text input component that automatically configures keyboard type, input formatters, and Material 3 styling to optimize mobile data entry precision.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enum representing the semantic intent of the input field,
/// which dictates the native soft keyboard layout presented to the user.
enum SemanticInputType {
  text,
  email,
  numeric,
  phone,
  currency,
  password,
}

/// A highly reusable, accessible, and mobile-first input component
/// that enforces correct keyboard layouts and MD3 design tokens.
class SemanticInputField extends StatefulWidget {
  final SemanticInputType semanticType;
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;

  const SemanticInputField({
    super.key,
    required this.semanticType,
    this.controller,
    this.labelText,
    this.hintText,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplete,
  });

  @override
  State<SemanticInputField> createState() => _SemanticInputFieldState();
}

class _SemanticInputFieldState extends State<SemanticInputField> {
  late final TextEditingController _internalController;
  late final FocusNode _internalFocusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _hasFocus = _internalFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _internalFocusNode.removeListener(_handleFocusChange);
    if (widget.controller == null) {
      _internalController.dispose();
    }
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  /// Maps the semantic type to Flutter's native [TextInputType].
  TextInputType _resolveKeyboardType() {
    switch (widget.semanticType) {
      case SemanticInputType.email:
        return TextInputType.emailAddress;
      case SemanticInputType.numeric:
        return TextInputType.number;
      case SemanticInputType.phone:
        return TextInputType.phone;
      case SemanticInputType.currency:
        return const TextInputType.numberWithOptions(decimal: true);
      case SemanticInputType.password:
        return TextInputType.text;
      case SemanticInputType.text:
      default:
        return TextInputType.text;
    }
  }

  /// Generates character-level input masking middleware based on semantic type.
  List<TextInputFormatter> _resolveInputFormatters() {
    switch (widget.semanticType) {
      case SemanticInputType.numeric:
        // Poka-Yoke: Forces numeric-only input, equivalent to pattern="[0-9]*"
        return [FilteringTextInputFormatter.digitsOnly];
      case SemanticInputType.currency:
        // Allows digits and a single decimal point for financial entries
        return [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))];
      case SemanticInputType.phone:
        // Basic phone formatting allowance
        return [FilteringTextInputFormatter.allow(RegExp(r'^[+0-9\-\s()]*$'))];
      case SemanticInputType.email:
      case SemanticInputType.text:
      case SemanticInputType.password:
      default:
        return [];
    }
  }

  /// Resolves autofill hints for accessibility and native OS integration.
  Iterable<String> _resolveAutofillHints() {
    switch (widget.semanticType) {
      case SemanticInputType.email:
        return [AutofillHints.email];
      case SemanticInputType.phone:
        return [AutofillHints.telephoneNumber];
      case SemanticInputType.password:
        return [AutofillHints.password];
      default:
        return [];
    }
  }

  bool get _isObscured => widget.semanticType == SemanticInputType.password;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    // MD3 high-contrast focus state styling rules
    final Color activeBorderColor = _hasFocus
        ? colorScheme.primary
        : colorScheme.outlineVariant;
    final double borderWidth = _hasFocus ? 2.0 : 1.0;

    // Enforce minimum 44px touch perimeter around the element
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56.0),
        child: Semantics(
          label: widget.labelText ?? widget.hintText,
          textField: true,
          child: TextFormField(
            controller: _internalController,
            focusNode: _internalFocusNode,
            keyboardType: _resolveKeyboardType(),
            inputFormatters: _resolveInputFormatters(),
            obscureText: _isObscured,
            autofillHints: _resolveAutofillHints(),
            enabled: widget.enabled,
            textInputAction: widget.textInputAction ?? TextInputAction.next,
            onEditingComplete: widget.onEditingComplete,
            onChanged: widget.onChanged,
            validator: widget.validator,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              labelStyle: textTheme.bodyMedium?.copyWith(
                color: _hasFocus ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
              hintStyle: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 2.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: colorScheme.error,
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                  color: colorScheme.error,
                  width: 2.0,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              filled: true,
              fillColor: _hasFocus
                  ? colorScheme.surfaceContainerHighest.withOpacity(0.3)
                  : colorScheme.surfaceContainerLowest,
            ),
          ),
        ),
      ),
    );
  }
}

/// Mock registry demonstrating how atomic input configurations are stored
/// and retrieved in the Universal Component Registry.
class InputComponentRegistry {
  static const Map<String, SemanticInputType> fieldMappings = {
    '/udf/form/email': SemanticInputType.email,
    '/udf/form/phone': SemanticInputType.phone,
    '/udf/form/amount': SemanticInputType.currency,
    '/udf/form/pin': SemanticInputType.numeric,
    '/udf/form/password': SemanticInputType.password,
    '/udf/form/full_name': SemanticInputType.text,
  };

  static SemanticInputType resolveType(String objectPath) {
    return fieldMappings[objectPath] ?? SemanticInputType.text;
  }
}
