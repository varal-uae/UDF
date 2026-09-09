// BCDLD-016 — Inline Binary Action Gate Controls.
// A Material 3 widget that presents a definitive binary choice using a SegmentedButton,
// enforces an explicit submit tap, and expires the action after a hardcoded 10-minute window.

import 'dart:async';
import 'package:flutter/material.dart';

class Bcdld016InlineBinaryActionGate extends StatefulWidget {
  const Bcdld016InlineBinaryActionGate({
    super.key,
    required this.summary,
    required this.onSubmit,
    this.positiveLabel = 'Approve',
    this.negativeLabel = 'Deny',
    this.initialSelection,
  });

  final String summary;
  final ValueChanged<bool> onSubmit;
  final String positiveLabel;
  final String negativeLabel;
  final bool? initialSelection;

  @override
  State<Bcdld016InlineBinaryActionGate> createState() =>
      _Bcdld016InlineBinaryActionGateState();
}

class _Bcdld016InlineBinaryActionGateState
    extends State<Bcdld016InlineBinaryActionGate> {
  static const Duration _validityWindow = Duration(minutes: 10);
  Timer? _expiryTimer;
  bool? _selection;
  bool _isExpired = false;
  Duration _remaining = _validityWindow;

  @override
  void initState() {
    super.initState();
    _selection = widget.initialSelection;
    _startExpiryTimer();
  }

  void _startExpiryTimer() {
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= Duration.zero) {
        timer.cancel();
        setState(() => _isExpired = true);
      } else {
        setState(() => _remaining -= const Duration(seconds: 1));
      }
    });
  }

  String get _formattedRemaining {
    final minutes = _remaining.inMinutes.toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _handleSubmit() {
    if (_selection == null || _isExpired) return;
    widget.onSubmit(_selection!);
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Descriptive operational summary container.
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(widget.summary, style: Theme.of(context).textTheme.bodyLarge),
        ),
        const SizedBox(height: 16),
        // Dedicated voting toggle pane directly beneath the summary.
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(
              value: true,
              label: Text(widget.positiveLabel),
              icon: const Icon(Icons.check_circle_outline),
            ),
            ButtonSegment(
              value: false,
              label: Text(widget.negativeLabel),
              icon: const Icon(Icons.cancel_outlined),
            ),
          ],
          selected: _selection == null ? <bool>{} : <bool>{_selection!},
          onSelectionChanged: _isExpired
              ? null
              : (selection) => setState(() => _selection = selection.first),
          emptySelectionAllowed: true,
        ),
        const SizedBox(height: 12),
        // Inline binary action gate: toggle positioned directly above submit button.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isExpired ? 'Expired' : 'Valid for $_formattedRemaining',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: _isExpired ? colorScheme.error : colorScheme.primary,
                  ),
            ),
            FilledButton(
              onPressed: (_selection == null || _isExpired) ? null : _handleSubmit,
              child: const Text('Submit'),
            ),
          ],
        ),
      ],
    );
  }
}
