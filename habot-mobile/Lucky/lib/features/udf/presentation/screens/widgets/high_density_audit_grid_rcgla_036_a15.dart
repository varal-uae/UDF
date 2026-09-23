// RCGLA-036-A15 — High-Density Audit Log Grid Layout.
// Implements a responsive, high-density Material 3 data grid for audit logs with monospaced right-alignment, row highlighting on tap, ellipsis overflow handling, and mobile-first vertical stacking into digest cards.

import 'package:flutter/material.dart';

/// Atomic-level data model for audit log entries.
class AuditLogEntry {
  final String lockType;
  final String lockStatus;
  final String lockedBy;
  final DateTime lockTimestamp;
  final String lockReason;
  final double balanceAmount;

  const AuditLogEntry({
    required this.lockType,
    required this.lockStatus,
    required this.lockedBy,
    required this.lockTimestamp,
    required this.lockReason,
    required this.balanceAmount,
  });
}

/// Mock data repository supplying realistic local data for the audit grid.
class MockAuditLogRepository {
  static const List<AuditLogEntry> entries = [
    AuditLogEntry(
      lockType: 'LEDGER',
      lockStatus: 'ACTIVE',
      lockedBy: 'admin@habot.ae',
      lockTimestamp: DateTime(2026, 9, 20, 14, 30),
      lockReason: 'End of month reconciliation variance detected in structural ledger.',
      balanceAmount: 145230.75,
    ),
    AuditLogEntry(
      lockType: 'INVOICE',
      lockStatus: 'PENDING',
      lockedBy: 'auditor_02@habot.ae',
      lockTimestamp: DateTime(2026, 9, 21, 9, 15),
      lockReason: 'Supplier invoice requires secondary approval due to threshold breach.',
      balanceAmount: 8920.00,
    ),
    AuditLogEntry(
      lockType: 'TRANSACTION',
      lockStatus: 'LOCKED',
      lockedBy: 'system_auto',
      lockTimestamp: DateTime(2026, 9, 22, 18, 45),
      lockReason: 'Automated fraud detection flag triggered by anomalous velocity pattern.',
      balanceAmount: -45000.50,
    ),
    AuditLogEntry(
      lockType: 'LEDGER',
      lockStatus: 'RESOLVED',
      lockedBy: 'cfo@habot.ae',
      lockTimestamp: DateTime(2026, 9, 23, 10, 0),
      lockReason: 'Variance cleared after manual adjustment and sign-off.',
      balanceAmount: 0.00,
    ),
  ];
}

/// High-density grid layout widget for rendering audit logs.
/// Adapts between a tabular desktop view and vertically stacked cards on mobile.
class HighDensityAuditGrid extends StatefulWidget {
  const HighDensityAuditGrid({super.key});

  @override
  State<HighDensityAuditGrid> createState() => _HighDensityAuditGridState();
}

class _HighDensityAuditGridState extends State<HighDensityAuditGrid> {
  int? _selectedRowIndex;
  bool _isDrawerOpen = false;

  void _onRowTapped(int index) {
    setState(() {
      _selectedRowIndex = _selectedRowIndex == index ? null : index;
    });
  }

  void _dismissDrawerScrim() {
    if (_isDrawerOpen) {
      setState(() => _isDrawerOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    final entries = MockAuditLogRepository.entries;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Immutable Audit History'),
            actions: [
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => setState(() => _isDrawerOpen = true),
              ),
            ],
          ),
          body: isMobile
              ? _buildMobileLayout(context, entries, theme)
              : _buildDesktopLayout(context, entries, theme),
        ),
        // Background dimming scrim event listener to dismiss drawer when tapped
        if (_isDrawerOpen)
          GestureDetector(
            onTap: _dismissDrawerScrim,
            child: Container(
              color: Colors.black54,
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {}, // Prevent tap from propagating to scrim
                  child: Material(
                    elevation: 16,
                    child: SizedBox(
                      width: 250,
                      height: double.infinity,
                      child: Column(
                        children: [
                          DrawerHeader(child: Text('Menu', style: theme.textTheme.headlineSmall)),
                          ListTile(title: const Text('Export Logs'), onTap: () => setState(() => _isDrawerOpen = false)),
                          ListTile(title: const Text('Settings'), onTap: () => setState(() => _isDrawerOpen = false)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Mobile layout: Stacks multi-column data verification blocks vertically into clean digest cards.
  Widget _buildMobileLayout(BuildContext context, List<AuditLogEntry> entries, ThemeData theme) {
    return ListView.separated(
      padding: const EdgeInsets.all(8.0),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isSelected = _selectedRowIndex == index;

        return InkWell(
          onTap: () => _onRowTapped(index),
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                  : index.isEven
                      ? theme.colorScheme.surfaceContainerLowest
                      : theme.colorScheme.surface,
              border: Border.all(
                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildChip(entry.lockType, theme),
                    _buildStatusChip(entry.lockStatus, theme),
                  ],
                ),
                const SizedBox(height: 8),
                // Monospaced right-aligned balance prioritized with explicit text weight
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatCurrency(entry.balanceAmount),
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: entry.balanceAmount < 0 ? theme.colorScheme.error : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Locked By: ${entry.lockedBy}', style: theme.textTheme.bodyMedium),
                Text(
                  'Timestamp: ${_formatDate(entry.lockTimestamp)}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                // Ellipsis tail forcing touch expansion for out-of-bounds fields
                Text(
                  entry.lockReason,
                  maxLines: isSelected ? null : 2,
                  overflow: isSelected ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Desktop layout: Highly dense Material grid template built for lightning-fast vertical eye scanning.
  Widget _buildDesktopLayout(BuildContext context, List<AuditLogEntry> entries, ThemeData theme) {
    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
          child: DataTable(
            headingRowHeight: 40,
            dataRowMinHeight: 36,
            dataRowMaxHeight: 36,
            horizontalMargin: 12,
            columnSpacing: 16,
            headingTextStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            columns: const [
              DataColumn(label: Text('Lock Type')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Locked By')),
              DataColumn(label: Text('Timestamp')),
              DataColumn(label: Text('Balance'), numeric: true),
              DataColumn(label: Expanded(child: Text('Reason'))),
            ],
            rows: List.generate(entries.length, (index) {
              final entry = entries[index];
              final isSelected = _selectedRowIndex == index;

              return DataRow(
                selected: isSelected,
                onSelectChanged: (_) => _onRowTapped(index),
                color: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return theme.colorScheme.primaryContainer.withOpacity(0.3);
                  }
                  return index.isEven ? theme.colorScheme.surfaceContainerLowest : null;
                }),
                cells: [
                  DataCell(_buildChip(entry.lockType, theme)),
                  DataCell(_buildStatusChip(entry.lockStatus, theme)),
                  DataCell(Text(entry.lockedBy, style: theme.textTheme.bodySmall)),
                  DataCell(Text(_formatDate(entry.lockTimestamp), style: theme.textTheme.bodySmall)),
                  // Monospaced right-alignment locks decimals to an absolute vertical line
                  DataCell(
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _formatCurrency(entry.balanceAmount),
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontWeight: FontWeight.w700,
                          color: entry.balanceAmount < 0 ? theme.colorScheme.error : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  // Out-of-bounds fields highlight using contrasting error typography or ellipsis
                  DataCell(
                    Tooltip(
                      message: entry.lockReason,
                      child: Text(
                        entry.lockReason,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, ThemeData theme) {
    return Chip(
      label: Text(label, style: theme.textTheme.labelSmall),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  Widget _buildStatusChip(String status, ThemeData theme) {
    Color bgColor;
    switch (status) {
      case 'ACTIVE':
        bgColor = Colors.green.shade100;
        break;
      case 'PENDING':
        bgColor = Colors.orange.shade100;
        break;
      case 'LOCKED':
        bgColor = theme.colorScheme.errorContainer;
        break;
      default:
        bgColor = theme.colorScheme.surfaceContainerHighest;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: status == 'LOCKED' ? theme.colorScheme.onErrorContainer : theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs().toStringAsFixed(2);
    final parts = absAmount.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '${isNegative ? '-' : ''}AED $intPart.${parts[1]}';
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
