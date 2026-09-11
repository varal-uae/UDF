// EDBAA-034-14 — Mobile UI/UX layout for immutable ledger net profit focus.
// Locks visual attention on core net profit balances with monospaced currency,
// inline lineage sub-menus, and read-only cell highlights.

import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';

class NetProfitFocusLayout extends StatefulWidget {
  const NetProfitFocusLayout({super.key, required this.lines});
  final List<ProfitLine> lines;

  @override
  State<NetProfitFocusLayout> createState() => _NetProfitFocusLayoutState();
}

class ProfitLine {
  const ProfitLine({
    required this.label,
    required this.amount,
    required this.children,
    this.isReadOnly = true,
  });
  final String label;
  final double amount;
  final List<ProfitLine> children;
  final bool isReadOnly;
}

class _NetProfitFocusLayoutState extends State<NetProfitFocusLayout> {
  final Set<int> _expandedIndexes = <int>{};

  String _currency(double value) {
    final sign = value < 0 ? '-' : '';
    final abs = value.abs();
    final whole = abs.truncate();
    final cents = ((abs - whole) * 100).round().toString().padLeft(2, '0');
    final wholeStr = whole.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < wholeStr.length; i++) {
      if (i > 0 && (wholeStr.length - i) % 3 == 0) buffer.write(',');
      buffer.write(wholeStr[i]);
    }
    return '$sign\$${buffer.toString()}.$cents';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Net Profit Balances',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Read-only ledger view. Tap a parent figure to trace source data lineages.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            ...List<Widget>.generate(widget.lines.length, (index) {
              final line = widget.lines[index];
              final expanded = _expandedIndexes.contains(index);
              return _ProfitRow(
                line: line,
                expanded: expanded,
                formatter: _currency,
                onTap: () {
                  setState(() {
                    if (expanded) {
                      _expandedIndexes.remove(index);
                    } else {
                      _expandedIndexes.add(index);
                    }
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ProfitRow extends StatelessWidget {
  const _ProfitRow({
    required this.line,
    required this.expanded,
    required this.formatter,
    required this.onTap,
  });

  final ProfitLine line;
  final bool expanded;
  final String Function(double) formatter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final readOnlyColor = theme.colorScheme.surfaceContainerHigh.withOpacity(0.65);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: line.children.isEmpty ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: line.isReadOnly ? readOnlyColor : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: line.isReadOnly
                    ? theme.colorScheme.outlineVariant
                    : theme.colorScheme.primary.withOpacity(0.35),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    line.label,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  formatter(line.amount),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (line.children.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 4, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: line.children
                  .map(
                    (child) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.subdirectory_arrow_right, size: 16, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Expanded(child: Text(child.label, style: theme.textTheme.bodySmall)),
                          Text(
                            formatter(child.amount),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}
