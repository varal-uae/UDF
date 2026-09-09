// AEETE-022 — SecureFieldMask conditional field masking container.
// Renders sensitive values as a 4-character masked placeholder with a padlock icon,
// blocks text selection/copy, and triggers a clearance request callback on tap.
// A responsive grid adapts from single column to balanced double columns beyond 1024dp.

import 'package:flutter/material.dart';

/// A conditional field masking container that hides sensitive values behind a
/// standard masked placeholder and a padlock marker. Vertical internal cell
/// padding is fixed to exactly 6dp top and bottom. Text selection and clipboard
/// copying are disabled inside the masked area.
class SecureFieldMask extends StatelessWidget {
  const SecureFieldMask({
    super.key,
    required this.label,
    this.value,
    this.maskCharacter = '•',
    this.maskLength = 4,
    this.onClearanceRequest,
  });

  final String label;
  final String? value;
  final String maskCharacter;
  final int maskLength;
  final VoidCallback? onClearanceRequest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maskedValue = value == null
        ? ''
        : List.filled(maskLength, maskCharacter).join();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 4),
          SelectionContainer.disabled(
            child: InkWell(
              onTap: onClearanceRequest,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      maskedValue,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Responsive grid for multiple [SecureFieldMask] fields. Uses a single column
/// below 1024dp and balanced double columns at or above 1024dp.
class SecureFieldMaskGrid extends StatelessWidget {
  const SecureFieldMaskGrid({
    super.key,
    required this.children,
    this.spacing = 12,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1024;
        if (!isWide) {
          return Column(
            children: children,
          );
        }
        final itemWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(
                width: itemWidth,
                child: child,
              ),
          ],
        );
      },
    );
  }
}