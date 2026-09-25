// SCTSS-020-A07 — LLM Confidence Score Badge & Gating Logic.
// A color-coded pill badge that communicates AI output certainty and gates automated execution buttons when confidence falls below 70%.

import 'package:flutter/material.dart';

/// Enum representing the three distinct visual states of AI certainty.
enum ConfidenceTier {
  low,
  medium,
  high,
}

/// Data model for mock AI output lock state.
class AiOutputLockData {
  final String lockType;
  final bool lockStatus;
  final String lockedBy;
  final DateTime lockTimestamp;
  final String lockReason;

  const AiOutputLockData({
    required this.lockType,
    required this.lockStatus,
    required this.lockedBy,
    required this.lockTimestamp,
    required this.lockReason,
  });
}

/// Evaluates the confidence percentage and returns the corresponding tier.
ConfidenceTier evaluateConfidenceTier(double confidenceScore) {
  if (confidenceScore < 0.70) return ConfidenceTier.low;
  if (confidenceScore < 0.90) return ConfidenceTier.medium;
  return ConfidenceTier.high;
}

/// Returns the appropriate color for the confidence tier based on MD3 tokens.
Color getTierColor(ConfidenceTier tier, ColorScheme colorScheme) {
  switch (tier) {
    case ConfidenceTier.low:
      return colorScheme.error;
    case ConfidenceTier.medium:
      return colorScheme.tertiary;
    case ConfidenceTier.high:
      return colorScheme.primary;
  }
}

/// Returns the text label for the confidence tier.
String getTierLabel(ConfidenceTier tier) {
  switch (tier) {
    case ConfidenceTier.low:
      return 'Low';
    case ConfidenceTier.medium:
      return 'Med';
    case ConfidenceTier.high:
      return 'High';
  }
}

/// A small, color-coded percentage badge attached to the header of the AI output pane.
/// Highly scannable micro-badge (pill format) that instantly communicates safety without text clutter.
class ConfidenceScoreBadge extends StatelessWidget {
  final double confidenceScore;

  const ConfidenceScoreBadge({
    super.key,
    required this.confidenceScore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tier = evaluateConfidenceTier(confidenceScore);
    final tierColor = getTierColor(tier, colorScheme);
    final percentageText = '${(confidenceScore * 100).round()}%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: tierColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: tierColor.withOpacity(0.5), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            tier == ConfidenceTier.low
                ? Icons.warning_amber_rounded
                : tier == ConfidenceTier.medium
                    ? Icons.info_outline_rounded
                    : Icons.check_circle_outline_rounded,
            size: 14.0,
            color: tierColor,
          ),
          const SizedBox(width: 6.0),
          Text(
            percentageText,
            style: theme.textTheme.labelSmall?.copyWith(
              color: tierColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4.0),
          Text(
            getTierLabel(tier),
            style: theme.textTheme.labelSmall?.copyWith(
              color: tierColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Gating logic widget that locks automated execution buttons when confidence falls into the low-confidence tier (<70%).
/// Outputs with <70% confidence physically disable the "Accept" button, forcing the user to manually edit the text first.
class AiExecutionGate extends StatelessWidget {
  final double confidenceScore;
  final VoidCallback? onAccept;
  final VoidCallback? onEdit;
  final String aiOutputText;

  const AiExecutionGate({
    super.key,
    required this.confidenceScore,
    required this.aiOutputText,
    this.onAccept,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLocked = confidenceScore < 0.70;
    final tier = evaluateConfidenceTier(confidenceScore);

    // Mock lock data for telemetry / system collection
    final mockLockData = AiOutputLockData(
      lockType: 'CONFIDENCE_GATE',
      lockStatus: isLocked,
      lockedBy: 'AI_CONFIDENCE_ENGINE',
      lockTimestamp: DateTime.now(),
      lockReason: isLocked
          ? 'Confidence score ${(confidenceScore * 100).round()}% is below 70% threshold.'
          : 'Confidence score acceptable.',
    );

    return Card(
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AI Generated Output',
                  style: theme.textTheme.titleMedium,
                ),
                ConfidenceScoreBadge(confidenceScore: confidenceScore),
              ],
            ),
            const SizedBox(height: 12.0),

            // AI Output Pane
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                aiOutputText,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16.0),

            // Warning banner for low confidence
            if (isLocked)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, color: theme.colorScheme.onErrorContainer, size: 20.0),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'Automated execution locked. Manual review/edit required due to low AI confidence.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18.0),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 12.0),
                FilledButton.icon(
                  onPressed: isLocked ? null : onAccept,
                  icon: Icon(
                    isLocked ? Icons.lock : Icons.check,
                    size: 18.0,
                  ),
                  label: const Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Preview/Demo widget to showcase the 3 distinct visual states clearly communicating AI certainty.
class ConfidenceScoreBadgePreview extends StatelessWidget {
  const ConfidenceScoreBadgePreview({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data simulating different AI outputs
    const mockOutputs = [
      {'score': 0.55, 'text': 'Drafting an email to the client regarding the delayed shipment...'},
      {'score': 0.82, 'text': 'Summary of Q3 financial results indicates a 12% growth in revenue...'},
      {'score': 0.98, 'text': 'Standard operating procedure for safety compliance verified...'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Confidence Gating Demo'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockOutputs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 24.0),
        itemBuilder: (context, index) {
          final item = mockOutputs[index];
          return AiExecutionGate(
            confidenceScore: item['score'] as double,
            aiOutputText: item['text'] as String,
            onAccept: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('AI Output Accepted')),
              );
            },
            onEdit: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Editor...')),
              );
            },
          );
        },
      ),
    );
  }
}
