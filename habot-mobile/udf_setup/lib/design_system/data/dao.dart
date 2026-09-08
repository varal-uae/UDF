/// AISS Step 113 -- GEN-04484 (part 2 of 2: the DAO)
/// "Build Data Access Objects (DAOs) for CRUD operations on local entities."
/// Metric: Data Synchronization Success Rate -- floor 0.98, optimal 0.999,
///         ceiling 1.0.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// METRIC READING, STATED. "Data Synchronization Success Rate" is a property
/// of a sync loop that does not exist yet -- Step 123 builds it. What a DAO
/// owns, and what is measured here, is the LOCAL half of that rate: of every
/// CRUD operation attempted against the store, how many completed without
/// losing or corrupting the record. A DAO cannot make the network work; it can
/// guarantee that nothing is lost before the network is reached. Where the
/// full rate cannot be produced it is reported as NOT PRODUCED rather than
/// having the local figure passed off as the whole thing.
///
/// WHY THIS COMES AFTER THE INTERFACE, from the build order: "a DAO written
/// first is a DAO the interface gets bent around."
///
/// WHAT THE DAO ADDS OVER THE STORE. The store moves bytes. The DAO adds the
/// four things that make bytes into records, each of which is a decision:
///
///   1. ENCODING, once. `HabotRecordCodec`, never per-entity JSON scattered
///      through the app.
///   2. REVISION DISCIPLINE. A save whose revision is not ahead of what is
///      stored is a stale write and is REJECTED, not applied. This is what
///      stops a slow reconnect overwriting newer local work -- the single most
///      common data-loss bug in offline-first apps.
///   3. TOMBSTONES. A delete writes a marker rather than removing the row,
///      because a row that simply vanishes cannot be replicated: the server
///      has no way to tell "deleted" from "never seen". The marker is what
///      Step 118's delta path reads.
///   4. AN OUTBOX TICKET per write, produced at queue time so Step 122 has a
///      stable idempotency key across retries.
library;

import 'dart:typed_data';

import 'local_store.dart';
import 'repository.dart';

/// Turns a record back into an entity. Supplied per DAO; the DAO itself stays
/// generic, which is what keeps the storage layer free of entity types.
typedef HabotEntityDecoder<T extends HabotEntity> =
    T? Function(Map<String, Object?> record);

/// Why a DAO write was refused.
enum HabotDaoRejection {
  /// The incoming revision is not ahead of what is stored.
  staleRevision,

  /// The stored bytes could not be decoded.
  corruptRecord,

  /// The entity declared an empty or malformed id.
  invalidIdentity,
}

/// The record field names, declared once. A DAO and a delta reader that
/// disagree about a field name is a bug that only shows up on a real device.
class HabotRecordFields {
  const HabotRecordFields._();

  static const String id = 'entity_id';
  static const String revision = 'revision';
  static const String deleted = 'deleted_ind';
  static const String updatedAt = 'updated_at';
  static const String payload = 'payload';

  static const List<String> all = <String>[
    id,
    revision,
    deleted,
    updatedAt,
    payload,
  ];
}

/// CRUD over one collection.
class HabotDao<T extends HabotEntity> {
  HabotDao({
    required this.collection,
    required this.store,
    required this.decoder,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    if (!collection.isValid) {
      throw HabotStoreContractError(
        'Invalid collection name "${collection.name}"',
      );
    }
  }

  final HabotCollection collection;
  final HabotLocalStore store;
  final HabotEntityDecoder<T> decoder;
  final DateTime Function() _clock;

  int _attempted = 0;
  int _succeeded = 0;
  final List<HabotDaoRejection> _rejections = <HabotDaoRejection>[];

  /// Operations attempted against the store, and how many completed.
  int get attempted => _attempted;
  int get succeeded => _succeeded;
  List<HabotDaoRejection> get rejections =>
      List<HabotDaoRejection>.unmodifiable(_rejections);

  /// The LOCAL half of the sheet's metric. See the library comment for what
  /// this is not.
  double get localSuccessRate => _attempted == 0 ? 1 : _succeeded / _attempted;

  // ---- read ---------------------------------------------------------------

  Future<HabotResult<T>> findById(String id) async {
    _attempted++;
    final Uint8List? bytes = await store.read(collection, id);
    if (bytes == null) {
      _succeeded++;
      return HabotFailure<T>(
        failure: HabotDataFailure.notFound,
        detail: 'no local record',
        retryable: false,
      );
    }
    final Map<String, Object?>? record = HabotRecordCodec.decode(bytes);
    if (record == null) {
      _rejections.add(HabotDaoRejection.corruptRecord);
      return HabotFailure<T>(
        failure: HabotDataFailure.corrupt,
        detail: 'stored bytes could not be decoded',
        retryable: false,
      );
    }
    if (record[HabotRecordFields.deleted] == true) {
      _succeeded++;
      return HabotFailure<T>(
        failure: HabotDataFailure.notFound,
        detail: 'record is a tombstone',
        retryable: false,
      );
    }
    final T? entity = decoder(record);
    if (entity == null) {
      _rejections.add(HabotDaoRejection.corruptRecord);
      return HabotFailure<T>(
        failure: HabotDataFailure.corrupt,
        detail: 'record decoded but did not produce an entity',
        retryable: false,
      );
    }
    _succeeded++;
    return HabotSuccess<T>(
      value: entity,
      origin: HabotDataOrigin.local,
      retrievedAt: _readTimestamp(record),
    );
  }

  /// Live records, in insertion order, tombstones excluded.
  Future<HabotResult<List<T>>> findAll() async {
    _attempted++;
    final List<T> out = <T>[];
    for (final String key in await store.keys(collection)) {
      final Uint8List? bytes = await store.read(collection, key);
      if (bytes == null) {
        continue;
      }
      final Map<String, Object?>? record = HabotRecordCodec.decode(bytes);
      if (record == null) {
        _rejections.add(HabotDaoRejection.corruptRecord);
        continue;
      }
      if (record[HabotRecordFields.deleted] == true) {
        continue;
      }
      final T? entity = decoder(record);
      if (entity != null) {
        out.add(entity);
      }
    }
    _succeeded++;
    return HabotSuccess<List<T>>(
      value: out,
      origin: HabotDataOrigin.local,
    );
  }

  /// The stored revision for [id], or null when nothing is stored. Includes
  /// tombstones -- a delete has a revision too, and ignoring it lets a stale
  /// create resurrect a deleted record.
  Future<int?> revisionOf(String id) async {
    final Uint8List? bytes = await store.read(collection, id);
    if (bytes == null) {
      return null;
    }
    final Map<String, Object?>? record = HabotRecordCodec.decode(bytes);
    final Object? r = record?[HabotRecordFields.revision];
    return r is int ? r : null;
  }

  // ---- write --------------------------------------------------------------

  /// Store [entity], if and only if its revision is ahead of what is stored.
  Future<HabotResult<HabotWriteTicket>> save(T entity) async {
    _attempted++;
    if (entity.entityId.trim().isEmpty) {
      _rejections.add(HabotDaoRejection.invalidIdentity);
      return const HabotFailure<HabotWriteTicket>(
        failure: HabotDataFailure.unknown,
        detail: 'entity declared an empty id',
        retryable: false,
      );
    }
    final int? stored = await revisionOf(entity.entityId);
    if (stored != null && entity.revision <= stored) {
      _rejections.add(HabotDaoRejection.staleRevision);
      return HabotFailure<HabotWriteTicket>(
        failure: HabotDataFailure.conflict,
        detail:
            'revision ${entity.revision} is not ahead of the stored revision '
            '$stored; the local copy is newer and has been kept',
        retryable: false,
      );
    }

    final DateTime now = _clock();
    final Map<String, Object?> record = <String, Object?>{
      HabotRecordFields.id: entity.entityId,
      HabotRecordFields.revision: entity.revision,
      HabotRecordFields.deleted: false,
      HabotRecordFields.updatedAt: now.toIso8601String(),
      HabotRecordFields.payload: entity.toRecord(),
    };

    try {
      await store.write(
        collection,
        entity.entityId,
        HabotRecordCodec.encode(record),
      );
    } on HabotStoreWriteException catch (e) {
      return HabotFailure<HabotWriteTicket>(
        failure: e.failure == HabotStoreFailure.full
            ? HabotDataFailure.storageFull
            : HabotDataFailure.unknown,
        detail: e.toString(),
      );
    }

    _succeeded++;
    return HabotSuccess<HabotWriteTicket>(
      value: HabotWriteTicket(
        ticketId: ticketIdFor(collection, entity.entityId, entity.revision),
        entityId: entity.entityId,
        queuedAt: now,
        pending: true,
      ),
      origin: HabotDataOrigin.local,
      retrievedAt: now,
    );
  }

  /// Write a tombstone. See point 3 in the library comment.
  Future<HabotResult<HabotWriteTicket>> delete(
    String id, {
    required int revision,
  }) async {
    _attempted++;
    final int? stored = await revisionOf(id);
    if (stored != null && revision <= stored) {
      _rejections.add(HabotDaoRejection.staleRevision);
      return HabotFailure<HabotWriteTicket>(
        failure: HabotDataFailure.conflict,
        detail:
            'delete at revision $revision is not ahead of the stored '
            'revision $stored',
        retryable: false,
      );
    }
    final DateTime now = _clock();
    await store.write(
      collection,
      id,
      HabotRecordCodec.encode(<String, Object?>{
        HabotRecordFields.id: id,
        HabotRecordFields.revision: revision,
        HabotRecordFields.deleted: true,
        HabotRecordFields.updatedAt: now.toIso8601String(),
        HabotRecordFields.payload: null,
      }),
    );
    _succeeded++;
    return HabotSuccess<HabotWriteTicket>(
      value: HabotWriteTicket(
        ticketId: ticketIdFor(collection, id, revision),
        entityId: id,
        queuedAt: now,
        pending: true,
      ),
      origin: HabotDataOrigin.local,
      retrievedAt: now,
    );
  }

  /// Ids that currently hold a tombstone. Step 118 reads these.
  Future<List<String>> tombstones() async {
    final List<String> out = <String>[];
    for (final String key in await store.keys(collection)) {
      final Uint8List? bytes = await store.read(collection, key);
      if (bytes == null) {
        continue;
      }
      final Map<String, Object?>? record = HabotRecordCodec.decode(bytes);
      if (record?[HabotRecordFields.deleted] == true) {
        out.add(key);
      }
    }
    return out;
  }

  /// Deterministic, so a retry of the same write produces the SAME key. This
  /// is the property Step 122 depends on; a random id here would make every
  /// retry look like a new submission.
  static String ticketIdFor(
    HabotCollection collection,
    String entityId,
    int revision,
  ) => '${collection.name}:$entityId:$revision';

  DateTime? _readTimestamp(Map<String, Object?> record) {
    final Object? raw = record[HabotRecordFields.updatedAt];
    return raw is String ? DateTime.tryParse(raw) : null;
  }
}
