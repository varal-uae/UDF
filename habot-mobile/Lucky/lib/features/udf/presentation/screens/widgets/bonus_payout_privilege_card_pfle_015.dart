// PFLE-015 — Bonus Payout Privilege Control Card.
// Enforces least-privilege UI rendering for bonus payout fields with read-only lock icons, high-contrast MD3 typography, haptic pull-to-refresh feedback, and Poka-Yoke boundary controls.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mock domain data representing role-based privilege assignments.
class _PrivilegeMockData {
  static const Map<String, List<String>> rolePermissions = {
    'COMPENSATION_ADMIN': ['base_salary', 'bonus_metric', 'payout_final'],
    'HR_MANAGER': ['base_salary', 'bonus_metric'],
    'EMPLOYEE': ['base_salary'],
  };

  static const Map<String, dynamic> employeeMetrics = {
    'user_id': 'USR-99281',
    'execution_id': 'EXEC-34290-PFLE015',
    'execution_status': 'COMPLETED',
    'execution_timestamp': '2026-09-23T14:30:00Z',
    'step_outcome': 'PASS',
    'base_salary': 45000.00,
    'bonus_metric': 12.5,
    'payout_final': 5625.00,
    'financial_accuracy_pct': 100.0,
  };
}

class BonusPayoutPrivilegeCard extends StatefulWidget {
  final String userRole;

  const BonusPayoutPrivilegeCard({
    super.key,
    required this.userRole,
  });

  @override
  State<BonusPayoutPrivilegeCard> createState() => _BonusPayoutPrivilegeCardState();
}

class _BonusPayoutPrivilegeCardState extends State<BonusPayoutPrivilegeCard> {
  bool _isRefreshing = false;
  late Map<String, dynamic> _mockData;
  late List<String> _allowedFields;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _mockData = Map<String, dynamic>.from(_PrivilegeMockData.employeeMetrics);
    _allowedFields = _PrivilegeMockData.rolePermissions[widget.userRole] ?? [];
  }

  Future<void> _handleRefresh() async {
    // Poka-Yoke: Prevent concurrent refresh actions
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    // Haptic feedback triggered on data refresh as per UX Translation
    await HapticFeedback.mediumImpact();

    // Simulate network delay for pull-to-refresh logic
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // Mistake-Proofing: Validate financial accuracy boundaries (Floor: 99.99, Optimal/Ceiling: 100)
    final double accuracy = _mockData['financial_accuracy_pct'] as double;
    if (accuracy < 99.99 || accuracy > 100.0) {
      // Boundary control fails closed by default
      _mockData['execution_status'] = 'REJECTED';
      _mockData['step_outcome'] = 'FAIL';
    }

    setState(() {
      _isRefreshing = false;
    });
  }

  bool _hasPermission(String fieldKey) {
    return _allowedFields.contains(fieldKey);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      // Never steal input focus away from active fields to announce mundane background status steps
      notificationPredicate: (ScrollNotification notification) {
        return notification.depth == 0;
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // High-contrast typography indicating final bonus metrics
              Text(
                'Performance Bonus Payouts',
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Role: ${widget.userRole} | Status: ${_mockData['execution_status']}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24.0),
              
              // Auto-adjust vertical stacking bounds cleanly on narrow responsive screens
              _buildMetricField(
                context: context,
                label: 'Base Salary',
                value: '\$${_mockData['base_salary'].toStringAsFixed(2)}',
                fieldKey: 'base_salary',
              ),
              const SizedBox(height: 16.0),
              _buildMetricField(
                context: context,
                label: 'Bonus Metric (%)',
                value: '${_mockData['bonus_metric']}%',
                fieldKey: 'bonus_metric',
              ),
              const SizedBox(height: 16.0),
              _buildMetricField(
                context: context,
                label: 'Final Payout',
                value: '\$${_mockData['payout_final'].toStringAsFixed(2)}',
                fieldKey: 'payout_final',
                isFinalMetric: true,
              ),
              
              const SizedBox(height: 32.0),
              
              // Pin placement vectors rigidly above the hardware interaction strip
              SafeArea(
                top: false,
                child: FilledButton.icon(
                  onPressed: _isRefreshing ? null : _handleRefresh,
                  icon: const Icon(Icons.sync),
                  label: const Text('Refresh Metrics'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricField({
    required BuildContext context,
    required String label,
    required String value,
    required String fieldKey,
    bool isFinalMetric = false,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isPermitted = _hasPermission(fieldKey);

    return Card(
      elevation: 0,
      color: isPermitted ? colorScheme.surfaceContainerHighest : colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: isPermitted ? colorScheme.outlineVariant : colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isPermitted ? colorScheme.onSurfaceVariant : colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  // Leverage bold canvas contrast treatments to guarantee readability
                  Text(
                    isPermitted ? value : '••••••••',
                    style: (isFinalMetric ? theme.textTheme.titleLarge : theme.textTheme.bodyLarge)?.copyWith(
                      fontWeight: isFinalMetric ? FontWeight.w800 : FontWeight.w500,
                      color: isPermitted 
                          ? (isFinalMetric ? colorScheme.primary : colorScheme.onSurface)
                          : colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
            // Lock icons explicitly displayed on read-only fields
            if (!isPermitted)
              Icon(
                Icons.lock_outline_rounded,
                color: colorScheme.error.withOpacity(0.7),
                size: 24.0,
                semanticLabel: 'Read-only field: Access denied for current role',
              )
            else
              Icon(
                Icons.check_circle_outline_rounded,
                color: colorScheme.primary,
                size: 24.0,
                semanticLabel: 'Authorized field',
              ),
          ],
        ),
      ),
    );
  }
}
