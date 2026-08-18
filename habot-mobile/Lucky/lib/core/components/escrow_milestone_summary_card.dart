// SEPGE-001 — Session Milestone Escrow Summary Card.
// Displays prominent summary cards with locked field properties and trust badges representing escrow safety.

import 'package:flutter/material.dart';

class EscrowMilestoneSummaryCard extends StatelessWidget {
  const EscrowMilestoneSummaryCard({
    super.key,
    required this.milestoneTitle,
    required this.escrowAmount,
    required this.isLocked,
    required this.holdReason,
  });

  final String milestoneTitle;
  final double escrowAmount;
  final bool isLocked;
  final String holdReason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    milestoneTitle,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Badge(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isLocked ? Icons.lock : Icons.lock_open, size: 12, color: cs.onPrimaryContainer),
                      const SizedBox(width: 4),
                      Text(isLocked ? 'ESCROW HELD' : 'UNLOCKED'),
                    ],
                  ),
                  backgroundColor: isLocked ? cs.primaryContainer : cs.secondaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Escrow Locked Amount', style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                  Text(
                    'AED ${escrowAmount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.shield_outlined, size: 16, color: cs.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Protected by Session Milestone Lock: $holdReason',
                    style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
