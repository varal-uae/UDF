// BPTR-0407-A02 — Masking Feedback Animations: haptic shake, dynamic error hints, and auto tutorial.
// Intercepts invalid input with formatters, vibrates on rejection, and expands a format tutorial after repeated failures.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable Material 3 text field that applies an input mask and provides
/// immediate localized feedback without blocking the on-screen keyboard.
class MaskedFeedbackField extends StatefulWidget {
  const MaskedFeedbackField({
    super.key,
    required this.label,
    required this.controller,
    required this.maskFormatter,
    this.validator,
    this.formatHint = 'Please follow the required format.',
    this.attemptLimit = 3,
    this.helperText,
  });

  final String label;
  final TextEditingController controller;
  final TextInputFormatter maskFormatter;
  final String? Function(String?)? validator;
  final String formatHint;
  final int attemptLimit;
  final String? helperText;

  @override
  State<MaskedFeedbackField> createState() => _MaskedFeedbackFieldState();
}

class _MaskedFeedbackFieldState extends State<MaskedFeedbackField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  late final Animation<Offset> _shakeOffset = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0.05, 0),
  ).chain(CurveTween(curve: Curves.elasticOut)).animate(_shakeController);

  int _failedAttempts = 0;
  String? _errorText;

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _validate(String value) {
    final error = widget.validator?.call(value);
    if (error != null) {
      setState(() {
        _errorText = error;
        _failedAttempts++;
      });
      HapticFeedback.vibrate();
      _shakeController.forward(from: 0);
    } else if (_errorText != null) {
      setState(() {
        _errorText = null;
        _failedAttempts = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showTutorial = _failedAttempts >= widget.attemptLimit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            return Transform.translate(
              offset: _shakeOffset.value,
              child: child,
            );
          },
          child: TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              labelText: widget.label,
              helperText: widget.helperText,
              errorText: _errorText,
              errorMaxLines: 3,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            inputFormatters: [widget.maskFormatter],
            onChanged: _validate,
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: showTutorial
              ? Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.formatHint,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
