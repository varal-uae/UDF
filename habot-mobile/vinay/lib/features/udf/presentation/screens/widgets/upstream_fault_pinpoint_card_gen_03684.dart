// GEN-03684 — Upstream Fault Pinpoint Status Card.
// M3 Elevated Card displaying upstream database node traversal status, completion state, and diagnostic metrics with 30s background polling and pull-to-refresh support.

import 'dart:async';
import 'package:flutter/material.dart';

enum _StepStatus { pass, fail, pending }

class _MockDiagnosticData {
  final String nodeId;
  final String componentName;
  final _StepStatus status;
  final DateTime timestamp;
  final double accuracy;

  const _MockDiagnosticData({
    required this.nodeId,
    required this.componentName,
    required this.status,
    required this.timestamp,
    required this.accuracy,
  });
}

final List<_MockDiagnosticData> _mockUpstreamNodes = [
  _MockDiagnosticData(
    nodeId: 'NODE-001',
    componentName: 'Byt Ingestion Service',
    status: _StepStatus.pass,
    timestamp: DateTime(2026, 9, 28, 10, 15),
    accuracy: 1.0,
  ),
  _MockDiagnosticData(
    nodeId: 'NODE-002',
    componentName: 'Lineage Diagnostic Engine',
    status: _StepStatus.fail,
    timestamp: DateTime(2026, 9, 28, 10, 16),
    accuracy: 0.0,
  ),
  _MockDiagnosticData(
    nodeId: 'NODE-003',
    componentName: 'GCP BigQuery Partitioner',
    status: _StepStatus.pending,
    timestamp: DateTime(2026, 9, 28, 10, 17),
    accuracy: 1.0,
  ),
];

class UpstreamFaultPinpointCardGen03684 extends StatefulWidget {
  const UpstreamFaultPinpointCardGen03684({super.key});

  @override
  State<UpstreamFaultPinpointCardGen03684> createState() => _UpstreamFaultPinpointCardGen03684State();
}

class _UpstreamFaultPinpointCardGen03684State extends State<UpstreamFaultPinpointCardGen03684> {
  Timer? _pollingTimer;
  bool _isPolling = true;
  List<_MockDiagnosticData> _currentData = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isPolling) {
        _fetchData();
      }
    });
  }

  Future<void> _fetchData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _currentData = List.from(_mockUpstreamNodes);
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _isPolling = false);
    await _fetchData();
    setState(() => _isPolling = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Manual sync completed successfully.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Color _getStatusColor(_StepStatus status, ThemeData theme) {
    switch (status) {
      case _StepStatus.pass:
        return theme.colorScheme.primary;
      case _StepStatus.fail:
        return theme.colorScheme.error;
      case _StepStatus.pending:
        return theme.colorScheme.tertiary;
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
    final isDesktop = MediaQuery.sizeOf(context).width >= 840;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: theme.colorScheme.primary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = isDesktop ? 2 : 1;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: isDesktop ? 2.5 : 2.0,
            ),
            itemCount: _currentData.length,
            itemBuilder: (context, index) {
              final node = _currentData[index];
              return _buildNodeCard(theme, node);
            },
          );
        },
      ),
    );
  }

  Widget _buildNodeCard(ThemeData theme, _MockDiagnosticData node) {
    final statusColor = _getStatusColor(node.status, theme);

    return Card(
      elevation: 3,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showConfigBottomSheet(theme, node),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      node.componentName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      _getStatusLabel(node.status),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: statusColor.withOpacity(0.12),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'Node ID: ${node.nodeId}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Accuracy: ${(node.accuracy * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    '${node.timestamp.hour}:${node.timestamp.minute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfigBottomSheet(ThemeData theme, _MockDiagnosticData node) {
    showModalBottomSheet(
      context: context,
      useMaterial3: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Node Configuration',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Component'),
                  subtitle: Text(node.componentName),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Current Status'),
                  subtitle: Text(_getStatusLabel(node.status)),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Pinpoint Accuracy'),
                  subtitle: Text('${(node.accuracy * 100).toStringAsFixed(0)}%'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
