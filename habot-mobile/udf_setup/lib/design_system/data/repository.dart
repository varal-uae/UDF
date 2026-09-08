/// AISS Step 112 -- GEN-03327
/// "Write abstract Repository interfaces for data fetching and local
///  persistence."
/// Metric: Repository Abstract Conformance -- floor 1.0, optimal 1.0,
///         ceiling 1.0. Reference standard: SOLID.
///
/// THE BEST-ALIGNED ROW IN THE BATCH. All three bands are 1.0, which is the
/// sheet saying: this is not a percentage, it is a yes. Either every
/// repository conforms or the step has not been done. That is gated literally.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// WHAT "CONFORMANCE" IS MADE OF, so the 1.0 means something. Four properties,
/// each checkable:
///
///   1. NO STORAGE ENGINE IN THE SIGNATURE. A repository that returns a
///      database row type is not an abstraction, it is a rename. Everything
///      here is expressed in entities and [HabotResult].
///   2. FAILURE IS A VALUE, NOT AN EXCEPTION. An offline-first app spends its
///      life in the failure path; a design where the normal case throws is a
///      design where callers forget to catch. [HabotResult] makes the failure
///      as typed as the success.
///   3. FRESHNESS IS EXPLICIT. Every read says where the data came from and
///      how old it is, because "is this stale?" is a question the caller must
///      be able to answer and the repository cannot answer for them.
///   4. WRITES ARE ADDRESSED, NOT FIRED. A write returns the identity of what
///      it queued, so Step 122 can attach an idempotency key to it and Step
///      117 can find it again after a restart.
///
/// WHY THIS COMES BEFORE THE DAO. Everything downstream imports this
/// interface. A DAO written first is a DAO the interface gets bent around,
/// and the bend is always in the direction of whatever storage engine was
/// convenient that week.
///
/// SDUI, RECORDED. The Step 114 row mentions "SDUI layout JSON". This
/// interface is designed for RECORDS, not for layouts. If server-driven UI is
/// ever genuinely planned, this file is where that decision lands, and it
/// would be a different interface -- not this one with a `Map` squeezed
/// through it.
library;

/// Where a value came from. The caller decides what to do about it; the
/// repository only has to be honest.
enum HabotDataOrigin {
  /// Read from the server in this call.
  network,

  /// Read from the device.
  local,

  /// Read from the device, and the server has not been reachable since.
  localStale,

  /// Nothing was available anywhere.
  none,
}

/// Why a read or write did not succeed.
enum HabotDataFailure {
  offline,
  timeout,
  unauthorised,
  notFound,
  conflict,
  storageFull,
  corrupt,
  serverFailure,
  unknown,
}

/// A success or a failure, as a value.
///
/// Sealed so a `switch` over it is exhaustive and a new case cannot be added
/// without every caller being told about it.
sealed class HabotResult<T> {
  const HabotResult();

  bool get isSuccess => this is HabotSuccess<T>;

  /// The value, or null. Deliberately not a getter that throws: an
  /// offline-first caller reaches for this constantly.
  T? get valueOrNull =>
      this is HabotSuccess<T> ? (this as HabotSuccess<T>).value : null;

  HabotDataFailure? get failureOrNull =>
      this is HabotFailure<T> ? (this as HabotFailure<T>).failure : null;
}

class HabotSuccess<T> extends HabotResult<T> {
  const HabotSuccess({
    required this.value,
    required this.origin,
    this.retrievedAt,
  });

  final T value;

  /// Property 3: freshness is explicit.
  final HabotDataOrigin origin;

  /// When the value was obtained from its origin. Null for a value that has
  /// never left the device.
  final DateTime? retrievedAt;

  bool get isStale => origin == HabotDataOrigin.localStale;

  Duration? ageAt(DateTime now) =>
      retrievedAt == null ? null : now.difference(retrievedAt!);
}

class HabotFailure<T> extends HabotResult<T> {
  const HabotFailure({
    required this.failure,
    required this.detail,
    this.cachedValue,
    this.retryable = true,
  });

  final HabotDataFailure failure;

  /// Scrubbed, human-readable. Step 19 owns the sentence a USER sees; this is
  /// the sentence a developer sees.
  final String detail;

  /// An offline read can fail AND still have something to show. Losing that
  /// distinction is how offline-first apps end up with blank screens.
  final T? cachedValue;

  final bool retryable;
}

/// Anything a repository can store. An entity knows its own identity and
/// nothing about how it is stored.
abstract interface class HabotEntity {
  /// Stable across devices and restarts. Not a database row id.
  String get entityId;

  /// Monotonic per entity. Step 118's delta path and Step 116's atomic commit
  /// both need to know which of two copies is later without asking a clock
  /// that may be wrong.
  int get revision;

  Map<String, Object?> toRecord();
}

/// The identity of a queued write. Property 4.
class HabotWriteTicket {
  const HabotWriteTicket({
    required this.ticketId,
    required this.entityId,
    required this.queuedAt,
    required this.pending,
  });

  /// Unique per attempt. Step 122 uses this as the idempotency key, which is
  /// why it is generated at queue time and not at send time -- a key made at
  /// send time is a new key on every retry, which is no key at all.
  final String ticketId;

  final String entityId;
  final DateTime queuedAt;

  /// True while the write has not reached the server.
  final bool pending;

  Map<String, Object?> toJson() => <String, Object?>{
    'ticket_id': ticketId,
    'entity_id': entityId,
    'queued_at': queuedAt.toIso8601String(),
    'pending': pending,
  };
}

/// Read access.
abstract interface class HabotReadRepository<T extends HabotEntity> {
  /// One entity. Never throws for an ordinary failure.
  Future<HabotResult<T>> findById(String id);

  /// Everything this repository holds, in a stable order.
  Future<HabotResult<List<T>>> findAll();

  /// A stream that emits on every local change, so a screen does not poll.
  Stream<List<T>> watchAll();
}

/// Write access.
abstract interface class HabotWriteRepository<T extends HabotEntity> {
  /// Store [entity] locally and queue it for the server.
  ///
  /// Returns as soon as the LOCAL write is durable. That is the offline-first
  /// contract: the user's work is safe before the network is involved, and
  /// the ticket is how they find out later whether it left the device.
  Future<HabotResult<HabotWriteTicket>> save(T entity);

  Future<HabotResult<HabotWriteTicket>> delete(String id);

  /// Writes that have not reached the server. This is what the Step 48
  /// offline banner counts and what Step 125's chip renders.
  Future<HabotResult<List<HabotWriteTicket>>> pendingWrites();
}

/// Both halves. Most callers want this.
abstract interface class HabotRepository<T extends HabotEntity>
    implements HabotReadRepository<T>, HabotWriteRepository<T> {}

/// The conformance check the metric names.
///
/// The bands are 1.0 / 1.0 / 1.0, so this returns a boolean per property and
/// the gate requires all of them. A percentage would let three quarters of an
/// abstraction pass, and three quarters of an abstraction is a leak.
class HabotRepositoryConformance {
  const HabotRepositoryConformance._();

  static const List<String> properties = <String>[
    'no storage engine appears in any signature',
    'failure is returned as a value, not thrown',
    'every read declares its origin and age',
    'every write returns an addressable ticket',
  ];

  /// Property 1, checked against a type name rather than trusted.
  ///
  /// The names below are the engines this project might plausibly acquire.
  /// A repository signature mentioning one of them has stopped being an
  /// abstraction.
  static const Set<String> forbiddenEngineTokens = <String>{
    'sqlite',
    'sqflite',
    'hive',
    'isar',
    'objectbox',
    'sharedpreferences',
    'firestore',
    'bigquery',
    'cursor',
    'resultset',
    'row',
    'table',
    'column',
  };

  static bool signatureIsClean(String signature) {
    final String lower = signature.toLowerCase();
    return !forbiddenEngineTokens.any(lower.contains);
  }

  /// The exact figure the metric asks for: 1.0 or nothing.
  static double rate({required List<bool> propertyResults}) =>
      propertyResults.every((bool b) => b) ? 1.0 : 0.0;
}
