/// COMPONENT METADATA BLOCK
/// Configuration Key: BPTR_0407_ANIMATED_MASKED_INPUT
/// Configuration Value: SHAKE_HAPTIC_3STRIKE_ENABLED
/// Configuration Type: UI_INTERACTIVE_INPUT_MASK
/// Validation Status: VALIDATED
/// Configuration Timestamp: 2026-08-18T10:38:28Z
/// Completion Status: Target: Complete - Requirements Traceability Coverage
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// BPTR-0407: Animated Masked Input Field with Localized Shake & 3-Strike Tutorial Tooltip
class AnimatedMaskedInputField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final String formatMask; // e.g. "XXX-XX-XXXX" or "AAA-123"
  final ValueChanged<String>? onChanged;

  const AnimatedMaskedInputField({
    super.key,
    this.labelText = 'Security Identification Code',
    this.hintText = 'ABC-1234',
    this.formatMask = 'AAA-0000',
    this.onChanged,
  });

  @override
  State<AnimatedMaskedInputField> createState() =>
      _AnimatedMaskedInputFieldState();
}

class _AnimatedMaskedInputFieldState extends State<AnimatedMaskedInputField>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  final TextEditingController _controller = TextEditingController();

  int _failedAttempts = 0;
  bool _showTutorial = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Horizontal Shake Offset Curve
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _triggerShakeAndHaptic() {
    HapticFeedback.heavyImpact();
    _shakeController.forward(from: 0.0);

    setState(() {
      _failedAttempts++;
      if (_failedAttempts >= 3) {
        _showTutorial = true;
      }
      _errorText = 'Invalid keystroke format detected';
    });
  }

  void _resetErrorsOnValidInput() {
    if (_failedAttempts > 0 || _showTutorial || _errorText != null) {
      setState(() {
        _failedAttempts = 0;
        _showTutorial = false;
        _errorText = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 3-Strike Format Tutorial Tooltip Container (Auto-expanding via AnimatedSize)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _showTutorial
                ? Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: colorScheme.error,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Poka-Yoke Format Tutorial (3-Strike Triggered)',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Required format: 3 Uppercase Letters followed by a hyphen and 4 Digits (e.g., ABC-1234). Non-conforming keystrokes are rejected.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onErrorContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Localized Horizontal Shake Container
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              final double offset =
                  math.sin(_shakeAnimation.value * math.pi * 6) * 12.0;
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: TextFormField(
                controller: _controller,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  _CustomPatternMaskFormatter(
                    formatMask: widget.formatMask,
                    onInvalidKeystroke: _triggerShakeAndHaptic,
                    onValidKeystroke: _resetErrorsOnValidInput,
                  ),
                ],
                onChanged: (val) {
                  if (widget.onChanged != null) {
                    widget.onChanged!(val);
                  }
                },
                decoration: InputDecoration(
                  labelText: widget.labelText,
                  hintText: widget.hintText,
                  errorText: _errorText,
                  prefixIcon: Icon(
                    Icons.security_sharp,
                    color: colorScheme.primary,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: colorScheme.outline),
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
                      width: 2.0,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: colorScheme.error,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom TextInputFormatter enforcing ABC-1234 format mask with invalid keystroke interception
class _CustomPatternMaskFormatter extends TextInputFormatter {
  final String formatMask;
  final VoidCallback onInvalidKeystroke;
  final VoidCallback onValidKeystroke;

  _CustomPatternMaskFormatter({
    required this.formatMask,
    required this.onInvalidKeystroke,
    required this.onValidKeystroke,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length < oldValue.text.length) {
      // Allow backspace deletion
      onValidKeystroke();
      return newValue;
    }

    final newText = newValue.text;
    if (newText.isEmpty) {
      onValidKeystroke();
      return newValue;
    }

    // Example pattern: AAA-0000 (3 uppercase letters, hyphen, 4 numbers)
    final insertedChar = newText.substring(newText.length - 1);
    final index = newText.length - 1;

    if (index >= 8) {
      // Reached max length limit
      onInvalidKeystroke();
      return oldValue;
    }

    bool isValid = false;

    if (index < 3) {
      // First 3 chars must be letters
      if (RegExp(r'[a-zA-Z]').hasMatch(insertedChar)) {
        isValid = true;
        // Auto uppercase conversion
        final uppercaseText = newText.toUpperCase();
        onValidKeystroke();
        return TextEditingValue(
          text: uppercaseText,
          selection: TextSelection.collapsed(offset: uppercaseText.length),
        );
      }
    } else if (index == 3) {
      // 4th char is auto hyphen or check hyphen
      if (insertedChar == '-' || RegExp(r'[0-9]').hasMatch(insertedChar)) {
        isValid = true;
        String formatted = newText;
        if (!newText.contains('-')) {
          formatted = '${newText.substring(0, 3)}-${newText.substring(3)}';
        }
        onValidKeystroke();
        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    } else {
      // Remaining chars must be digits
      if (RegExp(r'[0-9]').hasMatch(insertedChar)) {
        isValid = true;
      }
    }

    if (!isValid) {
      onInvalidKeystroke();
      return oldValue;
    }

    onValidKeystroke();
    return newValue;
  }
}
