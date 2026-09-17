// GEN-00825 — Real-Time Performance Clock & Latency SLA Monitor (byt_execution_time_ms).
// Measures execution time of instrumented operations, evaluates Pass/Fail against SLA
// boundaries (floor <= 1s, ceiling <= 3s), and streams metric events aligned to
// Google Cloud Ops Suite / BigQuery (partitioned by event_date, clustered by trace_id).

import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

/// SLA verdict for a single measured execution.
enum SlaVerdict { pass, fail }

/// SLA boundaries for the `Metric Push Delay` / `byt_execution_time_ms` metric.
///
/// Floor boundary: <= 1 sec (optimal target: instant).
/// Ceiling boundary: <= 3 secs. Anything beyond the ceiling is a hard failure.
@immutable
class LatencySlaThresholds {
  const LatencySlaThresholds({
    this.floor = const Duration(seconds: 1),
    this.ceiling = const Duration(seconds: 3),
  });

  /// Floor threshold: executions at or under this are fully compliant.
  final Duration floor;

  /// Ceiling threshold: executions above this violate the SLA.
  final Duration ceiling;

  /// Evaluates [elapsed] against the SLA boundaries.
  SlaVerdict evaluate(Duration elapsed) =>
      elapsed <= ceiling ? SlaVerdict.pass : SlaVerdict.fail;

  /// Whether [elapsed] meets the optimal (floor) target.
  bool isOptimal(Duration elapsed) => elapsed <= floor;
}

/// A single `byt_execution_time_ms` metric event.
///
/// Payload shape is aligned with the BigQuery streaming contract:
/// partitioned by [eventDate], clustered by [traceId].
@immutable
class LatencyMetricEvent {
  const LatencyMetricEvent({
    required this.metricName,
    required this.bytExecutionTimeMs,
    required this.verdict,
    required this.isOptimal,
    required this.timestamp,
    required this.traceId,
    required this.sessionId,
    required this.operation,
  });

  /// Metric identifier pushed to Google Cloud Monitoring.
  final String metricName;

  /// Measured execution time in milliseconds (`byt_execution_time_ms`).
  final double bytExecutionTimeMs;

  /// Pass / Fail qualitative output captured per the Ops Suite standard.
  final SlaVerdict verdict;

  /// Whether the execution met the floor (optimal) target.
  final bool isOptimal;

  /// Action/event timestamp (UTC).
  final DateTime timestamp;

  /// Trace identifier used for BigQuery clustering.
  final String traceId;

  /// User/session identifier collected by the system.
  final String sessionId;

  /// Logical name of the instrumented operation.
  final String operation;

  /// BigQuery partition key (YYYY-MM-DD) derived from [timestamp].
  String get eventDate {
    final utc = timestamp.toUtc();
    final mm = utc.month.toString().padLeft(2, '0');
    final dd = utc.day.toString().padLeft(2, '0');
    return '${utc.year}-$mm-$dd';
  }

  /// Serializes to the Cloud Monitoring / BigQuery export payload.
  Map<String, Object?> toJson() => <String, Object?>{
        'metric_name': metricName,
        'byt_execution_time_ms': bytExecutionTimeMs,
        'completion_status': verdict == SlaVerdict.pass ? 'Pass' : 'Fail',
        'is_optimal': isOptimal,
        'event_timestamp': timestamp.toUtc().toIso8601String(),
        'event_date': eventDate,
        'trace_id': traceId,
        'session_id': sessionId,
        'operation': operation,
        'standard': 'Google Cloud Ops Suite Standard',
      };
}

/// Sink responsible for exporting metric events to Google Cloud Monitoring
/// (and onward to BigQuery). Implementations must be non-blocking and
/// failure-isolated so telemetry never disrupts the measured operation.
abstract class LatencyMetricSink {
  FutureOr<void> emit(LatencyMetricEvent event);
}

/// Debug sink that prints events in debug builds only.
class DebugLatencyMetricSink implements LatencyMetricSink {
  const DebugLatencyMetricSink();

  @override
  FutureOr<void> emit(LatencyMetricEvent event) {
    assert(() {
      debugPrint('[GEN-00825] metric=${event.metricName} '
          'byt_execution_time_ms=${event.bytExecutionTimeMs} '
          'status=${event.verdict == SlaVerdict.pass ? 'Pass' : 'Fail'} '
          'trace=${event.traceId}');
      return true;
    }());
  }
}

/// Real-time performance clock and latency SLA monitor.
///
/// Wraps operations with a monotonic [Stopwatch], computes
/// `byt_execution_time_ms`, evaluates Pass/Fail against [thresholds],
/// and pushes the result to every registered [LatencyMetricSink].
///
/// Poka-yoke: emission errors are swallowed (and reported via [onError])
/// so telemetry can never crash the instrumented code path.
class LatencySlaMonitor {
  LatencySlaMonitor({
    required List<LatencyMetricSink> sinks,
    this.thresholds = const LatencySlaThresholds(),
    this.metricName = 'byt_execution_time_ms',
    this.onError,
  }) : _sinks = List<LatencyMetricSink>.unmodifiable(sinks);

  final List<LatencyMetricSink> _sinks;

  /// SLA boundaries (floor <= 1s, ceiling <= 3s).
  final LatencySlaThresholds thresholds;

  /// Metric name emitted to Cloud Monitoring.
  final String metricName;

  /// Optional observer for sink emission failures.
  final void Function(Object error, StackTrace stackTrace)? onError;

  final Queue<LatencyMetricEvent> _recent = Queue<LatencyMetricEvent>();

  /// Rolling window of the most recent events (max 100) for UI health chips.
  UnmodifiableListView<LatencyMetricEvent> get recentEvents =>
      UnmodifiableListView<LatencyMetricEvent>(_recent);

  /// Measures [operation] and emits a metric event with its execution time.
  ///
  /// Returns the operation's result unchanged; the measured value is never
  /// altered by telemetry.
  Future<T> measure<T>({
    required String operation,
    required String traceId,
    required String sessionId,
    required Future<T> Function() body,
  }) async {
    final sw = Stopwatch()..start();
    try {
      return await body();
    } finally {
      sw.stop();
      final elapsed = sw.elapsed;
      final event = LatencyMetricEvent(
        metricName: metricName,
        bytExecutionTimeMs: elapsed.inMicroseconds / 1000.0,
        verdict: thresholds.evaluate(elapsed),
        isOptimal: thresholds.isOptimal(elapsed),
        timestamp: DateTime.now().toUtc(),
        traceId: traceId,
        sessionId: sessionId,
        operation: operation,
      );
      _record(event);
      await _emitSafely(event);
    }
  }

  /// Synchronous variant of [measure] for non-async code paths.
  T measureSync<T>({
    required String operation,
    required String traceId,
    required String sessionId,
    required T Function() body,
  }) {
    final sw = Stopwatch()..start();
    try {
      return body();
    } finally {
      sw.stop();
      final elapsed = sw.elapsed;
      final event = LatencyMetricEvent(
        metricName: metricName,
        bytExecutionTimeMs: elapsed.inMicroseconds / 1000.0,
        verdict: thresholds.evaluate(elapsed),
        isOptimal: thresholds.isOptimal(elapsed),
        timestamp: DateTime.now().toUtc(),
        traceId: traceId,
        sessionId: sessionId,
        operation: operation,
      );
      _record(event);
      unawaited(_emitSafely(event));
    }
  }

  /// Aggregate pass rate (0.0–1.0) across the rolling window.
  double get passRate {
    if (_recent.isEmpty) return 1.0;
    final passes =
        _recent.where((e) => e.verdict == SlaVerdict.pass).length;
    return passes / _recent.length;
  }

  void _record(LatencyMetricEvent event) {
    _recent.addLast(event);
    while (_recent.length > 100) {
      _recent.removeFirst();
    }
  }

  Future<void> _emitSafely(LatencyMetricEvent event) async {
    for (final sink in _sinks) {
      try {
        await sink.emit(event);
      } catch (error, stackTrace) {
        onError?.call(error, stackTrace);
      }
    }
  }
}
