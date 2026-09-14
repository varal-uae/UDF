/// AISS Step 161 -- GEN-04770
/// Setup Step (Action) / Atomic Step: "Wire data logging per the BigQuery/GCP
///   alignment requirement: Step completion events streamed to BigQuery funnel
///   analytics (data captured: Step transition timestamp, time-per-step, and
///   step drop-off rates logged)."
/// Metric: Event Logging Completeness & Streaming Latency -- Floor "<=5 min
///         latency, >=99% completeness", Optimal "<=1 min, 100%",
///         Ceiling "<=15 min before stale". Complete / Partial / Not Complete.
///
/// **THE SAME BOUNDARY AS STEPS 132 AND 145, AND A DIFFERENT VOLUME
/// PROBLEM.** The client records and hands over; the server lands the row. But
/// where a language selection happens once or twice in an install's life, a
/// funnel emits an event per step per flow — hundreds per session. One outbox
/// entry per event would mean hundreds of HTTP requests on a metered
/// connection for data nobody is waiting on, and it would compete with the
/// Step 124 governor's budget against the writes a user IS waiting on.
///
/// So events BATCH: [HabotFunnelStream] accumulates and flushes a batch as one
/// outbox entry. The batch is the unit of delivery and of the completeness
/// figure, and the trade it makes is stated: a batch lost is more events lost
/// than a single entry, which is why the batch goes through the same durable
/// outbox rather than being held in memory until it is full.
///
/// **"DROP-OFF RATES LOGGED" IS NOT A CLIENT FIGURE, AND SAYING SO MATTERS.**
/// A drop-off rate is a ratio across many users; one device knows only its own
/// runs. A client that computed and sent "drop-off: 0.6" would be sending a
/// denominator of one, and a warehouse averaging those numbers would produce
/// something that looks like a rate and is not. The client therefore sends the
/// EVENTS the rate is computed from — step index, step count, time on step —
/// and the rate is a query. [HabotFunnelStream.dropOffIsServerSide] records it.
///
/// **THE LATENCY THE ROW BOUNDS IS NOT THE LATENCY THIS CLIENT CONTROLS**,
/// exactly as at Step 145. The client owns handover; transport, ingestion and
/// the streaming insert are the server's. Reporting an end-to-end figure this
/// code cannot observe would be a fabricated measurement.
library;

import '../data/outbox.dart';
import '../tokens/motion_tokens.dart';
import 'event_schema.dart';
import 'pii_sanitizer.dart';

/// Why a batch was flushed. Recorded so a tail of small batches can be told
/// apart from a steady stream of full ones.
enum HabotFlushReason {
  /// The batch reached [HabotFunnelStream.batchSize].
  full,

  /// The app is going to the background and might not come back.
  lifecycle,

  /// The caller asked.
  manual,
}

/// Batches schema-valid events into the durable outbox.
class HabotFunnelStream {
  HabotFunnelStream({
    required this.outbox,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final HabotOutbox outbox;
  final DateTime Function() _clock;

  static const String destinationTable = 'analytics.funnel_events_v1';
  static const String outboxKind = 'funnel_event_batch';

  /// Large enough that the request count stays sane on a busy session; small
  /// enough that losing one batch loses seconds of history rather than a
  /// session of it.
  static const int batchSize = 25;

  final List<HabotEvent> _pending = <HabotEvent>[];
  final List<HabotEvent> _accepted = <HabotEvent>[];
  final Set<String> _handedOver = <String>{};
  final List<String> _refused = <String>[];
  int _batches = 0;

  int get pendingCount => _pending.length;
  int get batchesFlushed => _batches;
  List<String> get refused => List<String>.unmodifiable(_refused);
  int get eventsAccepted => _accepted.length;

  /// Events accepted but never handed to the queue. Empty is the requirement.
  List<String> get notHandedOver => _accepted
      .map(idOf)
      .where((String id) => !_handedOver.contains(id))
      .toList();

  static String idOf(HabotEvent e) =>
      '${e.traceId}:${e.kind.name}:${e.sessionOrdinal}';

  /// Add an event. Refused -- not silently dropped -- if it fails the schema
  /// or if the sanitiser finds anything in it.
  bool add(HabotEvent event) {
    if (!HabotEventSchema.matches(event)) {
      _refused.add('${idOf(event)}: schema');
      return false;
    }
    if (!HabotPiiSanitizer.rowIsClean(event.toRow())) {
      _refused.add('${idOf(event)}: sanitiser');
      return false;
    }
    _accepted.add(event);
    _pending.add(event);
    return true;
  }

  /// Flush whatever is pending as one outbox entry.
  Future<HabotOutboxEntry?> flush({
    HabotFlushReason reason = HabotFlushReason.manual,
  }) async {
    if (_pending.isEmpty) {
      return null;
    }
    final List<HabotEvent> batch = List<HabotEvent>.from(_pending);
    _pending.clear();
    _batches++;
    final HabotOutboxEntry entry = await outbox.enqueue(
      id: batchIdOf(batch),
      kind: outboxKind,
      payload: <String, Object?>{
        'destination_table': destinationTable,
        'partition_field': HabotEventSchema.partitionField,
        'cluster_field': HabotEventSchema.clusterField,
        'schema_version': HabotEventSchema.version,
        'flush_reason': reason.name,
        'event_count': batch.length,
        'events': batch.map((HabotEvent e) => e.toRow()).toList(),
      },
    );
    _handedOver.addAll(batch.map(idOf));
    return entry;
  }

  /// Add, and flush when the batch is full.
  Future<HabotOutboxEntry?> addAndMaybeFlush(HabotEvent event) async {
    if (!add(event)) {
      return null;
    }
    if (_pending.length >= batchSize) {
      return flush(reason: HabotFlushReason.full);
    }
    return null;
  }

  /// Deterministic per batch, so a retry of the same batch dedupes at the
  /// Step 117 outbox rather than landing twice.
  static String batchIdOf(List<HabotEvent> batch) =>
      batch.isEmpty ? 'empty' : '${idOf(batch.first)}+${batch.length}';

  // ---- the row's metric ---------------------------------------------------

  /// The share of accepted events that reached the durable queue.
  ///
  /// Tracked at handover rather than inferred from the queue, for the reason
  /// Steps 132 and 145 give: a sent entry is gone from the queue, and absence
  /// cannot then distinguish delivered from never-queued.
  double get captureCompleteness => _accepted.isEmpty
      ? 1
      : (_accepted.length - notHandedOver.length) / _accepted.length;

  static String bandFor(Duration endToEnd) {
    if (endToEnd <= HabotMotion.telemetryDeliveryOptimal) {
      return 'Complete (<= 1 min)';
    }
    if (endToEnd <= HabotMotion.telemetryDeliveryFloor) {
      return 'Complete (<= 5 min)';
    }
    return endToEnd <= HabotMotion.telemetryStale ? 'Partial' : 'Not Complete';
  }

  static bool isStale(Duration endToEnd) =>
      endToEnd > HabotMotion.telemetryStale;

  static const double captureFloor = 0.99;
  static const double captureOptimal = 1.0;

  static const String batchingNote =
      'A language selection happens once in an install\'s life; a funnel emits '
      'an event per step per flow. One outbox entry per event would mean '
      'hundreds of requests on a metered connection for data nobody is '
      'waiting on, competing with the Step 124 governor\'s budget against the '
      'writes a user IS waiting on. Events batch, and the batch goes through '
      'the durable outbox rather than sitting in memory until it is full -- '
      'because a lost batch is more events lost than a lost entry.';

  static const String dropOffIsServerSide =
      '"Step drop-off rates logged" is not a client figure. A drop-off rate is '
      'a ratio across many users; one device knows only its own runs. A client '
      'sending "drop-off: 0.6" would be sending a denominator of one, and a '
      'warehouse averaging those would produce something that looks like a '
      'rate and is not. The client sends the events the rate is computed '
      'from -- step index, step count, time on step -- and the rate is a query.';

  static const String latencyBoundaryNote =
      'The row bounds end-to-end delivery, which spans transport, an ingestion '
      'service and a streaming insert. The client owns handover and reports '
      'that. Reporting an end-to-end figure this code cannot observe would be '
      'a fabricated measurement. Same reasoning as Step 145.';

  static const String bigQueryBoundary =
      'A mobile client must not write to BigQuery: an app holding warehouse '
      'credentials would be a security defect rather than a feature. The batch '
      'carries the destination table, the partition field and the cluster '
      'field the GCP row names; landing the rows is the server concern. Same '
      'boundary as Steps 132 and 145.';
}
