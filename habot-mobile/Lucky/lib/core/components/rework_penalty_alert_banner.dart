// BTPM-029 — Track and Penalize Repeated Task Rework Cycles.
// Displays high-contrast danger alert banners (#FF3B30), triggers rejection haptics, and shows score deltas.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReworkPenaltyAlertBanner extends StatefulWidget {
  const ReworkPenaltyAlertBanner({
    super.key,
    required this.workerId,
    required this.reworkCount,
    required this.previousScore,
    required this.newScore,
    required this.reason,
    this.triggerHaptics = true,
  });

  final String workerId;
  final int reworkCount;
  final double previousScore;
  final double newScore;
  final String reason;
  final bool triggerHaptics;

  @override
  State<ReworkPenaltyAlertBanner> createState() => _ReworkPenaltyAlertBannerState();
}

class _ReworkPenaltyAlertBannerState extends State<ReworkPenaltyAlertBanner> {
  @override
  void initState() {
    super.initState();
    if (widget.triggerHaptics) {
      HapticFeedback.vibrate(); // Tactile rejection haptics
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    const dangerRed = Color(0xFFFF3B30); // Material danger color #FF3B30

    return Card(
      color: dangerRed.withOpacity(0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: dangerRed, width: 2),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.error, color: dangerRed, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Task Rework Penalty Applied',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: dangerRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Rework Cycle #${widget.reworkCount}: ${widget.reason}',
              style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Current Score: ${widget.previousScore.toStringAsFixed(1)} ➔ ${widget.newScore.toStringAsFixed(1)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: dangerRed,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
