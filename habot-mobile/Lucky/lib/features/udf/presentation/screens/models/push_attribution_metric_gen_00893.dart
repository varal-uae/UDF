// GEN-00893 — Data Model: Metric configuration & evaluation result for 'Event Dispatch Latency'.
// Encodes floor / optimal / ceiling boundaries defined in the atomic requirement.

import 'package:meta/meta.dart';

import 'push_attribution_event_gen_00893.dart';

/// Evaluation result for a measured latency value against configured boundaries.
enum MetricVerdict { optimal, acceptable, degraded, failed }

/// Immutable configuration of the 'Event Dispatch Latency' metric.
@immutable
class EventDispatchLatencyMetric {
  const EventDispatchLatencyMetric({
    this.floorBoundaryMs = 50,
    this.optimalTargetMs = 15,
    this.ceilingBoundaryMs = 100,
  });

  /// Floor threshold: values at or below are considered passing.
  final int floorBoundaryMs;

  /// Optimal target: gold-standard dispatch latency.
  final int optimalTargetMs;

  /// Ceiling boundary: anything above is a hard failure.
  final int ceilingBoundaryMs;

  /// Evaluates a sampled latency against the metric boundaries.
  MetricVerdict evaluate(int latencyMs) {
    if (latencyMs < 0) {
      return MetricVerdict.failed;
    }
    if (latencyMs <= optimalTargetMs) {
      return MetricVerdict.optimal;
    }
    if (latencyMs <= floorBoundaryMs) {
      return MetricVerdict.acceptable;
    }
    if (latencyMs <= ceilingBoundaryMs) {
      return MetricVerdict.degraded;
    }
    return MetricVerdict.failed;
  }

  /// Maps a verdict to the human-readable gate output defined by the spec.
  CompletionStatus toCompletionStatus(MetricVerdict verdict) {
    switch (verdict) {
      case MetricVerdict.optimal:
      case MetricVerdict.acceptable:
        return CompletionStatus.pass;
      case MetricVerdict.degraded:
      case MetricVerdict.failed:
        return CompletionStatus.fail;
    }
  }
}
