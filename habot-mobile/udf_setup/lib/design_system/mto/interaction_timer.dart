/// AISS: GEN-03866-A01 -- "Add an INTERACTION TIMER tracking worker execution
/// duration on the mobile screen."
/// Metric: Interaction Timer Resolution Drift -- Floor "<10 ms",
///         Optimal "<1 ms", Ceiling "50 ms".
/// Standard: W3C User Timing / High Resolution Time.
///
/// WHAT IS BEING TIMED, AND WHAT IS NOT. This measures how long a worker spent
/// ON A TASK, not how long the task sat on the device. A phone that rings
/// mid-task, or an app sent to the background, is not the worker working -- so
/// the timer pauses. Wall-clock elapsed time is still available separately,
/// because the reallocation rule in Step 94 is about wall clock: a task nobody
/// has touched for five minutes goes back in the queue whether or not the
/// worker's app was open.
///
/// ON DRIFT. The metric is a resolution measure: the difference between what
/// the timer says elapsed and what actually elapsed. Two halves, and only one
/// of them is observable here:
///
///   ARITHMETIC DRIFT -- accumulate a series of intervals and compare the
///   total against their sum. That is measurable in a suite, it is what a
///   pause/resume implementation gets wrong, and it is what the gate reports.
///
///   WALL-CLOCK DRIFT -- what `DateTime.now()` on a specific handset does
///   against a reference clock under thermal load. No test host produces that
///   figure, and none is invented here.
///
/// The clock is injected for the same reason it is in Steps 66 and 79: a timer
/// tested against the real clock is a flaky test, and a flaky test that
/// measures drift is worse than none.
library;

import 'package:flutter/foundation.dart';

import '../tokens/motion_tokens.dart';

/// What the timer is doing.
enum HabotTimerState { idle, running, paused, stopped }

/// One interval of actual work.
@immutable
class HabotWorkInterval {
  const HabotWorkInterval({required this.startedAt, required this.endedAt});

  final DateTime startedAt;
  final DateTime endedAt;

  Duration get duration => endedAt.difference(startedAt);
}

/// The interaction timer.
class HabotInteractionTimer extends ChangeNotifier {
  HabotInteractionTimer({required this.taskId, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final String taskId;
  final DateTime Function() _clock;

  final List<HabotWorkInterval> _intervals = <HabotWorkInterval>[];
  DateTime? _currentStart;
  DateTime? _firstStart;
  DateTime? _stoppedAt;
  HabotTimerState _state = HabotTimerState.idle;

  HabotTimerState get state => _state;

  List<HabotWorkInterval> get intervals =>
      List<HabotWorkInterval>.unmodifiable(_intervals);

  /// Metric bands, from the sheet's own row.
  static Duration get driftFloor => HabotMotion.mtoTimerDriftFloor;
  static Duration get driftOptimal => HabotMotion.mtoTimerDriftOptimal;
  static Duration get driftCeiling => HabotMotion.mtoTimerDriftCeiling;

  void start() {
    if (_state == HabotTimerState.running || _state == HabotTimerState.stopped) {
      return;
    }
    final DateTime now = _clock();
    _firstStart ??= now;
    _currentStart = now;
    _state = HabotTimerState.running;
    notifyListeners();
  }

  /// The worker looked away: a call, a notification, the app backgrounded.
  void pause() {
    if (_state != HabotTimerState.running) {
      return;
    }
    _closeInterval();
    _state = HabotTimerState.paused;
    notifyListeners();
  }

  void stop() {
    if (_state == HabotTimerState.running) {
      _closeInterval();
    }
    if (_state == HabotTimerState.stopped) {
      return;
    }
    _stoppedAt = _clock();
    _state = HabotTimerState.stopped;
    notifyListeners();
  }

  void _closeInterval() {
    final DateTime? start = _currentStart;
    if (start == null) {
      return;
    }
    _intervals.add(HabotWorkInterval(startedAt: start, endedAt: _clock()));
    _currentStart = null;
  }

  /// Time the worker actually spent on the task, excluding pauses.
  Duration get workedDuration {
    Duration total = Duration.zero;
    for (final HabotWorkInterval interval in _intervals) {
      total += interval.duration;
    }
    final DateTime? open = _currentStart;
    if (open != null) {
      total += _clock().difference(open);
    }
    return total;
  }

  /// Wall-clock time since the worker first opened the task, pauses included.
  /// This is what Step 94's reallocation rule reads.
  Duration get elapsedSinceStart {
    final DateTime? first = _firstStart;
    if (first == null) {
      return Duration.zero;
    }
    return (_stoppedAt ?? _clock()).difference(first);
  }

  /// The paused time, which is exactly the difference between the two.
  Duration get pausedDuration => elapsedSinceStart - workedDuration;

  /// ARITHMETIC DRIFT: the accumulated total against the sum of the recorded
  /// intervals. Zero means the accumulator lost nothing and double-counted
  /// nothing across every start, pause and resume.
  Duration get accumulationDrift {
    Duration summed = Duration.zero;
    for (final HabotWorkInterval interval in _intervals) {
      summed += interval.duration;
    }
    final Duration reported = _currentStart == null
        ? workedDuration
        : workedDuration - _clock().difference(_currentStart!);
    final int deltaUs = (reported - summed).inMicroseconds.abs();
    return Duration(microseconds: deltaUs);
  }

  bool get meetsDriftFloor => accumulationDrift < driftFloor;
  bool get meetsDriftOptimal => accumulationDrift < driftOptimal;

  /// What the card and the queue read.
  String get readout {
    final Duration worked = workedDuration;
    final int minutes = worked.inMinutes;
    final int seconds = worked.inSeconds - (minutes * 60);
    final String paddedSeconds = seconds.toString().padLeft(2, '0');
    return '$minutes:$paddedSeconds';
  }

  /// True once the worker has passed the SLA target from Step 95.
  bool get isOverSla => elapsedSinceStart >= HabotMotion.mtoSlaTarget;
}
