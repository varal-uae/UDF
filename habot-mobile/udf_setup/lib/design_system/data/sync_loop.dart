/// AISS Step 123 -- GEN-05276
/// Atomic Step: "Unit-test and validate the implementation of: implement a
///               background sync subroutine (serviceWorker.sync) to transmit
///               queued entries when online."
/// Metric: Validation Test Pass Rate (Offline Data Sync Success Rate) --
///         Floor ">= 95% test pass rate, >= 80% code coverage",
///         Optimal "100% test pass rate, >= 90% code coverage".
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// SUBSTITUTION RECORDED: `serviceWorker.sync` is a browser API. This is a
/// native Flutter client and has no service worker. The equivalent is a
/// scheduled sync worker driven by the Step 47 connectivity state machine,
/// which is what this is.
///
/// METRIC HALF PRODUCIBLE, RECORDED. The pass rate is produced here and is
/// real. The code-coverage half needs `flutter test --coverage` on a machine
/// with the toolchain; this container has neither, so it is reported as NOT
/// PRODUCED rather than estimated.
///
/// THE ASSEMBLY STEP. First point at which the batch does something end to
/// end. It consumes, and does not reimplement:
///
///   Step 112  `HabotRepository`      -- the contract everything speaks
///   Step 113  `HabotDao`             -- durable local writes
///   Step 116  `HabotUnitOfWork`      -- all-or-nothing commits
///   Step 117  `HabotOutbox`          -- the queue, in the order work was done
///   Step 118  `HabotDeltaApplier`    -- the read half of the same pipe
///   Step 121  `HabotReconnectPolicy` -- how hard to retry
///   Step 122  `HabotIdempotentDispatcher` -- never twice
///   Step 47   `HabotConnectivityMonitor`  -- whether to try at all
///
/// THE ORDER WITHIN A SWEEP, and why it is this way round:
///
///   1. DRAIN FIRST, then apply deltas. A delta applied before the local queue
///      empties hits the Step 118 conflict rule and gets deferred, so applying
///      first just does work twice. Draining first also means the server's
///      next delta already reflects what we sent.
///   2. STOP ON THE FIRST UNKNOWN OUTCOME. If an answer did not come back, the
///      link is unhealthy and the next send is likely to be unknown too --
///      and every unknown is a payload the server may have applied. Continuing
///      would pile up ambiguity. The sweep ends and the backoff takes over.
///   3. RETRY DEFERRED DELTAS LAST, because that is the moment the conflict
///      that caused the deferral has gone away.
library;

import 'dart:async';

import '../resilience/connectivity_state.dart';
import '../resilience/reconnect_policy.dart';
import 'delta.dart';
import 'idempotency.dart';
import 'outbox.dart';
import 'repository.dart';

/// Why a sweep ended.
enum HabotSyncStop {
  /// Everything queued was sent.
  drained,

  /// The device has no network.
  offline,

  /// An answer did not come back; see the header.
  unknownOutcome,

  /// The governor paused heavy work. See Step 124.
  pausedByGovernor,

  /// An entry ran out of attempts and was moved to dead letters.
  deadLettered,
}

/// What one sweep did.
class HabotSyncSweep {
  const HabotSyncSweep({
    required this.startedAt,
    required this.sent,
    required this.failed,
    required this.deltasApplied,
    required this.stop,
    required this.detail,
  });

  final DateTime startedAt;
  final int sent;
  final int failed;
  final int deltasApplied;
  final HabotSyncStop stop;
  final String detail;

  bool get isClean => stop == HabotSyncStop.drained && failed == 0;

  Map<String, Object?> toJson() => <String, Object?>{
    'started_at': startedAt.toIso8601String(),
    'sent': sent,
    'failed': failed,
    'deltas_applied': deltasApplied,
    'stop': stop.name,
    'detail': detail,
  };
}

/// Decides whether heavy work may proceed. Step 124 implements it; the loop
/// depends on the question, not on the answer.
abstract interface class HabotSyncGovernor {
  /// False when heavy background synchronisation must pause.
  bool get allowsHeavyWork;

  /// Why, for the evidence record.
  String get reason;
}

/// A governor that never pauses. The default, so the loop is usable before
/// Step 124 exists and so a test can isolate the loop from the governor.
class HabotAlwaysAllow implements HabotSyncGovernor {
  const HabotAlwaysAllow();

  @override
  bool get allowsHeavyWork => true;

  @override
  String get reason => 'no governor configured';
}

/// The sync loop.
class HabotSyncLoop {
  HabotSyncLoop({
    required this.outbox,
    required this.dispatcher,
    required this.monitor,
    required this.policy,
    required this.transmit,
    this.applier,
    this.governor = const HabotAlwaysAllow(),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final HabotOutbox outbox;
  final HabotIdempotentDispatcher dispatcher;
  final HabotConnectivityMonitor monitor;
  final HabotReconnectPolicy policy;

  /// What actually reaches the server. Injected, so the loop is testable
  /// without a network and so the transport can be replaced (Step 126) without
  /// touching the loop.
  final Future<void> Function(HabotOutboxEntry entry) transmit;

  /// Optional: the read half. Absent in a telemetry-only configuration.
  final HabotDeltaApplier<HabotEntity>? applier;

  final HabotSyncGovernor governor;
  final DateTime Function() _clock;

  final List<HabotSyncSweep> _sweeps = <HabotSyncSweep>[];
  Timer? _timer;
  bool _running = false;

  List<HabotSyncSweep> get sweeps => List<HabotSyncSweep>.unmodifiable(_sweeps);
  bool get isRunning => _running;

  int get totalSent =>
      _sweeps.fold(0, (int a, HabotSyncSweep s) => a + s.sent);
  int get totalFailed =>
      _sweeps.fold(0, (int a, HabotSyncSweep s) => a + s.failed);

  /// One sweep. This is the whole subroutine; [start] only calls it on a
  /// schedule, which is why every gate can drive it directly.
  Future<HabotSyncSweep> sweep({List<HabotDelta> incoming = const <HabotDelta>[]}) async {
    final DateTime began = _clock();
    int sent = 0;
    int failed = 0;
    int applied = 0;

    if (monitor.isOffline) {
      return _record(
        HabotSyncSweep(
          startedAt: began,
          sent: 0,
          failed: 0,
          deltasApplied: 0,
          stop: HabotSyncStop.offline,
          detail: 'the device reports no network; nothing was attempted',
        ),
      );
    }
    if (!governor.allowsHeavyWork) {
      return _record(
        HabotSyncSweep(
          startedAt: began,
          sent: 0,
          failed: 0,
          deltasApplied: 0,
          stop: HabotSyncStop.pausedByGovernor,
          detail: governor.reason,
        ),
      );
    }

    // 1. Drain, oldest first.
    //
    // A SNAPSHOT, not a repeated `next()`. An entry that fails without
    // exhausting its attempts goes back to pending, so re-asking the queue for
    // "the next one" would hand back the same entry forever and the sweep
    // would never end. One pass per sweep; anything enqueued while this runs
    // is picked up by the next one, which is also the right backpressure.
    HabotSyncStop stop = HabotSyncStop.drained;
    String detail = 'the queue emptied';
    final List<HabotOutboxEntry> batch = await outbox.pending();
    for (final HabotOutboxEntry entry in batch) {
      if (entry.state == HabotOutboxState.dead) {
        continue;
      }
      if (!governor.allowsHeavyWork) {
        stop = HabotSyncStop.pausedByGovernor;
        detail = governor.reason;
        break;
      }
      final HabotOutboxEntry inFlight = await outbox.markInFlight(entry);
      final HabotSendResult<bool> result = await dispatcher.send<bool>(
        key: inFlight.id,
        kind: inFlight.kind,
        call: () async {
          await transmit(inFlight);
          return true;
        },
      );

      if (result.outcome == HabotSendOutcome.settled ||
          result.isDuplicateSuppressed) {
        await outbox.markSent(inFlight);
        sent++;
        policy.onConnected();
      } else if (result.outcome == HabotSendOutcome.unknown) {
        // 2. Stop here. Every further send would be equally ambiguous, and
        //    every ambiguous send is a payload the server may have applied.
        failed++;
        policy.onDropped();
        await outbox.markFailed(
          inFlight,
          result.detail ?? 'no answer came back',
        );
        stop = HabotSyncStop.unknownOutcome;
        detail =
            'an answer did not come back for "${inFlight.id}". The link is '
            'unhealthy, so the sweep stopped rather than piling up sends '
            'whose outcome nobody knows. The entry keeps its key and will be '
            'retried with it.';
      } else {
        failed++;
        final HabotOutboxEntry after = await outbox.markFailed(
          inFlight,
          result.detail ?? 'rejected',
        );
        if (after.state == HabotOutboxState.dead) {
          stop = HabotSyncStop.deadLettered;
          detail =
              '"${after.id}" ran out of attempts and was moved to dead '
              'letters after ${after.attempts} tries. It is kept, not '
              'dropped.';
        }
      }
      if (stop == HabotSyncStop.unknownOutcome) {
        break;
      }
    }

    // 3. Apply what came in, then re-offer anything held.
    if (applier != null && stop != HabotSyncStop.unknownOutcome) {
      if (incoming.isNotEmpty) {
        applied += (await applier!.apply(incoming)).applied;
      }
      if (applier!.deferred.isNotEmpty) {
        applied += (await applier!.retryDeferred()).applied;
      }
    }

    return _record(
      HabotSyncSweep(
        startedAt: began,
        sent: sent,
        failed: failed,
        deltasApplied: applied,
        stop: stop,
        detail: detail,
      ),
    );
  }

  HabotSyncSweep _record(HabotSyncSweep s) {
    _sweeps.add(s);
    return s;
  }

  /// Run on a schedule. The Step 47 monitor is the trigger this replaces
  /// `serviceWorker.sync` with.
  void start({Duration? every}) {
    _timer?.cancel();
    _running = true;
    _timer = Timer.periodic(
      every ?? HabotConnectivityPolicy.pollInterval,
      (_) => unawaited(sweep()),
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _running = false;
  }

  /// The producible half of the row's metric: of everything the loop attempted
  /// to send, the share that reached the server.
  double get sendSuccessRate {
    final int attempted = totalSent + totalFailed;
    return attempted == 0 ? 1 : totalSent / attempted;
  }

  static const String serviceWorkerSubstitution =
      'serviceWorker.sync is a browser API; this is a native Flutter client '
      'with no service worker. The equivalent is a scheduled sweep driven by '
      'the Step 47 connectivity state machine.';

  static const String coverageNote =
      'The code-coverage half of this row metric (>= 80% floor, >= 90% '
      'optimal) is NOT PRODUCED. It needs flutter test --coverage on a machine '
      'with the Dart toolchain; this environment has neither the toolchain nor '
      'the network to install it. No figure is estimated in its place.';
}
