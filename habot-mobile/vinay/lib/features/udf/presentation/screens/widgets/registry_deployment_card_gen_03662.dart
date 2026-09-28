// GEN-03662 — Registry Deployment SLA Status Card.
// M3 Elevated Card displaying component publish/store status for @habot/fixed-assets-core with mock telemetry data, 30s polling, and pull-to-refresh support.

import 'dart:async';
import 'package:flutter/material.dart';

enum _DeploymentStatus { pass, fail }

class _MockRegistryTelemetry {
  final String packageId;
  final String metricName;
  final double currentSla;
  final double floorBoundary;
  final double optimalTarget;
  final _DeploymentStatus status;
  final DateTime timestamp;
  final String traceId;

  const _MockRegistryTelemetry({
    required this.packageId,
    required this.metricName,
    required this.currentSla,
    required this.floorBoundary,
    required this.optimalTarget,
    required this.status,
    required this.timestamp,
    required this.traceId,
  });
}

const List<_MockRegistryTelemetry> _kMockData = [
  _MockRegistryTelemetry(
    packageId: '@habot/fixed-assets-core',
    metricName: 'Registry Deployment SLA',
    currentSla: 0.9995,
    floorBoundary: 0.999,
    optimalTarget: 0.9999,
    status: _DeploymentStatus.pass,
    timestamp: DateTime(2026, 9, 28, 10, 15, 0),
    traceId: 'trace-gen-03662-001',
  ),
];

class RegistryDeploymentCardGen03662 extends StatefulWidget {
  const RegistryDeploymentCardGen03662({super.key});

  @override
  State<RegistryDeploymentCardGen03662> createState() => _RegistryDeploymentCardGen03662State();
}

class _RegistryDeploymentCardGen03662State extends State<RegistryDeploymentCardGen03662> {
  late _MockRegistryTelemetry _telemetry;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _telemetry = _kMockData.first;
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _telemetry = _MockRegistryTelemetry(
        packageId: _telemetry.packageId,
        metricName: _telemetry.metricName,
        currentSla: _telemetry.currentSla,
        floorBoundary: _telemetry.floorBoundary,
        optimalTarget: _telemetry.optimalTarget,
        status: _telemetry.status,
        timestamp: DateTime.now(),
        traceId: 'trace-gen-03662-${DateTime.now().millisecondsSinceEpoch}',
      );
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPass = _telemetry.status == _DeploymentStatus.pass;
    final statusColor = isPass ? colorScheme.primary : colorScheme.error;
    final statusLabel = isPass ? 'Pass' : 'Fail';

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Component Registry Health',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _telemetry.packageId,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Chip(
                            avatar: Icon(
                              isPass ? Icons.check_circle : Icons.error,
                              size: 18,
                              color: statusColor,
                            ),
                            label: Text(statusLabel),
                            backgroundColor: statusColor.withOpacity(0.1),
                            labelStyle: TextStyle(color: statusColor),
                            side: BorderSide.none,
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      _MetricRow(
                        label: 'Metric',
                        value: _telemetry.metricName,
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _MetricRow(
                        label: 'Current SLA',
                        value: _telemetry.currentSla.toStringAsFixed(4),
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _MetricRow(
                        label: 'Floor Boundary',
                        value: _telemetry.floorBoundary.toStringAsFixed(3),
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _MetricRow(
                        label: 'Optimal Target',
                        value: _telemetry.optimalTarget.toStringAsFixed(4),
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _MetricRow(
                        label: 'Trace ID',
                        value: _telemetry.traceId,
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      _MetricRow(
                        label: 'Last Updated',
                        value: '${_telemetry.timestamp.hour}:${_telemetry.timestamp.minute.toString().padLeft(2, '0')}:${_telemetry.timestamp.second.toString().padLeft(2, '0')}',
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ),
              if (_isRefreshing) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}