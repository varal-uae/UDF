import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'input_mask_catalog.dart';

// RIMV-006-A01 — Masked Text Field.
// Reusable input widget with programmatic masking built in.
// Spec: atoms/inputs/MaskedTextField
//
// Features:
//   - Auto-flips keyboard to numeric when focus moves to value fields
//   - Blocks alphabetical input via TextInputFormatter
//   - Blur validation hook — validates on focus leave
//   - Clear-text tracking mark inside dense fields
//   - Submit button state managed via onValidityChanged callback

enum MaskType { numeric, numericDecimal, date, phoneUAE, phoneIndia, currency, currencyAED, currencyINR }

class MaskedTextField extends StatefulWidget {
  const MaskedTextField({
    super.key,
    required this.maskType,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.validator,
    this.onChanged,
    this.onValidityChanged,
    this.enabled = true,
    this.required = true,
    // GEN-04313 — WCAG 2.1 AA accessibility
    this.semanticsLabel,
    this.semanticsHint,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.onFieldSubmitted,
  });

  final MaskType maskType;
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  /// Fires whenever validity state changes — use to toggle submit button.
  final ValueChanged<bool>? onValidityChanged;

  final bool enabled;
  final bool required;
  // GEN-04313 — WCAG 2.1 AA
  final String? semanticsLabel;
  final String? semanticsHint;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<MaskedTextField> createState() => _MaskedTextFieldState();
}

class _MaskedTextFieldState extends State<MaskedTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? _errorText;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        TextEditingController(text: widget.initialValue ?? '');
    // Use external FocusNode if provided (for keyboard chain), else own one
    _focusNode = widget.focusNode ?? FocusNode();

    // Blur validation hook — validates on focus leave
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _validate(_controller.text);
    });
  }

  @override
  void dispose() {
    // Only dispose focusNode if we created it internally
    if (widget.focusNode == null) _focusNode.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _validate(String value) {
    final error = widget.validator != null
        ? widget.validator!(value)
        : _defaultValidator(value);

    final isValid = error == null;
    setState(() => _errorText = error);

    if (isValid != _isValid) {
      _isValid = isValid;
      widget.onValidityChanged?.call(isValid);
    }
  }

  String? _defaultValidator(String? value) {
    switch (widget.maskType) {
      case MaskType.date:
        return InputMaskCatalog.validateDate(value);
      case MaskType.phoneUAE:
        return InputMaskCatalog.validatePhone(value, countryCode: '+971');
      case MaskType.phoneIndia:
        return InputMaskCatalog.validatePhone(value, countryCode: '+91');
      case MaskType.currency:
      case MaskType.currencyAED:
      case MaskType.currencyINR:
        return InputMaskCatalog.validateCurrency(value);
      case MaskType.numeric:
      case MaskType.numericDecimal:
        return InputMaskCatalog.validateNumeric(value);
    }
  }

  List<TextInputFormatter> get _formatters {
    switch (widget.maskType) {
      case MaskType.numeric:        return [InputMaskCatalog.numeric];
      case MaskType.numericDecimal: return [InputMaskCatalog.numericDecimal];
      case MaskType.date:           return [InputMaskCatalog.date];
      case MaskType.phoneUAE:       return [InputMaskCatalog.phoneUAE];
      case MaskType.phoneIndia:     return [InputMaskCatalog.phoneIndia];
      case MaskType.currency:       return [InputMaskCatalog.currency];
      case MaskType.currencyAED:    return [InputMaskCatalog.currencyAED];
      case MaskType.currencyINR:    return [InputMaskCatalog.currencyINR];
    }
  }

  TextInputType get _keyboardType {
    switch (widget.maskType) {
      case MaskType.date:           return InputMaskCatalog.dateKeyboard;
      case MaskType.phoneUAE:
      case MaskType.phoneIndia:     return InputMaskCatalog.phoneKeyboard;
      default:                      return InputMaskCatalog.numericKeyboard;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = _errorText != null;

    return Semantics(
      // GEN-04313 — WCAG 2.1 AA: screen reader label
      label:     widget.semanticsLabel ?? widget.label,
      hint:      widget.semanticsHint ?? _hintForMask(widget.maskType),
      textField: true,
      child: TextFormField(
        controller:        _controller,
        focusNode:         _focusNode,
        enabled:           widget.enabled,
        keyboardType:      _keyboardType,
        inputFormatters:   _formatters,
        textInputAction:   widget.textInputAction,
        onFieldSubmitted:  widget.onFieldSubmitted,
        onChanged: (value) {
        widget.onChanged?.call(value);
        // Clear error while typing — re-validate on blur
        if (_errorText != null) setState(() => _errorText = null);
      },
      decoration: InputDecoration(
        labelText: widget.label,
        hintText:  widget.hint ?? _hintForMask(widget.maskType),

        // Spec: sharp dark neutral label tones
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: hasError
              ? theme.colorScheme.error
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),

        // Spec: active layout sections turn red on error
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: hasError
                ? theme.colorScheme.error
                : theme.colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: hasError
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),

        // Spec: clear-text tracking mark inside dense fields
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.cancel_rounded, size: 18),
                tooltip: 'Clear',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: () {
                  _controller.clear();
                  _validate('');
                },
              )
            : null,

        // Spec: single-sentence help tip below field
        errorText: _errorText,
        errorStyle: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.error,
          shadows: [Shadow(color: theme.colorScheme.surface, blurRadius: 2)],
        ),
      ),
      ),  // TextFormField
    );    // Semantics
  }

  String _hintForMask(MaskType type) {
    switch (type) {
      case MaskType.date:        return 'DD/MM/YYYY';
      case MaskType.phoneUAE:    return '+971 50 123 4567';
      case MaskType.phoneIndia:  return '+91 98765 43210';
      case MaskType.currency:
      case MaskType.currencyAED: return '0.00';
      case MaskType.currencyINR: return '0.00';
      default:                   return '0';
    }
  }
}
