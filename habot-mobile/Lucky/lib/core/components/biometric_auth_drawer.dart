// BDAE-001 — Native Biometric API Challenge Bridge.
// Displays bottom sheet drawer on mobile viewports (<840dp) and centered dialog on desktop (>840dp).
// Enforces 48x48dp confirmation touch targets and relaxed 24dp desktop padding.

import 'package:flutter/material.dart';

class BiometricAuthDrawer extends StatelessWidget {
  const BiometricAuthDrawer({
    super.key,
    required this.challengeTitle,
    required this.onAuthenticate,
    required this.onCancel,
  });

  final String challengeTitle;
  final VoidCallback onAuthenticate;
  final VoidCallback onCancel;

  static Future<void> show(
    BuildContext context, {
    required String challengeTitle,
    required VoidCallback onAuthenticate,
    required VoidCallback onCancel,
  }) async {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 840) {
      // Desktop / Wide viewport: Centered focus-locked dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24.0), // 24dp desktop internal margin
              child: BiometricAuthDrawer(
                challengeTitle: challengeTitle,
                onAuthenticate: () {
                  Navigator.of(ctx).pop();
                  onAuthenticate();
                },
                onCancel: () {
                  Navigator.of(ctx).pop();
                  onCancel();
                },
              ),
            ),
          ),
        ),
      );
    } else {
      // Mobile viewport: Compact bottom drawer
      await showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: BiometricAuthDrawer(
            challengeTitle: challengeTitle,
            onAuthenticate: () {
              Navigator.of(ctx).pop();
              onAuthenticate();
            },
            onCancel: () {
              Navigator.of(ctx).pop();
              onCancel();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.fingerprint, size: 56, color: cs.primary),
        const SizedBox(height: 16),
        Text(
          'Biometric Verification',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          challengeTitle,
          style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(100, 48), // Enforces 48dp target
              ),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: onAuthenticate,
              icon: const Icon(Icons.fingerprint, size: 20),
              label: const Text('Authenticate'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(140, 48), // Enforces 48dp target
              ),
            ),
          ],
        ),
      ],
    );
  }
}
