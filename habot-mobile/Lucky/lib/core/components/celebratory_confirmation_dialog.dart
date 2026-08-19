// ACRAE-031 — Finalize Hire & Celebratory Confirmation Dialog.
// Displays an M3 dialog with HeadlineMedium celebratory message, primary Lock Record button, and tap-and-hold interaction.

import 'package:flutter/material.dart';

class CelebratoryConfirmationDialog extends StatefulWidget {
  const CelebratoryConfirmationDialog({
    super.key,
    required this.celebrationMessage,
    required this.candidateName,
    required this.onFinalizeLock,
  });

  final String celebrationMessage;
  final String candidateName;
  final VoidCallback onFinalizeLock;

  static Future<void> show(
    BuildContext context, {
    required String celebrationMessage,
    required String candidateName,
    required VoidCallback onFinalizeLock,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CelebratoryConfirmationDialog(
        celebrationMessage: celebrationMessage,
        candidateName: candidateName,
        onFinalizeLock: () {
          Navigator.of(ctx).pop();
          onFinalizeLock();
        },
      ),
    );
  }

  @override
  State<CelebratoryConfirmationDialog> createState() => _CelebratoryConfirmationDialogState();
}

class _CelebratoryConfirmationDialogState extends State<CelebratoryConfirmationDialog> {
  double _holdProgress = 0.0;
  bool _isHolding = false;

  void _startHolding() async {
    setState(() => _isHolding = true);
    for (int i = 1; i <= 10; i++) {
      if (!_isHolding) break;
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted && _isHolding) {
        setState(() => _holdProgress = i / 10);
      }
    }
    if (_holdProgress >= 1.0 && mounted) {
      widget.onFinalizeLock();
    }
  }

  void _cancelHolding() {
    setState(() {
      _isHolding = false;
      _holdProgress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AlertDialog(
      icon: Icon(Icons.stars_rounded, size: 48, color: cs.primary),
      title: Text(
        'Success Felicitations!',
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: cs.primary,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.celebrationMessage,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Candidate: ${widget.candidateName}',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            'Press and hold button to Lock Record',
            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: _holdProgress, color: cs.primary),
        ],
      ),
      actions: [
        GestureDetector(
          onTapDown: (_) => _startHolding(),
          onTapUp: (_) => _cancelHolding(),
          onTapCancel: _cancelHolding,
          child: FilledButton.icon(
            onPressed: () {}, // Handled via tap-and-hold gesture
            icon: const Icon(Icons.lock, size: 18),
            label: Text(_isHolding ? 'Holding to Lock (${(_holdProgress * 100).toInt()}%)' : 'Hold to Lock Record'),
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
      ],
    );
  }
}
