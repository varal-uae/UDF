// GEN-00318 — Media Error Fallback Placeholder (M3).
// Renders a Material 3 placeholder illustration when a media load fails, with an
// optional 48x48dp retry touch target. The CI/CD merge-gate portion of GEN-00318
// is infrastructure-only (pipeline/branch protection) and is not actionable in this
// Flutter codebase; this widget covers the Flutter-actionable fallback requirement.

import 'package:flutter/material.dart';

/// A reusable, mistake-proofed fallback widget for failed media loads.
///
/// Use [MediaErrorFallbackGen00318.wrap] to attach an `errorBuilder` to any
/// [Image.network] (or similar) call site, or render the fallback directly.
class MediaErrorFallbackGen00318 extends StatelessWidget {
  const MediaErrorFallbackGen00318({
    super.key,
    this.onRetry,
    this.message,
    this.compact = false,
  });

  /// Optional retry callback. When provided, a 48x48dp M3 retry action is shown.
  final VoidCallback? onRetry;

  /// Optional override for the fallback message shown to the user.
  final String? message;

  /// When true, renders a reduced-height variant for dense layouts (e.g. list tiles).
  final bool compact;

  /// Returns an [ImageErrorWidgetBuilder] that renders this fallback on failure.
  static ImageErrorWidgetBuilder errorBuilder({
    VoidCallback? onRetry,
    String? message,
    bool compact = false,
  }) {
    return (BuildContext context, Object error, StackTrace? stackTrace) {
      return MediaErrorFallbackGen00318(
        onRetry: onRetry,
        message: message,
        compact: compact,
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final Widget illustration = Icon(
      Icons.broken_image_outlined,
      size: compact ? 32 : 56,
      color: colorScheme.onSurfaceVariant,
    );

    final Widget label = Text(
      message ?? 'Media unavailable',
      style: (compact ? textTheme.bodySmall : textTheme.bodyMedium)?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );

    return Semantics(
      image: true,
      label: message ?? 'Media failed to load. Placeholder shown.',
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: compact ? 72 : 160),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: compact ? 8 : 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            illustration,
            SizedBox(height: compact ? 4 : 12),
            label,
            if (onRetry != null) ...<Widget>[
              SizedBox(height: compact ? 4 : 12),
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  onPressed: onRetry,
                  tooltip: 'Retry loading media',
                  icon: Icon(Icons.refresh, color: colorScheme.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
