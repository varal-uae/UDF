// GEN-01225 — BI Dashboard Stream Order Fee Breakdown Card.
// Displays order fee breakdowns and average order values using M3 Elevated Cards with status chips, background polling every 30 seconds, and pull-to-refresh support. Responsive single-column on mobile (<600dp) and multi-column on desktop (>=840dp).

import 'dart:async';
import 'package:flutter/material.dart';

enum DataRefreshStatus { good, average, poor }

class OrderFeeBreakdown {
  final String category;
  final double amount;
  final double percentage;

  const OrderFeeBreakdown({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}

class BiDashboardData {
  final double averageOrderValue;
  final List<OrderFeeBreakdown> feeBreakdowns;
  final DataRefreshStatus refreshStatus;
  final DateTime lastUpdated;

  const BiDashboardData({
    required this.averageOrderValue,
    required this.feeBreakdowns,
    required this.refreshStatus,
    required this.lastUpdated,
  });
}

class MockBiDashboardRepository {
  static const BiDashboardData _mockData = BiDashboardData(
    averageOrderValue: 452.75,
    refreshStatus: DataRefreshStatus.good,
    lastUpdated: null,
    feeBreakdowns: [
      OrderFeeBreakdown(category: 'Service Fee', amount: 25.00, percentage: 5.5),
      OrderFeeBreakdown(category: 'Delivery Fee', amount: 15.00, percentage: 3.3),
      OrderFeeBreakdown(category: 'Tax', amount: 18.50, percentage: 4.1),
      OrderFeeBreakdown(category: 'Platform Fee', amount: 10.00, percentage: 2.2),
    ],
  );

  Future<BiDashboardData> fetchDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 80)); // Sub-100ms latency simulation
    return BiDashboardData(
      averageOrderValue: _mockData.averageOrderValue,
      feeBreakdowns: _mockData.feeBreakdowns,
      refreshStatus: _mockData.refreshStatus,
      lastUpdated: DateTime.now(),
    );
  }
}

class BiDashboardStreamCard extends StatefulWidget {
  const BiDashboardStreamCard({super.key});

  @override
  State<BiDashboardStreamCard> createState() => _BiDashboardStreamCardState();
}

class _BiDashboardStreamCardState extends State<BiDashboardStreamCard> {
  final MockBiDashboardRepository _repository = MockBiDashboardRepository();
  BiDashboardData? _data;
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      final data = await _repository.fetchDashboardData();
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
    await _loadData();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Color _getStatusColor(DataRefreshStatus status, ColorScheme colorScheme) {
    switch (status) {
      case DataRefreshStatus.good:
        return colorScheme.primary;
      case DataRefreshStatus.average:
        return colorScheme.tertiary;
      case DataRefreshStatus.poor:
        return colorScheme.error;
    }
  }

  String _getStatusLabel(DataRefreshStatus status) {
    switch (status) {
      case DataRefreshStatus.good:
        return 'Good';
      case DataRefreshStatus.average:
        return 'Average';
      case DataRefreshStatus.poor:
        return 'Poor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isDesktop = constraints.maxWidth >= 840;

          if (_isLoading && _data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_data == null) {
            return const Center(child: Text('No data available'));
          }

          final cards = <Widget>[
            _buildAovCard(theme, colorScheme),
            ..._data!.feeBreakdowns.map((fee) => _buildFeeCard(fee, theme, colorScheme)),
          ];

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: isDesktop
                ? Wrap(spacing: 16.0, runSpacing: 16.0, children: cards)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: cards
                        .map((card) => Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: card,
                            ))
                        .toList(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildAovCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 3.0,
      surfaceTintColor: colorScheme.surfaceTint,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Average Order Value', style: theme.textTheme.titleMedium),
                Chip(
                  label: Text(
                    _getStatusLabel(_data!.refreshStatus),
                    style: TextStyle(
                      color: _getStatusColor(_data!.refreshStatus, colorScheme),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: _getStatusColor(_data!.refreshStatus, colorScheme).withOpacity(0.1),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Text(
              '\$${_data!.averageOrderValue.toStringAsFixed(2)}',
              style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Last updated: ${_formatTime(_data!.lastUpdated)}',
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeCard(OrderFeeBreakdown fee, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 3.0,
      surfaceTintColor: colorScheme.surfaceTint,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fee.category, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4.0),
                  Text('${fee.percentage.toStringAsFixed(1)}%', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            Text(
              '\$${fee.amount.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return 'N/A';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}
