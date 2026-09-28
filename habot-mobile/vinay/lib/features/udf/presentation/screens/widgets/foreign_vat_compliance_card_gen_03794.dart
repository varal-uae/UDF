// GEN-03794 — Automated Foreign VAT Conversion Engine and Mobile Cross-Border Compliance UI.
// M3 Elevated Card displaying step completion state with background polling, pull-to-refresh, and deep-link drill-down.

import 'dart:async';
import 'package:flutter/material.dart';

enum ComplianceStatus { complete, notComplete, pending }

class ForeignVatComplianceData {
  final String traceId;
  final String deliverableName;
  final ComplianceStatus status;
  final DateTime timestamp;
  final double apiLatencyMs;

  const ForeignVatComplianceData({
    required this.traceId,
    required this.deliverableName,
    required this.status,
    required this.timestamp,
    required this.apiLatencyMs,
  });
}

class MockForeignVatRepository {
  static const List<ForeignVatComplianceData> _mockData = [
    ForeignVatComplianceData(
      traceId: 'trace-gen-03794-001',
      deliverableName: 'Automated Foreign VAT Conversion Engine',
      status: ComplianceStatus.complete,
      timestamp: DateTime(2026, 9, 28, 10, 0),
      apiLatencyMs: 45.2,
    ),
    ForeignVatComplianceData(
      traceId: 'trace-gen-03794-002',
      deliverableName: 'Mobile Cross-Border Compliance UI',
      status: ComplianceStatus.pending,
      timestamp: DateTime(2026, 9, 28, 10, 5),
      apiLatencyMs: 62.1,
    ),
  ];

  Future<List<ForeignVatComplianceData>> fetchComplianceData() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _mockData;
  }
}

class ForeignVatComplianceCard extends StatefulWidget {
  const ForeignVatComplianceCard({super.key});

  @override
  State<ForeignVatComplianceCard> createState() => _ForeignVatComplianceCardState();
}

class _ForeignVatComplianceCardState extends State<ForeignVatComplianceCard> {
  final MockForeignVatRepository _repository = MockForeignVatRepository();
  List<ForeignVatComplianceData> _data = [];
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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final result = await _repository.fetchComplianceData();
      if (mounted) {
        setState(() {
          _data = result;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadData();
    });
  }

  Future<void> _onRefresh() async {
    await _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Compliance data synchronized'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Color _getStatusColor(ComplianceStatus status, ColorScheme colorScheme) {
    switch (status) {
      case ComplianceStatus.complete:
        return colorScheme.primary;
      case ComplianceStatus.notComplete:
        return colorScheme.error;
      case ComplianceStatus.pending:
        return colorScheme.tertiary;
    }
  }

  String _getStatusLabel(ComplianceStatus status) {
    switch (status) {
      case ComplianceStatus.complete:
        return 'Complete';
      case ComplianceStatus.notComplete:
        return 'Not Complete';
      case ComplianceStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: colorScheme.primary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 840;
          final crossAxisCount = isDesktop ? 2 : 1;

          if (_isLoading && _data.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: isDesktop ? 3.0 : 2.5,
            ),
            itemCount: _data.length,
            itemBuilder: (context, index) {
              final item = _data[index];
              return Semantics(
                label: '${item.deliverableName}, Status: ${_getStatusLabel(item.status)}',
                button: true,
                child: _buildElevatedCard(item, theme, colorScheme),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildElevatedCard(
    ForeignVatComplianceData item,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showBottomSheet(context, item, theme),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.deliverableName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Chip(
                    label: Text(
                      _getStatusLabel(item.status),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: _getStatusColor(item.status, colorScheme),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${item.apiLatencyMs.toStringAsFixed(1)}ms',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.link, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Drill-down',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
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

  void _showBottomSheet(
    BuildContext context,
    ForeignVatComplianceData item,
    ThemeData theme,
  ) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuration Details',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Trace ID', item.traceId, theme),
              _buildDetailRow('Deliverable', item.deliverableName, theme),
              _buildDetailRow('Status', _getStatusLabel(item.status), theme),
              _buildDetailRow('API Latency', '${item.apiLatencyMs.toStringAsFixed(1)}ms', theme),
              _buildDetailRow('Timestamp', item.timestamp.toIso8601String(), theme),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}