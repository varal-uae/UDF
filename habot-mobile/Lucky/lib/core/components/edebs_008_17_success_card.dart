// EDEBS-008-17 — Full-width MD3 elevated success card for verified mobile vendor onboarding.
// Implements a fixed structural layout: full-width Card, MD3 elevated surface, stacked verified record, and 48dp padding.

import 'package:flutter/material.dart';

class Edebs00817SuccessCard extends StatelessWidget {
  const Edebs00817SuccessCard({
    super.key,
    required this.title,
    required this.message,
    required this.verifiedLabel,
    this.validationStatus = 'Layout Validation Status: Valid',
    this.actionLabel,
    this.onActionPressed,
  });

  final String title;
  final String message;
  final String verifiedLabel;
  final String validationStatus;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  static const double horizontalPadding = 48.0;
  static const double verticalPadding = 48.0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Semantics(
      container: true,
      label: 'Success card: $title. $verifiedLabel. $validationStatus',
      child: SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 3,
          margin: EdgeInsets.zero,
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(
                  Icons.verified_rounded,
                  size: 48,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        verifiedLabel,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        validationStatus,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (actionLabel != null && onActionPressed != null) ...<Widget>[
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: onActionPressed,
                    child: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
