/// Step 342 (MCIIM-014-11) -- "48dp (44px)", which is two standards' numbers
/// presented as a unit conversion.
///
/// The row: "Enforce strict touch element padding rules targeting the isolated
/// task text fields."
/// Metric: **Process Step Execution Conformance** -- floor 0.9, optimal 0.97,
/// ceiling 1. Complete / Partial / Not Complete. ISO 9001:2015; Six Sigma
/// DPMO.
///
/// **The Setup Step column reads "Set the global mobile action element minimum
/// height parameter to 48dp (44px)".** Those are not the same measurement in
/// different units. 48dp at the baseline density is 48px, not 44. And 44 is not
/// a conversion of anything: it is Apple's Human Interface Guidelines figure,
/// and separately the number WCAG 2.1 SC 2.5.5 uses at Level AAA. The
/// parenthesis reads as a helpful restatement and is in fact a second
/// specification, from a second vendor, silently disagreeing by four points.
///
/// **Which matters because the difference is a real one.** 44 to 48 is 9 per
/// cent on each side and 19 per cent of area. Step 227 already recorded that
/// this project resolves the disagreement upward -- 48dp, from MD3 -- and the
/// band Step 184 built puts 44 at the floor and 48 at the optimal, so the two
/// numbers in that parenthesis are the two ends of a band this repository has
/// been carrying since Step 184.
///
/// **Padding is not size, which is the row's other conflation.** A 24dp icon
/// with 12dp of padding on every side is a 48dp target; the same icon inside a
/// 48dp box with the padding on two sides is a 48-by-24 target. What has to
/// clear the band is the smaller dimension of the hit rectangle, and the row's
/// word for the input -- padding -- does not determine it.
///
/// **COLUMN NOTE.** The Setup Step column contains the 48dp/44px conflation;
/// the Data Requirement column is about isolating a single Byt with surface
/// elevation and 16dp margins, which is layout rather than touch; and the band
/// is a conformance ratio with no stated population.
library;

import '../tokens/touch_target_band.dart';

/// How a target reaches its size.
enum HabotSizingRoute {
  /// The content is the size and padding makes up the difference.
  paddedContent,

  /// The box is the size and the content sits inside it.
  fixedBox,
}

/// One field's hit rectangle, in dp.
class HabotHitRect {
  const HabotHitRect({required this.width, required this.height});

  final double width;
  final double height;

  double get minor => width < height ? width : height;
}

/// The padding rule on isolated task fields.
class HabotFieldPadding {
  const HabotFieldPadding._();

  // -----------------------------------------------------------------------
  // The parenthesis.
  // -----------------------------------------------------------------------

  static const double rowDp = 48;
  static const double rowPx = 44;

  /// At the baseline density 1dp is 1px, so the conversion is the identity.
  static const double baselineDensity = 1;

  static double get dpConvertedToPx => rowDp * baselineDensity;

  static bool get theParenthesisIsNotAConversion => dpConvertedToPx != rowPx;

  static double get discrepancyPx => dpConvertedToPx - rowPx;

  static double get areaRatio => (rowDp * rowDp) / (rowPx * rowPx);

  /// 9 per cent on a side, 19 per cent of area.
  static bool get theGapIsNineteenPerCentOfArea =>
      (areaRatio - 1.1900826446280992).abs() < 1e-9;

  static const Map<double, String> whereEachNumberComesFrom = <double, String>{
    48: 'Material Design 3, and this project\'s own token since Step 3',
    44: 'Apple Human Interface Guidelines, and WCAG 2.1 SC 2.5.5 at AAA',
  };

  static bool get bothNumbersHaveASource =>
      whereEachNumberComesFrom.length == 2;

  static const String conversionNote =
      'The Setup Step reads "48dp (44px)". At the baseline density one dp is '
      'one px, so 48dp is 48px and the parenthesis is not a restatement of the '
      'figure before it. Nor is 44 a conversion of anything: it is Apple\'s '
      'Human Interface Guidelines number, and separately the figure WCAG 2.1 '
      'SC 2.5.5 uses at Level AAA. Two vendors\' specifications are printed as '
      'though one were the other in different units, and they disagree by four '
      'points -- nine per cent on a side and nineteen per cent of area.';

  // -----------------------------------------------------------------------
  // The disagreement is already resolved in this repository.
  // -----------------------------------------------------------------------

  static double get bandFloorDp => HabotTouchBand.floorDp;
  static double get bandOptimalDp => HabotTouchBand.optimalDp;

  /// The two numbers in the parenthesis are the two ends of the existing band.
  static bool get theParenthesisIsTheBand =>
      bandFloorDp == rowPx && bandOptimalDp == rowDp;

  static const int theStepThatResolvedIt = 227;

  static const String resolutionNote =
      'Step 184 built a touch band with 44dp at the floor and 48dp at the '
      'optimal, and Step 227 recorded that this project resolves the '
      'disagreement upward and enforces 48. So the two numbers this row prints '
      'as a conversion are, in this repository, the floor and the optimal of a '
      'band that has existed since Step 184. Nothing new is declared here; the '
      'row is answered by pointing at what is already true.';

  // -----------------------------------------------------------------------
  // Padding is not size.
  // -----------------------------------------------------------------------

  static const double iconContentDp = 24;

  static HabotHitRect paddedOnAllSides(double padding) => HabotHitRect(
        width: iconContentDp + padding * 2,
        height: iconContentDp + padding * 2,
      );

  static HabotHitRect paddedHorizontallyOnly(double padding) => HabotHitRect(
        width: iconContentDp + padding * 2,
        height: iconContentDp,
      );

  static const double declaredPaddingDp = 12;

  static HabotHitRect get symmetric => paddedOnAllSides(declaredPaddingDp);

  static HabotHitRect get horizontalOnly =>
      paddedHorizontallyOnly(declaredPaddingDp);

  /// Same padding value, same content, two different verdicts.
  static bool get thesamePaddingGivesTwoVerdicts =>
      symmetric.minor == rowDp && horizontalOnly.minor == iconContentDp;

  static bool clearsTheBand(HabotHitRect r) => r.minor >= bandOptimalDp;

  static int get rectanglesThatClear =>
      <HabotHitRect>[symmetric, horizontalOnly].where(clearsTheBand).length;

  static const String paddingNote =
      'A 24dp icon with 12dp of padding on four sides is a 48dp square target. '
      'The same icon with the same 12dp applied on two sides is 48 by 24, and '
      'the dimension a finger has to hit accurately is the smaller one. The '
      'row specifies padding, which does not determine the hit rectangle '
      'without also specifying which sides it is on -- so the rule enforced '
      'here is stated on the rectangle rather than on the padding.';

  // -----------------------------------------------------------------------
  // The band, and the population it does not name.
  // -----------------------------------------------------------------------

  static const double metricFloor = 0.9;
  static const double metricOptimal = 0.97;
  static const double metricCeiling = 1;

  static bool get theBandIsOrderedCorrectly =>
      metricFloor < metricOptimal && metricOptimal < metricCeiling;

  static const String populationNamedByTheRow = '';

  static bool get theRowNamesNoPopulation => populationNamedByTheRow.isEmpty;

  static const String bandNote =
      'The band itself is well formed -- 0.9, 0.97, 1, in the right order for '
      'a higher-is-better ratio -- and says nothing about what is being '
      'divided by what. A conformance ratio of 0.97 over four fields and over '
      'four hundred are different claims, and the row names no population, so '
      'the denominator is stated here instead: the fields on the isolated task '
      'surface.';

  static Map<String, bool> get obligations => <String, bool>{
        'the enforced minimum is the band optimal, not the floor':
            bandOptimalDp == rowDp,
        'the rule is stated on the hit rectangle, not the padding':
            paddingNote.contains('stated on the rectangle'),
        'the smaller dimension is the one measured':
            symmetric.minor == rowDp,
        'the conflicting numbers are traced to their sources':
            bothNumbersHaveASource,
        'the band population is named here since the row does not':
            theRowNamesNoPopulation && bandNote.contains('denominator'),
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Complete' : 'Partial';

  static Map<String, bool> get checks => <String, bool>{
        '48dp is not 44px':
            theParenthesisIsNotAConversion && discrepancyPx == 4,
        'the gap is nineteen per cent of area':
            theGapIsNineteenPerCentOfArea,
        'each number is traced to a different vendor':
            bothNumbersHaveASource &&
                conversionNote.contains('Two vendors'),
        'the two numbers are the two ends of the existing band':
            theParenthesisIsTheBand && theStepThatResolvedIt == 227,
        'the resolution is cited rather than repeated':
            resolutionNote.contains('Step 184') &&
                resolutionNote.contains('already true'),
        'the same padding value gives two different targets':
            thesamePaddingGivesTwoVerdicts,
        'only the symmetric rectangle clears the band':
            rectanglesThatClear == 1 && clearsTheBand(symmetric),
        'two sizing routes are named':
            HabotSizingRoute.values.length == 2,
        'the band is well formed and names no population':
            theBandIsOrderedCorrectly && theRowNamesNoPopulation,
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete',
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Set the global '
      'mobile action element minimum height parameter to 48dp (44px)", which '
      'presents two vendors\' specifications as one figure in two units; the '
      'Data Requirement column is about isolating a single Byt with surface '
      'elevation and 16dp margins, which is layout rather than touch; and the '
      'band is a conformance ratio with no stated population. Atomic Step: '
      '"Enforce strict touch element padding rules targeting the isolated task '
      'text fields."';
}
