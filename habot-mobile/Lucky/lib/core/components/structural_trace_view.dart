// VPVMP-016-11 — Structural Trace Viewer and Mathematical Balance Alerts.
// Renders lightweight list blocks of trace maps for micro-screens.
// Displays zero-balance flashes and high-contrast Material 3 validation alert styles.

import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Renders system tracing logs and triggers mathematical zero-balance alerts.
class StructuralTraceView extends StatefulWidget {
  const StructuralTraceView({
    super.key,
    required this.traceLogs,
    required this.balanceAmount,
    required this.onZeroBalanceTriggered,
  });

  final List<String> traceLogs;
  final double balanceAmount;
  final VoidCallback onZeroBalanceTriggered;

  @override
  State<StructuralTraceView> createState() => _StructuralTraceViewState();
}

class _StructuralTraceViewState extends State<StructuralTraceView> {
  Color? _flashColor;

  @override
  void didUpdateWidget(covariant StructuralTraceView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Flash quick background color tint variations when math score hits zero successfully
    if (widget.balanceAmount == 0.0 && oldWidget.balanceAmount != 0.0) {
      _triggerZeroBalanceFlash();
      widget.onZeroBalanceTriggered();
    }
  }

  void _triggerZeroBalanceFlash() {
    setState(() => _flashColor = const Color(HabotColorTokens.successContainer)); // Light green success container flash
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _flashColor = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final isBalanced = widget.balanceAmount == 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: _flashColor ?? Colors.transparent,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. High-Contrast Math Alert
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isBalanced ? cs.primaryContainer : cs.errorContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isBalanced ? cs.primary : cs.error,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isBalanced ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: isBalanced ? cs.onPrimaryContainer : cs.onErrorContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBalanced ? 'Account Balance Reconciled' : 'Discrepancy Detected',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: isBalanced ? cs.onPrimaryContainer : cs.onErrorContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        isBalanced
                            ? 'Mathematical balance is exactly zero.'
                            : 'Remaining offset: AED ${widget.balanceAmount.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isBalanced ? cs.onPrimaryContainer : cs.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // 2. Trace Map List Title
          Text(
            'Structural Trace logs',
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          
          // 3. Lightweight Scroll List of Trace Maps (condensed text blocks)
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.traceLogs.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.traceLogs[index],
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: cs.onSurface,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
