// GEN-01258 — Security Dashboard displaying fraud review volume, operator decision SLA rates, and chargeback prevention metrics.
// Implements M3 Elevated Cards with status chips, 30s background polling, pull-to-refresh, and responsive single/multi-column layout.

import 'dart:async';
import 'package:flutter/material.dart';

enum MetricStatus { good, average, poor }

class SecurityMetric {
  final String title;
  final String value;
  final MetricStatus status;
  final double authenticityRate;

  const SecurityMetric({
    required this.title,
    required this.value,
    required this.status,
    required this.authenticityRate,
  });
}

class MockSecurityRepository {
  static const List<SecurityMetric> metrics = [
    SecurityMetric(
      title: 'Fraud Review Volume',
      value: '1,248 reviews',
      status: MetricStatus.good,
      authenticityRate: 0.98,
    ),
    SecurityMetric(
      title: 'Operator Decision SLA Rate',
      value: '94.2% within SLA',
      status: MetricStatus.average,
      authenticityRate: 0.92,
    ),
    SecurityMetric(
      title: 'Chargeback Prevention',
      value: '\$42,500 saved',
      status: MetricStatus.good,
      authenticityRate: 0.99,
    ),
  ];

  Future<List<SecurityMetric>> fetchMetrics() async {
    await Future.delayed(const Duration(milliseconds: 80));
    return metrics;
  }
}

class SecurityDashboardGen01258 extends StatefulWidget {
  const SecurityDashboardGen01258({super.key});

  @override
  State<SecurityDashboardGen01258> createState() => _SecurityDashboardGen01258State();
}

class _SecurityDashboardGen01258State extends State<SecurityDashboardGen01258> {
  final MockSecurityRepository _repository = MockSecurityRepository();
  late Future<List<SecurityMetric>> _metricsFuture;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
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
    setState(() {
      _metricsFuture = _repository.fetchMetrics();
    });
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
    final ThemeData theme = Theme.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 840;
    final int crossAxisCount = isDesktop ? 3 : 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Dashboard'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<SecurityMetric>>(
        future: _metricsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading metrics: \${snapshot.error}'));
          }

          final metrics = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: _loadMetrics,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: isDesktop ? 2.5 : 2.0,
                ),
                itemCount: metrics.length,
                itemBuilder: (context, index) {
                  final metric = metrics[index];
                  return _buildMetricCard(metric, theme);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(SecurityMetric metric, ThemeData theme) {
    final Color statusColor = _getStatusColor(metric.status, theme);
    final String statusLabel = _getStatusLabel(metric.status);

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Drill-down for \${metric.title}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(16.0),
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: statusColor, width: 1.0),
                    ),
                    child: Text(
                      statusLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Text(
                metric.value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 16.0,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    'Authenticity: \${(metric.authenticityRate * 100).toStringAsFixed(1)}%',
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
}
