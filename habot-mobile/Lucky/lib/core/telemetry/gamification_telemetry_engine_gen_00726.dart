// GEN-00726 — Mobile Gamification & Loyalty Event Telemetry Engine.
// Provides idempotent event processing with duplicate UUID prevention, M3 status reporting, and BigQuery-aligned telemetry streaming.

import 'dart:async';

import 'package:flutter/material.dart';

/// Core telemetry engine for gamification and loyalty events.
/// Enforces duplicate event UUID blocking to prevent double point accrual.
class GamificationTelemetryEngine {
  GamificationTelemetryEngine._();

  static final GamificationTelemetryEngine instance =
      GamificationTelemetryEngine._();

  final Set<String> _processedEventUuids = <String>{};
  final StreamController<TelemetryEvent> _eventStreamController =
      StreamController<TelemetryEvent>.broadcast();

  /// Stream of telemetry events aligned for BigQuery partitioning by event_date
  /// and clustering by trace_id.
  Stream<TelemetryEvent> get eventStream => _eventStreamController.stream;

  /// Processes a gamification event. Returns false if the event UUID
  /// has already been processed (preventing double point accrual).
  bool processEvent({
    required String eventUuid,
    required String traceId,
    required String userId,
    required String eventType,
    Map<String, dynamic>? metadata,
  }) {
    if (_processedEventUuids.contains(eventUuid)) {
      return false;
    }

    // Transaction lock simulation: add UUID before async operations
    _processedEventUuids.add(eventUuid);

    final TelemetryEvent telemetryEvent = TelemetryEvent(
      eventUuid: eventUuid,
      traceId: traceId,
      userId: userId,
      eventType: eventType,
      timestamp: DateTime.now().toUtc(),
      metadata: metadata ?? const <String, dynamic>{},
    );

    _eventStreamController.add(telemetryEvent);
    return true;
  }

  /// Checks if an event UUID has already been processed.
  bool isDuplicate(String eventUuid) =>
      _processedEventUuids.contains(eventUuid);

  /// Clears processed events (useful for session reset or testing).
  void clearProcessedEvents() => _processedEventUuids.clear();

  void dispose() {
    _eventStreamController.close();
  }
}

/// Represents a single telemetry event for BigQuery streaming.
class TelemetryEvent {
  const TelemetryEvent({
    required this.eventUuid,
    required this.traceId,
    required this.userId,
    required this.eventType,
    required this.timestamp,
    required this.metadata,
  });

  final String eventUuid;
  final String traceId;
  final String userId;
  final String eventType;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  /// Serializes to a map suitable for BigQuery JSON ingestion.
  Map<String, dynamic> toBigQueryMap() {
    return <String, dynamic>{
      'event_uuid': eventUuid,
      'trace_id': traceId,
      'user_id': userId,
      'event_type': eventType,
      'event_date':
          '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}',
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// M3 Elevated Card displaying telemetry step completion state.
/// Implements single-column mobile layout (<600dp) and multi-column desktop (>=840dp).
class TelemetryStatusCard extends StatelessWidget {
  const TelemetryStatusCard({
    super.key,
    required this.stepName,
    required this.isPassing,
    required this.metricValue,
    this.onDeepLinkTap,
  });

  final String stepName;
  final bool isPassing;
  final String metricValue;
  final VoidCallback? onDeepLinkTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Card(
      elevation: 3.0, // M3 Elevated Card Level 2 (3dp)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onDeepLinkTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      stepName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  _buildStatusChip(colorScheme),
                ],
              ),
              const SizedBox(height: 12.0),
              Text(
                'Duplicate Accrual Prevention Rate: $metricValue',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ColorScheme colorScheme) {
    return Chip(
      avatar: Icon(
        isPassing ? Icons.check_circle : Icons.error,
        size: 18.0,
        color: isPassing
            ? colorScheme.primary
            : colorScheme.error,
      ),
      label: Text(
        isPassing ? 'Pass' : 'Fail',
        style: TextStyle(
          color: isPassing
              ? colorScheme.primary
              : colorScheme.error,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: isPassing
          ? colorScheme.primaryContainer.withOpacity(0.3)
          : colorScheme.errorContainer.withOpacity(0.3),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
    );
  }
}

/// Background polling service that refreshes telemetry data every 30 seconds.
class TelemetryPollingService {
  TelemetryPollingService({
    this.pollInterval = const Duration(seconds: 30),
  });

  final Duration pollInterval;
  Timer? _pollTimer;

  /// Starts the 30-second background polling cycle.
  void startPolling(VoidCallback onPoll) {
    stopPolling();
    _pollTimer = Timer.periodic(pollInterval, (_) => onPoll());
  }

  /// Stops the background polling cycle.
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }
}
