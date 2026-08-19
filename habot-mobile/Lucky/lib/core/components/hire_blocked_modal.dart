// ACRAE-028 — Hire Blocked Exception Modal & Override Request.
// Renders an M3 Error Modal Dialog when compliance validation fails, with HeadlineSmall block reasons and Request Override workflow.

import 'package:flutter/material.dart';

class HireBlockedModal extends StatelessWidget {
  const HireBlockedModal({
    super.key,
    required this.missingScoresCount,
    required this.blockReason,
    required this.onRequestOverride,
  });

  final int missingScoresCount;
  final String blockReason;
  final VoidCallback onRequestOverride;

  static Future<void> show(
    BuildContext context, {
    required int missingScoresCount,
    required String blockReason,
    required VoidCallback onRequestOverride,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => HireBlockedModal(
        missingScoresCount: missingScoresCount,
        blockReason: blockReason,
        onRequestOverride: () {
          Navigator.of(ctx).pop();
          onRequestOverride();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AlertDialog(
      icon: Icon(Icons.block, size: 48, color: cs.error),
      title: Text(
        'Hire Blocked',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: cs.error,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Compliance Gate Rejection: $missingScoresCount out of 20 score fields are missing.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            blockReason,
            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(minimumSize: const Size(100, 48)),
          child: const Text('Back'),
        ),
        FilledButton.icon(
          onPressed: onRequestOverride,
          icon: const Icon(Icons.shield, size: 18),
          label: const Text('Request Override'),
          style: FilledButton.styleFrom(
            backgroundColor: cs.error,
            foregroundColor: cs.onError,
            minimumSize: const Size(160, 48),
          ),
        ),
      ],
    );
  }
}
