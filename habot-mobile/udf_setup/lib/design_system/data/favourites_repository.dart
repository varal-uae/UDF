/// AISS Step 132 -- GEN-01496
/// Atomic Step: "Write bookmark additions, removals, and collection mappings
///               to the BigQuery user_favorites_v1 table."
/// Metric: Saved-State Persistence Reliability -- Floor 0.98, Optimal 1,
///         Ceiling 1.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// A CORRECTION TO THE STEPS 111-125 BUILD ORDER, RECORDED. That document
/// lists this row as "saved-state persistence reliability" -- its metric name,
/// not its requirement. The Atomic Step is specific and quite different: write
/// bookmark ADDITIONS, REMOVALS and COLLECTION MAPPINGS to a named BigQuery
/// table. Three operations and a destination, not a general reliability
/// property. Building from the earlier characterisation would have produced
/// the wrong thing.
///
/// WHAT A CLIENT CAN AND CANNOT DO ABOUT A BIGQUERY TABLE. It cannot write to
/// one -- BigQuery is not a client-facing store, and a mobile app holding
/// credentials for a warehouse would be a security defect rather than a
/// feature. What the client owns is the near half: record the three
/// operations durably, in order, and hand them to the Step 117 outbox for the
/// server to land in `user_favorites_v1`. The far half is a server concern and
/// is recorded as such rather than faked.
///
/// WHY REMOVALS ARE THE INTERESTING CASE. An addition that fails to sync
/// reappears as missing -- annoying, obvious, recoverable. A REMOVAL that
/// fails to sync comes back: the user deletes a bookmark, closes the app, and
/// it returns. That is the bug people report as "the app does not save
/// anything", and it is why a removal is a tombstone (Step 113) rather than a
/// deletion. The server has to learn that the absence was deliberate.
///
/// COLLECTION MAPPINGS ARE THE THIRD OPERATION and are not derivable from the
/// other two: a bookmark can move between collections without being added or
/// removed. Modelling that as remove-then-add would produce two rows in
/// `user_favorites_v1` for one user action and lose the ordering that says
/// which collection it ended up in.
library;

import 'dao.dart';
import 'local_store.dart';
import 'outbox.dart';
import 'repository.dart';

/// The three operations the row names. Not more, not fewer.
enum HabotFavouriteOp { add, remove, mapToCollection }

/// One bookmark, as this client holds it.
class HabotFavourite implements HabotEntity {
  const HabotFavourite({
    required this.entityId,
    required this.revision,
    required this.itemId,
    required this.collectionName,
    this.removed = false,
  });

  @override
  final String entityId;

  @override
  final int revision;

  /// What was bookmarked.
  final String itemId;

  /// Which collection it sits in. Empty means the default collection.
  final String collectionName;

  /// A removal kept as a record rather than an absence -- see the header.
  final bool removed;

  @override
  Map<String, Object?> toRecord() => <String, Object?>{
    'item_id': itemId,
    'collection': collectionName,
    'removed': removed,
  };

  HabotFavourite copyWith({
    int? revision,
    String? collectionName,
    bool? removed,
  }) => HabotFavourite(
    entityId: entityId,
    revision: revision ?? this.revision,
    itemId: itemId,
    collectionName: collectionName ?? this.collectionName,
    removed: removed ?? this.removed,
  );

  static HabotFavourite? fromRecord(
    String id,
    int revision,
    Map<String, Object?> payload,
  ) {
    final Object? item = payload['item_id'];
    if (item is! String) {
      return null;
    }
    return HabotFavourite(
      entityId: id,
      revision: revision,
      itemId: item,
      collectionName: payload['collection'] is String
          ? payload['collection']! as String
          : '',
      removed: payload['removed'] == true,
    );
  }
}

/// One recorded change, in the shape the server needs to land a row.
class HabotFavouriteChange {
  const HabotFavouriteChange({
    required this.op,
    required this.favourite,
    required this.at,
  });

  final HabotFavouriteOp op;
  final HabotFavourite favourite;
  final DateTime at;

  /// The destination named by the row, carried on the payload rather than
  /// assumed by the server. If the table is ever versioned to v2, this is the
  /// one place that changes.
  static const String destinationTable = 'user_favorites_v1';

  Map<String, Object?> toPayload() => <String, Object?>{
    'entity_id': favourite.entityId,
    'op': op.name,
    'item_id': favourite.itemId,
    'collection': favourite.collectionName,
    'removed': favourite.removed,
    'revision': favourite.revision,
    'at': at.toIso8601String(),
    'destination_table': destinationTable,
  };
}

/// Bookmarks: written locally first, queued for the server second.
class HabotFavouritesRepository {
  HabotFavouritesRepository({
    required HabotLocalStore store,
    required this.outbox,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       dao = HabotDao<HabotFavourite>(
         collection: collection,
         store: store,
         decoder: (Map<String, Object?> record) {
           final Object? id = record[HabotRecordFields.id];
           final Object? rev = record[HabotRecordFields.revision];
           final Object? payload = record[HabotRecordFields.payload];
           if (id is! String || rev is! int || payload is! Map<String, Object?>) {
             return null;
           }
           return HabotFavourite.fromRecord(id, rev, payload);
         },
       );

  static const HabotCollection collection = HabotCollection('favourites');
  static const String outboxKind = 'favourite-change';

  final HabotDao<HabotFavourite> dao;
  final HabotOutbox outbox;
  final DateTime Function() _clock;

  final List<HabotFavouriteChange> _recorded = <HabotFavouriteChange>[];

  /// Ticket ids that were actually handed to the outbox. Tracked at the moment
  /// of enqueue rather than inferred later: once an entry has been sent it is
  /// gone from the queue, and "not in the queue" cannot then distinguish
  /// "delivered" from "never queued at all" -- which is exactly the failure
  /// this metric is supposed to catch.
  final Set<String> _handedOver = <String>{};

  List<HabotFavouriteChange> get recorded =>
      List<HabotFavouriteChange>.unmodifiable(_recorded);

  int get changesRecorded => _recorded.length;

  Future<HabotResult<HabotWriteTicket>> _persist(
    HabotFavourite next,
    HabotFavouriteOp op,
  ) async {
    // Local first. The user's action is durable before the network is
    // involved -- the Step 112 contract, applied here.
    final HabotResult<HabotWriteTicket> saved = await dao.save(next);
    if (!saved.isSuccess) {
      return saved;
    }
    final HabotFavouriteChange change = HabotFavouriteChange(
      op: op,
      favourite: next,
      at: _clock(),
    );
    _recorded.add(change);
    final String ticket = saved.valueOrNull!.ticketId;
    await outbox.enqueue(
      id: ticket,
      kind: outboxKind,
      payload: change.toPayload(),
    );
    _handedOver.add(ticket);
    return saved;
  }

  /// Operation 1.
  Future<HabotResult<HabotWriteTicket>> add({
    required String entityId,
    required String itemId,
    String collectionName = '',
  }) async {
    final int rev = (await dao.revisionOf(entityId) ?? 0) + 1;
    return _persist(
      HabotFavourite(
        entityId: entityId,
        revision: rev,
        itemId: itemId,
        collectionName: collectionName,
      ),
      HabotFavouriteOp.add,
    );
  }

  /// Operation 2. A tombstone, not a deletion -- see the header.
  Future<HabotResult<HabotWriteTicket>> remove(String entityId) async {
    final HabotResult<HabotFavourite> current = await dao.findById(entityId);
    final HabotFavourite? existing = current.valueOrNull;
    if (existing == null) {
      return const HabotFailure<HabotWriteTicket>(
        failure: HabotDataFailure.notFound,
        detail: 'nothing to remove',
        retryable: false,
      );
    }
    return _persist(
      existing.copyWith(revision: existing.revision + 1, removed: true),
      HabotFavouriteOp.remove,
    );
  }

  /// Operation 3. Not remove-then-add -- see the header.
  Future<HabotResult<HabotWriteTicket>> mapToCollection({
    required String entityId,
    required String collectionName,
  }) async {
    final HabotResult<HabotFavourite> current = await dao.findById(entityId);
    final HabotFavourite? existing = current.valueOrNull;
    if (existing == null) {
      return const HabotFailure<HabotWriteTicket>(
        failure: HabotDataFailure.notFound,
        detail: 'nothing to map',
        retryable: false,
      );
    }
    return _persist(
      existing.copyWith(
        revision: existing.revision + 1,
        collectionName: collectionName,
      ),
      HabotFavouriteOp.mapToCollection,
    );
  }

  /// Live bookmarks, tombstones excluded.
  Future<List<HabotFavourite>> current() async {
    final HabotResult<List<HabotFavourite>> all = await dao.findAll();
    return (all.valueOrNull ?? const <HabotFavourite>[])
        .where((HabotFavourite f) => !f.removed)
        .toList();
  }

  /// The metric, over the half the client owns: of the changes the user made,
  /// the share that were durably recorded AND queued for the server.
  ///
  /// A change written locally but not queued would survive a restart and never
  /// reach anyone else, which is the failure this figure is for.
  Future<double> persistenceReliability() async {
    if (_recorded.isEmpty) {
      return 1;
    }
    int accounted = 0;
    for (final HabotFavouriteChange c in _recorded) {
      final String ticket = HabotDao.ticketIdFor(
        collection,
        c.favourite.entityId,
        c.favourite.revision,
      );
      final bool storedLocally =
          (await dao.revisionOf(c.favourite.entityId)) != null;
      if (storedLocally && _handedOver.contains(ticket)) {
        accounted++;
      }
    }
    return accounted / _recorded.length;
  }

  /// Changes that were written locally but never reached the queue. Empty is
  /// the requirement; non-empty names each one, because a silent count tells
  /// nobody which bookmark will never reach the server.
  List<String> get notHandedOver => _recorded
      .where(
        (HabotFavouriteChange c) => !_handedOver.contains(
          HabotDao.ticketIdFor(
            collection,
            c.favourite.entityId,
            c.favourite.revision,
          ),
        ),
      )
      .map((HabotFavouriteChange c) => '${c.op.name} ${c.favourite.entityId}')
      .toList();

  static const double floor = 0.98;
  static const double optimal = 1.0;

  static const String characterisationCorrection =
      'The Steps 111-125 build order lists this row as "saved-state '
      'persistence reliability", which is its metric name rather than its '
      'requirement. The Atomic Step names three specific operations -- '
      'bookmark additions, removals and collection mappings -- and a '
      'destination table. Building from the earlier characterisation would '
      'have produced the wrong component.';

  static const String bigQueryBoundary =
      'A mobile client cannot and must not write to BigQuery: it is not a '
      'client-facing store, and an app holding warehouse credentials would be '
      'a security defect rather than a feature. The client owns the near half '
      '-- record the three operations durably and in order, and hand them to '
      'the outbox carrying the destination table name. Landing the row in '
      'user_favorites_v1 is a server concern and is recorded as such.';
}
