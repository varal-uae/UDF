// GEN-03464 — Push Warning Alert Card for Engineering Console.
// Displays high-priority push warning alerts to assigned managers using M3 Elevated Cards, status chips, and responsive single/multi-column layout with 30s polling and pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum PushAlertStatus { pass, fail, pending }

class PushWarningAlert {
  final String traceId;
  final String managerName;
  final String message;
  final PushAlertStatus status;
  final int deliveryLatencyMs;
  final DateTime timestamp;

  const PushWarningAlert({
    required this.traceId,
    required this.managerName,
    required this.message,
    required this.status,
    required this.deliveryLatencyMs,
    required this.timestamp,
  });
}

class MockPushAlertRepository {
  static List<PushWarningAlert> fetchAlerts() {
    return [
      PushWarningAlert(
        traceId: 'trace-001-gen-03464',
        managerName: 'Alice Johnson',
        message: 'High-priority system threshold exceeded.',
        status: PushAlertStatus.pass,
        deliveryLatencyMs: 145,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      PushWarningAlert(
        traceId: 'trace-002-gen-03464',
        managerName: 'Bob Smith',
        message: 'Database connection pool exhaustion warning.',
        status: PushAlertStatus.fail,
        deliveryLatencyMs: 2150,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      PushWarningAlert(
        traceId: 'trace-003-gen-03464',
        managerName: 'Carol Davis',
        message: 'API latency spike detected in payment service.',
        status: PushAlertStatus.pending,
        deliveryLatencyMs: 480,
        timestamp: DateTime.now().subtract(const Duration(seconds: 30)),
      ),
    ];
  }
}

class PushWarningAlertCardGen03464 extends StatefulWidget {
  const PushWarningAlertCardGen03464({super.key});

  @override
  State<PushWarningAlertCardGen03464> createState() => _PushWarningAlertCardGen03464State();
}

class _PushWarningAlertCardGen03464State extends State<PushWarningAlertCardGen03464> {
  List<PushWarningAlert> _alerts = [];
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadAlerts());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAlerts() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() {
      _alerts = MockPushAlertRepository.fetchAlerts();
      _isRefreshing = false;
    });
  }

  Color _statusColor(PushAlertStatus status, ColorScheme cs) {
    switch (status) {
      case PushAlertStatus.pass:
        return cs.primary;
      case PushAlertStatus.fail:
        return cs.error;
      case PushAlertStatus.pending:
        return cs.tertiary;
    }
  }

  String _statusLabel(PushAlertStatus status) {
    switch (status) {
      case PushAlertStatus.pass:
        return 'Pass';
      case PushAlertStatus.fail:
        return 'Fail';
      case PushAlertStatus.pending:
        return 'Pending';
    }
  }

  void _onDeepLinkDrillDown(PushWarningAlert alert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Drilling down into trace: ${alert.traceId}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 840;

    return RefreshIndicator(
      onRefresh: _loadAlerts,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (_alerts.isEmpty && !_isRefreshing) {
            return Center(
              child: Text('No push warning alerts available.', style: textTheme.bodyLarge),
            );
          }

          if (isDesktop) {
            return GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.4,
              ),
              itemCount: _alerts.length,
              itemBuilder: (context, index) => _buildCard(_alerts[index], cs, textTheme),
            );
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: _alerts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildCard(_alerts[index], cs, textTheme),
          );
        },
      ),
    );
  }

  Widget _buildCard(PushWarningAlert alert, ColorScheme cs, TextTheme textTheme) {
    return GestureDetector(
      onTap: () => _onDeepLinkDrillDown(alert),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      alert.managerName,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      _statusLabel(alert.status),
                      style: TextStyle(color: cs.surface, fontSize: 12),
                    ),
                    backgroundColor: _statusColor(alert.status, cs),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                alert.message,
                style: textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Latency: ${alert.deliveryLatencyMs}ms',
                    style: textTheme.labelMedium?.copyWith(
                      color: alert.deliveryLatencyMs < 500
                          ? cs.primary
                          : alert.deliveryLatencyMs < 2000
                              ? cs.tertiary
                              : cs.error,
                    ),
                  ),
                  Text(
                    'Trace: ${alert.traceId}',
                    style: textTheme.labelSmall?.copyWith(color: cs.outline),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '${alert.timestamp.hour}:${alert.timestamp.minute.toString().padLeft(2, '0')}',
                  style: textTheme.labelSmall?.copyWith(color: cs.outlineVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
