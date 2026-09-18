// GEN-01446 — Reset All Button Widget.
// A prominent Material 3 button that clears active filter parameters to prevent zero-result states.
// Implements 48x48dp touch targets, M3 Elevated styling, and mock telemetry event logging.

import 'package:flutter/material.dart';

/// Mock telemetry data structure for capturing reset events locally.
class _ResetTelemetryEvent {
  final String action;
  final String status;
  final DateTime timestamp;
  final String sessionId;

  _ResetTelemetryEvent({
    required this.action,
    required this.status,
    required this.timestamp,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() => {
        'action': action,
        'status': status,
        'timestamp': timestamp.toIso8601String(),
        'sessionId': sessionId,
      };
}

/// Mock repository simulating BigQuery event streaming partitioned by event_date.
class _MockTelemetryRepository {
  static final List<_ResetTelemetryEvent> _events = [];

  static void logEvent(_ResetTelemetryEvent event) {
    _events.add(event);
    // In production, this would stream to GCP BigQuery clustered by trace_id.
    debugPrint('[GEN-01446] Telemetry Logged: ${event.toJson()}');
  }
}

/// A prominent "Reset All" button adhering to Material Design 3 specifications.
/// Clears active parameters and prevents zero-result states in the UDF feature.
class ResetAllButton extends StatelessWidget {
  /// Callback triggered when the user taps the reset button.
  final VoidCallback onResetAll;

  /// Optional session ID for telemetry tracking. Defaults to a mock UUID.
  final String sessionId;

  const ResetAllButton({
    super.key,
    required this.onResetAll,
    this.sessionId = 'mock-session-gen-01446',
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        // Enforcing minimum 48x48dp touch target as per M3 accessibility guidelines
        height: 48.0,
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () {
            _handleReset(context);
          },
          icon: const Icon(Icons.refresh_rounded, size: 24.0),
          label: const Text(
            'Reset All',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.errorContainer,
            foregroundColor: colorScheme.onErrorContainer,
            elevation: 3.0, // M3 Elevated Cards Level 2 (3dp) equivalent
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            minimumSize: const Size(48.0, 48.0),
          ),
        ),
      ),
    );
  }

  void _handleReset(BuildContext context) {
    // Execute the clear parameters logic
    onResetAll();

    // Log telemetry event
    _MockTelemetryRepository.logEvent(
      _ResetTelemetryEvent(
        action: 'Reset All',
        status: 'Good',
        timestamp: DateTime.now(),
        sessionId: sessionId,
      ),
    );

    // Show M3 Snackbar for confirmation
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All active parameters have been cleared.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16.0),
        ),
      );
    }
  }
}
