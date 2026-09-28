// GEN-03937 — CI Runner Setup Status Card with M3 Elevated Design.
// Displays build job environment health (ubuntu-latest) via Material 3 Elevated Card, status chips, and background polling every 30 seconds.

import 'dart:async';
import 'package:flutter/material.dart';

enum CiRunnerStatus { complete, notComplete, pending }

class CiRunnerHealthData {
  final String stepName;
  final CiRunnerStatus status;
  final double setupLatencySeconds;
  final DateTime lastChecked;
  final String traceId;

  const CiRunnerHealthData({
    required this.stepName,
    required this.status,
    required this.setupLatencySeconds,
    required this.lastChecked,
    required this.traceId,
  });
}

class MockCiRunnerRepository {
  static const List<CiRunnerHealthData> _mockData = [
    CiRunnerHealthData(
      stepName: 'Define the build job environment running on ubuntu-latest.',
      status: CiRunnerStatus.complete,
      setupLatencySeconds: 1.45,
      lastChecked: DateTime(2026, 9, 28, 10, 0, 0),
      traceId: 'trace-gen-03937-001',
    ),
  ];

  Future<CiRunnerHealthData> fetchHealth() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockData.first;
  }
}

class CiRunnerStatusCardGen03937 extends StatefulWidget {
  const CiRunnerStatusCardGen03937({super.key});

  @override
  State<CiRunnerStatusCardGen03937> createState() => _CiRunnerStatusCardGen03937State();
}

class _CiRunnerStatusCardGen03937State extends State<CiRunnerStatusCardGen03937> {
  final MockCiRunnerRepository _repository = MockCiRunnerRepository();
  CiRunnerHealthData? _healthData;
  Timer? _pollingTimer;
  bool _isLoading = true;

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
      final data = await _repository.fetchHealth();
      if (mounted) {
        setState(() {
          _healthData = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _statusColor(CiRunnerStatus status, ColorScheme colorScheme) {
    switch (status) {
      case CiRunnerStatus.complete:
        return colorScheme.primary;
      case CiRunnerStatus.notComplete:
        return colorScheme.error;
      case CiRunnerStatus.pending:
        return colorScheme.tertiary;
    }
  }

  String _statusLabel(CiRunnerStatus status) {
    switch (status) {
      case CiRunnerStatus.complete:
        return 'Complete';
      case CiRunnerStatus.notComplete:
        return 'Not Complete';
      case CiRunnerStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final cardWidth = isMobile ? constraints.maxWidth : 600.0;

            return Center(
              child: SizedBox(
                width: cardWidth,
                child: Card(
                  elevation: 3.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'CI Runner Setup Health',
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (_healthData != null)
                              Chip(
                                avatar: Icon(
                                  _healthData!.status == CiRunnerStatus.complete
                                      ? Icons.check_circle_outline
                                      : Icons.error_outline,
                                  size: 18.0,
                                  color: _statusColor(_healthData!.status, colorScheme),
                                ),
                                label: Text(
                                  _statusLabel(_healthData!.status),
                                  style: textTheme.labelMedium?.copyWith(
                                    color: _statusColor(_healthData!.status, colorScheme),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: _statusColor(_healthData!.status, colorScheme).withOpacity(0.1),
                                side: BorderSide.none,
                              ),
                          ],
                        ),
                        const SizedBox(height: 24.0),
                        if (_isLoading && _healthData == null)
                          const Center(child: CircularProgressIndicator())
                        else if (_healthData != null)
                          ...[
                            Text(
                              'Step Description',
                              style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              _healthData!.stepName,
                              style: textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16.0),
                            Divider(color: colorScheme.outlineVariant),
                            const SizedBox(height: 16.0),
                            Row(
                              children: [
                                Expanded(
                                  child: _MetricTile(
                                    label: 'Setup Latency',
                                    value: '${_healthData!.setupLatencySeconds.toStringAsFixed(2)} s',
                                    target: '< 2 s',
                                    ceiling: '30 s',
                                    colorScheme: colorScheme,
                                    textTheme: textTheme,
                                  ),
                                ),
                                if (!isMobile) const SizedBox(width: 24.0),
                                if (!isMobile)
                                  Expanded(
                                    child: _MetricTile(
                                      label: 'Trace ID',
                                      value: _healthData!.traceId,
                                      target: 'N/A',
                                      ceiling: 'N/A',
                                      colorScheme: colorScheme,
                                      textTheme: textTheme,
                                    ),
                                  ),
                              ],
                            ),
                            if (isMobile) ...[
                              const SizedBox(height: 16.0),
                              _MetricTile(
                                label: 'Trace ID',
                                value: _healthData!.traceId,
                                target: 'N/A',
                                ceiling: 'N/A',
                                colorScheme: colorScheme,
                                textTheme: textTheme,
                              ),
                            ],
                            const SizedBox(height: 24.0),
                            Text(
                              'Last Checked: ${_healthData!.lastChecked.toLocal().toString().split('.').first}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ]
                        else
                          Center(
                            child: Text(
                              'No data available.',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.error,
                              ),
                            ),
                          ),
                        const SizedBox(height: 16.0),
                        SizedBox(
                          height: 48.0,
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Deep-link drill-down triggered.'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.open_in_new, size: 20.0),
                            label: const Text('View Engineering Console'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String target;
  final String ceiling;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.target,
    required this.ceiling,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Optimal: $target | Ceiling: $ceiling',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}