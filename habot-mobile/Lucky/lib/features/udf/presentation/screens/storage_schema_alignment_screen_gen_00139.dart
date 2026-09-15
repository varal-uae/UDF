// GEN-00139 — Local Storage Schemas & Mobile ED Data Contracts Alignment Screen.
// Responsive M3 engineering console screen providing continuous validation of local storage
// schemas against mobile Event-Driven (ED) data contracts with automated polling and drill-down metrics.

import 'dart:async';
import 'package:flutter/material.dart';

/// Completion status classification for schema contracts.
enum SchemaVerificationStatus {
  complete,
  partial,
  notComplete,
}

/// Data model representing a local storage schema contract alignment record.
class StorageSchemaContractRecord {
  final String schemaId;
  final String entityName;
  final String mobileEdVersion;
  final String localStoreVersion;
  final int mappedFieldsCount;
  final int totalContractFieldsCount;
  final SchemaVerificationStatus status;
  final DateTime lastChecked;
  final String notes;

  const StorageSchemaContractRecord({
    required this.schemaId,
    required this.entityName,
    required this.mobileEdVersion,
    required this.localStoreVersion,
    required this.mappedFieldsCount,
    required this.totalContractFieldsCount,
    required this.status,
    required this.lastChecked,
    required this.notes,
  });

  bool get isFullyAligned =>
      status == SchemaVerificationStatus.complete &&
      mappedFieldsCount == totalContractFieldsCount;

  double get alignmentRatio => totalContractFieldsCount == 0
      ? 1.0
      : (mappedFieldsCount / totalContractFieldsCount).clamp(0.0, 1.0);
}

/// Main Screen for GEN-00139 schema verification console.
class StorageSchemaAlignmentScreenGen00139 extends StatefulWidget {
  const StorageSchemaAlignmentScreenGen00139({super.key});

  @override
  State<StorageSchemaAlignmentScreenGen00139> createState() =>
      _StorageSchemaAlignmentScreenGen00139State();
}

class _StorageSchemaAlignmentScreenGen00139State
    extends State<StorageSchemaAlignmentScreenGen00139> {
  Timer? _pollingTimer;
  bool _isLoading = false;
  DateTime _lastSyncTime = DateTime.now();

  List<StorageSchemaContractRecord> _schemaRecords = [
    StorageSchemaContractRecord(
      schemaId: 'ED-LOCAL-001',
      entityName: 'UserSessionState',
      mobileEdVersion: 'v2.4.0',
      localStoreVersion: 'v2.4.0',
      mappedFieldsCount: 18,
      totalContractFieldsCount: 18,
      status: SchemaVerificationStatus.complete,
      lastChecked: DateTime.now().subtract(const Duration(minutes: 2)),
      notes: 'Fully aligned with mobile event pipeline definition.',
    ),
    StorageSchemaContractRecord(
      schemaId: 'ED-LOCAL-002',
      entityName: 'OfflineWorkflowQueue',
      mobileEdVersion: 'v3.1.0',
      localStoreVersion: 'v3.0.8',
      mappedFieldsCount: 14,
      totalContractFieldsCount: 16,
      status: SchemaVerificationStatus.partial,
      lastChecked: DateTime.now().subtract(const Duration(minutes: 4)),
      notes: 'Missing transient idempotency_key and retry_count fields in local SQLite table.',
    ),
    StorageSchemaContractRecord(
      schemaId: 'ED-LOCAL-003',
      entityName: 'TelemetryTraceBuffer',
      mobileEdVersion: 'v1.8.2',
      localStoreVersion: 'v1.8.2',
      mappedFieldsCount: 9,
      totalContractFieldsCount: 9,
      status: SchemaVerificationStatus.complete,
      lastChecked: DateTime.now().subtract(const Duration(minutes: 1)),
      notes: 'All trace_id and partition headers matched to BigQuery export spec.',
    ),
    StorageSchemaContractRecord(
      schemaId: 'ED-LOCAL-004',
      entityName: 'FormDraftSnapshot',
      mobileEdVersion: 'v2.0.0',
      localStoreVersion: 'v1.2.0',
      mappedFieldsCount: 5,
      totalContractFieldsCount: 12,
      status: SchemaVerificationStatus.notComplete,
      lastChecked: DateTime.now().subtract(const Duration(minutes: 7)),
      notes: 'Pending major migration schema sync. Local cache requires migration script.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startLivenessHandshake();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // Blueprint: Start automated 30-second background polling cycle.
  void _startLivenessHandshake() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshSchemas(silent: true);
    });
  }

  // Blueprint: Refresh schema verification data from local contract engine.
  Future<void> _refreshSchemas({bool silent = false}) async {
    if (!silent) {
      setState(() => _isLoading = true);
    }

    await Future<void>.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;

    setState(() {
      _lastSyncTime = DateTime.now();
      _isLoading = false;
      _schemaRecords = _schemaRecords.map((item) {
        return StorageSchemaContractRecord(
          schemaId: item.schemaId,
          entityName: item.entityName,
          mobileEdVersion: item.mobileEdVersion,
          localStoreVersion: item.localStoreVersion,
          mappedFieldsCount: item.mappedFieldsCount,
          totalContractFieldsCount: item.totalContractFieldsCount,
          status: item.status,
          lastChecked: DateTime.now(),
          notes: item.notes,
        );
      }).toList();
    });

    if (!silent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Schema alignment contracts refreshed successfully.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Blueprint: Inspect contract drill-down details via M3 Modal Bottom Sheet.
  void _showContractDetails(StorageSchemaContractRecord item) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                item.entityName,
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Contract ID: ${item.schemaId}',
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('ED Contract Version', item.mobileEdVersion),
              _buildDetailRow('Local Store Schema', item.localStoreVersion),
              _buildDetailRow(
                'Field Parity',
                '${item.mappedFieldsCount} / ${item.totalContractFieldsCount} fields',
              ),
              _buildDetailRow('Verification State', _formatStatus(item.status)),
              _buildDetailRow('Last Verified', item.lastChecked.toIso8601String()),
              const SizedBox(height: 16),
              Text(
                'Engineering Notes:',
                style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(item.notes, style: textTheme.bodyMedium),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.tonal(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close Details'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _formatStatus(SchemaVerificationStatus status) {
    switch (status) {
      case SchemaVerificationStatus.complete:
        return 'Complete';
      case SchemaVerificationStatus.partial:
        return 'Partial';
      case SchemaVerificationStatus.notComplete:
        return 'Not Complete';
    }
  }

  Color _statusColor(SchemaVerificationStatus status, ColorScheme colorScheme) {
    switch (status) {
      case SchemaVerificationStatus.complete:
        return colorScheme.primary;
      case SchemaVerificationStatus.partial:
        return colorScheme.tertiary;
      case SchemaVerificationStatus.notComplete:
        return colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final completedCount = _schemaRecords
        .where((r) => r.status == SchemaVerificationStatus.complete)
        .length;
    final totalCount = _schemaRecords.length;
    final overallPercentage = ((completedCount / totalCount) * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Storage ED Alignment'),
        actions: [
          IconButton(
            tooltip: 'Manual Sync',
            icon: const Icon(Icons.sync),
            onPressed: () => _refreshSchemas(silent: false),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshSchemas(silent: false),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 840;
            final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 840;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top KPI Summary Card
                  Card(
                    elevation: 3.0,
                    color: colorScheme.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'GEN-00139 Health Dashboard',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Chip(
                                avatar: Icon(
                                  overallPercentage == 100
                                      ? Icons.check_circle
                                      : Icons.warning_amber_rounded,
                                  color: overallPercentage == 100
                                      ? colorScheme.primary
                                      : colorScheme.tertiary,
                                  size: 18,
                                ),
                                label: Text('$overallPercentage% Aligned'),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Metric: Requirements Definition Completeness (Gate 2020 DoD).',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: completedCount / totalCount,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Compliant: $completedCount of $totalCount Schemas',
                                style: textTheme.bodySmall,
                              ),
                              Text(
                                'Last Polled: ${_lastSyncTime.hour.toString().padLeft(2, '0')}:${_lastSyncTime.minute.toString().padLeft(2, '0')}:${_lastSyncTime.second.toString().padLeft(2, '0')}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Local Storage Data Contracts',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Responsive Grid / List layout
                  if (isDesktop)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.4,
                      ),
                      itemCount: _schemaRecords.length,
                      itemBuilder: (context, index) =>
                          _buildSchemaCard(_schemaRecords[index], colorScheme, textTheme),
                    )
                  else if (isTablet)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: _schemaRecords.length,
                      itemBuilder: (context, index) =>
                          _buildSchemaCard(_schemaRecords[index], colorScheme, textTheme),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _schemaRecords.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _buildSchemaCard(_schemaRecords[index], colorScheme, textTheme),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Blueprint: Render schema alignment card with touch target >= 48x48 and M3 styling.
  Widget _buildSchemaCard(
    StorageSchemaContractRecord item,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final statusColor = _statusColor(item.status, colorScheme);

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: item.status == SchemaVerificationStatus.complete
              ? colorScheme.outlineVariant
              : statusColor.withOpacity(0.4),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showContractDetails(item),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.entityName,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item.schemaId,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    backgroundColor: statusColor.withOpacity(0.12),
                    side: BorderSide(color: statusColor.withOpacity(0.4)),
                    label: Text(
                      _formatStatus(item.status),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contract Parity: ${item.mappedFieldsCount}/${item.totalContractFieldsCount} fields',
                          style: textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: item.alignmentRatio,
                          color: statusColor,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ED: ${item.mobileEdVersion} | Local: ${item.localStoreVersion}',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  // Ensured 48x48dp minimum touch target
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward, size: 20),
                      onPressed: () => _showContractDetails(item),
                      tooltip: 'View Details',
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
}
