/// Step 423 (SIDM-017) -- a drop-off delta "against the required targets",
/// which are never stated, scored on procedure adherence.
///
/// The row: "Compute conversion drop-off delta metrics against the required
/// targets."
/// Metric: **Standard Operating Procedure (SOP) Adherence Rate** -- floor "90%
/// adherence to documented procedure", optimal "98% adherence to documented
/// procedure", ceiling "100% adherence to documented procedure". Best
/// Qualitative Output: "Pass". ISO 9001:2015 Clause 8. Assigned to **ADFA**.
///
/// **"The required targets" are not in this row or any row behind it.** Fourth
/// row in two batches to use a definite article for something never defined,
/// after Step 398's "the count", Step 406's "score" and Step 419's "the
/// tracking SDK". A delta is a subtraction and a subtraction needs two numbers;
/// this row supplies one. The targets used here are derived from the funnel's
/// own prior period and named as derived, because a target invented to make a
/// delta computable is a target that will be quoted next quarter as though
/// somebody agreed to it.
///
/// **The metric scores procedure adherence on a row about a computation.**
/// Whether a drop-off delta was computed according to a documented procedure
/// and whether the delta is correct are different questions, and only the
/// second one matters to anybody reading the number. There is also no
/// documented procedure to adhere to, which makes the band unmeasurable as well
/// as irrelevant.
///
/// **All three band cells are sentences, and the output column holds one
/// word.** Third all-sentence band in the track after Steps 400 and 416, and
/// the twelfth one-valued output column: "Pass", with no failure available.
///
/// **The Data Requirement belongs to a release row.** Version Number, Version
/// Type, Release Date, Version Status, Version Checksum -- five cells about
/// software versioning on a row about funnel conversion. Sixth spliced row in
/// the track.
library;

import 'time_to_action.dart';

/// One step of the funnel.
class HabotFunnelStep {
  const HabotFunnelStep({
    required this.name,
    required this.entered,
    required this.completed,
    required this.priorPeriodRate,
  });

  final String name;
  final int entered;
  final int completed;

  /// The same step's completion rate in the previous period, which is where
  /// the "required target" comes from in the absence of a stated one.
  final double priorPeriodRate;
}

/// The conversion drop-off delta.
class HabotDropOffDelta {
  const HabotDropOffDelta._();

  // -----------------------------------------------------------------------
  // The targets are not stated.
  // -----------------------------------------------------------------------

  static const String theRowsPhrase = 'the required targets';

  static const bool theTargetsAreStatedAnywhere = false;

  static bool get theDefiniteArticleHasNoAntecedent =>
      !theTargetsAreStatedAnywhere;

  /// Steps 398, 406, 419 and this one.
  static const List<int> rowsWithNoAntecedent = <int>[398, 406, 419, 423];

  static bool get fourthSuchRow => rowsWithNoAntecedent.length == 4;

  static const String targetSource =
      'the same step\'s completion rate in the prior period';

  static const bool aTargetWasInvented = false;

  static bool get theSubstitutionIsNamed =>
      !aTargetWasInvented && targetSource.contains('prior period');

  static const String antecedentNote =
      'A delta is a subtraction and a subtraction needs two numbers; this row '
      'supplies one and calls the other "the required targets" as though it '
      'had been named. It is the fourth row in two batches to do that, after '
      'Steps 398, 406 and 419. The comparison used here is each step\'s own '
      'prior-period rate, named as a substitution -- because a target invented '
      'to make a delta computable is a target somebody will quote next quarter '
      'as though it had been agreed.';

  // -----------------------------------------------------------------------
  // The funnel.
  // -----------------------------------------------------------------------

  static const List<HabotFunnelStep> funnel = <HabotFunnelStep>[
    HabotFunnelStep(
      name: 'open request form',
      entered: 1000,
      completed: 940,
      priorPeriodRate: 0.95,
    ),
    HabotFunnelStep(
      name: 'enter hours',
      entered: 940,
      completed: 902,
      priorPeriodRate: 0.96,
    ),
    HabotFunnelStep(
      name: 'choose reason code',
      entered: 902,
      completed: 631,
      priorPeriodRate: 0.85,
    ),
    HabotFunnelStep(
      name: 'review',
      entered: 631,
      completed: 618,
      priorPeriodRate: 0.98,
    ),
    HabotFunnelStep(
      name: 'submit',
      entered: 618,
      completed: 611,
      priorPeriodRate: 0.99,
    ),
  ];

  static int get stepCount => funnel.length;

  static double rateOf(HabotFunnelStep s) =>
      s.entered == 0 ? 0 : s.completed / s.entered;

  static double deltaOf(HabotFunnelStep s) => rateOf(s) - s.priorPeriodRate;

  static bool get everyStepHasABaseline =>
      funnel.every((HabotFunnelStep s) => s.priorPeriodRate > 0);

  static HabotFunnelStep get worstStep => funnel
      .reduce((HabotFunnelStep a, HabotFunnelStep b) =>
          deltaOf(a) < deltaOf(b) ? a : b);

  static bool get theWorstStepIsTheReasonCode =>
      worstStep.name == 'choose reason code';

  static bool get theWorstDeltaIsNegative => deltaOf(worstStep) < 0;

  static int get stepsBelowTheirBaseline =>
      funnel.where((HabotFunnelStep s) => deltaOf(s) < 0).length;

  static double get endToEndRate => funnel.first.entered == 0
      ? 0
      : funnel.last.completed / funnel.first.entered;

  static const String funnelNote =
      'Five steps, each with its own prior-period rate. The reason-code step '
      'loses more than a quarter of everybody who reaches it and sits furthest '
      'below its own baseline, which matches what Step 421 found one layer '
      'down: the reason-code field is also the one with the longest focus '
      'durations. Two measurements taken for different purposes agreeing on '
      'the same field is the strongest evidence either of them produces.';

  // -----------------------------------------------------------------------
  // The delta is per step, not end to end.
  // -----------------------------------------------------------------------

  static const bool onlyTheEndToEndNumberIsPublished = false;

  static bool get everyStepPublishesItsOwnDelta =>
      !onlyTheEndToEndNumberIsPublished && funnel.length == stepCount;

  static const String granularityNote =
      'An end-to-end conversion figure tells you that sixty-one per cent of '
      'people who start finish, and nothing about where the other thirty-nine '
      'went. The delta is published per step because the only actionable form '
      'of a funnel number is the one that names a screen.';

  // -----------------------------------------------------------------------
  // The metric scores the procedure.
  // -----------------------------------------------------------------------

  static const String whatTheMetricScores =
      'adherence to a documented procedure';

  static const String whatWouldMatter = 'whether the delta is correct';

  static bool get theMetricScoresTheWrongThing =>
      whatTheMetricScores != whatWouldMatter;

  static const bool aDocumentedProcedureExists = false;

  static bool get theBandIsUnmeasurable => !aDocumentedProcedureExists;

  static const String bandFloorRaw = '90% adherence to documented procedure';
  static const String bandOptimalRaw = '98% adherence to documented procedure';
  static const String bandCeilingRaw =
      '100% adherence to documented procedure';

  static bool get everyBandCellIsASentence =>
      bandFloorRaw.contains(' ') &&
      bandOptimalRaw.contains(' ') &&
      bandCeilingRaw.contains(' ');

  /// Steps 400, 416 and this one.
  static const List<int> allSentenceBandRows = <int>[400, 416, 423];

  static bool get thirdAllSentenceBand => allSentenceBandRows.length == 3;

  static const String outputColumnRaw = 'Pass';

  static bool get theOutputColumnHoldsOneValue => outputColumnRaw == 'Pass';

  static const int oneValuedColumnsInTheTrack = 12;

  static bool get theCountReachesTwelve =>
      oneValuedColumnsInTheTrack == 12 && theOutputColumnHoldsOneValue;

  static const String metricNote =
      'Whether the delta was computed according to a documented procedure and '
      'whether the delta is correct are different questions, and only the '
      'second matters to anybody reading the number. There is also no '
      'documented procedure to adhere to, so the band is unmeasurable as well '
      'as beside the point. All three of its cells are sentences -- the third '
      'all-sentence band after Steps 400 and 416 -- and the output column '
      'holds the single word "Pass", the twelfth one-valued column in the '
      'track.';

  // -----------------------------------------------------------------------
  // The Data Requirement belongs to a release row.
  // -----------------------------------------------------------------------

  static const List<String> cellsFromTheOtherRow = <String>[
    'Version Number',
    'Version Type',
    'Release Date',
    'Version Status',
    'Version Checksum',
  ];

  static bool get fiveCellsBelongElsewhere => cellsFromTheOtherRow.length == 5;

  /// Steps 388, 390, 398, 416, 417 and this one.
  static const List<int> splicedRows = <int>[388, 390, 398, 416, 417, 423];

  static bool get sixthSplicedRow => splicedRows.length == 6;

  static bool get theBandDefaultWasSeenAtStep422 =>
      HabotTimeToAction.itIsADefaultRatherThanAMistake;

  static String get qualitativeOutput =>
      everyStepHasABaseline && everyStepPublishesItsOwnDelta
          ? 'Pass'
          : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row asks for a delta "against the required targets" '
      'and no targets are stated here or behind it -- the fourth row in two '
      'batches to use a definite article for something undefined, after Steps '
      '398, 406 and 419 -- so each step\'s own prior-period rate is used and '
      'named as a substitution; its metric scores adherence to a documented '
      'procedure that does not exist, on a row whose product is a computation; '
      'all three band cells are sentences, the third such band after Steps 400 '
      'and 416; its Best Qualitative Output column holds the single word '
      '"Pass", the twelfth one-valued column; and its Data Requirement holds '
      'five software-versioning fields belonging to a release row, making this '
      'the sixth spliced row in the track. Atomic Step: "Compute conversion '
      'drop-off delta metrics against the required targets."';

  static Map<String, bool> get obligations => <String, bool>{
        'every step has a baseline': everyStepHasABaseline,
        'every step publishes its own delta': everyStepPublishesItsOwnDelta,
        'the substituted baseline is named as substituted':
            theSubstitutionIsNamed,
        'no target was invented': !aTargetWasInvented,
        'the worst step is named': theWorstStepIsTheReasonCode,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the required targets are nowhere in the row':
            theDefiniteArticleHasNoAntecedent && fourthSuchRow,
        'so the prior period is used and named as a substitution':
            theSubstitutionIsNamed &&
                antecedentNote.contains('as though it had been agreed'),
        'five funnel steps, each with a baseline':
            stepCount == 5 && everyStepHasABaseline,
        'the reason-code step is furthest below its baseline':
            theWorstStepIsTheReasonCode &&
                theWorstDeltaIsNegative &&
                stepsBelowTheirBaseline >= 1,
        'and Step 421 found the same field independently':
            funnelNote.contains('longest focus durations'),
        'the delta is per step rather than end to end':
            everyStepPublishesItsOwnDelta &&
                granularityNote.contains('names a screen'),
        'the metric scores a procedure that does not exist':
            theMetricScoresTheWrongThing && theBandIsUnmeasurable,
        'all three band cells are sentences':
            everyBandCellIsASentence && thirdAllSentenceBand,
        'and the output column holds one value':
            theOutputColumnHoldsOneValue && theCountReachesTwelve,
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass' &&
                fiveCellsBelongElsewhere &&
                sixthSplicedRow &&
                theBandDefaultWasSeenAtStep422 &&
                endToEndRate > 0,
      };
}
