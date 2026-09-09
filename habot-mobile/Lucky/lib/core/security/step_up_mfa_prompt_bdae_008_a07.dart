// BDAE-008-A07 — Step-up MFA prompt for high-risk actions.
// Opens as a bottom sheet on mobile and a centered modal on desktop, with split large one-time-code boxes, desktop paste support, and local-only code handling.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef StepUpMfaSubmitCallback = Future<bool> Function(String code);

class StepUpMFAPrompt extends StatefulWidget {
  const StepUpMFAPrompt({
    super.key,
    required this.title,
    this.message,
    required this.onSubmit,
  });

  final String title;
  final String? message;
  final StepUpMfaSubmitCallback onSubmit;

  @override
  State<StepUpMFAPrompt> createState() => _StepUpMFAPromptState();
}

class _StepUpMFAPromptState extends State<StepUpMFAPrompt> {
  static const int _codeLength = 6;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  bool _submitting = false;
  String? _errorText;

  bool get _isDesktop => MediaQuery.sizeOf(context).width >= 600;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _codeLength,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(_codeLength, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((controller) => controller.text).join();

  bool get _isComplete =>
      _code.length == _codeLength &&
      _code.codeUnits.every((unit) => unit >= 48 && unit <= 57);

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      _controllers[index].text = value.substring(value.length - 1);
      _controllers[index].selection = TextSelection.collapsed(
        offset: _controllers[index].text.length,
      );
    }

    if (value.isNotEmpty && index < _codeLength - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }

    setState(() {
      _errorText = null;
    });
  }

  Future<void> _handlePaste() async {
    if (!_isDesktop) return;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text ?? '';
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < _codeLength) return;

    for (var i = 0; i < _codeLength; i++) {
      _controllers[i].text = digits[i];
      _controllers[i].selection = TextSelection.collapsed(offset: 1);
    }

    setState(() {
      _errorText = null;
    });
    FocusScope.of(context).requestFocus(_focusNodes[_codeLength - 1]);
  }

  Future<void> _submit() async {
    if (!_isComplete) {
      setState(() {
        _errorText = 'Enter all $_codeLength digits.';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _errorText = null;
    });

    final isValid = await widget.onSubmit(_code);
    if (!mounted) return;

    if (isValid) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _submitting = false;
        _errorText = 'Verification failed. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_codeLength, (index) {
              return SizedBox(
                width: 48,
                height: 56,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  autofocus: index == 0,
                  enabled: !_submitting,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) => _onChanged(index, value),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                ),
              );
            }),
          ),
          if (_isDesktop) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _submitting ? null : _handlePaste,
              icon: const Icon(Icons.content_paste_go),
              label: const Text('Paste verification code'),
            ),
          ],
          if (_errorText != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Verify'),
          ),
        ],
      ),
    );
  }
}

Future<bool?> showStepUpMfaPrompt(
  BuildContext context, {
  required String title,
  String? message,
  required StepUpMfaSubmitCallback onSubmit,
}) {
  final isDesktop = MediaQuery.sizeOf(context).width >= 600;

  if (isDesktop) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: StepUpMFAPrompt(
            title: title,
            message: message,
            onSubmit: onSubmit,
          ),
        ),
      ),
    );
  }

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => SafeArea(
      child: StepUpMFAPrompt(
        title: title,
        message: message,
        onSubmit: onSubmit,
      ),
    ),
  );
}
