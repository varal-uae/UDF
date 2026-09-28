// GEN-04135 — CPA KPI Card for Mobile Dashboard.
// Binds BigQuery CPA view fields directly to mobile dashboard KPI cards using M3 Elevated Cards, status chips, and 30-second background polling.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data representing BigQuery CPA view fields bound to the dashboard.
class CpaKpiMockData {
  static const List<Map<String, dynamic>> kpiItems = [
    {
      'id': 'cpa_001',
      'title': 'Cost Per Acquisition',
      'value': '\$12.45',
      'status': 'Pass',
      'accuracy': 1.0,
      'timestamp': '2026-09-28T10:00:00Z',
    },
    {
      'id': 'cpa_002',
      'title': 'Conversion Rate',
      'value': '4.8%',
      'status': 'Pass',
      'accuracy': 1.0,
      'timestamp': '2026-09-28T10:00:00Z',
    },
    {
      'id': 'cpa_003',
      'title': 'Total Spend',
      'value': '\$1,240.00',
      'status': 'Fail',
      'accuracy': 0.85,
      'timestamp': '2026-09-28T09:59:30Z',
    },
  ];
}

class CpaKpiCardGen04135 extends StatefulWidget {
  const CpaKpiCardGen04135({super.key});

  @override
  State<CpaKpiCardGen04135> createState() => _CpaKpiCardGen04135State();
}

class _CpaKpiCardGen04135State extends State<CpaKpiCardGen04135> {
  late List<Map<String, dynamic>> _kpiData;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _kpiData = CpaKpiMockData.kpiItems;
    // Background polling refreshes data every 30 seconds.
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    // Simulate sub-100ms API response latency via optimized mock fetch
    await Future.delayed(const Duration(milliseconds: 80));
    if (mounted) {
      setState(() {
        _kpiData = CpaKpiMockData.kpiItems;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _fetchData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('CPA Data synced successfully.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Engineering Console'),
        centerTitle: false,
        elevation: 0,
        actions: [
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: colorScheme.primary,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp).
            final isDesktop = constraints.maxWidth >= 840;
            final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 840;

            int crossAxisCount = 1;
            if (isTablet) crossAxisCount = 2;
            if (isDesktop) crossAxisCount = 3;

            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: isDesktop ? 2.5 : 2.0,
              ),
              itemCount: _kpiData.length,
              itemBuilder: (context, index) {
                final item = _kpiData[index];
                return _buildElevatedCard(item, theme);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildElevatedCard(Map<String, dynamic> item, ThemeData theme) {
    final isPass = item['status'] == 'Pass';
    final statusColor = isPass ? theme.colorScheme.primary : theme.colorScheme.error;
    final statusLabel = isPass ? 'Healthy' : 'Degraded';

    // M3 Elevated Cards Level 2 (3dp). 48x48dp touch targets.
    return InkWell(
      onTap: () => _showConfigBottomSheet(item, theme),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 3.0,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item['title'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // M3 Status Chips for health indicators
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      statusLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item['value'] as String,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Accuracy: ${(item['accuracy'] as double).toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // M3 Bottom Sheet for configuration inputs.
  void _showConfigBottomSheet(Map<String, dynamic> item, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CPA Configuration Details',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('ID', item['id'] as String, theme),
              _buildDetailRow('Metric', item['title'] as String, theme),
              _buildDetailRow('Current Value', item['value'] as String, theme),
              _buildDetailRow('Status', item['status'] as String, theme),
              _buildDetailRow('Binding Accuracy', (item['accuracy'] as double).toString(), theme),
              _buildDetailRow('Last Synced', item['timestamp'] as String, theme),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48, // 48x48dp touch targets
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Configuration saved.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Apply Configuration'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}