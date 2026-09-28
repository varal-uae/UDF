// GEN-03992 — API Fetch Latency Dashboard Metric Card.
// Displays dashboard metric API call latency status using M3 ElevatedCard with inline status chip, 48x48dp touch targets, and mock polling data.

import 'dart:async';
import 'package:flutter/material.dart';

enum _LatencyStatus { pass, fail }

class _MockLatencyRecord {
  final String traceId;
  final int latencyMs;
  final DateTime timestamp;
  final _LatencyStatus status;

  const _MockLatencyRecord({
    required this.traceId,
    required this.latencyMs,
    required this.timestamp,
    required this.status,
  });
}

class ApiLatencyCardGen03992 extends StatefulWidget {
  const ApiLatencyCardGen03992({super.key});

  @override
  State<ApiLatencyCardGen03992> createState() => _ApiLatencyCardGen03992State();
}

class _ApiLatencyCardGen03992State extends State<ApiLatencyCardGen03992> {
  late List<_MockLatencyRecord> _records;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _records = _generateMockData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  List<_MockLatencyRecord> _generateMockData() {
    final now = DateTime.now();
    return [
      _MockLatencyRecord(
        traceId: 'trace-001-gen-03992',
        latencyMs: 24,
        timestamp: now.subtract(const Duration(seconds: 10)),
        status: _LatencyStatus.pass,
      ),
      _MockLatencyRecord(
        traceId: 'trace-002-gen-03992',
        latencyMs: 142,
        timestamp: now.subtract(const Duration(seconds: 40)),
        status: _LatencyStatus.pass,
      ),
      _MockLatencyRecord(
        traceId: 'trace-003-gen-03992',
        latencyMs: 315,
        timestamp: now.subtract(const Duration(seconds: 70)),
        status: _LatencyStatus.fail,
      ),
      _MockLatencyRecord(
        traceId: 'trace-004-gen-03992',
        latencyMs: 18,
        timestamp: now.subtract(const Duration(seconds: 100)),
        status: _LatencyStatus.pass,
      ),
    ];
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _records = _generateMockData();
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

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
                'Dashboard Metric API Latency',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enterprise Portal SLA | Floor: < 300ms | Optimal: < 30ms',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (_isRefreshing)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: LinearProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                ),
              isMobile ? _buildSingleColumnLayout(theme) : _buildMultiColumnLayout(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSingleColumnLayout(ThemeData theme) {
    return Column(
      children: _records.map((record) => _buildMetricCard(record, theme)).toList(),
    );
  }

  Widget _buildMultiColumnLayout(ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: _records.length,
      itemBuilder: (context, index) => _buildMetricCard(_records[index], theme),
    );
  }

  Widget _buildMetricCard(_MockLatencyRecord record, ThemeData theme) {
    final isPass = record.status == _LatencyStatus.pass;
    final statusColor = isPass ? Colors.green : Colors.red;
    final statusLabel = isPass ? 'Pass' : 'Fail';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showDetailBottomSheet(record, theme),
          child: SizedBox(
            height: 48,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${record.latencyMs} ms',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          record.traceId,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: statusColor.withOpacity(0.12),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailBottomSheet(_MockLatencyRecord record, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      useMaterial3: true,
      showDragHandle: true,
      builder: (context) {
        final isPass = record.status == _LatencyStatus.pass;
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Metric Detail',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Trace ID', record.traceId, theme),
              _buildDetailRow('Latency', '${record.latencyMs} ms', theme),
              _buildDetailRow('Timestamp', record.timestamp.toIso8601String(), theme),
              _buildDetailRow(
                'Status',
                isPass ? 'Pass (< 300ms)' : 'Fail (>= 300ms)',
                theme,
                valueColor: isPass ? Colors.green : Colors.red,
              ),
              _buildDetailRow('Standard', 'Enterprise Portal SLA', theme),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Deep-link drill-down acknowledged.'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                  child: const Text('Drill Down'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
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
                fontWeight: FontWeight.w600,
                color: valueColor ?? theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}