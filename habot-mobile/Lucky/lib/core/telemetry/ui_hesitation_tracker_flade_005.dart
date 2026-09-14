// FLADE-005 — UI Hesitation Tracking & Telemetry Dispatcher.
// Detects user hesitation on critical interactive widgets (hover or touch hold > 5s) and dispatches throttled telemetry events to the analytics pipeline.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Telemetry payload capturing atomic execution metadata for hesitation tracking.
@immutable
class HesitationTelemetryPayload {
  const HesitationTelemetryPayload({
    required this.stepExecutionId,
    required this.targetElementId,
    required this.executionStatus,
    required this.executionTimestamp,
    required this.stepOutcome,
    required this.userId,
    required this.hesitationDurationMs,
    this.completionStatus = 'Conditional Pass',
    this.metadata = const {},
  });

  final String stepExecutionId;
  final String targetElementId;
  final String executionStatus;
  final DateTime executionTimestamp;
  final String stepOutcome;
  final String userId;
  final int hesitationDurationMs;
  final String completionStatus;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => {
        'step_execution_id': stepExecutionId,
        'target_element_id': targetElementId,
        'execution_status': executionStatus,
        'execution_timestamp': executionTimestamp.toIso8601String(),
        'step_outcome': stepOutcome,
        'user_id': userId,
        'hesitation_duration_ms': hesitationDurationMs,
        'completion_status': completionStatus,
        'metadata': metadata,
      };
}

/// Callback signature for hesitation telemetry dispatching.
typedef HesitationCallback = void Function(HesitationTelemetryPayload payload);

/// A mobile-first and responsive wrapper widget that monitors pointer hover
/// and touch dwell times exceeding [hesitationThreshold] (default 5 seconds),
/// emitting throttled analytics payloads.
class HesitationTracker extends StatefulWidget {
  const HesitationTracker({
    super.key,
    required this.targetElementId,
    required this.child,
    this.userId = 'anonymous_user',
    this.stepExecutionId = 'FLADE-005',
    this.hesitationThreshold = const Duration(seconds: 5),
    this.throttleWindow = const Duration(seconds: 15),
    this.onHesitationDetected,
    this.enableTouchTracking = true,
    this.enableHoverTracking = true,
  });

  final String targetElementId;
  final Widget child;
  final String userId;
  final String stepExecutionId;
  final Duration hesitationThreshold;
  final Duration throttleWindow;
  final HesitationCallback? onHesitationDetected;
  final bool enableTouchTracking;
  final bool enableHoverTracking;

  @override
  State<HesitationTracker> createState() => _HesitationTrackerState();
}

class _HesitationTrackerState extends State<HesitationTracker> {
  Timer? _hesitationTimer;
  DateTime? _dwellStartTime;
  DateTime? _lastDispatchedTime;

  void _onInteractionStart() {
    _dwellStartTime = DateTime.now();
    _hesitationTimer?.cancel();
    _hesitationTimer = Timer(widget.hesitationThreshold, _triggerHesitation);
  }

  void _onInteractionEnd() {
    _hesitationTimer?.cancel();
    _hesitationTimer = null;
    _dwellStartTime = null;
  }

  void _triggerHesitation() {
    final now = DateTime.now();
    if (_lastDispatchedTime != null &&
        now.difference(_lastDispatchedTime!) < widget.throttleWindow) {
      return;
    }

    final start = _dwellStartTime ?? now.subtract(widget.hesitationThreshold);
    final duration = now.difference(start).inMilliseconds;

    final payload = HesitationTelemetryPayload(
      stepExecutionId: widget.stepExecutionId,
      targetElementId: widget.targetElementId,
      executionStatus: 'HesitationDetected',
      executionTimestamp: now,
      stepOutcome: 'FrictionAlert',
      userId: widget.userId,
      hesitationDurationMs: duration,
      completionStatus: 'Conditional Pass',
      metadata: {
        'platform': defaultTargetPlatform.name,
        'threshold_ms': widget.hesitationThreshold.inMilliseconds,
      },
    );

    _lastDispatchedTime = now;
    widget.onHesitationDetected?.call(payload);
  }

  @override
  void dispose() {
    _hesitationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = widget.child;

    if (widget.enableHoverTracking) {
      content = MouseRegion(
        onEnter: (_) => _onInteractionStart(),
        onExit: (_) => _onInteractionEnd(),
        child: content,
      );
    }

    if (widget.enableTouchTracking) {
      content = Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _onInteractionStart(),
        onPointerUp: (_) => _onInteractionEnd(),
        onPointerCancel: (_) => _onInteractionEnd(),
        child: content,
      );
    }

    return content;
  }
}
