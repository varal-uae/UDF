// GEN-03640 — Metric Calculation Standardization Card.
// M3 Elevated Card displaying dashboard metric standardization status with background polling, pull-to-refresh, and responsive single-column/multi-column layout.

import 'dart:async';
import 'package:flutter/material.dart';

enum MetricStatus { pass, fail, pending }

class MetricStandardizationModel {
  final String metricName;
  final double floorBoundary;
  final double optimalTarget;
  final double ceilingBoundary;
  final MetricStatus status;
  final DateTime lastUpdated;

  const MetricStandardizationModel({
    required this.metricName,
    required this.floorBoundary,
    required this.optimalTarget,
    required this.ceilingBoundary,
    required this.status,
    required this.lastUpdated,
  });
}

class MockMetricRepository {
  static Future<List<MetricStandardizationModel>> fetchMetrics() async {
    await Future.delayed(const Duration(milliseconds: 80));
    return [
      MetricStandardizationModel(
        metricName: 'Metric Calculation Standardization Ratio',
        floorBoundary: 1.0,
        optimalTarget: 1.0,
        ceilingBoundary: 1.0,
        status: MetricStatus.pass,
        lastUpdated: DateTime.now(),
      ),
      MetricStandardizationModel(
        metricName: 'Corporate BI Governance Compliance',
        floorBoundary: 1.0,
        optimalTarget: 1.0,
        ceilingBoundary: 1.0,
        status: MetricStatus.pass,
        lastUpdated: DateTime.now(),
      ),
    ];
  }
}

class MetricStandardizationCard extends StatefulWidget {
  const MetricStandardizationCard({super.key});

  @override
  State<MetricStandardizationCard> createState() => _MetricStandardizationCardState();
}

class _MetricStandardizationCardState extends State<MetricStandardizationCard> {
  List<MetricStandardizationModel> _metrics = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadMetrics());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMetrics() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await MockMetricRepository.fetchMetrics();
      if (mounted) {
        setState(() {
          _metrics = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _statusColor(MetricStatus status, ColorScheme cs) {
    switch (status) {
      case MetricStatus.pass:
        return cs.primary;
      case MetricStatus.fail:
        return cs.error;
      case MetricStatus.pending:
        return cs.tertiary;
    }
  }

  String _statusLabel(MetricStatus status) {
    switch (status) {
      case MetricStatus.pass:
        return 'Pass';
      case MetricStatus.fail:
        return 'Fail';
      case MetricStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 840;

    return RefreshIndicator(
      onRefresh: _loadMetrics,
      color: cs.primary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = isDesktop ? 2 : 1;
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                    childAspectRatio: isDesktop ? 2.5 : 2.0,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (_isLoading && _metrics.isEmpty) {
                        return Card(
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (index >= _metrics.length) return null;
                      final metric = _metrics[index];
                      return Card(
                        elevation: 3.0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16.0),
                          onTap: () => _showDetailSheet(context, metric),
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
                                        metric.metricName,
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Chip(
                                      label: Text(_statusLabel(metric.status)),
                                      backgroundColor: _statusColor(metric.status, cs).withValues(alpha: 0.1),
                                      labelStyle: TextStyle(color: _statusColor(metric.status, cs), fontWeight: FontWeight.bold),
                                      side: BorderSide.none,
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text('Floor: ${metric.floorBoundary} | Target: ${metric.optimalTarget} | Ceiling: ${metric.ceilingBoundary}',
                                    style: theme.textTheme.bodySmall),
                                const SizedBox(height: 4.0),
                                Text('Updated: ${metric.lastUpdated.toIso8601String().substring(0, 19)}',
                                    style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: _isLoading && _metrics.isEmpty ? 2 : _metrics.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDetailSheet(BuildContext context, MetricStandardizationModel metric) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 8.0,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Metric Configuration Detail', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 16.0),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Metric Name'),
                subtitle: Text(metric.metricName),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Status'),
                subtitle: Text(_statusLabel(metric.status)),
                trailing: Icon(
                  metric.status == MetricStatus.pass ? Icons.check_circle : Icons.cancel,
                  color: metric.status == MetricStatus.pass ? Colors.green : Colors.red,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Boundaries'),
                subtitle: Text('Floor: ${metric.floorBoundary}, Optimal: ${metric.optimalTarget}, Ceiling: ${metric.ceilingBoundary}'),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                height: 48.0,
                child: FilledButton.tonal(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Configuration acknowledged.'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                    );
                  },
                  child: const Text('Acknowledge & Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
