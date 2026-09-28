// GEN-03761 — CFO Alert Engineering Console Card.
// Displays high-risk un-provisioned customer balance alerts older than 90 days
// using M3 Elevated Cards, Status Chips, and 30-second background polling with pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum AlertHealthStatus { pass, fail }

class CfoAlertMetric {
  final String traceId;
  final String customerId;
  final double balanceAmount;
  final int daysOverdue;
  final DateTime eventTimestamp;
  final AlertHealthStatus status;

  const CfoAlertMetric({
    required this.traceId,
    required this.customerId,
    required this.balanceAmount,
    required this.daysOverdue,
    required this.eventTimestamp,
    required this.status,
  });
}

class MockCfoAlertRepository {
  static const List<CfoAlertMetric> mockAlerts = [
    CfoAlertMetric(
      traceId: 'trace-001-gen-03761',
      customerId: 'CUST-HR-9921',
      balanceAmount: 145000.00,
      daysOverdue: 94,
      eventTimestamp: _kMockNow,
      status: AlertHealthStatus.pass,
    ),
    CfoAlertMetric(
      traceId: 'trace-002-gen-03761',
      customerId: 'CUST-HR-8834',
      balanceAmount: 89250.50,
      daysOverdue: 112,
      eventTimestamp: _kMockNow,
      status: AlertHealthStatus.fail,
    ),
    CfoAlertMetric(
      traceId: 'trace-003-gen-03761',
      customerId: 'CUST-HR-7712',
      balanceAmount: 210500.75,
      daysOverdue: 91,
      eventTimestamp: _kMockNow,
      status: AlertHealthStatus.pass,
    ),
  ];

  static const DateTime _kMockNow = DateTime(2026, 9, 28, 10, 30);

  Future<List<CfoAlertMetric>> fetchAlerts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockAlerts;
  }
}

class CfoAlertConsoleCard extends StatefulWidget {
  const CfoAlertConsoleCard({super.key});

  @override
  State<CfoAlertConsoleCard> createState() => _CfoAlertConsoleCardState();
}

class _CfoAlertConsoleCardState extends State<CfoAlertConsoleCard> {
  final MockCfoAlertRepository _repository = MockCfoAlertRepository();
  List<CfoAlertMetric> _alerts = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadData(showLoading: false);
    });
  }

  Future<void> _loadData({bool showLoading = true}) async {
    if (showLoading && mounted) setState(() => _isLoading = true);
    try {
      final data = await _repository.fetchAlerts();
      if (mounted) {
        setState(() {
          _alerts = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    await _loadData(showLoading: false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Manual sync completed successfully.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.sizeOf(context).width >= 840;

    return Card(
      elevation: 3.0,
      clipBehavior: Clip.antiAlias,
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
                    'Self-Chasing Mechanism: High-Risk Balances (>90 Days)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Chip(
                  avatar: Icon(
                    _isLoading ? Icons.sync : Icons.check_circle_outline,
                    size: 18,
                  ),
                  label: Text(_isLoading ? 'Syncing' : 'Live'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              RefreshIndicator(
                onRefresh: _onRefresh,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = isDesktop ? 2 : 1;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: isDesktop ? 3.5 : 3.0,
                      ),
                      itemCount: _alerts.length,
                      itemBuilder: (context, index) {
                        return _AlertItemCard(alert: _alerts[index]);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AlertItemCard extends StatelessWidget {
  final CfoAlertMetric alert;

  const _AlertItemCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPass = alert.status == AlertHealthStatus.pass;

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (ctx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alert Details', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Text('Trace ID: ${alert.traceId}'),
                  Text('Customer: ${alert.customerId}'),
                  Text('Balance: \$${alert.balanceAmount.toStringAsFixed(2)}'),
                  Text('Days Overdue: ${alert.daysOverdue}'),
                  Text('Status: ${isPass ? 'PASS' : 'FAIL'}'),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: Icon(
                  isPass ? Icons.shield_outlined : Icons.warning_amber_rounded,
                  color: isPass ? Colors.green : Colors.red,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    alert.customerId,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${alert.balanceAmount.toStringAsFixed(2)} • ${alert.daysOverdue}d overdue',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            FilterChip(
              selected: isPass,
              label: Text(isPass ? 'PASS' : 'FAIL'),
              onSelected: (_) {},
              showCheckmark: false,
              backgroundColor: isPass
                  ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                  : theme.colorScheme.errorContainer.withOpacity(0.3),
              selectedColor: isPass
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.errorContainer,
            ),
          ],
        ),
      ),
    );
  }
}