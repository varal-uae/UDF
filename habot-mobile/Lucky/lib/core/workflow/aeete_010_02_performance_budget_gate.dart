// AEETE-010-02 — Performance Budget Gate & Shared Input Masking.
// Enforces the 150KB core shell size limit and merges masking into shared input components for lightweight UI.

import 'package:flutter/services.dart';

class PerformanceBudgetGate {
  static const int maxCoreShellBytes = 150 * 1024; // 150KB
  static bool isWithinBudget(int sizeInBytes) => sizeInBytes <= maxCoreShellBytes;
  static String get budgetLabel => '${(maxCoreShellBytes / 1024).toStringAsFixed(0)}KB';
}

class MaskedTextInputFormatter extends TextInputFormatter {
  final String mask;
  MaskedTextInputFormatter({required this.mask});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final buffer = StringBuffer();
    int maskIndex = 0;
    int textIndex = 0;
    while (maskIndex < mask.length && textIndex < newValue.text.length) {
      if (mask[maskIndex] == '#') {
        final char = newValue.text[textIndex];
        if (RegExp(r'[0-9]').hasMatch(char)) {
          buffer.write(char);
          textIndex++;
        } else {
          textIndex++;
          continue;
        }
      } else {
        buffer.write(mask[maskIndex]);
      }
      maskIndex++;
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
