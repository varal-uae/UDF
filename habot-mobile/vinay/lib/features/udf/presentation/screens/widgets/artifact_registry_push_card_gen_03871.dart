// GEN-03871 — Artifact Registry Push Status Card.
// Displays the completion state and latency metrics for pushing a built image to Google Artifact Registry using M3 Elevated Cards and Status Chips.

import 'package:flutter/material.dart';

enum _StepStatus { complete, notComplete, inProgress }

class _ArtifactPushMockData {
  final String stepName;
  final String metricName;
  final double currentLatencySeconds;
  final double floorBoundary;
  final double optimalTarget;
  final double ceilingBoundary;
  final _StepStatus status;
  final DateTime lastUpdated;

  const _ArtifactPushMockData({
    required this.stepName,
    required this.metricName,
    required this.currentLatencySeconds,
    required this.floorBoundary,
    required this.optimalTarget,
    required this.ceilingBoundary,
    required this.status,
    required this.lastUpdated,
  });
}

const _ArtifactPushMockData _mockData = _ArtifactPushMockData(
  stepName: 'Push the built image to Google Artifact Registry',
  metricName: 'Artifact Registry Push Latency',
  currentLatencySeconds: 8.4,
  floorBoundary: 30.0,
  optimalTarget: 10.0,
  ceilingBoundary: 60.0,
  status: _StepStatus.complete,
  lastUpdated: DateTime(2026, 9, 28, 14, 30, 0),
);

class ArtifactRegistryPushCardGen03871 extends StatefulWidget {
  const ArtifactRegistryPushCardGen03871({super.key});

  @override
  State<ArtifactRegistryPushCardGen03871> createState() => _ArtifactRegistryPushCardGen03871State();
}

class _ArtifactRegistryPushCardGen03871State extends State<ArtifactRegistryPushCardGen03871> {
  late _ArtifactPushMockData _data;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _data = _mockData;
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
        _data = _ArtifactPushMockData(
          stepName: _data.stepName,
          metricName: _data.metricName,
          currentLatencySeconds: 7.2,
          floorBoundary: _data.floorBoundary,
          optimalTarget: _data.optimalTarget,
          ceilingBoundary: _data.ceilingBoundary,
          status: _StepStatus.complete,
          lastUpdated: DateTime.now(),
        );
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Data synced successfully.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Color _getStatusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (_data.status) {
      case _StepStatus.complete:
        return _data.currentLatencySeconds <= _data.optimalTarget
            ? colorScheme.primary
            : colorScheme.tertiary;
      case _StepStatus.inProgress:
        return colorScheme.secondary;
      case _StepStatus.notComplete:
        return colorScheme.error;
    }
  }

  String _getStatusLabel() {
    switch (_data.status) {
      case _StepStatus.complete:
        return 'Complete';
      case _StepStatus.inProgress:
        return 'In Progress';
      case _StepStatus.notComplete:
        return 'Not Complete';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Engineering Console',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _data.stepName,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Semantics(
                            label: 'Status: ${_getStatusLabel()}',
                            child: Chip(
                              avatar: Icon(
                                _data.status == _StepStatus.complete
                                    ? Icons.check_circle_outline
                                    : _data.status == _StepStatus.inProgress
                                        ? Icons.sync
                                        : Icons.error_outline,
                                size: 18,
                                color: _getStatusColor(context),
                              ),
                              label: Text(
                                _getStatusLabel(),
                                style: textTheme.labelLarge?.copyWith(
                                  color: _getStatusColor(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: _getStatusColor(context).withValues(alpha: 0.12),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _data.metricName,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${_data.currentLatencySeconds.toStringAsFixed(1)}s',
                            style: textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(context),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildMetricRow(
                                  context,
                                  'Optimal Target',
                                  '< ${_data.optimalTarget.toStringAsFixed(0)}s',
                                ),
                                const SizedBox(height: 4),
                                _buildMetricRow(
                                  context,
                                  'Floor Boundary',
                                  '< ${_data.floorBoundary.toStringAsFixed(0)}s',
                                ),
                                const SizedBox(height: 4),
                                _buildMetricRow(
                                  context,
                                  'Ceiling Boundary',
                                  '${_data.ceilingBoundary.toStringAsFixed(0)}s',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Last updated: ${_formatDateTime(_data.lastUpdated)}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          if (_isRefreshing)
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary,
                              ),
                            )
                          else
                            IconButton(
                              onPressed: _refreshData,
                              icon: Icon(
                                Icons.refresh,
                                color: colorScheme.primary,
                              ),
                              iconSize: 24,
                              constraints: const BoxConstraints(
                                minWidth: 48,
                                minHeight: 48,
                              ),
                              tooltip: 'Refresh data',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} $h:$m:$s';
  }
}