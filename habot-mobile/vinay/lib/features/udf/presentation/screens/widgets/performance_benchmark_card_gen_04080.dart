// GEN-04080 — Performance Benchmark Status Card for Mobile Engineering Console.
// Displays M3 Elevated Card with inline status chip, background polling every 30s, and pull-to-refresh for mobile dashboard response latency metrics.

import 'dart:async';
import 'package:flutter/material.dart';

enum BenchmarkStatus { pass, fail, pending }

class BenchmarkResult {
  final String metricName;
  final double latencyMs;
  final BenchmarkStatus status;
  final DateTime timestamp;
  final String traceId;

  const BenchmarkResult({
    required this.metricName,
    required this.latencyMs,
    required this.status,
    required this.timestamp,
    required this.traceId,
  });
}

class MockBenchmarkRepository {
  static const double _floorThreshold = 500.0;
  static const double _optimalTarget = 150.0;
  static const double _ceilingBoundary = 1000.0;

  Future<BenchmarkResult> fetchLatestBenchmark() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final randomLatency = 80.0 + (DateTime.now().millisecond % 200);
    final status = randomLatency < _floorThreshold ? BenchmarkStatus.pass : BenchmarkStatus.fail;

    return BenchmarkResult(
      metricName: 'Mobile Dashboard Response Latency',
      latencyMs: randomLatency,
      status: status,
      timestamp: DateTime.now(),
      traceId: 'trace-${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

class PerformanceBenchmarkCardGen04080 extends StatefulWidget {
  const PerformanceBenchmarkCardGen04080({super.key});

  @override
  State<PerformanceBenchmarkCardGen04080> createState() => _PerformanceBenchmarkCardGen04080State();
}

class _PerformanceBenchmarkCardGen04080State extends State<PerformanceBenchmarkCardGen04080> {
  final MockBenchmarkRepository _repository = MockBenchmarkRepository();
  BenchmarkResult? _currentResult;
  bool _isLoading = true;
  Timer? _pollingTimer;

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
      final result = await _repository.fetchLatestBenchmark();
      if (mounted) {
        setState(() {
          _currentResult = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(BuildContext context, BenchmarkStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case BenchmarkStatus.pass:
        return colorScheme.primary;
      case BenchmarkStatus.fail:
        return colorScheme.error;
      case BenchmarkStatus.pending:
        return colorScheme.outline;
    }
  }

  String _getStatusLabel(BenchmarkStatus status) {
    switch (status) {
      case BenchmarkStatus.pass:
        return 'PASS';
      case BenchmarkStatus.fail:
        return 'FAIL';
      case BenchmarkStatus.pending:
        return 'PENDING';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Engineering Console - Step Health',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _isLoading && _currentResult == null
                      ? const SizedBox(
                          height: 120,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _buildCardContent(context, theme),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, ThemeData theme) {
    if (_currentResult == null) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('No benchmark data available')),
      );
    }

    final result = _currentResult!;
    final statusColor = _getStatusColor(context, result.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                result.metricName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Chip(
              label: Text(
                _getStatusLabel(result.status),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: statusColor,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Response Time', style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  '${result.latencyMs.toStringAsFixed(1)} ms',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Threshold (<500ms)', style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  result.latencyMs < 500.0 ? 'Within Limits' : 'Exceeded',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Trace ID: ${result.traceId}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Last Updated: ${result.timestamp.toLocal().toString().split('.').first}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        if (_isLoading) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ],
      ],
    );
  }
}