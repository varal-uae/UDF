// BPTR-0407-A05 — Masking Feedback Animations Component.
// Provides a reusable input field wrapper with 'shake-failure' animation, haptic feedback, and auto-expanding validation hints for mobile format errors.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MaskingFeedbackField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final int maxLines;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  const MaskingFeedbackField({
    super.key,
    this.labelText,
    this.hintText,
    this.validator,
    this.inputFormatters,
    this.keyboardType,
    this.controller,
    this.maxLines = 1,
    this.autofocus = false,
    this.onChanged,
    this.onFieldSubmitted,
  });

  @override
  State<MaskingFeedbackField> createState() => _MaskingFeedbackFieldState();
}

class _MaskingFeedbackFieldState extends State<MaskingFeedbackField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  String? _errorText;
  TextEditingController? _internalController;

  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -1.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: -0.5)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -0.5, end: 0.5)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.5, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(_shakeController);
  }

  void _validateAndShake(String? value) {
    final validator = widget.validator;
    if (validator == null) return;
    final result = validator(value);
    if (result != null) {
      if (_errorText != result) {
        setState(() => _errorText = result);
        HapticFeedback.vibrate();
        _shakeController.forward(from: 0);
      }
    } else {
      if (_errorText != null) {
        setState(() => _errorText = null);
      }
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    if (widget.controller == null) {
      _internalController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final dx = _shakeAnimation.value * 6.0;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: child,
        );
      },
      child: TextFormField(
        controller: _controller,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        maxLines: widget.maxLines,
        autofocus: widget.autofocus,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          errorText: _errorText,
          border: const OutlineInputBorder(),
          errorMaxLines: 3,
        ),
        onChanged: (value) {
          _validateAndShake(value);
          widget.onChanged?.call(value);
        },
        onFieldSubmitted: (value) {
          _validateAndShake(value);
          widget.onFieldSubmitted?.call(value);
        },
      ),
    );
  }
}