// GEN-01897 — DCYN Base Class Boolean Validator.
// Validates Boolean data types natively within the DCYN base class with M3 status chips and mock compliance data.

import 'package:flutter/material.dart';

/// Core DCYN base class for native boolean validation.
class DcynBase {
  final String fieldName;
  final dynamic rawValue;

  const DcynBase({required this.fieldName, required this.rawValue});

  bool get isValidBoolean => rawValue is bool;

  bool? get parsedBoolean {
    if (rawValue is bool) return rawValue as bool;
    if (rawValue is String) {
      final lower = (rawValue as String).toLowerCase().trim();
      if (lower == 'true') return true;
      if (lower == 'false') return false;
    }
    if (rawValue is num) {
      if (rawValue == 1) return true;
      if (rawValue == 0) return false;
    }
    return null;
  }
}

/// Compliance record model.
class ComplianceRecord {
  final String traceId;
  final DateTime eventDate;
  final DcynBase field;
  final bool passed;

  const ComplianceRecord({
    required this.traceId,
    required this.eventDate,
    required this.field,
    required this.passed,
  });
}

/// Mock repository providing local data per requirement rule.
class MockComplianceRepository {
  static List<ComplianceRecord> fetchRecords() {
    final now = DateTime.now();
    return [
      ComplianceRecord(
        traceId: 'trace-001',
        eventDate: now.subtract(const Duration(hours: 1)),
        field: const DcynBase(fieldName: 'isActive', rawValue: true),
        passed: true,
      ),
      ComplianceRecord(
        traceId: 'trace-002',
        eventDate: now.subtract(const Duration(hours: 2)),
        field: const DcynBase(fieldName: 'isVerified', rawValue: 'false'),
        passed: true,
      ),
      ComplianceRecord(
        traceId: 'trace-003',
        eventDate: now.subtract(const Duration(hours: 3)),
        field: const DcynBase(fieldName: 'hasAccess', rawValue: 1),
        passed: true,
      ),
      ComplianceRecord(
        traceId: 'trace-004',
        eventDate: now.subtract(const Duration(hours: 4)),
        field: const DcynBase(fieldName: 'isDeleted', rawValue: 'invalid'),
        passed: false,
      ),
    ];
  }

  static double calculatePassRate(List<ComplianceRecord> records) {
    if (records.isEmpty) return 0.0;
    final passedCount = records.where((r) => r.passed).length;
    return (passedCount / records.length) * 100.0;
  }
}

/// Screen implementing M3 responsive layout for GEN-01897.
class DcynBooleanValidatorScreen extends StatefulWidget {
  const DcynBooleanValidatorScreen({super.key});

  @override
  State<DcynBooleanValidatorScreen> createState() => _DcynBooleanValidatorScreenState();
}

class _DcynBooleanValidatorScreenState extends State<DcynBooleanValidatorScreen> {
  late List<ComplianceRecord> _records;
  late double _passRate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _records = MockComplianceRepository.fetchRecords();
    _passRate = MockComplianceRepository.calculatePassRate(_records);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 840;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GEN-01897: DCYN Boolean Validation'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadData();
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: isDesktop ? _buildMultiColumnLayout() : _buildSingleColumnLayout(),
        ),
      ),
    );
  }

  Widget _buildSingleColumnLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildKpiCard(),
        const SizedBox(height: 16),
        ..._records.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildRecordCard(r),
        )),
      ],
    );
  }

  Widget _buildMultiColumnLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 1, child: _buildKpiCard()),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _records.map((r) => SizedBox(
              width: 380,
              child: _buildRecordCard(r),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard() {
    final meetsThreshold = _passRate >= 98.0;
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Compliance Gate Pass Rate (%)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_passRate.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: meetsThreshold ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
                Chip(
                  label: Text(meetsThreshold ? 'PASS' : 'FAIL'),
                  backgroundColor: meetsThreshold ? Colors.green.shade50 : Colors.red.shade50,
                  labelStyle: TextStyle(
                    color: meetsThreshold ? Colors.green.shade800 : Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'ISO/IEC 27001:2022 Standard | Floor: 98%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(ComplianceRecord record) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetailsSheet(record),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.field.fieldName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Raw: ${record.field.rawValue} | Parsed: ${record.field.parsedBoolean}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Trace: ${record.traceId}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Chip(
                avatar: Icon(
                  record.passed ? Icons.check_circle_outline : Icons.error_outline,
                  size: 18,
                  color: record.passed ? Colors.green : Colors.red,
                ),
                label: Text(record.passed ? 'Valid' : 'Invalid'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailsSheet(ComplianceRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Validation Details', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _detailRow('Field Name', record.field.fieldName),
              _detailRow('Raw Value', record.field.rawValue.toString()),
              _detailRow('Is Valid Boolean', record.field.isValidBoolean.toString()),
              _detailRow('Parsed Boolean', record.field.parsedBoolean.toString()),
              _detailRow('Trace ID', record.traceId),
              _detailRow('Event Date', record.eventDate.toIso8601String()),
              _detailRow('Status', record.passed ? 'PASS' : 'FAIL'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Acknowledged ${record.field.fieldName}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Acknowledge'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
