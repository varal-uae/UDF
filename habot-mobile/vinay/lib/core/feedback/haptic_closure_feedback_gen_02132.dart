// GEN-02132 — Haptic Closure Feedback Service.
// Triggers haptic feedback to signal absolute closure and task exit, with mock telemetry streaming and M3 status tracking.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mock telemetry event model for BigQuery alignment (partitioned by event_date, clustered by trace_id).
class HapticTelemetryEvent {
  final String atomicId;
  final String action;
  final String completionStatus; // 'Complete' | 'Partial' | 'Not Complete'
  final DateTime timestamp;
  final String sessionId;
  final String traceId;

  const HapticTelemetryEvent({
    required this.atomicId,
    required this.action,
    required this.completionStatus,
    required this.timestamp,
    required this.sessionId,
    required this.traceId,
  });

  Map<String, dynamic> toJson() => {
        'atomic_id': atomicId,
        'action': action,
        'completion_status': completionStatus,
        'timestamp': timestamp.toIso8601String(),
        'session_id': sessionId,
        'trace_id': traceId,
        'event_date': '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}',
      };
}

/// Core service implementing the haptic closure feedback requirement.
/// Depends on prior foundational step GEN-02131.
class HapticClosureFeedbackService {
  HapticClosureFeedbackService._();
  static final HapticClosureFeedbackService instance = HapticClosureFeedbackService._();

  /// Simulated session ID for telemetry capture.
  final String _mockSessionId = 'sess_udf_${DateTime.now().millisecondsSinceEpoch}';

  /// Triggers the heavy impact haptic feedback signaling absolute closure.
  /// Returns a [HapticTelemetryEvent] representing the execution log.
  Future<HapticTelemetryEvent> triggerClosureFeedback() async {
    try {
      await HapticFeedback.heavyImpact();
      return HapticTelemetryEvent(
        atomicId: 'GEN-02132',
        action: 'Trigger haptic feedback to signal absolute closure and task exit.',
        completionStatus: 'Complete',
        timestamp: DateTime.now(),
        sessionId: _mockSessionId,
        traceId: 'trace_${DateTime.now().microsecondsSinceEpoch}',
      );
    } catch (_) {
      return HapticTelemetryEvent(
        atomicId: 'GEN-02132',
        action: 'Trigger haptic feedback to signal absolute closure and task exit.',
        completionStatus: 'Not Complete',
        timestamp: DateTime.now(),
        sessionId: _mockSessionId,
        traceId: 'trace_${DateTime.now().microsecondsSinceEpoch}',
      );
    }
  }
}

/// M3 Elevated Card Level 2 (3dp) widget displaying the step completion state.
/// Single-column mobile layout (<600dp), multi-column desktop (>=840dp) compatible.
class HapticClosureStatusCard extends StatelessWidget {
  final HapticTelemetryEvent? latestEvent;
  final VoidCallback onTrigger;

  const HapticClosureStatusCard({
    super.key,
    this.latestEvent,
    required thisTrigger,
  }) : onTrigger = onTrigger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isComplete = latestEvent?.completionStatus == 'Complete';
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GEN-02132: Task Exit Haptics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(
                    latestEvent?.completionStatus ?? 'Pending',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isComplete ? colorScheme.onPrimary : colorScheme.onErrorContainer,
                    ),
                  ),
                  backgroundColor: isComplete ? colorScheme.primary : colorScheme.errorContainer,
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Text(
              'Trigger haptic feedback to signal absolute closure and task exit.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: onTrigger,
                icon: const Icon(Icons.vibration, size: 20.0),
                label: const Text('Trigger Closure'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(48.0, 48.0), // 48x48dp touch target
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// M3 Bottom Sheet configuration input placeholder for engineering console.
class HapticConfigBottomSheet extends StatelessWidget {
  const HapticConfigBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (context) => const HapticConfigBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24.0,
        right: 24.0,
        top: 24.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 32.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          Text('Configure Haptic Step (GEN-02132)', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16.0),
          TextField(
            decoration: InputDecoration(
              labelText: 'Metric Floor Boundary (%)',
              hintText: '90',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24.0),
          SizedBox(
            width: double.infinity,
            height: 48.0,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configuration saved successfully.')),
                );
              },
              child: const Text('Apply Configuration'),
            ),
          ),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }
}
