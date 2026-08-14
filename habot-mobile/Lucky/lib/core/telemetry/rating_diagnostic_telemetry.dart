import 'dart:developer' as developer;

import 'failure_reason_catalog.dart';

// IS27-FEBFL-024-AS01-A01 — Rating diagnostic telemetry.
// Streams low-rating incident metrics to cluster analytics (Pub/Sub stub).

class RatingDiagnosticTelemetry {
  RatingDiagnosticTelemetry._();

  static Future<void> dispatch({
    required RatingDiagnosticPayload payload,
    String? sessionId,
    String? userId,
  }) async {
    final event = {
      ...payload.toMap(),
      'event':      'low_rating_diagnostic_submitted',
      'session_id': sessionId,
      'user_id':    userId,
      'platform':   'mobile',
      'source':     'LowRatingDiagnosticForm',
      'priority':   'high',
    };

    developer.log(
      '[RatingDiagnostic] score=${payload.score} reasons=${payload.reasons.length}',
      name: 'IS27-FEBFL-024',
    );

    await _sendToAnalytics(event);
  }

  /// TODO: Replace with Pub/Sub / support ticket endpoint when backend ready.
  static Future<void> _sendToAnalytics(Map<String, dynamic> payload) async {
    // await http.post(Uri.parse('<RATING_DIAGNOSTIC_ENDPOINT>'), body: jsonEncode(payload));
  }
}
