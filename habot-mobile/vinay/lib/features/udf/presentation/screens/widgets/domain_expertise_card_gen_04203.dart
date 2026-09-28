// GEN-04203 — Domain Expertise Engagement Status Card.
// M3 Elevated Card displaying RACI role assignment coverage, completion state, and liveness handshake status for mobile engineering console.

import 'package:flutter/material.dart';

enum _StepStatus { pass, fail, pending }

class _RoleAssignment {
  final String role;
  final String assignee;
  final bool isAssigned;

  const _RoleAssignment({
    required this.role,
    required this.assignee,
    required this.isAssigned,
  });
}

class _Gen04203MockData {
  static const String atomicId = 'GEN-04203';
  static const String stepName = 'Domain Expertise Engagement';
  static const String standard = 'PMBOK 7th Edition – RACI Responsibility Assignment Practice';
  static const int pollingIntervalSeconds = 30;
  static const _StepStatus overallStatus = _StepStatus.pass;

  static const List<_RoleAssignment> roles = [
    _RoleAssignment(role: 'Mobile UI Developer', assignee: 'Alex Chen', isAssigned: true),
    _RoleAssignment(role: 'Operations Systems Engineer', assignee: 'Sarah Miller', isAssigned: true),
    _RoleAssignment(role: 'GCP Architect', assignee: 'James Wilson', isAssigned: true),
    _RoleAssignment(role: 'UX/UI Designer (MD3)', assignee: 'Maria Garcia', isAssigned: true),
    _RoleAssignment(role: 'DCDF Engine Architect', assignee: 'Pending Assignment', isAssigned: false),
  ];
}

class DomainExpertiseCardGen04203 extends StatefulWidget {
  const DomainExpertiseCardGen04203({super.key});

  @override
  State<DomainExpertiseCardGen04203> createState() => _DomainExpertiseCardGen04203State();
}

class _DomainExpertiseCardGen04203State extends State<DomainExpertiseCardGen04203> {
  late DateTime _lastSynced;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _lastSynced = DateTime.now();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _lastSynced = DateTime.now();
      _isRefreshing = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Liveness handshake confirmed. Data synchronized.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Color _statusColor(BuildContext context, _StepStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case _StepStatus.pass:
        return colorScheme.primary;
      case _StepStatus.fail:
        return colorScheme.error;
      case _StepStatus.pending:
        return colorScheme.tertiary;
    }
  }

  String _statusLabel(_StepStatus status) {
    switch (status) {
      case _StepStatus.pass:
        return 'Pass';
      case _StepStatus.fail:
        return 'Fail';
      case _StepStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    final assignedCount = _Gen04203MockData.roles.where((r) => r.isAssigned).length;
    final totalCount = _Gen04203MockData.roles.length;
    final coveragePercent = (assignedCount / totalCount * 100).toStringAsFixed(0);

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _Gen04203MockData.stepName,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Atomic ID: ${_Gen04203MockData.atomicId}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Chip(
                  label: Text(
                    _statusLabel(_Gen04203MockData.overallStatus),
                    style: TextStyle(
                      color: _statusColor(context, _Gen04203MockData.overallStatus),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: _statusColor(context, _Gen04203MockData.overallStatus).withOpacity(0.12),
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified_user_outlined, size: 20, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'RACI Coverage: $coveragePercent%',
                      style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      '$assignedCount/$totalCount Assigned',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: assignedCount / totalCount,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    assignedCount == totalCount ? colorScheme.primary : colorScheme.tertiary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Role Assignments',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ..._Gen04203MockData.roles.map((role) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        role.isAssigned ? Icons.check_circle : Icons.radio_button_unchecked,
                        size: 18,
                        color: role.isAssigned ? colorScheme.primary : colorScheme.outline,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              role.role,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              role.assignee,
                              style: textTheme.bodySmall?.copyWith(
                                color: role.isAssigned
                                    ? colorScheme.onSurfaceVariant
                                    : colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
                const Divider(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildMetaItem(
                      context,
                      icon: Icons.sync,
                      label: 'Last Sync',
                      value: '${_lastSynced.hour.toString().padLeft(2, '0')}:${_lastSynced.minute.toString().padLeft(2, '0')}:${_lastSynced.second.toString().padLeft(2, '0')}',
                    ),
                    _buildMetaItem(
                      context,
                      icon: Icons.timer_outlined,
                      label: 'Polling',
                      value: '${_Gen04203MockData.pollingIntervalSeconds}s',
                    ),
                    _buildMetaItem(
                      context,
                      icon: Icons.book_outlined,
                      label: 'Standard',
                      value: 'PMBOK 7th',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.tonalIcon(
                    onPressed: _isRefreshing ? null : _handleRefresh,
                    icon: _isRefreshing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh, size: 20),
                    label: Text(_isRefreshing ? 'Syncing...' : 'Manual Sync'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        Text(
          value,
          style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
