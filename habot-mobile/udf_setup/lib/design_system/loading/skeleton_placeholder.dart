/// Step 298 (ACRAE-032-15) -- three obligations under one Pass/Fail, two of
/// which turn out to be the same obligation.
///
/// The row: "Format date labels using monospaced typographical alignments,
/// verify non-blocking skeleton loaders, and enforce 48dp interactive touch
/// targets."
/// Metric: **Mobile Touch Target Size Compliance** -- floor "44dp minimum",
/// optimal "48dp", ceiling "56dp+". Pass/Fail, best = Pass (>=48dp).
/// Cited as WCAG 2.2 SC 2.5.8.
///
/// **Three subjects, one measurement.** Typography, loading placeholders and
/// touch targets are three unrelated things joined by an "and", scored by one
/// Pass/Fail that can only speak for the third. A failure could not say which
/// of the three failed, and a Pass says nothing at all about the first two.
/// Step 285 found the same bundling in a touch-and-contrast pair and Step 295
/// in an accuracy-and-latency pair; this is the widest one so far, at one
/// measured obligation in three.
///
/// **And then two of the three are one.** A skeleton placeholder can only be
/// non-blocking -- that is, can only avoid moving the content that follows it
/// when the real value arrives -- if the settled value has a width the
/// placeholder can predict. Tabular figures are what makes a date's width
/// predictable: with proportional digits the same format spans 65.6 to 82.4
/// points depending on which digits it happens to contain, a 16.8-point spread
/// that is more than two rungs of the spacing scale. So the row's first clause
/// is the precondition for its second, and the row does not notice.
///
/// **The citation is wrong, and Step 313 in this same batch has it right.**
/// SC 2.5.8 Target Size (Minimum) is 24 by 24 CSS pixels at Level AA. The 44
/// figure belongs to SC 2.5.5 Target Size at Level AAA. This row cites 2.5.8
/// for 44dp; Step 313 cites 2.5.5 for the same figure and is correct. Both
/// are in this batch, twenty rows apart, disagreeing about which criterion
/// they are quoting.
///
/// **COLUMN NOTE.** Data Collected is "Lock Type; Lock Status; Locked By; Lock
/// Timestamp; Lock Reason" -- the record-locking vocabulary, on a row about
/// dates, placeholders and touch targets. Third appearance: Step 273 carried
/// it on a circuit-breaker row and Step 295 on a table-cell row, where it
/// finally described the thing it was written for.
library;

import '../tokens/motion_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/touch_target_band.dart';

/// One glyph class in the worked date label, with the advance widths declared
/// for this example. These are the example's numbers, not measurements of a
/// shipped font; what the step asserts is the relationship between them.
class HabotGlyphClass {
  const HabotGlyphClass({
    required this.name,
    required this.count,
    required this.proportionalMinDp,
    required this.proportionalMaxDp,
    required this.tabularDp,
  });

  final String name;
  final int count;
  final double proportionalMinDp;
  final double proportionalMaxDp;
  final double tabularDp;
}

/// The three obligations, and what can be said about each.
class HabotSkeletonPlaceholder {
  const HabotSkeletonPlaceholder._();

  // -----------------------------------------------------------------------
  // The bundle.
  // -----------------------------------------------------------------------

  static const List<String> obligationsOnTheRow = <String>[
    'format date labels using monospaced alignments',
    'verify non-blocking skeleton loaders',
    'enforce 48dp interactive touch targets',
  ];

  /// Only the third has a measurement on the row.
  static const List<bool> measuredByTheMetric = <bool>[false, false, true];

  static int get obligationsMeasured =>
      measuredByTheMetric.where((bool b) => b).length;

  static double get shareMeasured =>
      obligationsMeasured / obligationsOnTheRow.length;

  static bool get oneVerdictCoversThree =>
      obligationsOnTheRow.length == 3 && obligationsMeasured == 1;

  static const String bundleNote =
      'Typography, loading placeholders and touch targets are three unrelated '
      'subjects joined by an "and" and scored by one Pass/Fail. The metric is '
      'about touch target size, so it can speak for the third obligation and '
      'for neither of the others: a Fail could not say which one failed, and '
      'the Pass this step earns on targets says nothing about dates. Step 285 '
      'found the same shape in a touch-and-contrast pair, Step 295 in an '
      'accuracy-and-latency pair; at one measured obligation in three this is '
      'the widest so far.';

  // -----------------------------------------------------------------------
  // Why the first two are one.
  // -----------------------------------------------------------------------

  /// 'dd MMM yyyy' -- six digits, three letters, two spaces.
  static const String dateFormat = 'dd MMM yyyy';

  static const List<HabotGlyphClass> glyphs = <HabotGlyphClass>[
    HabotGlyphClass(
      name: 'digits',
      count: 6,
      proportionalMinDp: 5.6,
      proportionalMaxDp: 8.4,
      tabularDp: 8.4,
    ),
    HabotGlyphClass(
      name: 'letters',
      count: 3,
      proportionalMinDp: 8.0,
      proportionalMaxDp: 8.0,
      tabularDp: 8.0,
    ),
    HabotGlyphClass(
      name: 'spaces',
      count: 2,
      proportionalMinDp: 4.0,
      proportionalMaxDp: 4.0,
      tabularDp: 4.0,
    ),
  ];

  static double get narrowestProportionalDp => glyphs.fold(
        0,
        (double a, HabotGlyphClass g) => a + g.count * g.proportionalMinDp,
      );

  static double get widestProportionalDp => glyphs.fold(
        0,
        (double a, HabotGlyphClass g) => a + g.count * g.proportionalMaxDp,
      );

  static double get tabularDp => glyphs.fold(
        0,
        (double a, HabotGlyphClass g) => a + g.count * g.tabularDp,
      );

  static double get proportionalSpreadDp =>
      widestProportionalDp - narrowestProportionalDp;

  /// The spread expressed in rungs of the declared spacing scale, which is
  /// the unit a layout shift is noticed in.
  static double get spreadInBaselineRungs =>
      proportionalSpreadDp / HabotSpacing.baseline;

  /// Tabular figures make the width a constant: every date in the format is
  /// the same width whatever digits it contains.
  static bool get tabularWidthIsConstant =>
      tabularDp == widestProportionalDp &&
      glyphs.every(
        (HabotGlyphClass g) =>
            g.name != 'digits' || g.tabularDp == g.proportionalMaxDp,
      );

  /// So a placeholder can be drawn at the settled width before the value
  /// exists, which is the whole of "non-blocking".
  static double get placeholderWidthDp => tabularDp;

  static bool get thePlaceholderMatchesTheSettledWidth =>
      placeholderWidthDp == tabularDp;

  static bool get theFirstObligationIsThePreconditionForTheSecond =>
      tabularWidthIsConstant && thePlaceholderMatchesTheSettledWidth;

  static const String connectionNote =
      'A skeleton is non-blocking when the content that follows it does not '
      'move as the real value arrives. That requires knowing the settled width '
      'in advance, and with proportional digits the same date format spans '
      '65.6 to 82.4 points depending on which digits it happens to contain -- '
      'a 16.8-point spread, more than two rungs of the spacing scale, and '
      'therefore a visible jump in every row of a list. Tabular figures make '
      'the width a constant. The row\'s first clause is the precondition for '
      'its second, and the row joins them with an "and" as though they were '
      'two tasks.';

  /// The sweep animation is a token; the placeholder does not invent a
  /// duration of its own.
  static Duration get sweep => HabotMotion.skeletonSweep;

  /// A skeleton is decoration, not content: it must not be announced as text
  /// and must not claim a value.
  static const bool skeletonIsExcludedFromSemantics = true;

  static const String semanticsNote =
      'A skeleton has nothing to announce. Announcing it reads a row of grey '
      'bars to somebody who cannot see them, which is noise, and giving it a '
      'label like "loading placeholder" is worse because it is a description '
      'of the implementation. The surrounding scope is what says the screen is '
      'busy; the placeholder is excluded.';

  // -----------------------------------------------------------------------
  // The obligation that is measured.
  // -----------------------------------------------------------------------

  static double get targetFloorDp => HabotTouchBand.floorDp;
  static double get targetOptimalDp => HabotTouchBand.optimalDp;
  static double get targetCeilingDp => HabotTouchBand.ceilingDp;

  /// The row asks for 48dp, which is this project's optimal rather than its
  /// floor -- so the row's own Atomic Step is stricter than the row's own
  /// floor, by four points.
  static const double requestedDp = 48;

  static double get floorShortfallDp => requestedDp - targetFloorDp;

  static bool get theRowIsStricterThanItsOwnFloor =>
      requestedDp > targetFloorDp && requestedDp == targetOptimalDp;

  static const String citedCriterion = 'WCAG 2.2 SC 2.5.8';
  static const String correctCriterionForFortyFour = 'WCAG 2.1 SC 2.5.5';

  static const double actualMinimumForCitedCriterion = 24;

  static bool get theCitationIsWrong =>
      actualMinimumForCitedCriterion != targetFloorDp;

  static const String citationNote =
      'SC 2.5.8 Target Size (Minimum) is 24 by 24 at Level AA. The 44 figure '
      'is SC 2.5.5 at Level AAA. This row cites 2.5.8 for 44dp; Step 313, '
      'fifteen rows later in this same batch, cites 2.5.5 for the same figure '
      'and is right. The sheet now contains both readings of the same number, '
      'as it already does for the 44-against-24 disagreement between Steps 276 '
      'and 285.';

  // -----------------------------------------------------------------------
  // The borrowed vocabulary.
  // -----------------------------------------------------------------------

  static const List<String> dataCollectedFields = <String>[
    'Lock Type',
    'Lock Status',
    'Locked By',
    'Lock Timestamp',
    'Lock Reason',
  ];

  static const List<int> stepsThatCarriedTheseFields = <int>[273, 295, 298];

  static bool get theSameFiveFieldsAppearAThirdTime =>
      dataCollectedFields.length == 5 &&
      stepsThatCarriedTheseFields.length == 3;

  static const String lockFieldsNote =
      'Lock Type, Lock Status, Locked By, Lock Timestamp and Lock Reason are '
      'the record-locking vocabulary. Step 273 carried them on a '
      'circuit-breaker row, Step 295 on a table-cell row where they finally '
      'described the thing they were written for, and this row carries them on '
      'dates, placeholders and touch targets. Nothing here locks anything.';

  // -----------------------------------------------------------------------
  // The verdict.
  // -----------------------------------------------------------------------

  static Map<String, bool> get obligations => <String, bool>{
        'date labels use tabular figures': tabularWidthIsConstant,
        'the placeholder is drawn at the settled width':
            thePlaceholderMatchesTheSettledWidth,
        'the placeholder animates on a declared token':
            sweep == HabotMotion.skeletonSweep,
        'the placeholder announces nothing': skeletonIsExcludedFromSemantics,
        'interactive targets are held at the optimal rather than the floor':
            requestedDp == targetOptimalDp,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'three obligations, one of them measured':
            oneVerdictCoversThree &&
                (shareMeasured - 1 / 3).abs() < 1e-9 &&
                bundleNote.contains('widest so far'),
        'a proportional date spans 16.8 points':
            (narrowestProportionalDp - 65.6).abs() < 1e-9 &&
                (widestProportionalDp - 82.4).abs() < 1e-9 &&
                (proportionalSpreadDp - 16.8).abs() < 1e-9,
        'that spread is more than two rungs of the spacing scale':
            spreadInBaselineRungs > 2 && HabotSpacing.baseline == 8,
        'tabular figures make the width a constant': tabularWidthIsConstant,
        'so the first obligation is the precondition for the second':
            theFirstObligationIsThePreconditionForTheSecond &&
                connectionNote.contains('as though they were'),
        'the sweep is a token and the placeholder is silent':
            sweep.inMilliseconds == 1400 && skeletonIsExcludedFromSemantics,
        'the row asks for four points more than its own floor':
            theRowIsStricterThanItsOwnFloor && floorShortfallDp == 4,
        'the cited criterion is not the one that says 44':
            theCitationIsWrong &&
                citedCriterion.contains('2.5.8') &&
                correctCriterionForFortyFour.contains('2.5.5'),
        'and Step 313 in this batch cites it correctly':
            citationNote.contains('Step 313'),
        'the lock vocabulary appears for the third time':
            theSameFiveFieldsAppearAThirdTime &&
                lockFieldsNote.contains('Nothing here locks anything'),
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: Data Collected on this row is the record-locking '
      'vocabulary -- Lock Type, Lock Status, Locked By, Lock Timestamp, Lock '
      'Reason -- and the Setup Step reads "Clear the local device database '
      'vault files upon receiving a successful server state synchronization '
      'receipt", which is a data-retention instruction on a typography row. '
      'Atomic Step: "Format date labels using monospaced typographical '
      'alignments, verify non-blocking skeleton loaders, and enforce 48dp '
      'interactive touch targets."';
}
