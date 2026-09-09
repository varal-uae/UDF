// BPTR-0067-A08 — Inverted Pyramid Layout for Operational Dashboard.
// Vertical stacking layout that pins the highest-priority metric at the top with the largest visual weight and progressively reduces emphasis for up to four secondary metrics.

import 'package:flutter/material.dart';

/// A single metric entry for the inverted pyramid layout.
class InvertedPyramidMetric {
  const InvertedPyramidMetric({
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
}

class InvertedPyramidLayout extends StatelessWidget {
  const InvertedPyramidLayout({
    super.key,
    required this.metrics,
    this.maxVisibleEntries = 5,
  }) : assert(metrics.length <= maxVisibleEntries,
            'Inverted pyramid supports a maximum of $maxVisibleEntries entries.');

  /// The metrics to display, ordered by priority (index 0 = highest priority).
  final List<InvertedPyramidMetric> metrics;

  /// Maximum number of visible entries; enforces the 5-key-entry limit.
  final int maxVisibleEntries;

  @override
  Widget build(BuildContext context) {
    final visibleMetrics = metrics.take(maxVisibleEntries).toList();
    if (visibleMetrics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PrimaryMetricCard(metric: visibleMetrics.first),
        for (int i = 1; i < visibleMetrics.length; i++) ...[
          const SizedBox(height: 8),
          _SecondaryMetricCard(metric: visibleMetrics[i], level: i),
        ],
      ],
    );
  }
}

class _PrimaryMetricCard extends StatelessWidget {
  const _PrimaryMetricCard({required this.metric});

  final InvertedPyramidMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card.filled(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (metric.icon != null) ...[
                  Icon(metric.icon, size: 28, color: theme.colorScheme.onPrimaryContainer),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    metric.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              metric.value,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            if (metric.subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                metric.subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SecondaryMetricCard extends StatelessWidget {
  const _SecondaryMetricCard({required this.metric, required this.level});

  final InvertedPyramidMetric metric;
  final int level; // 1-based priority level for secondary metrics

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Progressive weight reduction: higher level -> lighter weight and smaller text.
    final fontWeight = switch (level) {
      1 => FontWeight.w600,
      2 => FontWeight.w500,
      _ => FontWeight.w400,
    };
    final valueStyle = switch (level) {
      1 => theme.textTheme.headlineSmall,
      2 => theme.textTheme.titleLarge,
      _ => theme.textTheme.titleMedium,
    };

    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (metric.icon != null) ...[
              Icon(metric.icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.title,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: fontWeight),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    metric.value,
                    style: valueStyle?.copyWith(fontWeight: fontWeight),
                  ),
                  if (metric.subtitle != null)
                    Text(
                      metric.subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
