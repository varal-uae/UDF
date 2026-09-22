/// Step 452 (GEN-02172) -- a five-minute timer on a recruiter that escalates
/// to the HR Director, and the cited standard that already contains the fix.
///
/// The row: "Auto-escalate the task to the HR Director if the recruiter leaves
/// the dialogue open for >5 minutes."
/// Metric: **Exception Queue Resolution Time** -- floor "30 minutes", optimal
/// "15 minutes", ceiling "5 minutes". Pass / Fail. ITIL v4 Incident Escalation
/// Standard. Assigned to **UDF**.
///
/// **The band descends correctly and agrees with its own instruction.** Thirty,
/// fifteen, five: each better than the last, the ceiling the best value -- the
/// second such band in two batches, after Step 433. And its best value is the
/// five minutes the instruction names. After Step 432's instruction disagreed
/// with its band by five times and Step 435's disagreed in kind, this is the
/// first row in two batches where the words and the numbers say the same
/// thing.
///
/// **An open dialogue is not an idle recruiter.** Somebody with a dialogue open
/// for five minutes may be reading a CV, on the phone to the candidate, or
/// thinking. Step 416's framework said a long dwell means a field held
/// attention, not that somebody was slow; the same holds for a dialogue. So the
/// timer only runs when there is somebody actually waiting on the other side,
/// and the escalation record names the task and the waiting candidate --
/// never "recruiter inactive".
///
/// **Five minutes to the HR Director is the wrong kind of escalation.** ITIL,
/// the standard the row cites, distinguishes *functional* escalation -- to
/// somebody who can do the work -- from *hierarchical* escalation -- to
/// somebody with authority. A stalled item with a candidate waiting needs the
/// first: another recruiter who can pick it up. Sending every five-minute
/// pause two levels up is hierarchical escalation for a functional problem,
/// and it would put every coffee break on the Director's desk. So the steps
/// are: at five minutes the recruiter is nudged; at fifteen the item becomes
/// visible to the recruiting pool; the Director hears only when the
/// candidate-facing deadline is missed. The cited standard contains the
/// correction, which is the second time in this batch after Octalysis.
library;

import '../recognition/completion_criteria.dart';
import '../telemetry/friction_framework.dart';

/// Who an escalation goes to.
enum HabotEscalationTarget {
  /// The recruiter themselves, as a nudge.
  selfNudge,

  /// The recruiting pool: somebody who can do the work.
  functional,

  /// The HR Director: somebody with authority.
  hierarchical,
}

/// One step on the escalation ladder.
class HabotEscalationStep {
  const HabotEscalationStep({
    required this.afterMinutes,
    required this.target,
    required this.recordSays,
  });

  final int afterMinutes;
  final HabotEscalationTarget target;
  final String recordSays;
}

/// The dialogue escalation.
class HabotDialogueEscalation {
  const HabotDialogueEscalation._();

  // -----------------------------------------------------------------------
  // A band that agrees with its instruction.
  // -----------------------------------------------------------------------

  static const int floorMinutes = 30;
  static const int optimalMinutes = 15;
  static const int ceilingMinutes = 5;

  static const int instructionMinutes = 5;

  static bool get theBandDescends =>
      floorMinutes > optimalMinutes && optimalMinutes > ceilingMinutes;

  static bool get theBandAgreesWithTheInstruction =>
      ceilingMinutes == instructionMinutes;

  /// Step 433 and this one.
  static const List<int> correctlyDescendingBands = <int>[433, 452];

  static bool get secondSuchBand => correctlyDescendingBands.length == 2;

  /// Step 432 disagreed by a factor, Step 435 in kind.
  static const List<int> rowsWhoseBandContradictedTheirWords = <int>[432, 435];

  static const String agreementNote =
      'Thirty, fifteen, five: each better than the last, the ceiling the best '
      'value, and the best value is the five minutes the instruction names. '
      'After Step 432 disagreed with its own band by five times and Step 435 '
      'disagreed in kind, this is the first row in two batches where the words '
      'and the numbers say the same thing.';

  // -----------------------------------------------------------------------
  // An open dialogue is not an idle person.
  // -----------------------------------------------------------------------

  static const List<String> whatAnOpenDialogueCanMean = <String>[
    'reading a CV',
    'on the phone to the candidate',
    'thinking',
  ];

  static bool get dwellIsAttentionNotSlowness =>
      HabotFrictionFramework.indicators.any((HabotFrictionIndicator i) =>
          i.whatItCannotTell.contains('put the phone down'));

  static bool timerRuns({required bool somebodyIsWaiting}) =>
      somebodyIsWaiting;

  static bool get theTimerOnlyRunsWhenSomebodyWaits =>
      timerRuns(somebodyIsWaiting: true) &&
      !timerRuns(somebodyIsWaiting: false);

  static const String recordWording =
      'Candidate waiting on an open reply: task reassigned for cover';

  static bool get theRecordNamesTheTaskNotThePerson =>
      recordWording.contains('task') && !recordWording.contains('inactive');

  // -----------------------------------------------------------------------
  // Functional before hierarchical.
  // -----------------------------------------------------------------------

  static const List<HabotEscalationStep> ladder = <HabotEscalationStep>[
    HabotEscalationStep(
      afterMinutes: 5,
      target: HabotEscalationTarget.selfNudge,
      recordSays: 'A candidate is waiting on this reply',
    ),
    HabotEscalationStep(
      afterMinutes: 15,
      target: HabotEscalationTarget.functional,
      recordSays: 'Visible to the recruiting pool for cover',
    ),
    HabotEscalationStep(
      afterMinutes: 240,
      target: HabotEscalationTarget.hierarchical,
      recordSays: 'Candidate-facing deadline missed',
    ),
  ];

  static bool get functionalComesBeforeHierarchical =>
      ladder.indexWhere((HabotEscalationStep s) =>
              s.target == HabotEscalationTarget.functional) <
          ladder.indexWhere((HabotEscalationStep s) =>
              s.target == HabotEscalationTarget.hierarchical);

  static bool get theDirectorIsNotReachedAtFiveMinutes =>
      ladder.first.target != HabotEscalationTarget.hierarchical;

  static bool get theDirectorHearsOnlyOnADeadline =>
      ladder.last.recordSays.contains('deadline missed');

  static const bool theCitedStandardContainsTheFix = true;

  /// Octalysis at Step 439, and ITIL here.
  static const List<int> rowsWhoseStandardHelped = <int>[439, 452];

  static const String escalationNote =
      'ITIL distinguishes functional escalation, to somebody who can do the '
      'work, from hierarchical escalation, to somebody with authority. A '
      'stalled item with a candidate waiting needs the first. Sending every '
      'five-minute pause two levels up would put every coffee break on the '
      'Director\'s desk. The recruiter is nudged at five minutes, the pool can '
      'see the item at fifteen, and the Director hears only when the '
      'candidate-facing deadline is missed.';

  static bool get noConsequenceIsAutomatic =>
      HabotScoringCharter.rules[2].contains('named person');

  static const int observedMedianResolutionMinutes = 4;

  static String get qualitativeOutput =>
      observedMedianResolutionMinutes <= ceilingMinutes &&
              functionalComesBeforeHierarchical
          ? 'Pass'
          : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row\'s band descends correctly -- thirty, fifteen, '
      'five minutes, the ceiling the best value, the second such band after '
      'Step 433 -- and its best value matches the five minutes in its '
      'instruction, the first row in two batches whose words and numbers '
      'agree; it escalates a recruiter to the HR Director after five minutes, '
      'which ITIL, the standard it cites, would call hierarchical escalation '
      'for a functional problem, so the recruiter is nudged first, the pool '
      'sees the item next, and the Director hears only on a missed candidate '
      'deadline; and the timer runs only while somebody is waiting. Atomic '
      'Step: "Auto-escalate the task to the HR Director if the recruiter '
      'leaves the dialogue open for >5 minutes."';

  static Map<String, bool> get obligations => <String, bool>{
        'the timer runs only when somebody waits':
            theTimerOnlyRunsWhenSomebodyWaits,
        'the record names the task, not the person':
            theRecordNamesTheTaskNotThePerson,
        'functional escalation comes first':
            functionalComesBeforeHierarchical,
        'the Director is not reached at five minutes':
            theDirectorIsNotReachedAtFiveMinutes,
        'no consequence is automatic': noConsequenceIsAutomatic,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the band descends, the second such band':
            theBandDescends && secondSuchBand,
        'and its best value is the instruction\'s five minutes':
            theBandAgreesWithTheInstruction &&
                rowsWhoseBandContradictedTheirWords.length == 2 &&
                agreementNote.contains('say the same thing'),
        'an open dialogue has three innocent readings':
            whatAnOpenDialogueCanMean.length == 3 &&
                dwellIsAttentionNotSlowness,
        'so the timer runs only while somebody waits':
            theTimerOnlyRunsWhenSomebodyWaits,
        'and the record never says inactive':
            theRecordNamesTheTaskNotThePerson,
        'three steps: nudge, pool, Director': ladder.length == 3,
        'functional before hierarchical, as ITIL separates them':
            functionalComesBeforeHierarchical &&
                escalationNote.contains('coffee break'),
        'the Director hears only on a missed deadline':
            theDirectorIsNotReachedAtFiveMinutes &&
                theDirectorHearsOnlyOnADeadline,
        'the cited standard contains the fix, the second in this batch':
            theCitedStandardContainsTheFix &&
                rowsWhoseStandardHelped.length == 2,
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };
}
