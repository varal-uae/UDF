/// AISS Step 164 -- GEN-04253
/// Setup Step (Action) / Atomic Step: "Capture mobile app cold start times and
///   page interactivity load times (target < 2s on 3G)."
/// Metric: UI/System Response Latency (RAIL Model) -- Floor "300 ms
///         (Perceptible Delay)", Optimal "< 100 ms (Instantaneous, RAIL
///         Standard)", Ceiling "1,000 ms (User Attention-Loss Threshold)".
///         Good / Average / Poor.
///
/// **THE ROW MIXES TWO BUDGETS, AND APPLYING ONE TO THE OTHER WOULD MAKE EVERY
/// COLD START REPORT "POOR" FOREVER.** RAIL's 100ms is the budget for a
/// RESPONSE TO AN INPUT — a tap producing a visible change. A cold start is
/// not a response to an input; it is an app being built from nothing, and no
/// mobile app has ever done it in 100ms. The row's own setup text names the
/// other budget in the same sentence: "< 2s on 3G".
///
/// So the RAIL bands are applied to what they are for — [HabotTimingKind]
/// values that are responses — and cold start is judged against
/// [HabotMotion.coldStartBudget] (Step 165's 1.2s) and interactivity against
/// [HabotMotion.interactiveOn3g]. The separation is recorded rather than
/// assumed, because reporting a 900ms cold start as a RAIL failure is a number
/// that is technically derived and tells nobody anything.
///
/// **A MEAN HIDES THE THING YOU ARE LOOKING FOR.** Start-up timings have a
/// long tail: the p50 is the device the developer tests on and the p95 is the
/// three-year-old handset in a depot. [HabotTimingSet.percentile] is the
/// reported figure; the mean is available and deliberately not what the band
/// is computed from.
///
/// **A TIMING WITHOUT ITS CONDITIONS IS NOT A MEASUREMENT.** Every capture
/// carries whether the app was in the foreground for the whole of it (Step 166
/// drops the ones that were not) and whether it was a first launch after
/// install, which is materially slower and would otherwise poison the p95.
library;

import '../tokens/motion_tokens.dart';
import 'event_schema.dart';

/// What was timed.
enum HabotTimingKind {
  /// Process start to first frame. Not a RAIL response -- see the header.
  coldStart,

  /// Resume from background to first frame.
  warmStart,

  /// A screen becoming usable: data on screen and controls live.
  interactivity,

  /// A tap producing a visible change. The only kind RAIL's bands are for.
  inputResponse,
}

/// Which budget a kind is judged against.
enum HabotBudgetFamily { rail, startup, interactive }

/// One captured timing.
class HabotTiming {
  const HabotTiming({
    required this.kind,
    required this.elapsed,
    required this.at,
    required this.traceId,
    required this.foregroundThroughout,
    required this.firstLaunchAfterInstall,
  });

  final HabotTimingKind kind;
  final Duration elapsed;
  final DateTime at;
  final String traceId;

  /// False when the app went to the background at any point during the
  /// measurement. Step 166 drops these.
  final bool foregroundThroughout;

  /// A first launch pays for one-time setup and is materially slower.
  /// Reported separately rather than averaged in.
  final bool firstLaunchAfterInstall;

  HabotEvent toEvent({
    required String view,
    required int sessionOrdinal,
  }) =>
      HabotEvent(
        kind: HabotEventKind.timingCaptured,
        view: view,
        traceId: traceId,
        occurredAt: at,
        sessionOrdinal: sessionOrdinal,
        payload: <String, Object?>{
          'timing_kind': kind.name,
          'elapsed_ms': elapsed.inMilliseconds,
          'foreground': foregroundThroughout,
        },
      );
}

/// A set of timings of one kind.
class HabotTimingSet {
  const HabotTimingSet(this.kind, this.samples);

  final HabotTimingKind kind;
  final List<Duration> samples;

  bool get isEmpty => samples.isEmpty;

  /// Nearest-rank percentile. Stated rather than left to a library, because
  /// which of the several definitions is used changes the number.
  Duration percentile(int p) {
    if (samples.isEmpty) {
      return Duration.zero;
    }
    final List<Duration> sorted = List<Duration>.from(samples)
      ..sort((Duration a, Duration b) => a.compareTo(b));
    final int rank = ((p / 100) * sorted.length).ceil();
    final int index = (rank <= 0 ? 1 : rank) - 1;
    return sorted[index >= sorted.length ? sorted.length - 1 : index];
  }

  /// Available, and deliberately not what the band is computed from.
  Duration get mean {
    if (samples.isEmpty) {
      return Duration.zero;
    }
    int micros = 0;
    for (final Duration d in samples) {
      micros += d.inMicroseconds;
    }
    return Duration(microseconds: micros ~/ samples.length);
  }

  Duration get p50 => percentile(50);
  Duration get p95 => percentile(95);
}

/// Captures and bands timings.
class HabotRailTimings {
  HabotRailTimings();

  final List<HabotTiming> _captured = <HabotTiming>[];

  List<HabotTiming> get captured => List<HabotTiming>.unmodifiable(_captured);

  void capture(HabotTiming timing) => _captured.add(timing);

  /// Which budget family a kind belongs to. A total mapping, so a new kind
  /// cannot be added without someone deciding what it is judged against.
  static HabotBudgetFamily familyOf(HabotTimingKind kind) {
    switch (kind) {
      case HabotTimingKind.inputResponse:
        return HabotBudgetFamily.rail;
      case HabotTimingKind.coldStart:
      case HabotTimingKind.warmStart:
        return HabotBudgetFamily.startup;
      case HabotTimingKind.interactivity:
        return HabotBudgetFamily.interactive;
    }
  }

  /// The RAIL bands, verbatim from the row.
  static Duration get railOptimal => HabotMotion.railInstant;
  static Duration get railFloor => HabotMotion.railPerceptible;
  static Duration get railCeiling => HabotMotion.railAttentionLoss;

  /// The startup budget the setup text and Step 165 name.
  static Duration get startupBudget => HabotMotion.coldStartBudget;

  /// The interactivity target the setup text names.
  static Duration get interactiveBudget => HabotMotion.interactiveOn3g;

  /// The row's qualitative vocabulary, applied against the right budget.
  static String bandFor(HabotTimingKind kind, Duration observed) {
    switch (familyOf(kind)) {
      case HabotBudgetFamily.rail:
        if (observed <= railOptimal) {
          return 'Good';
        }
        return observed <= railFloor
            ? 'Average'
            : (observed <= railCeiling ? 'Average' : 'Poor');
      case HabotBudgetFamily.startup:
        return observed <= startupBudget ? 'Good' : 'Poor';
      case HabotBudgetFamily.interactive:
        return observed <= interactiveBudget ? 'Good' : 'Poor';
    }
  }

  /// Samples of one kind, excluding first launches and anything that was not
  /// wholly in the foreground.
  HabotTimingSet setOf(HabotTimingKind kind) => HabotTimingSet(
        kind,
        _captured
            .where((HabotTiming t) =>
                t.kind == kind &&
                t.foregroundThroughout &&
                !t.firstLaunchAfterInstall)
            .map((HabotTiming t) => t.elapsed)
            .toList(),
      );

  /// First launches, reported separately rather than averaged in.
  HabotTimingSet firstLaunchSetOf(HabotTimingKind kind) => HabotTimingSet(
        kind,
        _captured
            .where((HabotTiming t) =>
                t.kind == kind && t.firstLaunchAfterInstall)
            .map((HabotTiming t) => t.elapsed)
            .toList(),
      );

  /// The reported figure for a kind: the p95, not the mean.
  Duration reportedFor(HabotTimingKind kind) => setOf(kind).p95;

  String bandOf(HabotTimingKind kind) =>
      bandFor(kind, reportedFor(kind));

  /// Kinds with no usable sample. Named rather than silently reported as
  /// zero, which would band as "Good".
  List<HabotTimingKind> get unmeasuredKinds => HabotTimingKind.values
      .where((HabotTimingKind k) => setOf(k).isEmpty)
      .toList();

  static const String twoBudgetsNote =
      'RAIL\'s 100ms is the budget for a response to an input. A cold start is '
      'not a response to an input; it is an app being built from nothing, and '
      'no mobile app has done it in 100ms. The row\'s own setup text names the '
      'other budget in the same sentence ("< 2s on 3G"). Applying the RAIL '
      'bands to a cold start would report every launch as a failure against a '
      'bound that was never meant for it -- technically derived, and useless.';

  static const String percentileNote =
      'Start-up timings have a long tail: the p50 is the device the developer '
      'tests on and the p95 is the three-year-old handset in a depot. The p95 '
      'is what is reported. The mean is available and is deliberately not what '
      'the band is computed from.';

  static const String conditionsNote =
      'A timing without its conditions is not a measurement. Every capture '
      'carries whether the app stayed in the foreground for the whole of it '
      '(Step 166 drops the ones that did not) and whether it was a first '
      'launch after install, which is materially slower and would otherwise '
      'poison the p95.';

  static const String noSampleNote =
      'A kind with no usable sample is NAMED rather than reported as zero. '
      'Zero bands as "Good", which is how a metric that is not being collected '
      'ends up looking like a metric that is passing.';
}
