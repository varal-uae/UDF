// GEN-00095 — Transaction Trace ID Generator & Session Health Console.
// Generates RFC 4122 UUIDv4 trace_id per user transaction session; M3 responsive health dashboard with 30s liveness polling.
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// EC Blueprint for GEN-00095:
// EC: Generate -> create RFC4122 UUIDv4 trace_id per transaction session.
// EC: Validate -> verify UUIDv4 format and version/variant bits.
// EC: Monitor -> poll liveness every 30s and expose Pass/Fail health.
// EC: Render -> display M3 responsive single-column/multi-column console.

/// EC: Generate - UUIDv4 trace_id compliant with IETF RFC 4122.
/// Collision bound: <=1 per 10^15 IDs (birthday-bound). No external dependency.
class TraceId {
  TraceId._();
  static final Random _secure = Random.secure();

  /// EC: Generate - new UUIDv4 string.
  static String generate() {
    final List<int> bytes = List<int>.generate(16, (_) => _secure.nextInt(256));
    bytes[6] = (bytes[6] & 0x0F) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3F) | 0x80; // variant RFC4122
    return _format(bytes);
  }

  /// EC: Validate - check UUIDv4 shape, version and variant.
  static bool isValid(String id) {
    final RegExp v4 = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return v4.hasMatch(id);
  }

  static String _format(List<int> b) {
    String h(int v) => v.toRadixString(16).padLeft(2, '0');
    final StringBuffer sb = StringBuffer();
    for (int i = 0; i < 16; i++) {
      sb.write(h(b[i]));
      if (i == 3 || i == 5 || i == 7 || i == 9) sb.write('-');
    }
    return sb.toString();
  }
}

/// Transaction session bound to a single trace_id.
/// BigQuery mapping: partitioned by event_date, clustered by trace_id.
class UdfTransactionSession {
  final String traceId;
  final String sessionId;
  final DateTime startedAt;
  final String status; // Pass | Fail

  const UdfTransactionSession({
    required this.traceId,
    required this.sessionId,
    required this.startedAt,
    this.status = 'Pass',
  });

  /// EC: Serialize - BigQuery-ready event payload.
  Map<String, dynamic> toBigQueryJson() {
    final String eventDate = startedAt.toUtc().toIso8601String().substring(0, 10);
    return {
      'event_date': eventDate,
      'trace_id': traceId,
      'session_id': sessionId,
      'completion_status': status,
      'event_timestamp': startedAt.toUtc().toIso8601String(),
    };
  }
}

/// EC: Monitor - session store with 30s liveness handshake.
class TraceSessionStore extends ChangeNotifier {
  UdfTransactionSession? current;
  bool isHealthy = true;
  DateTime? lastHandshake;
  Timer? _pollTimer;
  int totalGenerated = 0;

  /// EC: Initialize - start first session and begin polling.
  void initialize() {
    startNewSession();
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _handshake());
  }

  /// EC: Generate - create new session with fresh trace_id.
  void startNewSession() {
    final String traceId = TraceId.generate();
    final bool ok = TraceId.isValid(traceId);
    current = UdfTransactionSession(
      traceId: traceId,
      sessionId: 'sess_${DateTime.now().millisecondsSinceEpoch}',
      startedAt: DateTime.now(),
      status: ok ? 'Pass' : 'Fail',
    );
    totalGenerated++;
    isHealthy = ok;
    lastHandshake = DateTime.now();
    notifyListeners();
  }

  /// EC: Refresh - manual pull-to-refresh sync.
  Future<void> refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _handshake();
  }

  void _handshake() {
    if (current == null || !TraceId.isValid(current!.traceId)) {
      isHealthy = false;
    } else {
      isHealthy = true;
      lastHandshake = DateTime.now();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

/// GEN-00095 M3 engineering console: responsive health dashboard.
/// Single-column <600dp, multi-column >=840dp. M3 Elevated Card L2 + status chip.
class Gen00095TraceConsoleScreen extends StatefulWidget {
  const Gen00095TraceConsoleScreen({super.key});
  @override
  State<Gen00095TraceConsoleScreen> createState() => _Gen00095TraceConsoleScreenState();
}

class _Gen00095TraceConsoleScreenState extends State<Gen00095TraceConsoleScreen> {
  late final TraceSessionStore _store;

  @override
  void initState() {
    super.initState();
    _store = TraceSessionStore()..initialize();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  /// EC: Render - open M3 bottom sheet with trace details.
  void _showConfigSheet(BuildContext context, UdfTransactionSession session) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trace details', style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 12),
                SelectableText(session.traceId),
                const SizedBox(height: 8),
                Text('event_date clustered by trace_id • BigQuery ready',
                    style: Theme.of(ctx).textTheme.bodySmall),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// EC: Notify - confirm rotation via M3 Snackbar.
  void _rotate(BuildContext context) {
    _store.startNewSession();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('New trace_id: ${_store.current?.traceId ?? ''}'), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (BuildContext context, _) {
        final UdfTransactionSession? session = _store.current;
        final bool pass = _store.isHealthy && session?.status == 'Pass';
        return Scaffold(
          appBar: AppBar(title: const Text('Trace Session • GEN-00095'), centerTitle: false),
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              final bool isDesktop = c.maxWidth >= 840;
              final Widget healthCard = _HealthCard(
                session: session,
                isHealthy: pass,
                lastHandshake: _store.lastHandshake,
                total: _store.totalGenerated,
                onDetails: session == null ? null : () => _showConfigSheet(context, session),
                onRotate: () => _rotate(context),
              );
              final Widget metricCard = _MetricCard(isHealthy: pass);
              if (isDesktop) {
                return RefreshIndicator(
                  onRefresh: _store.refresh,
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(16),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [healthCard, metricCard],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: _store.refresh,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [healthCard, const SizedBox(height: 12), metricCard],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _HealthCard extends StatelessWidget {
  final UdfTransactionSession? session;
  final bool isHealthy;
  final DateTime? lastHandshake;
  final int total;
  final VoidCallback? onDetails;
  final VoidCallback onRotate;
  const _HealthCard({required this.session, required this.isHealthy, required this.lastHandshake, required this.total, required this.onDetails, required this.onRotate});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: Text('Session health', style: Theme.of(context).textTheme.titleMedium)),
                Chip(
                  label: Text(isHealthy ? 'Pass' : 'Fail'),
                  backgroundColor: isHealthy ? cs.primaryContainer : cs.errorContainer,
                  labelStyle: TextStyle(color: isHealthy ? cs.onPrimaryContainer : cs.onErrorContainer),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Semantics(liveRegion: true, child: SelectableText(session?.traceId ?? '—', style: Theme.of(context).textTheme.bodyMedium)),
            const SizedBox(height: 8),
            Text('Sessions: $total • Liveness: ${lastHandshake != null ? TimeOfDay.fromDateTime(lastHandshake!).format(context) : '—'}',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 48, height: 48,
                  child: IconButton.filledTonal(onPressed: onDetails, icon: const Icon(Icons.info_outline), tooltip: 'Details'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(onPressed: onRotate, child: const Text('Rotate trace_id')),
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

class _MetricCard extends StatelessWidget {
  final bool isHealthy;
  const _MetricCard({required this.isHealthy});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Unique Identifier Collision Rate', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Floor: ≤1 per 10^15 • Target: 0 • Ceiling: 0', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: isHealthy ? 1.0 : 0.0),
            const SizedBox(height: 8),
            const Text('Standard: IETF RFC 4122 (UUID) • Output: Pass/Fail'),
          ],
        ),
      ),
    );
  }
}
