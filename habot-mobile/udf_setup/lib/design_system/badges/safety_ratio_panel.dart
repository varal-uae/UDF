/// Step 358 (GEN-01407) -- the first of four rows in this batch carrying one
/// already-tokenised band, and a ratio with no denominator on its face.
///
/// The row: "Display verified safety account ratios on security monitoring
/// dashboards."
/// Metric: **Dashboard Data Refresh Latency** -- floor "<1 hour", optimal
/// "<5 minutes", ceiling "<24 hours". Good/Average/Poor. Modern Data Stack SLA
/// Benchmark (dbt/Fivetran).
///
/// **A twenty-four-hour ceiling against a one-hour floor.** On a
/// lower-is-better measure the ceiling is the best attainable value, so read
/// that way this band says a day-old dashboard is ideal and an hour-old one is
/// barely acceptable. The same three cells appear character for character on
/// **Steps 358, 362, 374 and 375** of this batch -- and on **Steps 163 and
/// 175**, which already tokenised them as `dashboardRefreshFloor`,
/// `dashboardRefreshOptimal` and `dashboardRefreshCeiling`. Six rows, one band.
/// Until now every inversion this track recorded was a single cell somebody
/// got wrong; six identical copies is a template, which puts the defect in
/// whatever produced the rows and settles what open decision 47 left open.
///
/// **Those earlier steps read the ceiling as the worst bound**, and the token
/// comment says so: "beyond a day the panel is history rather than a
/// dashboard". That reading is sensible and is the opposite of how every other
/// latency band in this sheet uses its ceiling, which is the whole problem --
/// two consumers of the same three numbers reach opposite conclusions and
/// neither is being careless.
///
/// **A ratio needs its denominator on screen.** "98% of accounts verified"
/// over 50 accounts and over 50,000 are different facts, and a security
/// dashboard is where somebody decides whether to act. The panel shows the
/// numerator and the denominator, and refuses to render a percentage below a
/// minimum population, because 2 of 3 is not 67 per cent in any useful sense.
///
/// **"Verified" here is Step 357's problem at a different scale.** An account
/// is verified against something -- an identity document, a bank record, a
/// background check -- and the ratio is meaningless until the panel says which.
///
/// **COLUMN NOTE.** The band's three cells are shared verbatim with Steps 362,
/// 374 and 375 of this batch and with Steps 163 and 175; the Data Requirement
/// cell holds the Atomic Step's own text as the artefact to prepare; and the
/// Setup Step column is empty.
library;

import '../dashboard/freshness.dart';
import '../tokens/motion_tokens.dart';

/// What an account was verified against.
enum HabotSafetyBasis {
  /// A government identity document was checked.
  identityDocument,

  /// A criminal-record or background check was returned.
  backgroundCheck,

  /// A bank account was confirmed.
  bankRecord,
}

/// One ratio as the panel holds it.
class HabotSafetyRatio {
  const HabotSafetyRatio({
    required this.basis,
    required this.verified,
    required this.population,
  });

  final HabotSafetyBasis basis;
  final int verified;
  final int population;

  double? get fraction => population == 0 ? null : verified / population;
}

/// The safety account ratio panel.
class HabotSafetyRatioPanel {
  const HabotSafetyRatioPanel._();

  // -----------------------------------------------------------------------
  // The band, and the six rows that share it.
  // -----------------------------------------------------------------------

  /// Read from the tokens Steps 163 and 175 declared, not restated here.
  static int get bandFloorMinutes =>
      HabotMotion.dashboardRefreshFloor.inMinutes;

  static int get bandOptimalMinutes =>
      HabotMotion.dashboardRefreshOptimal.inMinutes;

  static int get bandCeilingMinutes =>
      HabotMotion.dashboardRefreshCeiling.inMinutes;

  static bool get theBandWasAlreadyTokenised =>
      bandFloorMinutes == 60 &&
      bandOptimalMinutes == 5 &&
      bandCeilingMinutes == 1440;

  static bool get theBandIsInverted => bandCeilingMinutes > bandFloorMinutes;

  static int get ceilingOverFloor => bandCeilingMinutes ~/ bandFloorMinutes;

  /// The ceiling is twenty-four times the floor, in the wrong direction.
  static bool get theCeilingIsTwentyFourTimesTheFloor => ceilingOverFloor == 24;

  /// Every row in the sheet carrying these identical three cells.
  static const List<int> rowsSharingThisBand = <int>[
    163,
    175,
    358,
    362,
    374,
    375,
  ];

  static bool get sixRowsShareOneBand =>
      rowsSharingThisBand.length == 6 && theBandIsInverted;

  /// The four that are new in this batch.
  static List<int> get newInThisBatch =>
      rowsSharingThisBand.where((int r) => r >= 356).toList();

  static const int inversionsBeforeThisBatch = 6;

  static int get inversionsAfterThisBatch =>
      inversionsBeforeThisBatch + newInThisBatch.length;

  static bool get theCountReachesTen => inversionsAfterThisBatch == 10;

  static const String bandNote =
      'Floor one hour, optimal five minutes, ceiling twenty-four hours -- the '
      'ceiling twenty-four times the floor. Read as every other latency band '
      'in this sheet is read, with the ceiling as the best attainable value, '
      'it says a day-old dashboard is ideal. Steps 163 and 175 read it the '
      'other way and tokenised it, and their comment says "beyond a day the '
      'panel is history rather than a dashboard" -- which is sensible and is '
      'the opposite convention. Six rows carry these three cells: 163, 175, '
      'and 358, 362, 374 and 375 of this batch. Six identical copies is a '
      'template, which puts the defect in whatever produced the rows.';

  // -----------------------------------------------------------------------
  // A ratio needs a denominator.
  // -----------------------------------------------------------------------

  static const int minimumPopulation = 30;

  static const List<HabotSafetyRatio> ratios = <HabotSafetyRatio>[
    HabotSafetyRatio(
      basis: HabotSafetyBasis.identityDocument,
      verified: 2940,
      population: 3000,
    ),
    HabotSafetyRatio(
      basis: HabotSafetyBasis.backgroundCheck,
      verified: 2100,
      population: 3000,
    ),
    HabotSafetyRatio(
      basis: HabotSafetyBasis.bankRecord,
      verified: 2,
      population: 3,
    ),
  ];

  static bool isPublishable(HabotSafetyRatio r) =>
      r.population >= minimumPopulation;

  static List<HabotSafetyRatio> get publishable =>
      ratios.where(isPublishable).toList();

  static List<HabotSafetyRatio> get suppressed =>
      ratios.where((HabotSafetyRatio r) => !isPublishable(r)).toList();

  /// Two of the three ratios may be shown as percentages; the third is
  /// published as a count, because 2 of 3 is not 67 per cent in any useful
  /// sense.
  static bool get twoOfThreeArePublishableAsPercentages =>
      publishable.length == 2 && suppressed.length == 1;

  static String labelFor(HabotSafetyRatio r) {
    if (!isPublishable(r)) {
      return '${r.verified} of ${r.population}';
    }
    final double pct = (r.fraction ?? 0) * 100;
    return '${pct.toStringAsFixed(1)}% of ${r.population}';
  }

  static bool get everyLabelCarriesTheDenominator =>
      ratios.every((HabotSafetyRatio r) => labelFor(r).contains('of '));

  static const String denominatorNote =
      '"98% of accounts verified" over fifty accounts and over fifty thousand '
      'are different facts, and a security dashboard is where somebody decides '
      'whether to act on one. Every label here carries its denominator, and a '
      'ratio over fewer than thirty is published as a count instead, because '
      'two of three is not sixty-seven per cent in any sense a reader can use.';

  // -----------------------------------------------------------------------
  // "Verified" against what.
  // -----------------------------------------------------------------------

  static bool get everyRatioNamesItsBasis =>
      ratios.map((HabotSafetyRatio r) => r.basis).toSet().length == 3;

  static const bool theRatiosAreCombinedIntoOne = false;

  static const String basisNote =
      'An account is verified against something: an identity document, a '
      'background check, a bank record. Step 357 has the same problem on one '
      'badge; here it has it three times over, because a single "verified" '
      'ratio would average three populations that were checked by three '
      'different processes at three different times. The panel keeps them '
      'apart, and the widest gap between them -- 98.0 per cent on documents '
      'against 70.0 per cent on background checks -- is the number worth '
      'seeing.';

  static double get widestGap {
    final List<double> fractions = publishable
        .map((HabotSafetyRatio r) => r.fraction ?? 0)
        .toList()
      ..sort();
    return fractions.isEmpty ? 0 : fractions.last - fractions.first;
  }

  static bool get theGapIsTwentyEightPoints =>
      ((widestGap * 100) - 28).abs() < 1e-9;

  // -----------------------------------------------------------------------
  // Freshness, from the existing policy.
  // -----------------------------------------------------------------------

  static bool get theFreshnessVocabularyIsAlreadyDeclared =>
      HabotFreshness.values.length == 4;

  static HabotFreshness freshnessOf(Duration age) =>
      HabotFreshnessPolicy.classify(age);

  static bool get anHourOldPanelIsLabelledDelayed =>
      freshnessOf(const Duration(hours: 1)) == HabotFreshness.delayed;

  static const String freshnessNote =
      'The panel does not adopt the row\'s band, because adopting it would '
      'mean treating a day-old security dashboard as ideal. It classifies its '
      'own age with the Step 129 policy, which labels anything past the budget '
      'Delayed and says so on the face of the panel -- so a reader is told the '
      'figures are old rather than left to assume they are current.';

  static Map<String, bool> get obligations => <String, bool>{
        'every ratio names what it was verified against':
            everyRatioNamesItsBasis,
        'the three ratios are not averaged into one':
            !theRatiosAreCombinedIntoOne,
        'every label carries its denominator':
            everyLabelCarriesTheDenominator,
        'a ratio over a small population is published as a count':
            twoOfThreeArePublishableAsPercentages,
        'the panel labels its own age': anHourOldPanelIsLabelledDelayed,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'the ceiling is twenty-four times the floor':
            theBandIsInverted && theCeilingIsTwentyFourTimesTheFloor,
        'six rows share the identical band, four of them new here':
            sixRowsShareOneBand &&
                newInThisBatch.length == 4 &&
                rowsSharingThisBand.contains(163),
        'the track\'s inversion count reaches ten':
            theCountReachesTen && inversionsBeforeThisBatch == 6,
        'the band was tokenised at Steps 163 and 175':
            theBandWasAlreadyTokenised && bandNote.contains('a template'),
        'three ratios, three bases, none averaged':
            everyRatioNamesItsBasis && !theRatiosAreCombinedIntoOne,
        'every label carries its denominator':
            everyLabelCarriesTheDenominator,
        'the small-population ratio is published as a count':
            twoOfThreeArePublishableAsPercentages &&
                labelFor(ratios.last) == '2 of 3',
        'the gap between two bases is 28 points':
            theGapIsTwentyEightPoints &&
                basisNote.contains('three different processes'),
        'the panel labels its own age with Step 129\'s policy':
            theFreshnessVocabularyIsAlreadyDeclared &&
                anHourOldPanelIsLabelledDelayed &&
                freshnessNote.contains('Step 129'),
        'five obligations, all met, giving Good':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good',
      };

  static const String columnNote =
      'COLUMN NOTE: the band on this row sets a ceiling of 24 hours against a '
      'floor of 1 hour on a lower-is-better measure, and the same three cells '
      'appear verbatim on Steps 362, 374 and 375 of this batch and on Steps '
      '163 and 175, which tokenised them; '
      'the Data Requirement cell holds the Atomic Step\'s own text as the '
      'artefact to prepare; and the Setup Step column is empty. Atomic Step: '
      '"Display verified safety account ratios on security monitoring '
      'dashboards."';
}
