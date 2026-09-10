// CUITC-009 — Vendor Payment Threshold Proximity Widget.
// Displays Section 43B(h) compliance window proximity with linear progress bars,
// warning palette transitions, expandable guidance, and crisp financial typography.

import 'package:flutter/material.dart';

class Cuitc009VendorPaymentThresholdProximity extends StatelessWidget {
  const Cuitc009VendorPaymentThresholdProximity({
    super.key,
    required this.title,
    required this.currentValue,
    required this.floorBoundary,
    required this.optimalTarget,
    required this.ceilingBoundary,
    this.unitLabel = '%',
    this.advice = const [],
  });

  final String title;
  final double currentValue;
  final double floorBoundary;
  final double optimalTarget;
  final double ceilingBoundary;
  final String unitLabel;
  final List<String> advice;

  double get _normalizedValue {
    final range = ceilingBoundary - floorBoundary;
    if (range <= 0) return 0;
    return ((currentValue - floorBoundary) / range).clamp(0.0, 1.0);
  }

  Color _indicatorColor(ColorScheme scheme) {
    final targetDistance = (currentValue - optimalTarget).abs();
    final warningThreshold = (ceilingBoundary - optimalTarget) * 0.25;
    if (targetDistance <= warningThreshold) {
      return scheme.primary;
    }
    if (currentValue < optimalTarget) {
      return Colors.orange.shade700;
    }
    return scheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = _indicatorColor(scheme);
    final percentage = (_normalizedValue * 100).toStringAsFixed(1);

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _normalizedValue,
                      minHeight: 12,
                      backgroundColor: scheme.surfaceContainer,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$currentValue$unitLabel',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Proximity: $percentage% of compliance window',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (advice.isNotEmpty) ...[
              const SizedBox(height: 12),
              Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(top: 4),
                  title: Text(
                    'Threshold guidance',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  children: advice
                      .map(
                        (item) => Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '• $item',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
