// GEN-01214 — Add-On Revenue Expansion Metrics & AOV Growth Card.
// Renders add-on revenue expansion metrics and Average Order Value (AOV) growth on commercial dashboards using M3 Elevated Cards with responsive layout and background polling.

import 'dart:async';
import 'package:flutter/material.dart';

enum MetricStatus { good, average, poor }

class MockAovMetric {
  final String label;
  final double value;
  final MetricStatus status;
  final double attachRate;

  const MockAovMetric({
    required this.label,
    required this.value,
    required this.status,
    required this.attachRate,
  });
}

class MockAddonRevenueRepository {
  static const List<MockAovMetric> _mockData = [
    MockAovMetric(
      label: 'Average Order Value (AOV)',
      value: 145.50,
      status: MetricStatus.good,
      attachRate: 0.32,
    ),
    MockAovMetric(
      label: 'Add-On Attach Rate',
      value: 0.28,
      status: MetricStatus.average,
      attachRate: 0.28,
    ),
    MockAovMetric(
      label: 'Cross-Sell Revenue',
      value: 12400.00,
      status: MetricStatus.poor,
      attachRate: 0.08,
    ),
  ];

  Future<List<MockAovMetric>> fetchMetrics() async {
    await Future.delayed(const Duration(milliseconds: 80)); // Sub-100ms simulation
    return _mockData;
  }
}

class AddonRevenueMetricsCardGen01214 extends StatefulWidget {
  const AddonRevenueMetricsCardGen01214({super.key});

  @override
  State<AddonRevenueMetricsCardGen01214> createState() => _AddonRevenueMetricsCardGen01214State();
}

class _AddonRevenueMetricsCardGen01214State extends State<AddonRevenueMetricsCardGen01214> {
  final MockAddonRevenueRepository _repository = MockAddonRevenueRepository();
  List<MockAovMetric> _metrics = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMetrics() async {
    try {
      final data = await _repository.fetchMetrics();
      if (mounted) {
        setState(() {
          _metrics = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadMetrics();
    });
  }

  String _formatValue(MockAovMetric metric) {
    if (metric.label.contains('Rate')) {
      return '${(metric.value * 100).toStringAsFixed(1)}%';
    }
    return '\$${metric.value.toStringAsFixed(2)}';
  }

  Color _getStatusColor(MetricStatus status, ThemeData theme) {
    switch (status) {
      case MetricStatus.good:
        return theme.colorScheme.primary;
      case MetricStatus.average:
        return theme.colorScheme.tertiary;
      case MetricStatus.poor:
        return theme.colorScheme.error;
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
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 840;
    final crossAxisCount = isDesktop ? 3 : 1;

    return RefreshIndicator(
      onRefresh: _loadMetrics,
      child: _isLoading && _metrics.isEmpty
          ? SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: isDesktop ? 2.5 : 2.0,
              ),
              itemCount: _metrics.length,
              itemBuilder: (context, index) {
                final metric = _metrics[index];
                return _buildMetricCard(metric, theme);
              },
            ),
    );
  }

  Widget _buildMetricCard(MockAovMetric metric, ThemeData theme) {
    final statusColor = _getStatusColor(metric.status, theme);
    final statusLabel = _getStatusLabel(metric.status);
    final floorThreshold = 0.1;
    final isBelowFloor = metric.attachRate < floorThreshold;

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Deep-link drill-down placeholder
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Drill-down for ${metric.label}'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
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
                      metric.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      statusLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Text(
                _formatValue(metric),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8.0),
              if (metric.label == 'Add-On Attach Rate') ...[
                Row(
                  children: [
                    Icon(
                      isBelowFloor ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                      size: 16.0,
                      color: isBelowFloor ? theme.colorScheme.error : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      isBelowFloor
                          ? 'Below floor threshold ($floorThreshold)'
                          : 'Above floor threshold ($floorThreshold)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isBelowFloor ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
