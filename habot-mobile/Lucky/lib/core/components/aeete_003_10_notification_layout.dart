// AEETE-003-10 — Notification Layout Standards Component.
// Enforces standard UI guidelines for structural clarity: background contrast, fluid track sizing, spacing/alignment rules, and concise interface microcopy.

import 'package:flutter/material.dart';

/// Layout type for notification presentation.
enum NotificationLayoutType { banner, card, inline }

/// Grid dimensions used by the notification layout.
class NotificationGridDimensions {
  final int columns;
  final double gutter;
  final double borderRadius;
  const NotificationGridDimensions({
    this.columns = 12,
    this.gutter = 8,
    this.borderRadius = 12,
  });
}

/// Spacing rules for notification content.
class NotificationSpacingRules {
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double gap;
  const NotificationSpacingRules({
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(8),
    this.gap = 12,
  });
}

/// Alignment settings for notification content.
class NotificationAlignmentSettings {
  final AlignmentGeometry alignment;
  const NotificationAlignmentSettings({
    this.alignment = Alignment.centerLeft,
  });
}

/// Validation status following the Good/Average/Poor scale.
enum NotificationValidationStatus { good, average, poor }

/// AEETE-003-10 notification layout component.
/// Preserves structural clarity using standard UI guidelines and Material 3 tokens.
class Aeete00310NotificationLayout extends StatelessWidget {
  final String title;
  final String message;
  final NotificationLayoutType layoutType;
  final NotificationGridDimensions gridDimensions;
  final NotificationSpacingRules spacingRules;
  final NotificationAlignmentSettings alignmentSettings;
  final NotificationValidationStatus validationStatus;

  const Aeete00310NotificationLayout({
    super.key,
    required this.title,
    required this.message,
    this.layoutType = NotificationLayoutType.card,
    this.gridDimensions = const NotificationGridDimensions(),
    this.spacingRules = const NotificationSpacingRules(),
    this.alignmentSettings = const NotificationAlignmentSettings(),
    this.validationStatus = NotificationValidationStatus.good,
  });

  bool get isLayoutValid => validationStatus == NotificationValidationStatus.good;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final (background, foreground) = switch (layoutType) {
      NotificationLayoutType.banner => (colorScheme.primaryContainer, colorScheme.onPrimaryContainer),
      NotificationLayoutType.card => (colorScheme.surfaceContainerHighest, colorScheme.onSurface),
      NotificationLayoutType.inline => (colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
    };

    return Semantics(
      container: true,
      label: '$title: $message',
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        margin: spacingRules.margin,
        padding: spacingRules.padding,
        alignment: alignmentSettings.alignment,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(gridDimensions.borderRadius),
          border: Border.all(
            color: isLayoutValid ? colorScheme.outlineVariant : colorScheme.error,
            width: isLayoutValid ? 1 : 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(color: foreground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _ValidationBadge(status: validationStatus),
              ],
            ),
            SizedBox(height: spacingRules.gap),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: spacingRules.gap / 2),
            Text(
              'Layout: ${layoutType.name} | Columns: ${gridDimensions.columns} | Gutter: ${gridDimensions.gutter} | Status: ${validationStatus.name}',
              style: theme.textTheme.labelSmall?.copyWith(color: foreground.withValues(alpha: 0.7)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ValidationBadge extends StatelessWidget {
  final NotificationValidationStatus status;
  const _ValidationBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = switch (status) {
      NotificationValidationStatus.good => (Icons.check_circle, theme.colorScheme.primary),
      NotificationValidationStatus.average => (Icons.warning_amber_rounded, theme.colorScheme.tertiary),
      NotificationValidationStatus.poor => (Icons.error_rounded, theme.colorScheme.error),
    };
    return Tooltip(
      message: 'Validation: ${status.name}',
      child: Icon(icon, size: 18, color: color),
    );
  }
}