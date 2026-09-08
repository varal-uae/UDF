/// AISS Step 116 -- GEN-02093
/// Atomic Step: "Physically prevent partial data states using the atomic
///               commit logic."
/// Metric: Automated PR Rejection Rate for Non-Compliance (%) -- 95 / 99.5 / 100.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row. The Atomic
/// Step is the whole requirement, and it is a strong one -- "physically
/// prevent" is the sharpest poka-yoke sentence in the batch.
///
/// METRIC MISMATCH, RECORDED. A pull-request rejection rate is a code-review
/// measure on a RUNTIME data-integrity rule. No client-side suite can produce
/// it, and it would not mean anything if it could: a PR that passes review can
/// still write half a record. It is reported as NOT PRODUCED. What is gated is
/// the requirement the row actually states, by inducing a failure mid-write and
/// proving nothing survived it.
///
/// WHY THIS SITS HERE, from the build order: Step 20's rollback boundary
/// already restores a form baseline IN MEMORY, and the moment writes become
/// durable a half-written record survives the restart that used to clear it.
/// Step 113 made writes durable. This is the step that closes what that opened.
///
/// WHAT "PHYSICALLY PREVENT" IS READ TO MEAN, so it can be checked rather than
/// admired. Three properties:
///
///   1. A unit of work is COMMITTED OR IT IS NOT. There is no partial state to
///      observe -- not at the end, and not in the middle, because a reader
///      cannot see a staged write until the commit lands.
///   2. FAILURE IS THE DEFAULT. A unit of work that is never committed leaves
///      nothing behind. Forgetting to commit loses the work, which is the safe
///      direction; forgetting to roll back would keep half of it, which is not.
///   3. THE STORE MUST SAY IT CAN DO THIS. A store without transactions is
///      REFUSED at construction rather than being run against optimistically.
///      Pretending a guarantee exists is worse than not having it.
library;

import 'dart:typed_data';

import 'local_store.dart';
import 'repository.dart';

/// Why a unit of work did not commit.
enum HabotCommitFailure {
  /// The store cannot promise all-or-nothing.
  storeHasNoTransactions,

  /// A write inside the unit threw.
  writeFailed,

  /// The caller asked to abort.
  abandoned,

  /// Nothing was staged.
  empty,
}

/// One staged change, held until commit.
class HabotStagedWrite {
  const HabotStagedWrite({
    required this.collection,
    required this.key,
    required this.bytes,
    required this.description,
  });

  final HabotCollection collection;
  final String key;

  /// Null means "remove this key".
  final Uint8List? bytes;

  /// What this write is, in a sentence, so a failed commit can say what was
  /// lost rather than how many bytes were lost.
  final String description;

  bool get isRemoval => bytes == null;

  @override
  String toString() =>
      '${isRemoval ? "remove" : "write"} ${collection.name}/$key -- $description';
}

/// The outcome of a commit attempt.
class HabotCommitResult {
  const HabotCommitResult._({
    required this.committed,
    required this.writes,
    this.failure,
    this.detail,
  });

  const HabotCommitResult.committed(int writes)
    : this._(committed: true, writes: writes);

  const HabotCommitResult.failed({
    required HabotCommitFailure failure,
    required String detail,
  }) : this._(
         committed: false,
         writes: 0,
         failure: failure,
         detail: detail,
       );

  final bool committed;

  /// How many writes landed. Zero on any failure -- that is the point.
  final int writes;

  final HabotCommitFailure? failure;
  final String? detail;

  Map<String, Object?> toJson() => <String, Object?>{
    'committed': committed,
    'writes': writes,
    if (failure != null) 'failure': failure!.name,
    if (detail != null) 'detail': detail,
  };
}

/// Thrown when a unit of work is built on a store that cannot promise
/// all-or-nothing. Property 3.
class HabotNonTransactionalStoreError extends StateError {
  HabotNonTransactionalStoreError(String engine)
    : super(
        'HabotUnitOfWork refuses to run against "$engine", which does not '
        'support transactions. An atomic commit on a store that cannot roll '
        'back is not an atomic commit -- it is the same partial write with a '
        'reassuring name on it.',
      );
}

/// A set of writes that land together or not at all.
///
/// Nothing reaches the store until [commit]. A reader cannot observe a staged
/// write, which is property 1: there is no window in which the record is half
/// there.
class HabotUnitOfWork {
  HabotUnitOfWork(this.store) {
    if (!store.supportsTransactions) {
      throw HabotNonTransactionalStoreError(store.engineName);
    }
  }

  final HabotLocalStore store;

  final List<HabotStagedWrite> _staged = <HabotStagedWrite>[];
  bool _closed = false;

  List<HabotStagedWrite> get staged =>
      List<HabotStagedWrite>.unmodifiable(_staged);

  int get stagedCount => _staged.length;

  /// True once this unit has committed or been abandoned. A closed unit
  /// refuses further staging: reusing one is how two logical transactions end
  /// up sharing a fate neither intended.
  bool get isClosed => _closed;

  void stage(HabotStagedWrite write) {
    if (_closed) {
      throw StateError(
        'This unit of work is already closed. Staging "$write" onto it would '
        'attach a new change to a transaction that has already been decided.',
      );
    }
    _staged.add(write);
  }

  void stageRecord({
    required HabotCollection collection,
    required String key,
    required Map<String, Object?> record,
    required String description,
  }) => stage(
    HabotStagedWrite(
      collection: collection,
      key: key,
      bytes: HabotRecordCodec.encode(record),
      description: description,
    ),
  );

  void stageRemoval({
    required HabotCollection collection,
    required String key,
    required String description,
  }) => stage(
    HabotStagedWrite(
      collection: collection,
      key: key,
      bytes: null,
      description: description,
    ),
  );

  /// Throw the whole unit away. Property 2: this is what happens by default to
  /// anything that is not committed.
  HabotCommitResult abandon(String why) {
    _closed = true;
    final int lost = _staged.length;
    _staged.clear();
    return HabotCommitResult.failed(
      failure: HabotCommitFailure.abandoned,
      detail: '$lost staged write(s) discarded: $why',
    );
  }

  /// Apply every staged write, or none.
  Future<HabotCommitResult> commit() async {
    if (_closed) {
      throw StateError('This unit of work has already been decided.');
    }
    if (_staged.isEmpty) {
      _closed = true;
      return const HabotCommitResult.failed(
        failure: HabotCommitFailure.empty,
        detail: 'nothing was staged; there is nothing to commit',
      );
    }
    final int count = _staged.length;
    try {
      await store.transaction(() async {
        for (final HabotStagedWrite w in _staged) {
          if (w.isRemoval) {
            await store.remove(w.collection, w.key);
          } else {
            await store.write(w.collection, w.key, w.bytes!);
          }
        }
      });
    } on Object catch (e) {
      _closed = true;
      final List<String> lost =
          _staged.map((HabotStagedWrite w) => w.description).toList();
      _staged.clear();
      return HabotCommitResult.failed(
        failure: HabotCommitFailure.writeFailed,
        detail:
            'commit failed after staging $count write(s); the store was left '
            'exactly as it was. Nothing was written. Lost: ${lost.join("; ")}. '
            'Cause: $e',
      );
    }
    _closed = true;
    _staged.clear();
    return HabotCommitResult.committed(count);
  }
}

/// The properties this step claims, so a gate can check them and a reviewer
/// can read them.
class HabotAtomicCommitContract {
  const HabotAtomicCommitContract._();

  static const List<String> properties = <String>[
    'a unit of work commits entirely or not at all',
    'a staged write is not observable before the commit lands',
    'an uncommitted unit leaves nothing behind -- failure is the default',
    'a store without transactions is refused at construction',
    'a decided unit cannot be reused',
  ];

  /// The relationship to Step 115, stated once. A mutation log is the ORDER of
  /// changes; a unit of work is the ATOMICITY of them. Both are needed and
  /// neither replaces the other: replaying a log that contains half a unit of
  /// work reproduces the half.
  static const String relationToMutations =
      'Step 115 gives a change an identity, an order and an inverse. Step 116 '
      'gives a GROUP of changes a single fate. A replay of a mutation log that '
      'contains a partially applied unit would faithfully reproduce the '
      'partial state, which is why the group boundary has to exist underneath '
      'the log rather than being derived from it.';

  static HabotResult<int> asResult(HabotCommitResult r) => r.committed
      ? HabotSuccess<int>(value: r.writes, origin: HabotDataOrigin.local)
      : HabotFailure<int>(
          failure: HabotDataFailure.corrupt,
          detail: r.detail ?? 'commit failed',
          retryable: r.failure != HabotCommitFailure.abandoned,
        );
}
