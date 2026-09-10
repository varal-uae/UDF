// CSIVW-001-A12 — StandardTextInputMask reusable responsive text entry block with strict input masking, validation states, helper/error text, and counter boundaries.
// Supports ASCII-only paste filtering, max-length enforcement, focus/error border states, and fluid width layout.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AsciiOnlyTextInputFormatter extends TextInputFormatter {
  const AsciiOnlyTextInputFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final filtered = newValue.text.runes.where((rune) => rune <= 0x7F).map((rune) => String.fromCharCode(rune)).join();
    if (filtered == newValue.text) {
      return newValue;
    }
    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
      composing: TextRange.empty,
    );
  }
}

class StandardTextInputMask extends StatefulWidget {
  const StandardTextInputMask({
    super.key,
    this.controller,
    this.initialValue,
    required this.label,
    this.helperText,
    this.errorText,
    this.validator,
    this.maxLength = 500,
    this.maxLines = 4,
    this.minLines = 2,
    this.enabled = true,
    this.textInputAction = TextInputAction.newline,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String label;
  final String? helperText;
  final String? errorText;
  final String? Function(String?)? validator;
  final int maxLength;
  final int maxLines;
  final int minLines;
  final bool enabled;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;

  @override
  State<StandardTextInputMask> createState() => _StandardTextInputMaskState();
}

class _StandardTextInputMaskState extends State<StandardTextInputMask> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        textInputAction: widget.textInputAction,
        validator: widget.validator,
        inputFormatters: <TextInputFormatter>[
          const AsciiOnlyTextInputFormatter(),
          LengthLimitingTextInputFormatter(widget.maxLength),
        ],
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          labelText: widget.label,
          helperText: widget.helperText,
          errorText: widget.errorText,
          helperMaxLines: 3,
          errorMaxLines: 3,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: hasError ? colorScheme.error : colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.error, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.error, width: 2),
          ),
        ),
      ),
    );
  }
}
