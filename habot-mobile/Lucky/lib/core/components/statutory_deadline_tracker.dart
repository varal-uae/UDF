// GCCC-001 — Statutory Year-End Submission Date Tracking Constraint.
// Renders M3 progress indicators where surface accent colors shift dynamically based on remaining days.

import 'package:flutter/material.dart';

class StatutoryDeadlineTracker extends StatelessWidget {
  const StatutoryDeadlineTracker({
    super.key,
    required this.submissionTitle,
    required this.daysRemaining,
    required this.totalFilingWindowDays,
    required this.onTapFilingDetails,
  });

  final String submissionTitle;
  final int daysRemaining;
  final int totalFilingWindowDays;
  final VoidCallback onTapFilingDetails;

  Color _resolveAccentColor(ColorScheme cs) {
    if (daysRemaining > 30) return cs.primary;
    if (daysRemaining > 15) return cs.tertiary;
    return cs.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accentColor = _resolveAccentColor(cs);
    final progress = (daysRemaining / totalFilingWindowDays).clamp(0.0, 1.0);

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
                    submissionTitle,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Badge(
                  label: Text('$daysRemaining Days Left'),
                  backgroundColor: accentColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              color: accentColor,
              backgroundColor: cs.surfaceContainerHighest,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Text(
              daysRemaining <= 5
                  ? 'Urgent: Statutory deadline approaching. File immediately to avoid penalties.'
                  : 'Filing window open. Track required documents and submit before year-end deadline.',
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onTapFilingDetails,
              icon: const Icon(Icons.description_outlined, size: 18),
              label: const Text('View Filing Details'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 48), // 48dp touch target
              ),
            ),
          ],
        ),
      ),
    );
  }
}
