// GEN-01644 — Experiment Conversion Dashboard Widget.
// Displays real-time experiment conversion deltas and confidence intervals on growth BI dashboards using M3 Elevated Cards, status chips, and responsive layout.

import 'dart:async';
import 'package:flutter/material.dart';

enum HealthStatus { good, average, poor }

class ExperimentMetric {
  final String id;
  final String name;
  final double conversionDelta;
  final double confidenceLower;
  final double confidenceUpper;
  final HealthStatus health;
  final DateTime lastUpdated;

  const ExperimentMetric({
    required this.id,
    required this.name,
    required this.conversionDelta,
    required this.confidenceLower,
    required this.confidenceUpper,
    required this.health,
    required this.lastUpdated,
  });
}

class MockExperimentRepository {
  static List<ExperimentMetric> fetchMetrics() {
    return [
      ExperimentMetric(
        id: 'exp_001',
        name: 'Checkout Flow Optimization',
        conversionDelta: 0.042,
        confidenceLower: 0.015,
        confidenceUpper: 0.069,
        health: HealthStatus.good,
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      ExperimentMetric(
        id: 'exp_002',
        name: 'Onboarding V2 A/B Test',
        conversionDelta: -0.011,
        confidenceLower: -0.035,
        confidenceUpper: 0.013,
        health: HealthStatus.poor,
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ExperimentMetric(
        id: 'exp_003',
        name: 'Pricing Page Redesign',
        conversionDelta: 0.008,
        confidenceLower: -0.002,
        confidenceUpper: 0.018,
        health: HealthStatus.average,
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ];
  }
}

class ExperimentConversionDashboardGen01644 extends StatefulWidget {
  const ExperimentConversionDashboardGen01644({super.key});

  @override
  State<ExperimentConversionDashboardGen01644> createState() => _ExperimentConversionDashboardGen01644State();
}

class _ExperimentConversionDashboardGen01644State extends State<ExperimentConversionDashboardGen01644> {
  late List<ExperimentMetric> _metrics;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _metrics = MockExperimentRepository.fetchMetrics();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    
    await Future.delayed(const Duration(milliseconds: 600));
    
    if (mounted) {
      setState(() {
        _metrics = MockExperimentRepository.fetchMetrics();
        _isRefreshing = false;
      });
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Color _getHealthColor(HealthStatus status, ColorScheme colorScheme) {
    switch (status) {
      case HealthStatus.good:
        return colorScheme.primary;
      case HealthStatus.average:
        return colorScheme.tertiary;
      case HealthStatus.poor:
        return colorScheme.error;
    }
  }

  String _getHealthLabel(HealthStatus status) {
    switch (status) {
      case HealthStatus.good:
        return 'Good';
      case HealthStatus.average:
        return 'Average';
      case HealthStatus.poor:
        return 'Poor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Growth BI Dashboard'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            onPressed: _isRefreshing ? null : _refreshData,
            tooltip: 'Manual Sync',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final crossAxisCount = isMobile ? 1 : (constraints.maxWidth >= 840 ? 2 : 1);

            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: isMobile ? 2.2 : 2.5,
              ),
              itemCount: _metrics.length,
              itemBuilder: (context, index) {
                final metric = _metrics[index];
                return _buildMetricCard(metric, theme, colorScheme);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricCard(ExperimentMetric metric, ThemeData theme, ColorScheme colorScheme) {
    final healthColor = _getHealthColor(metric.health, colorScheme);
    final deltaPercent = (metric.conversionDelta * 100).toStringAsFixed(2);
    final isPositive = metric.conversionDelta >= 0;

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deep-link drill-down for ${metric.name}'),
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
                      metric.name,
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
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isPositive ? '+' : ''}$deltaPercent%',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: isPositive ? colorScheme.primary : colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      'Conv. Delta',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.analytics_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      'CI: [${(metric.confidenceLower * 100).toStringAsFixed(2)}%, ${(metric.confidenceUpper * 100).toStringAsFixed(2)}%]',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'Updated ${TimeOfDay.fromDateTime(metric.lastUpdated).format(context)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}