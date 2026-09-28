// GEN-03508 — Conversion Analytics Dashboard displaying variant performance metrics.
// Implements M3 responsive layout (single-column mobile <600dp, multi-column desktop >=840dp),
// Elevated Cards Level 2, Status Chips, 48x48dp touch targets, pull-to-refresh, and 30s background polling with mock data.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data model for variant performance metrics.
class VariantMetric {
  final String id;
  final String variantName;
  final double conversionRate;
  final int totalUsers;
  final int conversions;
  final VariantStatus status;

  const VariantMetric({
    required this.id,
    required this.variantName,
    required this.conversionRate,
    required this.totalUsers,
    required this.conversions,
    required this.status,
  });
}

enum VariantStatus { active, paused, completed, error }

/// Mock repository providing local hardcoded data.
class MockAnalyticsRepository {
  static const List<VariantMetric> _mockMetrics = [
    VariantMetric(
      id: 'var_001',
      variantName: 'Control (A)',
      conversionRate: 0.124,
      totalUsers: 15420,
      conversions: 1912,
      status: VariantStatus.active,
    ),
    VariantMetric(
      id: 'var_002',
      variantName: 'Variant B (New CTA)',
      conversionRate: 0.158,
      totalUsers: 15380,
      conversions: 2430,
      status: VariantStatus.active,
    ),
    VariantMetric(
      id: 'var_003',
      variantName: 'Variant C (Redesign)',
      conversionRate: 0.091,
      totalUsers: 8200,
      conversions: 746,
      status: VariantStatus.paused,
    ),
    VariantMetric(
      id: 'var_004',
      variantName: 'Variant D (Pricing)',
      conversionRate: 0.182,
      totalUsers: 5000,
      conversions: 910,
      status: VariantStatus.completed,
    ),
  ];

  Future<List<VariantMetric>> fetchMetrics() async {
    // Simulate network latency well under the 200ms floor threshold
    await Future.delayed(const Duration(milliseconds: 45));
    return _mockMetrics;
  }
}

class ConversionAnalyticsDashboardGen03508 extends StatefulWidget {
  const ConversionAnalyticsDashboardGen03508({super.key});

  @override
  State<ConversionAnalyticsDashboardGen03508> createState() =>
      _ConversionAnalyticsDashboardGen03508State();
}

class _ConversionAnalyticsDashboardGen03508State
    extends State<ConversionAnalyticsDashboardGen03508> {
  final MockAnalyticsRepository _repository = MockAnalyticsRepository();
  List<VariantMetric> _metrics = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Background polling refreshes data every 30 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadData(showLoadingIndicator: false);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData({bool showLoadingIndicator = true}) async {
    if (showLoadingIndicator && mounted) {
      setState(() => _isLoading = true);
    }
    try {
      final data = await _repository.fetchMetrics();
      if (mounted) {
        setState(() {
          _metrics = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load metrics: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  Color _getStatusColor(VariantStatus status, ThemeData theme) {
    switch (status) {
      case VariantStatus.active:
        return theme.colorScheme.primary;
      case VariantStatus.completed:
        return theme.colorScheme.tertiary;
      case VariantStatus.paused:
        return theme.colorScheme.secondary;
      case VariantStatus.error:
        return theme.colorScheme.error;
    }
  }

  String _getStatusLabel(VariantStatus status) {
    switch (status) {
      case VariantStatus.active:
        return 'Active';
      case VariantStatus.completed:
        return 'Completed';
      case VariantStatus.paused:
        return 'Paused';
      case VariantStatus.error:
        return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversion Analytics'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: 'Manual Sync',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp)
                  final isDesktop = constraints.maxWidth >= 840;
                  final isTablet =
                      constraints.maxWidth >= 600 && constraints.maxWidth < 840;

                  final int crossAxisCount =
                      isDesktop ? 3 : (isTablet ? 2 : 1);

                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16.0),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 16.0,
                            crossAxisSpacing: 16.0,
                            childAspectRatio: isDesktop ? 2.2 : 2.5,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final metric = _metrics[index];
                              return _buildMetricCard(metric, theme);
                            },
                            childCount: _metrics.length,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }

  /// Builds an M3 Elevated Card Level 2 (3dp elevation) with inline status chip.
  Widget _buildMetricCard(VariantMetric metric, ThemeData theme) {
    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () => _showDetailsBottomSheet(metric, theme),
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
                      metric.variantName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // M3 Status Chip for health indicators
                  _buildStatusChip(metric.status, theme),
                ],
              ),
              const Spacer(),
              Text(
                '${(metric.conversionRate * 100).toStringAsFixed(2)}%',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Conversion Rate',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSubStat(
                    'Users',
                    metric.totalUsers.toString(),
                    theme,
                  ),
                  _buildSubStat(
                    'Conversions',
                    metric.conversions.toString(),
                    theme,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(VariantStatus status, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status, theme).withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _getStatusLabel(status),
        style: theme.textTheme.labelSmall?.copyWith(
          color: _getStatusColor(status, theme),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSubStat(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// M3 Bottom Sheet for configuration inputs / deep-link drill-down details.
  void _showDetailsBottomSheet(VariantMetric metric, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 32,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        metric.variantName,
                        style: theme.textTheme.headlineSmall,
                      ),
                      _buildStatusChip(metric.status, theme),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow('Variant ID', metric.id, theme),
                  _buildDetailRow(
                    'Conversion Rate',
                    '${(metric.conversionRate * 100).toStringAsFixed(2)}%',
                    theme,
                  ),
                  _buildDetailRow(
                    'Total Users',
                    metric.totalUsers.toString(),
                    theme,
                  ),
                  _buildDetailRow(
                    'Total Conversions',
                    metric.conversions.toString(),
                    theme,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48, // 48x48dp touch targets
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Configuration saved'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('Apply Configuration'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}