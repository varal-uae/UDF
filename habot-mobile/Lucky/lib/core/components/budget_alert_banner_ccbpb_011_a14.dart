// CCBPB-011-A14 — Budget vs. Actual Expenditure Alert Threshold Banner.
// Reusable Material 3 banner for live budget threshold alerts; supports visibility hooks,
// severity color mapping, and md.sys.color.errorContainer for over-budget breaches.

import 'package:flutter/material.dart';

enum BudgetAlertSeverity { info, warning, critical, overBudget }

class BudgetAlertBanner extends StatelessWidget {
  const BudgetAlertBanner({
    super.key,
    required this.message,
    this.title,
    this.severity = BudgetAlertSeverity.warning,
    this.visible = true,
    this.onDismiss,
    this.actionLabel,
    this.onAction,
    this.semanticLabel,
  });

  final String message;
  final String? title;
  final BudgetAlertSeverity severity;
  final bool visible;
  final VoidCallback? onDismiss;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? semanticLabel;

  bool get _isCritical =>
      severity == BudgetAlertSeverity.critical ||
      severity == BudgetAlertSeverity.overBudget;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final backgroundColor = _backgroundColor(colors);
    final foregroundColor = _foregroundColor(colors);

    return Semantics(
      liveRegion: true,
      label: semanticLabel ?? '${title ?? 'Budget alert'}: $message',
      container: true,
      child: Material(
        color: backgroundColor,
        elevation: _isCritical ? 3 : 0,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_icon, color: foregroundColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null) ...[
                      Text(
                        title!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: foregroundColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: foregroundColor,
                        height: 1.35,
                      ),
                    ),
                    if (actionLabel != null && onAction != null) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: onAction,
                        style: TextButton.styleFrom(
                          foregroundColor: foregroundColor,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(48, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(actionLabel!),
                      ),
                    ],
                  ],
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  onPressed: onDismiss,
                  icon: Icon(Icons.close, color: foregroundColor),
                  tooltip: 'Dismiss budget alert',
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _backgroundColor(ColorScheme colors) {
    switch (severity) {
      case BudgetAlertSeverity.info:
        return colors.surfaceContainerHighest;
      case BudgetAlertSeverity.warning:
        return colors.tertiaryContainer;
      case BudgetAlertSeverity.critical:
      case BudgetAlertSeverity.overBudget:
        return colors.errorContainer;
    }
  }

  Color _foregroundColor(ColorScheme colors) {
    switch (severity) {
      case BudgetAlertSeverity.info:
        return colors.onSurfaceVariant;
      case BudgetAlertSeverity.warning:
        return colors.onTertiaryContainer;
      case BudgetAlertSeverity.critical:
      case BudgetAlertSeverity.overBudget:
        return colors.onErrorContainer;
    }
  }

  IconData get _icon {
    switch (severity) {
      case BudgetAlertSeverity.info:
        return Icons.info_outline;
      case BudgetAlertSeverity.warning:
        return Icons.warning_amber_rounded;
      case BudgetAlertSeverity.critical:
        return Icons.error_outline;
      case BudgetAlertSeverity.overBudget:
        return Icons.block;
    }
  }
}
