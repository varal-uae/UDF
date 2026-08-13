import 'package:flutter/material.dart';

/// FEBFL-018-A01 — Standard "Service Unavailable" fallback UI.
/// Centered layout, maximizing whitespace. Friendly, non-alarming.
/// Clear typography hierarchy: title → body → error code → CTA.
class ErrorFallbackScreen extends StatelessWidget {
  const ErrorFallbackScreen({
    super.key,
    required this.module,
    required this.onRetry,
  });

  final String module;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorCode = 'ERR-${module.toUpperCase().replaceAll(' ', '_')}';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Illustration
                Icon(
                  Icons.cloud_off_rounded,
                  size: 80,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'Something went wrong',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Body
                Text(
                  'We\'re having trouble loading this section.\nPlease try again or go back home.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Error code
                Text(
                  errorCode,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 40),

                // Primary CTA — Retry
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Try Again'),
                ),
                const SizedBox(height: 12),

                // Secondary CTA — Go Home
                TextButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text('Return to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
