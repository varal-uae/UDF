// GEN-03629 — Audit Payload Schema Standardization Status Card.
// Displays the audit log payload standardization compliance status using M3 Elevated Cards, Status Chips, and responsive single/multi-column layout with 30s polling and pull-to-refresh.

import 'dart:async';
import 'package:flutter/material.dart';

enum AuditStandardizationStatus { pass, fail, pending }

class AuditPayloadMockData {
  final String globalReferenceId;
  final String metricName;
  final AuditStandardizationStatus status;
  final String referenceStandard;
  final DateTime lastChecked;
  final double floorBoundary;
  final double optimalTarget;
  final double ceilingBoundary;

  const AuditPayloadMockData({
    required this.globalReferenceId,
    required this.metricName,
    required this.status,
    required this.referenceStandard,
    required this.lastChecked,
    required this.floorBoundary,
    required this.optimalTarget,
    required this.ceilingBoundary,
  });
}

class AuditPayloadStatusCardGen03629 extends StatefulWidget {
  const AuditPayloadStatusCardGen03629({super.key});

  @override
  State<AuditPayloadStatusCardGen03629> createState() => _AuditPayloadStatusCardGen03629State();
}

class _AuditPayloadStatusCardGen03629State extends State<AuditPayloadStatusCardGen03629> {
  late List<AuditPayloadMockData> _mockData;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadMockData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _loadMockData() {
    _mockData = [
      AuditPayloadMockData(
        globalReferenceId: 'GEN-03629',
        metricName: 'Audit Payload Schema Standardization',
        status: AuditStandardizationStatus.pass,
        referenceStandard: 'ISO/IEC 27001 Audit Logging Standards',
        lastChecked: DateTime.now(),
        floorBoundary: 1.0,
        optimalTarget: 1.0,
        ceilingBoundary: 1.0,
      ),
      AuditPayloadMockData(
        globalReferenceId: 'GEN-03628',
        metricName: 'Audit Log Retention Policy',
        status: AuditStandardizationStatus.pass,
        referenceStandard: 'ISO/IEC 27001 Audit Logging Standards',
        lastChecked: DateTime.now().subtract(const Duration(minutes: 5)),
        floorBoundary: 1.0,
        optimalTarget: 1.0,
        ceilingBoundary: 1.0,
      ),
    ];
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {
          _loadMockData();
        });
      }
    });
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _loadMockData();
        _isRefreshing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Audit payload status synchronized'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Color _getStatusColor(AuditStandardizationStatus status, ThemeData theme) {
    switch (status) {
      case AuditStandardizationStatus.pass:
        return theme.colorScheme.primary;
      case AuditStandardizationStatus.fail:
        return theme.colorScheme.error;
      case AuditStandardizationStatus.pending:
        return theme.colorScheme.tertiary;
    }
  }

  String _getStatusLabel(AuditStandardizationStatus status) {
    switch (status) {
      case AuditStandardizationStatus.pass:
        return 'Pass';
      case AuditStandardizationStatus.fail:
        return 'Fail';
      case AuditStandardizationStatus.pending:
        return 'Pending';
    }
  }

  IconData _getStatusIcon(AuditStandardizationStatus status) {
    switch (status) {
      case AuditStandardizationStatus.pass:
        return Icons.check_circle_outline_rounded;
      case AuditStandardizationStatus.fail:
        return Icons.error_outline_rounded;
      case AuditStandardizationStatus.pending:
        return Icons.hourglass_empty_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 840;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: theme.colorScheme.primary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (isDesktop) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.4,
              ),
              itemCount: _mockData.length,
              itemBuilder: (context, index) => _buildCard(_mockData[index], theme),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _mockData.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildCard(_mockData[index], theme),
          );
        },
      ),
    );
  }

  Widget _buildCard(AuditPayloadMockData data, ThemeData theme) {
    final statusColor = _getStatusColor(data.status, theme);

    return InkWell(
      onTap: () => _showDetailBottomSheet(data, theme),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      data.metricName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Chip(
                    avatar: Icon(
                      _getStatusIcon(data.status),
                      size: 18,
                      color: statusColor,
                    ),
                    label: Text(
                      _getStatusLabel(data.status),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: statusColor.withOpacity(0.1),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Ref ID: ${data.globalReferenceId}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Standard: ${data.referenceStandard}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: theme.colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    'Last checked: ${_formatTime(data.lastChecked)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
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

  void _showDetailBottomSheet(AuditPayloadMockData data, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    data.metricName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Global Reference ID', data.globalReferenceId, theme),
                  _buildDetailRow('Status', _getStatusLabel(data.status), theme),
                  _buildDetailRow('Reference Standard', data.referenceStandard, theme),
                  _buildDetailRow('Floor Boundary', data.floorBoundary.toString(), theme),
                  _buildDetailRow('Optimal Target', data.optimalTarget.toString(), theme),
                  _buildDetailRow('Ceiling Boundary', data.ceilingBoundary.toString(), theme),
                  _buildDetailRow('Last Checked', _formatTime(data.lastChecked), theme),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Deep-link drill-down initiated'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_new, size: 20),
                    label: const Text('View Full Audit Report'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
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
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} $h:$m:$s';
  }
}
