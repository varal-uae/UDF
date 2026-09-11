// FCSES-018 — Fail-Closed Blocking Banner.
// Renders a Material 3 error-container banner beneath a persistent header and blocks content until restoration.
import 'package:flutter/material.dart';

class FailClosedBlockingBanner extends StatelessWidget {
  const FailClosedBlockingBanner({
    super.key,
    required this.message,
    this.title = 'Access restricted',
    this.actionLabel,
    this.onExplicitAction,
    this.canDismiss = false,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onExplicitAction;
  final bool canDismiss;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.errorContainer,
      elevation: 0,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.gpp_maybe_rounded,
                color: colorScheme.onErrorContainer,
                size: 28,
                semanticLabel: 'Security caution',
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onErrorContainer,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (canDismiss && onExplicitAction != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onExplicitAction,
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onErrorContainer,
                    textStyle: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: Text(actionLabel ?? 'Review'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class FailClosedBlockingBannerOverlay extends StatelessWidget {
  const FailClosedBlockingBannerOverlay({
    super.key,
    required this.child,
    required this.isActive,
    required this.message,
    this.topOffset = kToolbarHeight,
    this.title = 'Access restricted',
    this.actionLabel,
    this.onExplicitAction,
    this.canDismiss = false,
  });

  final Widget child;
  final bool isActive;
  final String message;
  final double topOffset;
  final String title;
  final String? actionLabel;
  final VoidCallback? onExplicitAction;
  final bool canDismiss;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isActive) ...[
          Positioned.fill(
            top: topOffset,
            child: const ModalBarrier(
              dismissible: false,
              color: Colors.transparent,
            ),
          ),
          Positioned(
            top: topOffset,
            left: 0,
            right: 0,
            child: FailClosedBlockingBanner(
              title: title,
              message: message,
              actionLabel: actionLabel,
              onExplicitAction: onExplicitAction,
              canDismiss: canDismiss,
            ),
          ),
        ],
      ],
    );
  }
}
