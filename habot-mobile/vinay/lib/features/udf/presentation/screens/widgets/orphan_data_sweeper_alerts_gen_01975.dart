// GEN-01975 — Orphan Data Sweeper & Alerts.
// Displays alert routing thresholds and on-call developer assignments using M3 Elevated Cards, status chips, 30-second polling, pull-to-refresh, and a bottom sheet for configuration inputs.

import 'dart:async';
import 'package:flutter/material.dart';

enum AlertHealth { good, fair, poor }

class AlertThresholdData {
  final String id;
  final String metricName;
  final int currentValue;
  final int floorBoundary;
  final int optimalTarget;
  final int ceilingBoundary;
  final AlertHealth health;
  final String onCallDeveloper;
  final DateTime lastUpdated;

  const AlertThresholdData({
    required this.id,
    required this.metricName,
    required this.currentValue,
    required this.floorBoundary,
    required this.optimalTarget,
    required this.ceilingBoundary,
    required this.health,
    required this.onCallDeveloper,
    required this.lastUpdated,
  });
}

class MockAlertRepository {
  static List<AlertThresholdData> fetchAlerts() {
    return [
      AlertThresholdData(
        id: 'trace-001',
        metricName: 'Maximum Unacknowledged Message Age (seconds)',
        currentValue: 8,
        floorBoundary: 60,
        optimalTarget: 10,
        ceilingBoundary: 5,
        health: AlertHealth.good,
        onCallDeveloper: 'Vinay H.',
        lastUpdated: DateTime.now(),
      ),
      AlertThresholdData(
        id: 'trace-002',
        metricName: 'Maximum Unacknowledged Message Age (seconds)',
        currentValue: 45,
        floorBoundary: 60,
        optimalTarget: 10,
        ceilingBoundary: 5,
        health: AlertHealth.fair,
        onCallDeveloper: 'Sarah K.',
        lastUpdated: DateTime.now().subtract(const Duration(seconds: 15)),
      ),
      AlertThresholdData(
        id: 'trace-003',
        metricName: 'Maximum Unacknowledged Message Age (seconds)',
        currentValue: 72,
        floorBoundary: 60,
        optimalTarget: 10,
        ceilingBoundary: 5,
        health: AlertHealth.poor,
        onCallDeveloper: 'Alex M.',
        lastUpdated: DateTime.now().subtract(const Duration(seconds: 40)),
      ),
    ];
  }
}

class OrphanDataSweeperAlertsGen01975 extends StatefulWidget {
  const OrphanDataSweeperAlertsGen01975({super.key});

  @override
  State<OrphanDataSweeperAlertsGen01975> createState() => _OrphanDataSweeperAlertsGen01975State();
}

class _OrphanDataSweeperAlertsGen01975State extends State<OrphanDataSweeperAlertsGen01975> {
  List<AlertThresholdData> _alerts = [];
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _alerts = MockAlertRepository.fetchAlerts();
    });
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadData();
    });
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    _loadData();
    if (mounted) setState(() => _isRefreshing = false);
  }

  Color _healthColor(AlertHealth health, ColorScheme cs) {
    switch (health) {
      case AlertHealth.good:
        return cs.primary;
      case AlertHealth.fair:
        return cs.tertiary;
      case AlertHealth.poor:
        return cs.error;
    }
  }

  String _healthLabel(AlertHealth health) {
    switch (health) {
      case AlertHealth.good:
        return 'Good';
      case AlertHealth.fair:
        return 'Fair';
      case AlertHealth.poor:
        return 'Poor';
    }
  }

  void _openConfigBottomSheet(AlertThresholdData data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Configure Threshold', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              Text('Metric: ${data.metricName}', style: Theme.of(ctx).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text('On-Call: ${data.onCallDeveloper}', style: Theme.of(ctx).textTheme.bodyMedium),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'New Floor Boundary (seconds)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Configuration updated successfully.'),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
                      ),
                    );
                  },
                  child: const Text('Save Configuration'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orphan Data Sweeper & Alerts'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 840;
            final crossAxisCount = isDesktop ? 2 : 1;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: isDesktop ? 2.5 : 1.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final alert = _alerts[index];
                        return _buildElevatedCard(alert, colorScheme, textTheme);
                      },
                      childCount: _alerts.length,
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

  Widget _buildElevatedCard(AlertThresholdData alert, ColorScheme cs, TextTheme tt) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _openConfigBottomSheet(alert),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      alert.metricName,
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      _healthLabel(alert.health),
                      style: TextStyle(color: cs.surface, fontSize: 12),
                    ),
                    backgroundColor: _healthColor(alert.health, cs),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 18, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text('${alert.currentValue}s', style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  Icon(Icons.person_outline, size: 18, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(alert.onCallDeveloper, style: tt.bodyMedium),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Floor: ${alert.floorBoundary}s | Optimal: ${alert.optimalTarget}s | Ceiling: ${alert.ceilingBoundary}s',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                'Trace: ${alert.id}',
                style: tt.labelSmall?.copyWith(color: cs.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
