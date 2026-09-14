/// AISS Step 166 -- GEN-04539
/// Setup Step (Action) / Atomic Step: "Filter out performance trace data
///   collected during background execution states."
/// Metric: Form Field Validation Accuracy -- Floor 0.95, Optimal 0.99,
///         Ceiling 1.0. Good / Average / Poor.
///
/// **A MISMATCHED METRIC, RECORDED.** The Atomic Step is about performance
/// traces; the metric names form field validation. They have nothing to do
/// with each other. What the metric's SHAPE is good for is an accuracy rate
/// over a classification, and this step is a classifier — so it is read as
/// filter accuracy: the share of traces sorted correctly into kept and
/// dropped. The reading is recorded rather than the metric being ignored.
///
/// **THE OBVIOUS IMPLEMENTATION KEEPS EXACTLY THE WRONG TRACES.** Checking
/// "was the app in the foreground?" at the moment a trace is captured passes
/// the case everyone tests and fails the case that matters. A trace that
/// STARTS in the foreground and finishes after the user backgrounded the app
/// reads as foreground at capture time — and its elapsed time includes every
/// second the process spent suspended. Those are the traces that produce a
/// p95 of eleven seconds and a week of investigation into a cold start that
/// was never slow.
///
/// So a trace is kept only when the app was in the foreground for the WHOLE
/// of it. [HabotTraceFilter] classifies against the lifecycle transitions
/// that happened during the window, not against the state at either end.
///
/// **A DROPPED TRACE IS COUNTED, NOT DISCARDED SILENTLY.** If the drop rate
/// climbs, either the app is being backgrounded constantly — which is itself
/// a finding — or the filter has a bug. A filter that leaves no trace of what
/// it removed cannot be told apart from one that removes nothing.
library;

import 'rail_timings.dart';

/// What the filter decided, and why.
enum HabotTraceVerdict {
  /// Foreground throughout. Usable.
  kept,

  /// The app was backgrounded for some or all of the window.
  droppedBackgrounded,

  /// A first launch after install. Real, but materially slower, and reported
  /// separately rather than mixed in.
  divertedFirstLaunch,

  /// The window is not a window: zero or negative elapsed time.
  droppedImplausible,
}

/// One lifecycle transition, as the Step 119 observer reports them.
class HabotLifecycleTransition {
  const HabotLifecycleTransition({
    required this.at,
    required this.toForeground,
  });

  final DateTime at;

  /// True when the app came to the foreground at this instant; false when it
  /// went to the background.
  final bool toForeground;
}

/// One classified trace.
class HabotTraceDecision {
  const HabotTraceDecision({
    required this.timing,
    required this.verdict,
    required this.reason,
  });

  final HabotTiming timing;
  final HabotTraceVerdict verdict;
  final String reason;

  bool get isKept => verdict == HabotTraceVerdict.kept;
}

/// Classifies performance traces against lifecycle history.
class HabotTraceFilter {
  const HabotTraceFilter({required this.transitions});

  /// Every foreground/background transition observed, in order.
  final List<HabotLifecycleTransition> transitions;

  /// True when the app was in the foreground for the whole window
  /// [start, end].
  ///
  /// **This is the method the step exists for.** Any transition to the
  /// background inside the window disqualifies the trace, however briefly --
  /// a two-second suspension is two seconds added to the measurement.
  bool foregroundThroughout(DateTime start, DateTime end) {
    for (final HabotLifecycleTransition t in transitions) {
      final bool inside = !t.at.isBefore(start) && !t.at.isAfter(end);
      if (inside && !t.toForeground) {
        return false;
      }
    }
    // A window that begins while backgrounded is also disqualified: the most
    // recent transition before the start tells us which state we were in.
    HabotLifecycleTransition? latestBefore;
    for (final HabotLifecycleTransition t in transitions) {
      if (t.at.isAfter(start)) {
        continue;
      }
      if (latestBefore == null || t.at.isAfter(latestBefore.at)) {
        latestBefore = t;
      }
    }
    return latestBefore == null || latestBefore.toForeground;
  }

  /// Classify one trace.
  HabotTraceDecision classify(HabotTiming timing) {
    if (timing.elapsed <= Duration.zero) {
      return HabotTraceDecision(
        timing: timing,
        verdict: HabotTraceVerdict.droppedImplausible,
        reason: 'Elapsed time is not positive; the window is not a window.',
      );
    }
    final DateTime end = timing.at;
    final DateTime start = end.subtract(timing.elapsed);
    if (!foregroundThroughout(start, end)) {
      return HabotTraceDecision(
        timing: timing,
        verdict: HabotTraceVerdict.droppedBackgrounded,
        reason: 'The app was backgrounded during the window, so the elapsed '
            'time includes seconds the process spent suspended.',
      );
    }
    if (timing.firstLaunchAfterInstall) {
      return HabotTraceDecision(
        timing: timing,
        verdict: HabotTraceVerdict.divertedFirstLaunch,
        reason: 'First launch after install pays for one-time setup. Real, '
            'and reported separately rather than mixed into the p95.',
      );
    }
    return HabotTraceDecision(
      timing: timing,
      verdict: HabotTraceVerdict.kept,
      reason: 'Foreground throughout.',
    );
  }

  List<HabotTraceDecision> classifyAll(Iterable<HabotTiming> timings) =>
      timings.map(classify).toList();

  /// The naive classifier, kept so the difference is demonstrable rather than
  /// asserted: it trusts the flag on the trace, which describes the state at
  /// capture time.
  static bool naiveKeeps(HabotTiming timing) => timing.foregroundThroughout;

  // ---- the row's metric, read as filter accuracy --------------------------

  /// Accuracy against a known-correct labelling.
  ///
  /// [expected] is what each trace should have been classified as. A filter
  /// is only measurable against ground truth; a rate computed from the
  /// filter's own output would be 1.0 by construction.
  static double accuracy(
    List<HabotTraceDecision> decisions,
    List<HabotTraceVerdict> expected,
  ) {
    if (decisions.isEmpty || decisions.length != expected.length) {
      return 0;
    }
    int correct = 0;
    for (int i = 0; i < decisions.length; i++) {
      if (decisions[i].verdict == expected[i]) {
        correct++;
      }
    }
    return correct / decisions.length;
  }

  /// Counts by verdict. A dropped trace is counted, not discarded silently --
  /// see the header.
  static Map<HabotTraceVerdict, int> tally(
    List<HabotTraceDecision> decisions,
  ) {
    final Map<HabotTraceVerdict, int> out = <HabotTraceVerdict, int>{};
    for (final HabotTraceDecision d in decisions) {
      out[d.verdict] = (out[d.verdict] ?? 0) + 1;
    }
    return out;
  }

  /// The share of traces dropped for being backgrounded. A rising figure is
  /// either a finding about how the app is used or a bug in this filter, and
  /// both are worth seeing.
  static double dropRate(List<HabotTraceDecision> decisions) {
    if (decisions.isEmpty) {
      return 0;
    }
    return decisions
            .where((HabotTraceDecision d) =>
                d.verdict == HabotTraceVerdict.droppedBackgrounded)
            .length /
        decisions.length;
  }

  static const double floor = 0.95;
  static const double optimal = 0.99;
  static const double ceiling = 1.0;

  static String bandFor(double accuracyRate) {
    if (accuracyRate >= optimal) {
      return 'Good';
    }
    return accuracyRate >= floor ? 'Average' : 'Poor';
  }

  static const String metricMismatch =
      'The Atomic Step is about performance traces; the metric names form '
      'field validation accuracy. They have nothing to do with each other. '
      'What the metric SHAPE is good for is an accuracy rate over a '
      'classification, and this step is a classifier -- so it is read as '
      'filter accuracy: the share of traces sorted correctly into kept and '
      'dropped. Recorded rather than the metric being ignored.';

  static const String midWindowNote =
      'Checking "was the app in the foreground?" at capture time passes the '
      'case everyone tests and fails the one that matters. A trace that starts '
      'in the foreground and finishes after the user backgrounded the app '
      'reads as foreground at capture time, and its elapsed time includes '
      'every second the process spent suspended. Those are the traces that '
      'produce a p95 of eleven seconds and a week of investigation into a cold '
      'start that was never slow.';

  static const String countedNotDiscardedNote =
      'A dropped trace is counted. If the drop rate climbs, either the app is '
      'being backgrounded constantly -- itself a finding -- or the filter has '
      'a bug. A filter that leaves no record of what it removed cannot be told '
      'apart from one that removes nothing.';

  static const String groundTruthNote =
      'Accuracy is measured against a known-correct labelling. A rate computed '
      'from the filter\'s own output would be 1.0 by construction and would '
      'measure nothing.';
}
