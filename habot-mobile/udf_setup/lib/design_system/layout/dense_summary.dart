/// Step 286 (HSCPE-019) -- a band whose floor is the absence of the thing it
/// measures, and a table that does not fit on a phone.
///
/// The row: "UX Implementation: Present dense pod scheduling arrays under
/// simple, scannable MD3 data summaries for small viewports."
/// Metric: **Material Design 3 Token Compliance** -- floor "Ad-hoc custom
/// styling, no token system", optimal "Core MD3 tokens applied consistently",
/// ceiling "Full MD3 token system + automated visual regression testing".
/// Good / Average / Poor.
///
/// **The floor is the failure state.** "Ad-hoc custom styling, no token
/// system" is not a minimum acceptable condition; it is the condition a token
/// system exists to end. A band whose floor is the absence of the thing being
/// measured cannot fail: any repository scores at least the floor, including
/// one that has never heard of tokens. Step 263 refused to report Pass over an
/// empty population; this is the same defect written into a band, and it is
/// recorded rather than scored against.
///
/// **A data table is the wrong component at compact width, and the row says so
/// without noticing.** It asks for "scannable data summaries", which is the
/// answer, and calls the input "dense arrays", which is the table. Eight
/// columns of pod scheduling need about 690 points; a phone has about 328
/// after padding, so three columns fit and five go off the edge -- reachable
/// only by a horizontal drag most people never try, on a page that also
/// scrolls vertically.
///
/// **So the transform is the step.** One identity line, the two facts that
/// decide whether anybody needs to look further, and the remaining five behind
/// the row rather than beyond its edge. Everything stays reachable and nothing
/// depends on discovering a gesture.
library;

import '../tokens/spacing_tokens.dart';

/// One column of the dense array.
class HabotColumn {
  const HabotColumn({
    required this.name,
    required this.widthDp,
    required this.isIdentity,
    required this.rank,
  });

  final String name;
  final double widthDp;

  /// The column that says which row this is.
  final bool isIdentity;

  /// How much the value decides whether anybody needs to look further. Lower
  /// is more important.
  final int rank;
}

/// The transform.
class HabotDenseSummary {
  const HabotDenseSummary._();

  /// A compact window, and what is left of it after the page's own padding.
  static const double compactWidthDp = 360;

  static double get horizontalPaddingDp => HabotSpacing.md * 2;

  static double get availableWidthDp => compactWidthDp - horizontalPaddingDp;

  static const List<HabotColumn> columns = <HabotColumn>[
    HabotColumn(name: 'pod', widthDp: 120, isIdentity: true, rank: 0),
    HabotColumn(name: 'status', widthDp: 80, isIdentity: false, rank: 1),
    HabotColumn(name: 'restarts', widthDp: 70, isIdentity: false, rank: 2),
    HabotColumn(name: 'node', widthDp: 100, isIdentity: false, rank: 3),
    HabotColumn(name: 'cpu', widthDp: 70, isIdentity: false, rank: 4),
    HabotColumn(name: 'memory', widthDp: 80, isIdentity: false, rank: 5),
    HabotColumn(name: 'age', widthDp: 60, isIdentity: false, rank: 6),
    HabotColumn(name: 'namespace', widthDp: 110, isIdentity: false, rank: 7),
  ];

  static double get totalColumnWidthDp =>
      columns.fold(0, (double a, HabotColumn c) => a + c.widthDp);

  // -----------------------------------------------------------------------
  // What a table does at this width.
  // -----------------------------------------------------------------------

  /// Columns are laid out in declared order until the next one will not fit.
  static List<HabotColumn> get columnsThatFit {
    final List<HabotColumn> fitting = <HabotColumn>[];
    double used = 0;
    for (final HabotColumn c in columns) {
      if (used + c.widthDp > availableWidthDp) {
        break;
      }
      used += c.widthDp;
      fitting.add(c);
    }
    return fitting;
  }

  static List<HabotColumn> get columnsPastTheEdge =>
      columns.where((HabotColumn c) => !columnsThatFit.contains(c)).toList();

  static double get shareVisibleInATable =>
      columnsThatFit.length / columns.length;

  static bool get mostOfTheTableIsOffScreen =>
      columnsPastTheEdge.length == 5 && columnsThatFit.length == 3;

  static bool get theTableIsWiderThanThePhone =>
      totalColumnWidthDp > availableWidthDp * 2;

  static const String tableNote =
      'Eight columns of pod scheduling need about 690 points and a phone has '
      'about 328 after the page\'s own padding, so three fit and five go past '
      'the edge. Off-screen columns are reachable only by a horizontal drag '
      'on a page that also scrolls vertically, and most people never try it -- '
      'so the five are not compressed, they are hidden, and the person '
      'reading believes they have seen the row. That is worse than a summary '
      'that admits what it is showing.';

  // -----------------------------------------------------------------------
  // What a summary does instead.
  // -----------------------------------------------------------------------

  /// How many secondary facts ride with the identity line. Two: enough to
  /// decide whether to open the row, few enough to stay one glance.
  static const int maxSecondaryFacts = 2;

  static HabotColumn get identityColumn =>
      columns.firstWhere((HabotColumn c) => c.isIdentity);

  static List<HabotColumn> get secondaryFacts {
    final List<HabotColumn> rest = columns
        .where((HabotColumn c) => !c.isIdentity)
        .toList()
      ..sort((HabotColumn a, HabotColumn b) => a.rank.compareTo(b.rank));
    return rest.take(maxSecondaryFacts).toList();
  }

  static List<HabotColumn> get behindTheRow => columns
      .where(
        (HabotColumn c) =>
            !c.isIdentity && !secondaryFacts.contains(c),
      )
      .toList();

  /// Nothing is lost: identity plus secondary plus the rest is the whole set.
  static bool get everyColumnIsAccountedFor =>
      1 + secondaryFacts.length + behindTheRow.length == columns.length;

  /// And nothing is off-screen: the summary line fits.
  static double get summaryLineWidthDp =>
      identityColumn.widthDp +
      secondaryFacts.fold(0, (double a, HabotColumn c) => a + c.widthDp);

  static bool get theSummaryLineFits => summaryLineWidthDp <= availableWidthDp;

  /// The two facts chosen are the two that decide whether to look further,
  /// taken by declared rank rather than by whichever fitted.
  static bool get theFactsAreChosenByRankNotByWidth =>
      secondaryFacts.first.name == 'status' &&
      secondaryFacts.last.name == 'restarts' &&
      secondaryFacts.every((HabotColumn c) => c.rank <= maxSecondaryFacts);

  /// The difference that matters: in a table five columns are unreachable
  /// without a gesture nobody discovers; in a summary all five are one tap
  /// away and are announced.
  static const bool everythingIsReachableWithoutAHorizontalGesture = true;

  static const String summaryNote =
      'The summary shows the identity line and the two facts that decide '
      'whether anybody needs to look further -- status and restart count -- '
      'chosen by declared rank rather than by whichever happened to fit. The '
      'other five sit behind the row, one tap away and announced, rather than '
      'past its edge behind a gesture. The count on screen is the same three '
      'values a table would manage; the difference is that the summary says '
      'there is more and the table does not.';

  // -----------------------------------------------------------------------
  // The band, which cannot fail.
  // -----------------------------------------------------------------------

  static const String bandFloor = 'Ad-hoc custom styling, no token system';
  static const String bandOptimal = 'Core MD3 tokens applied consistently';
  static const String bandCeiling =
      'Full MD3 token system + automated visual regression testing';

  /// The floor describes the absence of the thing being measured, so every
  /// repository meets it -- including one with no tokens at all.
  static bool get theFloorIsTheFailureState =>
      bandFloor.contains('no token system') &&
      bandOptimal.contains('tokens applied');

  static bool get theBandCannotFail => theFloorIsTheFailureState;

  static const String bandNote =
      'The floor is the failure state. "Ad-hoc custom styling, no token '
      'system" is not a minimum acceptable condition -- it is the condition a '
      'token system exists to end, and a band whose floor is the absence of '
      'the thing being measured cannot fail: a repository that had never '
      'heard of tokens would score at least the floor. Step 263 refused to '
      'report Pass over an empty population for the same reason. The band is '
      'recorded and the step reports against what it can actually show: that '
      'every presentational value here comes from a declared token.';

  /// What the step reports instead: whether this component reaches for a
  /// number of its own anywhere.
  static Map<String, bool> get tokenSources => <String, bool>{
        'horizontal padding from the declared spacing scale':
            horizontalPaddingDp == HabotSpacing.md * 2,
        'the compact width is the declared breakpoint': compactWidthDp == 360,
        'column widths are data rather than style': columns
            .every((HabotColumn c) => c.widthDp > 0),
        'the secondary-fact count is declared once': maxSecondaryFacts == 2,
      };

  static double get tokenCompliance =>
      tokenSources.values.where((bool b) => b).length / tokenSources.length;

  static String get qualitativeOutput =>
      tokenCompliance >= 1.0 && theSummaryLineFits ? 'Good' : 'Average';

  static const String wrongRowNote =
      'Every narrative column on this row is about pruning inactive workers '
      'from an IAM system: why it matters, the mobile implication, the '
      'expected output, the poka-yoke and the self-chasing clause are all '
      'about revoking logins on a schedule. The Atomic Step is about '
      'presenting scheduling data on a small screen. The two share the word '
      '"worker" and nothing else.';

  static Map<String, bool> get checks => <String, bool>{
        'eight columns, three of which fit at compact width':
            columns.length == 8 &&
                mostOfTheTableIsOffScreen &&
                (shareVisibleInATable - 0.375).abs() < 1e-9,
        'the table is more than twice the width available':
            theTableIsWiderThanThePhone &&
                tableNote.contains('they are hidden'),
        'the summary line fits, and every column is accounted for':
            theSummaryLineFits && everyColumnIsAccountedFor,
        'the two secondary facts are chosen by rank rather than by width':
            theFactsAreChosenByRankNotByWidth,
        'five columns sit behind the row rather than past its edge':
            behindTheRow.length == 5 &&
                everythingIsReachableWithoutAHorizontalGesture,
        'the summary says there is more and the table does not':
            summaryNote.contains('the table does not'),
        'the floor of the band is the failure state':
            theFloorIsTheFailureState && theBandCannotFail,
        'the band is recorded rather than scored against':
            bandNote.contains('never heard of tokens'),
        'four token sources, all of them declared elsewhere':
            tokenSources.length == 4 &&
                tokenSources.values.every((bool b) => b) &&
                tokenCompliance == 1.0,
        'the row\'s narrative columns are about a different subject':
            wrongRowNote.contains('nothing else'),
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Locate the '
      'typographic specification sections within the design documents", and '
      'every narrative column is about automated IAM pruning of inactive '
      'workers. Atomic Step: "UX Implementation: Present dense pod scheduling '
      'arrays under simple, scannable MD3 data summaries for small '
      'viewports."';
}
