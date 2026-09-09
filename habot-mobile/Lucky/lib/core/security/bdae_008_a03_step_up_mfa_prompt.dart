// BDAE-008-A03 — Focused Step-Up MFA verification entry block for high-risk actions.
// Renders numeric security code entry inside mobile bottom sheet cards and desktop centered modal dialogs, using split large input boxes, auto-advance, and paste support.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<bool?> showStepUpMfaPrompt(
  BuildContext context, {
  String title = 'Verify it’s you',
  String subtitle = 'Enter the 6-digit security code to continue.',
  Future<bool> Function(String code)? onVerify,
}) {
  final isDesktop = MediaQuery.sizeOf(context).width >= 600;
  final form = _StepUpMfaForm(onVerify: onVerify);

  if (isDesktop) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subtitle),
              const SizedBox(height: 24),
              form,
            ],
          ),
        ),
      ),
    );
  }

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    backgroundColor: Theme.of(context).colorScheme.surface,
    showDragHandle: true,
    builder: (_) => SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
          top: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            form,
          ],
        ),
      ),
    ),
  );
}

class _StepUpMfaForm extends StatefulWidget {
  const _StepUpMfaForm({this.onVerify});
  final Future<bool> Function(String code)? onVerify;
  @override
  State<_StepUpMfaForm> createState() => _StepUpMfaFormState();
}

class _StepUpMfaFormState extends State<_StepUpMfaForm> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  bool get _isComplete => _controllers.every((c) => c.text.length == 1);

  String get _code => _controllers.map((c) => c.text).join();

  void _distribute(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    final clamped = digits.length > 6 ? digits.substring(0, 6) : digits;
    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].text = i < clamped.length ? clamped[i] : '';
    }
    final lastFilled = clamped.isNotEmpty ? clamped.length - 1 : 0;
    _focusNodes[lastFilled].requestFocus();
    setState(() {});
  }

  void _handleChange(int index, String value) {
    if (value.isEmpty) {
      if (index > 0) _focusNodes[index - 1].requestFocus();
      setState(() { _error = null; });
      return;
    }
    if (value.length > 1) {
      _distribute(value);
      return;
    }
    if (value.length == 1) {
      _controllers[index].text = value;
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
      setState(() { _error = null; });
    }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isNotEmpty) {
      _distribute(text);
    }
  }

  Future<void> _submit() async {
    if (!_isComplete || _submitting) return;
    setState(() { _submitting = true; _error = null; });
    final ok = await widget.onVerify?.call(_code) ?? true;
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() { _submitting = false; _error = 'Invalid security code. Try again.'; });
      _controllers[0].clear();
      for (var i = 1; i < _controllers.length; i++) { _controllers[i].clear(); }
      _focusNodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(6, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: i == 0 || i == 5 ? 0 : 4),
                child: TextField(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  autofocus: i == 0,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  textInputAction: i == 5 ? TextInputAction.done : TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: 2),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                  onChanged: (value) => _handleChange(i, value),
                  onSubmitted: (_) { if (_isComplete) _submit(); },
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _paste,
            icon: const Icon(Icons.content_paste_go_rounded, size: 18),
            label: const Text('Paste code'),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isComplete && !_submitting ? _submit : null,
            child: _submitting
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                : const Text('Verify'),
          ),
        ),
      ],
    );
  }
}
