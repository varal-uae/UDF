/// AISS Step 119 -- GEN-04418
/// Atomic Step: "Create an app-lifecycle listener triggering state cleanup
///               when app goes to background."
/// Metric: Memory Leak Incident Rate -- Floor < 1 per session (gate),
///         Optimal 0 per session, Ceiling 1.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// THE GAP THIS CLOSES, from the build order: **the app has never once been
/// told it was backgrounded.** Nothing in 118 steps reacts to it. Every timer
/// keeps counting, every subscription keeps listening, and every cache keeps
/// growing while the screen is off.
///
/// METRIC NOT PRODUCIBLE, RECORDED. A memory-leak incident rate needs a
/// profiler attached to a handset over a real session. No widget test can
/// observe it and no number is invented in its place. What the client DOES own
/// is whether every registered resource was actually released when the app
/// left the foreground -- that is countable, it is the precondition for the
/// leak rate being zero, and it is what is gated.
///
/// WHY A REGISTRY RATHER THAN A CALLBACK. A `didChangeAppLifecycleState`
/// callback somewhere in the widget tree is a callback that gets deleted in a
/// refactor, and nothing breaks visibly when it does. A resource that
/// REGISTERS itself is a resource the observer can count, so
/// [HabotLifecycleObserver.releasedOnLastBackground] is a fact rather than a
/// hope, and a resource that failed to release is named rather than missed.
///
/// FIRST OF THE LIFECYCLE BLOCK. Step 120 specialises it to the three running
/// clocks; Step 128 specialises it to the socket.
library;

import 'package:flutter/widgets.dart';

/// What a resource does when the app leaves the foreground.
enum HabotLifecycleAction {
  /// Stop consuming and let go of memory. A cache, a decoded image set.
  release,

  /// Stop counting. A timer whose elapsed time would otherwise include time
  /// the user could not see. See Step 120.
  suspend,

  /// Stop listening but keep the connection. A socket. See Step 128.
  detach,
}

/// Anything that must be told the app went away.
abstract interface class HabotLifecycleSensitive {
  /// A name that appears in the evidence when this resource fails to release.
  String get lifecycleLabel;

  HabotLifecycleAction get lifecycleAction;

  /// Called when the app leaves the foreground. Must be safe to call twice.
  void onBackgrounded();

  /// Called when it returns. Must be safe to call without a preceding
  /// [onBackgrounded] -- the platform does not promise pairs.
  void onForegrounded();

  /// True when this resource is currently holding nothing it should not.
  /// Checked after a backgrounding, and the reason a failure has an address.
  bool get isReleased;
}

/// One backgrounding, and what it achieved.
class HabotLifecycleSweep {
  const HabotLifecycleSweep({
    required this.at,
    required this.registered,
    required this.released,
    required this.failures,
  });

  final DateTime at;
  final int registered;
  final int released;

  /// Resources that did not report themselves released. Named, because a
  /// count on its own tells nobody what to fix.
  final List<String> failures;

  bool get isClean => failures.isEmpty && released == registered;

  double get releaseRate => registered == 0 ? 1 : released / registered;

  Map<String, Object?> toJson() => <String, Object?>{
    'at': at.toIso8601String(),
    'registered': registered,
    'released': released,
    'release_rate': releaseRate,
    'failures': failures,
  };
}

/// The listener. One per app.
class HabotLifecycleObserver with WidgetsBindingObserver {
  HabotLifecycleObserver({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  final List<HabotLifecycleSensitive> _resources =
      <HabotLifecycleSensitive>[];
  final List<HabotLifecycleSweep> _sweeps = <HabotLifecycleSweep>[];

  bool _inForeground = true;
  DateTime? _leftAt;
  Duration _totalBackgrounded = Duration.zero;

  List<HabotLifecycleSensitive> get resources =>
      List<HabotLifecycleSensitive>.unmodifiable(_resources);

  List<HabotLifecycleSweep> get sweeps =>
      List<HabotLifecycleSweep>.unmodifiable(_sweeps);

  bool get isInForeground => _inForeground;

  /// How long this session has spent backgrounded in total. Step 120 subtracts
  /// this from anything a worker is being timed against.
  Duration get totalBackgrounded => _totalBackgrounded;

  HabotLifecycleSweep? get lastSweep =>
      _sweeps.isEmpty ? null : _sweeps.last;

  int get releasedOnLastBackground => lastSweep?.released ?? 0;

  void register(HabotLifecycleSensitive resource) {
    if (!_resources.contains(resource)) {
      _resources.add(resource);
    }
  }

  void unregister(HabotLifecycleSensitive resource) =>
      _resources.remove(resource);

  /// The Flutter hook. Kept thin: everything it does is in [background] and
  /// [foreground], so both are reachable from a test without a platform
  /// message.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        foreground();
      case AppLifecycleState.inactive:
        // Deliberately ignored. `inactive` fires for a notification shade
        // pull and an incoming call banner -- releasing there would tear the
        // app down every time a notification arrives.
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        background();
    }
  }

  /// Tell every registered resource the app left, then check they listened.
  HabotLifecycleSweep background() {
    if (!_inForeground) {
      // Idempotent: the platform can send paused twice.
      return _sweeps.isNotEmpty
          ? _sweeps.last
          : HabotLifecycleSweep(
              at: _clock(),
              registered: _resources.length,
              released: _resources.length,
              failures: const <String>[],
            );
    }
    _inForeground = false;
    _leftAt = _clock();

    final List<String> failures = <String>[];
    int released = 0;
    for (final HabotLifecycleSensitive r in _resources) {
      try {
        r.onBackgrounded();
      } on Object catch (e) {
        failures.add('${r.lifecycleLabel} threw on background: $e');
        continue;
      }
      if (r.isReleased) {
        released++;
      } else {
        failures.add(
          '${r.lifecycleLabel} (${r.lifecycleAction.name}) did not report '
          'itself released',
        );
      }
    }
    final HabotLifecycleSweep sweep = HabotLifecycleSweep(
      at: _leftAt!,
      registered: _resources.length,
      released: released,
      failures: failures,
    );
    _sweeps.add(sweep);
    return sweep;
  }

  /// Tell every registered resource the app came back.
  Duration foreground() {
    if (_inForeground) {
      return Duration.zero;
    }
    _inForeground = true;
    final Duration away = _leftAt == null
        ? Duration.zero
        : _clock().difference(_leftAt!);
    _totalBackgrounded += away;
    _leftAt = null;
    for (final HabotLifecycleSensitive r in _resources) {
      r.onForegrounded();
    }
    return away;
  }

  /// The share of registered resources released on the last backgrounding.
  /// This is the client-side half of the row's metric -- see the header.
  double get lastReleaseRate => lastSweep?.releaseRate ?? 1;

  /// Every resource that has ever failed to release, across all sweeps.
  List<String> get allFailures =>
      <String>[for (final HabotLifecycleSweep s in _sweeps) ...s.failures];

  static const String metricNote =
      'Memory Leak Incident Rate is NOT PRODUCED. It needs a profiler attached '
      'to a handset across a real session; no widget test can observe it, and '
      'no number is invented in its place. What is measured is the '
      'precondition: whether every registered resource actually released when '
      'the app left the foreground.';
}
