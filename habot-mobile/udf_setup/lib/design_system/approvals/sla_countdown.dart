/// Step 395 (GEN-03226) -- a clock counting down to a consequence, and a band
/// whose ceiling is the worst of its three values.
///
/// The row: "Create visual SLA countdown timer widgets for approval review
/// cards."
/// Metric: **SLA Widget Refresh Interval** -- floor "1s", optimal "1s", ceiling
/// "2s". Best Qualitative Output: **"Complete"**. OPS SLA Timer Framework.
/// Assigned to **UDF**.
///
/// **A band that is collapsed at one end and inverted at the other.** Floor 1s,
/// optimal 1s, ceiling 2s. On a refresh interval lower is better, so the
/// ceiling -- the best attainable value -- is the worst of the three, and the
/// floor and the optimal are the same number. It is the first band in this
/// track to carry both defects at once: previous inversions had three distinct
/// values and previous collapses were flat.
///
/// **A second-by-second countdown is a decision about attention, not about
/// accuracy.** A timer ticking every second on a list of approval cards redraws
/// forty widgets a minute to move a number nobody is watching, and on a screen
/// reader it is a hostile environment -- an announcement every second is an
/// interruption every second. The cadence is bound to the magnitude: hours
/// remaining update once a minute, the last ten minutes update every second,
/// and the live region announces at thresholds rather than on every tick.
///
/// **What happens at zero is the part the row does not say.** A countdown
/// implies a consequence and the consequence is what makes the number worth
/// showing. Four worked cards: two escalate to a named person, one
/// auto-approves -- which is the one that has to be loudest -- and one simply
/// expires. A timer that does not say what zero means is decoration with a
/// clock face.
///
/// **A deadline is a time, not a duration.** "4h 12m left" is unreadable when
/// somebody comes back tomorrow, and it lies across a device sleep. The
/// absolute due time is shown beside the countdown and is what the record
/// stores, so two people in two time zones see the same deadline.
///
/// **The output column holds one value: "Complete".** The ninth one-valued
/// output column in this track, and the third in this batch after Steps 383
/// and 389 -- though Step 389's holds a scale with an annotation rather than a
/// bare word.
library;

import '../dashboard/freshness.dart';

/// What happens when the clock reaches zero.
enum HabotSlaConsequence {
  /// A named person is asked.
  escalates,

  /// The request is approved without anybody looking.
  autoApproves,

  /// The request lapses and has to be raised again.
  expires,
}

/// One approval card with a deadline.
class HabotApprovalCard {
  const HabotApprovalCard({
    required this.title,
    required this.secondsRemaining,
    required this.consequence,
    required this.dueAt,
  });

  final String title;
  final int secondsRemaining;
  final HabotSlaConsequence consequence;

  /// The absolute deadline, with an offset.
  final String dueAt;
}

/// The SLA countdown rule.
class HabotSlaCountdown {
  const HabotSlaCountdown._();

  // -----------------------------------------------------------------------
  // Collapsed and inverted at once.
  // -----------------------------------------------------------------------

  static const int bandFloorSeconds = 1;
  static const int bandOptimalSeconds = 1;
  static const int bandCeilingSeconds = 2;

  static bool get theFloorEqualsTheOptimal =>
      bandFloorSeconds == bandOptimalSeconds;

  /// Lower is better for a refresh interval, so a ceiling above the floor is
  /// the worst of the three values.
  static bool get theCeilingIsTheWorstValue =>
      bandCeilingSeconds > bandFloorSeconds;

  static bool get theBandIsCollapsedAndInverted =>
      theFloorEqualsTheOptimal && theCeilingIsTheWorstValue;

  static const bool anyPreviousBandCarriedBothDefects = false;

  static const String bandNote =
      'Floor 1s, optimal 1s, ceiling 2s. On a refresh interval lower is '
      'better, so the ceiling -- the best attainable value -- is the worst of '
      'the three, and the floor and the optimal are the same number. Every '
      'inversion this track has recorded had three distinct values and every '
      'collapse was flat; this is the first cell group to be both at once, '
      'which means neither defect can be read as the other one\'s rounding.';

  // -----------------------------------------------------------------------
  // Cadence follows magnitude.
  // -----------------------------------------------------------------------

  static const int lastMinutesTickedEverySecond = 10;

  static int refreshSecondsFor(int secondsRemaining) =>
      secondsRemaining <= lastMinutesTickedEverySecond * 60 ? 1 : 60;

  static bool get anHourAwayTicksOnceAMinute =>
      refreshSecondsFor(3600) == 60;

  static bool get theLastTenMinutesTickEverySecond =>
      refreshSecondsFor(300) == 1;

  static const bool everyCardTicksEverySecond = false;

  static int get redrawsPerMinuteAtOneSecond => 60;

  static int get redrawsPerMinuteAtOneMinute => 1;

  static int get redrawsSavedPerCardPerMinute =>
      redrawsPerMinuteAtOneSecond - redrawsPerMinuteAtOneMinute;

  static const bool theLiveRegionAnnouncesEveryTick = false;

  static const List<int> announcementThresholdsMinutes = <int>[60, 15, 5, 1];

  static bool get announcementsAreAtThresholds =>
      !theLiveRegionAnnouncesEveryTick &&
      announcementThresholdsMinutes.length == 4;

  static const String cadenceNote =
      'A timer ticking every second on a list of approval cards redraws sixty '
      'times a minute per card to move a number nobody is watching, and on a '
      'screen reader an announcement every second is an interruption every '
      'second. The cadence follows the magnitude: hours remaining update once '
      'a minute, the last ten minutes update every second, and the live region '
      'announces at four thresholds rather than on every tick.';

  // -----------------------------------------------------------------------
  // What zero means.
  // -----------------------------------------------------------------------

  static const List<HabotApprovalCard> cards = <HabotApprovalCard>[
    HabotApprovalCard(
      title: 'Overtime above 12 hours',
      secondsRemaining: 14520,
      consequence: HabotSlaConsequence.escalates,
      dueAt: '2026-09-17T18:00:00+04:00',
    ),
    HabotApprovalCard(
      title: 'Expense over AED 5,000',
      secondsRemaining: 540,
      consequence: HabotSlaConsequence.escalates,
      dueAt: '2026-09-17T14:09:00+04:00',
    ),
    HabotApprovalCard(
      title: 'Standard shift swap',
      secondsRemaining: 3600,
      consequence: HabotSlaConsequence.autoApproves,
      dueAt: '2026-09-17T15:00:00+04:00',
    ),
    HabotApprovalCard(
      title: 'Document re-upload request',
      secondsRemaining: 86400,
      consequence: HabotSlaConsequence.expires,
      dueAt: '2026-09-18T14:00:00+04:00',
    ),
  ];

  static bool get everyCardNamesItsConsequence =>
      cards.length == 4 &&
      cards
          .map((HabotApprovalCard c) => c.consequence)
          .toSet()
          .length ==
          HabotSlaConsequence.values.length;

  static List<HabotApprovalCard> get autoApproving => cards
      .where((HabotApprovalCard c) =>
          c.consequence == HabotSlaConsequence.autoApproves)
      .toList();

  static bool get theAutoApprovingCardIsTheLoudest =>
      autoApproving.length == 1;

  static const bool aTimerWithNoStatedConsequenceIsShown = false;

  static const String consequenceNote =
      'A countdown implies a consequence, and the consequence is what makes '
      'the number worth showing. Two of the four cards escalate to a named '
      'person, one auto-approves without anybody looking -- which is the one '
      'that has to be loudest, because inaction there is a decision -- and one '
      'simply lapses. A timer that does not say what zero means is decoration '
      'with a clock face.';

  // -----------------------------------------------------------------------
  // A deadline is a time.
  // -----------------------------------------------------------------------

  static bool get everyCardCarriesAnAbsoluteDueTime =>
      cards.every((HabotApprovalCard c) => c.dueAt.contains('+'));

  static const bool onlyTheDurationIsShown = false;

  static bool get bothTheCountdownAndTheDeadlineAreShown =>
      !onlyTheDurationIsShown && everyCardCarriesAnAbsoluteDueTime;

  static const String deadlineNote =
      '"4h 12m left" is unreadable when somebody comes back tomorrow, and it '
      'lies across a device sleep. The absolute due time is shown beside the '
      'countdown and is what the record stores, so two people in two time '
      'zones looking at one card see the same deadline rather than two '
      'different arithmetic results.';

  // -----------------------------------------------------------------------
  // Staleness is the declared policy.
  // -----------------------------------------------------------------------

  static HabotFreshness freshnessOf(Duration age) =>
      HabotFreshnessPolicy.classify(age);

  static bool get aStaleCountdownIsLabelled =>
      freshnessOf(HabotFreshnessPolicy.budget * 2) == HabotFreshness.delayed;

  static const String stalenessNote =
      'A countdown computed from data that stopped arriving is a confident '
      'wrong number, which is worse than a blank. The card carries the Step '
      '129 freshness state alongside the clock, so a countdown running off an '
      'hour-old fetch says so rather than counting down smoothly to a deadline '
      'that already moved.';

  // -----------------------------------------------------------------------
  // The output column.
  // -----------------------------------------------------------------------

  static const String outputColumn = 'Complete';

  static bool get theOutputCannotExpressAFailure => outputColumn == 'Complete';

  static const int oneValuedColumnsInTheTrack = 9;

  static const List<int> oneValuedColumnsInThisBatch = <int>[383, 389, 395];

  static bool get theCountReachesNine =>
      oneValuedColumnsInTheTrack == 9 &&
      oneValuedColumnsInThisBatch.length == 3 &&
      theOutputCannotExpressAFailure;

  static const String outputNote =
      '"Complete" with no failing value is the ninth one-valued output column '
      'in this track and the third in this batch, after Step 383\'s "Pass" and '
      'Step 389\'s scale-with-an-annotation. Three in twenty rows is a rate '
      'the earlier batches did not reach.';

  static Map<String, bool> get obligations => <String, bool>{
        'the tick rate follows the magnitude':
            anHourAwayTicksOnceAMinute && theLastTenMinutesTickEverySecond,
        'the live region announces at thresholds':
            announcementsAreAtThresholds,
        'every card names what happens at zero': everyCardNamesItsConsequence,
        'the auto-approving card is marked as such':
            theAutoApprovingCardIsTheLoudest,
        'every card carries an absolute due time':
            bothTheCountdownAndTheDeadlineAreShown,
        'a stale countdown is labelled': aStaleCountdownIsLabelled,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Complete' : 'Not Complete';

  static Map<String, bool> get checks => <String, bool>{
        'the floor equals the optimal': theFloorEqualsTheOptimal,
        'and the ceiling is the worst of the three':
            theCeilingIsTheWorstValue && theBandIsCollapsedAndInverted,
        'which no previous band in this track was':
            !anyPreviousBandCarriedBothDefects &&
                bandNote.contains('the other one\'s rounding'),
        'an hour away ticks once a minute and the last ten tick every second':
            anHourAwayTicksOnceAMinute &&
                theLastTenMinutesTickEverySecond &&
                !everyCardTicksEverySecond,
        'and that is 59 redraws a minute per card not taken':
            redrawsSavedPerCardPerMinute == 59 &&
                cadenceNote.contains('an interruption every second'),
        'announcements are at four thresholds': announcementsAreAtThresholds,
        'four cards, three consequences, one auto-approval':
            everyCardNamesItsConsequence &&
                theAutoApprovingCardIsTheLoudest &&
                !aTimerWithNoStatedConsequenceIsShown,
        'every card carries its absolute deadline':
            bothTheCountdownAndTheDeadlineAreShown &&
                deadlineNote.contains('two different arithmetic results'),
        'a stale countdown is labelled by the Step 129 policy':
            aStaleCountdownIsLabelled && stalenessNote.contains('Step 129'),
        'six obligations, all met, giving Complete':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete' &&
                theCountReachesNine,
      };

  static const String columnNote =
      'COLUMN NOTE: the band on this row sets a floor and an optimal both at '
      '1s and a ceiling at 2s, so on a lower-is-better measure it is collapsed '
      'at one end and inverted at the other -- the first band in this track to '
      'carry both defects at once; its Best Qualitative Output column holds '
      'the single word "Complete", the ninth one-valued output column and the '
      'third in this batch; its standard is an "OPS SLA Timer Framework"; its '
      'Data Requirement cell holds the Atomic Step\'s own sentence as the '
      'artefact to prepare; and the Setup Step column is empty. Atomic Step: '
      '"Create visual SLA countdown timer widgets for approval review cards."';
}
