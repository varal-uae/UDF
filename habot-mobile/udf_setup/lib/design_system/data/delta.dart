/// AISS Step 118 -- GEN-04064
/// Atomic Step: "Process incoming delta payloads on the mobile client to
///               update local key-value stores."
/// Metric: Local Delta Update Latency -- Floor <100ms, Optimal <20ms,
///         Ceiling 500ms.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// THE METRIC FITS, and it is producible here: applying a batch of deltas to a
/// local store is entirely client-side, so the number this gate reports is a
/// real measurement rather than a stand-in. Note the band direction -- lower is
/// better, and the ceiling (500ms) is the WORST acceptable value, not the best.
/// That is the sheet's normal convention and it is worth saying, because Step
/// 102's row used the opposite one.
///
/// WHY IT COMES STRAIGHT AFTER THE OUTBOX, from the build order: this is the
/// read half of the same pipe Step 117 writes into, "and a delta applied to a
/// store holding unsent local work is the first place a conflict can appear.
/// The two have to be designed against each other."
///
/// THE CONFLICT RULE, STATED. When a delta arrives for a record that has
/// unsent local changes, the local copy wins and the delta is DEFERRED, not
/// dropped and not applied. Three reasons:
///
///   * The local change is work a person did. The delta is a copy of what the
///     server thought before it heard about that work.
///   * Applying the delta would silently undo the user's edit, which is the
///     single worst thing an offline-first client can do.
///   * Dropping it would lose whatever ELSE the delta carried, so it is held
///     and re-offered after the outbox drains.
///
/// This is the Step 113 revision rule applied one layer up: a write that is
/// not ahead of what is stored does not land.
library;

import 'dao.dart';
import 'outbox.dart';
import 'repository.dart';

/// What a delta does to one record.
enum HabotDeltaOp { upsert, remove }

/// Why a delta was not applied.
enum HabotDeltaOutcome {
  applied,

  /// Older than or equal to what is stored. Ordinary on a reconnect.
  stale,

  /// The record has unsent local work. Held, not dropped.
  deferredForLocalWork,

  /// Malformed.
  rejected,
}

/// One incoming change.
class HabotDelta {
  const HabotDelta({
    required this.entityId,
    required this.revision,
    required this.op,
    this.payload,
  });

  final String entityId;

  /// The server's revision for this record. Compared against what is stored;
  /// no clock is consulted, because a device clock that is wrong would make
  /// the comparison wrong in a way nobody would notice.
  final int revision;

  final HabotDeltaOp op;

  /// Present for an upsert, absent for a removal.
  final Map<String, Object?>? payload;

  bool get isWellFormed =>
      entityId.trim().isNotEmpty &&
      revision > 0 &&
      (op == HabotDeltaOp.remove || payload != null);

  static HabotDelta? fromRecord(Map<String, Object?> r) {
    final Object? id = r['entity_id'];
    final Object? rev = r['revision'];
    final Object? op = r['op'];
    if (id is! String || rev is! int) {
      return null;
    }
    final HabotDeltaOp parsed = op == 'remove'
        ? HabotDeltaOp.remove
        : HabotDeltaOp.upsert;
    return HabotDelta(
      entityId: id,
      revision: rev,
      op: parsed,
      payload: r['payload'] is Map<String, Object?>
          ? r['payload']! as Map<String, Object?>
          : null,
    );
  }

  Map<String, Object?> toRecord() => <String, Object?>{
    'entity_id': entityId,
    'revision': revision,
    'op': op.name,
    if (payload != null) 'payload': payload,
  };
}

/// What happened to one delta.
class HabotDeltaResult {
  const HabotDeltaResult({
    required this.delta,
    required this.outcome,
    required this.detail,
  });

  final HabotDelta delta;
  final HabotDeltaOutcome outcome;
  final String detail;

  bool get applied => outcome == HabotDeltaOutcome.applied;

  Map<String, Object?> toJson() => <String, Object?>{
    'entity_id': delta.entityId,
    'revision': delta.revision,
    'op': delta.op.name,
    'outcome': outcome.name,
    'detail': detail,
  };
}

/// What a batch cost.
class HabotDeltaBatchReport {
  const HabotDeltaBatchReport({
    required this.results,
    required this.elapsed,
  });

  final List<HabotDeltaResult> results;
  final Duration elapsed;

  int get count => results.length;
  int get applied => results.where((HabotDeltaResult r) => r.applied).length;
  List<HabotDeltaResult> get deferred => results
      .where(
        (HabotDeltaResult r) =>
            r.outcome == HabotDeltaOutcome.deferredForLocalWork,
      )
      .toList();

  /// The metric, per delta, in milliseconds. Reported as a per-record figure
  /// because that is what the row's bands are scaled for.
  double get msPerDelta =>
      count == 0 ? 0 : elapsed.inMicroseconds / 1000 / count;

  bool get meetsFloor => msPerDelta < HabotDeltaApplier.floorMs;
  bool get meetsOptimal => msPerDelta < HabotDeltaApplier.optimalMs;
  bool get breachesCeiling => msPerDelta >= HabotDeltaApplier.ceilingMs;

  Map<String, Object?> toJson() => <String, Object?>{
    'deltas': count,
    'applied': applied,
    'deferred': deferred.length,
    'elapsed_ms': elapsed.inMicroseconds / 1000,
    'ms_per_delta': msPerDelta,
  };
}

/// Applies incoming deltas to the local store, respecting unsent local work.
class HabotDeltaApplier<T extends HabotEntity> {
  HabotDeltaApplier({
    required this.dao,
    required this.outbox,
    required this.decodeEntity,
  });

  final HabotDao<T> dao;

  /// Consulted for unsent local work. This is the coupling the build order
  /// asked for: the read path cannot decide safely without knowing what the
  /// write path is still holding.
  final HabotOutbox outbox;

  /// Turns a delta payload into an entity at the delta's revision.
  final T? Function(String entityId, int revision, Map<String, Object?> payload)
  decodeEntity;

  /// Lower is better. The ceiling is the WORST acceptable value here.
  static const double floorMs = 100;
  static const double optimalMs = 20;
  static const double ceilingMs = 500;

  /// Deltas held because the record had unsent local work. Re-offered by
  /// [retryDeferred] after the outbox drains.
  final List<HabotDelta> _deferred = <HabotDelta>[];

  List<HabotDelta> get deferred => List<HabotDelta>.unmodifiable(_deferred);

  Future<Set<String>> _idsWithUnsentWork() async {
    final Set<String> ids = <String>{};
    for (final HabotOutboxEntry e in await outbox.pending()) {
      final Object? id = e.payload['entity_id'];
      if (id is String) {
        ids.add(id);
      }
    }
    return ids;
  }

  Future<HabotDeltaResult> _applyOne(
    HabotDelta d,
    Set<String> locallyDirty,
  ) async {
    if (!d.isWellFormed) {
      return HabotDeltaResult(
        delta: d,
        outcome: HabotDeltaOutcome.rejected,
        detail: 'malformed: empty id, non-positive revision, or an upsert '
            'with no payload',
      );
    }
    if (locallyDirty.contains(d.entityId)) {
      _deferred.add(d);
      return HabotDeltaResult(
        delta: d,
        outcome: HabotDeltaOutcome.deferredForLocalWork,
        detail:
            '"${d.entityId}" has unsent local changes. Applying this would '
            'undo work the user did. Held and re-offered after the outbox '
            'drains.',
      );
    }
    final int? stored = await dao.revisionOf(d.entityId);
    if (stored != null && d.revision <= stored) {
      return HabotDeltaResult(
        delta: d,
        outcome: HabotDeltaOutcome.stale,
        detail:
            'revision ${d.revision} is not ahead of the stored $stored; the '
            'local copy is at least as new',
      );
    }
    if (d.op == HabotDeltaOp.remove) {
      final HabotResult<HabotWriteTicket> r = await dao.delete(
        d.entityId,
        revision: d.revision,
      );
      return HabotDeltaResult(
        delta: d,
        outcome: r.isSuccess
            ? HabotDeltaOutcome.applied
            : HabotDeltaOutcome.stale,
        detail: r.isSuccess ? 'tombstoned at revision ${d.revision}' : 'refused',
      );
    }
    final T? entity = decodeEntity(d.entityId, d.revision, d.payload!);
    if (entity == null) {
      return HabotDeltaResult(
        delta: d,
        outcome: HabotDeltaOutcome.rejected,
        detail: 'payload did not decode into an entity',
      );
    }
    final HabotResult<HabotWriteTicket> r = await dao.save(entity);
    return HabotDeltaResult(
      delta: d,
      outcome: r.isSuccess ? HabotDeltaOutcome.applied : HabotDeltaOutcome.stale,
      detail: r.isSuccess
          ? 'applied at revision ${d.revision}'
          : (r.failureOrNull?.name ?? 'refused'),
    );
  }

  /// Apply a batch and time it.
  Future<HabotDeltaBatchReport> apply(List<HabotDelta> deltas) async {
    final Set<String> dirty = await _idsWithUnsentWork();
    final Stopwatch watch = Stopwatch()..start();
    final List<HabotDeltaResult> out = <HabotDeltaResult>[];
    for (final HabotDelta d in deltas) {
      out.add(await _applyOne(d, dirty));
    }
    watch.stop();
    return HabotDeltaBatchReport(results: out, elapsed: watch.elapsed);
  }

  /// Re-offer everything that was held. Called by the Step 123 sync loop after
  /// the outbox drains, which is the moment the conflict that caused the
  /// deferral has gone away.
  Future<HabotDeltaBatchReport> retryDeferred() async {
    final List<HabotDelta> held = List<HabotDelta>.from(_deferred);
    _deferred.clear();
    return apply(held);
  }
}
