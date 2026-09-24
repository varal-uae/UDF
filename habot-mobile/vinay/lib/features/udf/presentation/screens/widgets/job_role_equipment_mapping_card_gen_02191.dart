// GEN-02191 — Job Role to Equipment Schema Mapping Console Card.
// Displays read-only M3 KPI status cards for schema/lineage validation pass rate with deep-link drill-down, single-column mobile layout, and background polling every 30 seconds.

import 'dart:async';
import 'package:flutter/material.dart';

enum ValidationStatus { pass, fail }

class SchemaValidationRecord {
  final String jobRole;
  final String equipmentSchema;
  final ValidationStatus status;
  final double passRate;
  final DateTime timestamp;
  final String traceId;

  const SchemaValidationRecord({
    required this.jobRole,
    required this.equipmentSchema,
    required this.status,
    required this.passRate,
    required this.timestamp,
    required this.traceId,
  });
}

class MockSchemaValidationRepository {
  static const List<SchemaValidationRecord> records = [
    SchemaValidationRecord(
      jobRole: 'Field Technician',
      equipmentSchema: 'HVAC-DIAG-V2',
      status: ValidationStatus.pass,
      passRate: 0.998,
      timestamp: DateTime(2026, 9, 24, 10, 15),
      traceId: 'trace-001-gen-02191',
    ),
    SchemaValidationRecord(
      jobRole: 'Safety Inspector',
      equipmentSchema: 'PPE-CHECK-V1',
      status: ValidationStatus.pass,
      passRate: 0.975,
      timestamp: DateTime(2026, 9, 24, 10, 16),
      traceId: 'trace-002-gen-02191',
    ),
    SchemaValidationRecord(
      jobRole: 'Heavy Operator',
      equipmentSchema: 'CRANE-OPS-V3',
      status: ValidationStatus.fail,
      passRate: 0.820,
      timestamp: DateTime(2026, 9, 24, 10, 17),
      traceId: 'trace-003-gen-02191',
    ),
  ];

  Future<List<SchemaValidationRecord>> fetchRecords() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return records;
  }
}

class JobRoleEquipmentMappingCardGen02191 extends StatefulWidget {
  const JobRoleEquipmentMappingCardGen02191({super.key});

  @override
  State<JobRoleEquipmentMappingCardGen02191> createState() => _JobRoleEquipmentMappingCardGen02191State();
}

class _JobRoleEquipmentMappingCardGen02191State extends State<JobRoleEquipmentMappingCardGen02191> {
  final MockSchemaValidationRepository _repository = MockSchemaValidationRepository();
  List<SchemaValidationRecord> _records = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadData());
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _repository.fetchRecords();
      if (mounted) {
        setState(() {
          _records = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Engineering Console'),
        centerTitle: false,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final crossAxisCount = isMobile ? 1 : (constraints.maxWidth >= 840 ? 3 : 2);

            if (_isLoading && _records.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schema/Lineage Validation Pass Rate',
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ISO/IEC 25012 Data Quality Model | Floor: 95% | Target: 99.9%',
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      childAspectRatio: isMobile ? 2.8 : 2.2,
                    ),
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final record = _records[index];
                      return _buildElevatedStatusCard(context, record);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildElevatedStatusCard(BuildContext context, SchemaValidationRecord record) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPass = record.status == ValidationStatus.pass;
    final chipColor = isPass ? colorScheme.primaryContainer : colorScheme.errorContainer;
    final chipText = isPass ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer;

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        onTap: () => _showDrillDownBottomSheet(context, record),
        borderRadius: BorderRadius.circular(16.0),
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
                      record.jobRole,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: chipColor,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      isPass ? 'PASS' : 'FAIL',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: chipText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Schema: ${record.equipmentSchema}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rate: ${(record.passRate * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDrillDownBottomSheet(BuildContext context, SchemaValidationRecord record) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
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
                    color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Configuration Details', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              _buildDetailRow('Job Role', record.jobRole),
              _buildDetailRow('Equipment Schema', record.equipmentSchema),
              _buildDetailRow('Validation Status', record.status.name.toUpperCase()),
              _buildDetailRow('Pass Rate', '${(record.passRate * 100).toStringAsFixed(2)}%'),
              _buildDetailRow('Timestamp', record.timestamp.toIso8601String()),
              _buildDetailRow('Trace ID', record.traceId),
              _buildDetailRow('Standard', 'ISO/IEC 25012 Data Quality Model'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48, // 48x48dp touch targets
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Sync confirmed for ${record.traceId}'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  },
                  child: const Text('Acknowledge & Sync'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}