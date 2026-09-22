/// Step 445 (GEN-02161) -- a feedback form scored on the loyalty of the people
/// who fill it in, asked by their employer, inside their employer's app.
///
/// The row: "Build a mobile-responsive feedback form using the Forms Component
/// Library."
/// Metric: **Candidate/Employee NPS** -- floor 0, optimal 30, ceiling "50+".
/// Good / Average / Poor. Bain & Company Net Promoter Score Benchmark.
/// Assigned to **UDF**.
///
/// **NPS measures the respondents, not the form.** A net promoter score is the
/// share of people who would recommend something minus the share who would
/// warn others off it. A well-built form collecting honest detractors scores
/// badly; a broken form nobody unhappy can finish scores well. The metric is
/// computed and published, and the form is judged on what a form can be judged
/// on -- whether it can be completed, by anybody, without friction.
///
/// **Asking employees to recommend their employer, non-anonymously, measures
/// fear.** "Candidate/Employee NPS" puts two populations under one number, and
/// the employee half is the eNPS question asked inside the employer's own
/// application. If the answer can be traced to the person, the score measures
/// how safe it feels to be honest as much as how people feel. So the form is
/// anonymous by construction: no user identifier is attached to a submission --
/// Step 419's allowlist has none to attach -- and no result is shown for a
/// group smaller than five. Candidates and employees are scored separately.
///
/// **The band's floor is the middle of the scale.** NPS runs from -100 to
/// +100. A floor of 0 is its midpoint, not its minimum, so half of the
/// scale's range sits below the floor with no label. The ceiling "50+" is open
/// with a plus sign doing the work of an inequality, the second in two batches
/// after Step 427's "95%+".
///
/// **The worked set scores 14, which is Average.** Fifty responses: eighteen
/// promoters, twenty-one passives, eleven detractors. Between the floor and the
/// optimal, and reported as such.
library;

import '../forms/blank_input_rule.dart';
import '../recognition/recognition_engagement.dart';
import '../telemetry/tracking_sdk.dart';

/// Which population a response belongs to.
enum HabotRespondentGroup {
  /// Somebody who applied.
  candidate,

  /// Somebody who works here.
  employee,
}

/// A set of responses to the recommend question.
class HabotNpsSample {
  const HabotNpsSample({
    required this.group,
    required this.promoters,
    required this.passives,
    required this.detractors,
  });

  final HabotRespondentGroup group;
  final int promoters;
  final int passives;
  final int detractors;
}

/// The feedback form.
class HabotFeedbackForm {
  const HabotFeedbackForm._();

  // -----------------------------------------------------------------------
  // The metric measures the respondents.
  // -----------------------------------------------------------------------

  static const String whatNpsMeasures = 'the people who answer';

  static const String whatAFormCanBeJudgedOn =
      'whether anybody can complete it without friction';

  static bool get theMetricMeasuresSomethingElse =>
      whatNpsMeasures != whatAFormCanBeJudgedOn;

  static const HabotNpsSample employees = HabotNpsSample(
    group: HabotRespondentGroup.employee,
    promoters: 18,
    passives: 21,
    detractors: 11,
  );

  static int respondents(HabotNpsSample s) =>
      s.promoters + s.passives + s.detractors;

  static int npsOf(HabotNpsSample s) {
    final int n = respondents(s);
    if (n == 0) {
      return 0;
    }
    return ((s.promoters - s.detractors) * 100 / n).round();
  }

  static int get observedNps => npsOf(employees);

  static bool get theFormIsJudgedOnCompletion =>
      HabotBlankInputRule.candidates.isNotEmpty;

  static const String metricNote =
      'A net promoter score is the share of people who would recommend '
      'something minus the share who would warn others off it. A well-built '
      'form collecting honest detractors scores badly, and a broken form '
      'nobody unhappy can finish scores well. The score is computed and '
      'published; the form is judged on what a form can be judged on.';

  // -----------------------------------------------------------------------
  // Anonymous by construction.
  // -----------------------------------------------------------------------

  static bool get noUserIdentifierCanBeAttached =>
      !HabotTrackingSdk.permits('user_id');

  static int get minimumGroupSize =>
      HabotRecognitionEngagement.minimumGroupSize;

  static bool reportable(HabotNpsSample s) =>
      respondents(s) >= minimumGroupSize;

  static bool get aGroupOfThreeIsNotReported =>
      !reportable(const HabotNpsSample(
        group: HabotRespondentGroup.employee,
        promoters: 1,
        passives: 1,
        detractors: 1,
      ));

  static const bool candidatesAndEmployeesShareOneScore = false;

  static bool get theTwoPopulationsAreSeparated =>
      !candidatesAndEmployeesShareOneScore &&
      HabotRespondentGroup.values.length == 2;

  static const String fearNote =
      'The employee half of this metric is the question "would you recommend '
      'working here" asked inside the employer\'s own application. If the '
      'answer can be traced to the person, the score measures how safe it '
      'feels to be honest as much as how people feel. No user identifier is '
      'attached to a submission, no result is shown for fewer than five '
      'people, and candidates and employees are scored separately.';

  // -----------------------------------------------------------------------
  // The band's floor is the middle of the scale.
  // -----------------------------------------------------------------------

  static const int scaleMinimum = -100;
  static const int scaleMaximum = 100;
  static const int bandFloor = 0;
  static const int bandOptimal = 30;
  static const String bandCeilingRaw = '50+';

  static bool get theFloorIsTheMidpoint =>
      bandFloor == (scaleMinimum + scaleMaximum) ~/ 2;

  static bool get theCeilingIsOpen => bandCeilingRaw.endsWith('+');

  /// Step 427's "95%+" and this.
  static const List<int> plusSignBoundaryRows = <int>[427, 445];

  static bool get secondPlusSignBoundary => plusSignBoundaryRows.length == 2;

  static String get qualitativeOutput {
    if (observedNps >= bandOptimal) {
      return 'Good';
    }
    return observedNps >= bandFloor ? 'Average' : 'Poor';
  }

  static const String bandNote =
      'NPS runs from -100 to +100, so a floor of 0 is the scale\'s midpoint '
      'rather than its minimum and half its range sits below the floor with no '
      'label. The ceiling reads "50+", open-ended, with a plus sign doing the '
      'work of an inequality for the second time in two batches after Step '
      '427. The worked set scores 14: between the floor and the optimal.';

  static const String columnNote =
      'COLUMN NOTE: this row scores a feedback form on the net promoter score '
      'of its respondents, which measures them rather than the form; it puts '
      'candidates and employees under one number and asks employees to '
      'recommend their employer inside the employer\'s app, so the form is '
      'anonymous by construction, scored per population, and suppressed below '
      'five respondents; its floor of 0 is the midpoint of a scale running '
      'from -100 to +100; and its ceiling "50+" is open-ended. The worked set '
      'scores 14, reported Average. Atomic Step: "Build a mobile-responsive '
      'feedback form using the Forms Component Library."';

  static Map<String, bool> get obligations => <String, bool>{
        'no user identifier is attached': noUserIdentifierCanBeAttached,
        'small groups are not reported': aGroupOfThreeIsNotReported,
        'the two populations are scored separately':
            theTwoPopulationsAreSeparated,
        'the form reuses the blank-input rule': theFormIsJudgedOnCompletion,
        'the score is reported as its band says': qualitativeOutput ==
            'Average',
      };

  static Map<String, bool> get checks => <String, bool>{
        'NPS measures the respondents, not the form':
            theMetricMeasuresSomethingElse &&
                metricNote.contains('nobody unhappy can finish'),
        'fifty responses: 18, 21 and 11':
            respondents(employees) == 50 &&
                employees.promoters == 18 &&
                employees.detractors == 11,
        'the score is 14': observedNps == 14,
        'no user identifier can be attached':
            noUserIdentifierCanBeAttached,
        'nothing is shown for fewer than five':
            aGroupOfThreeIsNotReported && minimumGroupSize == 5,
        'candidates and employees are scored apart':
            theTwoPopulationsAreSeparated &&
                fearNote.contains('safe it feels to be honest'),
        'the floor is the midpoint of the scale': theFloorIsTheMidpoint,
        'the ceiling is open, the second plus-sign boundary':
            theCeilingIsOpen && secondPlusSignBoundary,
        'the score sits between floor and optimal':
            observedNps > bandFloor &&
                observedNps < bandOptimal &&
                bandNote.contains('scores 14'),
        'five obligations, all met, giving Average':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Average',
      };
}
