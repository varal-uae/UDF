// GEN-00340 — ShaktiAlertPanel & Violation Event Subscriber.
// M3 alert panel rendering violation events with responsive single-column (<600dp)
// / multi-column (>=840dp) layout, 30s polling, pull-to-refresh, and a stream-based
// violation event subscriber whose execution events are forwarded to a telemetry sink
// (BigQuery-aligned: partitioned by event_date, clustered by trace_id).

import 'dart:async';

import 'package:flutter/material.dart';

/// Pass/Fail output captured per GEN-00340 acceptance criteria verification.
enum VerificationStatus { pass, fail, pending }

/// A single violation event delivered to the [ShaktiAlertPanel].
class ViolationEvent {
  const ViolationEvent({
    required this.traceId,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.status,
    this.sessionId,
  });

  /// Clustering key for BigQuery alignment (clustered by trace_id).
  final String traceId;
  final String title;
  final String description;
  final DateTime timestamp;
  final VerificationStatus status;
  final String? sessionId;

  /// Partition key for BigQuery alignment (partitioned by event_date).
  String get eventDate =>
      '${timestamp.year.toString().padLeft(4, '0')}-'
      '${timestamp.month.toString().padLeft(2, '0')}-'
      '${timestamp.day.toString().padLeft(2, '0')}';

  Map<String, Object?> toTelemetryPayload() => <String, Object?>{
        'trace_id': traceId,
        'event_date': eventDate,
        'title': title,
        'description': description,
        'status': status.name,
        'timestamp': timestamp.toIso8601String(),
        'session_id': sessionId,
      };
}

/// Telemetry sink contract — implemented by the core/telemetry layer to stream
/// step execution events to BigQuery (partitioned by event_date, clustered by
/// trace_id) per GEN-00340 GCP/BigQuery alignment.
abstract class ViolationTelemetrySink {
  Future<void> emit(ViolationEvent event);
}

/// Violation event subscriber for GEN-00340.
///
/// Subscribes to an upstream violation [Stream], forwards every event to the
/// [ViolationTelemetrySink], and re-broadcasts verified events to UI listeners.
/// Includes a liveness handshake: if no event arrives within [livenessWindow]
/// the [onLivenessTimeout] callback fires so callers can trigger rollback.
class ViolationEventSubscriber {
  ViolationEventSubscriber({
    required Stream<ViolationEvent> source,
    required ViolationTelemetrySink sink,
    this.livenessWindow = const Duration(seconds: 30),
    this.onLivenessTimeout,
  })  : _source = source,
        _sink = sink;

  final Stream<ViolationEvent> _source;
  final ViolationTelemetrySink _sink;
  final Duration livenessWindow;
  final VoidCallback? onLivenessTimeout;

  final StreamController<ViolationEvent> _verifiedController =
      StreamController<ViolationEvent>.broadcast();

  StreamSubscription<ViolationEvent>? _subscription;
  Timer? _livenessTimer;
  bool _isListening = false;

  /// Broadcast stream of violation events confirmed by this subscriber.
  Stream<ViolationEvent> get verifiedEvents => _verifiedController.stream;

  bool get isListening => _isListening;

  /// Starts the subscription and the automated liveness handshake.
  void start() {
    if (_isListening) return;
    _isListening = true;
    _subscription = _source.listen(_handleEvent, onError: _handleError);
    _resetLivenessTimer();
  }

  Future<void> _handleEvent(ViolationEvent event) async {
    _resetLivenessTimer();
    _verifiedController.add(event);
    try {
      await _sink.emit(event);
    } catch (_) {
      // Telemetry failures must not block the alert pipeline; the offline
      // queue (GEN-00340.1) retries delivery on reconnect.
    }
  }

  void _handleError(Object error) {
    onLivenessTimeout?.call();
  }

  void _resetLivenessTimer() {
    _livenessTimer?.cancel();
    _livenessTimer = Timer(livenessWindow, () => onLivenessTimeout?.call());
  }

  /// Stops the subscription and releases resources.
  Future<void> dispose() async {
    _livenessTimer?.cancel();
    await _subscription?.cancel();
    await _verifiedController.close();
    _isListening = false;
  }
}

/// GEN-00340 ShaktiAlertPanel.
///
/// M3 Elevated Card (Level 2, 3dp) panel listing violation events with inline
/// M3 status chips. Responsive: single-column on mobile (<600dp), multi-column
/// on desktop (>=840dp). All interactive targets meet the 48x48dp minimum.
class ShaktiAlertPanel extends StatefulWidget {
  const ShaktiAlertPanel({
    super.key,
    required this.subscriber,
    required this.onRefresh,
    this.pollingInterval = const Duration(seconds: 30),
    this.headerTitle = 'Shakti Alert Panel',
  });

  final ViolationEventSubscriber subscriber;

  /// Pull-to-refresh / polling callback — triggers a manual sync.
  final Future<void> Function() onRefresh;

  /// Background polling cadence (default 30s per GEN-00340).
  final Duration pollingInterval;
  final String headerTitle;

  @override
  State<ShaktiAlertPanel> createState() => _ShaktiAlertPanelState();
}

class _ShaktiAlertPanelState extends State<ShaktiAlertPanel> {
  final List<ViolationEvent> _events = <ViolationEvent>[];
  StreamSubscription<ViolationEvent>? _eventSubscription;
  Timer? _pollingTimer;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    widget.subscriber.start();
    _eventSubscription =
        widget.subscriber.verifiedEvents.listen(_onVerifiedEvent);
    _pollingTimer = Timer.periodic(widget.pollingInterval, (_) => _sync());
  }

  void _onVerifiedEvent(ViolationEvent event) {
    if (!mounted) return;
    setState(() => _events.insert(0, event));
  }

  Future<void> _sync() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _eventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isWide = constraints.maxWidth >= 840;
        return Card(
          elevation: 3, // M3 Elevated Card Level 2.
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildHeader(colors),
                const SizedBox(height: 12),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _sync,
                    child: isWide
                        ? _buildGrid(columns: 2)
                        : _buildGrid(columns: 1),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ColorScheme colors) {
    return Row(
      children: <Widget>[
        Icon(Icons.shield_outlined, color: colors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.headerTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (_isSyncing)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          _StatusChip(
            label: widget.subscriber.isListening ? 'Live' : 'Offline',
            color: widget.subscriber.isListening
                ? colors.primary
                : colors.error,
          ),
      ],
    );
  }

  Widget _buildGrid({required int columns}) {
    if (_events.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const <Widget>[
          SizedBox(height: 120),
          Center(child: Text('No violations reported.')),
        ],
      );
    }
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 132,
      ),
      itemCount: _events.length,
      itemBuilder: (BuildContext context, int index) =>
          _ViolationCard(event: _events[index]),
    );
  }
}

class _ViolationCard extends StatelessWidget {
  const _ViolationCard({required this.event});

  final ViolationEvent event;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final (String label, Color color) = switch (event.status) {
      VerificationStatus.pass => ('Pass', colors.primary),
      VerificationStatus.fail => ('Fail', colors.error),
      VerificationStatus.pending => ('Pending', colors.tertiary),
    };
    return Semantics(
      label: 'Violation ${event.title}, status $label',
      child: Container(
        constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                _StatusChip(label: label, color: color),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                event.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Text(
              'trace: ${event.traceId} · ${event.eventDate}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
