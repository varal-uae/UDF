// RIMV-002-A15 — Poka-Yoke Input Masking & Validation Utilities.
// Provides regex-constrained input formatters, native keyboard type mapping, and visual error feedback (shake animation) for Material 3 TextFields to prevent invalid data entry at the source.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enum representing supported input mask types for Poka-Yoke validation.
enum InputMaskType {
  numeric,
  decimal,
  email,
  phone,
  alphaOnly,
  alphanumeric,
  date,
}

/// Configuration blueprint for regex-constrained input elements.
class PokaYokeInputConfig {
  final InputMaskType maskType;
  final RegExp regExp;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final String errorMessage;

  const PokaYokeInputConfig._({
    required this.maskType,
    required this.regExp,
    required this.keyboardType,
    required this.inputFormatters,
    required this.errorMessage,
  });

  /// Factory method to generate input configurations based on mask type.
  factory PokaYokeInputConfig.fromType(InputMaskType type) {
    switch (type) {
      case InputMaskType.numeric:
        return PokaYokeInputConfig._(
          maskType: type,
          regExp: RegExp(r'^[0-9]*$'),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          errorMessage: 'Only numeric characters are allowed.',
        );
      case InputMaskType.decimal:
        return PokaYokeInputConfig._(
          maskType: type,
          regExp: RegExp(r'^\d*\.?\d*$'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
          ],
          errorMessage: 'Invalid decimal format.',
        );
      case InputMaskType.email:
        return PokaYokeInputConfig._(
          maskType: type,
          regExp: RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
          keyboardType: TextInputType.emailAddress,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
          ],
          errorMessage: 'Invalid email address format.',
        );
      case InputMaskType.phone:
        return PokaYokeInputConfig._(
          maskType: type,
          regExp: RegExp(r'^\+?[0-9\-\s()]*$'),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\+?[0-9\-\s()]*$')),
          ],
          errorMessage: 'Invalid phone number format.',
        );
      case InputMaskType.alphaOnly:
        return PokaYokeInputConfig._(
          maskType: type,
          regExp: RegExp(r'^[a-zA-Z]*$'),
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.lettersOnly,
          ],
          errorMessage: 'Only alphabetic characters are allowed.',
        );
      case InputMaskType.alphanumeric:
        return PokaYokeInputConfig._(
          maskType: type,
          regExp: RegExp(r'^[a-zA-Z0-9]*$'),
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]*$')),
          ],
          errorMessage: 'Only alphanumeric characters are allowed.',
        );
      case InputMaskType.date:
        return PokaYokeInputConfig._(
          maskType: type,
          regExp: RegExp(r'^[0-9\-/]*$'),
          keyboardType: TextInputType.datetime,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^[0-9\-/]*$')),
          ],
          errorMessage: 'Invalid date format.',
        );
    }
  }
}

/// A StatefulWidget wrapper that applies a shake animation when invalid input is detected.
/// Implements the "visual feedback (shake or color flash) if invalid key pressed" requirement.
class PokaYokeShakeField extends StatefulWidget {
  final TextEditingController controller;
  final PokaYokeInputConfig config;
  final InputDecoration? decoration;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const PokaYokeShakeField({
    super.key,
    required this.controller,
    required this.config,
    this.decoration,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<PokaYokeShakeField> createState() => _PokaYokeShakeFieldState();
}

class _PokaYokeShakeFieldState extends State<PokaYokeShakeField>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _hasError = false;
  String _lastValidText = '';

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));

    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final currentText = widget.controller.text;
    // Self-chasing: validate locally before backend latency
    if (!widget.config.regExp.hasMatch(currentText)) {
      // Revert to last valid state (rejected keystroke)
      widget.controller.value = TextEditingValue(
        text: _lastValidText,
        selection: TextSelection.collapsed(offset: _lastValidText.length),
      );
      
      if (!_shakeController.isAnimating) {
        setState(() => _hasError = true);
        _shakeController.forward(from: 0.0).then((_) {
          if (mounted) {
            setState(() => _hasError = false);
          }
        });
      }
    } else {
      _lastValidText = currentText;
      if (_hasError) {
        setState(() => _hasError = false);
      }
      widget.onChanged?.call(currentText);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Dismissing active mobile software keyboards automatically when forms enter loading modes
    // handled by `enabled` flag.
    if (!widget.enabled) {
      FocusScope.of(context).unfocus();
    }

    final baseDecoration = widget.decoration ?? InputDecoration(
      labelText: widget.config.maskType.name.toUpperCase(),
      border: const OutlineInputBorder(),
    );

    final errorDecoration = baseDecoration.copyWith(
      errorText: _hasError ? widget.config.errorMessage : null,
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.error, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.colorScheme.error, width: 2.0),
      ),
    );

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.config.keyboardType,
        inputFormatters: widget.config.inputFormatters,
        decoration: errorDecoration,
        enabled: widget.enabled,
        style: theme.textTheme.bodyLarge,
      ),
    );
  }
}

/// Mock telemetry logger for capturing test metrics as per Data Requirement.
class InputMaskTelemetryLogger {
  static final List<Map<String, dynamic>> _logs = [];

  static void logTestRun({
    required String testType,
    required bool testResult,
    required double testCoverage,
  }) {
    _logs.add({
      'test_type': testType,
      'test_result': testResult ? 'Pass' : 'Fail',
      'test_coverage': testCoverage,
      'test_timestamp': DateTime.now().toIso8601String(),
      'test_log_path': '/mock/logs/input_mask_${DateTime.now().millisecondsSinceEpoch}.log',
      'completion_status': testResult ? 'Pass' : 'Fail',
    });
  }

  static List<Map<String, dynamic>> get logs => List.unmodifiable(_logs);
  
  static double get passRate {
    if (_logs.isEmpty) return 0.0;
    final passed = _logs.where((l) => l['test_result'] == 'Pass').length;
    return passed / _logs.length;
  }
}
