// RCGLA-036-A13 — High-Density Grid Layout for Audit Logs.
// Implements a responsive, monospaced data grid with row highlighting, vertical stacking on mobile, and ellipsis overflow handling for audit verification.

import 'package:flutter/material.dart';

/// Represents a single atomic execution step in the audit log.
class AuditLogEntry {
  final String stepExecutionId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final double balanceAmount;

  const AuditLogEntry({
    required this.stepExecutionId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.balanceAmount,
  });
}

/// Mock data repository simulating BigQuery flat log fetches.
class MockAuditLogRepository {
  static List<AuditLogEntry> getMockLogs() {
    return List.generate(
      50,
      (index) => AuditLogEntry(
        stepExecutionId: 'STEP-${1000 + index}',
        executionStatus: index % 7 == 0 ? 'FAILED' : 'PASSED',
        executionTimestamp: DateTime(2026, 9, 23).subtract(Duration(hours: index)),
        stepOutcome: index % 7 == 0 ? 'Variance detected in ledger total' : 'Reconciled successfully',
        userId: 'USR-${(index % 5) + 1}',
        balanceAmount: 10000.00 + (index * 123.45),
      ),
    );
  }
}

/// High-density data grid layout template for the Immutable Audit History console.
class HighDensityAuditGrid extends StatefulWidget {
  const HighDensityAuditGrid({super.key});

  @override
  State<HighDensityAuditGrid> createState() => _HighDensityAuditGridState();
}

class _HighDensityAuditGridState extends State<HighDensityAuditGrid> {
  late final List<AuditLogEntry> _logs;
  int? _selectedRowIndex;

  @override
  void initState() {
    super.initState();
    _logs = MockAuditLogRepository.getMockLogs();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        return isMobile ? _buildMobileCards() : _buildDesktopGrid();
      },
    );
  }

  /// Mobile layout: Long multi-column data verification blocks stack vertically into clean digest cards.
  Widget _buildMobileCards() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        final entry = _logs[index];
        final bool isSelected = _selectedRowIndex == index;
        final bool isFailed = entry.executionStatus == 'FAILED';

        return GestureDetector(
          onTap: () => setState(() => _selectedRowIndex = isSelected ? null : index),
          child: Card(
            margin: const EdgeInsets.only(bottom: 8.0),
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                : isFailed
                    ? Theme.of(context).colorScheme.errorContainer.withOpacity(0.1)
                    : null,
            elevation: isSelected ? 2.0 : 0.5,
            child: Padding(
              padding: const EdgeInsets.all(12.0), // Comfortable layout padding to avoid crowding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.stepExecutionId,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (isFailed)
                        Text(
                          entry.executionStatus,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                              ),
                        )
                      else
                        Text(
                          entry.executionStatus,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontFamily: 'monospace',
                              ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Time: ${entry.executionTimestamp.toIso8601String()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'User: ${entry.userId}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 8.0),
                  // Ellipsis tail forcing touch expand on long outcomes
                  Text(
                    entry.stepOutcome,
                    maxLines: isSelected ? null : 2,
                    overflow: isSelected ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          color: isFailed ? Theme.of(context).colorScheme.error : null,
                        ),
                  ),
                  const Divider(height: 16.0),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      entry.balanceAmount.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w800, // Explicit text weight prioritizing active balances
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Desktop layout: Highly dense Material grid template built for lightning-fast vertical eye scanning.
  Widget _buildDesktopGrid() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        child: DataTable(
          headingRowHeight: 40.0, // Standardized line-height parameters
          dataRowMinHeight: 32.0, // High density
          dataRowMaxHeight: 32.0,
          columnSpacing: 24.0,
          columns: const [
            DataColumn(label: Text('Step ID', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Timestamp', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Outcome', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold))),
            DataColumn(label: Text('User ID', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Balance', numeric: true, style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold))),
          ],
          rows: List.generate(_logs.length, (index) {
            final entry = _logs[index];
            final bool isSelected = _selectedRowIndex == index;
            final bool isFailed = entry.executionStatus == 'FAILED';

            return DataRow(
              selected: isSelected,
              onSelectChanged: (_) => setState(() => _selectedRowIndex = isSelected ? null : index),
              color: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3);
                }
                if (isFailed) {
                  return Theme.of(context).colorScheme.errorContainer.withOpacity(0.1);
                }
                // Subtle Material row backgrounds to assist reading tracking
                return index.isEven ? Colors.grey.withOpacity(0.05) : null;
              }),
              cells: [
                DataCell(Text(entry.stepExecutionId, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
                DataCell(
                  Text(
                    entry.executionStatus,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: isFailed ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                      fontWeight: isFailed ? FontWeight.w900 : FontWeight.normal, // Contrasting error typography
                    ),
                  ),
                ),
                DataCell(Text(entry.executionTimestamp.toIso8601String(), style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
                DataCell(
                  SizedBox(
                    width: 250,
                    child: Text(
                      entry.stepOutcome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Self-chasing ellipsis tail
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: isFailed ? Theme.of(context).colorScheme.error : null,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(entry.userId, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
                DataCell(
                  Align(
                    alignment: Alignment.centerRight, // Monospaced right-alignment locking decimals
                    child: Text(
                      entry.balanceAmount.toStringAsFixed(2),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.w800, // Prioritize active balance numbers
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
