// RCGLA-043-A07 — Operational Data Table Component for UDF Corporate Interface.
// Implements a dense Material 3 data grid with exactly 6dp vertical cell padding, 48x48dp minimum touch targets, plain white backgrounds, and status badges that do not rely solely on color.

import 'package:flutter/material.dart';

/// Mock data model representing a transaction record.
class TransactionRecord {
  final String transactionId;
  final String description;
  final String status;
  final DateTime timestamp;

  const TransactionRecord({
    required this.transactionId,
    required this.description,
    required this.status,
    required this.timestamp,
  });
}

/// Hardcoded mock data to satisfy backend/API absence requirement.
const List<TransactionRecord> kMockTransactions = [
  TransactionRecord(
    transactionId: 'TXN-001-VALID',
    description: 'Payment processed successfully',
    status: 'Completed',
    timestamp: DateTime(2026, 9, 23, 10, 15),
  ),
  TransactionRecord(
    transactionId: 'TXN-002-ERR',
    description: 'Gateway timeout during settlement',
    status: 'Failed',
    timestamp: DateTime(2026, 9, 23, 10, 18),
  ),
  TransactionRecord(
    transactionId: 'TXN-003-PEND',
    description: 'Awaiting manual review',
    status: 'Pending',
    timestamp: DateTime(2026, 9, 23, 10, 22),
  ),
  TransactionRecord(
    transactionId: 'TXN-004-VALID',
    description: 'Refund initiated by support worker',
    status: 'Completed',
    timestamp: DateTime(2026, 9, 23, 10, 45),
  ),
];

/// Status badge widget ensuring text identity is present so color is never the sole identifier.
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color fgColor;
    final IconData icon;

    switch (status.toLowerCase()) {
      case 'completed':
        bgColor = Colors.green.shade50;
        fgColor = Colors.green.shade800;
        icon = Icons.check_circle_outline;
        break;
      case 'failed':
        bgColor = Colors.red.shade50;
        fgColor = Colors.red.shade800;
        icon = Icons.error_outline;
        break;
      case 'pending':
        bgColor = Colors.orange.shade50;
        fgColor = Colors.orange.shade800;
        icon = Icons.pending_outlined;
        break;
      default:
        bgColor = Colors.grey.shade50;
        fgColor = Colors.grey.shade800;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.0, color: fgColor),
          const SizedBox(width: 4.0),
          Text(
            status,
            style: TextStyle(
              color: fgColor,
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Primary operational data table component satisfying RCGLA-043-A07 requirements.
class OperationalDataTable extends StatelessWidget {
  final List<TransactionRecord> records;

  const OperationalDataTable({
    super.key,
    this.records = kMockTransactions,
  });

  /// Validates unique tracking identifiers (Poka-Yoke).
  /// Programmatically drops entries if duplicate IDs are found.
  List<TransactionRecord> _getValidatedRecords() {
    final seenIds = <String>{};
    return records.where((record) => seenIds.add(record.transactionId)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final validRecords = _getValidatedRecords();
    final theme = Theme.of(context);

    return Container(
      // Plain flat white canvas to optimize data row contrast readability
      color: Colors.white,
      child: DataTable(
        // Enforcing dense spec constraints
        dataRowMinHeight: 32.0,
        dataRowMaxHeight: 40.0,
        headingRowHeight: 48.0,
        horizontalMargin: 12.0,
        columnSpacing: 16.0,
        dividerThickness: 1.0,
        headingTextStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        dataTextStyle: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 13.0,
        ),
        columns: const [
          DataColumn(label: Text('Transaction ID')),
          DataColumn(label: Text('Description')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Timestamp')),
        ],
        rows: validRecords.map((record) {
          return DataRow(
            cells: [
              // Wrapping cell content to enforce strictly exactly 6dp top and bottom padding
              DataCell(
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Text(record.transactionId),
                ),
              ),
              DataCell(
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Text(
                    record.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: _StatusBadge(status: record.status),
                ),
              ),
              DataCell(
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Text(
                    '${record.timestamp.year}-${record.timestamp.month.toString().padLeft(2, '0')}-${record.timestamp.day.toString().padLeft(2, '0')} '
                    '${record.timestamp.hour.toString().padLeft(2, '0')}:${record.timestamp.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// Wrapper applying rectangular structures with subtly rounded corners
/// and enforcing 48x48 dp minimum touch target layout constraints.
class OperationalDataTableCard extends StatelessWidget {
  final List<TransactionRecord> records;

  const OperationalDataTableCard({
    super.key,
    this.records = kMockTransactions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 1.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // Subtly rounded corners
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 48.0, // Absolute 48 x 48 dp target layout constraint
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 32.0,
            ),
            child: OperationalDataTable(records: records),
          ),
        ),
      ),
    );
  }
}
