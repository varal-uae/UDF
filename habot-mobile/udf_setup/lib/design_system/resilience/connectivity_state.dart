/// AISS: GEN-02720-A01 -- "Write the offline UI state management logic that
/// activates when the polling function fails to receive a response within the
/// timeout threshold."
/// Mobile-First UX row: "Background polling refreshes data every 30 seconds.
/// Pull-to-refresh triggers manual sync."
///
/// The state machine, not the banner. Step 48 renders this; building the view
/// first would mean inventing a second answer to "are we offline?", and two
/// answers to that question is how an app ends up showing a cheerful sync icon
/// over a queue of forty unsent records.
///
/// Three states rather than two, deliberately. A poll that has missed once is
/// not offline -- one dropped response on a train is normal -- but it is not
/// healthy either, and the difference is worth showing before the user has
/// typed for another two minutes into something that will not send.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../tokens/motion_tokens.dart';

/// What the app currently believes about the network.
enum HabotConnectivity {
  /// The last poll answered inside the timeout.
  online,

  /// At least one poll missed, but not enough to call it offline.
  degraded,

  /// [HabotConnectivityPolicy.failuresBeforeOffline] consecutive polls have
  /// timed out.
  offline,
}

class HabotConnectivityPolicy {
  const HabotConnectivityPolicy._();

  /// "Background polling refreshes data every 30 seconds."
  static const Duration pollInterval = HabotMotion.pollInterval;

  /// A poll that has not answered in this long has failed. Shorter than the
  /// interval on purpose: a request still outstanding when the next poll is
  /// due is not going to arrive usefully.
  static const Duration pollTimeout = HabotMotion.pollTimeout;

  /// Consecutive failures before the app declares itself offline.
  static const int failuresBeforeOffline = 2;

  /// One success is enough to come back. Recovery should be eager -- the cost
  /// of being wrong is a banner that disappears half a minute early, against
  /// a user who cannot see that their connection is back.
  static const int successesBeforeOnline = 1;

  static HabotConnectivity classify(int consecutiveFailures) {
    if (consecutiveFailures == 0) {
      return HabotConnectivity.online;
    }
    if (consecutiveFailures < failuresBeforeOffline) {
      return HabotConnectivity.degraded;
    }
    return HabotConnectivity.offline;
  }
}

/// One item waiting to be sent.
@immutable
class HabotPendingItem {
  const HabotPendingItem({required this.id, required this.kind});

  final String id;

  /// What sort of thing is waiting -- "submission", "edit", "upload". Never
  /// the contents.
  final String kind;
}

/// The state machine.
///
/// The poll itself is injected, so the gates drive real transitions with a
/// fake network instead of waiting on one.
class HabotConnectivityMonitor extends ChangeNotifier {
  HabotConnectivityMonitor({required this.poll, Duration? interval})
    : interval = interval ?? HabotConnectivityPolicy.pollInterval;

  /// Returns true when the backend answered. Expected to complete inside
  /// [HabotConnectivityPolicy.pollTimeout]; the monitor enforces that itself
  /// rather than trusting the caller to.
  final Future<bool> Function() poll;

  final Duration interval;

  Timer? _timer;
  int _consecutiveFailures = 0;
  final List<HabotPendingItem> _pending = <HabotPendingItem>[];
  DateTime? _offlineSince;

  HabotConnectivity get state =>
      HabotConnectivityPolicy.classify(_consecutiveFailures);

  bool get isOffline => state == HabotConnectivity.offline;
  bool get isDegraded => state == HabotConnectivity.degraded;

  int get consecutiveFailures => _consecutiveFailures;

  /// Items queued while offline. The count the banner shows.
  List<HabotPendingItem> get pending =>
      List<HabotPendingItem>.unmodifiable(_pending);
  int get pendingCount => _pending.length;

  DateTime? get offlineSince => _offlineSince;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => unawaited(pollOnce()));
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// One poll. Also what pull-to-refresh calls -- "pull-to-refresh triggers
  /// manual sync" is the same operation, not a second path with its own state.
  Future<void> pollOnce() async {
    bool answered;
    try {
      answered = await poll().timeout(HabotConnectivityPolicy.pollTimeout);
    } on TimeoutException {
      answered = false;
    } catch (_) {
      answered = false;
    }
    _apply(answered: answered);
  }

  void _apply({required bool answered}) {
    final HabotConnectivity before = state;
    if (answered) {
      _consecutiveFailures = 0;
    } else {
      _consecutiveFailures++;
    }
    final HabotConnectivity after = state;
    if (after == HabotConnectivity.offline &&
        before != HabotConnectivity.offline) {
      _offlineSince = DateTime.now();
    }
    if (after == HabotConnectivity.online) {
      _offlineSince = null;
    }
    if (before != after) {
      notifyListeners();
    }
  }

  /// Queues work that could not be sent. Returns the queue depth.
  int enqueue(HabotPendingItem item) {
    _pending.add(item);
    notifyListeners();
    return _pending.length;
  }

  /// Drains the queue after recovery. Returns what was sent, so the caller can
  /// tell the user how much caught up rather than silently emptying it.
  List<HabotPendingItem> drain() {
    final List<HabotPendingItem> sent = List<HabotPendingItem>.from(_pending);
    _pending.clear();
    notifyListeners();
    return sent;
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
