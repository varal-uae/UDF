// BCDLD-001-19 — Verified Profile Badge & Trust Indicator Card.
// Renders approved profile pictures with a system verification badge and prominent trust cards with help links for missing credentials, using clear typography hierarchy and standard context layout.

import 'package:flutter/material.dart';

class Bcdld00119VerifiedProfileBadge extends StatelessWidget {
  const Bcdld00119VerifiedProfileBadge({
    super.key,
    required this.profileImageUrl,
    required this.isApproved,
    required this.isVerified,
    required this.hasMissingCredentials,
    required this.onHelpTap,
  });

  final String profileImageUrl;
  final bool isApproved;
  final bool isVerified;
  final bool hasMissingCredentials;
  final VoidCallback onHelpTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!isApproved) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(profileImageUrl),
            ),
            if (isVerified) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.verified,
                color: theme.colorScheme.primary,
                size: 20,
                semanticLabel: 'Verified system badge',
              ),
            ],
          ],
        ),
        if (hasMissingCredentials) ...[
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Some credentials are missing.',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onHelpTap,
                    child: const Text('Help'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
