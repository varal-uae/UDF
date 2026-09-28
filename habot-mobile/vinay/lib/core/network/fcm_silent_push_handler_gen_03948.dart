// GEN-03948 — FCM Silent Push Handler for clearing the active task screen.
// Listens for silent push notifications and programmatically pops the active task route if currently displayed, targeting <16ms execution delay.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data representing the expected FCM silent push payload structure.
class FcmSilentPushMockData {
  static const Map<String, dynamic> clearTaskPayload = {
    'action': 'clear_active_task',
    'trace_id': 'mock-trace-gen-03948-001',
    'timestamp_ms': 1727500000000,
    'data': {
      'task_id': 'task_999',
      'force_clear': true,
    },
  };
}

/// Service responsible for handling FCM silent pushes and clearing the active task screen.
class FcmSilentPushHandlerGen03948 {
  FcmSilentPushHandlerGen03948._();
  static final FcmSilentPushHandlerGen03948 instance = FcmSilentPushHandlerGen03948._();

  final StreamController<Map<String, dynamic>> _silentPushController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of incoming silent push payloads.
  Stream<Map<String, dynamic>> get silentPushStream => _silentPushController.stream;

  GlobalKey<NavigatorState>? _navigatorKey;

  /// Initializes the handler with the app's root navigator key.
  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    _silentPushController.stream.listen(_handleSilentPush);
  }

  /// Simulates receiving a silent push (for testing/local mock purposes).
  void simulateSilentPush(Map<String, dynamic> payload) {
    _silentPushController.add(payload);
  }

  Future<void> _handleSilentPush(Map<String, dynamic> payload) async {
    final stopwatch = Stopwatch()..start();

    try {
      final String? action = payload['action'] as String?;
      if (action == 'clear_active_task') {
        await _clearActiveTaskScreen();
      }
    } catch (e) {
      debugPrint('[GEN-03948] Error handling silent push: $e');
    } finally {
      stopwatch.stop();
      final int elapsedMs = stopwatch.elapsedMilliseconds;
      debugPrint('[GEN-03948] Screen Clear Execution Delay: ${elapsedMs}ms');

      // Log metric against boundaries: Floor < 33ms, Optimal < 16ms, Ceiling 50ms
      if (elapsedMs > 50) {
        debugPrint('[GEN-03948] WARNING: Exceeded ceiling boundary of 50ms.');
      } else if (elapsedMs < 16) {
        debugPrint('[GEN-03948] SUCCESS: Met optimal target of < 16ms.');
      } else if (elapsedMs < 33) {
        debugPrint('[GEN-03948] SUCCESS: Met floor threshold of < 33ms.');
      }

      _logTelemetry(payload, elapsedMs);
    }
  }

  Future<void> _clearActiveTaskScreen() async {
    final NavigatorState? navigator = _navigatorKey?.currentState;
    if (navigator == null || !navigator.mounted) return;

    // Check if the current route is the active task screen.
    // Using a generic route name check; adjust '/active-task' to match actual UDF routing.
    bool isOnActiveTaskScreen = false;
    navigator.popUntil((route) {
      if (route.settings.name == '/active-task' || route.settings.name == 'ActiveTaskScreen') {
        isOnActiveTaskScreen = true;
      }
      return true; // Do not actually pop here, just inspect
    });

    if (isOnActiveTaskScreen) {
      // Programmatically pop the active task screen if it is currently open.
      navigator.popUntil((route) {
        return route.settings.name != '/active-task' &&
            route.settings.name != 'ActiveTaskScreen';
      });
      debugPrint('[GEN-03948] Active task screen cleared successfully.');
    } else {
      debugPrint('[GEN-03948] Active task screen was not open. No action taken.');
    }
  }

  void _logTelemetry(Map<String, dynamic> payload, int delayMs) {
    // Mock telemetry logging aligned with BigQuery partitioning requirements
    final Map<String, dynamic> telemetryEvent = {
      'event_name': 'screen_clear_execution',
      'event_date': DateTime.now().toIso8601String().split('T').first,
      'trace_id': payload['trace_id'] ?? 'unknown',
      'execution_delay_ms': delayMs,
      'completion_status': delayMs <= 50 ? 'Complete' : 'Not Complete',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    debugPrint('[GEN-03948] Telemetry Event: $telemetryEvent');
  }

  void dispose() {
    _silentPushController.close();
  }
}

/// Mixin or helper to trigger mock silent push from UI for engineering console validation.
mixin SilentPushTestMixin<T extends StatefulWidget> on State<T> {
  void triggerMockClearTaskPush() {
    FcmSilentPushHandlerGen03948.instance
        .simulateSilentPush(FcmSilentPushMockData.clearTaskPayload);
  }
}