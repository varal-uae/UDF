// GEN-00893 — Data Model: Push campaign attribution & in-app engagement conversion event entity.
// Encapsulates the payload dispatched to Pub/Sub / BigQuery analytics.push_attribution_conversions.

import 'package:meta/meta.dart';

/// Immutable value object representing a single re-engagement conversion event.
@immutable
class PushAttributionEvent {
  const PushAttributionEvent({
    required this.eventId,
    required this.sessionId,
    required this.campaignId,
    required this.traceId,
    required this.eventTimestamp,
    required this.channel,
    required this.latencyMs,
    required this.completionStatus,
  });

  /// Unique identifier of the dispatched event (dedupe key downstream).
  final String eventId;

  /// User/session identifier captured by the mobile SDK.
  final String sessionId;

  /// Originating push campaign identifier that triggered re-engagement.
  final String campaignId;

  /// Distributed tracing id; used as BigQuery clustering key.
  final String traceId;

  /// Event occurrence time (UTC).
  final DateTime eventTimestamp;

  /// Originating engagement channel (push, in-app, deep-link).
  final PushEngagementChannel channel;

  /// Measured dispatch latency in milliseconds.
  final int latencyMs;

  /// Validation outcome captured from the step gate.
  final CompletionStatus completionStatus;

  /// Serializes the event for Pub/Sub streaming (partitioned by event_date, clustered by trace_id).
  Map<String, Object?> toPubSubPayload() {
    return <String, Object?>{
      'event_id': eventId,
      'session_id': sessionId,
      'campaign_id': campaignId,
      'trace_id': traceId,
      'event_date': _isoDate(eventTimestamp),
      'event_timestamp': eventTimestamp.toUtc().toIso8601String(),
      'channel': channel.name,
      'latency_ms': latencyMs,
      'completion_status': completionStatus.name,
    };
  }

  /// Produces a copy with adjusted fields, preserving immutability semantics.
  PushAttributionEvent copyWith({
    String? eventId,
    String? sessionId,
    String? campaignId,
    String? traceId,
    DateTime? eventTimestamp,
    PushEngagementChannel? channel,
    int? latencyMs,
    CompletionStatus? completionStatus,
  }) {
    return PushAttributionEvent(
      eventId: eventId ?? this.eventId,
      sessionId: sessionId ?? this.sessionId,
      campaignId: campaignId ?? this.campaignId,
      traceId: traceId ?? this.traceId,
      eventTimestamp: eventTimestamp ?? this.eventTimestamp,
      channel: channel ?? this.channel,
      latencyMs: latencyMs ?? this.latencyMs,
      completionStatus: completionStatus ?? this.completionStatus,
    );
  }

  static String _isoDate(DateTime value) {
    final DateTime utc = value.toUtc();
    final String month = utc.month.toString().padLeft(2, '0');
    final String day = utc.day.toString().padLeft(2, '0');
    return '${utc.year}-$month-$day';
  }
}

/// Channels that can originate a re-engagement conversion.
enum PushEngagementChannel { push, inApp, deepLink }

/// Gate outcome for the atomic step (Pass / Fail).
enum CompletionStatus { pass, fail }
