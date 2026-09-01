/// COMPLIANCE METADATA BLOCK
/// - Step Execution ID: HC-IAM-0107-LOG-2026
/// - Execution Status: Executed / Active
/// - Execution Timestamp: 2026-08-18T10:10:00Z
/// - Step Outcome: Structurally Read-Only UI Enforced
/// - User ID: SEC-ADMIN-8821
/// - Schema Design Compliance Rate: Target: Complete - 100% compliant with DAMA-DMBOK Data Modelling standards
library;

import 'package:flutter/material.dart';

/// Data model representing a read-only audit log record.
class LogEntry {
  final String stepExecutionId;
  final String timestamp;
  final String status;
  final String userId;
  final String stepOutcome;
  final String payloadHash;

  const LogEntry({
    required this.stepExecutionId,
    required this.timestamp,
    required this.status,
    required this.userId,
    required this.stepOutcome,
    required this.payloadHash,
  });
}

/// HC-IAM-0107: Protected Analytical Logs
///
/// Strictly enforces Append-Only UI rules by physically omitting any mutating
/// interactive controls (e.g., Edit/Delete buttons, Slidables, PopupMenuButtons).
class ProtectedAnalyticalLogs extends StatefulWidget {
  const ProtectedAnalyticalLogs({super.key});

  @override
  State<ProtectedAnalyticalLogs> createState() =>
      _ProtectedAnalyticalLogsState();
}

class _ProtectedAnalyticalLogsState extends State<ProtectedAnalyticalLogs> {
  final List<LogEntry> _allLogs = const [
    LogEntry(
      stepExecutionId: 'EXEC-2026-0818-0001',
      timestamp: '2026-08-18 09:15:22 UTC',
      status: 'SUCCESS',
      userId: 'USR-SEC-9901',
      stepOutcome: 'VERIFIED_DIGITAL_SIGNATURE',
      payloadHash: '0x8f4b23a9...e10d',
    ),
    LogEntry(
      stepExecutionId: 'EXEC-2026-0818-0002',
      timestamp: '2026-08-18 09:20:45 UTC',
      status: 'COMPLETED',
      userId: 'USR-AUDIT-4412',
      stepOutcome: 'APPENDED_LEDGER_RECORD',
      payloadHash: '0x3c11a49e...b981',
    ),
    LogEntry(
      stepExecutionId: 'EXEC-2026-0818-0003',
      timestamp: '2026-08-18 09:35:10 UTC',
      status: 'WARNING',
      userId: 'USR-SEC-9901',
      stepOutcome: 'SCHEMA_VALIDATION_PASSED',
      payloadHash: '0x99a22df1...440c',
    ),
    LogEntry(
      stepExecutionId: 'EXEC-2026-0818-0004',
      timestamp: '2026-08-18 09:48:02 UTC',
      status: 'COMPLETED',
      userId: 'USR-SYSTEM-001',
      stepOutcome: 'HASH_CHAIN_RECONSIDERATION',
      payloadHash: '0x12b557c8...a77e',
    ),
    LogEntry(
      stepExecutionId: 'EXEC-2026-0818-0005',
      timestamp: '2026-08-18 10:02:18 UTC',
      status: 'SUCCESS',
      userId: 'USR-AUDIT-4412',
      stepOutcome: 'IMMUTABLE_SNAPSHOT_CREATED',
      payloadHash: '0x550a19d2...ff34',
    ),
  ];

  String _filterQuery = '';

  List<LogEntry> get _filteredLogs {
    if (_filterQuery.isEmpty) return _allLogs;
    final q = _filterQuery.toLowerCase();
    return _allLogs.where((log) {
      return log.stepExecutionId.toLowerCase().contains(q) ||
          log.userId.toLowerCase().contains(q) ||
          log.status.toLowerCase().contains(q) ||
          log.stepOutcome.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Monospace style for administrative scannability
    const monospaceStyle = TextStyle(
      fontFamily: 'RobotoMono',
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Protected Analytical Logs'),
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Trust Marker: Prominent Banner explicitly stating Append-Only rule
          MaterialBanner(
            elevation: 1,
            leading: Icon(
              Icons.shield_outlined,
              color: colorScheme.primary,
              size: 28,
            ),
            content: Text(
              'Protected Table: Append-Only Immutable Records',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            actions: [
              Chip(
                avatar: const Icon(Icons.lock, size: 16),
                label: const Text(
                  'STRUCTURALLY READ-ONLY',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                backgroundColor: colorScheme.primaryContainer,
                side: BorderSide.none,
              ),
            ],
          ),

          // Read-Only Search Filter Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => setState(() => _filterQuery = val),
              decoration: InputDecoration(
                hintText: 'Search analytical logs by ID, status, or user...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),

          // Main Responsive Area
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth <= 600;

                if (_filteredLogs.isEmpty) {
                  return const Center(
                    child: Text('No matching immutable analytical logs found.'),
                  );
                }

                if (isMobile) {
                  // Mobile View: Dense Vertical ListView of Cards
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = _filteredLogs[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    log.stepExecutionId,
                                    style: monospaceStyle.copyWith(
                                      color: colorScheme.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  _buildStatusBadge(log.status, colorScheme),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.schedule, size: 14, color: colorScheme.outline),
                                  const SizedBox(width: 4),
                                  Text(
                                    log.timestamp,
                                    style: monospaceStyle.copyWith(
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'User: ${log.userId}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    log.stepOutcome,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  // Tablet/Web View: Native DataTable stretched to fill available width
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: DataTable(
                          columnSpacing: 24,
                          headingRowColor: WidgetStateProperty.all(
                            colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          ),
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Step Execution ID',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Execution Timestamp',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Status',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'User ID',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Step Outcome',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: _filteredLogs.map((log) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    log.stepExecutionId,
                                    style: monospaceStyle.copyWith(
                                      color: colorScheme.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    log.timestamp,
                                    style: monospaceStyle.copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                DataCell(_buildStatusBadge(log.status, colorScheme)),
                                DataCell(Text(log.userId)),
                                DataCell(
                                  Text(
                                    log.stepOutcome,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, ColorScheme colorScheme) {
    Color bg;
    Color fg;
    switch (status) {
      case 'SUCCESS':
      case 'COMPLETED':
        bg = colorScheme.primaryContainer;
        fg = colorScheme.onPrimaryContainer;
        break;
      case 'WARNING':
        bg = colorScheme.tertiaryContainer;
        fg = colorScheme.onTertiaryContainer;
        break;
      default:
        bg = colorScheme.surfaceContainerHighest;
        fg = colorScheme.onSurfaceVariant;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
