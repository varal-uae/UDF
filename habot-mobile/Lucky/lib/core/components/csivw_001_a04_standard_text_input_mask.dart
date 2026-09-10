// CSIVW-001-A04 — Standard Text Input Mask Component.
// Reusable responsive text entry block with ASCII filtering, max-length enforcement, optional masking, Material 3 validation states, and helper/counter text.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StandardTextInputMask extends StatelessWidget {
  const StandardTextInputMask({
    super.key,
    required this.controller,
    required this.label,
    required this.maxLength,
    this.helperText,
    this.hintText,
    this.validator,
    this.keyboardType = TextInputType.multiline,
    this.maxLines = 4,
    this.mask,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final int maxLength;
  final String? helperText;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final String? mask;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final formatters = <TextInputFormatter>[
      AsciiTextInputFormatter(),
      if (mask != null && mask!.isNotEmpty) MaskedTextInputFormatter(mask: mask!),
      LengthLimitingTextInputFormatter(maxLength),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth.isFinite ? constraints.maxWidth : double.infinity,
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            maxLines: maxLines,
            maxLength: maxLength,
            inputFormatters: formatters,
            validator: validator,
            decoration: InputDecoration(
              labelText: label,
              helperText: helperText,
              hintText: hintText,
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
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
                borderSide: BorderSide(color: colorScheme.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.error, width: 2),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AsciiTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final filtered = newValue.text.codeUnits.where((c) {
      return (c >= 32 && c <= 126) || c == 10 || c == 13 || c == 9;
    }).map((c) => String.fromCharCode(c)).join();
    if (filtered == newValue.text) return newValue;
    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

class MaskedTextInputFormatter extends TextInputFormatter {
  MaskedTextInputFormatter({required this.mask});
  final String mask;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    final buffer = StringBuffer();
    var rawIndex = 0;
    for (var i = 0; i < mask.length && rawIndex < raw.length; i++) {
      final maskChar = mask[i];
      if (maskChar == '#') {
        if (RegExp(r'[0-9]').hasMatch(raw[rawIndex])) {
          buffer.write(raw[rawIndex]);
          rawIndex++;
        } else {
          break;
        }
      } else if (maskChar == 'A') {
        if (RegExp(r'[A-Za-z]').hasMatch(raw[rawIndex])) {
          buffer.write(raw[rawIndex]);
          rawIndex++;
        } else {
          break;
        }
      } else {
        buffer.write(maskChar);
      }
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}