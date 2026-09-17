// GEN-00836 — MTO Task Dispatch & Exception Ranking Engine Status Console.
// Mobile-first M3 engineering-console screen surfacing Pub/Sub consumer health for
// topic-mto-queue with 30s background polling, pull-to-refresh, and Pass/Fail latency gating.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Latency gates derived from the GCP Pub/Sub Consumer Spec (GEN-00836).
class MtoLatencyThresholds {
  const MtoLatencyThresholds._();

  /// Optimal target: <= 5 ms.
  static const Duration optimal = Duration(milliseconds: 5);

  /// Floor boundary: <= 20 ms (Pass/Fail gate).
  static const Duration floor = Duration(milliseconds: 20);

  /// Ceiling boundary: 50 ms (hard rollback trigger).
  static const Duration ceiling = Duration(milliseconds: 50);
}

/// Health verdict for the GEN-00836 setup step.
enum MtoStepHealth { pass, fail, unknown }

/// Immutable snapshot of the Cloud Run dispatch microservice consumer state.
class MtoDispatchSnapshot {
  const MtoDispatchSnapshot({
    required this.topic,
    required this.consumeLatency,
    required this.pendingExceptions,
    required this.dispatchedTasks,
    required this.capturedAt,
    required this.ciGatePassing,
  });

  final String topic;
  final Duration consumeLatency;
  final int pendingExceptions;
  final int dispatchedTasks;
  final DateTime capturedAt;
  final bool ciGatePassing;

  /// Pass when Message Consume Latency respects the <= 20 ms floor boundary.
  bool get latencyPass =>
      consumeLatency.compareTo(MtoLatencyThresholds.floor) <= 0;

  MtoStepHealth get health {
    if (!ciGatePassing || !latencyPass) return MtoStepHealth.fail;
    return MtoStepHealth.pass;
  }
}

/// Telemetry gateway for the GEN-00836 dispatch engine.
///
/// Replace the simulated payload with the real Pub/Sub metrics endpoint
/// (stackdriver consumer-latency series) once the Cloud Run service is live.
class MtoDispatchTelemetryService {
  const MtoDispatchTelemetryService();

  Future<MtoDispatchSnapshot> fetchSnapshot() async {
    // Simulated sub-100ms mobile API read; swap for authenticated REST/gRPC call.
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final math.Random rng = math.Random();
    return MtoDispatchSnapshot(
      topic: 'topic-mto-queue',
      consumeLatency: Duration(milliseconds: 3 + rng.nextInt(14)),
      pendingExceptions: rng.nextInt(12),
      dispatchedTasks: 120 + rng.nextInt(380),
      capturedAt: DateTime.now(),
      ciGatePassing: true,
    );
  }
}

/// GEN-00836 engineering-console dashboard.
///
/// Responsive M3 layout: single-column below 600dp, two-column at >= 840dp.
/// Background polling refreshes every 30 seconds; pull-to-refresh forces a sync.
class MtoDispatchStatusConsole extends StatefulWidget {
  const MtoDispatchStatusConsole({
    super.key,
    this.service = const MtoDispatchTelemetryService(),
    this.pollInterval = const Duration(seconds: 30),
  });

  final MtoDispatchTelemetryService service;
  final Duration pollInterval;

  @override
  State<MtoDispatchStatusConsole> createState() =>
      _MtoDispatchStatusConsoleState();
}

class _MtoDispatchStatusConsoleState extends State<MtoDispatchStatusConsole> {
  Timer? _pollTimer;
  MtoDispatchSnapshot? _snapshot;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
    // Self-chasing liveness handshake: poll every 30 seconds.
    _pollTimer = Timer.periodic(widget.pollInterval, (_) => _refresh());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final MtoDispatchSnapshot snapshot = await widget.service.fetchSnapshot();
      if (!mounted) return;
      setState(() {
        _snapshot = snapshot;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MTO Dispatch Engine'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // M3 responsive rule: single-column <600dp, multi-column >=840dp.
            final bool wide = constraints.maxWidth >= 840;
            final Widget content = _buildBody(context, wide);
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: content,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool wide) {
    if (_loading && _snapshot == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 96),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null && _snapshot == null) {
      return _ErrorState(onRetry: _refresh);
    }
    final MtoDispatchSnapshot snap = _snapshot!;
    final List<Widget> cards = <Widget>[
      _HealthCard(snapshot: snap),
      _LatencyCard(snapshot: snap),
      _ThroughputCard(snapshot: snap),
    ];
    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final Widget card in cards) ...<Widget>[
            card,
            const SizedBox(height: 12),
          ],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final Widget card in cards) ...<Widget>[
          Expanded(child: card),
          const SizedBox(width: 16),
        ],
      ],
    );
  }
}

/// M3 Elevated Card (Level 2, 3dp) with inline status chip for step health.
class _HealthCard extends StatelessWidget {
  const _HealthCard({required this.snapshot});

  final MtoDispatchSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final MtoStepHealth health = snapshot.health;
    final bool pass = health == MtoStepHealth.pass;
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // 48x48dp touch target; deep-link drill-down into trace detail.
        onTap: () => _showDrillDown(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Step Health',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Chip(
                    avatar: Icon(
                      pass ? Icons.check_circle : Icons.error,
                      size: 18,
                      color: pass ? colors.onPrimaryContainer : colors.onErrorContainer,
                    ),
                    label: Text(pass ? 'Pass' : 'Fail'),
                    backgroundColor:
                        pass ? colors.primaryContainer : colors.errorContainer,
                    side: BorderSide.none,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Pub/Sub topic: ${snapshot.topic}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'CI/CD gate: ${snapshot.ciGatePassing ? 'passing' : 'blocked'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDrillDown(BuildContext context) {
    // M3 Bottom Sheet for configuration / trace drill-down.
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('GEN-00836 Drill-Down',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('Topic: ${snapshot.topic}'),
            Text('Captured: ${snapshot.capturedAt.toIso8601String()}'),
            Text('Pending exceptions: ${snapshot.pendingExceptions}'),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// KPI card for Message Consume Latency against the <= 20 ms floor gate.
class _LatencyCard extends StatelessWidget {
  const _LatencyCard({required this.snapshot});

  final MtoDispatchSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final int ms = snapshot.consumeLatency.inMilliseconds;
    final bool pass = snapshot.latencyPass;
    final double progress =
        (ms / MtoLatencyThresholds.ceiling.inMilliseconds).clamp(0.0, 1.0);
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Message Consume Latency',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '$ms ms',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: pass ? colors.primary : colors.error,
                  ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: colors.surfaceContainerHighest,
              color: pass ? colors.primary : colors.error,
            ),
            const SizedBox(height: 8),
            Text(
              'Floor <= 20 ms | Optimal <= 5 ms | Ceiling 50 ms',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// KPI card for dispatch throughput and exception backlog.
class _ThroughputCard extends StatelessWidget {
  const _ThroughputCard({required this.snapshot});

  final MtoDispatchSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Dispatch Throughput',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _MetricRow(
              label: 'Tasks dispatched',
              value: '${snapshot.dispatchedTasks}',
            ),
            const SizedBox(height: 4),
            _MetricRow(
              label: 'Exceptions queued',
              value: '${snapshot.pendingExceptions}',
            ),
            const SizedBox(height: 4),
            _MetricRow(
              label: 'Last sync',
              value:
                  '${snapshot.capturedAt.hour.toString().padLeft(2, '0')}:${snapshot.capturedAt.minute.toString().padLeft(2, '0')}:${snapshot.capturedAt.second.toString().padLeft(2, '0')}',
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(value, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 96),
      child: Column(
        children: <Widget>[
          Icon(Icons.cloud_off,
              size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 12),
          const Text('Telemetry unavailable. Pull to retry.'),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Retry now'),
            ),
          ),
        ],
      ),
    );
  }
}
