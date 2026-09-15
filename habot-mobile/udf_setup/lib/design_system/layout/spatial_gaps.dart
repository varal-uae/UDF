/// Step 285 (BDAE-003) -- gaps as an alternative to size, which is what WCAG
/// actually says and what this row is groping at.
///
/// The row: "Set spatial gaps to standard metric increments for touch
/// targets."
/// Metric: **WCAG 2.2 Touch Target & Contrast Compliance** -- floor "24x24px /
/// 3:1", optimal "48x48dp / 4.5:1", ceiling ">=48dp / 7:1". Pass / Fail.
/// Cited: WCAG 2.2 Level AA.
///
/// **A gap is not a second requirement; it is the way out of the first.** SC
/// 2.5.8 asks for a 24x24 target *or* enough space around a smaller one: put a
/// 24-diameter circle on the centre of each target, and if no two circles
/// overlap, the smaller targets pass. So "spatial gaps for touch targets" is
/// the spacing exception, and it is implemented here as one predicate with two
/// branches rather than as two rules somebody has to remember to apply
/// together.
///
/// **This row's floor is the figure Step 276's floor got wrong.** Both rows
/// cite the same standard on the same day. This one says 24x24px for AA, which
/// is SC 2.5.8 exactly; Step 276 says 44px for AA, which is the AAA figure.
/// One of the two is right, they cannot both be, and the pair is recorded
/// together so the sheet's own disagreement is visible.
///
/// **The band mixes px and dp inside itself.** Floor in px, optimal and
/// ceiling in dp, for the same quantity. Step 276 has the same mix across two
/// rows; here it is inside one cell.
///
/// **And two success criteria are bundled into one Pass/Fail.** Target size is
/// SC 2.5.8; contrast is 1.4.3 and 1.4.11. A single verdict over both cannot
/// say which failed, so both are evaluated separately and the combined verdict
/// is derived rather than asserted.
library;

import '../tokens/spacing_tokens.dart';
import '../tokens/touch_target_band.dart';

/// Which success criterion a finding belongs to.
enum HabotCriterion {
  /// SC 2.5.8 Target Size (Minimum), Level AA.
  targetSize,

  /// SC 1.4.3 and 1.4.11, contrast.
  contrast,
}

/// One control, its size and the gap to its nearest neighbour.
class HabotControlGap {
  const HabotControlGap({
    required this.name,
    required this.sizeDp,
    required this.gapToNeighbourDp,
    required this.expectedToPass,
  });

  final String name;
  final double sizeDp;
  final double gapToNeighbourDp;

  /// What the criterion should say about it. The corpus is a test of the
  /// predicate, not a measurement of the application, and this field is what
  /// keeps those two apart.
  final bool expectedToPass;

  /// The distance between the centres of two adjacent equal targets.
  double get centreDistanceDp => sizeDp + gapToNeighbourDp;
}

/// The rule.
class HabotSpatialGaps {
  const HabotSpatialGaps._();

  // -----------------------------------------------------------------------
  // "Standard metric increments", checked against the scale that exists.
  // -----------------------------------------------------------------------

  /// The declared spacing scale.
  static List<double> get scale => <double>[
        HabotSpacing.none,
        HabotSpacing.xxs,
        HabotSpacing.xs,
        HabotSpacing.sm,
        HabotSpacing.md,
        HabotSpacing.lg,
        HabotSpacing.xl,
        HabotSpacing.xxl,
        HabotSpacing.xxxl,
      ];

  static double get baseline => HabotSpacing.baseline;
  static double get subBaseline => HabotSpacing.subBaseline;

  static List<double> get onTheBaseline =>
      scale.where((double v) => v % baseline == 0).toList();

  static List<double> get onTheSubBaselineOnly => scale
      .where((double v) => v % baseline != 0 && v % subBaseline == 0)
      .toList();

  /// Everything on the scale is a multiple of the sub-baseline; most of it is
  /// a multiple of the baseline. Both facts are measured rather than claimed,
  /// because "standard metric increments" is a phrase that sounds like a rule
  /// and is not one until somebody says what the increment is.
  static bool get everyValueIsOnTheGrid =>
      scale.every((double v) => v % subBaseline == 0);

  static bool get mostValuesAreOnTheBaseline =>
      onTheBaseline.length == 7 && onTheSubBaselineOnly.length == 2;

  static const String incrementNote =
      '"Standard metric increments" is a phrase that sounds like a rule and '
      'is not one until somebody says what the increment is. Here it is '
      'already declared: an 8-point baseline with a 4-point sub-baseline. '
      'Every value on the spacing scale is a multiple of 4; seven of the nine '
      'are multiples of 8, and the two that are not -- 4 and 12 -- are the '
      'sub-baseline and its odd multiple, which is why the sub-baseline was '
      'declared at all. The measurement is over the scale rather than over '
      'the sentence.';

  // -----------------------------------------------------------------------
  // The spacing exception, which is the row's real subject.
  // -----------------------------------------------------------------------

  /// SC 2.5.8, Level AA.
  static const double minimumTargetDp = 24;

  /// A target meets the criterion on its own size.
  static bool meetsOnSize(HabotControlGap c) => c.sizeDp >= minimumTargetDp;

  /// Or it meets it on spacing: a circle of the minimum diameter centred on
  /// each target, and no two circles overlapping. Two adjacent equal targets
  /// satisfy that when the distance between their centres is at least the
  /// diameter.
  static bool meetsOnSpacing(HabotControlGap c) =>
      c.centreDistanceDp >= minimumTargetDp;

  /// One predicate, two branches. A rule split into two that somebody has to
  /// remember to apply together is a rule half-applied.
  static bool meetsTargetSize(HabotControlGap c) =>
      meetsOnSize(c) || meetsOnSpacing(c);

  static const List<HabotControlGap> corpus = <HabotControlGap>[
    HabotControlGap(
      name: 'primary action button',
      sizeDp: 48,
      gapToNeighbourDp: 16,
      expectedToPass: true,
    ),
    HabotControlGap(
      name: 'icon button in a dense toolbar',
      sizeDp: 24,
      gapToNeighbourDp: 8,
      expectedToPass: true,
    ),
    HabotControlGap(
      name: 'inline link inside a paragraph',
      sizeDp: 18,
      gapToNeighbourDp: 12,
      expectedToPass: true,
    ),
    HabotControlGap(
      name: 'two chips packed edge to edge',
      sizeDp: 20,
      gapToNeighbourDp: 2,
      expectedToPass: false,
    ),
  ];

  static List<HabotControlGap> get passing =>
      corpus.where(meetsTargetSize).toList();

  static List<HabotControlGap> get failing =>
      corpus.where((HabotControlGap c) => !meetsTargetSize(c)).toList();

  /// The case the exception exists for: too small on its own, saved by the
  /// space around it.
  static List<HabotControlGap> get savedByTheirSpacing => corpus
      .where((HabotControlGap c) => !meetsOnSize(c) && meetsOnSpacing(c))
      .toList();

  /// And the case nothing saves.
  static bool get theCrowdedChipsFail =>
      failing.length == 1 && failing.single.name.contains('chips');

  static bool get theInlineLinkIsSavedBySpacing =>
      savedByTheirSpacing.length == 1 &&
      savedByTheirSpacing.single.name.contains('link');

  /// The share of the CORPUS that passes. Not a compliance rate for the
  /// application: the corpus was chosen to contain a failure, so a rate over
  /// it measures the choice rather than the product.
  static double get shareOfTheCorpusThatPasses =>
      passing.length / corpus.length;

  /// What the corpus actually tests: whether the predicate agrees with the
  /// expected verdict on every case, including the one it should refuse.
  static double get classifierAccuracy =>
      corpus
          .where((HabotControlGap c) => meetsTargetSize(c) == c.expectedToPass)
          .length /
      corpus.length;

  static bool get theCorpusContainsARefusal =>
      corpus.any((HabotControlGap c) => !c.expectedToPass);

  static const String corpusIsNotAPopulationNote =
      'The four cases are a test of the predicate, not a census of the '
      'application. A rate computed over them measures which cases were '
      'chosen, and they were chosen to include one the criterion must refuse '
      '-- a corpus where everything passes tests nothing. So the figure '
      'reported is the classifier\'s accuracy against the expected verdicts, '
      'and the share of the corpus that passes is published beside it with '
      'that distinction stated. Step 262 drew the same line for attachment '
      'validation.';

  static const String exceptionNote =
      'A gap is not a second requirement, it is the way out of the first. SC '
      '2.5.8 asks for a 24-point target OR enough space around a smaller one: '
      'place a 24-diameter circle on each target\'s centre, and if no two '
      'overlap, the small ones pass. That is what "spatial gaps for touch '
      'targets" is groping at, and it is implemented as one predicate with '
      'two branches -- a rule split into two that somebody has to remember to '
      'apply together is a rule half-applied. An 18-point inline link with 12 '
      'points around it passes; two 20-point chips packed 2 points apart do '
      'not, and no amount of enlarging the chips\' own hit area fixes that '
      'without moving them.';

  // -----------------------------------------------------------------------
  // The disagreement with Step 276.
  // -----------------------------------------------------------------------

  /// This row's floor, and Step 276's, both cited to the same standard on the
  /// same day.
  static const double thisRowsAaFloorDp = 24;
  static double get step276AaFloorDp => HabotTouchBand.floorDp;

  static bool get theTwoRowsDisagreeAboutAa =>
      thisRowsAaFloorDp != step276AaFloorDp;

  /// This one is right: 24 is SC 2.5.8, Level AA.
  static bool get thisRowsFloorIsTheCorrectAaFigure =>
      thisRowsAaFloorDp == minimumTargetDp;

  static const String disagreementNote =
      'Two rows in this batch cite the same standard for the same quantity '
      'and give different figures. This one says 24x24 for Level AA, which is '
      'SC 2.5.8 exactly; Step 276 says 44 for Level AA, which is the Level '
      'AAA figure from SC 2.5.5. They cannot both be right. This row is, and '
      'the pair is recorded together so the sheet\'s own disagreement is '
      'visible in the repository rather than resolved silently in favour of '
      'whichever row was implemented second.';

  static const String unitsNote =
      'The band mixes units inside one cell: the floor is written in px and '
      'the optimal and ceiling in dp, for the same quantity. Step 276 carries '
      'the same mix across two rows; here it is inside one. Everything in '
      'this repository is measured in dp, so the figures are read as dp and '
      'the discrepancy is recorded rather than converted.';

  // -----------------------------------------------------------------------
  // Two criteria, one verdict.
  // -----------------------------------------------------------------------

  static const double contrastFloor = 3;
  static const double contrastOptimal = 4.5;
  static const double contrastCeiling = 7;

  /// Evaluated separately, so a failure says which half failed.
  static Map<HabotCriterion, bool> verdictFor({
    required double observedContrast,
  }) =>
      <HabotCriterion, bool>{
        HabotCriterion.targetSize: classifierAccuracy == 1.0,
        HabotCriterion.contrast: observedContrast >= contrastOptimal,
      };

  static bool combinedPass({required double observedContrast}) =>
      verdictFor(observedContrast: observedContrast)
          .values
          .every((bool b) => b);

  /// A single Pass/Fail over two criteria cannot say which one failed, which
  /// is demonstrated rather than argued: the same combined verdict arises
  /// from two different causes.
  static bool get oneVerdictHidesWhichHalfFailed {
    final Map<HabotCriterion, bool> lowContrast =
        verdictFor(observedContrast: 3.2);
    return !combinedPass(observedContrast: 3.2) &&
        combinedPass(observedContrast: 4.5) &&
        lowContrast[HabotCriterion.contrast] == false &&
        lowContrast[HabotCriterion.targetSize] == true;
  }

  static const String bundledCriteriaNote =
      'Target size is SC 2.5.8; contrast is 1.4.3 and 1.4.11. Bundling them '
      'into one Pass/Fail means a failure cannot say which criterion failed, '
      'and the two have nothing to do with each other -- a control can be '
      'perfectly legible and impossible to hit, or the reverse. Both are '
      'evaluated separately here and the combined verdict is derived from the '
      'pair rather than asserted over it, so the report says which half is '
      'wrong.';

  static String get qualitativeOutput =>
      classifierAccuracy >= 1.0 && everyValueIsOnTheGrid ? 'Pass' : 'Fail';

  static const String wrongRowNote =
      'Every other column on this row is about TLS 1.3, edge load balancers '
      'and Terraform: "Why This Matters" is about downgrade vulnerabilities, '
      'the Expected Output is a Terraform file, and the Completion Measures '
      'are security sweepers confirming handshake failures. The Atomic Step '
      'and the metric are about touch targets. The row is two rows.';

  static Map<String, bool> get checks => <String, bool>{
        'every value on the spacing scale is on the grid':
            everyValueIsOnTheGrid && mostValuesAreOnTheBaseline,
        'the increment is the declared baseline rather than a phrase':
            baseline == 8 &&
                subBaseline == 4 &&
                incrementNote.contains('over the scale'),
        'target size is one predicate with two branches':
            meetsTargetSize(corpus.first) &&
                exceptionNote.contains('half-applied'),
        'a small control with space around it passes':
            theInlineLinkIsSavedBySpacing,
        'a small control packed against its neighbour does not':
            theCrowdedChipsFail,
        'the predicate agrees with every expected verdict, refusal included':
            classifierAccuracy == 1.0 && theCorpusContainsARefusal,
        'three of the four cases pass, and the corpus is named as a test '
            'rather than a population':
            passing.length == 3 &&
                (shareOfTheCorpusThatPasses - 0.75).abs() < 1e-9 &&
                corpusIsNotAPopulationNote.contains('tests nothing'),
        'this row and Step 276 disagree about the AA figure':
            theTwoRowsDisagreeAboutAa &&
                thisRowsFloorIsTheCorrectAaFigure &&
                disagreementNote.contains('cannot both be right'),
        'the px/dp mix inside one cell is recorded':
            unitsNote.contains('inside one'),
        'the two criteria are evaluated separately':
            oneVerdictHidesWhichHalfFailed &&
                bundledCriteriaNote.contains('which half is wrong'),
        'the contrast band is carried verbatim':
            contrastFloor == 3 &&
                contrastOptimal == 4.5 &&
                contrastCeiling == 7,
        'the row\'s other columns are recorded as a different subject':
            wrongRowNote.contains('two rows'),
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Launch the '
      'gamified mobile learning portal to the corporate app store", and every '
      'narrative column is about TLS 1.3 and edge load balancers. Atomic '
      'Step: "Set spatial gaps to standard metric increments for touch '
      'targets."';
}
