// GEN-04047 — Dashboard Metric Extraction Card Widget.
// Extracts and displays every data field and metric across dashboard cards using M3 Elevated Cards, Status Chips, and responsive single/multi-column layouts.

import 'package:flutter/material.dart';

enum _MetricStatus { complete, notComplete }

class _DashboardMetric {
  final String id;
  final String name;
  final String value;
  final double extractionRate;
  final _MetricStatus status;
  final DateTime timestamp;

  const _DashboardMetric({
    required this.id,
    required this.name,
    required this.value,
    required this.extractionRate,
    required this.status,
    required this.timestamp,
  });
}

const List<_DashboardMetric> _kMockMetrics = [
  _DashboardMetric(
    id: 'MET-001',
    name: 'Active Users',
    value: '12,450',
    extractionRate: 1.0,
    status: _MetricStatus.complete,
    timestamp: _kMockTimestamp,
  ),
  _DashboardMetric(
    id: 'MET-002',
    name: 'Revenue (USD)',
    value: '\$84,320.00',
    extractionRate: 1.0,
    status: _MetricStatus.complete,
    timestamp: _kMockTimestamp,
  ),
  _DashboardMetric(
    id: 'MET-003',
    name: 'Error Rate',
    value: '0.02%',
    extractionRate: 1.0,
    status: _MetricStatus.complete,
    timestamp: _kMockTimestamp,
  ),
  _DashboardMetric(
    id: 'MET-004',
    name: 'API Latency (p99)',
    value: '84ms',
    extractionRate: 1.0,
    status: _MetricStatus.notComplete,
    timestamp: _kMockTimestamp,
  ),
  _DashboardMetric(
    id: 'MET-005',
    name: 'Step Completion State',
    value: '98.5%',
    extractionRate: 1.0,
    status: _MetricStatus.complete,
    timestamp: _kMockTimestamp,
  ),
];

const DateTime _kMockTimestamp = DateTime(2026, 9, 28, 14, 30);

class DashboardMetricExtractionGen04047 extends StatefulWidget {
  const DashboardMetricExtractionGen04047({super.key});

  @override
  State<DashboardMetricExtractionGen04047> createState() =>
      _DashboardMetricExtractionGen04047State();
}

class _DashboardMetricExtractionGen04047State
    extends State<DashboardMetricExtractionGen04047> {
  late List<_DashboardMetric> _metrics;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _metrics = List.of(_kMockMetrics);
    _startBackgroundPolling();
  }

  void _startBackgroundPolling() {
    Future.delayed(const Duration(seconds: 30), () {
      if (!mounted) return;
      _refreshData();
      _startBackgroundPolling();
    });
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    setState(() {
      _metrics = List.of(_kMockMetrics);
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineering Console'),
        centerTitle: false,
        actions: [
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final crossAxisCount = isMobile ? 1 : (constraints.maxWidth >= 840 ? 3 : 2);

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: isMobile ? 2.4 : 1.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final metric = _metrics[index];
                        return _MetricElevatedCard(
                          metric: metric,
                          colorScheme: colorScheme,
                          onTap: () => _showBottomSheet(context, metric),
                        );
                      },
                      childCount: _metrics.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, _DashboardMetric metric) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metric.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Value'),
                subtitle: Text(metric.value),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                title: const Text('Metric Extraction Rate'),
                subtitle: Text('${metric.extractionRate}'),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                title: const Text('Status'),
                subtitle: Text(
                  metric.status == _MetricStatus.complete
                      ? 'Complete'
                      : 'Not Complete',
                ),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                title: const Text('Timestamp'),
                subtitle: Text(metric.timestamp.toIso8601String()),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Drill-down initiated for ${metric.id}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Deep-link Drill-down'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _MetricElevatedCard extends StatelessWidget {
  final _DashboardMetric metric;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _MetricElevatedCard({
    required this.metric,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = metric.status == _MetricStatus.complete;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: SizedBox(
        height: 48,
        child: Card(
          elevation: 3.0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
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
                        metric.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        isComplete ? 'Complete' : 'Not Complete',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isComplete
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onErrorContainer,
                            ),
                      ),
                      backgroundColor: isComplete
                          ? colorScheme.primaryContainer
                          : colorScheme.errorContainer,
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      metric.value,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                    ),
                    Text(
                      'Rate: ${metric.extractionRate}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}