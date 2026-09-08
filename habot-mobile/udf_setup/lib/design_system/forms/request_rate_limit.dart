/// AISS Step 131 -- GEN-00190
/// Atomic Step: "Debounce text field search inputs by 300ms on mobile
///               keyboards."
/// Metric: API Rate Limit Compliance -- Floor "<= 10 requests/second per
///         client (defined limit)", Optimal "sustained load at 70-80% of rate
///         limit capacity", Ceiling "10 requests/second (hard ceiling)".
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// **HALF OF THIS ROW IS ALREADY BUILT, AND IT IS NOT REBUILT HERE.** Step 33
/// (ANSA-006) implemented the 300ms search debounce in
/// `navigation/header_search.dart`, using `HabotMotion.searchDebounce`, and
/// gated it. Building a second debounce would give this project two of them,
/// which is exactly the drift these steps exist to prevent. The debounce half
/// of this step is therefore VERIFIED rather than implemented -- the gate
/// asserts the existing one is present and set to the 300ms the row names --
/// and the new work is the half that does not exist: the rate limit the METRIC
/// names.
///
/// WHY A DEBOUNCE IS NOT A RATE LIMIT, since the row treats them as one thing.
/// A debounce protects the server from one field being typed into. It does
/// nothing about six screens polling at once, a sync sweep draining a queue, or
/// a reconnect storm replaying an outbox -- all of which this app now does,
/// because Steps 117 to 128 built them. The debounce was sufficient when the
/// app only made requests when someone typed. It is not any more, and this
/// step is where that changes.
///
/// THE BUDGET IS SHARED, WHICH IS THE POINT. A per-caller limiter is not a
/// rate limit; it is several rate limits that add up to more than the ceiling.
/// [HabotRequestRateLimiter] is one bucket for the whole client, and every
/// outbound request passes through it.
///
/// PRIORITY EXISTS BECAUSE THE BUCKET IS SHARED. When the budget is nearly
/// spent, a background sweep must yield to the tap a person is waiting on --
/// the same distinction Step 124 makes, reused rather than redefined.
library;

import 'dart:collection';

import '../data/sync_governor.dart';
import '../tokens/motion_tokens.dart';

/// Why a request was not allowed through.
enum HabotRateDecision {
  /// Within budget.
  allowed,

  /// The budget is spent. Retry after the window.
  throttled,

  /// The budget is close to spent and this is background work, so it yields
  /// to whatever interactive request may still arrive in this window.
  yieldedToInteractive,
}

/// One decision.
class HabotRateVerdict {
  const HabotRateVerdict({
    required this.decision,
    required this.workClass,
    required this.usedInWindow,
    required this.retryAfter,
  });

  final HabotRateDecision decision;
  final HabotWorkClass workClass;

  /// Requests already spent in the current window.
  final int usedInWindow;

  /// How long to wait. Zero when allowed.
  final Duration retryAfter;

  bool get allowed => decision == HabotRateDecision.allowed;

  Map<String, Object?> toJson() => <String, Object?>{
    'decision': decision.name,
    'work_class': workClass.name,
    'used_in_window': usedInWindow,
    'retry_after_ms': retryAfter.inMilliseconds,
  };
}

/// One shared token bucket for the whole client.
class HabotRequestRateLimiter {
  HabotRequestRateLimiter({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  /// The row's hard ceiling, verbatim.
  static const int requestsPerSecond = 10;

  /// The row's optimal band: sustained load at 70-80% of capacity. The
  /// reserve above it is what interactive work spends.
  static const double sustainedTargetLow = 0.70;
  static const double sustainedTargetHigh = 0.80;

  /// Background work yields once this much of the window is spent, keeping the
  /// top of the budget free for a person who is waiting.
  static int get backgroundCeiling =>
      (requestsPerSecond * sustainedTargetHigh).floor();

  static Duration get window => HabotMotion.rateLimitWindow;

  final Queue<DateTime> _timestamps = Queue<DateTime>();
  final List<HabotRateVerdict> _verdicts = <HabotRateVerdict>[];

  List<HabotRateVerdict> get verdicts =>
      List<HabotRateVerdict>.unmodifiable(_verdicts);

  void _evict(DateTime now) {
    while (_timestamps.isNotEmpty &&
        now.difference(_timestamps.first) >= window) {
      _timestamps.removeFirst();
    }
  }

  int get usedInWindow {
    _evict(_clock());
    return _timestamps.length;
  }

  /// Ask for permission. A caller that does not like the answer waits
  /// [HabotRateVerdict.retryAfter]; it does not send anyway.
  HabotRateVerdict request(HabotWorkClass workClass) {
    final DateTime now = _clock();
    _evict(now);
    final int used = _timestamps.length;

    Duration retryAfter() => _timestamps.isEmpty
        ? Duration.zero
        : window - now.difference(_timestamps.first);

    late final HabotRateVerdict verdict;
    if (used >= requestsPerSecond) {
      verdict = HabotRateVerdict(
        decision: HabotRateDecision.throttled,
        workClass: workClass,
        usedInWindow: used,
        retryAfter: retryAfter(),
      );
    } else if (workClass != HabotWorkClass.interactive &&
        used >= backgroundCeiling) {
      verdict = HabotRateVerdict(
        decision: HabotRateDecision.yieldedToInteractive,
        workClass: workClass,
        usedInWindow: used,
        retryAfter: retryAfter(),
      );
    } else {
      _timestamps.addLast(now);
      verdict = HabotRateVerdict(
        decision: HabotRateDecision.allowed,
        workClass: workClass,
        usedInWindow: used + 1,
        retryAfter: Duration.zero,
      );
    }
    _verdicts.add(verdict);
    return verdict;
  }

  /// The row's metric: whether the client ever exceeded its ceiling.
  ///
  /// Computed over what actually went out, not over what was asked for -- a
  /// limiter judged on requests it refused would score perfectly while doing
  /// nothing.
  bool get compliedWithCeiling => _verdicts
      .where((HabotRateVerdict v) => v.allowed)
      .every((HabotRateVerdict v) => v.usedInWindow <= requestsPerSecond);

  /// Peak requests observed in any window.
  int get peakInWindow => _verdicts
      .where((HabotRateVerdict v) => v.allowed)
      .fold(0, (int a, HabotRateVerdict v) => v.usedInWindow > a ? v.usedInWindow : a);

  /// Interactive requests let through while the background was yielding. The
  /// reason the reserve exists, counted.
  int get interactivePreferred => _verdicts
      .where(
        (HabotRateVerdict v) =>
            v.allowed &&
            v.workClass == HabotWorkClass.interactive &&
            v.usedInWindow > backgroundCeiling,
      )
      .length;

  /// True when sustained load sits in the row's optimal band.
  bool inSustainedBand(int observedPerSecond) =>
      observedPerSecond >= requestsPerSecond * sustainedTargetLow &&
      observedPerSecond <= requestsPerSecond * sustainedTargetHigh;

  static const String debounceAlreadyBuilt =
      'The 300ms search debounce this row names was implemented and gated at '
      'Step 33 (ANSA-006) in navigation/header_search.dart, using '
      'HabotMotion.searchDebounce. It is verified here, not rebuilt: a second '
      'debounce would be two definitions of the same behaviour. The new work '
      'is the rate limit the metric names, which did not exist.';
}
