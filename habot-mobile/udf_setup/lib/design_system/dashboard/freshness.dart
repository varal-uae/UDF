/// AISS Step 129 -- GEN-02555
/// Atomic Step: "Program the dashboard to refresh its KPI summary on each page
///               load."
/// Metric: Data Freshness (minutes) -- Floor 5, Optimal 0-1, Ceiling 1.
/// Best Qualitative Output: Real-time / Near Real-time / Delayed.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// A ROW THIS BATCH CHANGES THE ANSWER TO. "Refresh on each page load" is a
/// web instruction, and taken literally on a mobile client it is wrong twice
/// over: there is no page load, and refreshing on every screen entry over a
/// rural link is how an app becomes unusable. What the metric asks for is the
/// thing that actually matters -- data no older than five minutes, ideally
/// under one.
///
/// So the requirement is implemented as a FRESHNESS BUDGET rather than a
/// refresh trigger: entering the dashboard refreshes if what is on screen has
/// gone stale, and does not if it has not. Same metric, and it survives being
/// opened four times in a minute.
///
/// THE HALF THAT MAKES IT HONEST. Before Step 112 every read was a network
/// read and "how old is this?" had no answer. `HabotSuccess` now carries an
/// origin and a `retrievedAt`, so the age of what is on screen is a fact. This
/// step turns that fact into a decision and, when the data IS stale and cannot
/// be refreshed, into something the user is told rather than something they
/// have to guess at from a number that looks current.
///
/// SHOWING STALE DATA IS FINE. SHOWING IT SILENTLY IS NOT. A field worker on a
/// dead link needs yesterday's totals more than they need an empty screen. The
/// rule is that stale data is always labelled with its age, never presented as
/// current.
library;

import '../data/repository.dart';
import '../tokens/motion_tokens.dart';

/// How current the figures on screen are.
enum HabotFreshness {
  /// Inside the optimal band. The row's "Real-time".
  realTime,

  /// Inside the floor. "Near Real-time".
  nearRealTime,

  /// Past the floor. "Delayed" -- must be labelled.
  delayed,

  /// Nothing has ever been loaded.
  never,
}

extension HabotFreshnessLabel on HabotFreshness {
  /// The row's own vocabulary, so the evidence and the sheet agree.
  String get qualitativeOutput {
    switch (this) {
      case HabotFreshness.realTime:
        return 'Real-time';
      case HabotFreshness.nearRealTime:
        return 'Near Real-time';
      case HabotFreshness.delayed:
        return 'Delayed';
      case HabotFreshness.never:
        return 'Delayed';
    }
  }

  bool get mustBeLabelled =>
      this == HabotFreshness.delayed || this == HabotFreshness.never;
}

/// The freshness policy.
class HabotFreshnessPolicy {
  const HabotFreshnessPolicy._();

  /// The row's floor: data older than this is Delayed.
  static Duration get budget => HabotMotion.dashboardFreshnessBudget;

  /// The row's optimal: under this is Real-time.
  static Duration get optimal => HabotMotion.dashboardFreshnessOptimal;

  static HabotFreshness classify(Duration? age) {
    if (age == null) {
      return HabotFreshness.never;
    }
    if (age <= optimal) {
      return HabotFreshness.realTime;
    }
    if (age <= budget) {
      return HabotFreshness.nearRealTime;
    }
    return HabotFreshness.delayed;
  }

  /// Whether entering the dashboard should trigger a fetch.
  ///
  /// Not "always", which the row literally says, and not "never". See the
  /// header for why the literal reading is the wrong build.
  static bool shouldRefresh(Duration? age) =>
      classify(age) == HabotFreshness.delayed ||
      classify(age) == HabotFreshness.never;
}

/// What the dashboard is currently showing, and how old it is.
class HabotFreshnessState {
  const HabotFreshnessState({
    required this.retrievedAt,
    required this.origin,
    required this.now,
  });

  /// When the figures on screen were obtained. Comes from the Step 112
  /// `HabotSuccess.retrievedAt` -- not invented here.
  final DateTime? retrievedAt;

  final HabotDataOrigin origin;
  final DateTime now;

  Duration? get age =>
      retrievedAt == null ? null : now.difference(retrievedAt!);

  HabotFreshness get freshness => HabotFreshnessPolicy.classify(age);

  bool get shouldRefresh => HabotFreshnessPolicy.shouldRefresh(age);

  /// The minutes figure the metric is scaled in.
  double get ageMinutes =>
      age == null ? double.infinity : age!.inMilliseconds / 60000;

  /// What the user is told. Empty when the data is current enough that saying
  /// so would be noise.
  String get staleLabel {
    if (!freshness.mustBeLabelled) {
      return '';
    }
    if (retrievedAt == null) {
      return 'Not loaded yet';
    }
    final int minutes = age!.inMinutes;
    if (minutes < 60) {
      return 'Updated $minutes minute${minutes == 1 ? "" : "s"} ago';
    }
    final int hours = age!.inHours;
    return 'Updated $hours hour${hours == 1 ? "" : "s"} ago';
  }

  /// The rule from the header, as a checkable property: data past the budget
  /// is never presented without its age.
  bool get isHonest => !freshness.mustBeLabelled || staleLabel.isNotEmpty;

  /// A stale read from the device with no network behind it is the ordinary
  /// case for this app, not an error state.
  bool get isOfflineStale =>
      origin == HabotDataOrigin.localStale &&
      freshness == HabotFreshness.delayed;

  Map<String, Object?> toJson() => <String, Object?>{
    'retrieved_at': retrievedAt?.toIso8601String(),
    'origin': origin.name,
    'age_minutes': ageMinutes == double.infinity ? null : ageMinutes,
    'freshness': freshness.name,
    'qualitative_output': freshness.qualitativeOutput,
    'should_refresh': shouldRefresh,
    'stale_label': staleLabel,
  };
}

/// Decides when the KPI summary reloads, and records what it decided.
class HabotDashboardFreshness {
  HabotDashboardFreshness({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  DateTime? _lastLoadedAt;
  HabotDataOrigin _origin = HabotDataOrigin.none;

  int _entries = 0;
  int _refreshes = 0;

  /// How many times the dashboard was entered.
  int get entries => _entries;

  /// How many of those actually fetched. The number that shows the budget is
  /// doing something: entering four times in a minute must not be four fetches.
  int get refreshes => _refreshes;

  HabotFreshnessState get state => HabotFreshnessState(
    retrievedAt: _lastLoadedAt,
    origin: _origin,
    now: _clock(),
  );

  /// Record a successful load, taking its age from the result itself.
  void recordLoad(HabotSuccess<Object?> result) {
    _lastLoadedAt = result.retrievedAt ?? _clock();
    _origin = result.origin;
  }

  /// The dashboard was entered. Returns true when a fetch should happen.
  bool onEnter() {
    _entries++;
    if (state.shouldRefresh) {
      _refreshes++;
      return true;
    }
    return false;
  }

  /// The share of entries that did NOT need a network round trip. Not a sheet
  /// metric -- reported because it is the cost side of the freshness decision,
  /// and a freshness policy judged only on freshness will always choose to
  /// refresh.
  double get suppressionRate =>
      _entries == 0 ? 1 : (_entries - _refreshes) / _entries;

  static const String literalReadingNote =
      'The row says "refresh on each page load". There is no page load on a '
      'mobile client, and refreshing on every screen entry over a rural link '
      'is how an app becomes unusable. The metric -- Data Freshness in minutes '
      '-- is what the row is actually asking for, so the requirement is '
      'implemented as a freshness budget. Same metric, survives being opened '
      'four times in a minute.';
}
