// GEN-04069 — Local DB Initialization Configuration Status Card.
// Displays the completion state of local database initialization scripts using M3 Elevated Cards, status chips, and responsive single/multi-column layout with 30s polling.

import 'dart:async';
import 'package:flutter/material.dart';

enum _InitStatus { complete, notComplete, pending }

class _MockDbInitData {
  final String metricName;
  final _InitStatus status;
  final DateTime timestamp;
  final String sessionId;
  final double floorBoundary;
  final double optimalTarget;
  final double ceilingBoundary;

  const _MockDbInitData({
    required this.metricName,
    required this.status,
    required this.timestamp,
    required this.sessionId,
    required this.floorBoundary,
    required this.optimalTarget,
    required this.ceilingBoundary,
  });
}

class LocalDbInitConfigCardGen04069 extends StatefulWidget {
  const LocalDbInitConfigCardGen04069({super.key});

  @override
  State<LocalDbInitConfigCardGen04069> createState() => _LocalDbInitConfigCardGen04069State();
}

class _LocalDbInitConfigCardGen04069State extends State<LocalDbInitConfigCardGen04069> {
  late _MockDbInitData _data;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _data = _fetchMockData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  _MockDbInitData _fetchMockData() {
    return _MockDbInitData(
      metricName: 'Local DB Init Configuration',
      status: _InitStatus.complete,
      timestamp: DateTime.now(),
      sessionId: 'session_gen_04069_001',
      floorBoundary: 1.0,
      optimalTarget: 1.0,
      ceilingBoundary: 1.0,
    );
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      setState(() {
        _data = _fetchMockData();
        _isRefreshing = false;
      });
    }
  }

  Color _getStatusColor(BuildContext context, _InitStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case _InitStatus.complete:
        return colorScheme.primary;
      case _InitStatus.notComplete:
        return colorScheme.error;
      case _InitStatus.pending:
        return colorScheme.tertiary;
    }
  }

  String _getStatusText(_InitStatus status) {
    switch (status) {
      case _InitStatus.complete:
        return 'Complete';
      case _InitStatus.notComplete:
        return 'Not Complete';
      case _InitStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isDesktop = constraints.maxWidth >= 840;

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: isDesktop ? _buildMultiColumnLayout(context) : _buildSingleColumnLayout(context, isMobile),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSingleColumnLayout(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context),
        const SizedBox(height: 16),
        _buildElevatedCard(context),
        const SizedBox(height: 16),
        _buildMetricsCard(context),
        if (isMobile) ...[
          const SizedBox(height: 16),
          _buildActionButtons(context),
        ],
      ],
    );
  }

  Widget _buildMultiColumnLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildElevatedCard(context),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMetricsCard(context),
              const SizedBox(height: 16),
              _buildActionButtons(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Database Initialization', style: textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('GEN-04069 - Mobile DB Setup Standards', style: textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildElevatedCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(context, _data.status);

    // M3 Elevated Cards Level 2 (3dp elevation)
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _data.metricName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                // M3 Status Chips for health indicators
                Chip(
                  avatar: Icon(Icons.circle, size: 12, color: statusColor),
                  label: Text(_getStatusText(_data.status)),
                  backgroundColor: statusColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                  side: BorderSide.none,
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              'Open the mobile application\'s local database initialization configuration scripts.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  'Last updated: ${_data.timestamp.toString().substring(0, 19)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const Spacer(),
                if (_isRefreshing)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsCard(BuildContext context) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configuration Metrics', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            _buildMetricRow(context, 'Floor Boundary', _data.floorBoundary.toString()),
            _buildMetricRow(context, 'Optimal Target', _data.optimalTarget.toString()),
            _buildMetricRow(context, 'Ceiling Boundary', _data.ceilingBoundary.toString()),
            _buildMetricRow(context, 'Session ID', _data.sessionId),
            _buildMetricRow(context, 'Standard', 'Mobile DB Setup Standards'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 48x48dp touch targets
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: () => _showConfigBottomSheet(context),
            icon: const Icon(Icons.settings),
            label: const Text('View Configuration'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.sync),
            label: const Text('Manual Sync'),
          ),
        ),
      ],
    );
  }

  void _showConfigBottomSheet(BuildContext context) {
    // M3 Bottom Sheet for configuration inputs
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('DB Init Configuration Details', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Script Path',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
                readOnly: true,
                controller: TextEditingController(text: '/assets/db/init_scripts/'),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Reference Standard',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                ),
                readOnly: true,
                controller: TextEditingController(text: 'Mobile DB Setup Standards'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // M3 Snackbar for confirmations
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Configuration reviewed successfully.'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
                      ),
                    );
                  },
                  child: const Text('Confirm & Close'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}