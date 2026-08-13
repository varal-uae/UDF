/*
 * STEP 19: NSKFI-015 — Build Mobile Virtual Keyboard Layout Interceptors
 * 
 * Setup Step (Action): Access the SmartKeyboardField component inside the Frontend Design System.
 * Setup Step Description: Attach specific attributes (inputmode="numeric", pattern="[0-9]*") to all value entry blocks;
 *   disable autocomplete; auto-focus traversal down form rows.
 * 
 * Mobile-First & Responsive UX/UI Decisions:
 *   - Optimize text selection experiences for handheld ergonomics.
 *   - Ensure clear helper text guidelines match current input types.
 *   - Keypad structures block letters entirely from numeric entries, eliminating manual typos on phones.
 * 
 * What Was Done to Complete This Step:
 *   - Created `SmartKeyboardField` widget and `KeyboardInterceptorConfig` model in a single file.
 *   - Implemented native numeric keypad invocation, regex input formatters, and auto-focus action hooks.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/spacing_tokens.dart';

class KeyboardInterceptorConfig {
  final TextInputType keyboardType;
  final String? inputPattern;
  final bool disableAutocomplete;
  final bool autoFocusNextRow;

  const KeyboardInterceptorConfig({
    this.keyboardType = TextInputType.number,
    this.inputPattern = r'[0-9]*',
    this.disableAutocomplete = true,
    this.autoFocusNextRow = true,
  });
}

/// Step NSKFI-015: Mobile Virtual Keyboard Layout Interceptor component (SmartKeyboardField).
class SmartKeyboardField extends StatelessWidget {
  final String label;
  final String? hintText;
  final KeyboardInterceptorConfig config;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFieldSubmitted;

  const SmartKeyboardField({
    super.key,
    required this.label,
    this.hintText,
    this.config = const KeyboardInterceptorConfig(),
    this.onChanged,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.xs),
      child: TextFormField(
        keyboardType: config.keyboardType,
        enableSuggestions: !config.disableAutocomplete,
        autocorrect: !config.disableAutocomplete,
        inputFormatters: [
          if (config.inputPattern != null)
            FilteringTextInputFormatter.allow(RegExp(config.inputPattern!)),
        ],
        textInputAction: config.autoFocusNextRow ? TextInputAction.next : TextInputAction.done,
        onChanged: onChanged,
        onFieldSubmitted: (val) {
          if (config.autoFocusNextRow) {
            FocusScope.of(context).nextFocus(); // Auto push focus to next row
          }
          onFieldSubmitted?.call();
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          helperText: 'Native Interceptor: ${config.keyboardType} (Autocomplete Disabled)',
          prefixIcon: const Icon(Icons.keyboard),
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}
