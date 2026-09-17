// GEN-00893 — Controller: Orchestrates dispatch validation, metric evaluation and manual sync refresh.
// Keeps UI stateless-friendly by exposing immutable view state to the widget layer.

import 'package:flutter/foundation.dart';

import '../data/push_attribution_mock_data_gen_00893.dart';
import '../models/push_attribution_event_gen_00893.dart';
import '../models/push_attribution_metric_gen_00893.dart';

/// Immutable snapshot consumed by the M3 engineering console screen.
@immutable
class PushAttributionViewState {
  const PushAttributionViewState({
    required this.events,
    required this.lastSyncedAt,
  });

  final List<PushAttributionEvent> events;
  final DateTime lastSyncedAt;

  /// Aggregate gate outcome across all dispatched events.
  CompletionStatus get overallStatus =>
      events.every((PushAttributionEvent e) => e.completionStatus == CompletionStatus.pass)
          ? CompletionStatus.pass
          : CompletionStatus.fail;

  /// Mean dispatch latency across all events, rounded to the nearest millisecond.
  int get averageLatencyMs {
    if (events.isEmpty) {
      return 0;
    }
    final int total = events.fold<int>(0, (int sum, PushAttributionEvent e) => sum + e.latencyMs);
    return (total / events.length).round();
  }
}

/// Owns the console state and the metric evaluation logic for GEN-00893.
class PushAttributionController extends ChangeNotifier {
  PushAttributionController({
    EventDispatchLatencyMetric? metric,
  }) : _metric = metric ?? const EventDispatchLatencyMetric();

  final EventDispatchLatencyMetric _metric;

  PushAttributionViewState _state = PushAttributionViewState(
    events: PushAttributionMockData.sampleEvents(),
    lastSyncedAt: DateTime.now().toUtc(),
  );

  /// Read-only snapshot for the presentation layer.
  PushAttributionViewState get state => _state;

  /// Evaluates a raw latency value using the configured metric boundaries.
  MetricVerdict evaluateLatency(int latencyMs) => _metric.evaluate(latencyMs);

  /// Simulates a pull-to-refresh manual sync of dispatched conversion events.
  void refresh() {
    _state = PushAttributionViewState(
      events: PushAttributionMockData.sampleEvents(),
      lastSyncedAt: DateTime.now().toUtc(),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
