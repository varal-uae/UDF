// ONLSC-019-A11 — Orphan Nodes Monitor Dashboard Widget.
// Displays recruitment orphan node metrics with responsive two-column/single-column layouts, bold numeric values, and a filter drawer. Includes local mock data for step execution tracking.

import 'package:flutter/material.dart';

/// Mock data model representing an orphan node step execution record.
class StepExecutionRecord {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final bool isComplete;

  const StepExecutionRecord({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.isComplete,
  });
}

/// Local mock repository providing realistic dummy data for the dashboard.
class MockOrphanNodeRepository {
  static List<StepExecutionRecord> getRecords() {
    return [
      const StepExecutionRecord(
        stepExecutionId: 'SE-9914-001',
        executionStatus: 'Pending',
        executionTimestamp: null,
        stepOutcome: 'Orphaned recruiter assignment detected',
        userId: 'USR-8821',
        isComplete: false,
      ),
      const StepExecutionRecord(
        stepExecutionId: 'SE-9914-002',
        executionStatus: 'Resolved',
        executionTimestamp: null,
        stepOutcome: 'Recruiter action forced via dashboard',
        userId: 'USR-4432',
        isComplete: true,
      ),
      const StepExecutionRecord(
        stepExecutionId: 'SE-9914-003',
        executionStatus: 'Failed',
        executionTimestamp: null,
        stepOutcome: 'Timeout waiting for recruiter acknowledgment',
        userId: 'USR-1109',
        isComplete: false,
      ),
    ];
  }

  // Using actual dates to avoid null issues in const
  static List<StepExecutionRecord> fetchMockData() {
    final now = DateTime(2026, 9, 23);
    return [
      StepExecutionRecord(
        stepExecutionId: 'SE-9914-001',
        executionStatus: 'Pending',
        executionTimestamp: now.subtract(const Duration(hours: 2)),
        stepOutcome: 'Orphaned recruiter assignment detected',
        userId: 'USR-8821',
        isComplete: false,
      ),
      StepExecutionRecord(
        stepExecutionId: 'SE-9914-002',
        executionStatus: 'Resolved',
        executionTimestamp: now.subtract(const Duration(hours: 5)),
        stepOutcome: 'Recruiter action forced via dashboard',
        userId: 'USR-4432',
        isComplete: true,
      ),
      StepExecutionRecord(
        stepExecutionId: 'SE-9914-003',
        executionStatus: 'Failed',
        executionTimestamp: now.subtract(const Duration(days: 1)),
        stepOutcome: 'Timeout waiting for recruiter acknowledgment',
        userId: 'USR-1109',
        isComplete: false,
      ),
    ];
  }
}

/// Standardized touch target utility ensuring minimum 48x48 bounds per WCAG 2.1 AA.
class TouchTargetWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const TouchTargetWrapper({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 48.0,
          minHeight: 48.0,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.0),
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// Main dashboard widget for monitoring orphan nodes in recruitment data.
class OrphanNodesMonitorWidget extends StatefulWidget {
  const OrphanNodesMonitorWidget({super.key});

  @override
  State<OrphanNodesMonitorWidget> createState() => _OrphanNodesMonitorWidgetState();
}

class _OrphanNodesMonitorWidgetState extends State<OrphanNodesMonitorWidget> {
  late List<StepExecutionRecord> _records;
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _records = MockOrphanNodeRepository.fetchMockData();
  }

  List<StepExecutionRecord> get _filteredRecords {
    if (_filterStatus == 'All') return _records;
    return _records.where((r) => r.executionStatus == _filterStatus).toList();
  }

  double get _completenessPercentage {
    if (_records.isEmpty) return 0.0;
    final completed = _records.where((r) => r.isComplete).length;
    return (completed / _records.length) * 100.0;
  }

  void _openFilterDrawer() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Data',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ...['All', 'Pending', 'Resolved', 'Failed'].map((status) {
                  return ListTile(
                    title: Text(status),
                    selected: _filterStatus == status,
                    onTap: () {
                      setState(() => _filterStatus = status);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.sizeOf(context).width >= 840;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orphan Nodes Monitor'),
        actions: [
          TouchTargetWrapper(
            onTap: _openFilterDrawer,
            child: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metrics Grid: 4-column on desktop, single vertical stack on mobile
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 840 ? 4 : 1;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: crossAxisCount == 1 ? 4.0 : 1.5,
                  children: [
                    _buildMetricCard(
                      context,
                      title: 'Total Events',
                      value: '${_records.length}',
                      icon: Icons.analytics_outlined,
                    ),
                    _buildMetricCard(
                      context,
                      title: 'Traceability',
                      value: '${_completenessPercentage.toStringAsFixed(1)}%',
                      icon: Icons.track_changes,
                    ),
                    _buildMetricCard(
                      context,
                      title: 'Pending Actions',
                      value: '${_records.where((r) => !r.isComplete).length}',
                      icon: Icons.pending_actions,
                    ),
                    _buildMetricCard(
                      context,
                      title: 'Optimal Target',
                      value: '100%',
                      icon: Icons.check_circle_outline,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Execution Logs',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // Two column scaling layout for logs on larger screens
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredRecords.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final record = _filteredRecords[index];
                  return _buildLogTile(context, record, isDesktop);
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
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Numeric data values use prominent bold font weights
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogTile(
    BuildContext context,
    StepExecutionRecord record,
    bool isDesktop,
  ) {
    final theme = Theme.of(context);
    final timeStr = record.executionTimestamp != null
        ? '${record.executionTimestamp!.hour}:${record.executionTimestamp!.minute.toString().padLeft(2, '0')}'
        : 'N/A';

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: isDesktop
          ? Row(
              children: [
                Expanded(flex: 2, child: Text(record.stepExecutionId, style: const TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text(record.userId)),
                Expanded(flex: 2, child: _buildStatusChip(record.executionStatus)),
                Expanded(flex: 3, child: Text(record.stepOutcome)),
                Expanded(flex: 1, child: Text(timeStr, textAlign: TextAlign.end)),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      record.stepExecutionId,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(timeStr, style: theme.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 4),
                Text(record.userId, style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                _buildStatusChip(record.executionStatus),
                const SizedBox(height: 8),
                Text(record.stepOutcome, style: theme.textTheme.bodyMedium),
              ],
            ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    switch (status) {
      case 'Resolved':
        bgColor = Colors.green.shade100;
        break;
      case 'Pending':
        bgColor = Colors.orange.shade100;
        break;
      case 'Failed':
        bgColor = Colors.red.shade100;
        break;
      default:
        bgColor = Colors.grey.shade200;
    }
    return Chip(
      label: Text(status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      backgroundColor: bgColor,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}