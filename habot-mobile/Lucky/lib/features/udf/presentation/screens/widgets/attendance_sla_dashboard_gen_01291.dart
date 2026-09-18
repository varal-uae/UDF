// GEN-01291 — Attendance Notification Delivery Speeds & Safety SLA Metrics Dashboard.
// Displays read-only M3 Elevated Cards with status chips for dashboard data refresh latency metrics. Single-column on mobile (<600dp), multi-column on desktop (>=840dp). Background polling every 30 seconds with pull-to-refresh support.

import 'dart:async';
import 'package:flutter/material.dart';

enum SlaStatus { good, average, poor }

class SlaMetricModel {
  final String id;
  final String title;
  final String description;
  final Duration currentLatency;
  final SlaStatus status;
  final DateTime lastUpdated;
  final String traceId;

  const SlaMetricModel({
    required this.id,
    required this.title,
    required this.description,
    required this.currentLatency,
    required this.status,
    required this.lastUpdated,
    required this.traceId,
  });
}

class MockSlaRepository {
  static List<SlaMetricModel> fetchMetrics() {
    final now = DateTime.now();
    return [
      SlaMetricModel(
        id: 'metric_001',
        title: 'Attendance Notification Delivery Speed',
        description: 'End-to-end latency for attendance push notifications to mobile clients.',
        currentLatency: const Duration(minutes: 3, seconds: 12),
        status: SlaStatus.good,
        lastUpdated: now.subtract(const Duration(seconds: 15)),
        traceId: 'trace_a1b2c3d4',
      ),
      SlaMetricModel(
        id: 'metric_002',
        title: 'Safety SLA Compliance Rate',
        description: 'Percentage of safety alerts delivered within the <5 minute optimal target.',
        currentLatency: const Duration(minutes: 7, seconds: 45),
        status: SlaStatus.average,
        lastUpdated: now.subtract(const Duration(seconds: 22)),
        traceId: 'trace_e5f6g7h8',
      ),
      SlaMetricModel(
        id: 'metric_003',
        title: 'Dashboard Data Refresh Latency',
        description: 'Time taken for BigQuery partitioned event_date streams to reflect on engineering console.',
        currentLatency: const Duration(hours: 1, minutes: 15),
        status: SlaStatus.poor,
        lastUpdated: now.subtract(const Duration(minutes: 2)),
        traceId: 'trace_i9j0k1l2',
      ),
      SlaMetricModel(
        id: 'metric_004',
        title: 'API Response Latency (Mobile)',
        description: 'P95 response time for mobile client API calls against sub-100ms SLA target.',
        currentLatency: const Duration(milliseconds: 85),
        status: SlaStatus.good,
        lastUpdated: now.subtract(const Duration(seconds: 5)),
        traceId: 'trace_m3n4o5p6',
      ),
    ];
  }
}

class AttendanceSlaDashboardGen01291 extends StatefulWidget {
  const AttendanceSlaDashboardGen01291({super.key});

  @override
  State<AttendanceSlaDashboardGen01291> createState() => _AttendanceSlaDashboardGen01291State();
}

class _AttendanceSlaDashboardGen01291State extends State<AttendanceSlaDashboardGen01291> {
  List<SlaMetricModel> _metrics = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
    // Background polling refreshes data every 30 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadMetrics();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMetrics() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (!mounted) return;
    setState(() {
      _metrics = MockSlaRepository.fetchMetrics();
      _isLoading = false;
    });
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    } else if (d.inMinutes > 0) {
      return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
    } else if (d.inSeconds > 0) {
      return '${d.inSeconds}s';
    } else {
      return '${d.inMilliseconds}ms';
    }
  }

  Color _getStatusColor(SlaStatus status, ThemeData theme) {
    switch (status) {
      case SlaStatus.good:
        return theme.colorScheme.primary;
      case SlaStatus.average:
        return theme.colorScheme.tertiary;
      case SlaStatus.poor:
        return theme.colorScheme.error;
    }
  }

  String _getStatusLabel(SlaStatus status) {
    switch (status) {
      case SlaStatus.good:
        return 'Good';
      case SlaStatus.average:
        return 'Average';
      case SlaStatus.poor:
        return 'Poor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp)
    final isDesktop = screenWidth >= 840;
    final crossAxisCount = isDesktop ? 2 : 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Dashboards'),
        centerTitle: false,
        elevation: 0,
      ),
      body: _isLoading && _metrics.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              // Pull-to-refresh triggers manual sync
              onRefresh: _loadMetrics,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16.0,
                        crossAxisSpacing: 16.0,
                        childAspectRatio: isDesktop ? 2.5 : 1.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final metric = _metrics[index];
                          return _buildMetricCard(metric, theme);
                        },
                        childCount: _metrics.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMetricCard(SlaMetricModel metric, ThemeData theme) {
    final statusColor = _getStatusColor(metric.status, theme);

    // M3 Elevated Cards Level 2 (3dp)
    return Card(
      elevation: 3.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: () {
          // Deep-link drill-down placeholder
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Drilling down into trace: ${metric.traceId}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
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
                      metric.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // M3 Status Chips for health indicators
                  Chip(
                    label: Text(
                      _getStatusLabel(metric.status),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: statusColor.withOpacity(0.12),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                metric.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Latency',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDuration(metric.currentLatency),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Last Updated',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        TimeOfDay.fromDateTime(metric.lastUpdated).format(context),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
