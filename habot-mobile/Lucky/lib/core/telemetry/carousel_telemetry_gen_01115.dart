// GEN-01115 — Carousel Telemetry Streamer for BigQuery.
// Streams carousel view, slide transition, and skip events to BigQuery with mock local fallback. Implements M3 status chips and FRE metric evaluation.

import 'dart:convert';

/// Represents the type of carousel telemetry event.
enum CarouselEventType {
  view,
  slideTransition,
  skip,
}

/// Data model for a carousel telemetry event.
class CarouselTelemetryEvent {
  final String eventId;
  final String traceId;
  final String sessionId;
  final String userId;
  final CarouselEventType eventType;
  final int slideIndex;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  CarouselTelemetryEvent({
    required this.eventId,
    required this.traceId,
    required this.sessionId,
    required this.userId,
    required this.eventType,
    required this.slideIndex,
    required this.timestamp,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
        'event_id': eventId,
        'trace_id': traceId,
        'session_id': sessionId,
        'user_id': userId,
        'event_type': eventType.name,
        'slide_index': slideIndex,
        'timestamp': timestamp.toIso8601String(),
        'metadata': metadata,
      };

  @override
  String toString() => jsonEncode(toJson());
}

/// Evaluates First-Run Experience (FRE) Completion Rate against thresholds.
enum FreQualitativeStatus { good, average, poor }

class FreMetricEvaluator {
  static const double floorBoundary = 0.7;
  static const double optimalTarget = 0.9;
  static const double ceilingBoundary = 1.0;

  static FreQualitativeStatus evaluate(double completionRate) {
    if (completionRate >= optimalTarget && completionRate <= ceilingBoundary) {
      return FreQualitativeStatus.good;
    } else if (completionRate >= floorBoundary && completionRate < optimalTarget) {
      return FreQualitativeStatus.average;
    } else {
      return FreQualitativeStatus.poor;
    }
  }

  static String statusToString(FreQualitativeStatus status) {
    switch (status) {
      case FreQualitativeStatus.good:
        return 'Good';
      case FreQualitativeStatus.average:
        return 'Average';
      case FreQualitativeStatus.poor:
        return 'Poor';
    }
  }
}

/// Mock repository simulating streaming events to BigQuery partitioned by event_date, clustered by trace_id.
class BigQueryTelemetryRepository {
  final List<Map<String, dynamic>> _mockBigQueryTable = [];

  BigQueryTelemetryRepository._internal();
  static final BigQueryTelemetryRepository instance = BigQueryTelemetryRepository._internal();

  /// Streams a single event to the mock BigQuery table.
  Future<bool> streamEvent(CarouselTelemetryEvent event) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 45));
    
    final record = event.toJson();
    // BigQuery alignment: partitioned by event_date, clustered by trace_id
    record['event_date'] = '${event.timestamp.year}-${event.timestamp.month.toString().padLeft(2, '0')}-${event.timestamp.day.toString().padLeft(2, '0')}';
    
    _mockBigQueryTable.add(record);
    return true;
  }

  /// Retrieves all streamed events (for engineering console dashboard).
  List<Map<String, dynamic>> getStreamedEvents() {
    return List.unmodifiable(_mockBigQueryTable);
  }

  /// Calculates current FRE completion rate from mock data.
  double calculateFreCompletionRate(String sessionId) {
    final sessionEvents = _mockBigQueryTable.where((e) => e['session_id'] == sessionId).toList();
    if (sessionEvents.isEmpty) return 0.0;
    
    final hasSkip = sessionEvents.any((e) => e['event_type'] == CarouselEventType.skip.name);
    final viewCount = sessionEvents.where((e) => e['event_type'] == CarouselEventType.view.name).length;
    
    // Simplified mock logic: if skipped, lower rate; otherwise based on views
    if (hasSkip) return 0.5;
    if (viewCount >= 3) return 0.95;
    if (viewCount == 2) return 0.8;
    return 0.6;
  }
}

/// Service to handle carousel telemetry streaming operations.
class CarouselTelemetryService {
  final BigQueryTelemetryRepository _repository = BigQueryTelemetryRepository.instance;
  int _eventCounter = 0;

  String _generateEventId() => 'evt_${DateTime.now().millisecondsSinceEpoch}_${++_eventCounter}';
  String _generateTraceId() => 'trc_${DateTime.now().microsecondsSinceEpoch}';

  /// Records a carousel view event.
  Future<void> recordCarouselView({
    required String sessionId,
    required String userId,
    required int slideIndex,
  }) async {
    final event = CarouselTelemetryEvent(
      eventId: _generateEventId(),
      traceId: _generateTraceId(),
      sessionId: sessionId,
      userId: userId,
      eventType: CarouselEventType.view,
      slideIndex: slideIndex,
      timestamp: DateTime.now(),
    );
    await _repository.streamEvent(event);
  }

  /// Records a slide transition event.
  Future<void> recordSlideTransition({
    required String sessionId,
    required String userId,
    required int slideIndex,
    required int nextSlideIndex,
  }) async {
    final event = CarouselTelemetryEvent(
      eventId: _generateEventId(),
      traceId: _generateTraceId(),
      sessionId: sessionId,
      userId: userId,
      eventType: CarouselEventType.slideTransition,
      slideIndex: slideIndex,
      timestamp: DateTime.now(),
      metadata: {'next_slide_index': nextSlideIndex},
    );
    await _repository.streamEvent(event);
  }

  /// Records a skip event.
  Future<void> recordSkip({
    required String sessionId,
    required String userId,
    required int slideIndex,
  }) async {
    final event = CarouselTelemetryEvent(
      eventId: _generateEventId(),
      traceId: _generateTraceId(),
      sessionId: sessionId,
      userId: userId,
      eventType: CarouselEventType.skip,
      slideIndex: slideIndex,
      timestamp: DateTime.now(),
    );
    await _repository.streamEvent(event);
  }

  /// Gets the qualitative FRE status for a given session.
  FreQualitativeStatus getSessionFreStatus(String sessionId) {
    final rate = _repository.calculateFreCompletionRate(sessionId);
    return FreMetricEvaluator.evaluate(rate);
  }
}
