// EDBAA-020-A05 — System Action Button for objective UI command copy.
// Provides a Material 3 outlined action button with explicit command text,
// responsive padding, and a progress overlay on tap for immediate feedback.

import 'package:flutter/material.dart';

class SystemActionButton extends StatelessWidget {
  const SystemActionButton({
    super.key,
    required this.commandLabel,
    required this.onPressed,
    this.isLoading = false,
  });

  final String commandLabel;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final effectiveOnPressed = isLoading ? null : onPressed;

    return Semantics(
      button: true,
      enabled: effectiveOnPressed != null,
      label: commandLabel,
      child: Stack(
        alignment: Alignment.center,
        children: [
          OutlinedButton(
            onPressed: effectiveOnPressed,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              minimumSize: const Size(64, 48),
              side: BorderSide(color: colorScheme.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: textTheme.labelLarge,
              foregroundColor: colorScheme.primary,
            ),
            child: Text(
              commandLabel,
              textAlign: TextAlign.center,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withAlpha(153),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
