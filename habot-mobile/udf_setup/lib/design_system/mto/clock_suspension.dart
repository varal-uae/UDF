/// AISS Step 120 -- GEN-00247
/// Atomic Step: "Pause the live stream when the app transitions to mobile
///               background state."
/// Metric: General Task Completion Quality -- Floor "Task completed with
///         documented exceptions", Optimal "100% completion matching stated
///         implementation-step intent".
///
/// CONTAMINATED COLUMN, RECORDED. The Setup Step (Action) on this row reads
/// "Ensure the MasterLayout handles safe area insets -- accounts for notch,
/// status bar, and home gesture bar." That is a layout requirement, and it
/// belongs to Step 8 (RCGLA-018), which already owns and gates it. It has
/// nothing to do with pausing anything on backgrounding. It is NOT gated here
/// and nothing was built from it. The Atomic Step is the requirement.
///
/// METRIC MISMATCH, RECORDED: a Definition-of-Done placeholder on a step that
/// names a specific, observable behaviour. Reported as NOT PRODUCED.
///
/// "THE LIVE STREAM", READ AGAINST THIS APP. There is no video stream here.
/// What runs continuously, and what a backgrounded app keeps running against a
/// user who cannot see it, is three clocks -- and the build order names all
/// three:
///
///   * Step 66  `HabotDispatchClock` -- the offer acceptance window. A job
///     offer expiring while the worker's screen is off.
///   * Step 93  `HabotInteractionTimer` -- the worked-duration timer. Time
///     counted as "worked" while the app was not open.
///   * Step 94  `HabotTaskQueue.reallocationWindow` -- the reclaim window. A
///     task taken back off a worker who was never given a chance to act.
///
/// **This is a fairness bug, not a performance one.** A worker losing a job to
/// a timer that ran while their phone was in their pocket has lost income to a
/// clock nobody told them about. That is why each of the three is named
/// individually below and gated by name rather than "timers are paused".
///
/// HOW IT WORKS. [HabotSuspendableClock] is a clock that does not advance
/// while the app is backgrounded. Anything measuring a WORKER'S opportunity to
/// act reads it instead of `DateTime.now`. Wall-clock time is still available
/// and still correct -- what changes is which of the two a deadline is
/// measured against.
library;

import '../resilience/lifecycle_observer.dart';

/// A clock that stops while the app is not in the foreground.
///
/// Not a general-purpose clock. Use it for a deadline a PERSON is expected to
/// meet; use the wall clock for anything a server also measures, or the two
/// will disagree about when something expired.
class HabotSuspendableClock implements HabotLifecycleSensitive {
  HabotSuspendableClock({DateTime Function()? wallClock})
    : _wall = wallClock ?? DateTime.now;

  final DateTime Function() _wall;

  Duration _suspended = Duration.zero;
  DateTime? _suspendedAt;

  /// Total time excluded so far.
  Duration get suspendedTotal =>
      _suspendedAt == null
      ? _suspended
      : _suspended + _wall().difference(_suspendedAt!);

  bool get isSuspended => _suspendedAt != null;

  /// The wall clock, less the time the app spent backgrounded.
  DateTime now() => _wall().subtract(suspendedTotal);

  /// How much of [wallElapsed] the worker could actually see.
  Duration visible(Duration wallElapsed) {
    final Duration out = wallElapsed - suspendedTotal;
    return out.isNegative ? Duration.zero : out;
  }

  @override
  String get lifecycleLabel => 'HabotSuspendableClock';

  @override
  HabotLifecycleAction get lifecycleAction => HabotLifecycleAction.suspend;

  @override
  bool get isReleased => isSuspended;

  @override
  void onBackgrounded() {
    _suspendedAt ??= _wall();
  }

  @override
  void onForegrounded() {
    if (_suspendedAt == null) {
      return;
    }
    _suspended += _wall().difference(_suspendedAt!);
    _suspendedAt = null;
  }
}

/// The three clocks the build order names, each declared individually so a
/// gate can assert on it by name and a reviewer can see nothing was quietly
/// dropped.
enum HabotRunningClock {
  /// Step 66 -- the dispatch offer acceptance window.
  dispatchAcceptanceWindow,

  /// Step 93 -- the interaction timer's worked duration.
  interactionTimer,

  /// Step 94 -- the task reallocation window.
  taskReclaimWindow,
}

extension HabotRunningClockDetail on HabotRunningClock {
  String get owningStep {
    switch (this) {
      case HabotRunningClock.dispatchAcceptanceWindow:
        return 'Step 66 GEN-00692';
      case HabotRunningClock.interactionTimer:
        return 'Step 93 GEN-03866';
      case HabotRunningClock.taskReclaimWindow:
        return 'Step 94 GEN-00843';
    }
  }

  /// What the user loses if this clock runs while they cannot see it.
  String get unfairnessIfUnpaused {
    switch (this) {
      case HabotRunningClock.dispatchAcceptanceWindow:
        return 'A job offer expires while the phone is in the worker pocket. '
            'They were never shown it and it is gone.';
      case HabotRunningClock.interactionTimer:
        return 'Time the app spent backgrounded is counted as time worked, so '
            'a task looks slower than it was and an SLA is breached by the '
            'phone rather than by the person.';
      case HabotRunningClock.taskReclaimWindow:
        return 'A task is reclaimed from a worker who was never given a '
            'chance to act on it.';
    }
  }
}

/// One clock, registered with the lifecycle observer and told to stop.
class HabotSuspendedClockBinding implements HabotLifecycleSensitive {
  HabotSuspendedClockBinding({
    required this.clock,
    required this.suspendable,
    required this.pause,
    required this.resume,
    required this.isPaused,
  });

  final HabotRunningClock clock;

  /// The shared suspendable clock this binding keeps in step with.
  final HabotSuspendableClock suspendable;

  /// What actually stops. For Step 93 this is `HabotInteractionTimer.pause`,
  /// which already exists -- this step does not rebuild it, it calls it.
  final void Function() pause;
  final void Function() resume;
  final bool Function() isPaused;

  @override
  String get lifecycleLabel => '${clock.name} (${clock.owningStep})';

  @override
  HabotLifecycleAction get lifecycleAction => HabotLifecycleAction.suspend;

  @override
  bool get isReleased => isPaused();

  @override
  void onBackgrounded() => pause();

  @override
  void onForegrounded() => resume();
}

/// Registers all three clocks and reports whether any was missed.
class HabotClockSuspension {
  HabotClockSuspension({required this.observer, required this.clock}) {
    // The shared clock is itself lifecycle-sensitive, and it is registered
    // exactly once here rather than by each binding. Registering it per
    // binding would suspend it three times over and the excluded interval
    // would be wrong by a factor of three -- in the direction that flatters
    // the app, which is the worse direction.
    observer.register(clock);
  }

  final HabotLifecycleObserver observer;
  final HabotSuspendableClock clock;

  final Map<HabotRunningClock, HabotSuspendedClockBinding> _bound =
      <HabotRunningClock, HabotSuspendedClockBinding>{};

  void bind(HabotSuspendedClockBinding binding) {
    _bound[binding.clock] = binding;
    observer.register(binding);
  }

  Set<HabotRunningClock> get bound => _bound.keys.toSet();

  /// The clocks the build order names that have NOT been bound. Non-empty is
  /// a failure: a clock nobody paused is a clock still running against a
  /// worker who cannot see it.
  List<HabotRunningClock> get unbound => HabotRunningClock.values
      .where((HabotRunningClock c) => !_bound.containsKey(c))
      .toList();

  bool get isComplete => unbound.isEmpty;

  /// Clocks that were bound but did not actually stop on the last
  /// backgrounding.
  List<HabotRunningClock> get stillRunning => _bound.values
      .where((HabotSuspendedClockBinding b) => !b.isReleased)
      .map((HabotSuspendedClockBinding b) => b.clock)
      .toList();

  static const String contaminationNote =
      'Setup Step (Action) on this row reads "Ensure the MasterLayout handles '
      'safe area insets -- accounts for notch, status bar, and home gesture '
      'bar." That is a layout requirement owned and gated by Step 8 '
      '(RCGLA-018). It is unrelated to pausing on backgrounding, it is not '
      'gated here, and nothing was built from it.';
}
