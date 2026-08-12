import 'package:flutter/material.dart';
import 'pulsing_cta.dart';

/// Reusable Empty State Boilerplate enforcing centered layout and PulsingCTA action.
class EmptyStateBoilerplate extends StatelessWidget {
  const EmptyStateBoilerplate({
    super.key,
    required this.title,
    required this.description,
    required this.illustration,
    required this.onCtaPressed,
    this.ctaLabel = 'Get Started',
  });

  final String title;
  final String description;
  final Widget illustration;
  final VoidCallback onCtaPressed;
  final String ctaLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration container
            SizedBox(
              height: 120.0,
              width: 120.0,
              child: Center(child: illustration),
            ),
            const SizedBox(height: 24.0),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),

            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32.0),

            // Pulsing CTA Button
            PulsingCTA(
              label: ctaLabel,
              onPressed: onCtaPressed,
            ),
          ],
        ),
      ),
    );
  }
}
