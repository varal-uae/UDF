import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

// BPTR-0377-A01 — Shakti Alert overlay.
// Critical system alert rendered at z-index level 40 (shaktiAlert).
// Always topmost — dashboards, modals, and overlays must never obscure it.
// Inserted via Overlay so it sits above the entire Navigator stack.
//
// Usage:
//   ShaktiAlert.show(context, message: 'Session expired. Please log in again.');
//   ShaktiAlert.show(context, message: 'App update required.', type: ShaktiAlertType.forceUpgrade);

enum ShaktiAlertType { critical, forceUpgrade, sessionExpired, networkError }

class ShaktiAlert {
  ShaktiAlert._();

  static OverlayEntry? _activeEntry;

  static void show(
    BuildContext context, {
    required String message,
    ShaktiAlertType type = ShaktiAlertType.critical,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    dismiss();

    _activeEntry = OverlayEntry(
      builder: (_) => _ShaktiAlertWidget(
        message:     message,
        type:        type,
        onAction:    onAction,
        actionLabel: actionLabel,
        onDismiss:   dismiss,
      ),
    );

    Overlay.of(context).insert(_activeEntry!);
  }

  static void dismiss() {
    _activeEntry?.remove();
    _activeEntry = null;
  }
}

class _ShaktiAlertWidget extends StatelessWidget {
  const _ShaktiAlertWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
    this.onAction,
    this.actionLabel,
  });

  final String message;
  final ShaktiAlertType type;
  final VoidCallback onDismiss;
  final VoidCallback? onAction;
  final String? actionLabel;

  // Z-index enforced via Overlay — always above all Navigator routes.
  // Corresponds to HabotZIndex.shaktiAlert = 40.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        elevation: HabotElevation.level5,
        color: _backgroundColor(theme),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(_icon, color: _foregroundColor(theme), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _foregroundColor(theme),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (onAction != null && actionLabel != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      foregroundColor: _foregroundColor(theme),
                      minimumSize: const Size(0, 48),
                    ),
                    child: Text(actionLabel!),
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: _foregroundColor(theme),
                  tooltip: 'Dismiss',
                  onPressed: onDismiss,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _backgroundColor(ThemeData theme) {
    switch (type) {
      case ShaktiAlertType.forceUpgrade:
        return theme.colorScheme.primaryContainer;
      case ShaktiAlertType.sessionExpired:
        return theme.colorScheme.secondaryContainer;
      case ShaktiAlertType.networkError:
        return theme.colorScheme.surfaceContainerHighest;
      case ShaktiAlertType.critical:
        return theme.colorScheme.errorContainer;
    }
  }

  Color _foregroundColor(ThemeData theme) {
    switch (type) {
      case ShaktiAlertType.forceUpgrade:
        return theme.colorScheme.onPrimaryContainer;
      case ShaktiAlertType.sessionExpired:
        return theme.colorScheme.onSecondaryContainer;
      case ShaktiAlertType.networkError:
        return theme.colorScheme.onSurface;
      case ShaktiAlertType.critical:
        return theme.colorScheme.onErrorContainer;
    }
  }

  IconData get _icon {
    switch (type) {
      case ShaktiAlertType.forceUpgrade:   return Icons.system_update_rounded;
      case ShaktiAlertType.sessionExpired: return Icons.lock_outline_rounded;
      case ShaktiAlertType.networkError:   return Icons.cloud_off_rounded;
      case ShaktiAlertType.critical:       return Icons.warning_amber_rounded;
    }
  }
}
