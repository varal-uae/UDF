// PDMV-001 — Accounting Balance Transfer Automated Reconciliation & Audit Viewer.
// Displays real-time audit compliance logs for payout validation screens without manual refresh.

import 'package:flutter/material.dart';

class AuditTrailEntry {
  const AuditTrailEntry({
    required this.auditType,
    required this.auditDate,
    required this.auditResult,
    required this.auditTrailHash,
    required this.auditorInfo,
  });

  final String auditType;
  final String auditDate;
  final String auditResult;
  final String auditTrailHash;
  final String auditorInfo;
}

class AuditReconciliationViewer extends StatelessWidget {
  const AuditReconciliationViewer({
    super.key,
    required this.transferAmount,
    required this.isReconciled,
    required this.auditLogs,
  });

  final double transferAmount;
  final bool isReconciled;
  final List<AuditTrailEntry> auditLogs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: isReconciled ? cs.secondaryContainer : cs.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  isReconciled ? Icons.verified : Icons.error_outline,
                  color: isReconciled ? cs.onSecondaryContainer : cs.onErrorContainer,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isReconciled ? 'Balance Reconciled (AED ${transferAmount.toStringAsFixed(2)})' : 'Discrepancy Pending Audit',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isReconciled ? cs.onSecondaryContainer : cs.onErrorContainer,
                        ),
                      ),
                      Text(
                        isReconciled ? 'Automated ledger verification complete.' : 'Reconciliation logic pending hash validation.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isReconciled ? cs.onSecondaryContainer : cs.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Real-time Compliance Audit Trail Logs',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        ...auditLogs.map((log) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(log.auditType, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Badge(
                        label: Text(log.auditResult),
                        backgroundColor: log.auditResult == 'PASSED' ? cs.primary : cs.error,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Auditor: ${log.auditorInfo} | Date: ${log.auditDate}', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    'Hash: ${log.auditTrailHash}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
