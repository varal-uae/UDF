// CTTEE-031-09 — UI/UX feedback component for A−B=0 subtraction formula and UI design-system adherence.
// Renders immediate Material 3 chips/badges, pins critical status blocks to top layers, shifts threshold colors, and displays circular metric templates.

import 'package:flutter/material.dart';

class Cttee03109UiFeedbackWidget extends StatelessWidget {
  const Cttee03109UiFeedbackWidget({
    super.key,
    required this.a,
    required this.b,
    required this.adherenceRate,
    this.metricName = 'UI Design-System Adherence Rate',
  });

  final num a;
  final num b;
  final double adherenceRate;
  final String metricName;

  bool get _isBalanced => (a - b) == 0;

  Color _adherenceColor(ColorScheme scheme) {
    final percent = adherenceRate <= 1.0 ? adherenceRate * 100 : adherenceRate;
    if (percent >= 95) return scheme.primary;
    if (percent >= 85) return scheme.tertiary;
    return scheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final percent = adherenceRate <= 1.0 ? adherenceRate * 100 : adherenceRate;
    final statusColor = _adherenceColor(scheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 0,
          color: scheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'A − B = 0',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Chip(
                  avatar: Icon(
                    _isBalanced ? Icons.check_circle : Icons.error,
                    color: _isBalanced ? scheme.primary : scheme.error,
                    size: 18,
                  ),
                  label: Text(_isBalanced ? 'Balanced' : 'Unbalanced'),
                  backgroundColor: _isBalanced ? scheme.primaryContainer : scheme.errorContainer,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 148,
            height: 148,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withOpacity(0.12),
              border: Border.all(color: statusColor, width: 3),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Badge(
                  label: Text('${percent.toStringAsFixed(0)}%'),
                  backgroundColor: statusColor,
                  child: Icon(Icons.design_services, color: statusColor),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    metricName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
