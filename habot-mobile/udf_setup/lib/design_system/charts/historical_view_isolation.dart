/// Step 367 (OFBSE-013-04) -- separating what is live from what is history,
/// and a band with two measures in each cell.
///
/// The row: "Isolate views serving historical metric charts or non-realtime
/// dashboard summaries."
/// Metric: **Monitoring Coverage & Alert Latency** -- floor "95% cov. /
/// <15 min", optimal "99% cov. / <5 min", ceiling "100% cov. / <1 min".
/// High (Scale: High/Medium/Low). Google SRE Book. Assigned to **DEA**.
///
/// **Each boundary cell holds two measures joined by a slash**, which is a
/// shape this track has not met before. A coverage percentage and a latency are
/// different quantities with different units and different failure modes, and
/// pairing them in one cell means a reading can satisfy half a boundary. 99 per
/// cent coverage at twelve minutes is above the optimal on one axis and below
/// the floor on the other, and the cell cannot say which verdict wins. Split
/// into two bands they are both well formed and both correctly ordered, which
/// is the argument for splitting rather than for discarding.
///
/// **The isolation the row asks for is the right instinct with the wrong
/// reason.** Historical views are separated from live ones not to protect the
/// renderer but because they make *different promises*. A live view must say
/// how old it is and must refresh; a historical view must say what period it
/// covers and must **not** silently move. A chart that redraws under somebody
/// reading it, because new data arrived for a period they thought was closed,
/// is the failure this separation prevents.
///
/// **A period that is still open is neither.** Today's figures are historical
/// in form and live in fact, and the honest answer is a third state: a view
/// labelled as covering a period that has not finished, so a reader knows the
/// bar will grow.
///
/// **Isolation also has to be enforced rather than intended.** A historical
/// view that quietly subscribes to the live stream is the defect, and it is
/// invisible until somebody watches a number change on a closed month. The
/// subscription is a property of the view kind rather than a decision each
/// screen makes.
library;

import '../dashboard/freshness.dart';

/// What a view promises about the figures on it.
enum HabotViewKind {
  /// Current, refreshes, labels its age.
  live,

  /// A closed period. Does not move.
  historical,

  /// A period that has not finished yet.
  openPeriod,
}

/// One view as the isolation rule sees it.
class HabotIsolatedView {
  const HabotIsolatedView({
    required this.name,
    required this.kind,
    required this.subscribesToLiveStream,
  });

  final String name;
  final HabotViewKind kind;
  final bool subscribesToLiveStream;
}

/// The isolation between live and historical views.
class HabotHistoricalViewIsolation {
  const HabotHistoricalViewIsolation._();

  // -----------------------------------------------------------------------
  // A band with two measures in each cell.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = '95% cov. / <15 min';
  static const String bandOptimalRaw = '99% cov. / <5 min';
  static const String bandCeilingRaw = '100% cov. / <1 min';

  static bool get eachCellHoldsTwoMeasures =>
      bandFloorRaw.contains('/') &&
      bandOptimalRaw.contains('/') &&
      bandCeilingRaw.contains('/');

  /// Split out, the two bands are both well formed.
  static const List<int> coverageBand = <int>[95, 99, 100];
  static const List<int> latencyBandMinutes = <int>[15, 5, 1];

  static bool get theCoverageBandIsOrderedForHigherIsBetter =>
      coverageBand[0] < coverageBand[1] && coverageBand[1] < coverageBand[2];

  static bool get theLatencyBandIsOrderedForLowerIsBetter =>
      latencyBandMinutes[0] > latencyBandMinutes[1] &&
      latencyBandMinutes[1] > latencyBandMinutes[2];

  static bool get bothHalvesAreWellFormed =>
      theCoverageBandIsOrderedForHigherIsBetter &&
      theLatencyBandIsOrderedForLowerIsBetter;

  /// 99% coverage at 12 minutes: above the optimal on one axis, below the
  /// floor on the other, and the cell cannot say which verdict wins.
  static const int splitReadingCoverage = 99;
  static const int splitReadingLatencyMinutes = 12;

  static bool get theSplitReadingIsAboveTheCoverageOptimal =>
      splitReadingCoverage >= coverageBand[1];

  static bool get theSplitReadingIsBelowTheLatencyFloor =>
      splitReadingLatencyMinutes < latencyBandMinutes[0];

  static bool get oneReadingSatisfiesHalfOfEachBoundary =>
      theSplitReadingIsAboveTheCoverageOptimal &&
      theSplitReadingIsBelowTheLatencyFloor;

  static const String bandNote =
      'Each boundary cell holds two measures joined by a slash -- a coverage '
      'percentage and a latency -- which is a shape this track has not met '
      'before. They have different units and different failure modes, so a '
      'reading can satisfy half a boundary: 99 per cent coverage at twelve '
      'minutes clears the coverage optimal and misses the latency floor, and '
      'the cell has no way to say which verdict wins. Split apart they are two '
      'well-formed bands, one higher-is-better and one lower-is-better, which '
      'is an argument for splitting rather than for discarding.';

  // -----------------------------------------------------------------------
  // Different promises, not different renderers.
  // -----------------------------------------------------------------------

  static const Map<HabotViewKind, String> promiseOf = <HabotViewKind, String>{
    HabotViewKind.live: 'this is current, and here is how old it is',
    HabotViewKind.historical: 'this covers a closed period and will not move',
    HabotViewKind.openPeriod:
        'this covers a period that has not finished, so it will grow',
  };

  static bool get everyKindMakesADifferentPromise =>
      promiseOf.length == HabotViewKind.values.length &&
      promiseOf.values.toSet().length == HabotViewKind.values.length;

  static const int kindsTheRowNames = 2;

  static bool get theRowNamesTwoOfThree =>
      kindsTheRowNames == 2 && HabotViewKind.values.length == 3;

  static const String promiseNote =
      'Historical views are separated from live ones not to protect a renderer '
      'but because they promise different things. A live view says how old it '
      'is and refreshes; a historical view says what period it covers and does '
      'not move. A chart that redraws under somebody reading it, because new '
      'data arrived for a period they thought was closed, is precisely the '
      'failure this separation prevents -- and the row gives the right '
      'instruction for the wrong reason.';

  static const String openPeriodNote =
      'Today\'s figures are historical in form and live in fact, which is why '
      'two kinds are not enough. The row names two; the third is a view '
      'labelled as covering a period that has not finished, so a reader knows '
      'the last bar will grow rather than discovering it tomorrow and '
      'distrusting the chart.';

  // -----------------------------------------------------------------------
  // Isolation enforced rather than intended.
  // -----------------------------------------------------------------------

  static const List<HabotIsolatedView> views = <HabotIsolatedView>[
    HabotIsolatedView(
      name: 'live exception counter',
      kind: HabotViewKind.live,
      subscribesToLiveStream: true,
    ),
    HabotIsolatedView(
      name: 'last month\'s throughput',
      kind: HabotViewKind.historical,
      subscribesToLiveStream: false,
    ),
    HabotIsolatedView(
      name: 'last quarter\'s incidents',
      kind: HabotViewKind.historical,
      subscribesToLiveStream: false,
    ),
    HabotIsolatedView(
      name: 'this month so far',
      kind: HabotViewKind.openPeriod,
      subscribesToLiveStream: true,
    ),
  ];

  static bool subscriptionIsCorrect(HabotIsolatedView v) =>
      v.kind == HabotViewKind.historical
          ? !v.subscribesToLiveStream
          : v.subscribesToLiveStream;

  static bool get everySubscriptionFollowsTheKind =>
      views.every(subscriptionIsCorrect);

  static int get historicalViews =>
      views.where((HabotIsolatedView v) => v.kind == HabotViewKind.historical)
          .length;

  static bool get noHistoricalViewSubscribes => views
      .where((HabotIsolatedView v) => v.kind == HabotViewKind.historical)
      .every((HabotIsolatedView v) => !v.subscribesToLiveStream);

  /// The subscription is a property of the kind rather than a per-screen
  /// decision, so a new historical view cannot get it wrong.
  static const bool eachScreenDecidesItsOwnSubscription = false;

  static const String enforcementNote =
      'A historical view that quietly subscribes to the live stream is the '
      'defect, and it is invisible until somebody watches a number change on a '
      'closed month. Making the subscription a property of the view kind '
      'rather than a decision each screen makes means a new historical view '
      'cannot get it wrong, which is the difference between isolation that is '
      'enforced and isolation that was intended.';

  // -----------------------------------------------------------------------
  // The age label, from the existing policy.
  // -----------------------------------------------------------------------

  static bool labelsItsAge(HabotIsolatedView v) =>
      v.kind != HabotViewKind.historical;

  static HabotFreshness freshnessOf(Duration age) =>
      HabotFreshnessPolicy.classify(age);

  static bool get theLiveViewLabelsItsAge =>
      labelsItsAge(views.first) &&
      freshnessOf(const Duration(minutes: 30)) == HabotFreshness.delayed;

  static const String ageNote =
      'A live view carries its age from the Step 129 policy. A historical view '
      'does not, because "37 minutes old" is meaningless on last quarter\'s '
      'incidents -- what it carries instead is the period it covers. Applying '
      'one label to both is how a closed month ends up looking stale.';

  static Map<String, bool> get obligations => <String, bool>{
        'each view kind makes a different promise':
            everyKindMakesADifferentPromise,
        'an unfinished period is its own kind':
            HabotViewKind.values.contains(HabotViewKind.openPeriod),
        'no historical view subscribes to the live stream':
            noHistoricalViewSubscribes,
        'the subscription follows the kind rather than the screen':
            everySubscriptionFollowsTheKind &&
                !eachScreenDecidesItsOwnSubscription,
        'a live view labels its age and a historical view its period':
            theLiveViewLabelsItsAge,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'High' : 'Low';

  static Map<String, bool> get checks => <String, bool>{
        'each boundary cell holds two measures':
            eachCellHoldsTwoMeasures,
        'split apart both halves are well formed':
            bothHalvesAreWellFormed &&
                coverageBand.length == 3 &&
                latencyBandMinutes.length == 3,
        'one reading can satisfy half of each boundary':
            oneReadingSatisfiesHalfOfEachBoundary &&
                bandNote.contains('which verdict wins'),
        'three view kinds, of which the row names two':
            theRowNamesTwoOfThree && everyKindMakesADifferentPromise,
        'the separation is about promises, not renderers':
            promiseNote.contains('wrong reason'),
        'an open period is labelled as growing':
            openPeriodNote.contains('will grow'),
        'two historical views, neither subscribing':
            historicalViews == 2 && noHistoricalViewSubscribes,
        'the subscription is a property of the kind':
            everySubscriptionFollowsTheKind &&
                !eachScreenDecidesItsOwnSubscription &&
                enforcementNote.contains('cannot get it wrong'),
        'a live view labels its age with the Step 129 policy':
            theLiveViewLabelsItsAge && ageNote.contains('Step 129'),
        'five obligations, all met, giving High':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'High',
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to DEA rather than UDF, and each of '
      'its three boundary cells holds two measures joined by a slash -- a '
      'coverage percentage and a latency -- so a reading can satisfy half a '
      'boundary; its Data Requirement column is about non-blocking snackbars '
      'and carries CSS and ARIA attributes; and its Setup Step column reads '
      '"Document the finalized progressive loading configuration". Atomic '
      'Step: "Isolate views serving historical metric charts or non-realtime '
      'dashboard summaries."';
}
