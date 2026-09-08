/// AISS Step 130 -- GEN-04737
/// Atomic Step: "Test the implementation against the completion measures: Zero
///               duplicate API calls generated under simulated multi-tap
///               stress tests; 100% DOM unlock upon response or timeout."
/// Metric: Acceptance / Completion-Measure Test Pass Rate -- Floor ">= 95% of
///         stated completion measures met", Optimal "100%".
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// A ROW THAT NAMES ITS OWN ACCEPTANCE TEST, which is rare enough to use
/// literally. Two measures, both binary, both directly checkable:
///
///   1. Zero duplicate API calls under multi-tap stress.
///   2. 100% unlock on response OR timeout.
///
/// The gate runs both and reports the share met. Nothing is interpreted.
///
/// "DOM UNLOCK" IS A WEB TERM, RECORDED. There is no DOM here. The equivalent
/// is the disabled state of the control: a button locked while a submit is in
/// flight, and unlocked when the answer arrives. The substitution is exact --
/// the failure it names is the same one, a control that stays disabled forever
/// because the response never came and nobody wrote the timeout.
///
/// **THE SECOND MEASURE IS THE ONE THAT BITES.** Locking on tap is easy and
/// everyone does it. Unlocking on TIMEOUT is what people forget, and the
/// result is a worker staring at a dead button with no way forward but to
/// force-quit the app -- losing, before this batch, everything they had typed.
/// [HabotSubmitGuard] has no code path that locks without arming a timeout.
///
/// RELATION TO STEP 122, because they look similar and are not. Step 122 stops
/// a duplicate reaching the SERVER, by key. This stops a duplicate being
/// STARTED, at the widget. Both are needed: without 122 a retry after a
/// reconnect duplicates; without this, a double tap spends two round trips and
/// leaves the second one racing the first. They are the same defect caught at
/// two different distances.
library;

import 'dart:async';

import '../tokens/motion_tokens.dart';

/// Why a tap did not start a call.
enum HabotSubmitRejection {
  /// A submit for this action is already in flight.
  alreadyInFlight,

  /// Inside the multi-tap window after the last accepted tap.
  withinTapWindow,
}

/// The state of one guarded control.
enum HabotSubmitState { idle, locked }

/// What happened to one tap.
class HabotTapOutcome {
  const HabotTapOutcome({
    required this.accepted,
    required this.callsStarted,
    this.rejection,
  });

  final bool accepted;

  /// Running total of calls this guard has actually started. The number the
  /// first completion measure is about.
  final int callsStarted;

  final HabotSubmitRejection? rejection;
}

/// Locks a control for the duration of a submit, and always unlocks it.
class HabotSubmitGuard {
  HabotSubmitGuard({
    this.timeout,
    void Function(HabotSubmitState state)? onStateChanged,
    DateTime Function()? clock,
  }) : _onStateChanged = onStateChanged,
       _clock = clock ?? DateTime.now;

  /// How long a submit may stay locked before the control is released
  /// regardless. Never null in practice -- see the header.
  final Duration? timeout;

  final void Function(HabotSubmitState state)? _onStateChanged;
  final DateTime Function() _clock;

  static Duration get defaultTimeout => HabotMotion.submitLockTimeout;

  /// Taps closer together than this are the same intent. Reuses the existing
  /// double-tap window rather than declaring a second one.
  static Duration get tapWindow => HabotMotion.doubleTapWindow;

  Duration get effectiveTimeout => timeout ?? defaultTimeout;

  HabotSubmitState _state = HabotSubmitState.idle;
  DateTime? _lastAcceptedAt;
  int _callsStarted = 0;
  int _tapsReceived = 0;
  int _unlockedOnResponse = 0;
  int _unlockedOnTimeout = 0;
  Timer? _timeoutTimer;

  HabotSubmitState get state => _state;
  bool get isLocked => _state == HabotSubmitState.locked;

  int get tapsReceived => _tapsReceived;
  int get callsStarted => _callsStarted;
  int get unlockedOnResponse => _unlockedOnResponse;
  int get unlockedOnTimeout => _unlockedOnTimeout;

  void _setState(HabotSubmitState s) {
    if (_state == s) {
      return;
    }
    _state = s;
    _onStateChanged?.call(s);
  }

  /// A tap arrived. Returns whether it should start a call.
  HabotTapOutcome tap() {
    _tapsReceived++;
    if (isLocked) {
      return HabotTapOutcome(
        accepted: false,
        callsStarted: _callsStarted,
        rejection: HabotSubmitRejection.alreadyInFlight,
      );
    }
    final DateTime now = _clock();
    if (_lastAcceptedAt != null &&
        now.difference(_lastAcceptedAt!) < tapWindow) {
      return HabotTapOutcome(
        accepted: false,
        callsStarted: _callsStarted,
        rejection: HabotSubmitRejection.withinTapWindow,
      );
    }
    _lastAcceptedAt = now;
    _callsStarted++;
    _setState(HabotSubmitState.locked);
    // There is no branch here that locks without arming this. That is the
    // whole of the second completion measure.
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(effectiveTimeout, _releaseOnTimeout);
    return HabotTapOutcome(accepted: true, callsStarted: _callsStarted);
  }

  /// The answer came back.
  void complete() {
    if (!isLocked) {
      return;
    }
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _unlockedOnResponse++;
    _setState(HabotSubmitState.idle);
  }

  void _releaseOnTimeout() {
    if (!isLocked) {
      return;
    }
    // Cancelled as well as cleared: expireNow() drives this path directly, and
    // leaving the real timer armed would fire a second release later.
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _unlockedOnTimeout++;
    _setState(HabotSubmitState.idle);
  }

  /// Drive the timeout without waiting for it. For a gate, and for a caller
  /// that has independently learned the request is gone.
  void expireNow() => _releaseOnTimeout();

  void dispose() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  // ---- the row's two completion measures, evaluated ----------------------

  /// Measure 1: zero duplicate calls under multi-tap stress. True when the
  /// guard started fewer calls than it received taps, and started exactly the
  /// number of distinct intents.
  bool zeroDuplicateCalls({required int distinctIntents}) =>
      _callsStarted == distinctIntents && _tapsReceived >= _callsStarted;

  /// Measure 2: every lock ended in an unlock, by response or by timeout.
  bool get unlocksAlways =>
      !isLocked && (_unlockedOnResponse + _unlockedOnTimeout) == _callsStarted;

  /// The row's metric: the share of its own stated completion measures met.
  double completionMeasurePassRate({required int distinctIntents}) {
    final List<bool> measures = <bool>[
      zeroDuplicateCalls(distinctIntents: distinctIntents),
      unlocksAlways,
    ];
    return measures.where((bool b) => b).length / measures.length;
  }

  static const double floor = 0.95;
  static const double optimal = 1.0;

  static const String domSubstitution =
      '"DOM unlock" is a web term; there is no DOM here. The equivalent is the '
      'disabled state of the control -- locked while a submit is in flight, '
      'released when the answer arrives OR the timeout fires. The failure the '
      'measure names is identical: a control that stays disabled forever '
      'because the response never came and nobody wrote the timeout.';
}
