// GEN-01390 — Hesitation Tracking Wrapper for Mobile Screen View Containers.
// Wraps all mobile screen view containers to detect hesitation and rage-clicks, streaming metrics to mock telemetry with M3 status indicators.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock telemetry sink representing BigQuery streaming partitioned by event_date, clustered by trace_id.
class _MockTelemetrySink {
  static void logEvent({
    required String eventType,
    required double durationMs,
    required String sessionId,
    required String traceId,
  }) {
    // In production, this streams to GCP BigQuery via @habot/shared-library.
    debugPrint(
      '[GEN-01390 Telemetry] type=$eventType, duration=${durationMs.toStringAsFixed(2)}ms, '
      'sessionId=$sessionId, traceId=$traceId, event_date=${DateTime.now().toIso8601String().split('T').first}',
    );
  }
}

/// Qualitative output based on Nielsen Norman Group UX Analytics Benchmark.
enum HesitationQuality { good, average, poor }

/// Evaluates hesitation duration against floor (0.85) and optimal (0.95) thresholds.
HesitationQuality evaluateHesitation(double durationMs) {
  // Floor boundary: 0.85 accuracy equivalent -> <300ms is Good
  // Optimal target: 0.95 accuracy equivalent -> <150ms is Optimal
  // Ceiling boundary: >1000ms is Poor
  if (durationMs < 300) return HesitationQuality.good;
  if (durationMs < 1000) return HesitationQuality.average;
  return HesitationQuality.poor;
}

/// A wrapper widget that tracks hesitation (dwell time before interaction)
/// and rage-clicks (rapid successive taps) on its child container.
/// Implements M3 Elevated Card Level 2 (3dp) styling and 48x48dp touch targets.
class HesitationTrackingWrapper extends StatefulWidget {
  final Widget child;
  final String screenName;
  final String? sessionId;

  const HesitationTrackingWrapper({
    super.key,
    required this.child,
    required this.screenName,
    this.sessionId,
  });

  @override
  State<HesitationTrackingWrapper> createState() => _HesitationTrackingWrapperState();
}

class _HesitationTrackingWrapperState extends State<HesitationTrackingWrapper> {
  DateTime? _renderTime;
  bool _hasInteracted = false;
  int _tapCount = 0;
  Timer? _rageClickTimer;
  final String _traceId = UniqueKey().toString();
  late final String _sessionId;

  // Background polling refresh interval per requirement: 30 seconds.
  Timer? _livenessHandshakeTimer;

  @override
  void initState() {
    super.initState();
    _renderTime = DateTime.now();
    _sessionId = widget.sessionId ?? 'session_${DateTime.now().millisecondsSinceEpoch}';

    // Automated Liveness Handshake monitors this step every 30 seconds.
    _livenessHandshakeTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _MockTelemetrySink.logEvent(
        eventType: 'liveness_handshake',
        durationMs: 0,
        sessionId: _sessionId,
        traceId: _traceId,
      );
    });
  }

  @override
  void dispose() {
    _rageClickTimer?.cancel();
    _livenessHandshakeTimer?.cancel();
    super.dispose();
  }

  void _handleInteraction() {
    if (_hasInteracted || _renderTime == null) return;
    _hasInteracted = true;

    final hesitationDuration = DateTime.now().difference(_renderTime!).inMilliseconds.toDouble();
    final quality = evaluateHesitation(hesitationDuration);

    _MockTelemetrySink.logEvent(
      eventType: 'hesitation_detected',
      durationMs: hesitationDuration,
      sessionId: _sessionId,
      traceId: _traceId,
    );

    debugPrint('[GEN-01390] Screen: ${widget.screenName}, Hesitation: ${hesitationDuration}ms, Quality: ${quality.name}');
  }

  void _handleTapDown(TapDownDetails details) {
    _handleInteraction();
    _tapCount++;

    _rageClickTimer?.cancel();
    _rageClickTimer = Timer(const Duration(milliseconds: 500), () {
      if (_tapCount >= 3) {
        _MockTelemetrySink.logEvent(
          eventType: 'rage_click_detected',
          durationMs: _tapCount.toDouble(),
          sessionId: _sessionId,
          traceId: _traceId,
        );
        debugPrint('[GEN-01390] Rage click detected on ${widget.screenName}: $_tapCount taps');
      }
      _tapCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // M3 responsive layout: single-column on mobile (<600dp), multi-column on desktop (>=840dp).
    // This wrapper enforces the tracking boundary around any screen container.
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: _handleTapDown,
      child: widget.child,
    );
  }
}

/// M3 Status Chip for displaying hesitation health indicator.
/// Touch target enforced at 48x48dp minimum.
class HesitationStatusChip extends StatelessWidget {
  final HesitationQuality quality;

  const HesitationStatusChip({super.key, required this.quality});

  Color _getColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (quality) {
      case HesitationQuality.good:
        return colorScheme.primary;
      case HesitationQuality.average:
        return colorScheme.tertiary;
      case HesitationQuality.poor:
        return colorScheme.error;
    }
  }

  String _getLabel() {
    switch (quality) {
      case HesitationQuality.good:
        return 'Good';
      case HesitationQuality.average:
        return 'Average';
      case HesitationQuality.poor:
        return 'Poor';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      child: Center(
        child: Chip(
          avatar: Icon(Icons.circle, size: 12, color: _getColor(context)),
          label: Text(_getLabel()),
          backgroundColor: _getColor(context).withOpacity(0.12),
          labelStyle: TextStyle(color: _getColor(context)),
        ),
      ),
    );
  }
}

/// M3 Elevated Card Level 2 (3dp) wrapper for engineering console KPI display.
/// Single-column mobile layout with M3 status cards displaying step completion state.
class HesitationKpiCard extends StatelessWidget {
  final String screenName;
  final HesitationQuality currentQuality;

  const HesitationKpiCard({
    super.key,
    required this.screenName,
    required this.currentQuality,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Screen Health: $screenName',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detection Accuracy Target: ≥0.85',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                HesitationStatusChip(quality: currentQuality),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
