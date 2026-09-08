/// AISS Step 122 -- GEN-03635
/// Atomic Step: "Build the reusable component: Idempotent API Wrapper
///               Middleware @enforce_idempotency."
/// Metric: Middleware Reusability Score -- Floor 0.9, Optimal 1, Ceiling 1.
/// Data Collected by System: "@enforce_idempotency".
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// NON-NEGOTIABLE ONCE 117 AND 121 EXIST TOGETHER, from the build order: "a
/// queue that retries plus a link that reconnects means the same submission
/// WILL be sent twice -- and without an idempotency key the second one is a
/// duplicate task, a duplicate payment or a duplicate approval."
///
/// It is placed after both so it wraps a real retry path rather than a
/// hypothetical one.
///
/// `@ENFORCE_IDEMPOTENCY` IS A PYTHON DECORATOR. The row names one, and Dart
/// has no equivalent that can wrap behaviour at runtime -- an annotation here
/// is metadata a code generator would have to act on, and there is no
/// generator in this project. So the mechanism is a WRAPPER rather than an
/// annotation: [HabotIdempotentDispatcher.send] is the only way to reach the
/// wire, and it cannot be called without a key. That is the same guarantee the
/// decorator gives, obtained the way this language obtains it, and the
/// substitution is recorded rather than papered over.
///
/// WHAT IDEMPOTENCY MEANS HERE, precisely, because the word is used loosely:
/// sending the same key twice must have the same effect on the SERVER as
/// sending it once, and must return the same answer to the CALLER. Three
/// mechanisms, because a duplicate arrives in three different ways:
///
///   1. IN FLIGHT. The same key is sent while the first attempt is still
///      outstanding -- a double tap, or the sync loop racing the user. The
///      second caller joins the first request rather than starting a second.
///   2. ALREADY SETTLED. The same key is sent after a successful reply. The
///      cached reply is returned and NOTHING goes to the wire.
///   3. UNKNOWN OUTCOME. The request went out and the answer never came back.
///      This is the case that actually matters, and the only safe move is to
///      retry with the SAME key so the server can recognise it. A new key here
///      is what creates the duplicate payment.
///
/// THE KEY COMES FROM STEP 113. `HabotDao.ticketIdFor` is deterministic in
/// collection, entity and revision, so a retry of the same write produces the
/// same key without anyone remembering to keep one.
library;

import 'dart:async';

/// How a send ended.
enum HabotSendOutcome {
  /// The server answered and the answer was kept.
  settled,

  /// The server answered a previous attempt; this one returned that answer
  /// without touching the wire.
  replayed,

  /// Joined an attempt that was already in flight.
  coalesced,

  /// Sent, and the answer never arrived. Safe to retry with the same key.
  unknown,

  /// The server refused in a way that will not change on retry.
  rejected,
}

/// The result of one send.
class HabotSendResult<R> {
  const HabotSendResult({
    required this.key,
    required this.outcome,
    required this.attempts,
    this.value,
    this.detail,
  });

  final String key;
  final HabotSendOutcome outcome;

  /// How many times this key has actually reached the wire. The number that
  /// matters: it must be 1 no matter how many times the caller asked.
  final int attempts;

  final R? value;
  final String? detail;

  bool get reachedServer =>
      outcome == HabotSendOutcome.settled || outcome == HabotSendOutcome.unknown;

  bool get isDuplicateSuppressed =>
      outcome == HabotSendOutcome.replayed ||
      outcome == HabotSendOutcome.coalesced;

  Map<String, Object?> toJson() => <String, Object?>{
    'key': key,
    'outcome': outcome.name,
    'wire_attempts': attempts,
    if (detail != null) 'detail': detail,
  };
}

/// Thrown when a caller tries to reach the wire without a key.
class HabotMissingIdempotencyKeyError extends ArgumentError {
  HabotMissingIdempotencyKeyError()
    : super(
        'A send with no idempotency key cannot be made safe. The key is not '
        'optional: it is what lets the server recognise the second copy of a '
        'submission that the outbox retried or the socket resent. Use '
        'HabotDao.ticketIdFor, which is deterministic in collection, entity '
        'and revision.',
      );
}

/// Wraps every call to the wire.
///
/// There is no way past it: [send] is the only entry point and it requires a
/// key. That is what the row's decorator would have enforced.
class HabotIdempotentDispatcher {
  HabotIdempotentDispatcher({this.replayCacheLimit = 200});

  /// How many settled answers to remember. Bounded, because an unbounded
  /// replay cache is a memory leak wearing a correctness argument.
  final int replayCacheLimit;

  final Map<String, Object?> _settled = <String, Object?>{};
  final List<String> _settledOrder = <String>[];
  final Map<String, Future<Object?>> _inFlight = <String, Future<Object?>>{};
  final Map<String, int> _wireAttempts = <String, int>{};

  /// Distinct payload kinds this dispatcher has been used for. The metric the
  /// row names -- "Middleware Reusability Score" -- is reuse, and reuse is
  /// countable: a wrapper used by one call site is not reusable, it is a
  /// function.
  final Set<String> _kindsWrapped = <String>{};

  Set<String> get kindsWrapped => Set<String>.unmodifiable(_kindsWrapped);

  int wireAttemptsFor(String key) => _wireAttempts[key] ?? 0;

  bool hasSettled(String key) => _settled.containsKey(key);

  bool isInFlight(String key) => _inFlight.containsKey(key);

  int get settledCount => _settled.length;

  void _remember(String key, Object? value) {
    _settled[key] = value;
    _settledOrder.add(key);
    while (_settledOrder.length > replayCacheLimit) {
      _settled.remove(_settledOrder.removeAt(0));
    }
  }

  /// Send once, whatever the caller does.
  ///
  /// [call] is what actually reaches the wire; it is invoked at most once per
  /// key until that key settles. [kind] is recorded for the reusability count.
  Future<HabotSendResult<R>> send<R>({
    required String key,
    required String kind,
    required Future<R> Function() call,
  }) async {
    if (key.trim().isEmpty) {
      throw HabotMissingIdempotencyKeyError();
    }
    _kindsWrapped.add(kind);

    // 2. Already settled -- return the kept answer, touch nothing.
    if (_settled.containsKey(key)) {
      return HabotSendResult<R>(
        key: key,
        outcome: HabotSendOutcome.replayed,
        attempts: wireAttemptsFor(key),
        value: _settled[key] as R?,
        detail: 'this key already settled; the kept answer was returned and '
            'nothing was sent',
      );
    }

    // 1. In flight -- join it rather than starting a second.
    final Future<Object?>? existing = _inFlight[key];
    if (existing != null) {
      final Object? value = await existing;
      return HabotSendResult<R>(
        key: key,
        outcome: HabotSendOutcome.coalesced,
        attempts: wireAttemptsFor(key),
        value: value as R?,
        detail: 'joined an attempt already in flight for this key',
      );
    }

    final Completer<Object?> completer = Completer<Object?>();
    _inFlight[key] = completer.future;
    _wireAttempts[key] = wireAttemptsFor(key) + 1;

    try {
      final R value = await call();
      _remember(key, value);
      completer.complete(value);
      return HabotSendResult<R>(
        key: key,
        outcome: HabotSendOutcome.settled,
        attempts: wireAttemptsFor(key),
        value: value,
      );
    } on HabotUnknownOutcomeException catch (e) {
      // 3. The answer never came. Do NOT cache anything: the key must be
      //    retried, with this same key, so the server can recognise it.
      completer.complete(null);
      return HabotSendResult<R>(
        key: key,
        outcome: HabotSendOutcome.unknown,
        attempts: wireAttemptsFor(key),
        detail:
            'no answer came back (${e.detail}). The request may or may not '
            'have been applied. Retry with THIS key -- a new one would create '
            'the duplicate this middleware exists to prevent.',
      );
    } on Object catch (e) {
      completer.complete(null);
      return HabotSendResult<R>(
        key: key,
        outcome: HabotSendOutcome.rejected,
        attempts: wireAttemptsFor(key),
        detail: '$e',
      );
    } finally {
      _inFlight.remove(key);
    }
  }

  /// Forget a settled key. For a server that has told us it no longer holds
  /// the result -- not for making room, which [replayCacheLimit] handles.
  void forget(String key) {
    _settled.remove(key);
    _settledOrder.remove(key);
  }

  /// The metric, computed rather than asserted.
  ///
  /// Reusability is read as: the share of the declared payload kinds that
  /// actually go through this wrapper. A middleware that three of five call
  /// sites bypass is 0.6 reusable, and the two that bypass it are exactly
  /// where the duplicate will appear.
  double reusabilityOver(Set<String> declaredKinds) {
    if (declaredKinds.isEmpty) {
      return 1;
    }
    final int wrapped =
        declaredKinds.where(_kindsWrapped.contains).length;
    return wrapped / declaredKinds.length;
  }

  static const double floor = 0.9;
  static const double optimal = 1.0;

  /// Every mutation-carrying payload kind in this app. The denominator of the
  /// reusability score, declared so it cannot be quietly narrowed to whatever
  /// happens to be wrapped today.
  static const Set<String> mutationKinds = <String>{
    'task-submit',
    'task-accept',
    'batch-approve',
    'preference-write',
    'telemetry-batch',
  };

  static const String decoratorSubstitution =
      'The row names a Python decorator, @enforce_idempotency. Dart has no '
      'runtime-behaviour annotation and this project has no code generator, so '
      'the same guarantee is obtained with a wrapper: send() is the only path '
      'to the wire and it cannot be called without a key.';
}

/// Raised by a transport when a request went out and no answer came back.
///
/// Distinct from an ordinary failure ON PURPOSE. An ordinary failure means the
/// server said no; this means nobody knows. They need opposite handling, and
/// collapsing them is how a retry becomes a double submission.
class HabotUnknownOutcomeException implements Exception {
  const HabotUnknownOutcomeException(this.detail);

  final String detail;

  @override
  String toString() => 'HabotUnknownOutcomeException: $detail';
}
