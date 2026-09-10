// CKCKM-019 — Access Revoked Screen for IAM key rotation/session invalidation.
// Displays a Material 3 empty state when a worker's session tokens are invalidated after encryption key rotation or security policy enforcement.

import 'package:flutter/material.dart';

class AccessRevokedCkckm019Screen extends StatelessWidget {
  const AccessRevokedCkckm019Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Revoked'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Your session has been revoked',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Access to the portal has been disabled. Please contact your administrator if you believe this is an error.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
