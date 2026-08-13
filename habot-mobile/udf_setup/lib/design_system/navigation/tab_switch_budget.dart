/// AISS: GEN-01474-A01 -- "Benchmark tab switching latency to ensure view
/// rendering completes under 200ms."
///
/// METRIC MISMATCH, RECORDED: the row's Metric Name is "Information
/// Architecture Task Success Rate" (Floor 0.8), which is a usability-study
/// measure -- you get it by watching people try to find things, not by timing a
/// render. The number this step actually names is in the Setup Step itself:
/// **200ms**. That is what is gated, and the mismatch is recorded rather than
/// quietly reinterpreted.
///
/// The budget is not a new number either. `HabotMotion.interactiveCeiling` was
/// set at 200ms in Step 11 for exactly this reason -- anything the user waits
/// on. Declaring a second 200ms here would create two places to change it.
library;

import '../tokens/motion_tokens.dart';

/// One recorded switch between destinations.
class HabotTabSwitchSample {
  const HabotTabSwitchSample({
    required this.from,
    required this.to,
    required this.duration,
  });

  final String from;
  final String to;
  final Duration duration;

  bool get withinBudget => duration <= HabotTabSwitchBudget.ceiling;
}

/// The budget, and the record of what was measured against it.
class HabotTabSwitchBudget {
  HabotTabSwitchBudget({Stopwatch? clock}) : _clock = clock ?? Stopwatch();

  /// "under 200ms" -- the interactive ceiling the motion tokens already set.
  static const Duration ceiling = HabotMotion.interactiveCeiling;

  final Stopwatch _clock;
  final List<HabotTabSwitchSample> _samples = <HabotTabSwitchSample>[];
  String? _pendingFrom;
  String? _pendingTo;

  List<HabotTabSwitchSample> get samples =>
      List<HabotTabSwitchSample>.unmodifiable(_samples);

  /// Call when a destination change starts.
  void begin({required String from, required String to}) {
    _pendingFrom = from;
    _pendingTo = to;
    _clock
      ..reset()
      ..start();
  }

  /// Call when the new destination has finished rendering. Returns the sample.
  HabotTabSwitchSample end() {
    _clock.stop();
    final HabotTabSwitchSample sample = HabotTabSwitchSample(
      from: _pendingFrom ?? 'unknown',
      to: _pendingTo ?? 'unknown',
      duration: _clock.elapsed,
    );
    _samples.add(sample);
    _pendingFrom = null;
    _pendingTo = null;
    return sample;
  }

  /// Records a switch measured elsewhere -- by a widget test driving frames,
  /// for instance, where a wall clock measures the test host rather than the
  /// app.
  HabotTabSwitchSample record({
    required String from,
    required String to,
    required Duration duration,
  }) {
    final HabotTabSwitchSample sample = HabotTabSwitchSample(
      from: from,
      to: to,
      duration: duration,
    );
    _samples.add(sample);
    return sample;
  }

  bool get allWithinBudget =>
      _samples.every((HabotTabSwitchSample s) => s.withinBudget);

  Duration get worst => _samples.isEmpty
      ? Duration.zero
      : _samples
            .map((HabotTabSwitchSample s) => s.duration)
            .reduce((Duration a, Duration b) => a > b ? a : b);

  /// The share of switches inside the budget, as a percentage. This is the
  /// number worth reporting: one slow switch out of two hundred is a different
  /// problem from every switch being slow.
  double get passRate => _samples.isEmpty
      ? 100
      : (_samples.where((HabotTabSwitchSample s) => s.withinBudget).length /
                _samples.length) *
            100;

  void reset() {
    _samples.clear();
    _pendingFrom = null;
    _pendingTo = null;
  }
}
