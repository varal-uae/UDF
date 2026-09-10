// CSIVW-014-A11 — Sentiment-Aware Text Input Filter for UDF forms.
// Provides as-you-type sentiment validation, dynamic border/helper feedback, submit gating,
// shake feedback on invalid submission, and dropdown fallback after repeated violations.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class SentimentCheckResult {
  const SentimentCheckResult({
    required this.isValid,
    this.reason,
    this.isBannedLanguage = false,
  });

  final bool isValid;
  final String? reason;
  final bool isBannedLanguage;
}

typedef SentimentValidator = Future<SentimentCheckResult> Function(String text);

typedef SentimentTextSubmitted = void Function(String text, {required bool fromFallback});

class SentimentAwareTextInput extends StatefulWidget {
  const SentimentAwareTextInput({
    super.key,
    required this.sentimentValidator,
    required this.onSubmitted,
    this.controller,
    this.label = 'Message',
    this.hint = 'Type your message',
    this.fallbackOptions = const <String>[],
    this.debounceDuration = const Duration(milliseconds: 450),
    this.maxViolations = 3,
  });

  final SentimentValidator sentimentValidator;
  final SentimentTextSubmitted onSubmitted;
  final TextEditingController? controller;
  final String label;
  final String hint;
  final List<String> fallbackOptions;
  final Duration debounceDuration;
  final int maxViolations;

  @override
  State<SentimentAwareTextInput> createState() => _SentimentAwareTextInputState();
}

class _SentimentAwareTextInputState extends State<SentimentAwareTextInput>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final AnimationController _shakeController;

  Timer? _debounce;
  bool _isChecking = false;
  bool _isValid = true;
  String? _errorText;
  int _violationCount = 0;
  bool _showDropdownFallback = false;
  String? _selectedFallback;

  bool get _isFallbackMode => _showDropdownFallback && widget.fallbackOptions.isNotEmpty;

  bool get _canSubmit {
    if (_isChecking) return false;
    if (_isFallbackMode) return _selectedFallback != null;
    return _controller.text.trim().isNotEmpty && _isValid;
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _debounce?.cancel();
    final text = _controller.text.trim();

    if (text.isEmpty) {
      setState(() {
        _isChecking = false;
        _isValid = true;
        _errorText = null;
      });
      return;
    }

    setState(() {
      _isChecking = true;
      _errorText = null;
    });

    _debounce = Timer(widget.debounceDuration, () => _runValidation(text));
  }

  Future<void> _runValidation(String text) async {
    final result = await widget.sentimentValidator(text);
    if (!mounted || _controller.text.trim() != text) return;

    setState(() {
      _isChecking = false;
      _isValid = result.isValid;
      _errorText = result.isValid ? null : (result.reason ?? 'Please revise your message.');
    });
  }

  void _shake() {
    _shakeController.forward(from: 0);
  }

  void _handleSubmit() {
    if (_isFallbackMode) {
      if (_selectedFallback == null) {
        _shake();
        return;
      }
      widget.onSubmitted(_selectedFallback!, fromFallback: true);
      return;
    }

    if (_isChecking || !_isValid || _controller.text.trim().isEmpty) {
      _shake();
      _registerViolation();
      return;
    }

    widget.onSubmitted(_controller.text.trim(), fromFallback: false);
  }

  void _registerViolation() {
    _violationCount += 1;
    if (_violationCount >= widget.maxViolations && widget.fallbackOptions.isNotEmpty) {
      setState(() {
        _showDropdownFallback = true;
        _selectedFallback = null;
      });
    }
  }

  InputDecoration _decoration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = _isChecking
        ? colorScheme.tertiary
        : _isValid
            ? colorScheme.outline
            : colorScheme.error;

    return InputDecoration(
      labelText: widget.label,
      hintText: widget.hint,
      errorText: _errorText,
      helperText: _isChecking ? 'Checking sentiment...' : 'As-you-type validation above the keyboard.',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final progress = _shakeController.value;
        final dx = math.sin(progress * math.pi * 4) * 8 * (1 - progress);
        return Transform.translate(
          offset: Offset(dx, 0),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isFallbackMode)
            DropdownButtonFormField<String>(
              value: _selectedFallback,
              decoration: InputDecoration(
                labelText: widget.label,
                helperText: 'Free-text entry disabled after repeated sentiment violations.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: widget.fallbackOptions
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                setState(() {
                  _selectedFallback = value;
                });
              },
            )
          else
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              minLines: 3,
              maxLines: 6,
              textInputAction: TextInputAction.newline,
              decoration: _decoration(context),
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _isChecking ? null : _handleSubmit,
            style: _canSubmit
                ? null
                : FilledButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    foregroundColor: colorScheme.onSurfaceVariant,
                  ),
            child: _isChecking
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
