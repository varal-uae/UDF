// GEN-01346 — Master Executive Dashboard displaying commercial revenue, transaction volumes, and operational health metrics.
// Implements M3 Elevated Cards with status chips, responsive single/multi-column layout, 30s background polling, and pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum MetricStatus { good, average, poor }

class DashboardMetric {
  final String title;
  final String value;
  final MetricStatus status;
  final String refreshLatency;

  const DashboardMetric({
    required this.title,
    required this.value,
    required this.status,
    required this.refreshLatency,
  });
}

class MockDashboardRepository {
  static const List<DashboardMetric> mockMetrics = [
    DashboardMetric(
      title: 'Commercial Revenue Generation',
      value: 'AED 4,250,000',
      status: MetricStatus.good,
      refreshLatency: '< 2 minutes',
    ),
    DashboardMetric(
      title: 'Transaction Volumes',
      value: '128,450 / hr',
      status: MetricStatus.average,
      refreshLatency: '< 5 minutes',
    ),
    DashboardMetric(
      title: 'Operational Health',
      value: '99.98% Uptime',
      status: MetricStatus.good,
      refreshLatency: '< 1 minute',
    ),
    DashboardMetric(
      title: 'API Response Latency',
      value: '45ms (p99)',
      status: MetricStatus.good,
      refreshLatency: '< 1 minute',
    ),
    DashboardMetric(
      title: 'Data Pipeline Sync',
      value: 'Delayed',
      status: MetricStatus.poor,
      refreshLatency: '45 minutes',
    ),
  ];

  Future<List<DashboardMetric>> fetchMetrics() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockMetrics;
  }
}

class MasterExecutiveDashboardGen01346 extends StatefulWidget {
  const MasterExecutiveDashboardGen01346({super.key});

  @override
  State<MasterExecutiveDashboardGen01346> createState() => _MasterExecutiveDashboardGen01346State();
}

class _MasterExecutiveDashboardGen01346State extends State<MasterExecutiveDashboardGen01346> {
  final MockDashboardRepository _repository = MockDashboardRepository();
  late Future<List<DashboardMetric>> _metricsFuture;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
    _startPolling();
  }

  void _loadMetrics() {
    setState(() {
      _metricsFuture = _repository.fetchMetrics();
    });
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadMetrics();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _loadMetrics();
    await _metricsFuture;
  }

  Color _getStatusColor(MetricStatus status, ColorScheme colorScheme) {
    switch (status) {
      case MetricStatus.good:
        return colorScheme.primary;
      case MetricStatus.average:
        return colorScheme.tertiary;
      case MetricStatus.poor:
        return colorScheme.error;
    }
  }

  String _getStatusLabel(MetricStatus status) {
    switch (status) {
      case MetricStatus.good:
        return 'Good';
      case MetricStatus.average:
        return 'Average';
      case MetricStatus.poor:
        return 'Poor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Executive Dashboard'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<DashboardMetric>>(
        future: _metricsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading metrics: ${snapshot.error}'));
          }

          final metrics = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                final crossAxisCount = isMobile ? 1 : (constraints.maxWidth >= 840 ? 3 : 2);

                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: isMobile ? 2.5 : 2.0,
                  ),
                  itemCount: metrics.length,
                  itemBuilder: (context, index) {
                    final metric = metrics[index];
                    return _buildMetricCard(metric, colorScheme);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(DashboardMetric metric, ColorScheme colorScheme) {
    final statusColor = _getStatusColor(metric.status, colorScheme);
    final statusLabel = _getStatusLabel(metric.status);

    return Card(
      elevation: 3.0, // M3 Elevated Card Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Drilling down into ${metric.title}...'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      metric.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Chip(
                    label: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12.0,
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
              const SizedBox(height: 8.0),
              Text(
                metric.value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                'Refresh Latency: ${metric.refreshLatency}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}