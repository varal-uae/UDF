// OPMV-018-A05 — UI Friction Tracking Logger
// Deploys programmatic event checking listeners to capture field hover or freeze durations exceeding five seconds, packaging records into compressed payloads for asynchronous background logging.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

/// Represents a single friction event captured from user interaction delays.
class FrictionEvent {
  final String lockedObjectId;
  final String lockStatus;
  final DateTime lockDate;
  final String lockReason;
  final String userId;
  final String completionStatus;
  final DateTime actionTimestamp;
  final String sessionId;
  final Duration hesitationDuration;

  const FrictionEvent({
    required this.lockedObjectId,
    required this.lockStatus,
    required this.lockDate,
    required this.lockReason,
    required this.userId,
    required this.completionStatus,
    required this.actionTimestamp,
    required this.sessionId,
    required this.hesitationDuration,
  });

  Map<String, dynamic> toJson() => {
        'locked_object_id': lockedObjectId,
        'lock_status': lockStatus,
        'lock_date': lockDate.toIso8601String(),
        'lock_reason': lockReason,
        'user_id': userId,
        'completion_status': completionStatus,
        'action_timestamp': actionTimestamp.toIso8601String(),
        'session_id': sessionId,
        'hesitation_duration_ms': hesitationDuration.inMilliseconds,
      };
}

/// Asynchronous background logger that ingests friction events and simulates
/// decoupled messaging queue dispatch (GCP / BigQuery alignment).
class FrictionLoggerService {
  FrictionLoggerService._();
  static final FrictionLoggerService instance = FrictionLoggerService._();

  final List<FrictionEvent> _eventQueue = [];
  bool _isProcessing = false;

  /// Enqueues an event. Drops automatically if core identity headers are missing (Poka-Yoke).
  void logEvent(FrictionEvent event) {
    if (event.lockedObjectId.isEmpty ||
        event.userId.isEmpty ||
        event.sessionId.isEmpty) {
      debugPrint('[FrictionLogger] Dropped event: Missing core identity headers.');
      return;
    }

    _eventQueue.add(event);
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessing || _eventQueue.isEmpty) return;
    _isProcessing = true;

    // Simulate batching and compressing payloads asynchronously
    await Future.delayed(const Duration(milliseconds: 500));

    final batch = List<FrictionEvent>.from(_eventQueue);
    _eventQueue.clear();

    for (final event in batch) {
      final payload = jsonEncode(event.toJson());
      // Mock ingestion to standard decoupled messaging queues
      debugPrint('[FrictionLogger] Dispatched payload (${payload.length} chars): ${event.lockedObjectId}');
    }

    _isProcessing = false;
    if (_eventQueue.isNotEmpty) {
      _processQueue();
    }
  }

  /// Returns mock data for dashboard visualization.
  List<FrictionEvent> getMockDashboardData() {
    return [
      FrictionEvent(
        lockedObjectId: 'FIELD_EMAIL_01',
        lockStatus: 'FROZEN',
        lockDate: DateTime.now().subtract(const Duration(minutes: 5)),
        lockReason: 'Hesitation exceeded 5s threshold',
        userId: 'USR_MOCK_992',
        completionStatus: 'Fail',
        actionTimestamp: DateTime.now(),
        sessionId: 'SESS_ABC_123',
        hesitationDuration: const Duration(seconds: 7),
      ),
      FrictionEvent(
        lockedObjectId: 'FIELD_PHONE_02',
        lockStatus: 'ACTIVE',
        lockDate: DateTime.now().subtract(const Duration(minutes: 2)),
        lockReason: 'Input mask confusion detected',
        userId: 'USR_MOCK_441',
        completionStatus: 'Pass',
        actionTimestamp: DateTime.now(),
        sessionId: 'SESS_DEF_456',
        hesitationDuration: const Duration(seconds: 5, milliseconds: 200),
      ),
    ];
  }
}

/// A reusable wrapper widget that tracks focus/hover duration on its child.
/// If the child remains focused without input for > 5 seconds, it logs a friction event.
class FrictionTrackingWrapper extends StatefulWidget {
  final Widget child;
  final String objectId;
  final String userId;
  final String sessionId;

  /// Material Design Motion System boundaries
  static const Duration floorBoundary = Duration(milliseconds: 100);
  static const Duration optimalTargetMin = Duration(milliseconds: 200);
  static const Duration optimalTargetMax = Duration(milliseconds: 300);
  static const Duration ceilingBoundary = Duration(milliseconds: 400);
  static const Duration frictionThreshold = Duration(seconds: 5);

  const FrictionTrackingWrapper({
    super.key,
    required this.child,
    required this.objectId,
    this.userId = 'MOCK_USER_ID',
    this.sessionId = 'MOCK_SESSION_ID',
  });

  @override
  State<FrictionTrackingWrapper> createState() => _FrictionTrackingWrapperState();
}

class _FrictionTrackingWrapperState extends State<FrictionTrackingWrapper> {
  Timer? _hesitationTimer;
  DateTime? _focusStartTime;

  void _onFocusGained() {
    _focusStartTime = DateTime.now();
    _hesitationTimer?.cancel();
    _hesitationTimer = Timer(FrictionTrackingWrapper.frictionThreshold, () {
      _logFrictionEvent('User hesitation/freeze exceeded 5 seconds');
    });
  }

  void _onFocusLost() {
    _hesitationTimer?.cancel();
    if (_focusStartTime != null) {
      final duration = DateTime.now().difference(_focusStartTime!);
      if (duration >= FrictionTrackingWrapper.frictionThreshold) {
        _logFrictionEvent('Field blur after prolonged freeze');
      }
    }
    _focusStartTime = null;
  }

  void _logFrictionEvent(String reason) {
    final event = FrictionEvent(
      lockedObjectId: widget.objectId,
      lockStatus: 'FROZEN',
      lockDate: DateTime.now(),
      lockReason: reason,
      userId: widget.userId,
      completionStatus: 'Fail',
      actionTimestamp: DateTime.now(),
      sessionId: widget.sessionId,
      hesitationDuration: _focusStartTime != null
          ? DateTime.now().difference(_focusStartTime!)
          : FrictionTrackingWrapper.frictionThreshold,
    );
    FrictionLoggerService.instance.logEvent(event);
  }

  @override
  void dispose() {
    _hesitationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          _onFocusGained();
        } else {
          _onFocusLost();
        }
      },
      child: widget.child,
    );
  }
}

/// Standardized dashboard card layout pattern for visualizing friction metrics.
class FrictionMetricCard extends StatelessWidget {
  final FrictionEvent event;

  const FrictionMetricCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFail = event.completionStatus == 'Fail';

    return Card(
      elevation: 2,
      color: isFail ? theme.colorScheme.errorContainer : theme.colorScheme.surfaceContainerHighest,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  event.lockedObjectId,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isFail ? theme.colorScheme.onErrorContainer : null,
                  ),
                ),
                Icon(
                  isFail ? Icons.error_outline : Icons.check_circle_outline,
                  color: isFail ? theme.colorScheme.error : theme.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Reason: ${event.lockReason}', style: theme.textTheme.bodyMedium),
            Text('Duration: ${event.hesitationDuration.inMilliseconds}ms', style: theme.textTheme.bodySmall),
            Text('Status: ${event.completionStatus}', style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              'Immutable Proof: ${event.actionTimestamp.toIso8601String()}',
              style: theme.textTheme.labelSmall?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
