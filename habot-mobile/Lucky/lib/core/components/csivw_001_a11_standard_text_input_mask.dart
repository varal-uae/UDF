// CSIVW-001-A11 — StandardTextInputMask: strict client-side input masking for template text areas.
// Provides ASCII-only filtering (including clipboard paste), max length enforcement, counter/helper/error UI, and reusable Material 3 form field styling.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StandardTextInputMask extends StatelessWidget {
  const StandardTextInputMask({
    super.key,
    required this.controller,
    this.label = 'Template text',
    this.hint,
    this.maxLength = 2000,
    this.minLines = 4,
    this.maxLines = 8,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.helperText = 'ASCII characters only. Invalid pasted content is removed.',
    this.errorText,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLength;
  final int minLines;
  final int maxLines;
  final bool enabled;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final String helperText;
  final String? errorText;
  final AutovalidateMode autovalidateMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorText != null;

    return TextFormField(
      controller: controller,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: <TextInputFormatter>[
        const _AsciiOnlyClipboardFormatter(),
        LengthLimitingTextInputFormatter(maxLength),
      ],
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      autovalidateMode: autovalidateMode,
      validator: (value) {
        final text = value ?? '';
        if (text.isNotEmpty && _AsciiOnlyClipboardFormatter.containsInvalidCharacters(text)) {
          return 'Remove non-ASCII characters before continuing.';
        }
        return validator?.call(value);
      },
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        errorText: errorText,
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        filled: true,
        fillColor: hasError
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.surfaceContainerHighest,
      ),
    );
  }
}

class _AsciiOnlyClipboardFormatter extends TextInputFormatter {
  const _AsciiOnlyClipboardFormatter();

  static bool _isAllowed(int codeUnit) {
    return codeUnit == 0x09 ||
        codeUnit == 0x0A ||
        codeUnit == 0x0D ||
        (codeUnit >= 0x20 && codeUnit <= 0x7E);
  }

  static bool containsInvalidCharacters(String value) {
    for (final codeUnit in value.codeUnits) {
      if (!_isAllowed(codeUnit)) return true;
    }
    return false;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final buffer = StringBuffer();
    var removedBeforeSelection = 0;
    final selectionOffset = newValue.selection.baseOffset.clamp(0, newValue.text.length).toInt();

    for (var i = 0; i < newValue.text.length; i++) {
      final codeUnit = newValue.text.codeUnitAt(i);
      if (_isAllowed(codeUnit)) {
        buffer.writeCharCode(codeUnit);
      } else if (i < selectionOffset) {
        removedBeforeSelection++;
      }
    }

    final filtered = buffer.toString();
    if (filtered == newValue.text) return newValue;

    final newOffset = (newValue.selection.baseOffset - removedBeforeSelection)
        .clamp(0, filtered.length)
        .toInt();
    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}
