/// AISS Step 113 -- GEN-04484 (part 1 of 2: the store)
/// "Build Data Access Objects (DAOs) for CRUD operations on local entities."
/// Reference standard, verbatim: "Offline-First Mobile Architecture Best
/// Practice" -- the clearest statement of intent in the batch.
/// Metric: Data Synchronization Success Rate -- floor 0.98, optimal 0.999.
///
/// SUBSTITUTION RECORDED. Step 117's row names SQLite. There is no SQLite
/// dependency in this project and this environment cannot reach pub.dev to add
/// one. Rather than pretend, the storage ENGINE is put behind
/// [HabotLocalStore] -- a byte-level key/value contract narrow enough that
/// sqflite, Hive, Isar or a plain file directory all satisfy it. Swapping the
/// engine later is then a change behind an interface rather than a rewrite,
/// which is the entire reason Step 112 came first.
///
/// [HabotMemoryStore] is included and is honestly named: it is what the tests
/// run against and what the app falls back to when no engine is registered.
/// It is NOT durable, and [HabotMemoryStore.isDurable] says so, so nothing can
/// claim offline persistence on the strength of it.
///
/// WHY BYTES AND NOT OBJECTS. A store that takes objects has to know how to
/// serialise them, which drags the entity types into the storage layer and
/// breaks the Step 112 conformance rule about engines in signatures. Bytes in,
/// bytes out; the DAO owns the encoding, and Step 114 wraps this same
/// interface to encrypt them.
library;

import 'dart:convert';
import 'dart:typed_data';

/// A namespace within the store. One per entity type.
extension type const HabotCollection(String name) {
  bool get isValid =>
      name.isNotEmpty &&
      RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name) &&
      name.length <= 40;
}

/// Why a store operation failed.
enum HabotStoreFailure { notFound, full, corrupt, unavailable, rejected }

/// Thrown only for programming errors -- a bad collection name, a key that is
/// not a key. Ordinary failures are returned, not thrown, per Step 112.
class HabotStoreContractError extends ArgumentError {
  HabotStoreContractError(super.message);
}

/// The byte-level storage contract.
///
/// Deliberately small. Every method here can be implemented by any key/value
/// engine on any platform, which is what makes the engine replaceable.
abstract interface class HabotLocalStore {
  /// False for anything that does not survive process death. Callers that
  /// claim offline durability must check this rather than assume it.
  bool get isDurable;

  /// A name for the evidence record, e.g. 'memory' or 'sqflite'.
  String get engineName;

  Future<Uint8List?> read(HabotCollection collection, String key);

  Future<void> write(HabotCollection collection, String key, Uint8List bytes);

  Future<void> remove(HabotCollection collection, String key);

  /// Keys in insertion order. Order matters: Step 117's outbox drains in the
  /// order work was done, and a store that returns a hash order silently
  /// reorders a worker's day.
  Future<List<String>> keys(HabotCollection collection);

  Future<void> clear(HabotCollection collection);

  /// Apply every write or none. Step 116's atomic commit is built on this;
  /// an engine that cannot do it says so and Step 116 refuses to run against
  /// it rather than pretending the guarantee exists.
  bool get supportsTransactions;

  Future<void> transaction(Future<void> Function() body);
}

/// The in-memory implementation. Honest about what it is.
class HabotMemoryStore implements HabotLocalStore {
  HabotMemoryStore({this.failNextWrite = false});

  final Map<String, Map<String, Uint8List>> _data =
      <String, Map<String, Uint8List>>{};

  /// Insertion order per collection, kept explicitly rather than relying on
  /// map iteration order surviving a future refactor.
  final Map<String, List<String>> _order = <String, List<String>>{};

  /// Test seam: makes the next write fail, so the atomic-commit and rollback
  /// paths can be exercised deliberately rather than hoped about.
  bool failNextWrite;

  @override
  bool get isDurable => false;

  @override
  String get engineName => 'memory (NOT durable)';

  @override
  bool get supportsTransactions => true;

  void _check(HabotCollection c) {
    if (!c.isValid) {
      throw HabotStoreContractError('Invalid collection name "${c.name}"');
    }
  }

  @override
  Future<Uint8List?> read(HabotCollection collection, String key) async {
    _check(collection);
    return _data[collection.name]?[key];
  }

  @override
  Future<void> write(
    HabotCollection collection,
    String key,
    Uint8List bytes,
  ) async {
    _check(collection);
    if (failNextWrite) {
      failNextWrite = false;
      throw const HabotStoreWriteException(HabotStoreFailure.full);
    }
    final Map<String, Uint8List> c = _data.putIfAbsent(
      collection.name,
      () => <String, Uint8List>{},
    );
    final List<String> order = _order.putIfAbsent(
      collection.name,
      () => <String>[],
    );
    if (!c.containsKey(key)) {
      order.add(key);
    }
    c[key] = bytes;
  }

  @override
  Future<void> remove(HabotCollection collection, String key) async {
    _check(collection);
    _data[collection.name]?.remove(key);
    _order[collection.name]?.remove(key);
  }

  @override
  Future<List<String>> keys(HabotCollection collection) async {
    _check(collection);
    return List<String>.unmodifiable(_order[collection.name] ?? <String>[]);
  }

  @override
  Future<void> clear(HabotCollection collection) async {
    _check(collection);
    _data.remove(collection.name);
    _order.remove(collection.name);
  }

  @override
  Future<void> transaction(Future<void> Function() body) async {
    // Snapshot, run, restore on failure. A real engine delegates to its own
    // transaction; the guarantee the caller sees is identical.
    final Map<String, Map<String, Uint8List>> dataSnapshot =
        <String, Map<String, Uint8List>>{
          for (final MapEntry<String, Map<String, Uint8List>> e
              in _data.entries)
            e.key: Map<String, Uint8List>.from(e.value),
        };
    final Map<String, List<String>> orderSnapshot = <String, List<String>>{
      for (final MapEntry<String, List<String>> e in _order.entries)
        e.key: List<String>.from(e.value),
    };
    try {
      await body();
    } on Object {
      _data
        ..clear()
        ..addAll(dataSnapshot);
      _order
        ..clear()
        ..addAll(orderSnapshot);
      rethrow;
    }
  }
}

/// A store operation that failed for a reason the caller may want to act on.
class HabotStoreWriteException implements Exception {
  const HabotStoreWriteException(this.failure, [this.detail]);

  final HabotStoreFailure failure;
  final String? detail;

  @override
  String toString() =>
      'HabotStoreWriteException(${failure.name}${detail == null ? "" : ": $detail"})';
}

/// JSON <-> bytes. The one encoding this project uses, declared once so the
/// DAO and the encrypted store cannot disagree about it.
class HabotRecordCodec {
  const HabotRecordCodec._();

  static Uint8List encode(Map<String, Object?> record) =>
      Uint8List.fromList(utf8.encode(json.encode(record)));

  /// Returns null rather than throwing on damaged bytes: a corrupt record is
  /// an ordinary event on a device whose storage filled up mid-write, and it
  /// must not take the whole read down with it.
  static Map<String, Object?>? decode(Uint8List bytes) {
    try {
      final Object? decoded = json.decode(utf8.decode(bytes));
      return decoded is Map<String, Object?> ? decoded : null;
    } on FormatException {
      return null;
    }
  }
}
