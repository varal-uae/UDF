/// AISS Step 121 -- GEN-02731
/// Atomic Step: "Write the reconnection logic with exponential backoff that
///               activates when the WebSocket connection is dropped."
/// Metric: Real-Time Event Delivery Latency -- Floor sub-500ms, Optimal
///         sub-200ms, Ceiling "latency exceeding 1 second degrades real-time
///         UX significantly".
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// METRIC NOT PRODUCIBLE, RECORDED. An event delivery latency needs a live
/// socket and a server on the other end of it. Neither exists in this suite,
/// and no number is invented. What a backoff policy owns is the SHAPE of its
/// own retry schedule, which is fully determined and fully testable: the
/// delays it produces, the cap it respects, the jitter it applies and the
/// point at which it gives up. That is what is gated.
///
/// WHAT THIS IS FOR, from the build order: "119 notices the app left, 120
/// stops the clocks, and this decides how hard to retry without draining a
/// battery in a dead-signal area."
///
/// THE THREE DECISIONS A BACKOFF MAKES, and why each is the way it is:
///
///   1. GROWTH. Doubling. Slower growth spends battery; faster growth leaves a
///      user offline long after the signal came back.
///   2. JITTER, and this is the one people leave out. Without it every device
///      that lost the same tower reconnects at the same instant, and the
///      server that just came back falls over again. Full jitter -- a uniform
///      draw over the whole window rather than a small wobble around it -- is
///      what actually spreads the load.
///   3. WHEN TO STOP. Never, while the device believes it has a network. A
///      field worker on rural connectivity is offline for hours, not seconds,
///      and a client that gives up permanently is a client that needs
///      restarting to work again. The cap on the DELAY is what protects the
///      battery; there is no cap on attempts.
///
/// IT LISTENS TO STEP 47. When the connectivity monitor says the device has no
/// network at all, retrying is pointless: [nextDelay] returns the idle
/// interval instead of climbing. Backoff is for a server that will not answer,
/// not for a radio that is switched off.
library;

import 'dart:math' as math;

import '../tokens/motion_tokens.dart';
import 'connectivity_state.dart';

/// Why the policy chose the delay it chose. Recorded so a log says which of
/// the three regimes produced a wait rather than only how long it was.
enum HabotBackoffRegime {
  /// First retry after a drop.
  initial,

  /// Doubling.
  climbing,

  /// At the ceiling.
  capped,

  /// The device has no network; not a server problem.
  offlineIdle,
}

/// One scheduled retry.
class HabotBackoffStep {
  const HabotBackoffStep({
    required this.attempt,
    required this.delay,
    required this.regime,
    required this.ceiling,
  });

  final int attempt;
  final Duration delay;
  final HabotBackoffRegime regime;

  /// The un-jittered window this delay was drawn from. Kept so a gate can
  /// check the jitter without knowing the random seed.
  final Duration ceiling;

  Map<String, Object?> toJson() => <String, Object?>{
    'attempt': attempt,
    'delay_ms': delay.inMilliseconds,
    'window_ms': ceiling.inMilliseconds,
    'regime': regime.name,
  };

  @override
  String toString() =>
      'attempt $attempt: ${delay.inMilliseconds}ms (${regime.name}, window '
      '${ceiling.inMilliseconds}ms)';
}

/// Exponential backoff with full jitter.
class HabotReconnectPolicy {
  HabotReconnectPolicy({
    this.monitor,
    math.Random? random,
    DateTime Function()? clock,
  }) : _random = random ?? math.Random(),
       _clock = clock ?? DateTime.now;

  /// Optional. When present, a device with no network idles rather than
  /// climbing -- see the header.
  final HabotConnectivityMonitor? monitor;

  final math.Random _random;
  final DateTime Function() _clock;

  /// The first retry window. Declared in the motion tokens, which is this
  /// project's single declaration site for every Duration -- the poka-yoke
  /// guard fails the build on a raw one written anywhere else.
  static Duration get base => HabotMotion.reconnectBase;

  /// The longest a client will ever wait between attempts. Thirty seconds is
  /// the Step 47 poll interval: past this, the connectivity monitor is already
  /// checking at least as often, so waiting longer buys nothing.
  static Duration get ceiling => HabotMotion.pollInterval;

  /// What to wait while the device reports no network at all.
  static Duration get offlineIdle => HabotMotion.pollInterval;

  int _attempt = 0;
  final List<HabotBackoffStep> _history = <HabotBackoffStep>[];
  DateTime? _droppedAt;

  int get attempt => _attempt;
  List<HabotBackoffStep> get history =>
      List<HabotBackoffStep>.unmodifiable(_history);

  /// How long the connection has been down. Reported rather than capped: the
  /// user is entitled to know it has been twenty minutes.
  Duration? get downFor =>
      _droppedAt == null ? null : _clock().difference(_droppedAt!);

  /// The un-jittered window for [attempt]: base * 2^(attempt-1), capped.
  static Duration windowFor(int attempt) {
    if (attempt <= 0) {
      return Duration.zero;
    }
    final int ms = base.inMilliseconds * (1 << math.min(attempt - 1, 20));
    return ms >= ceiling.inMilliseconds
        ? ceiling
        : Duration(milliseconds: ms);
  }

  /// The connection dropped. Resets nothing except the drop timestamp -- the
  /// attempt counter is reset by success, not by another failure.
  void onDropped() {
    _droppedAt ??= _clock();
  }

  /// The connection came back. Everything resets, so the next drop starts from
  /// the bottom rather than from wherever the last outage ended.
  void onConnected() {
    _attempt = 0;
    _droppedAt = null;
  }

  /// The next wait.
  HabotBackoffStep nextDelay() {
    if (monitor != null && monitor!.isOffline) {
      final HabotBackoffStep step = HabotBackoffStep(
        attempt: _attempt,
        delay: offlineIdle,
        regime: HabotBackoffRegime.offlineIdle,
        ceiling: offlineIdle,
      );
      _history.add(step);
      return step;
    }
    _attempt++;
    final Duration window = windowFor(_attempt);
    // Full jitter: uniform over [0, window]. A small wobble around the window
    // does not spread a thundering herd; drawing across the whole window does.
    final int ms = window.inMilliseconds == 0
        ? 0
        : _random.nextInt(window.inMilliseconds + 1);
    final HabotBackoffStep step = HabotBackoffStep(
      attempt: _attempt,
      delay: Duration(milliseconds: ms),
      regime: _attempt == 1
          ? HabotBackoffRegime.initial
          : (window == ceiling
                ? HabotBackoffRegime.capped
                : HabotBackoffRegime.climbing),
      ceiling: window,
    );
    _history.add(step);
    return step;
  }

  /// The attempt at which the window first reaches the cap. Derived, so
  /// changing [base] or [ceiling] cannot leave a stale number in a comment.
  static int get attemptsToCeiling {
    int n = 1;
    while (windowFor(n) < ceiling && n < 64) {
      n++;
    }
    return n;
  }

  /// There is deliberately no attempt limit -- see the header. Stated as a
  /// property so a gate can assert the absence rather than a reader having to
  /// notice it.
  static const bool givesUpEventually = false;

  static const String metricNote =
      'Real-Time Event Delivery Latency is NOT PRODUCED. It needs a live '
      'socket and a server; this suite has neither. What is gated is the shape '
      'of the retry schedule -- growth, jitter, cap, and the absence of an '
      'attempt limit -- which is fully determined and fully observable.';
}
