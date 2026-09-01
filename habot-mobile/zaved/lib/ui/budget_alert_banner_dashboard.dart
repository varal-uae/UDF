// ============================================================================
// COMPONENT METADATA BLOCK
// Object Type: Stateful Widget / Budget Alert Banner & Dashboard
// Object Location/Path: @habot/ui-components-core/budget_alert_banner_dashboard.dart
// Open Status: Active / Open
// Timestamp: 2026-08-19T11:24:40+05:30
// File Handle ID: FILE-CCBPB-011-BAB
// Completion Status: Pass - Environment & Configuration Setup Readiness
// ============================================================================

import 'package:flutter/material.dart';

/// CCBPB-011: BudgetAlertBanner & Dashboard
///
/// Features live metric cost comparison, sticky M3 error banner pinning,
/// and 100% hard limit lockout (Poka-Yoke) when current spend meets/exceeds budget limit.
class BudgetAlertBannerDashboard extends StatefulWidget {
  final double initialSpend;
  final double budgetLimit;

  const BudgetAlertBannerDashboard({
    super.key,
    this.initialSpend = 950.0,
    this.budgetLimit = 1000.0,
  });

  @override
  State<BudgetAlertBannerDashboard> createState() =>
      _BudgetAlertBannerDashboardState();
}

class _BudgetAlertBannerDashboardState
    extends State<BudgetAlertBannerDashboard> {
  late double _currentSpend;
  late double _budgetLimit;

  @override
  void initState() {
    super.initState();
    _currentSpend = widget.initialSpend;
    _budgetLimit = widget.budgetLimit;
  }

  void _addExpense(double amount) {
    setState(() {
      _currentSpend += amount;
    });
  }

  void _resetSpend() {
    setState(() {
      _currentSpend = 450.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isOverBudget = _currentSpend >= _budgetLimit;
    final spendPercentage = (_currentSpend / _budgetLimit * 100).clamp(0, 999).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Budget Alert Banner (CCBPB-011)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: "Reset Spend to \$450",
            onPressed: _resetSpend,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Sticky Viewport Pinning: Banner outside scrolling view, pinned below AppBar
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isOverBudget
                  ? Container(
                      key: const ValueKey("over_budget_banner"),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 14.0,
                      ),
                      // Standardized M3 Error Banner styling
                      color: colorScheme.errorContainer,
                      child: Row(
                        children: [
                          Icon(
                            Icons.error,
                            color: colorScheme.onErrorContainer,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "CRITICAL BUDGET OVERRUN DETECTED ($spendPercentage%)",
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onErrorContainer,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Current spend (\$$_currentSpend) meets or exceeds budget limit (\$$_budgetLimit). Purchase locks active.",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onErrorContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey("normal_banner")),
            ),

            // Main Dashboard Viewport
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth <= 600;

                  return ListView(
                    padding: const EdgeInsets.all(20.0),
                    children: [
                      // Metric Summary Cards
                      if (isMobile) ...[
                        _buildMetricCard(
                          context,
                          title: "Current Spend",
                          value: "\$${_currentSpend.toStringAsFixed(2)}",
                          icon: Icons.account_balance_wallet,
                          isWarning: isOverBudget,
                        ),
                        const SizedBox(height: 12),
                        _buildMetricCard(
                          context,
                          title: "Budget Cap Limit",
                          value: "\$${_budgetLimit.toStringAsFixed(2)}",
                          icon: Icons.savings,
                          isWarning: false,
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                context,
                                title: "Current Spend",
                                value: "\$${_currentSpend.toStringAsFixed(2)}",
                                icon: Icons.account_balance_wallet,
                                isWarning: isOverBudget,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildMetricCard(
                                context,
                                title: "Budget Cap Limit",
                                value: "\$${_budgetLimit.toStringAsFixed(2)}",
                                icon: Icons.savings,
                                isWarning: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Spend Progress Bar
                      Text(
                        "Budget Utilization Rate: $spendPercentage%",
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: (_currentSpend / _budgetLimit).clamp(0.0, 1.0),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(8),
                        color: isOverBudget ? colorScheme.error : colorScheme.primary,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                      ),
                      const SizedBox(height: 32),

                      // Simulator Controls
                      Text(
                        "Simulate Purchase Operations",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _addExpense(100.0),
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text("Add \$100 Purchase"),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _addExpense(500.0),
                            icon: const Icon(Icons.add_alert),
                            label: const Text("Add \$500 Big Purchase"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // 100% Hard Limit Lockout (Poka-Yoke): FilledButton onPressed set to null if over budget
                      Card(
                        elevation: 0,
                        color: colorScheme.surfaceContainerHigh,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Purchase Submission Gate (Poka-Yoke)",
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isOverBudget
                                    ? "Submission locked: Current spend meets/exceeds budget limit."
                                    : "Budget clear: Purchase submissions enabled.",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isOverBudget
                                      ? colorScheme.error
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 48.0,
                                child: FilledButton.icon(
                                  // Physically blocked when currentSpend >= budgetLimit
                                  onPressed: isOverBudget
                                      ? null
                                      : () {
                                          _addExpense(75.0);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("New \$75 purchase submitted!"),
                                            ),
                                          );
                                        },
                                  icon: Icon(
                                    isOverBudget ? Icons.block : Icons.shopping_bag,
                                  ),
                                  label: Text(
                                    isOverBudget
                                        ? "100% Hard Limit Lockout Active"
                                        : "Submit New Purchase (\$75)",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required bool isWarning,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: isWarning
          ? colorScheme.errorContainer
          : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isWarning ? colorScheme.error : colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isWarning
                  ? colorScheme.error.withValues(alpha: 0.2)
                  : colorScheme.primaryContainer,
              child: Icon(
                icon,
                color: isWarning
                    ? colorScheme.error
                    : colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isWarning
                        ? colorScheme.onErrorContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isWarning
                        ? colorScheme.onErrorContainer
                        : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
