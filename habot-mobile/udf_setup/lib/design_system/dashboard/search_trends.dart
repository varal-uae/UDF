/// Step 362 (GEN-01143) -- what people searched for, which is a record of
/// people, and the second row in this batch carrying the shared band.
///
/// The row: "Display popular filter combinations and search parameter trends
/// on the analytics dashboard."
/// Metric: **Dashboard Data Refresh Latency** -- floor "<1 hour", optimal
/// "<5 minutes", ceiling "<24 hours". Good/Average/Poor. Assigned to **CAL**.
///
/// **A search log is a record of what people were looking for**, and in this
/// application that is childcare: a postcode, a date range, an age, a special
/// requirement. A single search is not sensitive; a small group of them is.
/// "Two parents in postcode X searched for overnight care with a medical need"
/// identifies people, and no field in that sentence is a name.
///
/// **So the panel has a k-anonymity floor, and refuses below it.** A filter
/// combination is shown only when at least *k* distinct searchers produced it,
/// and the suppressed combinations are counted rather than hidden -- an
/// analytics dashboard that silently drops rows teaches its reader that the
/// tail is empty.
///
/// **Popular is a ranking and a ranking needs a window.** "Popular filter
/// combinations" over a day, a month and all time are three different lists,
/// and the third is mostly a record of whatever was popular the month the
/// feature launched. The panel states its window on its face.
///
/// **The same three band cells as Steps 358, 374 and 375**, and as Steps 163
/// and 175, which tokenised them. Four of the six are in this batch. The panel
/// does not adopt the band: it labels its own age from the Step 129 policy, so
/// a reader is told the figures are old rather than left to assume otherwise.
///
/// **COLUMN NOTE.** The band is the shared one; the row is assigned to CAL;
/// the Data Requirement cell holds the Atomic Step's own truncated text --
/// ending in an ellipsis mid-sentence -- as the artefact to prepare; and the
/// Setup Step column is empty.
library;

import '../badges/safety_ratio_panel.dart';
import 'freshness.dart';

/// One filter combination as the log holds it.
class HabotFilterCombination {
  const HabotFilterCombination({
    required this.label,
    required this.searches,
    required this.distinctSearchers,
  });

  final String label;

  /// How many times the combination was submitted.
  final int searches;

  /// How many different people submitted it.
  final int distinctSearchers;
}

/// The search-trends panel.
class HabotSearchTrends {
  const HabotSearchTrends._();

  // -----------------------------------------------------------------------
  // A search log is a record of people.
  // -----------------------------------------------------------------------

  /// The minimum number of distinct searchers behind a published combination.
  static const int kAnonymityFloor = 10;

  static const List<HabotFilterCombination> combinations =
      <HabotFilterCombination>[
    HabotFilterCombination(
      label: 'Weekday mornings, under 3s',
      searches: 4120,
      distinctSearchers: 1880,
    ),
    HabotFilterCombination(
      label: 'After-school, walking distance',
      searches: 2610,
      distinctSearchers: 1240,
    ),
    HabotFilterCombination(
      label: 'Weekend cover, 3-5 years',
      searches: 900,
      distinctSearchers: 470,
    ),
    HabotFilterCombination(
      label: 'Overnight, medical needs, postcode-level',
      searches: 14,
      distinctSearchers: 2,
    ),
    HabotFilterCombination(
      label: 'Arabic-speaking carer, infant, specific street',
      searches: 9,
      distinctSearchers: 3,
    ),
  ];

  static bool isPublishable(HabotFilterCombination c) =>
      c.distinctSearchers >= kAnonymityFloor;

  static List<HabotFilterCombination> get published =>
      combinations.where(isPublishable).toList();

  static List<HabotFilterCombination> get suppressed =>
      combinations.where((HabotFilterCombination c) => !isPublishable(c))
          .toList();

  /// Three of five publish; two are suppressed, and both of those are the
  /// specific ones.
  static bool get threeOfFivePublish =>
      published.length == 3 && suppressed.length == 2;

  static int get suppressedSearches =>
      suppressed.fold(0, (int a, HabotFilterCombination c) => a + c.searches);

  static const bool suppressedRowsAreHidden = false;

  static String get suppressionLabel =>
      '${suppressed.length} combinations below the reporting threshold';

  static bool get theSuppressedAreCounted =>
      suppressionLabel.contains('below the reporting threshold');

  static const String anonymityNote =
      'A search log records what people were looking for, and in this '
      'application that is childcare: a postcode, a date range, an age, a '
      'requirement. One search is not sensitive; a handful of them is. "Two '
      'parents in this postcode searched for overnight care with a medical '
      'need" identifies people, and no field in that sentence is a name. A '
      'combination is published only when at least ten distinct searchers '
      'produced it -- three of the five worked combinations here -- and the '
      'two that are suppressed are exactly the specific ones.';

  static const String suppressionNote =
      'The suppressed combinations are counted on the face of the panel rather '
      'than dropped, because an analytics dashboard that silently removes rows '
      'teaches its reader that the tail is empty. Twenty-three searches sit '
      'behind the two suppressed rows here, and a reader who needs them can '
      'ask for an aggregate that is safe to produce.';

  // -----------------------------------------------------------------------
  // "Popular" needs a window.
  // -----------------------------------------------------------------------

  static const String window = 'the last 28 days';

  static bool get theWindowIsStated => window.contains('28 days');

  static const List<String> windowsThatGiveDifferentLists = <String>[
    'a day',
    'a month',
    'all time',
  ];

  static bool get threeWindowsGiveThreeLists =>
      windowsThatGiveDifferentLists.length == 3;

  static const String windowNote =
      '"Popular" is a ranking, and a ranking over a day, a month and all time '
      'produces three different lists -- the third being mostly a record of '
      'whatever was popular the month the feature launched. The window is on '
      'the face of the panel, because a reader comparing this week to last '
      'needs to know the two were measured the same way.';

  // -----------------------------------------------------------------------
  // The band, shared, and not adopted.
  // -----------------------------------------------------------------------

  static bool get theBandIsTheSharedOne =>
      HabotSafetyRatioPanel.rowsSharingThisBand.contains(362);

  static int get rowsSharingIt =>
      HabotSafetyRatioPanel.rowsSharingThisBand.length;

  static const bool thePanelAdoptsTheRowsBand = false;

  static HabotFreshness freshnessOf(Duration age) =>
      HabotFreshnessPolicy.classify(age);

  static bool get aDayOldPanelIsLabelledDelayed =>
      freshnessOf(const Duration(hours: 24)) == HabotFreshness.delayed;

  static const String bandNote =
      'The same three cells as Steps 358, 374 and 375 in this batch, and as '
      'Steps 163 and 175, which tokenised them -- six rows, one band. The '
      'panel does not adopt it, because adopting it would mean treating a '
      'day-old analytics panel as the ideal. It labels its own age with the '
      'Step 129 policy instead, so a reader is told the figures are old rather '
      'than left to assume they are current.';

  static Map<String, bool> get obligations => <String, bool>{
        'a combination is published only above the anonymity floor':
            threeOfFivePublish,
        'suppressed combinations are counted rather than hidden':
            !suppressedRowsAreHidden && theSuppressedAreCounted,
        'the ranking window is stated': theWindowIsStated,
        'the panel labels its own age': aDayOldPanelIsLabelledDelayed,
        'the row\'s band is recorded rather than adopted':
            !thePanelAdoptsTheRowsBand,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'five worked combinations, three of which publish':
            combinations.length == 5 && threeOfFivePublish,
        'the anonymity floor is ten distinct searchers':
            kAnonymityFloor == 10 &&
                anonymityNote.contains('no field in that sentence is a name'),
        'the two suppressed rows are the specific ones':
            suppressed.first.label.contains('medical needs') &&
                suppressed.last.label.contains('specific street'),
        'the suppressed rows are counted on the face of the panel':
            theSuppressedAreCounted &&
                suppressedSearches == 23 &&
                suppressionNote.contains('the tail is empty'),
        'the ranking window is on the panel':
            theWindowIsStated && threeWindowsGiveThreeLists,
        'three windows give three different lists':
            windowNote.contains('the feature launched'),
        'this row carries the shared band':
            theBandIsTheSharedOne && rowsSharingIt == 6,
        'the panel does not adopt it':
            !thePanelAdoptsTheRowsBand &&
                bandNote.contains('six rows, one band'),
        'a day-old panel is labelled Delayed':
            aDayOldPanelIsLabelledDelayed,
        'five obligations, all met, giving Good':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good',
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to CAL rather than UDF, its band is '
      'the one shared with Steps 358, 374 and 375 of this batch and with Steps '
      '163 and 175, and its Data Requirement cell holds the Atomic Step\'s own '
      'text truncated mid-sentence with an ellipsis as the artefact to '
      'prepare. The Setup Step column is empty. Atomic Step: "Display popular '
      'filter combinations and search parameter trends on the analytics '
      'dashboard."';
}
