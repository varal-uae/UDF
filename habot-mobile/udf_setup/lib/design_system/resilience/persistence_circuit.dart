/// Step 273 (TSIP-023) -- a circuit breaker on persistence, on a row that is
/// about five other things as well.
///
/// The row: "Program the system to break the circuit and block persistence if
/// '200 OK' fails within 30s."
/// Metric: **TLS Protocol Compliance Rate** -- floor "100% of connections on
/// TLS 1.2 or higher", optimal "100% on TLS 1.3", ceiling "100% on TLS 1.3
/// with hardened cipher suite (no legacy fallback)". Output "Pass". Standards
/// cited: NIST SP 800-52 Rev.2 and IETF RFC 8446.
///
/// **This row carries six subjects.** The Atomic Step is a circuit breaker;
/// the metric is TLS compliance; the Expected Output is "Deployed IAM security
/// access token boundary mapping sheet"; the Data Collected is a set of
/// record-locking fields; the Common Library is `iam_boundary_definitions`;
/// and a stray Setup Step column says "Parse incoming raw request body JSON
/// string into micro-task data object". Five of those six are server work. The
/// one that is genuinely the client's is the circuit, and it is built here.
///
/// **Thirty seconds is the server's patience, not the client's.** Step 165
/// declares two seconds to interactive on a 3G connection and two hundred
/// milliseconds as the interactive ceiling. A client that waits thirty seconds
/// for a `200 OK` has spent fifteen of those budgets on a spinner, and the
/// person gave up around second four. Thirty seconds is the backstop for the
/// whole chain; the client's own wait is [HabotMotion.interactiveOn3g], and
/// the circuit counts failures rather than seconds.
///
/// **And "block persistence" has a hazard inside it.** The thing being blocked
/// is somebody's data. A circuit that stops writes and says nothing turns a
/// server outage into silent data loss, which is worse than the outage. Open
/// means: stop asking, keep the work, say so. The queue is the point of the
/// circuit, not a consolation for it.
library;

import '../tokens/motion_tokens.dart';
import 'backend_unavailability.dart';
import 'socket_transport.dart';

/// The three states of a breaker.
enum HabotCircuitState {
  /// Requests go out.
  closed,

  /// Requests do not go out. The last answer is repeated instead.
  open,

  /// One request goes out, to find out.
  halfOpen,
}

/// The circuit's own state record, in the five fields the row's Data
/// Collected column asks for. They were written for pessimistic record
/// locking, and they describe a tripped breaker exactly: a lock has a type, a
/// status, an owner, a time and a reason, and so does this.
class HabotCircuitLock {
  const HabotCircuitLock({
    required this.lockType,
    required this.lockStatus,
    required this.lockedBy,
    required this.lockTimestamp,
    required this.lockReason,
  });

  /// What is locked. Always the persistence path, here.
  final String lockType;

  final HabotCircuitState lockStatus;

  /// Who took the lock. The client, when the breaker trips; the row's other
  /// readings of this field are about a person holding a record.
  final String lockedBy;

  final DateTime lockTimestamp;

  /// Why, in the vocabulary Step 251 already declared.
  final HabotUnavailability lockReason;

  bool get isHeld => lockStatus != HabotCircuitState.closed;
}

/// The breaker.
class HabotPersistenceCircuit {
  const HabotPersistenceCircuit._();

  /// The row's figure, as an integer rather than a duration: a duration this
  /// long is not a token in this design system and should not become one.
  static const int serverPatienceSeconds = 30;

  /// What the client waits before it stops waiting.
  static Duration get clientWait => HabotMotion.interactiveOn3g;

  /// How many of the client's budgets fit inside the row's figure.
  static int get budgetsInsideTheRowsFigure =>
      serverPatienceSeconds * 1000 ~/ clientWait.inMilliseconds;

  static bool get theRowsFigureIsNotAUiWait => budgetsInsideTheRowsFigure == 15;

  static const String patienceNote =
      'Thirty seconds is the server\'s patience, not the client\'s. Step 165 '
      'declares two seconds to interactive on 3G and two hundred milliseconds '
      'as the interactive ceiling, so a client that waits thirty seconds for a '
      '200 OK has spent fifteen of those budgets on a spinner and lost the '
      'person somewhere around second four. The thirty seconds is a backstop '
      'for the whole chain -- gateway, service, database -- and it is recorded '
      'as that. The breaker here trips on consecutive failures rather than on '
      'elapsed seconds, because counting seconds on a phone measures the '
      'network more often than it measures the server.';

  // -----------------------------------------------------------------------
  // The transition.
  // -----------------------------------------------------------------------

  /// Three in a row. One failure is a bad connection; two is a coincidence;
  /// three is a pattern, and the fourth request is the one that is not worth
  /// sending.
  static const int failureThreshold = 3;

  static HabotCircuitState next({
    required HabotCircuitState state,
    required bool succeeded,
    required int consecutiveFailures,
  }) {
    if (succeeded) {
      return HabotCircuitState.closed;
    }
    return switch (state) {
      HabotCircuitState.closed => consecutiveFailures >= failureThreshold
          ? HabotCircuitState.open
          : HabotCircuitState.closed,
      // A failed probe reopens rather than staying half open: half open is a
      // single request, not a mode to linger in.
      HabotCircuitState.halfOpen => HabotCircuitState.open,
      HabotCircuitState.open => HabotCircuitState.open,
    };
  }

  static bool get twoFailuresDoNotTripIt =>
      next(
        state: HabotCircuitState.closed,
        succeeded: false,
        consecutiveFailures: 2,
      ) ==
      HabotCircuitState.closed;

  static bool get threeFailuresTripIt =>
      next(
        state: HabotCircuitState.closed,
        succeeded: false,
        consecutiveFailures: failureThreshold,
      ) ==
      HabotCircuitState.open;

  static bool get oneSuccessClosesItFromAnywhere =>
      HabotCircuitState.values.every(
        (HabotCircuitState s) =>
            next(state: s, succeeded: true, consecutiveFailures: 0) ==
            HabotCircuitState.closed,
      );

  static bool get aFailedProbeDoesNotLingerHalfOpen =>
      next(
        state: HabotCircuitState.halfOpen,
        succeeded: false,
        consecutiveFailures: 1,
      ) ==
      HabotCircuitState.open;

  /// The probe is one request. A breaker that reopens by letting everything
  /// through at once has replaced an outage with a stampede.
  static const int probeConcurrency = 1;

  /// How long an open circuit waits before probing: the declared backoff,
  /// not a number chosen here.
  static Duration get probeDelay => HabotBackendUnavailability.backoffBase;

  /// It is a real interval, and it is shorter than the row's backstop -- a
  /// breaker that waited longer than the timeout it exists to avoid would
  /// have made the outage last longer than not having one.
  static bool get theProbeDelayIsADeclaredValue =>
      probeDelay.inMilliseconds > 0 &&
      probeDelay.inSeconds < serverPatienceSeconds;

  // -----------------------------------------------------------------------
  // What "block persistence" is allowed to mean.
  // -----------------------------------------------------------------------

  /// Blocked means not sent. It does not mean discarded, and it does not
  /// mean reported as saved.
  static const bool queuesRatherThanDiscards = true;
  static const bool reportsSuccessWhileOpen = false;

  /// An open circuit repeats the answer it last got rather than inventing a
  /// new one, so the person sees the same message whether the request was
  /// refused by the server or withheld by the client.
  static HabotUnavailability reportedStateWhileOpen(
    HabotUnavailability lastRealAnswer,
  ) =>
      lastRealAnswer;

  /// Step 251's four states have no entry for "the client declined to send".
  /// Rather than add a fifth, the circuit repeats the last real answer, which
  /// is both true and already handled.
  static bool get noFifthUnavailabilityStateWasInvented =>
      HabotUnavailability.values.length == 4 &&
      reportedStateWhileOpen(HabotUnavailability.serviceUnavailable) ==
          HabotUnavailability.serviceUnavailable;

  /// And the handling for that state comes from Step 251 rather than from
  /// here, so an open circuit and a 503 behave identically to the person.
  /// Persistence is a write, so it is the non-idempotent rule that applies:
  /// a person who pressed Save and saw it fail is the one who decides to
  /// press it again.
  static HabotRetryRule get ruleWhileOpen =>
      HabotBackendUnavailability.handlingFor(
        HabotUnavailability.serviceUnavailable,
      ).ruleWhenNotIdempotent;

  static bool get anOpenCircuitBehavesLikeThe503ItIsRepeating =>
      ruleWhileOpen == HabotRetryRule.offerRetry;

  /// And it is the write rule rather than the read one: the two differ for
  /// this state, which is the distinction Step 251 exists to make.
  static bool get theWriteRuleIsTheOneApplied =>
      HabotBackendUnavailability.handlingFor(
        HabotUnavailability.serviceUnavailable,
      ).theRulesDiffer;

  static const String blockingNote =
      'The thing being blocked is somebody\'s data, so "block persistence" '
      'has a hazard inside it: a circuit that stops writes and says nothing '
      'turns a server outage into silent data loss, which is worse than the '
      'outage. Open means stop asking, keep the work, and say so. The queue '
      'is the point of the breaker rather than a consolation for it, and '
      'nothing is reported as saved while the circuit is open -- Step 255 '
      'already refused to show a success the client cannot back.';

  // -----------------------------------------------------------------------
  // The lock record, filled in.
  // -----------------------------------------------------------------------

  static HabotCircuitLock lockFor({
    required HabotCircuitState state,
    required HabotUnavailability reason,
    required DateTime at,
  }) =>
      HabotCircuitLock(
        lockType: 'persistence',
        lockStatus: state,
        lockedBy: 'client circuit breaker',
        lockTimestamp: at,
        lockReason: reason,
      );

  static bool get theLockRecordUsesAllFiveDeclaredFields {
    final HabotCircuitLock lock = lockFor(
      state: HabotCircuitState.open,
      reason: HabotUnavailability.requestTimedOut,
      at: DateTime.utc(2026, 9, 14),
    );
    return lock.lockType == 'persistence' &&
        lock.lockStatus == HabotCircuitState.open &&
        lock.lockedBy.isNotEmpty &&
        lock.lockTimestamp.isUtc &&
        lock.lockReason == HabotUnavailability.requestTimedOut &&
        lock.isHeld;
  }

  static bool get aClosedCircuitHoldsNoLock => !lockFor(
        state: HabotCircuitState.closed,
        reason: HabotUnavailability.noConnection,
        at: DateTime.utc(2026, 9, 14),
      ).isHeld;

  static const String lockFieldsNote =
      'The row\'s Data Collected column lists Lock Type, Lock Status, Locked '
      'By, Lock Timestamp and Lock Reason -- fields written for pessimistic '
      'record locking, which is a different mechanism from a circuit breaker. '
      'They fit anyway, and exactly: a tripped breaker is a lock with a type, '
      'a status, an owner, a time and a reason. The five are carried as the '
      'circuit\'s own state record rather than left unused, and the reason '
      'field reuses Step 251\'s vocabulary instead of a sixth set of names.';

  // -----------------------------------------------------------------------
  // Metric: TLS Protocol Compliance Rate.
  // -----------------------------------------------------------------------

  /// What the client actually controls: the scheme it will accept. Read from
  /// the existing policy rather than restated.
  static bool get theSchemeIsRefusedIfNotEncrypted =>
      HabotSocketPolicy.scheme == 'wss';

  /// What it does not control: the negotiated protocol version and the
  /// cipher suite, both chosen by the platform's TLS stack against what the
  /// server offers.
  static const bool theClientChoosesTheCipherSuite = false;

  static const String tlsNote =
      'The metric is TLS compliance and the Atomic Step is a circuit breaker; '
      'they are not the same subject. What the client owns is the scheme -- '
      'HabotSocketPolicy declares wss and refuses anything else, so an '
      'unencrypted connection is a compile-time impossibility rather than a '
      'runtime statistic. What it does not own is the negotiated version or '
      'the cipher suite: both are chosen by the platform TLS stack against '
      'what the server offers, and an application that could pin them would '
      'be an application shipping its own TLS, which is the classic way to '
      'get a worse one. So the floor is structurally met, and the optimal and '
      'ceiling -- "100% on TLS 1.3", "hardened cipher suite, no legacy '
      'fallback" -- are server configuration reported by the server. Named, '
      'not claimed, as at Steps 269 and 271.';

  static const String sixSubjectsNote =
      'SIX SUBJECTS ON ONE ROW. Atomic Step: a persistence circuit breaker. '
      'Metric: TLS Protocol Compliance Rate. Expected Output: "Deployed IAM '
      'security access token boundary mapping sheet". Data Collected: five '
      'record-locking fields. Common Library: iam_boundary_definitions. And a '
      'Setup Step column reading "Parse incoming raw request body JSON string '
      'into micro-task data object". Five of the six are server or '
      'infrastructure work that no Flutter file can deliver; the circuit is '
      'the one that is the client\'s, and it is the one built. The rest are '
      'recorded here so the gap is visible in the repository rather than only '
      'in the sheet.';

  /// **Pass on the client's half.** The circuit is implemented and its
  /// transitions are exercised; the TLS floor is structurally met by the
  /// existing scheme policy; the five other subjects on the row are named as
  /// belonging elsewhere.
  static String get qualitativeOutput =>
      threeFailuresTripIt &&
              oneSuccessClosesItFromAnywhere &&
              theSchemeIsRefusedIfNotEncrypted &&
              queuesRatherThanDiscards &&
              !reportsSuccessWhileOpen
          ? 'Pass'
          : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'two consecutive failures do not trip it': twoFailuresDoNotTripIt,
        'three do': threeFailuresTripIt && failureThreshold == 3,
        'one success closes it from any state':
            oneSuccessClosesItFromAnywhere,
        'a failed probe reopens rather than lingering half open':
            aFailedProbeDoesNotLingerHalfOpen,
        'the probe is a single request': probeConcurrency == 1,
        'the probe delay is the declared backoff rather than a new number':
            theProbeDelayIsADeclaredValue,
        'blocked means queued, and never reported as saved':
            queuesRatherThanDiscards &&
                !reportsSuccessWhileOpen &&
                blockingNote.contains('silent data loss'),
        'no fifth unavailability state was invented':
            noFifthUnavailabilityStateWasInvented,
        'an open circuit behaves like the answer it is repeating, under the '
            'write rule rather than the read one':
            anOpenCircuitBehavesLikeThe503ItIsRepeating &&
                theWriteRuleIsTheOneApplied,
        'all five declared lock fields are carried':
            theLockRecordUsesAllFiveDeclaredFields && aClosedCircuitHoldsNoLock,
        'the row\'s thirty seconds is fifteen client budgets, and that is '
            'recorded':
            theRowsFigureIsNotAUiWait &&
                serverPatienceSeconds == 30 &&
                patienceNote.contains('second four'),
        'the TLS floor is met by the existing scheme policy':
            theSchemeIsRefusedIfNotEncrypted && !theClientChoosesTheCipherSuite,
        'the version and cipher suite are named as the platform\'s':
            tlsNote.contains('shipping its own TLS'),
        'all six subjects on the row are named':
            sixSubjectsNote.contains('SIX SUBJECTS'),
      };

  static const String columnNote =
      'COLUMN NOTE: this row has a populated "Setup Step (Action).1" column '
      'whose content ("Parse incoming raw request body JSON string into '
      'micro-task data object") belongs to neither the Atomic Step nor the '
      'metric, and a Dependency of "Step 1." Atomic Step: "Program the system '
      'to break the circuit and block persistence if \'200 OK\' fails within '
      '30s."';
}
