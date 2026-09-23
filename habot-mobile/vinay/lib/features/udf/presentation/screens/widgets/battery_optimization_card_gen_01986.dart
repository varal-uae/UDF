// GEN-01986 — Battery Optimization Status Card.
// M3 Elevated Card displaying step completion state, battery drain reduction metrics, and ingress bandwidth costs with background polling and pull-to-refresh support.

import 'dart:async';
import 'package:flutter/material.dart';

enum StepCompletionStatus { complete, partial, notComplete }

class BatteryOptimizationData {
  final String atomicId;
  final String description;
  final double completionRate;
  final StepCompletionStatus status;
  final DateTime timestamp;
  final int batteryDrainReductionPct;
  final int bandwidthCostReductionPct;

  const BatteryOptimizationData({
    required this.atomicId,
    required this.description,
    required this.completionRate,
    required this.status,
    required this.timestamp,
    required this.batteryDrainReductionPct,
    required this.bandwidthCostReductionPct,
  });
}

class MockBatteryOptimizationRepository {
  static const BatteryOptimizationData mockData = BatteryOptimizationData(
    atomicId: 'GEN-01986',
    description: 'Reduce battery drain and ingress bandwidth costs through optimizations.',
    completionRate: 95.5,
    status: StepCompletionStatus.complete,
    timestamp: null as dynamic,
    batteryDrainReductionPct: 22,
    bandwidthCostReductionPct: 34,
  );

  Future<BatteryOptimizationData> fetchStepData() async {
    await Future.delayed(const Duration(milliseconds: 80));
    return BatteryOptimizationData(
      atomicId: mockData.atomicId,
      description: mockData.description,
      completionRate: mockData.completionRate,
      status: mockData.status,
      timestamp: DateTime.now(),
      batteryDrainReductionPct: mockData.batteryDrainReductionPct,
      bandwidthCostReductionPct: mockData.bandwidthCostReductionPct,
    );
  }
}

class BatteryOptimizationCard extends StatefulWidget {
  const BatteryOptimizationCard({super.key});

  @override
  State<BatteryOptimizationCard> createState() => _BatteryOptimizationCardState();
}

class _BatteryOptimizationCardState extends State<BatteryOptimizationCard> {
  final MockBatteryOptimizationRepository _repository = MockBatteryOptimizationRepository();
  BatteryOptimizationData? _data;
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
    try {
      final data = await _repository.fetchStepData();
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    await _fetchData();
  }

  Color _statusColor(BuildContext context, StepCompletionStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case StepCompletionStatus.complete:
        return colorScheme.primary;
      case StepCompletionStatus.partial:
        return colorScheme.tertiary;
      case StepCompletionStatus.notComplete:
        return colorScheme.error;
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
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading && _data == null
              ? const Center(child: CircularProgressIndicator())
              : _buildCard(theme, isMobile),
        ),
      ),
    );
  }

  Widget _buildCard(ThemeData theme, bool isMobile) {
    final data = _data!;
    final statusColor = _statusColor(context, data.status);

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    data.atomicId,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    _statusLabel(data.status),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  backgroundColor: statusColor,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              data.description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (isMobile)
              _buildMetricsColumn(theme, data)
            else
              _buildMetricsRow(theme, data),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: data.completionRate / 100.0,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(statusColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Step Completion Rate: ${data.completionRate.toStringAsFixed(1)}%',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (data.timestamp != null) ...[
              const SizedBox(height: 4),
              Text(
                'Last updated: ${data.timestamp!.toIso8601String().substring(0, 19)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsColumn(ThemeData theme, BatteryOptimizationData data) {
    return Column(
      children: [
        _buildMetricTile(theme, 'Battery Drain Reduction', '${data.batteryDrainReductionPct}%'),
        const SizedBox(height: 8),
        _buildMetricTile(theme, 'Bandwidth Cost Reduction', '${data.bandwidthCostReductionPct}%'),
      ],
    );
  }

  Widget _buildMetricsRow(ThemeData theme, BatteryOptimizationData data) {
    return Row(
      children: [
        Expanded(child: _buildMetricTile(theme, 'Battery Drain Reduction', '${data.batteryDrainReductionPct}%')),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricTile(theme, 'Bandwidth Cost Reduction', '${data.bandwidthCostReductionPct}%')),
      ],
    );
  }

  Widget _buildMetricTile(ThemeData theme, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}