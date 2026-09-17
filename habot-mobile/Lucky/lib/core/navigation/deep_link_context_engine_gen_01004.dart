// GEN-01004 — Automated Mobile Deep Link Routing & Context Restoration Engine.
// Clears cached deep link context from local memory immediately post-navigation and provides M3 UI status cards for the engineering console.

import 'dart:async';
import 'package:flutter/material.dart';

/// Mock telemetry event model for BigQuery alignment.
class DeepLinkTelemetryEvent {
  final String traceId;
  final DateTime eventDate;
  final String action;
  final String completionStatus;
  final String? sessionId;

  DeepLinkTelemetryEvent({
    required this.traceId,
    required this.eventDate,
    required this.action,
    required this.completionStatus,
    this.sessionId,
  });

  Map<String, dynamic> toJson() => {
        'trace_id': traceId,
        'event_date': eventDate.toIso8601String(),
        'action': action,
        'completion_status': completionStatus,
        'session_id': sessionId,
      };
}

/// Core engine responsible for routing, context restoration, and cache flushing.
class DeepLinkContextEngine {
  DeepLinkContextEngine._();
  static final DeepLinkContextEngine instance = DeepLinkContextEngine._();

  String? _cachedDeepLinkContext;
  final List<DeepLinkTelemetryEvent> _telemetryLog = [];

  bool get hasCachedContext => _cachedDeepLinkContext != null;
  String? get cachedContext => _cachedDeepLinkContext;
  List<DeepLinkTelemetryEvent> get telemetryLog => List.unmodifiable(_telemetryLog);

  /// Simulates receiving a deep link and caching its context.
  void receiveDeepLink(String uri, {String? sessionId}) {
    _cachedDeepLinkContext = uri;
    _logEvent(
      action: 'receive_deep_link',
      status: 'Complete',
      sessionId: sessionId,
    );
  }

  /// Clears cached deep link context from local memory immediately post-navigation.
  /// Floor threshold: Immediate (<= 1 sec).
  void flushContextCache({String? sessionId}) {
    final stopwatch = Stopwatch()..start();
    _cachedDeepLinkContext = null;
    stopwatch.stop();

    final flushTimeMs = stopwatch.elapsedMilliseconds;
    _logEvent(
      action: 'context_cache_flush',
      status: flushTimeMs <= 1000 ? 'Complete' : 'Not Complete',
      sessionId: sessionId,
    );
  }

  void _logEvent({
    required String action,
    required String status,
    String? sessionId,
  }) {
    _telemetryLog.add(DeepLinkTelemetryEvent(
      traceId: 'trace_${DateTime.now().millisecondsSinceEpoch}',
      eventDate: DateTime.now(),
      action: action,
      completionStatus: status,
      sessionId: sessionId,
    ));
  }
}

/// M3 Engineering Console Screen displaying step health and deep-link drill-down.
class DeepLinkEngineeringConsoleScreen extends StatefulWidget {
  const DeepLinkEngineeringConsoleScreen({super.key});

  @override
  State<DeepLinkEngineeringConsoleScreen> createState() => _DeepLinkEngineeringConsoleScreenState();
}

class _DeepLinkEngineeringConsoleScreenState extends State<DeepLinkEngineeringConsoleScreen> {
  Timer? _pollingTimer;
  late final DeepLinkContextEngine _engine;

  @override
  void initState() {
    super.initState();
    _engine = DeepLinkContextEngine.instance;
    // Background polling refreshes data every 30 seconds.
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _simulateNavigationAndFlush() {
    _engine.receiveDeepLink('udf://route/target_screen', sessionId: 'session_001');
    setState(() {});
    
    // Simulate immediate post-navigation flush
    Future.delayed(Duration.zero, () {
      _engine.flushContextCache(sessionId: 'session_001');
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Context cache flushed successfully.'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('UDF Deep Link Console'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: isMobile ? _buildMobileLayout(colorScheme) : _buildDesktopLayout(colorScheme),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _simulateNavigationAndFlush,
        label: const Text('Simulate Nav & Flush'),
        icon: const Icon(Icons.cleaning_services),
      ),
    );
  }

  Widget _buildMobileLayout(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStatusCard(colorScheme),
        const SizedBox(height: 16),
        _buildTelemetryList(colorScheme),
      ],
    );
  }

  Widget _buildDesktopLayout(ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildStatusCard(colorScheme)),
        const SizedBox(width: 24),
        Expanded(child: _buildTelemetryList(colorScheme)),
      ],
    );
  }

  Widget _buildStatusCard(ColorScheme colorScheme) {
    final hasCache = _engine.hasCachedContext;
    return Card(
      elevation: 3.0, // M3 Elevated Cards Level 2 (3dp)
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Context Cache Health',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Chip(
                  avatar: Icon(
                    hasCache ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                    size: 18,
                  ),
                  label: Text(hasCache ? 'Cached' : 'Flushed'),
                  backgroundColor: hasCache
                      ? colorScheme.errorContainer
                      : colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: hasCache
                        ? colorScheme.onErrorContainer
                        : colorScheme.onPrimaryContainer,
                  ),
                ),
                const Spacer(),
                Text(
                  'Target: Immediate',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (hasCache) ...[
              const SizedBox(height: 12),
              Text(
                'Active Context: ${_engine.cachedContext}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryList(ColorScheme colorScheme) {
    final logs = _engine.telemetryLog.reversed.toList();
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Execution Telemetry',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            if (logs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(child: Text('No events recorded yet.')),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    minVerticalPadding: 8,
                    leading: Icon(
                      log.completionStatus == 'Complete'
                          ? Icons.task_alt
                          : Icons.error_outline,
                      color: log.completionStatus == 'Complete'
                          ? colorScheme.primary
                          : colorScheme.error,
                    ),
                    title: Text(log.action),
                    subtitle: Text(
                      '${log.eventDate.toIso8601String().substring(11, 19)} | ${log.traceId}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: Chip(
                      label: Text(log.completionStatus),
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}