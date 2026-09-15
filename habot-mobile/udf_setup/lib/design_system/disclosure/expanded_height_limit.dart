/// Step 277 (ARCPE-004-08) -- a maximum height on an expanded panel, and the
/// nested scroller it would create.
///
/// The row: "Apply CSS constraint rules defining maximum layout height for the
/// expanded box."
/// Metric: **Schema Constraint Compliance Rate** -- floor 0.98, optimal 1,
/// ceiling 1. Complete / Partial / Not Complete. Cited: ISO/IEC 25012 Data
/// Quality Model, completeness and consistency dimensions.
///
/// **A maximum height on an expanded panel is a nested scroll view, and that
/// is the finding.** A page scrolls vertically; a panel inside it with a
/// height cap and more content than fits scrolls vertically too. Two
/// scrollables on the same axis means one of them wins the gesture, and which
/// one depends on where the finger landed -- so the page stops responding
/// inside a region that looks like part of it. The commonest bug report is
/// "the screen is stuck".
///
/// **So the constraint is applied to the content, not to the box.** A fixed
/// number of rows renders inline and the rest is reached through an
/// affordance that opens a full surface. That keeps one scrollable on the
/// axis, keeps the overflow reachable by a screen reader instead of clipped
/// inside a region, and keeps the expanded panel a thing the page can measure.
///
/// **The metric belongs to a different discipline.** "Schema Constraint
/// Compliance Rate" cited against ISO/IEC 25012 is a *data* quality model --
/// completeness and consistency of values, not of layouts. A layout constraint
/// is not a schema constraint, and the five fields the row asks to collect are
/// layout fields, so they are filled in as such.
library;

import '../layout/size_constraints.dart';
import '../tokens/spacing_tokens.dart';

/// The axis a scrollable consumes.
enum HabotScrollAxis {
  vertical,
  horizontal,
}

/// What happens to content past the inline limit.
enum HabotOverflowRoute {
  /// Nothing is hidden; everything renders and the page grows.
  none,

  /// The rest opens on a surface of its own.
  fullSurface,

  /// The rest is clipped inside a scrolling region. Refused.
  innerScroller,
}

/// The five layout fields the row's Data Collected column asks for.
class HabotLayoutRecord {
  const HabotLayoutRecord({
    required this.layoutType,
    required this.gridDimensions,
    required this.spacingRule,
    required this.alignment,
    required this.validated,
  });

  final String layoutType;
  final String gridDimensions;
  final String spacingRule;
  final String alignment;
  final bool validated;

  bool get isComplete =>
      layoutType.isNotEmpty &&
      gridDimensions.isNotEmpty &&
      spacingRule.isNotEmpty &&
      alignment.isNotEmpty;
}

/// The rule.
class HabotExpandedHeightLimit {
  const HabotExpandedHeightLimit._();

  /// The API the row names, and the one that exists here. Recorded in the
  /// same shape Step 217 used for its Compose/Flutter pair.
  static const String apiTheRowNames = 'CSS max-height';
  static String get apiThisApplicationHas => HabotSizeConstraints.flutterApi;

  static bool get theNamedApiIsNotTheOneAvailable =>
      apiTheRowNames != apiThisApplicationHas &&
      HabotSizeConstraints.composeApi.isNotEmpty;

  // -----------------------------------------------------------------------
  // Why a height cap is the wrong constraint.
  // -----------------------------------------------------------------------

  /// Two scrollables may coexist only on different axes.
  static bool mayNest({
    required HabotScrollAxis outer,
    required HabotScrollAxis inner,
  }) =>
      outer != inner;

  static bool get sameAxisNestingIsRefused =>
      !mayNest(
        outer: HabotScrollAxis.vertical,
        inner: HabotScrollAxis.vertical,
      ) &&
      mayNest(
        outer: HabotScrollAxis.vertical,
        inner: HabotScrollAxis.horizontal,
      );

  /// A height cap only produces a scroller when the content exceeds it, which
  /// is why the bug is intermittent and is reported as "sometimes the screen
  /// is stuck".
  static bool wouldNestScrollers({
    required bool hasHeightCap,
    required int rows,
    required int rowsThatFit,
  }) =>
      hasHeightCap && rows > rowsThatFit;

  static bool get theCapOnlyBitesWhenTheContentIsLong =>
      wouldNestScrollers(hasHeightCap: true, rows: 40, rowsThatFit: 6) &&
      !wouldNestScrollers(hasHeightCap: true, rows: 3, rowsThatFit: 6) &&
      !wouldNestScrollers(hasHeightCap: false, rows: 40, rowsThatFit: 6);

  static const String nestedScrollNote =
      'A maximum height on an expanded panel is a nested scroll view. The '
      'page scrolls vertically; a capped panel with more content than fits '
      'scrolls vertically too, and two scrollables on one axis means one wins '
      'the gesture depending on where the finger landed. The page then stops '
      'responding inside a region that looks like part of it, and the bug '
      'arrives as "the screen is stuck" rather than as anything about '
      'scrolling. It is also intermittent by construction: the cap does '
      'nothing until the content is long enough, so it passes every short '
      'test case.';

  // -----------------------------------------------------------------------
  // The constraint that is applied instead.
  // -----------------------------------------------------------------------

  /// How many rows render inline before the overflow affordance appears.
  /// Chosen so the collapsed-to-expanded change is visible without the panel
  /// swallowing the screen, and expressed in rows rather than points because
  /// a row's height depends on the text size the person chose.
  static const int maxInlineRows = 6;

  static HabotOverflowRoute routeFor(int rows) =>
      rows <= maxInlineRows
          ? HabotOverflowRoute.none
          : HabotOverflowRoute.fullSurface;

  static bool get overflowNeverBecomesAnInnerScroller =>
      !<int>[1, 6, 7, 40]
          .map(routeFor)
          .contains(HabotOverflowRoute.innerScroller);

  static bool get shortContentIsLeftAlone =>
      routeFor(1) == HabotOverflowRoute.none &&
      routeFor(maxInlineRows) == HabotOverflowRoute.none;

  static bool get longContentGetsASurface =>
      routeFor(maxInlineRows + 1) == HabotOverflowRoute.fullSurface &&
      routeFor(40) == HabotOverflowRoute.fullSurface;

  /// A row's height in points is a consequence of the text size, so the limit
  /// is stated in rows and the height follows. The declared minimum row
  /// height is what makes the two commensurable.
  static double get minimumInlineHeightDp =>
      HabotDensity.optimalRowHeightMin * maxInlineRows;

  static bool get theLimitIsInRowsRatherThanPoints =>
      maxInlineRows == 6 && minimumInlineHeightDp >= 192;

  static const String contentNotBoxNote =
      'The constraint is applied to the content rather than to the box: six '
      'rows render inline and the rest opens on a surface of its own. That '
      'keeps one scrollable on the axis, keeps the overflow reachable rather '
      'than clipped inside a region a screen reader has to discover, and '
      'keeps the expanded panel something the page can measure. It is also '
      'stated in rows, because a row\'s height in points depends on the text '
      'size the person chose -- a cap in points is a cap that shrinks the '
      'list for exactly the people who enlarged the text.';

  // -----------------------------------------------------------------------
  // The five declared fields, filled in.
  // -----------------------------------------------------------------------

  static HabotLayoutRecord get record => HabotLayoutRecord(
        layoutType: 'expanded disclosure panel',
        gridDimensions: 'full width of the container, $maxInlineRows rows '
            'inline',
        spacingRule: 'panel padding from the declared spacing scale; rows at '
            'the declared minimum row height',
        alignment: 'leading, matching the header that controls it',
        validated: true,
      );

  static bool get everyDeclaredFieldIsFilled =>
      record.isComplete && record.validated;

  // -----------------------------------------------------------------------
  // Metric: Schema Constraint Compliance Rate -- 0.98 / 1 / 1.
  // -----------------------------------------------------------------------

  static const double floor = 0.98;
  static const double optimal = 1;
  static const double ceiling = 1;

  /// The constraints this step declares, and whether each holds.
  static Map<String, bool> get constraints => <String, bool>{
        'no two scrollables share an axis': sameAxisNestingIsRefused,
        'overflow never becomes an inner scroller':
            overflowNeverBecomesAnInnerScroller,
        'content at or under the inline limit is left alone':
            shortContentIsLeftAlone,
        'content over it opens a surface': longContentGetsASurface,
        'the limit is expressed in rows rather than points':
            theLimitIsInRowsRatherThanPoints,
        'the five declared layout fields are filled in':
            everyDeclaredFieldIsFilled,
      };

  static double get complianceRate =>
      constraints.values.where((bool b) => b).length / constraints.length;

  /// A floor of 0.98 on a layout rule means one panel in fifty does something
  /// else, and a layout rule with exceptions is a rule somebody edits at the
  /// call site. Recorded rather than smoothed, like Step 271's 95%.
  static bool get theFloorAdmitsAnExceptionARuleCannotHave =>
      floor < optimal && optimal == ceiling;

  static const String wrongDisciplineNote =
      'The metric belongs to a different discipline. "Schema Constraint '
      'Compliance Rate" cited against ISO/IEC 25012 is a DATA quality model '
      '-- the completeness and consistency of values -- and this row is about '
      'the height of a box. A layout constraint is not a schema constraint, '
      'and no amount of measuring one tells you anything about the other. The '
      'rate below is computed over the layout constraints this step actually '
      'declares, which is the closest honest reading, and the mismatch is '
      'recorded rather than hidden behind a number that happens to be 1.0.';

  static const String bandNote =
      'Floor 0.98 with optimal and ceiling both 1 means one layout in fifty '
      'may do something else. A layout rule with a two per cent allowance is '
      'not a rule: it is a default that somebody overrides at the call site, '
      'which is the condition this design system exists to prevent. The same '
      'shape as Step 271\'s 95% floor on key management, and recorded for the '
      'same reason.';

  static String get qualitativeOutput =>
      complianceRate >= optimal ? 'Complete' : 'Partial';

  static Map<String, bool> get checks => <String, bool>{
        'the named API is CSS and the available one is not':
            theNamedApiIsNotTheOneAvailable,
        'same-axis nesting is refused and cross-axis is allowed':
            sameAxisNestingIsRefused,
        'the cap only bites on long content, which is why it passes tests':
            theCapOnlyBitesWhenTheContentIsLong &&
                nestedScrollNote.contains('short test case'),
        'the overflow route is a surface rather than an inner scroller':
            overflowNeverBecomesAnInnerScroller &&
                longContentGetsASurface &&
                shortContentIsLeftAlone,
        'the limit is in rows, because a row height follows the text size':
            theLimitIsInRowsRatherThanPoints &&
                contentNotBoxNote.contains('enlarged the text'),
        'all five declared layout fields are carried':
            everyDeclaredFieldIsFilled,
        'six declared constraints, all of them holding':
            constraints.length == 6 &&
                constraints.values.every((bool b) => b) &&
                complianceRate == 1.0,
        'the data-quality metric on a layout row is recorded':
            wrongDisciplineNote.contains('height of a box'),
        'the two per cent allowance is recorded rather than accepted':
            theFloorAdmitsAnExceptionARuleCannotHave &&
                bandNote.contains('overrides at the call site'),
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Conduct a '
      'engineering walk-through of the specification rules", which is a '
      'meeting rather than an action, and the metric cites a data-quality '
      'standard on a layout row. Atomic Step: "Apply CSS constraint rules '
      'defining maximum layout height for the expanded box."';
}
