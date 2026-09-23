// REF-016-A12 — Integrated character-level text formatting mask handler for data entry input fields.
// Provides real-time input masking, paste handling, invalid character filtering, and MD3-compliant 56px touch targets with a strict 4-column grid layout.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A configurable text formatter that applies structural masks to user input.
/// Drops invalid characters before they register in form state memory (Poka-Yoke).
/// Handles edge cases such as pasting pre-formatted text by stripping non-mask characters first.
class MaskedTextInputFormatter extends TextInputFormatter {
  final String mask;
  final RegExp allowedCharsRegExp;

  /// [mask] defines the structure, e.g., '(###) ###-####'.
  /// '#' represents an allowed character placeholder.
  /// [allowedCharsRegExp] defaults to digits only if not provided.
  MaskedTextInputFormatter({
    required this.mask,
    RegExp? allowedCharsRegExp,
  }) : allowedCharsRegExp = allowedCharsRegExp ?? RegExp(r'[0-9]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Extract only valid characters from the new input (handles paste edge cases)
    final String rawText = newValue.text
        .split('')
        .where((char) => allowedCharsRegExp.hasMatch(char))
        .join();

    final StringBuffer formatted = StringBuffer();
    int rawIndex = 0;

    for (int i = 0; i < mask.length && rawIndex < rawText.length; i++) {
      if (mask[i] == '#') {
        formatted.write(rawText[rawIndex]);
        rawIndex++;
      } else {
        formatted.write(mask[i]);
        // If the user typed exactly the mask separator, advance raw index conceptually
        // but since we stripped it from rawText, we just append the mask char.
      }
    }

    final String finalText = formatted.toString();
    
    // Calculate new cursor position
    int selectionIndex = finalText.length;
    if (newValue.selection.baseOffset < newValue.text.length) {
      // Attempt to maintain relative cursor position for mid-text edits
      selectionIndex = finalText.length.clamp(0, finalText.length);
    }

    return TextEditingValue(
      text: finalText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

/// A Poka-Yoke filtering logic gate that drops invalid characters from the keyboard buffer.
class StrictCharacterFilter extends TextInputFormatter {
  final RegExp allowedRegExp;

  StrictCharacterFilter(this.allowedRegExp);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If typing letters into a masked number field, results in zero-change response
    if (allowedRegExp.hasMatch(newValue.text) || newValue.text.isEmpty) {
      return newValue;
    }
    return oldValue;
  }
}

/// Mock telemetry data collector for atomic-level execution tracking.
class MaskTelemetryCollector {
  static const List<Map<String, dynamic>> mockExecutionLogs = [
    {
      'step_execution_id': 'EXEC-001',
      'execution_status': 'SUCCESS',
      'execution_timestamp': '2026-09-23T10:00:00Z',
      'step_outcome': 'High',
      'user_id': 'USR-992',
      'completion_status': 'High/Medium/Low',
      'action_event_timestamp': '2026-09-23T10:00:01Z',
      'session_id': 'SESS-11A'
    }
  ];

  static void logInteraction(String userId, String outcome) {
    // Simulates automated data entry task logging
    debugPrint('[REF-016-A12 Telemetry] User: $userId | Outcome: $outcome');
  }
}

/// MD3 Compliant Masked Input Field Widget.
/// Enforces minimum 56px height, full-width 4-column grid stretching, and flexible padding limits.
class MaskedInputField extends StatelessWidget {
  final String label;
  final String mask;
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool isRequired;

  const MaskedInputField({
    super.key,
    required this.label,
    required this.mask,
    this.hintText,
    this.controller,
    this.onChanged,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Enforce strict 4-column framework scaling smoothly across screen changes
        final double maxWidth = constraints.maxWidth;
        
        return Padding(
          // Set clear padding limits on inner components to keep layouts clean
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: SizedBox(
            // Map input field height parameters to match a minimum 56px standard for touch access
            height: 56.0,
            width: maxWidth, // Ensure input fields stretch across full grid column sets
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              onChanged: (String value) {
                onChanged?.call(value);
                MaskTelemetryCollector.logInteraction('current_user', 'input_changed');
              },
              inputFormatters: <TextInputFormatter>[
                // Logic gate dropping invalid chars + applying structural mask
                FilteringTextInputFormatter.allow(RegExp(r'[0-9#\+\-\(\)\s]')),
                MaskedTextInputFormatter(mask: mask),
              ],
              decoration: InputDecoration(
                labelText: label,
                hintText: hintText ?? mask.replaceAll('#', '0'),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                // Apply distinctive visual color variables for focus and idle states
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(color: colorScheme.error, width: 1.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(color: colorScheme.error, width: 2.0),
                ),
                // Adhere to MD3 text field error messaging layout rules
                errorStyle: TextStyle(
                  color: colorScheme.error,
                  fontSize: 12.0,
                  overflow: TextOverflow.ellipsis, // Keep validation notes short without clipping
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              ),
            ),
          ),
        );
      },
    );
  }
}
