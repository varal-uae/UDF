import 'dart:async';

// BPTR-0269-A05 — Atomic speech recognition hook (<20 lines functional core).
// Wire speech_to_text package when added to pubspec for device-native STT.
// Web: replace body with web SpeechRecognition API bridge.

typedef SpeechResultHandler = void Function(String transcript);

/// Minimal speech hook — permission-safe fallback to text-only on failure.
abstract class SpeechHook {
  static Future<bool> listen({
    required SpeechResultHandler onResult,
    Duration pauseTimeout = const Duration(seconds: 4),
  }) async {
    // Stub: returns false → caller keeps text entry path (permission-safe fallback).
    // TODO: speech_to_text — SpeechToText().listen(onResult: onResult, pauseFor: pauseTimeout)
    return false;
  }

  static Future<void> stop() async {
    // TODO: speech_to_text — SpeechToText().stop()
  }
}
