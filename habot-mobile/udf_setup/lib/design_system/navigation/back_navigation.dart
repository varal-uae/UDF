/// AISS: ANSA-012-A01 -- substep 4 "Link the master back arrow component to
/// secure state management targets", and the step's Poka-Yoke:
///
///   "Intercept routes block rapid double-tapping on back controls, saving
///    history queues from array corruption."
///
/// The failure this prevents is real: a user double-taps back on a slow device,
/// two pops fire before the first route transition completes, and the app
/// unwinds one screen further than intended -- or pops past the root and shows
/// a black screen. The guard is a monotonic debounce on pop, not a visual one.
library;

import 'package:flutter/widgets.dart';

import '../tokens/motion_tokens.dart';

/// Serialises back-navigation so a burst of taps produces exactly one pop.
class HabotBackNavigator {
  HabotBackNavigator({this.debounce = HabotMotion.backTapDebounce});

  /// Window inside which a second back request is swallowed.
  final Duration debounce;

  Duration? _lastPopAt;
  int _acceptedPops = 0;
  int _rejectedPops = 0;

  int get acceptedPops => _acceptedPops;
  int get rejectedPops => _rejectedPops;

  @visibleForTesting
  void reset() {
    _lastPopAt = null;
    _acceptedPops = 0;
    _rejectedPops = 0;
  }

  /// Decides whether a back request at [now] should be honoured.
  ///
  /// [now] is passed in rather than read from a clock so the gate can drive it
  /// deterministically. Production callers pass elapsed real time.
  bool shouldAcceptPop(Duration now) {
    final Duration? last = _lastPopAt;
    if (last != null && now - last < debounce) {
      _rejectedPops++;
      return false;
    }
    _lastPopAt = now;
    _acceptedPops++;
    return true;
  }

  /// Pops [navigator] at most once per [debounce] window.
  ///
  /// Returns true if a pop was actually performed.
  bool maybePop(NavigatorState navigator, Duration now) {
    if (!shouldAcceptPop(now)) {
      return false;
    }
    if (!navigator.canPop()) {
      // Never pop the root -- that is the "history queue corruption" the
      // step sheet warns about, in its most visible form.
      _acceptedPops--;
      _lastPopAt = null;
      return false;
    }
    navigator.pop();
    return true;
  }
}
