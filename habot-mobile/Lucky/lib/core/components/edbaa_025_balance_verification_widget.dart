// EDBAA-025 — Double-Entry Balance Verification UI Controls.
// Enforces disabled commit while variances exist, focuses discrepancy total during troubleshooting, and flags mismatched entries with warning borders.

import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';

class Edbaa025Entry {
  const Edbaa025Entry({
    required this.label,
    required this.value,
    required this.isMismatched,
  });

  final String label;
  final double value;
  final bool isMismatched;
}

class Edbaa025BalanceVerification extends StatefulWidget {
  const Edbaa025BalanceVerification({
    super.key,
    required this.debitTotal,
    required this.creditTotal,
    required this.entries,
    this.isTroubleshooting = false,
    this.onCommit,
  });

  final double debitTotal;
  final double creditTotal;
  final List<Edbaa025Entry> entries;
  final bool isTroubleshooting;
  final VoidCallback? onCommit;

  @override
  State<Edbaa025BalanceVerification> createState() => _Edbaa025BalanceVerificationState();
}

class _Edbaa025BalanceVerificationState extends State<Edbaa025BalanceVerification> {
  late final FocusNode _discrepancyFocusNode;

  double get _variance => (widget.debitTotal - widget.creditTotal).abs();

  bool get _hasVariance => _variance > 0.0001;

  @override
  void initState() {
    super.initState();
    _discrepancyFocusNode = FocusNode(debugLabel: 'EDBAA-025 discrepancy total');
    _syncTroubleshootingFocus();
  }

  @override
  void didUpdateWidget(covariant Edbaa025BalanceVerification oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTroubleshootingFocus();
  }

  @override
  void dispose() {
    _discrepancyFocusNode.dispose();
    super.dispose();
  }

  void _syncTroubleshootingFocus() {
    if (!mounted) return;
    if (widget.isTroubleshooting && _hasVariance) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _discrepancyFocusNode.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final warningColor = colorScheme.error;
    final numberStyle = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      fontFeatures: [FontFeature.tabularFigures()],
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Double-Entry Balance Verification',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _TotalRow(
              label: 'Debit total',
              value: widget.debitTotal,
              numberStyle: numberStyle,
            ),
            const SizedBox(height: 8),
            _TotalRow(
              label: 'Credit total',
              value: widget.creditTotal,
              numberStyle: numberStyle,
            ),
            const SizedBox(height: 12),
            Focus(
              focusNode: _discrepancyFocusNode,
              child: Semantics(
                label: 'Discrepancy total',
                value: _variance.toStringAsFixed(2),
                liveRegion: _hasVariance,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _hasVariance ? warningColor : colorScheme.outlineVariant,
                      width: _hasVariance ? 2 : 1,
                    ),
                    color: _hasVariance
                        ? warningColor.withOpacity(0.08)
                        : colorScheme.surfaceContainerHighest.withOpacity(0.35),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Discrepancy total',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _hasVariance ? warningColor : null,
                          ),
                        ),
                      ),
                      Text(
                        _variance.toStringAsFixed(2),
                        style: numberStyle?.copyWith(
                          color: _hasVariance ? warningColor : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.entries.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...widget.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _EntryRow(entry: entry, warningColor: warningColor),
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _hasVariance ? null : widget.onCommit,
              child: const Text('Commit'),
            ),
            if (_hasVariance) ...[
              const SizedBox(height: 8),
              Text(
                'Commit is disabled while an active variance exists.',
                style: theme.textTheme.bodySmall?.copyWith(color: warningColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    required this.numberStyle,
  });

  final String label;
  final double value;
  final TextStyle? numberStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(value.toStringAsFixed(2), style: numberStyle),
      ],
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.entry,
    required this.warningColor,
  });

  final Edbaa025Entry entry;
  final Color warningColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: entry.isMismatched ? warningColor : theme.colorScheme.outlineVariant,
          width: entry.isMismatched ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(child: Text(entry.label)),
          Text(
            entry.value.toStringAsFixed(2),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: entry.isMismatched ? FontWeight.w700 : FontWeight.w500,
              fontFeatures: [FontFeature.tabularFigures()],
              color: entry.isMismatched ? warningColor : null,
            ),
          ),
        ],
      ),
    );
  }
}
