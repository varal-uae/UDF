// GEN-02008 — Conversion Rate Monitor M3 Elevated Card.
// Displays step completion rate with M3 status chips, 48x48dp touch targets, single-column mobile layout, and 30-second background polling with pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum StepCompletionStatus { complete, partial, notComplete }

class ConversionMonitorData {
  final String stepId;
  final String stepName;
  final double completionRate;
  final StepCompletionStatus status;
  final DateTime timestamp;

  const ConversionMonitorData({
    required this.stepId,
    required this.stepName,
    required this.completionRate,
    required this.status,
    required this.timestamp,
  });
}

class MockConversionRepository {
  static const List<ConversionMonitorData> mockMetrics = [
    ConversionMonitorData(
      stepId: 'GEN-02007',
      stepName: 'Foundational Configuration',
      completionRate: 99.2,
      status: StepCompletionStatus.complete,
      timestamp: DateTime(2026, 9, 23, 10, 0),
    ),
    ConversionMonitorData(
      stepId: 'GEN-02008',
      stepName: 'Mobile-Specific Layout Optimization',
      completionRate: 94.5,
      status: StepCompletionStatus.partial,
      timestamp: DateTime(2026, 9, 23, 10, 5),
    ),
    ConversionMonitorData(
      stepId: 'GEN-02009',
      stepName: 'Telemetry Validation',
      completionRate: 78.0,
      status: StepCompletionStatus.notComplete,
      timestamp: DateTime(2026, 9, 23, 10, 10),
    ),
  ];

  Future<List<ConversionMonitorData>> fetchMetrics() async {
    await Future.delayed(const Duration(milliseconds: 80));
    return mockMetrics;
  }
}

class ConversionMonitorCard extends StatefulWidget {
  const ConversionMonitorCard({super.key});

  @override
  State<ConversionMonitorCard> createState() => _ConversionMonitorCardState();
}

class _ConversionMonitorCardState extends State<ConversionMonitorCard> {
  final MockConversionRepository _repository = MockConversionRepository();
  List<ConversionMonitorData> _metrics = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadMetrics(showLoading: false);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMetrics({bool showLoading = true}) async {
    if (showLoading) setState(() => _isLoading = true);
    try {
      final data = await _repository.fetchMetrics();
      if (mounted) setState(() => _metrics = data);
    } finally {
      if (mounted && showLoading) setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    await _loadMetrics();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Metrics synchronized successfully.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Color _statusColor(StepCompletionStatus status, ColorScheme cs) {
    switch (status) {
      case StepCompletionStatus.complete:
        return cs.primary;
      case StepCompletionStatus.partial:
        return cs.tertiary;
      case StepCompletionStatus.notComplete:
        return cs.error;
    }
  }

  String _statusLabel(StepCompletionStatus status) {
    switch (status) {
      case StepCompletionStatus.complete:
        return 'Complete';
      case StepCompletionStatus.partial:
        return 'Partial';
      case StepCompletionStatus.notComplete:
        return 'Not Complete';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      edgeOffset: 0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 840;
          final crossAxisCount = isDesktop ? 2 : 1;

          if (_isLoading && _metrics.isEmpty) {
            return SizedBox(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(color: cs.primary),
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: isDesktop ? 2.8 : 2.2,
            ),
            itemCount: _metrics.length,
            itemBuilder: (context, index) {
              final metric = _metrics[index];
              final color = _statusColor(metric.status, cs);
              final belowFloor = metric.completionRate < 90;

              return Card(
                elevation: 3,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Drill-down for ${metric.stepId}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
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
                                metric.stepName,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(
                                _statusLabel(metric.status),
                                style: TextStyle(
                                  color: color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: color.withOpacity(0.12),
                              side: BorderSide.none,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${metric.completionRate.toStringAsFixed(1)}%',
                              style: textTheme.headlineMedium?.copyWith(
                                color: belowFloor ? cs.error : cs.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: metric.completionRate / 100,
                                backgroundColor: cs.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  belowFloor ? cs.error : color,
                                ),
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 14, color: cs.outline),
                            const SizedBox(width: 4),
                            Text(
                              'Updated: ${metric.timestamp.hour}:${metric.timestamp.minute.toString().padLeft(2, '0')}',
                              style: textTheme.bodySmall?.copyWith(
                                color: cs.outline,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.open_in_new,
                                  color: cs.primary,
                                  size: 20,
                                ),
                                tooltip: 'View Details',
                                style: IconButton.styleFrom(
                                  minimumSize: const Size(48, 48),
                                  tapTargetSize: MaterialTapTargetSize.padded,
                                ),
                              ),
                            ),
                          ],
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
