import 'package:flutter/material.dart';

// PELCE-039-13 — Passive Failure Protocol.
// Defines all passive failure UI patterns per MD3 + Nielsen Norman heuristics.
// 4 patterns:
//   1. PassiveEmptyState     — MD3 empty state illustration + safe retry button
//   2. PassiveErrorSnackbar  — full-width error snackbar (bottom, auto-dismiss)
//   3. PassiveBottomError    — bottom pop-up persistent error sheet
//   4. PassiveInlineError    — inline disabled-state error with retry
//
// Rule: passive failures NEVER interrupt the user violently.
// Shakti Alert (shakti_alert.dart) handles violent interruptions.

// ─── 1. EMPTY STATE ILLUSTRATION + RETRY ─────────────────────────────────────

enum PassiveFailureType {
  networkError,
  serverError,
  noResults,
  noData,
  sessionExpired,
  permissionDenied,
  timeout,
}

class PassiveEmptyState extends StatelessWidget {
  const PassiveEmptyState({
    super.key,
    required this.type,
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.isRetrying = false,
  });

  final PassiveFailureType type;
  final VoidCallback? onRetry;
  final String retryLabel;

  /// When true — retry button is disabled and shows loading indicator.
  /// Prevents double-tap during in-flight retry.
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _config(type);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // MD3 Empty State illustration
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                config.icon,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              config.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Body
            Text(
              config.body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Safe retry button — disabled during retry to prevent double-tap.
            if (onRetry != null)
              FilledButton.icon(
                onPressed: isRetrying ? null : onRetry,
                icon: isRetrying
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : Icon(_retryIcon(type)),
                label: Text(isRetrying ? 'Retrying…' : retryLabel),
              ),
          ],
        ),
      ),
    );
  }

  IconData _retryIcon(PassiveFailureType type) {
    switch (type) {
      case PassiveFailureType.networkError:
      case PassiveFailureType.timeout:
        return Icons.wifi_rounded;
      case PassiveFailureType.sessionExpired:
        return Icons.login_rounded;
      default:
        return Icons.refresh_rounded;
    }
  }

  _EmptyStateConfig _config(PassiveFailureType type) {
    switch (type) {
      case PassiveFailureType.networkError:
        return _EmptyStateConfig(
          icon:  Icons.cloud_off_rounded,
          title: 'No connection',
          body:  'Check your internet connection and try again.',
        );
      case PassiveFailureType.serverError:
        return _EmptyStateConfig(
          icon:  Icons.dns_rounded,
          title: 'Service unavailable',
          body:  'We\'re having trouble reaching our servers. Try again shortly.',
        );
      case PassiveFailureType.noResults:
        return _EmptyStateConfig(
          icon:  Icons.search_off_rounded,
          title: 'No results found',
          body:  'Try adjusting your search or filters.',
        );
      case PassiveFailureType.noData:
        return _EmptyStateConfig(
          icon:  Icons.inbox_rounded,
          title: 'Nothing here yet',
          body:  'Data will appear here once it\'s available.',
        );
      case PassiveFailureType.sessionExpired:
        return _EmptyStateConfig(
          icon:  Icons.lock_outline_rounded,
          title: 'Session expired',
          body:  'Your session has ended. Please log in again.',
        );
      case PassiveFailureType.permissionDenied:
        return _EmptyStateConfig(
          icon:  Icons.block_rounded,
          title: 'Access restricted',
          body:  'You don\'t have permission to view this content.',
        );
      case PassiveFailureType.timeout:
        return _EmptyStateConfig(
          icon:  Icons.timer_off_rounded,
          title: 'Request timed out',
          body:  'This is taking longer than expected. Please try again.',
        );
    }
  }
}

class _EmptyStateConfig {
  const _EmptyStateConfig({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;
}

// ─── 2. FULL-WIDTH ERROR SNACKBAR ─────────────────────────────────────────────

/// MD3 full-width error snackbar — bottom of screen, auto-dismisses.
/// Safe retry action included. Never blocks the UI.
class PassiveErrorSnackbar {
  PassiveErrorSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          width: double.infinity,
          duration: duration,
          action: (actionLabel != null && onAction != null)
              ? SnackBarAction(label: actionLabel, onPressed: onAction)
              : null,
        ),
      );
  }
}

// ─── 3. BOTTOM POP-UP PERSISTENT ERROR SHEET ─────────────────────────────────

/// MD3 bottom pop-up error — persistent modal bottom sheet.
/// Used when the error requires user acknowledgement before continuing.
/// Includes safe retry button and dismiss option.
class PassiveBottomError extends StatelessWidget {
  const PassiveBottomError({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.onDismiss,
    this.isRetrying = false,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final VoidCallback? onDismiss;
  final bool isRetrying;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
    String retryLabel = 'Try Again',
    bool isRetrying = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      builder: (_) => PassiveBottomError(
        title:      title,
        message:    message,
        onRetry:    onRetry,
        retryLabel: retryLabel,
        isRetrying: isRetrying,
        onDismiss:  () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Icon
          Icon(
            Icons.error_outline_rounded,
            size: 40,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Message
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Retry — disabled during in-flight retry
          if (onRetry != null)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isRetrying ? null : onRetry,
                child: Text(isRetrying ? 'Retrying…' : retryLabel),
              ),
            ),
          const SizedBox(height: 8),

          // Dismiss
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onDismiss ?? () => Navigator.of(context).pop(),
              child: const Text('Dismiss'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 4. INLINE DISABLED-STATE ERROR ──────────────────────────────────────────

/// Inline error row — used inside forms or list items.
/// Shows error message with a disabled-style retry button.
/// Button re-enables once [isRetrying] is false.
class PassiveInlineError extends StatelessWidget {
  const PassiveInlineError({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.isRetrying = false,
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: isRetrying ? null : onRetry,
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onErrorContainer,
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(
                isRetrying ? '…' : retryLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
