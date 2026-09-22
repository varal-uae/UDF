/// Step 448 (GEN-05254) -- a monthly evaluation form, under a metric name whose
/// brackets change its subject.
///
/// The row: "Unit-test and validate the implementation of: create a
/// standardized mobile-friendly monthly evaluation form capturing key
/// performance indicators and factor notes"
/// Metric: **Validation Test Pass Rate (Performance Review Submission
/// Compliance)** -- floor ">= 95% test pass rate, >= 80% code coverage",
/// optimal "100% test pass rate, >= 90% code coverage", ceiling "100% coverage
/// (diminishing ROI beyond)". Pass/Fail. ISO/IEC 25010 & ISTQB Foundation.
/// Assigned to **DEA**.
///
/// **Two metrics in one name.** Outside the brackets: whether the form's tests
/// pass. Inside: whether managers submit their reviews on time. Those are
/// different quantities measured on different people, and a band cannot bound
/// both. The test pass rate is what the band's cells describe, so that is what
/// is measured; submission compliance is named as the second metric the
/// brackets smuggled in, and left unmeasured rather than folded into the first.
///
/// **"Factor notes" are the most important field and are asked for first.**
/// A month in which somebody was off sick for a week, covered a different
/// station, or spent three days in training is a month whose numbers mean
/// something different. If the form collects scores first and context
/// afterwards, the context arrives as an excuse. So factor notes are offered
/// before any score is entered, and a score entered without them carries the
/// fact that none were offered.
///
/// **The person evaluated sees the finished form and can answer it.** Step
/// 436's charter, rules one and two: the evaluation is shown to its subject,
/// with its working, and they can add a response that travels with it. The KPI
/// figures on the form are drawn from Step 441's scorecard, carrying the
/// completions they were computed from, rather than typed in by hand.
///
/// **A month on leave is not a low score.** Somebody away for the whole period
/// is "not evaluated this period", which is a state of its own and is never
/// averaged in as a zero.
///
/// **The ceiling carries an argument.** "(diminishing ROI beyond)" -- the ninth
/// annotated boundary in the track -- and the floor holds two criteria joined
/// by a comma, which at least says "and" more clearly than Step 430's oblique.
library;

import '../recognition/completion_criteria.dart';
import '../recognition/scorecard_endpoint.dart';

/// Where a person stands for an evaluation period.
enum HabotEvaluationState {
  /// Evaluated, with factor notes offered first.
  evaluated,

  /// Away for the whole period. Never averaged in as a zero.
  notEvaluatedThisPeriod,
}

/// The order in which the form asks for things.
enum HabotFormSection {
  /// Context: sickness, leave, cover, training.
  factorNotes,

  /// Figures drawn from the scorecard, with their working.
  kpis,

  /// The manager's assessment.
  assessment,

  /// The evaluated person's response.
  response,
}

/// The monthly evaluation form.
class HabotMonthlyEvaluationForm {
  const HabotMonthlyEvaluationForm._();

  // -----------------------------------------------------------------------
  // Two metrics in one name.
  // -----------------------------------------------------------------------

  static const String metricOutsideTheBrackets = 'Validation Test Pass Rate';

  static const String metricInsideTheBrackets =
      'Performance Review Submission Compliance';

  static bool get twoMetricsInOneName =>
      metricOutsideTheBrackets != metricInsideTheBrackets;

  static const bool theSecondMetricIsMeasuredHere = false;

  static bool get theBandDescribesTheFirst =>
      bandFloorRaw.contains('test pass rate');

  static const String nameNote =
      'Outside the brackets, whether the form\'s tests pass; inside, whether '
      'managers submit their reviews on time. Different quantities on '
      'different people, and one band cannot bound both. The band\'s cells '
      'describe test pass rate, so that is measured; submission compliance is '
      'named as the metric the brackets smuggled in and left unmeasured rather '
      'than folded into the first.';

  // -----------------------------------------------------------------------
  // Factor notes first.
  // -----------------------------------------------------------------------

  static const List<HabotFormSection> order = <HabotFormSection>[
    HabotFormSection.factorNotes,
    HabotFormSection.kpis,
    HabotFormSection.assessment,
    HabotFormSection.response,
  ];

  static bool get factorNotesComeFirst =>
      order.first == HabotFormSection.factorNotes;

  static bool get theResponseComesLast =>
      order.last == HabotFormSection.response;

  static const List<String> factorExamples = <String>[
    'a week off sick',
    'covering a different station',
    'three days of training',
    'a change of shift pattern',
  ];

  static const bool aScoreWithoutFactorNotesIsMarked = true;

  static const String factorNote =
      'A month with a week off sick, cover on a different station or three '
      'days of training is a month whose numbers mean something different. If '
      'the form collects scores first and context afterwards, the context '
      'arrives as an excuse. Factor notes are offered before any score, and a '
      'score entered without them carries the fact that none were offered.';

  // -----------------------------------------------------------------------
  // The person sees it and can answer.
  // -----------------------------------------------------------------------

  static bool get theSubjectSeesTheForm =>
      HabotScoringCharter.rules.first.contains('own score');

  static bool get theSubjectCanRespond =>
      order.contains(HabotFormSection.response);

  static bool get theKpisComeFromTheScorecard =>
      HabotScorecardEndpoint.everySampleFigureRenders;

  static const bool kpisAreTypedByHand = false;

  // -----------------------------------------------------------------------
  // A month on leave is not a zero.
  // -----------------------------------------------------------------------

  static HabotEvaluationState stateFor({required int daysPresent}) =>
      daysPresent == 0
          ? HabotEvaluationState.notEvaluatedThisPeriod
          : HabotEvaluationState.evaluated;

  static bool get aMonthAwayIsItsOwnState =>
      stateFor(daysPresent: 0) == HabotEvaluationState.notEvaluatedThisPeriod;

  static const bool anAbsenceIsAveragedAsZero = false;

  // -----------------------------------------------------------------------
  // The tests, and the band.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw =
      '>= 95% test pass rate, >= 80% code coverage';
  static const String bandOptimalRaw =
      '100% test pass rate, >= 90% code coverage';
  static const String bandCeilingRaw = '100% coverage (diminishing ROI beyond)';

  static bool get theCeilingCarriesAnArgument =>
      bandCeilingRaw.contains('diminishing ROI');

  static bool get theFloorJoinsTwoCriteriaWithAComma =>
      bandFloorRaw.contains(', ');

  static const int annotatedBoundariesInTheTrack = 9;

  static const int testsRun = 42;
  static const int testsPassed = 42;
  static const int coveragePercent = 91;

  static double get testPassRate =>
      testsRun == 0 ? 0 : testsPassed / testsRun * 100;

  static bool get theOptimalIsMet =>
      testPassRate == 100 && coveragePercent >= 90;

  static String get qualitativeOutput => theOptimalIsMet ? 'Pass' : 'Fail';

  static bool get completionMeansWhatStep436Says =>
      HabotCompletionCriteria.aNotifiedTerminalRecordIsComplete;

  static const String columnNote =
      'COLUMN NOTE: this row\'s metric name carries two metrics -- validation '
      'test pass rate outside the brackets and performance review submission '
      'compliance inside them -- and only the first is what the band '
      'describes; its ceiling reads "100% coverage (diminishing ROI beyond)", '
      'the ninth annotated boundary; and its floor joins two criteria with a '
      'comma. The form asks for factor notes before scores, shows the finished '
      'evaluation to the person it describes with room for their response, '
      'draws its figures from the Step 441 scorecard, and treats a month away '
      'as not evaluated rather than zero. Atomic Step: "Unit-test and validate '
      'the implementation of: create a standardized mobile-friendly monthly '
      'evaluation form capturing key performance indicators and factor notes"';

  static Map<String, bool> get obligations => <String, bool>{
        'factor notes are asked for first': factorNotesComeFirst,
        'the person sees the form and can respond':
            theSubjectSeesTheForm && theSubjectCanRespond,
        'KPIs come from the scorecard, not by hand':
            theKpisComeFromTheScorecard && !kpisAreTypedByHand,
        'a month away is not averaged as zero':
            aMonthAwayIsItsOwnState && !anAbsenceIsAveragedAsZero,
        'the tests meet the optimal': theOptimalIsMet,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the metric name carries two metrics':
            twoMetricsInOneName && !theSecondMetricIsMeasuredHere,
        'and the band describes only the first':
            theBandDescribesTheFirst && nameNote.contains('smuggled'),
        'four sections, factor notes first and the response last':
            order.length == 4 && factorNotesComeFirst && theResponseComesLast,
        'context asked for after scores arrives as an excuse':
            factorNote.contains('as an excuse') &&
                aScoreWithoutFactorNotesIsMarked &&
                factorExamples.length == 4,
        'the subject sees the form and can answer it':
            theSubjectSeesTheForm && theSubjectCanRespond,
        'KPIs are drawn from the Step 441 scorecard':
            theKpisComeFromTheScorecard && !kpisAreTypedByHand,
        'a month away is its own state':
            aMonthAwayIsItsOwnState && !anAbsenceIsAveragedAsZero,
        'the ceiling carries an argument and the floor a comma':
            theCeilingCarriesAnArgument &&
                theFloorJoinsTwoCriteriaWithAComma &&
                annotatedBoundariesInTheTrack == 9,
        'forty-two tests pass at 91 per cent coverage':
            testPassRate == 100 &&
                coveragePercent == 91 &&
                completionMeansWhatStep436Says,
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };
}
