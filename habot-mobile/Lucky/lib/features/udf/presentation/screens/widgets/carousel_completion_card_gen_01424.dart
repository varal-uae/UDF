// GEN-01424 — Carousel Completion Rate KPI Card.
// Displays the First-Run Experience carousel completion rate against a 90% target threshold using M3 Elevated Cards and Status Chips. Single-column mobile layout with 30-second background polling and pull-to-refresh support.

import 'dart:async';
import 'package:flutter/material.dart';

enum _CompletionStatus { good, average, poor }

class _CarouselMetric {
  final double completionRate;
  final DateTime timestamp;
  final String sessionId;

  const _CarouselMetric({
    required this.completionRate,
    required this.timestamp,
    required this.sessionId,
  });
}

class _MockCarouselRepository {
  static const List<_CarouselMetric> _mockData = [
    _CarouselMetric(completionRate: 0.92, timestamp: null, sessionId: 'sess_001'),
    _CarouselMetric(completionRate: 0.85, timestamp: null, sessionId: 'sess_002'),
    _CarouselMetric(completionRate: 0.74, timestamp: null, sessionId: 'sess_003'),
    _CarouselMetric(completionRate: 0.95, timestamp: null, sessionId: 'sess_004'),
    _CarouselMetric(completionRate: 0.68, timestamp: null, sessionId: 'sess_005'),
  ];

  Future<_CarouselMetric> fetchLatestMetric() async {
    await Future.delayed(const Duration(milliseconds: 80));
    final now = DateTime.now();
    final base = _mockData[now.second % _mockData.length];
    return _CarouselMetric(
      completionRate: base.completionRate,
      timestamp: now,
      sessionId: base.sessionId,
    );
  }
}

class CarouselCompletionCardGen01424 extends StatefulWidget {
  const CarouselCompletionCardGen01424({super.key});

  @override
  State<CarouselCompletionCardGen01424> createState() => _CarouselCompletionCardGen01424State();
}

class _CarouselCompletionCardGen01424State extends State<CarouselCompletionCardGen01424> {
  final _repository = _MockCarouselRepository();
  _CarouselMetric? _metric;
  bool _isLoading = true;
  Timer? _pollingTimer;

  static const double _floorBoundary = 0.7;
  static const double _optimalTarget = 0.9;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchData());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _repository.fetchLatestMetric();
      if (mounted) {
        setState(() {
          _metric = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  _CompletionStatus _evaluateStatus(double rate) {
    if (rate >= _optimalTarget) return _CompletionStatus.good;
    if (rate >= _floorBoundary) return _CompletionStatus.average;
    return _CompletionStatus.poor;
  }

  String _statusLabel(_CompletionStatus status) {
    switch (status) {
      case _CompletionStatus.good:
        return 'Good';
      case _CompletionStatus.average:
        return 'Average';
      case _CompletionStatus.poor:
        return 'Poor';
    }
  }

  Color _statusColor(_CompletionStatus status, ColorScheme cs) {
    switch (status) {
      case _CompletionStatus.good:
        return cs.primary;
      case _CompletionStatus.average:
        return cs.tertiary;
      case _CompletionStatus.poor:
        return cs.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('First-Run Experience', style: textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('Carousel Completion Rate', style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 16),
              Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _metric == null
                          ? Center(child: Text('No data available', style: textTheme.bodyLarge))
                          : _buildContent(cs, textTheme),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ColorScheme cs, TextTheme textTheme) {
    final rate = _metric!.completionRate;
    final status = _evaluateStatus(rate);
    final percentage = (rate * 100).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$percentage%', style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: cs.onSurface)),
                  const SizedBox(height: 4),
                  Text('Target: ${(_optimalTarget * 100).toStringAsFixed(0)}%', style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            Chip(
              label: Text(_statusLabel(status), style: TextStyle(color: _statusColor(status, cs))),
              backgroundColor: _statusColor(status, cs).withOpacity(0.12),
              side: BorderSide.none,
            ),
          ],
        ),
        const SizedBox(height: 24),
        LinearProgressIndicator(
          value: rate.clamp(0.0, 1.0),
          minHeight: 8,
          backgroundColor: cs.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(_statusColor(status, cs)),
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 24),
        Divider(color: cs.outlineVariant),
        const SizedBox(height: 16),
        _buildInfoRow('Session ID', _metric!.sessionId, cs, textTheme),
        const SizedBox(height: 8),
        _buildInfoRow('Last Updated', _formatTimestamp(_metric!.timestamp), cs, textTheme),
        const SizedBox(height: 8),
        _buildInfoRow('Benchmark', 'Mobile Growth Association FRE', cs, textTheme),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.tonal(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('Drill-down initiated for detailed analytics.'), behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('View Drill-Down Details'),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, ColorScheme cs, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        Text(value, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: cs.onSurface)),
      ],
    );
  }

  String _formatTimestamp(DateTime? dt) {
    if (dt == null) return 'N/A';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}
