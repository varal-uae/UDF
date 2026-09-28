// GEN-04302 — Route Guard Middleware for Authentication State Verification.
// Implements navigation route guard middleware to verify user authentication states before allowing access to protected routes. Enforces Material Design 3 motion and navigation guidelines with sub-100ms response latency targets.

import 'package:flutter/material.dart';

/// Enum representing the qualitative output for navigation interaction response latency.
enum NavigationLatencyStatus { good, average, poor }

/// Mock authentication state provider simulating backend auth verification.
class MockAuthStateProvider {
  static bool _isAuthenticated = false;

  static bool get isAuthenticated => _isAuthenticated;

  static void setAuthenticated(bool value) {
    _isAuthenticated = value;
  }

  /// Simulates an async auth check with realistic latency.
  static Future<bool> verifyAuthentication() async {
    // Simulate network/local storage check delay (target < 100ms)
    await Future.delayed(const Duration(milliseconds: 45));
    return _isAuthenticated;
  }
}

/// Telemetry event model for BigQuery alignment (partitioned by event_date, clustered by trace_id).
class RouteGuardTelemetryEvent {
  final String atomicId;
  final String traceId;
  final DateTime eventDate;
  final String routeName;
  final bool accessGranted;
  final int latencyMs;
  final NavigationLatencyStatus status;
  final String sessionId;

  RouteGuardTelemetryEvent({
    required this.atomicId,
    required this.traceId,
    required this.eventDate,
    required this.routeName,
    required this.accessGranted,
    required this.latencyMs,
    required this.status,
    required this.sessionId,
  });

  Map<String, dynamic> toJson() => {
        'atomic_id': atomicId,
        'trace_id': traceId,
        'event_date': eventDate.toIso8601String(),
        'route_name': routeName,
        'access_granted': accessGranted,
        'latency_ms': latencyMs,
        'status': status.name,
        'session_id': sessionId,
      };
}

/// Route guard middleware that verifies authentication states.
/// 
/// Implements M3 Motion & Navigation Guidelines.
/// Floor threshold: < 300ms, Optimal target: < 100ms, Ceiling: < 16ms.
class AuthRouteGuardMiddleware {
  static const String _atomicId = 'GEN-04302';
  static const int _floorThresholdMs = 300;
  static const int _optimalTargetMs = 100;

  final List<RouteGuardTelemetryEvent> _telemetryLog = [];

  List<RouteGuardTelemetryEvent> get telemetryLog => List.unmodifiable(_telemetryLog);

  /// Evaluates the latency and returns qualitative status per MD3 guidelines.
  NavigationLatencyStatus _evaluateLatency(int latencyMs) {
    if (latencyMs <= _optimalTargetMs) return NavigationLatencyStatus.good;
    if (latencyMs <= _floorThresholdMs) return NavigationLatencyStatus.average;
    return NavigationLatencyStatus.poor;
  }

  /// Core route guard execution method.
  /// Returns true if navigation is allowed, false if blocked/redirected.
  Future<bool> evaluateRoute({
    required BuildContext context,
    required String targetRoute,
    required String sessionId,
    String? redirectRoute,
  }) async {
    final stopwatch = Stopwatch()..start();
    final traceId = 'trace_${DateTime.now().millisecondsSinceEpoch}';

    final bool isAuth = await MockAuthStateProvider.verifyAuthentication();

    stopwatch.stop();
    final int latencyMs = stopwatch.elapsedMilliseconds;
    final NavigationLatencyStatus status = _evaluateLatency(latencyMs);

    final event = RouteGuardTelemetryEvent(
      atomicId: _atomicId,
      traceId: traceId,
      eventDate: DateTime.now(),
      routeName: targetRoute,
      accessGranted: isAuth,
      latencyMs: latencyMs,
      status: status,
      sessionId: sessionId,
    );

    _telemetryLog.add(event);

    if (!isAuth && context.mounted) {
      final routeToPush = redirectRoute ?? '/auth/login';
      Navigator.of(context).pushReplacementNamed(routeToPush);
      
      if (status == NavigationLatencyStatus.poor) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation latency exceeded floor threshold (${latencyMs}ms)'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return false;
    }

    return isAuth;
  }

  /// Generates a reusable GoRouter-style redirect function signature.
  /// Can be adapted for go_router's `redirect` property.
  Future<String?> generateRedirect({
    required BuildContext context,
    required String currentRoute,
    required String sessionId,
  }) async {
    final bool allowed = await evaluateRoute(
      context: context,
      targetRoute: currentRoute,
      sessionId: sessionId,
    );
    return allowed ? null : '/auth/login';
  }
}

/// M3 Elevated Card widget for Engineering Console displaying step health.
class RouteGuardHealthCard extends StatelessWidget {
  final RouteGuardTelemetryEvent latestEvent;

  const RouteGuardHealthCard({
    super.key,
    required this.latestEvent,
  });

  Color _getStatusColor(NavigationLatencyStatus status) {
    switch (status) {
      case NavigationLatencyStatus.good:
        return Colors.green;
      case NavigationLatencyStatus.average:
        return Colors.orange;
      case NavigationLatencyStatus.poor:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Route Guard Health',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Chip(
                  label: Text(
                    latestEvent.status.name.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(latestEvent.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: _getStatusColor(latestEvent.status).withOpacity(0.1),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Latency',
                    value: '${latestEvent.latencyMs}ms',
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    label: 'Access',
                    value: latestEvent.accessGranted ? 'Granted' : 'Denied',
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    label: 'Trace ID',
                    value: latestEvent.traceId.substring(0, 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;

  const _MetricTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

/// Global singleton instance for route guard middleware.
final authRouteGuard = AuthRouteGuardMiddleware();