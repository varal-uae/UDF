// GEN-02273 — Quiet Management Mode Status Card.
// Displays the execution status, Process Execution Accuracy metric, and completion state for the Quiet Management initialization step using M3 Elevated Cards and Status Chips.

import 'package:flutter/material.dart';

enum _StepStatus { pass, fail, pending }

class _QuietManagementMockData {
  final String atomicId;
  final String stepName;
  final String metricName;
  final double currentValue;
  final double floorBoundary;
  final double optimalTarget;
  final double ceilingBoundary;
  final _StepStatus status;
  final DateTime lastUpdated;

  const _QuietManagementMockData({
    required this.atomicId,
    required this.stepName,
    required this.metricName,
    required this.currentValue,
    required this.floorBoundary,
    required this.optimalTarget,
    required this.ceilingBoundary,
    required this.status,
    required this.lastUpdated,
  });
}

const _QuietManagementMockData kMockQuietManagementData = _QuietManagementMockData(
  atomicId: 'GEN-02273',
  stepName: 'Initiate "Quiet Management" mode across the organization.',
  metricName: 'Process Execution Accuracy',
  currentValue: 0.97,
  floorBoundary: 0.90,
  optimalTarget: 0.97,
  ceilingBoundary: 0.999,
  status: _StepStatus.pass,
  lastUpdated: DateTime(2026, 9, 24, 10, 30, 0),
);

class QuietManagementCardGen02273 extends StatefulWidget {
  const QuietManagementCardGen02273({super.key});

  @override
  State<QuietManagementCardGen02273> createState() => _QuietManagementCardGen02273State();
}

class _QuietManagementCardGen02273State extends State<QuietManagementCardGen02273> {
  late _QuietManagementMockData _data;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _data = kMockQuietManagementData;
    _startPolling();
  }

  void _startPolling() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _refreshData();
        _startPolling();
      }
    });
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _isRefreshing = false;
        _data = _QuietManagementMockData(
          atomicId: _data.atomicId,
          stepName: _data.stepName,
          metricName: _data.metricName,
          currentValue: _data.currentValue,
          floorBoundary: _data.floorBoundary,
          optimalTarget: _data.optimalTarget,
          ceilingBoundary: _data.ceilingBoundary,
          status: _data.currentValue >= _data.floorBoundary ? _StepStatus.pass : _StepStatus.fail,
          lastUpdated: DateTime.now(),
        );
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Quiet Management status synced successfully.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Color _getStatusColor(BuildContext context, _StepStatus status) {
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

  String _getStatusLabel(_StepStatus status) {
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
    final statusColor = _getStatusColor(context, _data.status);

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Engineering Console',
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _data.atomicId,
                              style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                          ),
                          Chip(
                            avatar: Icon(
                              _data.status == _StepStatus.pass ? Icons.check_circle : Icons.cancel,
                              size: 18,
                              color: statusColor,
                            ),
                            label: Text(
                              _getStatusLabel(_data.status),
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: statusColor.withOpacity(0.1),
                            side: BorderSide.none,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _data.stepName,
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      Text(
                        _data.metricName,
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: (_data.currentValue / _data.ceilingBoundary).clamp(0.0, 1.0),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Current: ${(_data.currentValue * 100).toStringAsFixed(1)}%',
                            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Floor: ${(_data.floorBoundary * 100).toStringAsFixed(0)}% | Target: ${(_data.optimalTarget * 100).toStringAsFixed(0)}%',
                            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            'Last updated: ${_data.lastUpdated.hour}:${_data.lastUpdated.minute.toString().padLeft(2, '0')}',
                            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                          const Spacer(),
                          if (_isRefreshing)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Semantics(
                button: true,
                label: 'View detailed drill-down for Quiet Management configuration',
                child: SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) => DraggableScrollableSheet(
                          initialChildSize: 0.5,
                          minChildSize: 0.25,
                          maxChildSize: 0.9,
                          expand: false,
                          builder: (context, scrollController) => Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    width: 40,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text('Configuration Details', style: textTheme.titleLarge),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: ListView(
                                    controller: scrollController,
                                    children: [
                                      _buildDetailRow('Standard', 'ISO/IEC 25010 Software Product Quality Standard'),
                                      _buildDetailRow('Dependency', 'GEN-02272'),
                                      _buildDetailRow('Shared Library', '@habot/shared-library'),
                                      _buildDetailRow('Estimated Time', '4 Hours'),
                                      _buildDetailRow('Completion Measures', '100% CI/CD pass rate. All validation checks passing.'),
                                      _buildDetailRow('Poka-Yoke', 'CI/CD pipeline physically blocks deployment if any gate fails.'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Deep-link Drill-down'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}