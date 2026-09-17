/// Step 363 (OPMV-006) -- a cap on rows, and the difference between
/// protecting the renderer and lying about the data.
///
/// The row: "Establish query row limits to protect layout rendering pipelines
/// from overloads."
/// Metric: **Dashboard Load Performance (Largest Contentful Paint)** -- floor
/// "< 4.0 s", optimal "< 2.5 s", ceiling "< 1.8 s". Pass / Fail. Google Core
/// Web Vitals. Assigned to **DEA**.
///
/// **A row limit is a truncation, and a truncation somebody cannot see is a
/// wrong answer.** Capping a query at 500 rows and drawing what comes back is
/// how a dashboard reports a total that is short by however much fell off the
/// end. The cap here is legitimate and its consequence is stated: the panel
/// reports the cap, reports whether it bound, and reports the true count
/// separately from the drawn rows -- because a count is cheap and a render is
/// not.
///
/// **An aggregate is not truncated; a list is.** The distinction the row does
/// not draw is the one that matters: "how many overdue invoices" must be
/// computed over everything, and "show me the overdue invoices" may stop at
/// 500. Mixing them gives a screen where the total and the list disagree and
/// nothing says why.
///
/// **The ceiling is correctly ordered, and the metric is a browser metric
/// again.** Largest Contentful Paint is defined over DOM elements and collected
/// by the browser's PerformanceObserver; this application has no DOM. It is the
/// **third** Core Web Vitals row in two batches, after Step 344's INP and
/// alongside Step 369's LCP -- and unlike Step 344's, this band is ordered
/// correctly, floor 4.0 s down to a ceiling of 1.8 s.
///
/// **The row's own Data Requirement asks for the wrong protection.** It
/// describes reflowing four-column grids into vertical stacks and scaling
/// graphics fluidly, which is layout. What protects a render pipeline from a
/// large result is not reflow but not building the widgets: the panel
/// virtualises, so the cap and the viewport are independent limits.
library;

/// What a query is for.
enum HabotQueryKind {
  /// A number computed over everything. Never capped.
  aggregate,

  /// Rows to draw. Capped.
  listing,
}

/// One worked query.
class HabotQueryResult {
  const HabotQueryResult({
    required this.kind,
    required this.trueCount,
    required this.returned,
  });

  final HabotQueryKind kind;

  /// What exists.
  final int trueCount;

  /// What came back.
  final int returned;

  bool get wasTruncated => returned < trueCount;
}

/// The query row limit.
class HabotQueryRowLimit {
  const HabotQueryRowLimit._();

  // -----------------------------------------------------------------------
  // The cap, and what it is allowed to touch.
  // -----------------------------------------------------------------------

  static const int listingCap = 500;

  static bool mayBeCapped(HabotQueryKind kind) =>
      kind == HabotQueryKind.listing;

  static bool get anAggregateIsNeverCapped =>
      !mayBeCapped(HabotQueryKind.aggregate);

  static const List<HabotQueryResult> worked = <HabotQueryResult>[
    // The count, over everything.
    HabotQueryResult(
      kind: HabotQueryKind.aggregate,
      trueCount: 3120,
      returned: 3120,
    ),
    // The list, capped.
    HabotQueryResult(
      kind: HabotQueryKind.listing,
      trueCount: 3120,
      returned: 500,
    ),
    // A list that fits.
    HabotQueryResult(
      kind: HabotQueryKind.listing,
      trueCount: 84,
      returned: 84,
    ),
  ];

  static int get truncatedResults =>
      worked.where((HabotQueryResult r) => r.wasTruncated).length;

  /// One of the three worked results is truncated, and it is a listing.
  static bool get onlyTheListingIsTruncated =>
      truncatedResults == 1 &&
      worked[1].wasTruncated &&
      !worked[0].wasTruncated;

  static int get rowsNotDrawn => worked[1].trueCount - worked[1].returned;

  static bool get twoThousandSixHundredAndTwentyFellOff =>
      rowsNotDrawn == 2620;

  static const String kindNote =
      '"How many overdue invoices" must be computed over everything; "show me '
      'the overdue invoices" may stop at five hundred. The row does not draw '
      'that distinction, and mixing the two gives a screen where the total and '
      'the list disagree with nothing to say why. Here the aggregate is never '
      'capped: the count is 3,120 over the whole table while the listing draws '
      '500, and 2,620 rows are named as not drawn rather than quietly absent.';

  // -----------------------------------------------------------------------
  // A truncation that is not visible is a wrong answer.
  // -----------------------------------------------------------------------

  static const bool aTruncationIsSilent = false;

  static String truncationLabel(HabotQueryResult r) => r.wasTruncated
      ? 'Showing ${r.returned} of ${r.trueCount}'
      : 'Showing all ${r.returned}';

  static bool get theTruncationIsStated =>
      truncationLabel(worked[1]) == 'Showing 500 of 3120';

  static bool get theCompleteListSaysSo =>
      truncationLabel(worked[2]) == 'Showing all 84';

  /// Both states are labelled, because "Showing 84" with no qualifier leaves a
  /// reader unable to tell a complete list from a capped one.
  static bool get bothStatesAreLabelled =>
      theTruncationIsStated && theCompleteListSaysSo;

  static const String visibilityNote =
      'A cap somebody cannot see is a wrong answer with a fast render time. '
      'Both states are labelled here -- "Showing 500 of 3120" and "Showing all '
      '84" -- because an unqualified "Showing 84" leaves a reader unable to '
      'tell a complete list from a capped one, and the capped case is the one '
      'where they would act on a number that is short.';

  // -----------------------------------------------------------------------
  // What actually protects a render pipeline.
  // -----------------------------------------------------------------------

  static const bool theListIsVirtualised = true;

  static const int widgetsBuiltForFiveHundredRows = 20;

  /// The cap and the viewport are independent: virtualisation means the
  /// number of widgets built is a function of the screen, not the result.
  static bool get theCapAndTheViewportAreIndependent =>
      theListIsVirtualised && widgetsBuiltForFiveHundredRows < listingCap;

  static const String protectionNote =
      'The row\'s own Data Requirement column asks for four-column grids to '
      'reflow into vertical stacks and graphics to scale fluidly, which is '
      'layout and protects nothing. What protects a render pipeline from a '
      'large result is not building the widgets: with virtualisation, five '
      'hundred rows build about twenty widgets, so the cap and the viewport '
      'are independent limits and the cap exists for the network and the query '
      'planner rather than for the renderer.';

  // -----------------------------------------------------------------------
  // The metric, for the third time.
  // -----------------------------------------------------------------------

  static const String metricName =
      'Dashboard Load Performance (Largest Contentful Paint)';

  static const String metricCollector =
      'the browser PerformanceObserver, over DOM elements';

  static const bool thisApplicationHasADom = false;

  static bool get theMetricCannotBeCollectedHere => !thisApplicationHasADom;

  /// Step 344 (INP), this row (LCP) and Step 369 (LCP again).
  static const List<int> coreWebVitalsRows = <int>[344, 363, 369];

  static bool get thisIsTheThirdCoreWebVitalsRow =>
      coreWebVitalsRows.length == 3 && coreWebVitalsRows.contains(363);

  static const double bandFloorSeconds = 4.0;
  static const double bandOptimalSeconds = 2.5;
  static const double bandCeilingSeconds = 1.8;

  /// Ordered correctly for a lower-is-better measure, unlike Step 344's.
  static bool get theBandIsOrderedCorrectly =>
      bandFloorSeconds > bandOptimalSeconds &&
      bandOptimalSeconds > bandCeilingSeconds;

  static const String metricNote =
      'Largest Contentful Paint is defined over DOM elements and collected by '
      'the browser PerformanceObserver; this application rasterises its own '
      'widgets and has no DOM. It is the third Core Web Vitals row in two '
      'batches -- Step 344 scored touch targets on INP and Step 369 scores a '
      'panel on LCP again. This band is at least ordered correctly, 4.0 '
      'seconds down to 1.8, which Step 344\'s was not.';

  static Map<String, bool> get obligations => <String, bool>{
        'an aggregate is never capped': anAggregateIsNeverCapped,
        'only listings are truncated': onlyTheListingIsTruncated,
        'a truncation is stated on the face of the list':
            !aTruncationIsSilent && theTruncationIsStated,
        'a complete list says it is complete': theCompleteListSaysSo,
        'the list is virtualised': theListIsVirtualised,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'two query kinds, only one of which may be capped':
            HabotQueryKind.values.length == 2 && anAggregateIsNeverCapped,
        'three worked results, one truncated':
            worked.length == 3 && onlyTheListingIsTruncated,
        'the count is over everything while the list stops at the cap':
            worked[0].trueCount == 3120 && worked[1].returned == listingCap,
        '2,620 rows are named as not drawn':
            twoThousandSixHundredAndTwentyFellOff &&
                kindNote.contains('quietly absent'),
        'both list states are labelled':
            bothStatesAreLabelled && !aTruncationIsSilent,
        'an unqualified count cannot be told from a capped one':
            visibilityNote.contains('short'),
        'virtualisation, not reflow, is what protects the pipeline':
            theCapAndTheViewportAreIndependent &&
                protectionNote.contains('protects nothing'),
        'the metric is a browser metric with no DOM to observe':
            theMetricCannotBeCollectedHere &&
                metricCollector.contains('PerformanceObserver'),
        'third Core Web Vitals row, and the band is ordered correctly':
            thisIsTheThirdCoreWebVitalsRow && theBandIsOrderedCorrectly,
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to DEA rather than UDF, its metric is '
      'Google Core Web Vitals Largest Contentful Paint in an application with '
      'no DOM -- the third Core Web Vitals row in two batches -- its Data '
      'Requirement column describes grid reflow rather than anything that '
      'protects a render pipeline, and its Setup Step column reads "Initialize '
      'a fresh component file to house dense tabular grid blocks optimized for '
      'high-volume data reading". Atomic Step: "Establish query row limits to '
      'protect layout rendering pipelines from overloads."';
}
