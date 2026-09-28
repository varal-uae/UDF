// GEN-03959 — Materialized View Fetch Latency M3 Status Card.
// Displays query response time metric with Pass/Fail status chip, 30s background polling, and pull-to-refresh support using mock data.

import 'dart:async';
import 'package:flutter/material.dart';

enum _LatencyStatus { pass, fail }

class _MockLatencyData {
  final double latencyMs;
  final _LatencyStatus status;
  final DateTime timestamp;
  final String traceId;

  const _MockLatencyData({
    required this.latencyMs,
    required this.status,
    required this.timestamp,
    required this.traceId,
  });
}

class MvLatencyCardGen03959 extends StatefulWidget {
  const MvLatencyCardGen03959({super.key});

  @override
  State<MvLatencyCardGen03959> createState() => _MvLatencyCardGen03959State();
}

class _MvLatencyCardGen03959State extends State<MvLatencyCardGen03959> {
  static const double _floorBoundary = 200.0;
  static const double _optimalTarget = 20.0;
  static const Duration _pollingInterval = Duration(seconds: 30);

  late _MockLatencyData _currentData;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  final List<_MockLatencyData> _mockHistory = [
    _MockLatencyData(
      latencyMs: 14.5,
      status: _LatencyStatus.pass,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      traceId: 'trace-001-gen-03959',
    ),
    _MockLatencyData(
      latencyMs: 45.2,
      status: _LatencyStatus.pass,
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      traceId: 'trace-002-gen-03959',
    ),
    _MockLatencyData(
      latencyMs: 12.8,
      status: _LatencyStatus.pass,
      timestamp: DateTime.now(),
      traceId: 'trace-003-gen-03959',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentData = _mockHistory.last;
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      _fetchLatestData();
    });
  }

  Future<void> _fetchLatestData() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);

    await Future.delayed(const Duration(milliseconds: 600));

    final simulatedLatency = 10.0 + (DateTime.now().millisecond % 50);
    final newStatus = simulatedLatency < _floorBoundary ? _LatencyStatus.pass : _LatencyStatus.fail;

    if (!mounted) return;
    setState(() {
      _currentData = _MockLatencyData(
        latencyMs: simulatedLatency,
        status: newStatus,
        timestamp: DateTime.now(),
        traceId: 'trace-${DateTime.now().millisecondsSinceEpoch}-gen-03959',
      );
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPass = _currentData.status == _LatencyStatus.pass;
    final isOptimal = _currentData.latencyMs < _optimalTarget;

    return RefreshIndicator(
      onRefresh: _fetchLatestData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Materialized View Fetch Latency',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'GEN-03959 | Engineering Console KPI',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16.0),
              Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_currentData.latencyMs.toStringAsFixed(1)} ms',
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isPass
                                        ? (isOptimal
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.tertiary)
                                        : theme.colorScheme.error,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  'Floor Boundary: < $_floorBoundary ms | Optimal: < $_optimalTarget ms',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Chip(
                            avatar: Icon(
                              isPass ? Icons.check_circle_outline : Icons.error_outline,
                              size: 18.0,
                              color: isPass
                                  ? theme.colorScheme.onSecondaryContainer
                                  : theme.colorScheme.onErrorContainer,
                            ),
                            label: Text(
                              isPass ? 'PASS' : 'FAIL',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: isPass
                                ? theme.colorScheme.secondaryContainer
                                : theme.colorScheme.errorContainer,
                            labelStyle: TextStyle(
                              color: isPass
                                  ? theme.colorScheme.onSecondaryContainer
                                  : theme.colorScheme.onErrorContainer,
                            ),
                            side: BorderSide.none,
                          ),
                        ],
                      ),
                      const Divider(height: 32.0),
                      _buildInfoRow(
                        context,
                        icon: Icons.fingerprint,
                        label: 'Trace ID',
                        value: _currentData.traceId,
                      ),
                      const SizedBox(height: 12.0),
                      _buildInfoRow(
                        context,
                        icon: Icons.access_time,
                        label: 'Last Checked',
                        value: _formatTimestamp(_currentData.timestamp),
                      ),
                      const SizedBox(height: 12.0),
                      _buildInfoRow(
                        context,
                        icon: Icons.sync,
                        label: 'Auto-Refresh',
                        value: 'Every 30 seconds',
                      ),
                      if (_isRefreshing) ...[
                        const SizedBox(height: 16.0),
                        LinearProgressIndicator(
                          borderRadius: BorderRadius.circular(4.0),
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              Text(
                'Recent History',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12.0),
              ..._mockHistory.reversed.map((data) => _buildHistoryTile(context, data)).toList(),
              const SizedBox(height: 48.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18.0, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8.0),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTile(BuildContext context, _MockLatencyData data) {
    final theme = Theme.of(context);
    final isPass = data.status == _LatencyStatus.pass;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        elevation: 1.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: ListTile(
          minVerticalPadding: 12.0,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          leading: Icon(
            isPass ? Icons.check_circle : Icons.cancel,
            color: isPass ? theme.colorScheme.primary : theme.colorScheme.error,
            size: 24.0,
          ),
          title: Text(
            '${data.latencyMs.toStringAsFixed(1)} ms',
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            _formatTimestamp(data.timestamp),
            style: theme.textTheme.bodySmall,
          ),
          trailing: Text(
            isPass ? 'Pass' : 'Fail',
            style: theme.textTheme.labelMedium?.copyWith(
              color: isPass ? theme.colorScheme.primary : theme.colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}