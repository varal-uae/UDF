// BDAE-008-A02 — Step-up MFA inline secondary validation prompt.
// Opens a secure verification sheet on mobile or a centered modal on desktop. Splits security codes into separate large entry boxes and allows desktop paste.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StepUpMfaPrompt extends StatefulWidget {
  const StepUpMfaPrompt({
    super.key,
    required this.onVerify,
    this.onCancel,
    this.codeLength = 6,
  });

  final Future<bool> Function(String code) onVerify;
  final VoidCallback? onCancel;
  final int codeLength;

  static Future<bool?> show(
    BuildContext context, {
    required Future<bool> Function(String code) onVerify,
    int codeLength = 6,
  }) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 600;
    final prompt = StepUpMfaPrompt(
      codeLength: codeLength,
      onVerify: onVerify,
    );

    if (isDesktop) {
      return showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          content: SizedBox(
            width: 420,
            child: prompt,
          ),
        ),
      );
    }

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: prompt,
          ),
        ),
      ),
    );
  }

  @override
  State<StepUpMfaPrompt> createState() => _StepUpMfaPromptState();
}

class _StepUpMfaPromptState extends State<StepUpMfaPrompt> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  String? _errorText;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.codeLength,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.codeLength,
      (_) => FocusNode(),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _handleCodeInput(int index, String value) {
    if (value.isEmpty) {
      return;
    }

    if (value.length == 1) {
      if (index < widget.codeLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
      return;
    }

    final digits = value.split('');
    int digitIndex = 0;
    for (int i = index; i < widget.codeLength && digitIndex < digits.length; i++) {
      _controllers[i].text = digits[digitIndex];
      digitIndex++;
    }

    if (digitIndex > 0) {
      final lastFilledIndex = index + digitIndex - 1;
      if (lastFilledIndex < widget.codeLength - 1) {
        _focusNodes[lastFilledIndex + 1].requestFocus();
      } else {
        _focusNodes[lastFilledIndex].unfocus();
      }
    }
  }

  Future<void> _verify() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != widget.codeLength) {
      setState(() {
        _errorText = 'Enter all ${widget.codeLength} digits.';
      });
      return;
    }

    setState(() {
      _verifying = true;
      _errorText = null;
    });

    final isValid = await widget.onVerify(code);

    if (!mounted) return;

    setState(() {
      _verifying = false;
      _errorText = isValid ? null : 'Invalid code. Please try again.';
    });

    if (isValid) {
      Navigator.of(context).pop(true);
    }
  }

  void _cancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    } else {
      Navigator.of(context).maybePop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Step-up verification',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the security code from your secure device.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.codeLength, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SizedBox(
                width: 48,
                child: TextField(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  keyboardType: TextInputType.number,
                  textInputAction: i == widget.codeLength - 1
                      ? TextInputAction.done
                      : TextInputAction.next,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                  ),
                  onChanged: (value) => _handleCodeInput(i, value),
                  onSubmitted: (_) => _verify(),
                  onTap: () => _controllers[i].selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _controllers[i].text.length,
                  ),
                ),
              ),
            );
          }),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 16),
          Text(
            _errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _verifying ? null : _cancel,
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: _verifying ? null : _verify,
              child: _verifying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Verify'),
            ),
          ],
        ),
      ],
    );
  }
}