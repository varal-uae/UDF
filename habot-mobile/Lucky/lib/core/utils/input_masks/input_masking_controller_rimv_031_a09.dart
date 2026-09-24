// RIMV-031-A09 — Input Masking Constraint Infrastructure Controller.
// Provides a core text input masking framework that filters characters via RegEx, swaps focus border tones programmatically, and renders visual masking outlines inside empty layout blocks using Material 3 tokens.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// High-performance validation hook module equivalent to `useInputMasking`.
/// Prevents invalid formatting from traveling toward backend systems by
/// locking down pasting actions and filtering typed characters against strict masks.
class InputMaskingController extends TextEditingController {
  InputMaskingController({required this.maskPattern}) : super();

  final RegExp maskPattern;

  @override
  set value(TextEditingValue newValue) {
    final filteredText = _applyMask(newValue.text);
    final newSelection = TextSelection.collapsed(
      offset: filteredText.length,
    );
    super.value = newValue.copyWith(
      text: filteredText,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }

  String _applyMask(String text) {
    final buffer = StringBuffer();
    for (final char in text.characters) {
      if (maskPattern.hasMatch(char)) {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }
}

/// A formatter that enforces the mask at the TextInputFormatter level
/// to ensure copied strings conform to strict destination mask formulas.
class RegexMaskingFormatter extends TextInputFormatter {
  RegexMaskingFormatter(this.allowedPattern);

  final RegExp allowedPattern;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final buffer = StringBuffer();
    for (final char in newValue.text.characters) {
      if (allowedPattern.hasMatch(char)) {
        buffer.write(char);
      }
    }
    final filteredText = buffer.toString();
    if (filteredText == newValue.text) {
      return newValue;
    }
    return TextEditingValue(
      text: filteredText,
      selection: TextSelection.collapsed(offset: filteredText.length),
    );
  }
}

/// Visual masking outline widget rendered inside empty field layout blocks.
/// Swaps focus border tones programmatically based on active input states.
class MaskedInputField extends StatefulWidget {
  const MaskedInputField({
    super.key,
    required this.controller,
    required this.maskPattern,
    required this.keyboardType,
    required this.labelText,
    required this.hintText,
    this.errorMessage,
  });

  final TextEditingController controller;
  final RegExp maskPattern;
  final TextInputType keyboardType;
  final String labelText;
  final String hintText;
  final String? errorMessage;

  @override
  State<MaskedInputField> createState() => _MaskedInputFieldState();
}

class _MaskedInputFieldState extends State<MaskedInputField> {
  late final FocusNode _focusNode;
  bool _hasFocus = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_validateInput);
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  void _validateInput() {
    final text = widget.controller.text;
    setState(() {
      _hasError = text.isNotEmpty && !widget.maskPattern.hasMatch(text);
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    widget.controller.removeListener(_validateInput);
    super.dispose();
  }

  Color _getBorderColor(BuildContext context) {
    final theme = Theme.of(context);
    if (_hasError || widget.errorMessage != null) {
      return theme.colorScheme.error;
    }
    if (_hasFocus) {
      return theme.colorScheme.primary;
    }
    return theme.colorScheme.outline;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = _getBorderColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          style: theme.textTheme.bodyMedium,
          inputFormatters: [RegexMaskingFormatter(widget.maskPattern)],
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
            labelStyle: theme.textTheme.bodyMedium,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0), // Material 3 Shape Token
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: borderColor, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
          ),
        ),
        // Execute clear error presentation tracks below active text regions
        if (widget.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 16.0),
            child: Text(
              widget.errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

/// Mock data constants for local testing without backend dependencies.
class InputMaskMockData {
  static const String numericOnlyLabel = 'Phone Number';
  static const String numericOnlyHint = 'Enter digits only';
  static const String alphaNumericLabel = 'Reference Code';
  static const String alphaNumericHint = 'Letters and numbers only';
  
  static final RegExp numericOnlyPattern = RegExp(r'^[0-9]*$');
  static final RegExp alphaNumericPattern = RegExp(r'^[a-zA-Z0-9]*$');
}

/// Example usage screen demonstrating the infrastructure.
class InputMaskingDemoScreen extends StatelessWidget {
  const InputMaskingDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final numericController = TextEditingController();
    final alphaNumericController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Masking Infrastructure'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Collapsible "Common Mistakes" accordion per Material Design Implementation requirement
            ExpansionTile(
              title: Text(
                'Common Mistakes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '1. Pasting alphabetic characters into numeric fields will result in zero character updates.\n'
                    '2. Special characters are automatically stripped to conform to strict destination mask formulas.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            MaskedInputField(
              controller: numericController,
              maskPattern: InputMaskMockData.numericOnlyPattern,
              keyboardType: TextInputType.number,
              labelText: InputMaskMockData.numericOnlyLabel,
              hintText: InputMaskMockData.numericOnlyHint,
            ),
            const SizedBox(height: 24.0),
            MaskedInputField(
              controller: alphaNumericController,
              maskPattern: InputMaskMockData.alphaNumericPattern,
              keyboardType: TextInputType.text,
              labelText: InputMaskMockData.alphaNumericLabel,
              hintText: InputMaskMockData.alphaNumericHint,
            ),
          ],
        ),
      ),
    );
  }
}