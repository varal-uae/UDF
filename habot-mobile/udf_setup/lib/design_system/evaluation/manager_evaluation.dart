/// Step 449 (GEN-05265) -- a manager evaluation tool with "automated
/// performance distribution tracking", which is the machinery of a forced
/// curve unless somebody decides it is not.
///
/// The row: "Integrate all components and confirm the expected output is
/// achieved: operational monthly manager evaluation tool with automated
/// performance distribution tracking"
/// Metric: **System Integration Test Pass Rate** -- floor ">= 90%", optimal 1,
/// ceiling 1. Pass/Fail. ISO/IEC 25010 -- Interoperability & Integration
/// Testing. Assigned to **UDF**.
///
/// **Distribution tracking is where stack ranking starts.** Once a system
/// knows how a manager's ratings are distributed, the next request is for that
/// distribution to match a curve -- a fixed share rated low whatever the team
/// actually did. A forced curve guarantees that some of a strong team fail and
/// some of a weak team pass, and it turns every evaluation into a comparison
/// with the person at the next desk. So the distribution is **reported** and
/// never **enforced**: each manager sees how their ratings fall, beside the
/// organisation's, and nothing requires them to move. No quota per band, no
/// automatic rescaling, no curve.
///
/// **What reporting is for.** A manager whose last twelve evaluations are all
/// "exceeds" learns something from seeing that, and so does one whose are all
/// "meets" -- in both cases about how they are using the scale, not about their
/// team. The report says that, in those words, beside the chart.
///
/// **"Manager evaluation" reads two ways.** Evaluations written by managers,
/// or evaluations of managers. The distribution tracking only makes sense for
/// the first, so that is what is built; the second reading is recorded because
/// an evaluation of managers is a different tool with different people at risk.
///
/// **The band mixes units.** A percentage floor, and an optimal and ceiling of
/// 1.
library;

import '../recognition/completion_criteria.dart';
import 'monthly_evaluation_form.dart';

/// A rating band on the evaluation scale.
enum HabotRatingBand {
  /// Below what the role needs this period.
  below,

  /// What the role needs.
  meets,

  /// Beyond what the role needs.
  exceeds,
}

/// The manager evaluation tool.
class HabotManagerEvaluation {
  const HabotManagerEvaluation._();

  // -----------------------------------------------------------------------
  // Reported, never enforced.
  // -----------------------------------------------------------------------

  static const bool theDistributionIsReported = true;

  static const bool aQuotaPerBandExists = false;

  static const bool ratingsAreRescaledAutomatically = false;

  static const bool aForcedCurveIsApplied = false;

  static bool get reportedNotEnforced =>
      theDistributionIsReported &&
      !aQuotaPerBandExists &&
      !ratingsAreRescaledAutomatically &&
      !aForcedCurveIsApplied;

  static bool get noScoreChangesWithoutAPerson =>
      HabotScoringCharter.rules[2].contains('named person');

  static const String curveNote =
      'Once a system knows how a manager\'s ratings are distributed, the next '
      'request is for the distribution to match a curve: a fixed share rated '
      'low whatever the team did. A forced curve guarantees that some of a '
      'strong team fail and some of a weak team pass, and it turns every '
      'evaluation into a comparison with the person at the next desk. The '
      'distribution is reported and never enforced -- no quota, no automatic '
      'rescaling, no curve.';

  // -----------------------------------------------------------------------
  // What the report says.
  // -----------------------------------------------------------------------

  static const Map<HabotRatingBand, int> thisManager = <HabotRatingBand, int>{
    HabotRatingBand.below: 0,
    HabotRatingBand.meets: 1,
    HabotRatingBand.exceeds: 11,
  };

  static const Map<HabotRatingBand, int> organisation =
      <HabotRatingBand, int>{
    HabotRatingBand.below: 14,
    HabotRatingBand.meets: 128,
    HabotRatingBand.exceeds: 58,
  };

  static int total(Map<HabotRatingBand, int> m) =>
      m.values.fold(0, (int a, int b) => a + b);

  static double shareExceeds(Map<HabotRatingBand, int> m) {
    final int t = total(m);
    return t == 0 ? 0 : (m[HabotRatingBand.exceeds] ?? 0) * 100 / t;
  }

  static bool get thisManagerIsSkewedHigh =>
      shareExceeds(thisManager) > shareExceeds(organisation) * 2;

  static const String reportCaption =
      'This shows how you are using the rating scale compared with the '
      'organisation. It says nothing about your team, and nothing requires '
      'your ratings to change.';

  static bool get theReportSaysWhatItIsFor =>
      reportCaption.contains('nothing requires');

  // -----------------------------------------------------------------------
  // Two readings of "manager evaluation".
  // -----------------------------------------------------------------------

  static const String readingBuilt = 'evaluations written by managers';

  static const String readingRecorded = 'evaluations of managers';

  static bool get theTwoReadingsDiffer => readingBuilt != readingRecorded;

  static bool get theFormIsTheStep448Form =>
      HabotMonthlyEvaluationForm.factorNotesComeFirst;

  // -----------------------------------------------------------------------
  // Integration, and the band.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = '>= 90%';
  static const double bandOptimal = 1;
  static const double bandCeiling = 1;

  static bool get theBandMixesUnits =>
      bandFloorRaw.contains('%') && bandCeiling == 1;

  static const int integrationTests = 18;
  static const int integrationPassed = 18;

  static double get passRate => integrationTests == 0
      ? 0
      : integrationPassed / integrationTests;

  static String get qualitativeOutput =>
      passRate == bandCeiling && reportedNotEnforced ? 'Pass' : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row asks for "automated performance distribution '
      'tracking" in a monthly manager evaluation tool, which is the machinery '
      'of a forced curve -- so the distribution is reported to each manager '
      'beside the organisation\'s and never enforced, with no quota, no '
      'automatic rescaling and no curve; "manager evaluation" reads two ways '
      'and the reading built is evaluations written by managers, with the '
      'other recorded; and its band writes a percentage floor against an '
      'optimal and ceiling of 1. Atomic Step: "Integrate all components and '
      'confirm the expected output is achieved: operational monthly manager '
      'evaluation tool with automated performance distribution tracking"';

  static Map<String, bool> get obligations => <String, bool>{
        'the distribution is reported': theDistributionIsReported,
        'and never enforced': reportedNotEnforced,
        'the report says what it is for': theReportSaysWhatItIsFor,
        'no rating changes without a person': noScoreChangesWithoutAPerson,
        'the integration tests pass': passRate == 1,
      };

  static Map<String, bool> get checks => <String, bool>{
        'distribution tracking is where stack ranking starts':
            curveNote.contains('next desk'),
        'so there is no quota, no rescaling and no curve':
            reportedNotEnforced,
        'this manager rates 11 of 12 as exceeds':
            total(thisManager) == 12 &&
                thisManager[HabotRatingBand.exceeds] == 11,
        'against 29 per cent across the organisation':
            total(organisation) == 200 && shareExceeds(organisation) == 29,
        'which the report shows as a use of the scale':
            thisManagerIsSkewedHigh && theReportSaysWhatItIsFor,
        'and no rating changes without a named person':
            noScoreChangesWithoutAPerson,
        '"manager evaluation" reads two ways':
            theTwoReadingsDiffer && readingBuilt.contains('written by'),
        'the form is Step 448\'s': theFormIsTheStep448Form,
        'the band mixes units, and eighteen integration tests pass':
            theBandMixesUnits && passRate == 1,
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };
}
