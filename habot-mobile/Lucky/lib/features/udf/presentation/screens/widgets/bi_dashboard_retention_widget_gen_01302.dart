// GEN-01302 — BI Dashboard Retention & Engagement Widget.
// Displays platform retention rates and activity engagement trends using M3 Elevated Cards, status chips, pull-to-refresh, and 30-second background polling. Responsive single-column (<600dp) and multi-column (>=840dp).

import 'dart:async';
import 'package:flutter/material.dart';

class BiDashboardRetentionWidgetGen01302 extends StatefulWidget {
  const BiDashboardRetentionWidgetGen01302({super.key});

  @override
  State<BiDashboardRetentionWidgetGen01302> createState() => _BiDashboardRetentionWidgetGen01302State();
}

class _BiDashboardRetentionWidgetGen01302State extends State<BiDashboardRetentionWidgetGen01302> {
  Timer? _pollingTimer;
  bool _isRefreshing = false;
  late List<_MockMetricData> _metrics;

  @override
  void initState() {
    super.initState();
    _metrics = _generateMockMetrics();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshData(isManual: false);
    });
  }

  Future<void> _refreshData({required bool isManual}) async {
    if (!mounted || _isRefreshing) return;
    setState(() => _isRefreshing = true);

    await Future.delayed(const Duration(milliseconds: 80)); // Simulate sub-100ms latency

    if (!mounted) return;
    setState(() {
      _metrics = _generateMockMetrics();
      _isRefreshing = false;
    });

    if (isManual && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dashboard data synchronized successfully.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _evaluateHealth(int refreshMinutes) {
    if (refreshMinutes < 5) return 'Good';
    if (refreshMinutes < 60) return 'Average';
    return 'Poor';
  }

  Color _healthColor(String health, ThemeData theme) {
    switch (health) {
      case 'Good':
        return theme.colorScheme.primary;
      case 'Average':
        return theme.colorScheme.tertiary;
      case 'Poor':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => _refreshData(isManual: true),
      edgeOffset: 0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 840;
          final crossAxisCount = isDesktop ? 2 : 1;

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              childAspectRatio: isDesktop ? 2.5 : 2.0,
            ),
            itemCount: _metrics.length,
            itemBuilder: (context, index) {
              final metric = _metrics[index];
              final health = _evaluateHealth(metric.refreshLatencyMinutes);
              final healthColor = _healthColor(health, theme);

              return Card(
                elevation: 3.0, // M3 Elevated Card Level 2 (3dp)
                surfaceTintColor: theme.colorScheme.surfaceTint,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: InkWell(
                  onTap: () {
                    // Deep-link drill-down placeholder
                  },
                  borderRadius: BorderRadius.circular(12.0),
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
                            const SizedBox(width: 8.0),
                            Chip(
                              label: Text(
                                health,
                                style: TextStyle(
                                  color: healthColor,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: healthColor.withOpacity(0.1),
                              side: BorderSide.none,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          '${metric.value}%',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Refresh Latency: ${metric.refreshLatencyMinutes} min',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        LinearProgressIndicator(
                          value: metric.trendValue,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                          minHeight: 4.0,
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<_MockMetricData> _generateMockMetrics() {
    return [
      _MockMetricData(
        title: 'D1 Platform Retention Rate',
        value: 84.5,
        refreshLatencyMinutes: 3,
        trendValue: 0.84,
      ),
      _MockMetricData(
        title: 'D7 Platform Retention Rate',
        value: 62.1,
        refreshLatencyMinutes: 12,
        trendValue: 0.62,
      ),
      _MockMetricData(
        title: 'Activity Engagement Trend (Weekly)',
        value: 78.3,
        refreshLatencyMinutes: 45,
        trendValue: 0.78,
      ),
      _MockMetricData(
        title: 'Feature Adoption Rate',
        value: 41.9,
        refreshLatencyMinutes: 120,
        trendValue: 0.41,
      ),
    ];
  }
}

class _MockMetricData {
  final String title;
  final double value;
  final int refreshLatencyMinutes;
  final double trendValue;

  _MockMetricData({
    required this.title,
    required this.value,
    required this.refreshLatencyMinutes,
    required this.trendValue,
  });
}
