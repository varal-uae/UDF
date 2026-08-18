// BCDLD-002 — Mobile Edge Client DCYN Rejection Response Handler.
// Renders immediate rejection modal and toast messages upon edge gate rejection payloads.

import 'package:flutter/material.dart';

class DcynRejectionPayload {
  const DcynRejectionPayload({
    required this.rejectionCode,
    required this.reason,
    required this.timestamp,
  });

  final String rejectionCode;
  final String reason;
  final String timestamp;
}

class DcynRejectionHandler {
  DcynRejectionHandler._();

  static void handleRejection(BuildContext context, DcynRejectionPayload payload) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // 1. Instant Toast Notification (<100ms visual response)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Action Rejected: ${payload.reason}'),
        backgroundColor: cs.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );

    // 2. Comprehensive Rejection Modal Dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.block, color: cs.error, size: 40),
        title: const Text('Edge Gate Blocked Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rejection Code: ${payload.rejectionCode}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(payload.reason, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Text('Timestamp: ${payload.timestamp}', style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace', color: cs.onSurfaceVariant)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Acknowledge'),
          ),
        ],
      ),
    );
  }
}
