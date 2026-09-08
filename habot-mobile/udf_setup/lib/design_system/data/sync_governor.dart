/// AISS Step 124 -- GEN-05397
/// Atomic Step, in full: "Implement the mistake-proofing (Poka-Yoke) control:
///   system automatically pauses heavy background data synchronizations when
///   network RTT (Round Trip Time) exceeds 1000ms, preserving critical
///   interactive UI calls."
/// Metric: Mistake-Proofing Control Effectiveness (Error Interception Rate) --
///         Floor ">= 90% of induced errors intercepted",
///         Optimal ">= 99% of induced errors intercepted".
///
/// A CORRECTION TO THE STEPS 111-125 BUILD ORDER, RECORDED. That document
/// states this row "says background sync 'automatically pauses' and NEVER SAYS
/// WHEN", calls it "a genuine specification hole", and asks the owner for a
/// decision. **That is wrong.** The row does say when, precisely: network RTT
/// exceeding 1000ms. It also says what must survive the pause: critical
/// interactive UI calls. Nothing was decided on the owner's behalf, because
/// nothing needed deciding -- the requirement was complete and had been read
/// too quickly. The threshold below is the sheet's number, not a choice.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// WHY RTT AND NOT "OFFLINE". Step 47 already handles a dead radio. This is the
/// harder case and the one that actually hurts a field worker: a link that
/// WORKS but is slow. Background sync on a 1200ms link does not fail -- it
/// succeeds, slowly, while occupying the same pipe the tap the user just made
/// is waiting on. The user experiences it as the app being broken. Pausing the
/// bulk work is what keeps the tap responsive.
///
/// THE WORD "PRESERVING" IS THE HALF PEOPLE DROP. A governor that pauses
/// everything on a slow link is a governor that makes a slow app into a dead
/// one. Interactive calls -- the thing a person is waiting on right now --
/// continue. [HabotWorkClass] is that distinction, made at the call site so it
/// cannot be guessed at later.
///
/// THE METRIC FITS, unusually. "Error Interception Rate" over induced errors
/// is directly producible: drive the RTT above the threshold, count how many
/// heavy operations were stopped, and report the share. That is what the gate
/// does.
library;

import 'dart:collection';

import '../tokens/motion_tokens.dart';
import 'sync_loop.dart';

/// What kind of work is asking to proceed.
enum HabotWorkClass {
  /// A person is waiting on this right now. Never paused -- the row says
  /// "preserving critical interactive UI calls", and this is that clause.
  interactive,

  /// Bulk background transfer: the outbox drain, a delta batch, telemetry.
  /// This is what "heavy background data synchronizations" means.
  heavyBackground,

  /// Small background work that is not bulk -- a heartbeat, a poll. Allowed
  /// while degraded, because stopping it is how the app loses track of whether
  /// the link recovered.
  lightBackground,
}

/// One RTT observation.
class HabotRttSample {
  const HabotRttSample({required this.rtt, required this.at});

  final Duration rtt;
  final DateTime at;
}

/// The decision for one request.
class HabotGovernorDecision {
  const HabotGovernorDecision({
    required this.workClass,
    required this.allowed,
    required this.observedRtt,
    required this.reason,
  });

  final HabotWorkClass workClass;
  final bool allowed;
  final Duration? observedRtt;
  final String reason;

  bool get intercepted => !allowed;

  Map<String, Object?> toJson() => <String, Object?>{
    'work_class': workClass.name,
    'allowed': allowed,
    'observed_rtt_ms': observedRtt?.inMilliseconds,
    'reason': reason,
  };
}

/// The poka-yoke control.
class HabotSyncGovernorControl implements HabotSyncGovernor {
  HabotSyncGovernorControl({
    this.sampleWindow = 5,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// How many recent samples the decision is made over. One slow request is
  /// noise; five in a row is a slow link. A governor that flaps on a single
  /// outlier pauses and resumes constantly, which is worse than not pausing.
  final int sampleWindow;

  final DateTime Function() _clock;

  final Queue<HabotRttSample> _samples = Queue<HabotRttSample>();
  final List<HabotGovernorDecision> _decisions = <HabotGovernorDecision>[];

  /// The sheet's number, verbatim: RTT above this pauses heavy sync.
  static Duration get threshold => HabotMotion.rttHeavySyncThreshold;

  static const double floor = 0.90;
  static const double optimal = 0.99;

  List<HabotGovernorDecision> get decisions =>
      List<HabotGovernorDecision>.unmodifiable(_decisions);

  List<HabotRttSample> get samples => List<HabotRttSample>.from(_samples);

  /// Record a round trip. Called by whatever actually measures one -- the
  /// Step 47 poll, the Step 127 heartbeat, or any completed request.
  void observe(Duration rtt) {
    _samples.addLast(HabotRttSample(rtt: rtt, at: _clock()));
    while (_samples.length > sampleWindow) {
      _samples.removeFirst();
    }
  }

  /// The median of the window. Median rather than mean, because one 8-second
  /// timeout should not by itself declare the link slow -- and on a genuinely
  /// slow link the median is above the threshold anyway.
  Duration? get observedRtt {
    if (_samples.isEmpty) {
      return null;
    }
    final List<int> ms =
        _samples.map((HabotRttSample s) => s.rtt.inMilliseconds).toList()
          ..sort();
    return Duration(milliseconds: ms[ms.length ~/ 2]);
  }

  /// True when the link is slow enough to pause bulk work.
  bool get isDegraded {
    final Duration? rtt = observedRtt;
    return rtt != null && rtt > threshold;
  }

  /// The decision for a specific request. This is the entry point; [allowsHeavyWork]
  /// is the [HabotSyncGovernor] view of the same thing.
  HabotGovernorDecision decide(HabotWorkClass workClass) {
    final Duration? rtt = observedRtt;
    late final bool allowed;
    late final String reason;

    if (workClass == HabotWorkClass.interactive) {
      allowed = true;
      reason =
          'interactive work is never paused -- the row requires "preserving '
          'critical interactive UI calls", and a governor that stops those '
          'turns a slow app into a dead one';
    } else if (!isDegraded) {
      allowed = true;
      reason = rtt == null
          ? 'no RTT samples yet; nothing to pause on'
          : 'RTT ${rtt.inMilliseconds}ms is within the '
                '${threshold.inMilliseconds}ms threshold';
    } else if (workClass == HabotWorkClass.lightBackground) {
      allowed = true;
      reason =
          'light background work continues while degraded: stopping the '
          'heartbeat and the poll is how the app loses track of whether the '
          'link recovered';
    } else {
      allowed = false;
      reason =
          'RTT ${rtt!.inMilliseconds}ms exceeds the '
          '${threshold.inMilliseconds}ms threshold. Heavy background '
          'synchronisation is paused so it stops competing with the request '
          'the user is waiting on.';
    }

    final HabotGovernorDecision decision = HabotGovernorDecision(
      workClass: workClass,
      allowed: allowed,
      observedRtt: rtt,
      reason: reason,
    );
    _decisions.add(decision);
    return decision;
  }

  @override
  bool get allowsHeavyWork => decide(HabotWorkClass.heavyBackground).allowed;

  @override
  String get reason =>
      _decisions.isEmpty ? 'no decision taken yet' : _decisions.last.reason;

  /// The metric the row names, computed rather than asserted: of the heavy
  /// operations that were attempted while the link was degraded, the share the
  /// control actually stopped.
  ///
  /// Interactive and light work are excluded from the denominator on purpose.
  /// They are not errors to intercept; they are what the control is required
  /// to let through, and counting them would inflate the rate with successes
  /// that had nothing to do with interception.
  double get interceptionRate {
    final List<HabotGovernorDecision> heavyWhileDegraded = _decisions
        .where(
          (HabotGovernorDecision d) =>
              d.workClass == HabotWorkClass.heavyBackground &&
              d.observedRtt != null &&
              d.observedRtt! > threshold,
        )
        .toList();
    if (heavyWhileDegraded.isEmpty) {
      return 1;
    }
    final int stopped = heavyWhileDegraded
        .where((HabotGovernorDecision d) => d.intercepted)
        .length;
    return stopped / heavyWhileDegraded.length;
  }

  /// Interactive calls that were let through while the link was degraded. The
  /// "preserving" half, counted so it can be shown rather than asserted.
  int get interactivePreserved => _decisions
      .where(
        (HabotGovernorDecision d) =>
            d.workClass == HabotWorkClass.interactive &&
            d.allowed &&
            d.observedRtt != null &&
            d.observedRtt! > threshold,
      )
      .length;

  bool get meetsFloor => interceptionRate >= floor;
  bool get meetsOptimal => interceptionRate >= optimal;

  static const String specificationCorrection =
      'The Steps 111-125 build order records this row as having a '
      'specification hole -- "says background sync automatically pauses and '
      'never says when". The row does say when: network RTT exceeding 1000ms, '
      'preserving critical interactive UI calls. The threshold here is the '
      'sheet number, and no owner decision was needed or taken.';
}
