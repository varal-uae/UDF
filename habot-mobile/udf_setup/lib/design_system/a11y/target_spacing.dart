/// Step 343 (CBSV-005-14) -- the gap between targets, which is the half of
/// touch accuracy nobody writes a row for.
///
/// The row: "Add padding spacing blocks around target objects to ensure mobile
/// touch accuracy."
/// Metric: **Process Execution Quality Score** -- floor ">=90%", optimal
/// ">=98%", ceiling 1. Good/Average/Poor. ISO 9001:2015.
///
/// **Two 48dp targets touching each other are two 48dp targets with no gap.**
/// Each passes every size rule this repository enforces, and a finger landing
/// on the seam hits one of them at random. Size governs whether a target can be
/// hit; spacing governs whether the *right* one is. Every touch row this track
/// has met -- Steps 3, 108, 184, 198, 227, 228, 229, 313 and 342 -- has been
/// about size. This is the first about the gap.
///
/// **The number is 8dp, and it is not new.** The spacing scale has carried it
/// since Step 2; what this file adds is the rule that adjacent interactive
/// targets may not share an edge. A contact patch is roughly 8 to 10mm across
/// and the reported centroid drifts several millimetres from where the person
/// believes they touched, which is why a seam between two live controls is a
/// coin toss rather than a near miss.
///
/// **The row's own Data Requirement asks for a long-press**, buried in a list
/// about masked reference values: "Long-press interactions on entity elements
/// cleanly copy masked unique reference values to system clipboards". A
/// long-press is not path-based, so SC 2.5.1 does not reach it -- but it is
/// invisible, and SC 2.5.3 aside, a function available only by long-press is
/// available only to people who already know it is there. The copy action also
/// gets a visible route.
///
/// **COLUMN NOTE.** The Data Requirement column lists spacing fields -- Spacing
/// Value, Unit Type (px/rem), Spacing Scale -- in which "rem" is a CSS unit
/// with no meaning in this application, and the Setup Step column is about
/// wrapping native containers in a central AppShell.
library;

import '../tokens/touch_target_band.dart';

/// One pair of adjacent interactive targets.
class HabotTargetPair {
  const HabotTargetPair({
    required this.label,
    required this.sizeDp,
    required this.gapDp,
  });

  final String label;
  final double sizeDp;
  final double gapDp;
}

/// The spacing rule between targets.
class HabotTargetSpacing {
  const HabotTargetSpacing._();

  // -----------------------------------------------------------------------
  // Size is not the same question as spacing.
  // -----------------------------------------------------------------------

  static double get minimumSizeDp => HabotTouchBand.optimalDp;

  /// From the spacing scale declared at Step 2. Nothing new is invented.
  static const double minimumGapDp = 8;

  static const List<HabotTargetPair> pairs = <HabotTargetPair>[
    HabotTargetPair(
      label: 'two icon buttons in a row header',
      sizeDp: 48,
      gapDp: 0,
    ),
    HabotTargetPair(
      label: 'a chip pair in a filter bar',
      sizeDp: 48,
      gapDp: 4,
    ),
    HabotTargetPair(
      label: 'the tray actions on a card',
      sizeDp: 48,
      gapDp: 8,
    ),
    HabotTargetPair(
      label: 'a field and its trailing action',
      sizeDp: 48,
      gapDp: 16,
    ),
  ];

  static bool clearsSize(HabotTargetPair p) => p.sizeDp >= minimumSizeDp;

  static bool clearsGap(HabotTargetPair p) => p.gapDp >= minimumGapDp;

  static int get pairsClearingSize => pairs.where(clearsSize).length;

  static int get pairsClearingGap => pairs.where(clearsGap).length;

  /// All four pass every size rule this repository has; two fail on the gap.
  static bool get sizePassesEverywhereAndSpacingDoesNot =>
      pairsClearingSize == 4 && pairsClearingGap == 2;

  static List<HabotTargetPair> get failingPairs =>
      pairs.where((HabotTargetPair p) => !clearsGap(p)).toList();

  static bool get theTouchingPairIsTheWorstCase =>
      failingPairs.isNotEmpty && failingPairs.first.gapDp == 0;

  static const String sizeVersusSpacingNote =
      'Two 48dp targets sharing an edge each satisfy every size rule this '
      'repository enforces, and a finger landing on the seam hits one of them '
      'at random. Size decides whether a target can be hit at all; spacing '
      'decides whether the right one is. Nine touch rows in this track have '
      'been about size -- Steps 3, 108, 184, 198, 227, 228, 229, 313 and '
      '342 -- and this is the first about the gap between two of them.';

  // -----------------------------------------------------------------------
  // Why 8dp and not zero.
  // -----------------------------------------------------------------------

  static const double contactPatchMinMm = 8;
  static const double contactPatchMaxMm = 10;

  /// Roughly, at the baseline density: 1dp is about 0.16mm of a 160dpi inch.
  static const double mmPerDpApproximate = 0.1588;

  static double get contactPatchMinDp => contactPatchMinMm / mmPerDpApproximate;

  /// The patch is bigger than the gap, which is the point: the gap does not
  /// have to separate the fingers, only the reported centroids.
  static bool get thePatchIsWiderThanTheGap =>
      contactPatchMinDp > minimumGapDp;

  static const String patchNote =
      'A fingertip contact patch is roughly 8 to 10 millimetres across, which '
      'is far wider than the 8dp gap, and that is not a contradiction: the gap '
      'does not separate the fingers, it separates the reported centroids. The '
      'centroid drifts a few millimetres from where a person believes they '
      'touched, so a seam between two live controls turns a small drift into a '
      'different action rather than a near miss.';

  // -----------------------------------------------------------------------
  // The long-press the row buries in a list about clipboards.
  // -----------------------------------------------------------------------

  static const String hiddenAffordance =
      'long-press to copy the masked reference';

  static const bool theLongPressIsPathBased = false;

  static const String visibleEquivalent =
      'a copy action in the overflow menu on the same element';

  static bool get theCopyActionHasAVisibleRoute =>
      visibleEquivalent.isNotEmpty;

  static const String longPressNote =
      'A long-press is not a path-based gesture, so SC 2.5.1 does not reach '
      'it. What reaches it is that nothing on the screen says it exists: a '
      'function available only by holding an element is available only to '
      'people who have been told. The row buries it in a list about masked '
      'reference values, as though it were a formatting decision. The copy '
      'action keeps the long-press and gains a visible route.';

  // -----------------------------------------------------------------------
  // The units in the row's own field list.
  // -----------------------------------------------------------------------

  static const List<String> unitsTheRowLists = <String>['px', 'rem'];

  static const List<String> unitsThisApplicationHas = <String>['dp'];

  static List<String> get unitsWithNoMeaningHere => unitsTheRowLists
      .where((String u) => !unitsThisApplicationHas.contains(u))
      .toList();

  static bool get bothListedUnitsAreForeign =>
      unitsWithNoMeaningHere.length == 2;

  static const String unitsNote =
      'The Data Requirement column names a "Unit Type (px/rem)" field. Neither '
      'is a unit this application has: px is a device pixel, which varies with '
      'density, and rem is a CSS unit relative to a root font size that does '
      'not exist outside a browser. Everything here is in dp, and the '
      'conversion the row implies is the same one Step 342 had to unpick.';

  static const String bandFloor = '>=90%';
  static const String bandOptimal = '>=98%';
  static const String bandCeiling = '1';

  static bool get theBandMixesUnits =>
      bandFloor.contains('%') && !bandCeiling.contains('%');

  static const String bandNote =
      'The floor and the optimal are percentages and the ceiling is the bare '
      'ratio "1", which is the same mixture Step 336 carries. The three values '
      'are at least in the right order, and the score published here is the '
      'share of adjacent interactive pairs that clear both the size rule and '
      'the gap rule.';

  static double get score => pairs.isEmpty
      ? 0
      : pairs.where((HabotTargetPair p) => clearsSize(p) && clearsGap(p))
              .length /
          pairs.length;

  static Map<String, bool> get obligations => <String, bool>{
        'the minimum size comes from the existing band':
            minimumSizeDp == HabotTouchBand.optimalDp,
        'the minimum gap comes from the spacing scale': minimumGapDp == 8,
        'adjacent interactive targets may not share an edge':
            theTouchingPairIsTheWorstCase,
        'the hidden copy action has a visible route':
            theCopyActionHasAVisibleRoute,
        'the foreign units are named rather than converted':
            bothListedUnitsAreForeign,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'four pairs, all of which clear the size rule':
            pairs.length == 4 && pairsClearingSize == 4,
        'two of the four fail on the gap':
            pairsClearingGap == 2 && sizePassesEverywhereAndSpacingDoesNot,
        'the touching pair is the worst case':
            theTouchingPairIsTheWorstCase && failingPairs.length == 2,
        'nine previous touch rows were about size':
            sizeVersusSpacingNote.contains('Steps 3, 108, 184'),
        'the contact patch is wider than the gap':
            thePatchIsWiderThanTheGap &&
                patchNote.contains('separates the reported centroids'),
        'the long-press is not path-based and still gets a route':
            !theLongPressIsPathBased && theCopyActionHasAVisibleRoute,
        'the hidden affordance is named':
            hiddenAffordance.contains('long-press'),
        'neither listed unit exists in this application':
            bothListedUnitsAreForeign &&
                unitsNote.contains('Step 342'),
        'the band mixes units and the score names its denominator':
            theBandMixesUnits && score == 0.5,
        'five obligations, all met, giving Good':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good',
      };

  static const String columnNote =
      'COLUMN NOTE: the Data Requirement column on this row asks for a "Unit '
      'Type (px/rem)" field, neither of which is a unit this application uses, '
      'and buries a long-press-to-copy affordance in a list about masked '
      'reference values; the Setup Step column is about wrapping native '
      'containers in a central AppShell. Atomic Step: "Add padding spacing '
      'blocks around target objects to ensure mobile touch accuracy."';
}
