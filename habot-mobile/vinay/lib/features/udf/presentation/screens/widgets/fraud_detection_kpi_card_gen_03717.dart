// GEN-03717 — Fraud Detection KPI Card for Engineering Console.
// Displays synthetic fraud test suite accuracy with M3 ElevatedCard, status chips, and 30s background polling.

import 'dart:async';
import 'package:flutter/material.dart';

enum FraudTestStatus { pass, fail, pending }

class FraudDetectionResult {
  final String metricName;
  final double accuracy;
  final double floorBoundary;
  final double optimalTarget;
  final FraudTestStatus status;
  final DateTime timestamp;
  final String traceId;

  const FraudDetectionResult({
    required this.metricName,
    required this.accuracy,
    required this.floorBoundary,
    required this.optimalTarget,
    required this.status,
    required this.timestamp,
    required this.traceId,
  });
}

class MockFraudDetectionRepository {
  static const List<FraudDetectionResult> _mockData = [
    FraudDetectionResult(
      metricName: 'Synthetic Fraud Test Suite Accuracy',
      accuracy: 0.972,
      floorBoundary: 0.95,
      optimalTarget: 0.99,
      status: FraudTestStatus.pass,
      timestamp: DateTime(2026, 9, 28, 10, 0),
      traceId: 'trace-gen-03717-001',
    ),
    FraudDetectionResult(
      metricName: 'Synthetic Fraud Test Suite Accuracy',
      accuracy: 0.931,
      floorBoundary: 0.95,
      optimalTarget: 0.99,
      status: FraudTestStatus.fail,
      timestamp: DateTime(2026, 9, 28, 9, 30),
      traceId: 'trace-gen-03717-002',
    ),
  ];

  int _index = 0;

  Future<FraudDetectionResult> fetchLatestResult() async {
    await Future.delayed(const Duration(milliseconds: 80)); // Sub-100ms simulation
    final result = _mockData[_index % _mockData.length];
    _index++;
    return result;
  }
}

class FraudDetectionKpiCardGen03717 extends StatefulWidget {
  const FraudDetectionKpiCardGen03717({super.key});

  @override
  State<FraudDetectionKpiCardGen03717> createState() => _FraudDetectionKpiCardGen03717State();
}

class _FraudDetectionKpiCardGen03717State extends State<FraudDetectionKpiCardGen03717> {
  final MockFraudDetectionRepository _repository = MockFraudDetectionRepository();
  FraudDetectionResult? _currentResult;
  Timer? _pollingTimer;
  bool _isPolling = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isPolling) {
        _fetchData();
      }
    });
  }

  Future<void> _fetchData() async {
    final result = await _repository.fetchLatestResult();
    if (mounted) {
      setState(() {
        _currentResult = result;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _isPolling = false);
    await _fetchData();
    setState(() => _isPolling = true);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Color _getStatusColor(BuildContext context, FraudTestStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case FraudTestStatus.pass:
        return colorScheme.primary;
      case FraudTestStatus.fail:
        return colorScheme.error;
      case FraudTestStatus.pending:
        return colorScheme.tertiary;
    }
  }

  String _getStatusLabel(FraudTestStatus status) {
    switch (status) {
      case FraudTestStatus.pass:
        return 'Pass';
      case FraudTestStatus.fail:
        return 'Fail';
      case FraudTestStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              return _buildCard(context, colorScheme, textTheme, isMobile);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isMobile,
  ) {
    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isMobile
            ? _buildMobileLayout(context, colorScheme, textTheme)
            : _buildDesktopLayout(context, colorScheme, textTheme),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context, textTheme),
        const SizedBox(height: 16),
        _buildMetricRow(context, textTheme, colorScheme),
        const SizedBox(height: 16),
        _buildStatusChip(context, colorScheme),
        const SizedBox(height: 12),
        _buildTimestamp(textTheme, colorScheme),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, textTheme),
              const SizedBox(height: 8),
              _buildMetricRow(context, textTheme, colorScheme),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatusChip(context, colorScheme),
              const SizedBox(height: 8),
              _buildTimestamp(textTheme, colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    return Row(
      children: [
        Icon(
          Icons.shield_outlined,
          size: 24,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Fraud Engine Testing Benchmark',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    if (_currentResult == null) {
      return const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final accuracyPercent = (_currentResult!.accuracy * 100).toStringAsFixed(1);
    final floorPercent = (_currentResult!.floorBoundary * 100).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _currentResult!.metricName,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$accuracyPercent%',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Floor Threshold: >$floorPercent% | Target: >99.0%',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context, ColorScheme colorScheme) {
    if (_currentResult == null) {
      return const SizedBox.shrink();
    }

    final status = _currentResult!.status;
    final statusColor = _getStatusColor(context, status);

    return Chip(
      avatar: Icon(
        status == FraudTestStatus.pass ? Icons.check_circle : Icons.cancel,
        size: 18,
        color: statusColor,
      ),
      label: Text(
        _getStatusLabel(status),
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: statusColor.withOpacity(0.1),
      side: BorderSide(color: statusColor.withOpacity(0.3)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildTimestamp(TextTheme textTheme, ColorScheme colorScheme) {
    if (_currentResult == null) {
      return const SizedBox.shrink();
    }

    return Text(
      'Last updated: ${_currentResult!.timestamp.toLocal().toString().substring(0, 19)}',
      style: textTheme.labelSmall?.copyWith(
        color: colorScheme.outline,
      ),
    );
  }
}
