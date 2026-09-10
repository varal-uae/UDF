// CCBPB-011-A16 — Budget vs. Actual Expenditure Alert Threshold Banner.
// Standardized Material 3 banner for live budget alerts, with conditional visibility, errorContainer breach styling, and responsive mobile typography.

import 'package:flutter/material.dart';

class BudgetAlertBanner extends StatelessWidget {
  const BudgetAlertBanner({
    super.key,
    required this.message,
    this.isVisible = true,
    this.isBreached = false,
    this.onActionPressed,
    this.actionLabel,
  });

  final String message;
  final bool isVisible;
  final bool isBreached;
  final VoidCallback? onActionPressed;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isBreached
        ? colorScheme.errorContainer
        : colorScheme.tertiaryContainer;
    final foregroundColor = isBreached
        ? colorScheme.onErrorContainer
        : colorScheme.onTertiaryContainer;

    return SafeArea(
      bottom: false,
      child: Material(
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isBreached ? Icons.error_outline : Icons.warning_amber_rounded,
                color: foregroundColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                ),
              ),
              if (actionLabel != null && onActionPressed != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onActionPressed,
                  style: TextButton.styleFrom(
                    foregroundColor: foregroundColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(48, 48),
                  ),
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class BudgetThresholdGuard {
  const BudgetThresholdGuard._();

  static bool canSubmitPurchase({
    required double actualSpend,
    required double budgetLimit,
  }) {
    if (budgetLimit <= 0) {
      return false;
    }
    return actualSpend < budgetLimit;
  }

  static bool isBreached({
    required double actualSpend,
    required double budgetLimit,
  }) {
    return budgetLimit > 0 && actualSpend >= budgetLimit;
  }
}
