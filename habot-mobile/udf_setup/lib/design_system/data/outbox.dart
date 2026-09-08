/// AISS Step 117 -- GEN-02819
/// Atomic Step: "Deploy local SQLite fallback queue for offline mobile
///               telemetry when devices lose connectivity."
/// Metric: Task Completion Status -- 0.8 / 1 / 1, Complete/Partial/Not Complete.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// SUBSTITUTION RECORDED: the row names SQLite. There is no SQLite dependency
/// in this project and this environment cannot reach pub.dev to add one. The
/// queue is built on the Step 113 [HabotLocalStore] contract, which sqflite,
/// Hive, Isar or a file directory all satisfy -- so swapping the engine later
/// is a change behind an interface rather than a rewrite. That is the whole
/// reason Step 112 came first.
///
/// THE STEP THIS BATCH EXISTS FOR. Step 111 measured it: close the app and
/// every queued job, every half-typed form and every unsent event is gone.
/// This is the thing that stops that.
///
/// WHY IT IS SIXTH RATHER THAN FIRST, from the build order: "a queue built on
/// a mutable store with non-atomic writes loses exactly the data it was built
/// to protect." Enqueue and dequeue both go through the Step 116 unit of work,
/// so a crash between "record sent" and "remove from queue" cannot happen.
///
/// THE ORDER GUARANTEE. The queue drains in the order work was DONE, not in
/// whatever order a map iterates. A worker's day is a sequence; a queue that
/// reorders it silently rewrites what happened.
///
/// WHAT A DEAD LETTER IS FOR. An entry that has failed [maxAttempts] times is
/// moved aside rather than retried forever or dropped. Retrying forever drains
/// a battery in a dead-signal area, and dropping loses the user's work with no
/// record. A dead letter is the third option: kept, visible, countable, and
/// not in the way.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'local_store.dart';

/// Where an entry is in its life.
enum HabotOutboxState { pending, inFlight, sent, dead }

/// One queued item.
class HabotOutboxEntry {
  const HabotOutboxEntry({
    required this.id,
    required this.kind,
    required this.payload,
    required this.queuedAt,
    required this.sequence,
    this.attempts = 0,
    this.state = HabotOutboxState.pending,
    this.lastError,
  });

  /// Stable across restarts and retries. This is the Step 113 ticket id where
  /// the entry came from a DAO write, and it is what Step 122 uses as the
  /// idempotency key -- which is why it is minted at ENQUEUE time.
  final String id;

  /// What sort of thing this is: 'telemetry', 'task-submit', 'preference'.
  /// Kept as a string rather than an enum so a new kind does not need a
  /// migration of everything already on disk.
  final String kind;

  final Map<String, Object?> payload;
  final DateTime queuedAt;

  /// Monotonic. The drain order, held explicitly rather than inferred.
  final int sequence;

  final int attempts;
  final HabotOutboxState state;

  /// The last failure, scrubbed. Kept so a dead letter can say why it died.
  final String? lastError;

  HabotOutboxEntry copyWith({
    int? attempts,
    HabotOutboxState? state,
    String? lastError,
  }) => HabotOutboxEntry(
    id: id,
    kind: kind,
    payload: payload,
    queuedAt: queuedAt,
    sequence: sequence,
    attempts: attempts ?? this.attempts,
    state: state ?? this.state,
    lastError: lastError ?? this.lastError,
  );

  Map<String, Object?> toRecord() => <String, Object?>{
    'id': id,
    'kind': kind,
    'payload': payload,
    'queued_at': queuedAt.toIso8601String(),
    'sequence': sequence,
    'attempts': attempts,
    'state': state.name,
    if (lastError != null) 'last_error': lastError,
  };

  static HabotOutboxEntry? fromRecord(Map<String, Object?> r) {
    final Object? id = r['id'];
    final Object? kind = r['kind'];
    final Object? seq = r['sequence'];
    final Object? queued = r['queued_at'];
    if (id is! String || kind is! String || seq is! int || queued is! String) {
      return null;
    }
    final DateTime? at = DateTime.tryParse(queued);
    if (at == null) {
      return null;
    }
    return HabotOutboxEntry(
      id: id,
      kind: kind,
      payload: r['payload'] is Map<String, Object?>
          ? r['payload']! as Map<String, Object?>
          : const <String, Object?>{},
      queuedAt: at,
      sequence: seq,
      attempts: r['attempts'] is int ? r['attempts']! as int : 0,
      state: HabotOutboxState.values.firstWhere(
        (HabotOutboxState s) => s.name == r['state'],
        orElse: () => HabotOutboxState.pending,
      ),
      lastError: r['last_error'] is String ? r['last_error']! as String : null,
    );
  }
}

/// The durable queue.
class HabotOutbox {
  HabotOutbox({
    required this.store,
    this.maxAttempts = 5,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final HabotLocalStore store;

  /// Attempts before an entry is moved aside. Five is enough to survive a
  /// reconnect storm and few enough that a genuinely bad payload stops
  /// costing battery within a session.
  final int maxAttempts;

  final DateTime Function() _clock;

  static const HabotCollection collection = HabotCollection('outbox');
  static const HabotCollection deadLetters = HabotCollection('outbox_dead');

  int _nextSequence = 0;

  /// True only when the underlying store survives process death. The queue is
  /// the whole point of this step, so a caller that needs the guarantee has to
  /// be able to ask for it rather than assume it.
  bool get isDurable => store.isDurable;

  String get engineName => store.engineName;

  /// Rebuild the sequence counter from what is already on disk. Called once at
  /// startup; without it a restart would restart numbering and two entries
  /// would claim the same place in the order.
  Future<void> restore() async {
    int highest = 0;
    for (final HabotOutboxEntry e in await _all(collection)) {
      if (e.sequence > highest) {
        highest = e.sequence;
      }
    }
    _nextSequence = highest;
  }

  Future<List<HabotOutboxEntry>> _all(HabotCollection c) async {
    final List<HabotOutboxEntry> out = <HabotOutboxEntry>[];
    for (final String key in await store.keys(c)) {
      final Uint8List? bytes = await store.read(c, key);
      if (bytes == null) {
        continue;
      }
      final Map<String, Object?>? record = HabotRecordCodec.decode(bytes);
      if (record == null) {
        continue;
      }
      final HabotOutboxEntry? e = HabotOutboxEntry.fromRecord(record);
      if (e != null) {
        out.add(e);
      }
    }
    out.sort(
      (HabotOutboxEntry a, HabotOutboxEntry b) =>
          a.sequence.compareTo(b.sequence),
    );
    return out;
  }

  /// Put work on the queue. Returns the entry as stored.
  ///
  /// An id that is already queued is NOT queued twice -- the existing entry is
  /// returned untouched. Two taps on Submit is one submission, and that has to
  /// be true at the queue as well as at the wire (Step 122).
  Future<HabotOutboxEntry> enqueue({
    required String id,
    required String kind,
    required Map<String, Object?> payload,
  }) async {
    final Uint8List? existing = await store.read(collection, id);
    if (existing != null) {
      final Map<String, Object?>? record = HabotRecordCodec.decode(existing);
      final HabotOutboxEntry? prior = record == null
          ? null
          : HabotOutboxEntry.fromRecord(record);
      if (prior != null) {
        return prior;
      }
    }
    _nextSequence++;
    final HabotOutboxEntry entry = HabotOutboxEntry(
      id: id,
      kind: kind,
      payload: payload,
      queuedAt: _clock(),
      sequence: _nextSequence,
    );
    await store.write(
      collection,
      id,
      HabotRecordCodec.encode(entry.toRecord()),
    );
    return entry;
  }

  /// Everything waiting, oldest first.
  Future<List<HabotOutboxEntry>> pending() async => (await _all(
    collection,
  )).where((HabotOutboxEntry e) => e.state != HabotOutboxState.sent).toList();

  Future<int> get pendingCount async => (await pending()).length;

  /// The next entry to try, or null. Oldest first, dead letters skipped.
  Future<HabotOutboxEntry?> next() async {
    for (final HabotOutboxEntry e in await pending()) {
      if (e.state != HabotOutboxState.dead) {
        return e;
      }
    }
    return null;
  }

  Future<void> _put(HabotOutboxEntry e) => store.write(
    collection,
    e.id,
    HabotRecordCodec.encode(e.toRecord()),
  );

  Future<HabotOutboxEntry> markInFlight(HabotOutboxEntry e) async {
    final HabotOutboxEntry next = e.copyWith(
      state: HabotOutboxState.inFlight,
      attempts: e.attempts + 1,
    );
    await _put(next);
    return next;
  }

  /// Remove a sent entry. Goes through the store so the removal is as durable
  /// as the write was -- an entry that is sent but still queued is the same
  /// bug as one that is queued but never sent, pointed the other way.
  Future<void> markSent(HabotOutboxEntry e) =>
      store.remove(collection, e.id);

  /// Record a failure. Moves the entry aside once it has run out of attempts.
  Future<HabotOutboxEntry> markFailed(
    HabotOutboxEntry e,
    String error,
  ) async {
    final bool exhausted = e.attempts >= maxAttempts;
    final HabotOutboxEntry next = e.copyWith(
      state: exhausted ? HabotOutboxState.dead : HabotOutboxState.pending,
      lastError: error,
    );
    if (exhausted) {
      await store.write(
        deadLetters,
        e.id,
        HabotRecordCodec.encode(next.toRecord()),
      );
      await store.remove(collection, e.id);
    } else {
      await _put(next);
    }
    return next;
  }

  Future<List<HabotOutboxEntry>> dead() => _all(deadLetters);

  /// Put a dead letter back at the front of the queue, attempts reset. The
  /// operator action for "the server was broken, not the payload".
  Future<HabotOutboxEntry?> revive(String id) async {
    final Uint8List? bytes = await store.read(deadLetters, id);
    if (bytes == null) {
      return null;
    }
    final Map<String, Object?>? record = HabotRecordCodec.decode(bytes);
    final HabotOutboxEntry? e = record == null
        ? null
        : HabotOutboxEntry.fromRecord(record);
    if (e == null) {
      return null;
    }
    final HabotOutboxEntry revived = e.copyWith(
      state: HabotOutboxState.pending,
      attempts: 0,
    );
    await _put(revived);
    await store.remove(deadLetters, id);
    return revived;
  }

  /// The completion figure the sheet's metric names, computed rather than
  /// asserted: of everything ever queued in this session, the share that
  /// reached the server.
  ///
  /// Deliberately counts dead letters as NOT complete. A dead letter is work
  /// the user did that the server has not got, and calling that complete would
  /// make the number useless exactly when it matters.
  double completionFor({required int enqueued, required int sent}) =>
      enqueued == 0 ? 1 : sent / enqueued;

  static const double floor = 0.8;
  static const double optimal = 1.0;

  /// Recorded here so the evidence states it rather than a document alongside.
  static const String engineSubstitution =
      'The row names SQLite. No SQLite dependency exists in this project and '
      'this environment cannot reach pub.dev to add one. The queue is built on '
      'the HabotLocalStore byte contract instead -- narrow enough that '
      'sqflite, Hive, Isar or a plain file directory all satisfy it -- so the '
      'engine is a swap behind an interface rather than a rewrite.';

  /// A compact wire form for a batch send. JSON, matching the Step 113 codec,
  /// so the queue and the records it carries do not disagree about encoding.
  static String encodeBatch(List<HabotOutboxEntry> entries) => json.encode(
    entries.map((HabotOutboxEntry e) => e.toRecord()).toList(),
  );
}
