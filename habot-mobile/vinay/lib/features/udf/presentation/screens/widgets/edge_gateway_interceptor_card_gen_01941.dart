// GEN-01941 — Edge Gateway Mobile Submit Interceptor UI Card.
// M3 Elevated Card displaying edge/gateway intercept completion state with status chips, 30s polling, and pull-to-refresh support.

import 'dart:async';
import 'package:flutter/material.dart';

enum InterceptStatus { complete, partial, notComplete }

class EdgeGatewayInterceptEvent {
  final String traceId;
  final String sessionId;
  final DateTime timestamp;
  final InterceptStatus status;
  final int latencyMs;

  const EdgeGatewayInterceptEvent({
    required this.traceId,
    required this.sessionId,
    required this.timestamp,
    required this.status,
    required this.latencyMs,
  });
}

class MockEdgeGatewayRepository {
  static const List<EdgeGatewayInterceptEvent> mockEvents = [
    EdgeGatewayInterceptEvent(
      traceId: 'trace-001-gen-01941',
      sessionId: 'session-mobile-01',
      timestamp: DateTime(2026, 9, 23, 10, 0, 0),
      status: InterceptStatus.complete,
      latencyMs: 42,
    ),
    EdgeGatewayInterceptEvent(
      traceId: 'trace-002-gen-01941',
      sessionId: 'session-mobile-02',
      timestamp: DateTime(2026, 9, 23, 10, 0, 30),
      status: InterceptStatus.partial,
      latencyMs: 87,
    ),
    EdgeGatewayInterceptEvent(
      traceId: 'trace-003-gen-01941',
      sessionId: 'session-mobile-03',
      timestamp: DateTime(2026, 9, 23, 10, 1, 0),
      status: InterceptStatus.notComplete,
      latencyMs: 150,
    ),
  ];

  Future<List<EdgeGatewayInterceptEvent>> fetchEvents() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return mockEvents;
  }
}

class EdgeGatewayInterceptorCard extends StatefulWidget {
  const EdgeGatewayInterceptorCard({super.key});

  @override
  State<EdgeGatewayInterceptorCard> createState() => _EdgeGatewayInterceptorCardState();
}

class _EdgeGatewayInterceptorCardState extends State<EdgeGatewayInterceptorCard> {
  final MockEdgeGatewayRepository _repository = MockEdgeGatewayRepository();
  List<EdgeGatewayInterceptEvent> _events = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadData());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final events = await _repository.fetchEvents();
      if (mounted) {
        setState(() {
          _events = events;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double _calculateCompletionRate() {
    if (_events.isEmpty) return 0.0;
    final completed = _events.where((e) => e.status == InterceptStatus.complete).length;
    return (completed / _events.length) * 100.0;
  }

  Color _getStatusColor(InterceptStatus status, ThemeData theme) {
    switch (status) {
      case InterceptStatus.complete:
        return theme.colorScheme.primary;
      case InterceptStatus.partial:
        return theme.colorScheme.tertiary;
      case InterceptStatus.notComplete:
        return theme.colorScheme.error;
    }
  }

  String _getStatusLabel(InterceptStatus status) {
    switch (status) {
      case InterceptStatus.complete:
        return 'Complete';
      case InterceptStatus.partial:
        return 'Partial';
      case InterceptStatus.notComplete:
        return 'Not Complete';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final completionRate = _calculateCompletionRate();
    final meetsFloor = completionRate >= 90.0;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edge/Gateway Interceptor Health',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 3.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: isMobile
                      ? _buildMobileLayout(theme, completionRate, meetsFloor)
                      : _buildDesktopLayout(theme, completionRate, meetsFloor),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Recent Interception Events',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ..._events.map((event) => _buildEventTile(event, theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(ThemeData theme, double rate, bool meetsFloor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildKpiHeader(theme, rate, meetsFloor),
        const SizedBox(height: 16),
        _buildMetricsRow(theme, rate),
      ],
    );
  }

  Widget _buildDesktopLayout(ThemeData theme, double rate, bool meetsFloor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildKpiHeader(theme, rate, meetsFloor)),
        const SizedBox(width: 32),
        Expanded(child: _buildMetricsRow(theme, rate)),
      ],
    );
  }

  Widget _buildKpiHeader(ThemeData theme, double rate, bool meetsFloor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step Completion Rate (%)', style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${rate.toStringAsFixed(1)}%',
              style: theme.textTheme.displaySmall?.copyWith(
                color: meetsFloor ? theme.colorScheme.primary : theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            Chip(
              avatar: Icon(
                meetsFloor ? Icons.check_circle : Icons.warning,
                size: 18,
                color: meetsFloor ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onErrorContainer,
              ),
              label: Text(meetsFloor ? 'Healthy' : 'Below Floor'),
              backgroundColor: meetsFloor
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.errorContainer,
              labelStyle: TextStyle(
                color: meetsFloor
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onErrorContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Floor: 90% | Optimal: 99% | Ceiling: 100%',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsRow(ThemeData theme, double rate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetricItem(theme, 'ISO Standard', 'ISO/IEC 27001:2022'),
        const SizedBox(height: 8),
        _buildMetricItem(theme, 'Data Source', 'edge/gateway'),
        const SizedBox(height: 8),
        _buildMetricItem(theme, 'Polling Interval', '30 seconds'),
        const SizedBox(height: 8),
        _buildMetricItem(theme, 'Last Sync', TimeOfDay.now().format(context)),
      ],
    );
  }

  Widget _buildMetricItem(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        )),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        )),
      ],
    );
  }

  Widget _buildEventTile(EdgeGatewayInterceptEvent event, ThemeData theme) {
    final statusColor = _getStatusColor(event.status, theme);
    final statusLabel = _getStatusLabel(event.status);

    return Card(
      elevation: 1.0,
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Drill-down for trace: ${event.traceId}'),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Dismiss',
                onPressed: () {},
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  event.status == InterceptStatus.complete
                      ? Icons.check_rounded
                      : event.status == InterceptStatus.partial
                          ? Icons.hourglass_bottom_rounded
                          : Icons.close_rounded,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.traceId,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Session: ${event.sessionId} • ${event.latencyMs}ms',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(statusLabel),
                backgroundColor: statusColor.withOpacity(0.12),
                labelStyle: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide.none,
              ),
            ],
          ),
        ),
      ),
    );
  }
}