// DLQDP-024-12 — Design Reconciliation Score Dashboard Card.
// Renders design reconciliation metrics inside centered Material 3 Data Cards.
// Guarantees >= 48dp touch targets for design review triggers.

import 'package:flutter/material.dart';

/// Render a Design Reconciliation Score Card inside an MD3 Data Card structure.
class DesignReconciliationCard extends StatelessWidget {
  const DesignReconciliationCard({
    super.key,
    required this.score,
    required this.targetCode,
    required this.onReconcile,
    this.isReconciling = false,
  });

  /// The reconciliation percentage score (e.g. 0.94)
  final double score;

  /// Target blueprint identification code (e.g., 'DLQDP-024')
  final String targetCode;

  /// Asynchronous reconciliation trigger
  final VoidCallback? onReconcile;

  /// Flag indicating in-progress asynchronous sync
  final bool isReconciling;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final scorePercent = (score * 100).toStringAsFixed(1);
    final bool isScoreOptimal = score >= 0.95;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Design Reconciliation Score',
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Score Display with Circular Metric
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: score,
                    strokeWidth: 8,
                    color: isScoreOptimal ? cs.primary : cs.error,
                    backgroundColor: cs.surfaceContainerHighest,
                  ),
                ),
                Text(
                  '$scorePercent%',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Target specification code
            Text(
              'Target Blueprint: $targetCode',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: cs.secondary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Reconcile Trigger Action - Enforces the 48dp minimum target
            SizedBox(
              height: 48,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isReconciling ? null : onReconcile,
                icon: isReconciling
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.sync_alt, size: 18),
                label: Text(isReconciling ? 'Syncing Layout...' : 'Sync Reconciliation'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
