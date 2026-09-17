// GEN-00737 — Mobile Ad Fraud & Invalid Traffic (IVT) Filtering Gate Console Screen.
// Displays read-only M3 KPI cards with deep-link drill-down for unsigned payload drop rate, implementing single-column mobile (<600dp) and multi-column desktop (>=840dp) responsive layout with 30-second background polling and pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

/// Hardcoded gateway rejection rule: payloads lacking valid cryptographic signatures are dropped.
const bool _kGatewayRejectsUnsignedPayloads = true;

class IvtFilteringGateScreen extends StatefulWidget {
  const IvtFilteringGateScreen({super.key});

  @override
  State<IvtFilteringGateScreen> createState() => _IvtFilteringGateScreenState();
}

class _IvtFilteringGateScreenState extends State<IvtFilteringGateScreen> {
  Timer? _pollingTimer;
  bool _isPolling = false;
  String _completionStatus = 'Pass';
  double _unsignedPayloadDropRate = 1.0; // 100% floor threshold
  DateTime _lastUpdated = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  void _startPolling() {
    if (_isPolling) return;
    _isPolling = true;
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshData();
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() {
      // Simulate fetching from BigQuery partitioned by event_date, clustered by trace_id
      _unsignedPayloadDropRate = _kGatewayRejectsUnsignedPayloads ? 1.0 : 0.0;
      _completionStatus = _unsignedPayloadDropRate >= 1.0 ? 'Pass' : 'Fail';
      _lastUpdated = DateTime.now();
    });
  }

  Future<void> _handlePullToRefresh() async {
    await _refreshData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Data synchronized successfully.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IVT Filtering Gate'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _handlePullToRefresh,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isDesktop = constraints.maxWidth >= 840;
            final int crossAxisCount = isDesktop ? 2 : 1;

            return CustomScrollView(
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: isDesktop ? 2.5 : 2.0,
                    ),
                    delegate: SliverChildListDelegate(
                      <Widget>[
                        _buildKpiCard(
                          context: context,
                          title: 'Completion Status',
                          value: _completionStatus,
                          icon: Icons.check_circle_outline,
                          statusColor: _completionStatus == 'Pass'
                              ? colorScheme.primary
                              : colorScheme.error,
                        ),
                        _buildKpiCard(
                          context: context,
                          title: 'Unsigned Payload Drop Rate',
                          value: '${(_unsignedPayloadDropRate * 100).toStringAsFixed(0)}%',
                          icon: Icons.security,
                          statusColor: _unsignedPayloadDropRate >= 1.0
                              ? colorScheme.primary
                              : colorScheme.error,
                        ),
                        _buildKpiCard(
                          context: context,
                          title: 'Gateway Rejection Rule',
                          value: _kGatewayRejectsUnsignedPayloads ? 'Active' : 'Inactive',
                          icon: Icons.block,
                          statusColor: _kGatewayRejectsUnsignedPayloads
                              ? colorScheme.primary
                              : colorScheme.error,
                        ),
                        _buildKpiCard(
                          context: context,
                          title: 'Last Updated',
                          value: '${_lastUpdated.hour}:${_lastUpdated.minute.toString().padLeft(2, '0')}:${_lastUpdated.second.toString().padLeft(2, '0')}',
                          icon: Icons.update,
                          statusColor: colorScheme.onSurfaceVariant,
                        ),
                      ],
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

  Widget _buildKpiCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color statusColor,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showConfigurationBottomSheet(context, title, value),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(icon, color: colorScheme.onSurfaceVariant, size: 24.0),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      value,
                      style: textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // M3 Status Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      title == 'Completion Status' ? value : 'Healthy',
                      style: textTheme.labelLarge?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfigurationBottomSheet(
    BuildContext context,
    String metricName,
    String currentValue,
  ) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 32.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              Text(
                'Metric Drill-Down',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16.0),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.insights),
                title: const Text('Metric Name'),
                subtitle: Text(metricName),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.data_thresholding),
                title: const Text('Current Value'),
                subtitle: Text(currentValue),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.shield_outlined),
                title: const Text('Standard Reference'),
                subtitle: const Text('OWASP API Security Top 10'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.rule),
                title: const Text('Gateway Rule'),
                subtitle: const Text('Hardcoded rejection of unsigned payloads'),
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                height: 48.0, // 48x48dp touch target
                child: FilledButton.tonal(
                  onPressed: () => Navigator.of(bottomSheetContext).pop(),
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(height: 8.0),
            ],
          ),
        );
      },
    );
  }
}
