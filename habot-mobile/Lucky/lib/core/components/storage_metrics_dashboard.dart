// HSCPE-002 — StorageClass Metrics Dashboard Component.
// Consolidates storage statistics into expandable tabs using global 8dp grid spacing tokens.

import 'package:flutter/material.dart';

class StorageMetricItem {
  const StorageMetricItem({
    required this.label,
    required this.capacityValue,
    required this.performanceValue,
    required this.details,
  });

  final String label;
  final String capacityValue;
  final String performanceValue;
  final String details;
}

class StorageMetricsDashboard extends StatelessWidget {
  const StorageMetricsDashboard({
    super.key,
    required this.metrics,
  });

  final List<StorageMetricItem> metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Storage Metrics & Performance (pd-ssd)',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8), // 8dp grid spacing
        ...metrics.map((item) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4), // 8dp grid spacing factor
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                item.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    Text(
                      'Capacity: ${item.capacityValue}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'IOPS: ${item.performanceValue}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    item.details,
                    style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
