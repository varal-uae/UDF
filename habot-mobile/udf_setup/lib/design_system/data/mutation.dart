/// AISS Step 115 -- GEN-04429
/// "Enforce immutability patterns across state updates using mutation
///  wrappers."
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// METRIC MISMATCH, RECORDED. The sheet gives this row a re-render latency in
/// milliseconds. That is a rendering measure on an immutability rule, and no
/// honest reading connects the two: a state container can be perfectly
/// immutable and slow, or mutable and fast. No latency figure is invented. The
/// step is gated on the property it names.
///
/// WHY THIS COMES BEFORE THE WRITE PATH RATHER THAN AFTER IT, from the build
/// order: "a store you can mutate in place is a store whose writes cannot be
/// ordered, replayed or rolled back -- which breaks the outbox at 117 and the
/// atomic commit at 116 before either is written."
///
/// That is the whole argument, and it is worth being precise about. Three
/// things Steps 116-123 need are all the same requirement wearing different
/// clothes:
///
///   * Step 116's atomic commit needs to UNDO a partial write. Undo requires
///     the previous value still to exist.
///   * Step 117's outbox needs to REPLAY a queued write after a restart.
///     Replay requires the change to be a value that can be stored, not a
///     side effect that already happened.
///   * Step 122's idempotency needs to recognise the SAME write twice. Same
///     requires the write to have an identity.
///
/// A [HabotMutation] is a change with a previous value, a next value and an
/// identity. It is what makes all three possible, which is why it is here and
/// not bolted on later.
///
/// WHAT "ENFORCE" MEANS HERE. Not a lint. [HabotImmutableStore] has no method
/// that takes a new state directly -- the only way in is [apply], which takes
/// a mutation. There is nowhere to write an in-place update, which is a
/// stronger guarantee than a rule saying not to.
library;

import 'repository.dart';

/// A described, replayable, ordered change to one value.
///
/// Immutable itself: `previous` and `next` are captured, not referenced
/// through something that can move underneath them.
class HabotMutation<T> {
  const HabotMutation({
    required this.mutationId,
    required this.description,
    required this.previous,
    required this.next,
    required this.sequence,
  });

  /// Stable across retries -- see Step 122. Two attempts at the same change
  /// carry the same id, which is what makes a duplicate recognisable.
  final String mutationId;

  /// What changed, in a sentence. Written for the person reading a replay log
  /// six months from now, who has no idea what `s.copyWith(f: true)` meant.
  final String description;

  final T previous;
  final T next;

  /// Monotonic within a store. Ordering is a property of the mutation, not of
  /// the order a list happened to end up in.
  final int sequence;

  /// The mutation that undoes this one. Note it keeps the same [mutationId]:
  /// an inverse is not a new change, it is the same change being taken back,
  /// and giving it a fresh id would let a replay apply both.
  HabotMutation<T> get inverse => HabotMutation<T>(
    mutationId: mutationId,
    description: 'undo: $description',
    previous: next,
    next: previous,
    sequence: sequence,
  );

  bool get isNoOp => previous == next;

  Map<String, Object?> toJson() => <String, Object?>{
    'mutation_id': mutationId,
    'description': description,
    'sequence': sequence,
    'is_no_op': isNoOp,
  };

  @override
  String toString() => '#$sequence $mutationId: $description';
}

/// Why a mutation was refused.
enum HabotMutationRejection {
  /// Its `previous` does not match the store's current value, so applying it
  /// would silently discard whatever happened in between.
  staleBase,

  /// Its sequence is not ahead of the last applied one.
  outOfOrder,

  /// Its id has already been applied. See Step 122.
  duplicate,

  /// It changes nothing.
  noOp,
}

/// The outcome of offering a mutation to a store.
class HabotMutationOutcome<T> {
  const HabotMutationOutcome._({
    required this.applied,
    required this.state,
    this.rejection,
    this.detail,
  });

  const HabotMutationOutcome.applied(T state)
    : this._(applied: true, state: state);

  const HabotMutationOutcome.rejected({
    required T state,
    required HabotMutationRejection rejection,
    required String detail,
  }) : this._(
         applied: false,
         state: state,
         rejection: rejection,
         detail: detail,
       );

  final bool applied;

  /// The state after the attempt. Unchanged when [applied] is false.
  final T state;

  final HabotMutationRejection? rejection;
  final String? detail;
}

/// A state container that can only be changed by applying a mutation.
///
/// There is no setter, no `state =`, no `update(fn)`. That is the enforcement.
class HabotImmutableStore<T> {
  HabotImmutableStore(T initial) : _state = initial;

  T _state;
  int _lastSequence = 0;
  final List<HabotMutation<T>> _applied = <HabotMutation<T>>[];
  final Set<String> _appliedIds = <String>{};
  final List<HabotMutationRejection> _rejections = <HabotMutationRejection>[];

  /// The current value. Read-only by construction -- the field is private and
  /// there is no setter anywhere in this class.
  T get state => _state;

  int get lastSequence => _lastSequence;

  /// Every change, in order. This is the replay log Steps 117 and 123 drain,
  /// and the undo stack Step 116 unwinds.
  List<HabotMutation<T>> get history =>
      List<HabotMutation<T>>.unmodifiable(_applied);

  List<HabotMutationRejection> get rejections =>
      List<HabotMutationRejection>.unmodifiable(_rejections);

  /// Build the next mutation. Sequence is assigned here, not by the caller,
  /// so two callers cannot mint the same one.
  HabotMutation<T> mutation({
    required String mutationId,
    required String description,
    required T next,
  }) => HabotMutation<T>(
    mutationId: mutationId,
    description: description,
    previous: _state,
    next: next,
    sequence: _lastSequence + 1,
  );

  HabotMutationOutcome<T> apply(HabotMutation<T> m) {
    if (_appliedIds.contains(m.mutationId)) {
      _rejections.add(HabotMutationRejection.duplicate);
      return HabotMutationOutcome<T>.rejected(
        state: _state,
        rejection: HabotMutationRejection.duplicate,
        detail:
            'mutation "${m.mutationId}" has already been applied; applying it '
            'again would double the change',
      );
    }
    if (m.isNoOp) {
      _rejections.add(HabotMutationRejection.noOp);
      return HabotMutationOutcome<T>.rejected(
        state: _state,
        rejection: HabotMutationRejection.noOp,
        detail: 'mutation "${m.mutationId}" changes nothing',
      );
    }
    if (m.previous != _state) {
      _rejections.add(HabotMutationRejection.staleBase);
      return HabotMutationOutcome<T>.rejected(
        state: _state,
        rejection: HabotMutationRejection.staleBase,
        detail:
            'mutation "${m.mutationId}" was built against a state that is no '
            'longer current; applying it would discard the change in between',
      );
    }
    if (m.sequence <= _lastSequence) {
      _rejections.add(HabotMutationRejection.outOfOrder);
      return HabotMutationOutcome<T>.rejected(
        state: _state,
        rejection: HabotMutationRejection.outOfOrder,
        detail:
            'sequence ${m.sequence} is not ahead of the last applied '
            '$_lastSequence',
      );
    }

    _state = m.next;
    _lastSequence = m.sequence;
    _applied.add(m);
    _appliedIds.add(m.mutationId);
    return HabotMutationOutcome<T>.applied(_state);
  }

  /// Undo the last [count] mutations, newest first.
  ///
  /// This is the mechanism Step 116's atomic commit is built on: a partial
  /// write is a run of mutations that must all come back off.
  int rollback({int count = 1}) {
    int undone = 0;
    while (undone < count && _applied.isNotEmpty) {
      final HabotMutation<T> last = _applied.removeLast();
      _appliedIds.remove(last.mutationId);
      _state = last.previous;
      _lastSequence = last.sequence - 1;
      undone++;
    }
    return undone;
  }

  /// Replay a log onto this store. Used after a restart: the durable half is
  /// the LOG, and the state is derived from it rather than stored separately,
  /// so the two cannot disagree.
  List<HabotMutationOutcome<T>> replay(List<HabotMutation<T>> log) =>
      log.map(apply).toList();
}

/// The properties this step claims, expressed so a gate can check them rather
/// than a reviewer having to believe them.
class HabotImmutabilityContract {
  const HabotImmutabilityContract._();

  static const List<String> properties = <String>[
    'the only way to change a store is to apply a mutation',
    'every mutation carries the value it replaced, so it can be undone',
    'every mutation carries a stable id, so a duplicate is recognisable',
    'every mutation carries a sequence, so a replay is ordered',
    'a mutation built against stale state is refused, not merged',
  ];

  /// Applying the same log twice must leave the same state as applying it
  /// once. This is the property Step 122's idempotency rests on, and it is
  /// checkable directly.
  static bool replayIsIdempotent<T>(T initial, List<HabotMutation<T>> log) {
    final HabotImmutableStore<T> once = HabotImmutableStore<T>(initial)
      ..replay(log);
    final HabotImmutableStore<T> twice = HabotImmutableStore<T>(initial)
      ..replay(log)
      ..replay(log);
    return once.state == twice.state &&
        once.history.length == twice.history.length;
  }

  /// A rolled-back run leaves the store exactly where it started.
  static bool rollbackIsExact<T>(T initial, List<HabotMutation<T>> log) {
    final HabotImmutableStore<T> s = HabotImmutableStore<T>(initial)
      ..replay(log);
    s.rollback(count: log.length);
    return s.state == initial && s.history.isEmpty;
  }
}

/// Wraps a repository write so the change is recorded as a mutation before it
/// is attempted, not after it succeeds.
///
/// The ordering matters: a write recorded only on success is a write that
/// cannot be retried after a crash, because nothing remembers it was wanted.
class HabotMutatingWriter<T extends HabotEntity> {
  HabotMutatingWriter({
    required this.repository,
    required HabotImmutableStore<List<T>> store,
  }) : _store = store;

  final HabotWriteRepository<T> repository;
  final HabotImmutableStore<List<T>> _store;

  HabotImmutableStore<List<T>> get store => _store;

  /// Record the intent, then attempt the write. On failure the mutation stays
  /// in the log -- that is the queue Step 117 drains, and removing it here
  /// would be the app forgetting work the user did.
  Future<HabotResult<HabotWriteTicket>> save(T entity) async {
    final List<T> next = <T>[
      ..._store.state.where((T e) => e.entityId != entity.entityId),
      entity,
    ];
    final HabotMutation<List<T>> m = _store.mutation(
      mutationId: '${entity.entityId}:${entity.revision}',
      description: 'save ${entity.entityId} at revision ${entity.revision}',
      next: next,
    );
    _store.apply(m);
    return repository.save(entity);
  }
}
