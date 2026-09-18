// GEN-01401 — Family Structure Metrics Dashboard Card.
// Displays aggregated family structure metrics on marketplace demographic dashboards using M3 Elevated Cards with status chips, 30-second background polling, and pull-to-refresh support.

import 'dart:async';

import 'package:flutter/material.dart';

enum MetricHealth { good, average, poor }

class FamilyStructureMetric {
  final String id;
  final String label;
  final int count;
  final double percentage;
  final MetricHealth health;
  final DateTime lastUpdated;

  const FamilyStructureMetric({
    required this.id,
    required this.label,
    required this.count,
    required this.percentage,
    required this.health,
    required this.lastUpdated,
  });
}

class MockFamilyMetricsRepository {
  static List<FamilyStructureMetric> fetchMetrics() {
    final now = DateTime.now();
    return [
      FamilyStructureMetric(
        id: 'trace_fs_001',
        label: 'Nuclear Family (2 Adults + Children)',
        count: 14520,
        percentage: 42.5,
        health: MetricHealth.good,
        lastUpdated: now.subtract(const Duration(minutes: 2)),
      ),
      FamilyStructureMetric(
        id: 'trace_fs_002',
        label: 'Extended Family (Multi-generational)',
        count: 8340,
        percentage: 24.4,
        health: MetricHealth.average,
        lastUpdated: now.subtract(const Duration(minutes: 15)),
      ),
      FamilyStructureMetric(
        id: 'trace_fs_003',
        label: 'Single Parent Household',
        count: 5120,
        percentage: 15.0,
        health: MetricHealth.good,
        lastUpdated: now.subtract(const Duration(minutes: 1)),
      ),
      FamilyStructureMetric(
        id: 'trace_fs_004',
        label: 'Couple Without Children',
        count: 4200,
        percentage: 12.3,
        health: MetricHealth.poor,
        lastUpdated: now.subtract(const Duration(hours: 2)),
      ),
      FamilyStructureMetric(
        id: 'trace_fs_005',
        label: 'Single Person Household',
        count: 1980,
        percentage: 5.8,
        health: MetricHealth.average,
        lastUpdated: now.subtract(const Duration(minutes: 45)),
      ),
    ];
  }
}

class FamilyStructureMetricsCardGen01401 extends StatefulWidget {
  const FamilyStructureMetricsCardGen01401({super.key});

  @override
  State<FamilyStructureMetricsCardGen01401> createState() => _FamilyStructureMetricsCardGen01401State();
}

class _FamilyStructureMetricsCardGen01401State extends State<FamilyStructureMetricsCardGen01401> {
  late List<FamilyStructureMetric> _metrics;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _metrics = MockFamilyMetricsRepository.fetchMetrics();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshData(showIndicator: false);
    });
  }

  Future<void> _refreshData({bool showIndicator = true}) async {
    if (!mounted) return;
    if (showIndicator) setState(() => _isRefreshing = true);

    await Future.delayed(const Duration(milliseconds: 80)); // Simulate <100ms API latency

    if (!mounted) return;
    setState(() {
      _metrics = MockFamilyMetricsRepository.fetchMetrics();
      _isRefreshing = false;
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Color _getHealthColor(MetricHealth health, ColorScheme colorScheme) {
    switch (health) {
      case MetricHealth.good:
        return colorScheme.primary;
      case MetricHealth.average:
        return colorScheme.tertiary;
      case MetricHealth.poor:
        return colorScheme.error;
    }
  }

  String _getHealthLabel(MetricHealth health) {
    switch (health) {
      case MetricHealth.good:
        return 'Good';
      case MetricHealth.average:
        return 'Average';
      case MetricHealth.poor:
        return 'Poor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = MediaQuery.sizeOf(context).width >= 840;

    return RefreshIndicator(
      onRefresh: () => _refreshData(showIndicator: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Marketplace Demographics: Family Structure',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Dashboard Data Refresh Latency Target: <1 hour | Optimal: <5 minutes',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                if (_isRefreshing)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: LinearProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 3 : 1,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                    childAspectRatio: isDesktop ? 2.5 : 3.0,
                  ),
                  itemCount: _metrics.length,
                  itemBuilder: (context, index) {
                    final metric = _metrics[index];
                    return _buildMetricCard(metric, theme, colorScheme);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(
    FamilyStructureMetric metric,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final healthColor = _getHealthColor(metric.health, colorScheme);

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () => _showConfigurationSheet(metric, theme),
        borderRadius: BorderRadius.circular(12.0),
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
                      metric.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      _getHealthLabel(metric.health),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: healthColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: healthColor.withOpacity(0.12),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${metric.count.toLocaleString()}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      '${metric.percentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Trace ID: ${metric.id} • Updated: ${_formatTime(metric.lastUpdated)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfigurationSheet(FamilyStructureMetric metric, ThemeData theme) {
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
                'Metric Drill-Down',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Category'),
                subtitle: Text(metric.label),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Total Count'),
                subtitle: Text(metric.count.toLocaleString()),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Health Status'),
                subtitle: Text(_getHealthLabel(metric.health)),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Last Refresh'),
                subtitle: Text(_formatTime(metric.lastUpdated)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48, // 48x48dp touch targets
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Deep-link drill-down triggered for ${metric.id}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Open Detailed Analytics'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

extension on int {
  String toLocaleString() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}