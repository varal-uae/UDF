import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/semantic_status_colors.dart';

/// Formatter that nullifies invalid keystrokes, masks visual format, and triggers callback counters.
class RegexMaskFormatter extends TextInputFormatter {
  RegexMaskFormatter({
    required this.mask,
    required this.allowedCharRegex,
    required this.onInvalidKeystroke,
    required this.onValidKeystroke,
  });

  final String mask;
  final RegExp allowedCharRegex;
  final VoidCallback onInvalidKeystroke;
  final VoidCallback onValidKeystroke;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Character deletion handled normally
    if (newValue.text.length < oldValue.text.length) {
      onValidKeystroke();
      return newValue;
    }

    // Isolate newly typed character
    final addedChar = newValue.text.substring(oldValue.text.length);

    // 3. Keystroke Nullification: Reject non-matching keystrokes
    if (!allowedCharRegex.hasMatch(addedChar)) {
      onInvalidKeystroke();
      return oldValue;
    }

    onValidKeystroke();

    // 2. Real-Time Visual Masking (e.g., ##/##/####)
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9a-zA-Z]'), '');
    final buffer = StringBuffer();
    int digitIndex = 0;

    for (int i = 0; i < mask.length && digitIndex < digitsOnly.length; i++) {
      if (mask[i] == '#') {
        buffer.write(digitsOnly[digitIndex]);
        digitIndex++;
      } else {
        buffer.write(mask[i]);
      }
    }

    final formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

/// Mobile Regex Input Masking Enforcer with dynamic keyboard, 3-strike Poka-Yoke tooltip, and error highlights.
class MaskedRegexInputField extends StatefulWidget {
  const MaskedRegexInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.mask,
    required this.allowedCharRegex,
    required this.fullMatchRegex,
    required this.expectedFormatHint,
    this.inputMode = TextInputType.number,
    this.controller,
    this.onChanged,
  });

  final String label;
  final String hintText;
  final String mask;
  final RegExp allowedCharRegex;
  final RegExp fullMatchRegex;
  final String expectedFormatHint;
  final TextInputType inputMode;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  State<MaskedRegexInputField> createState() => _MaskedRegexInputFieldState();
}

class _MaskedRegexInputFieldState extends State<MaskedRegexInputField> {
  late final TextEditingController _controller;
  int _invalidKeystrokeCount = 0;
  bool _showFormatTooltip = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  /// 4. The 3-Strike Tooltip (Poka-Yoke) counter trigger
  void _handleInvalidKeystroke() {
    setState(() {
      _invalidKeystrokeCount++;
      if (_invalidKeystrokeCount >= 3) {
        _showFormatTooltip = true;
      }
    });
  }

  /// Reset counter on valid keystroke
  void _handleValidKeystroke() {
    if (_invalidKeystrokeCount != 0 || _showFormatTooltip) {
      setState(() {
        _invalidKeystrokeCount = 0;
        _showFormatTooltip = false;
      });
    }
  }

  /// 5. Validate full string and trigger red border highlight
  void _validateFullMatch(String value) {
    final isMatch = widget.fullMatchRegex.hasMatch(value);
    setState(() {
      _hasError = value.isNotEmpty && !isMatch;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColors = theme.extension<SemanticStatusColors>()!;
    final errorColor = statusColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 4. Animated 3-Strike Tooltip Poka-Yoke Notice
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _showFormatTooltip
              ? Container(
                  key: const ValueKey('3_strike_tooltip'),
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: errorColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: errorColor, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 18.0, color: errorColor),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          '3 Invalid Keystrokes! ${widget.expectedFormatHint}',
                          style: TextStyle(
                            color: errorColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // 1. Dynamic Keyboard & 5. Red-Highlight Errors via InputDecoration
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48.0),
          child: TextFormField(
            controller: _controller,
            keyboardType: widget.inputMode,
            inputFormatters: [
              RegexMaskFormatter(
                mask: widget.mask,
                allowedCharRegex: widget.allowedCharRegex,
                onInvalidKeystroke: _handleInvalidKeystroke,
                onValidKeystroke: _handleValidKeystroke,
              ),
            ],
            onChanged: _validateFullMatch,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hintText,
              helperText: widget.expectedFormatHint,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14.0,
                horizontal: 16.0,
              ),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: _hasError ? errorColor : theme.colorScheme.outline,
                  width: _hasError ? 2.0 : 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: _hasError ? errorColor : theme.colorScheme.primary,
                  width: 2.0,
                ),
              ),
              errorText: _hasError ? 'Invalid format. ${widget.expectedFormatHint}' : null,
            ),
          ),
        ),
      ],
    );
  }
}
