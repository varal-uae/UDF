import 'package:flutter/foundation.dart';

// ARCPE-001 — Auth Abandon Telemetry.
// Spec: "Real-time tracking of sign-up drops within the core operational monitoring layout."
//       "Events pushed via Pub/Sub to trigger streaming real-time analytical records."
//
// Fires when user leaves login/signup screen without submitting.
// Stub ready — wire Pub/Sub endpoint when backend provides URL.

enum AuthAbandonPoint {
  loginScreen,    // Left login without submitting
  signupScreen,   // Left signup without completing
  splashScreen,   // Closed app during splash
}

abstract class AuthAbandonTelemetry {
  AuthAbandonTelemetry._();

  /// Call when user abandons auth screen.
  /// [abandonPoint] — where they dropped off.
  /// [filledFields] — which fields had content (for drop-off analysis).
  static Future<void> trackAbandon({
    required AuthAbandonPoint abandonPoint,
    required List<String> filledFields,
    String? sessionId,
    String? userId,
  }) async {
    final payload = {
      'event':        'auth_abandon',
      'abandon_point': abandonPoint.name,
      'filled_fields': filledFields,
      'session_id':    sessionId,
      'user_id':       userId,
      'timestamp':     DateTime.now().toUtc().toIso8601String(),
    };

    // Debug logging — visible in console during development
    debugPrint('[AuthAbandonTelemetry] ${payload.toString()}');

    // ⏳ Stub — replace with real Pub/Sub call when backend provides endpoint
    // await HabotHttpClient.instance.post(
    //   '/analytics/auth-abandon',
    //   data: payload,
    // );
  }
}
