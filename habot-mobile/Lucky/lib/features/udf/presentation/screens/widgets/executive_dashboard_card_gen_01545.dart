// GEN-01545 — Executive Dashboard MRR & Retention Card.
// Displays Monthly Recurring Revenue, average cart size, and subscription retention rates using M3 Elevated Cards with responsive layout and mock data.

import 'package:flutter/material.dart';

enum _DashboardHealth { good, average, poor }

class _MockMetric {
  final String label;
  final String value;
  final _DashboardHealth health;

  const _MockMetric({
    required this.label,
    required this.value,
    required this.health,
  });
}

class ExecutiveDashboardCardGen01545 extends StatefulWidget {
  const ExecutiveDashboardCardGen01545({super.key});

  @override
  State<ExecutiveDashboardCardGen01545> createState() => _ExecutiveDashboardCardGen01545State();
}

class _ExecutiveDashboardCardGen01545State extends State<ExecutiveDashboardCardGen01545> {
  late List<_MockMetric> _metrics;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    _metrics = const [
      _MockMetric(
        label: 'Monthly Recurring Revenue (MRR)',
        value: '\$1,245,000',
        health: _DashboardHealth.good,
      ),
      _MockMetric(
        label: 'Average Cart Size',
        value: '\$84.50',
        health: _DashboardHealth.average,
      ),
      _MockMetric(
        label: 'Subscription Retention Rate',
        value: '92.4%',
        health: _DashboardHealth.good,
      ),
    ];
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isRefreshing = false;
        _loadMockData();
      });
    }
  }

  Color _healthColor(_DashboardHealth health, ColorScheme colorScheme) {
    switch (health) {
      case _DashboardHealth.good:
        return colorScheme.primary;
      case _DashboardHealth.average:
        return colorScheme.tertiary;
      case _DashboardHealth.poor:
        return colorScheme.error;
    }
  }

  String _healthLabel(_DashboardHealth health) {
    switch (health) {
      case _DashboardHealth.good:
        return 'Good';
      case _DashboardHealth.average:
        return 'Average';
      case _DashboardHealth.poor:
        return 'Poor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final crossAxisCount = isMobile ? 1 : (constraints.maxWidth >= 840 ? 3 : 2);

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: isMobile ? 2.5 : 2.0,
            ),
            itemCount: _metrics.length,
            itemBuilder: (context, index) {
              final metric = _metrics[index];
              return Card(
                elevation: 3,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Drill-down for ${metric.label}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                                style: textTheme.titleSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(
                                _healthLabel(metric.health),
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: _healthColor(metric.health, colorScheme),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          metric.value,
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
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
}