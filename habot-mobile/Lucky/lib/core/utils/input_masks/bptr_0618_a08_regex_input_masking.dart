// BPTR-0618-A08 — Regex Input Masking for Mobile Forms.
// Reusable Flutter TextInputFormatter and masked text field that enforce regex-validated mobile input,
// format as the user types, block invalid keystrokes, and expose validity for submit gating.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegexMaskInputFormatter extends TextInputFormatter {
  RegexMaskInputFormatter({
    required this.allowedCharsPattern,
    required this.mask,
    this.onInvalidAttempt,
  });

  final RegExp allowedCharsPattern;
  final String mask;
  final VoidCallback? onInvalidAttempt;

  int get maxRawLength => mask.split('').where((char) => _isPlaceholder(char)).length;

  bool _isPlaceholder(String char) => char == '#' || char == 'A' || char == '*';

  Set<String> get _maskLiterals => mask
      .split('')
      .where((char) => !_isPlaceholder(char))
      .toSet();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = _extractRaw(newValue.text);
    final hasInvalidChar = newValue.text
        .split('')
        .any((char) => !allowedCharsPattern.hasMatch(char) && !_maskLiterals.contains(char));

    if (hasInvalidChar || raw.length > maxRawLength) {
      onInvalidAttempt?.call();
      return oldValue;
    }

    final formatted = _applyMask(raw);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _extractRaw(String input) {
    return input
        .split('')
        .where((char) => allowedCharsPattern.hasMatch(char))
        .join();
  }

  String _applyMask(String raw) {
    final buffer = StringBuffer();
    var rawIndex = 0;

    for (var maskIndex = 0;
        maskIndex < mask.length && rawIndex < raw.length;
        maskIndex++) {
      final maskChar = mask[maskIndex];

      if (_isPlaceholder(maskChar)) {
        buffer.write(raw[rawIndex]);
        rawIndex++;
      } else {
        buffer.write(maskChar);
      }
    }

    return buffer.toString();
  }
}

class RegexMaskedTextField extends StatefulWidget {
  const RegexMaskedTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.mask,
    required this.allowedCharsPattern,
    required this.validationPattern,
    this.helperText,
    this.errorText,
    this.keyboardType = TextInputType.number,
    this.onValidChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String mask;
  final RegExp allowedCharsPattern;
  final RegExp validationPattern;
  final String? helperText;
  final String? errorText;
  final TextInputType keyboardType;
  final ValueChanged<bool>? onValidChanged;

  @override
  State<RegexMaskedTextField> createState() => _RegexMaskedTextFieldState();
}

class _RegexMaskedTextFieldState extends State<RegexMaskedTextField> {
  bool _isValid = false;
  bool _touched = false;
  bool _pulseInvalid = false;

  @override
  void initState() {
    super.initState();
    _isValid = _computeValidity();
    widget.controller.addListener(_validate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validate);
    super.dispose();
  }

  void _validate() {
    final nextValid = _computeValidity();
    if (nextValid == _isValid) return;

    setState(() {
      _isValid = nextValid;
    });
    widget.onValidChanged?.call(nextValid);
  }

  bool _computeValidity() {
    final raw = _extractRaw(widget.controller.text);
    return raw.isNotEmpty && widget.validationPattern.hasMatch(raw);
  }

  String _extractRaw(String input) {
    return input
        .split('')
        .where((char) => widget.allowedCharsPattern.hasMatch(char))
        .join();
  }

  void _onInvalidAttempt() {
    if (!mounted) return;

    setState(() {
      _pulseInvalid = true;
    });

    Future.delayed(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      setState(() {
        _pulseInvalid = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _pulseInvalid ? theme.colorScheme.error : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        textInputAction: TextInputAction.next,
        inputFormatters: [
          RegexMaskInputFormatter(
            allowedCharsPattern: widget.allowedCharsPattern,
            mask: widget.mask,
            onInvalidAttempt: _onInvalidAttempt,
          ),
        ],
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          helperText: widget.helperText,
          errorText: _touched && !_isValid
              ? (widget.errorText ?? 'Invalid format')
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
        onTap: () {
          if (!_touched) {
            setState(() {
              _touched = true;
            });
          }
        },
        onChanged: (_) => _validate(),
      ),
    );
  }
}
