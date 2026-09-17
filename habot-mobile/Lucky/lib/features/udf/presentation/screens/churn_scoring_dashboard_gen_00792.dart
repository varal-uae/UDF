// GEN-00792 — Predictive Mobile CLV & Churn Scoring Dashboard.
// Displays read-only M3 KPI cards for Sync Export Latency with background polling every 30 seconds and pull-to-refresh. Responsive single-column on mobile (<600dp), multi-column on desktop (>=840dp).

import 'dart:async';
import 'package:flutter/material.dart';

enum ExportStatus { pass, fail, pending }

class ChurnScoringMetric {
  final String metricName;
  final Duration latency;
  final ExportStatus status;
  final DateTime timestamp;

  const ChurnScoringMetric({
    required this.metricName,
    required this.latency,
    required this.status,
    required this.timestamp,
  });
}

class ChurnScoringDashboardGen00792 extends StatefulWidget {
  const ChurnScoringDashboardGen00792({super.key});

  @override
  State<ChurnScoringDashboardGen00792> createState() => _ChurnScoringDashboardGen00792State();
}

class _ChurnScoringDashboardGen00792State extends State<ChurnScoringDashboardGen00792> {
  Timer? _pollingTimer;
  bool _isRefreshing = false;
  ChurnScoringMetric _currentMetric = ChurnScoringMetric(
    metricName: 'Sync Export Latency',
    latency: const Duration(minutes: 4),
    status: ExportStatus.pending,
    timestamp: DateTime.now(),
  );

  static const Duration _floorBoundary = Duration(minutes: 15);
  static const Duration _optimalTarget = Duration(minutes: 5);
  static const Duration _ceilingBoundary = Duration(minutes: 30);
  static const Duration _pollingInterval = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_pollingInterval, (_) => _fetchMetrics());
  }

  Future<void> _fetchMetrics() async {
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final simulatedLatency = Duration(minutes: (DateTime.now().second % 20) + 1);
    final status = simulatedLatency <= _floorBoundary ? ExportStatus.pass : ExportStatus.fail;

    setState(() {
      _currentMetric = ChurnScoringMetric(
        metricName: 'Sync Export Latency',
        latency: simulatedLatency,
        status: status,
        timestamp: DateTime.now(),
      );
    });
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await _fetchMetrics();
    if (mounted) {
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Manual sync completed successfully.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Color _getStatusColor(BuildContext context, ExportStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case ExportStatus.pass:
        return colorScheme.primary;
      case ExportStatus.fail:
        return colorScheme.error;
      case ExportStatus.pending:
        return colorScheme.outline;
    }
  }

  String _getStatusLabel(ExportStatus status) {
    switch (status) {
      case ExportStatus.pass:
        return 'Pass';
      case ExportStatus.fail:
        return 'Fail';
      case ExportStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CLV & Churn Scoring'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configuration',
            onPressed: () => _showConfigBottomSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 840;
            final padding = isDesktop ? 24.0 : 16.0;

            final metricsCard = _buildMetricsElevatedCard(context);
            final infoCard = _buildThresholdInfoCard(context);

            if (isDesktop) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(padding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: metricsCard),
                    SizedBox(width: padding),
                    Expanded(flex: 1, child: infoCard),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(padding),
              child: Column(
                children: [
                  metricsCard,
                  SizedBox(height: padding),
                  infoCard,
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricsElevatedCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusColor = _getStatusColor(context, _currentMetric.status);

    return Card(
      elevation: 3.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currentMetric.metricName,
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                Chip(
                  label: Text(
                    _getStatusLabel(_currentMetric.status),
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: statusColor.withOpacity(0.12),
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            Text(
              '${_currentMetric.latency.inMinutes} mins ${_currentMetric.latency.inSeconds.remainder(60)} secs',
              style: textTheme.displaySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Last updated: ${_formatTimestamp(_currentMetric.timestamp)}',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
            ),
            const SizedBox(height: 24.0),
            SizedBox(
              height: 48.0,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.analytics_outlined, size: 20.0),
                label: const Text('View Drill-down Details'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48.0, 48.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdInfoCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 3.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Threshold Boundaries', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16.0),
            _buildThresholdRow(context, 'Optimal Target', '<= 5 mins', colorScheme.primary),
            const Divider(height: 24.0),
            _buildThresholdRow(context, 'Floor Boundary', '<= 15 mins', colorScheme.tertiary),
            const Divider(height: 24.0),
            _buildThresholdRow(context, 'Ceiling Boundary', '30 mins', colorScheme.error),
            const SizedBox(height: 16.0),
            Text(
              'Reference Spec: Meta CAPI / Firebase Export Spec',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdRow(BuildContext context, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 8.0, height: 8.0, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 12.0),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showConfigBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24.0,
            right: 24.0,
            top: 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              Text(
                'Step Configuration',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'FCM Topic Override',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Meta CAPI Pixel ID',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                height: 48.0,
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Configuration saved.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Save Configuration'),
                ),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} $h:$m:$s';
  }
}