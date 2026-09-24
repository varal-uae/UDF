// GEN-02238 — Silent onHover / onTouch background trackers for mobile and MTO UI components.
// Injects silent interaction timers as background trackers, streams events to mock BigQuery telemetry, and enforces ITIL v4 Exception Queue Resolution Time thresholds with M3 status reporting.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock data simulating backend/BigQuery streaming alignment for GEN-02238.
class TelemetryMockData {
  static const String partitionField = 'event_date';
  static const String clusterField = 'trace_id';
  static const String metricName = 'Exception Queue Resolution Time';
  static const int floorBoundaryMinutes = 30;
  static const int optimalTargetMinutes = 15;
  static const int ceilingBoundaryMinutes = 5;
  static const Duration pollingInterval = Duration(seconds: 30);

  static Map<String, dynamic> generateEvent({
    required String type,
    required String sessionId,
    required int durationMs,
  }) {
    return {
      'type': type,
      'sessionId': sessionId,
      'durationMs': durationMs,
      'timestamp': DateTime.now().toIso8601String(),
      'trace_id': UniqueKey().toString(),
      'completionStatus': durationMs <= (ceilingBoundaryMinutes * 60000) ? 'Pass' : 'Fail',
    };
  }
}

/// Core reusable tracker module for silent onHover / onTouch background tracking.
class InteractionTrackerGen02238 {
  final String sessionId;
  final void Function(Map<String, dynamic> event)? onEventCaptured;

  Timer? _hoverTimer;
  Timer? _touchTimer;
  Stopwatch? _stopwatch;

  InteractionTrackerGen02238({
    required this.sessionId,
    this.onEventCaptured,
  });

  void startHoverTracking() {
    _stopwatch = Stopwatch()..start();
    _hoverTimer = Timer.periodic(TelemetryMockData.pollingInterval, (_) {
      _emitEvent('onHover');
    });
  }

  void stopHoverTracking() {
    _hoverTimer?.cancel();
    _hoverTimer = null;
    if (_stopwatch != null && _stopwatch!.isRunning) {
      _emitEvent('onHover');
      _stopwatch!.stop();
    }
  }

  void startTouchTracking() {
    _stopwatch = Stopwatch()..start();
    _touchTimer = Timer.periodic(TelemetryMockData.pollingInterval, (_) {
      _emitEvent('onTouch');
    });
  }

  void stopTouchTracking() {
    _touchTimer?.cancel();
    _touchTimer = null;
    if (_stopwatch != null && _stopwatch!.isRunning) {
      _emitEvent('onTouch');
      _stopwatch!.stop();
    }
  }

  void _emitEvent(String type) {
    final durationMs = _stopwatch?.elapsedMilliseconds ?? 0;
    final event = TelemetryMockData.generateEvent(
      type: type,
      sessionId: sessionId,
      durationMs: durationMs,
    );
    onEventCaptured?.call(event);
  }

  void dispose() {
    stopHoverTracking();
    stopTouchTracking();
  }
}

/// Wrapper widget that injects silent hover and touch trackers into any child component.
class TrackedInteractionWidget extends StatefulWidget {
  final Widget child;
  final String sessionId;
  final void Function(Map<String, dynamic> event)? onEventCaptured;

  const TrackedInteractionWidget({
    super.key,
    required this.child,
    this.sessionId = 'default-session-gen-02238',
    this.onEventCaptured,
  });

  @override
  State<TrackedInteractionWidget> createState() => _TrackedInteractionWidgetState();
}

class _TrackedInteractionWidgetState extends State<TrackedInteractionWidget> {
  late InteractionTrackerGen02238 _tracker;

  @override
  void initState() {
    super.initState();
    _tracker = InteractionTrackerGen02238(
      sessionId: widget.sessionId,
      onEventCaptured: widget.onEventCaptured ?? _defaultStreamToBigQuery,
    );
  }

  void _defaultStreamToBigQuery(Map<String, dynamic> event) {
    // Simulates streaming to BigQuery partitioned by event_date, clustered by trace_id
    debugPrint('[GEN-02238 BigQuery Stream] $event');
  }

  @override
  void dispose() {
    _tracker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _tracker.startHoverTracking(),
      onExit: (_) => _tracker.stopHoverTracking(),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (_) => _tracker.startTouchTracking(),
        onTapUp: (_) => _tracker.stopTouchTracking(),
        onTapCancel: () => _tracker.stopTouchTracking(),
        child: widget.child,
      ),
    );
  }
}

/// M3 Elevated Card displaying step completion state and health indicators.
class TrackerStatusCard extends StatelessWidget {
  final Map<String, dynamic>? latestEvent;

  const TrackerStatusCard({super.key, this.latestEvent});

  bool get _isPass {
    if (latestEvent == null) return false;
    return latestEvent!['completionStatus'] == 'Pass';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTabletOrDesktop = constraints.maxWidth >= 840;

        return Card(
          elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
          color: colorScheme.surfaceContainerHighest,
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Flex(
              direction: isMobile ? Axis.vertical : Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GEN-02238 Tracker Health',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Metric: ${TelemetryMockData.metricName}',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      'Floor: ${TelemetryMockData.floorBoundaryMinutes}m | Optimal: ${TelemetryMockData.optimalTargetMinutes}m | Ceiling: ${TelemetryMockData.ceilingBoundaryMinutes}m',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12, width: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      avatar: Icon(
                        _isPass ? Icons.check_circle : Icons.error,
                        size: 18,
                        color: _isPass ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
                      ),
                      label: Text(_isPass ? 'Pass' : 'Fail'),
                      backgroundColor: _isPass ? colorScheme.primaryContainer : colorScheme.errorContainer,
                      labelStyle: TextStyle(
                        color: _isPass ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (latestEvent != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        '${latestEvent!['durationMs']}ms',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Engineering Console Screen demonstrating the implementation.
class EngineeringConsoleScreenGen02238 extends StatefulWidget {
  const EngineeringConsoleScreenGen02238({super.key});

  @override
  State<EngineeringConsoleScreenGen02238> createState() => _EngineeringConsoleScreenState();
}

class _EngineeringConsoleScreenState extends State<EngineeringConsoleScreenGen02238> {
  Map<String, dynamic>? _latestEvent;
  final List<Map<String, dynamic>> _eventLog = [];

  void _handleEvent(Map<String, dynamic> event) {
    setState(() {
      _latestEvent = event;
      _eventLog.add(event);
    });

    // Automated Liveness Handshake / CI/CD gate simulation
    if (event['completionStatus'] == 'Fail') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Liveness Handshake Alert: Step failed validation. Rollback triggered.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'DISMISS',
            textColor: Theme.of(context).colorScheme.onError,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  void _openConfigBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Configuration Inputs', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Session ID Override',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Configuration saved successfully.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Apply Config'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UDF Engineering Console'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openConfigBottomSheet,
            tooltip: 'Configuration',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Pull-to-refresh triggers manual sync
          await Future.delayed(const Duration(milliseconds: 500));
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TrackerStatusCard(latestEvent: _latestEvent),
              const SizedBox(height: 24),
              Text('Interactive Test Area', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TrackedInteractionWidget(
                sessionId: 'console-session-gen-02238',
                onEventCaptured: _handleEvent,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Hover or Tap here to trigger silent trackers\n(Minimum 48x48dp touch target enforced)',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Recent Event Log', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ..._eventLog.reversed.take(5).map((e) => Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    e['completionStatus'] == 'Pass' ? Icons.check_circle_outline : Icons.highlight_off,
                    color: e['completionStatus'] == 'Pass' ? Colors.green : Colors.red,
                  ),
                  title: Text('${e['type']} - ${e['durationMs']}ms'),
                  subtitle: Text('Trace: ${e['trace_id']}'),
                  trailing: Text(e['completionStatus']),
                ),
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }
}