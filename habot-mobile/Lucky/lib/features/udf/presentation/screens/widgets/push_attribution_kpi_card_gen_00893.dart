// GEN-00893 — UI Widget: Read-only M3 KPI card surfacing aggregated metric state.
// Renders the 'Event Dispatch Latency' aggregate with deep-link drill-down affordance.

import 'package:flutter/material.dart';

/// M3 KPI card for the engineering console dashboard.
class PushAttributionKpiCard extends StatelessWidget {
  const PushAttributionKpiCard({
    required this.label,
    required this.value,
    required this.unitSuffix,
    required this.isHealthy,
    this.onDrillDown,
    super.key,
  });

  final String label;
  final String value;
  final String unitSuffix;
  final bool isHealthy;
  final VoidCallback? onDrillDown;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onDrillDown,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text(
                    value,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unitSuffix,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Icon(
                isHealthy ? Icons.check_circle_outline : Icons.error_outline,
                color: isHealthy ? scheme.primary : scheme.error,
                size: 20,
                semanticLabel: isHealthy ? 'Metric healthy' : 'Metric failing',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
