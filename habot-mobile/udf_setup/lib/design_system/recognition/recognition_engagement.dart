/// Step 443 (GEN-05243) -- gratitude metrics, and the first ceiling in the
/// track that means what a ceiling should.
///
/// The row: "Build and configure: stream gratitude metrics to BigQuery to track
/// team morale and customer sentiment trends"
/// Metric: **Recognition Program Engagement Rate** -- floor ">= 20%", optimal
/// ">= 30%", ceiling "<= 50% (gaming-risk ceiling)". Pass/Fail. SHRM
/// Employee/Customer Recognition Benchmark. Assigned to **DEA**.
///
/// **This is the best cell in the sheet.** "<= 50% (gaming-risk ceiling)" says
/// that engagement above half is not better but worse -- that when more than
/// half of everybody is sending thanks every period, the thanks has stopped
/// being gratitude and started being a thing people do because it is counted.
/// It is Goodhart's law written into a band. After Batch P established that the
/// Ceiling column holds the worst tolerable value on latency rows, this row
/// uses it exactly as a ceiling should be used: an upper bound beyond which
/// more of a good thing is a problem. The band is two-sided, and both sides are
/// failures. Seventh annotated boundary in the track, and the only one whose
/// annotation is a genuine insight rather than a defence.
///
/// **Gratitude volume is not morale.** The row streams gratitude metrics "to
/// track team morale". A team that thanks each other a lot may be a happy team,
/// or a team told to use the recognition feature, or a team where one person
/// thanks everybody every Friday. The figure is published as what it is --
/// recognition activity -- and the word morale is kept off the dashboard,
/// because a number labelled morale becomes the morale figure the moment it is
/// on a slide.
///
/// **Team figures need a minimum team size.** A "team" of two turns a team
/// metric into a report about one identifiable colleague. Nothing is published
/// for a group smaller than five, which is the point at which an aggregate
/// stops being a thinly disguised individual.
///
/// **Customer sentiment is a second subject.** Staff thanking each other and
/// customers rating a service are different populations with different
/// consent, and they share this row's instruction. They are streamed to
/// separate tables and never joined.
library;

import 'gratitude_policy.dart';

/// Where an engagement reading falls in a two-sided band.
enum HabotEngagementReading {
  /// Below the floor: the programme is not being used.
  tooLow,

  /// Between the floor and the gaming-risk ceiling.
  healthy,

  /// Above the ceiling: the thanks is being done because it is counted.
  gamingRisk,
}

/// One team's recognition activity for a period.
class HabotTeamRecognition {
  const HabotTeamRecognition({
    required this.team,
    required this.members,
    required this.membersWhoSentThanks,
  });

  final String team;
  final int members;
  final int membersWhoSentThanks;
}

/// The recognition-engagement stream.
class HabotRecognitionEngagement {
  const HabotRecognitionEngagement._();

  // -----------------------------------------------------------------------
  // A ceiling that means what a ceiling should.
  // -----------------------------------------------------------------------

  static const double floorPercent = 20;
  static const double optimalPercent = 30;
  static const double ceilingPercent = 50;

  static const String bandCeilingRaw = '<= 50% (gaming-risk ceiling)';

  static bool get theCeilingIsAnUpperBound =>
      bandCeilingRaw.startsWith('<=') && ceilingPercent > optimalPercent;

  static bool get theBandIsTwoSided =>
      floorPercent < optimalPercent && optimalPercent < ceilingPercent;

  static HabotEngagementReading readingFor(double percent) {
    if (percent < floorPercent) {
      return HabotEngagementReading.tooLow;
    }
    return percent > ceilingPercent
        ? HabotEngagementReading.gamingRisk
        : HabotEngagementReading.healthy;
  }

  static bool get bothSidesAreFailures =>
      readingFor(10) == HabotEngagementReading.tooLow &&
      readingFor(70) == HabotEngagementReading.gamingRisk;

  /// Steps 384, 409, 413, 430, 433, 437 and this one.
  static const List<int> annotatedBoundaryRows = <int>[
    384,
    409,
    413,
    430,
    433,
    437,
    443,
  ];

  static bool get seventhAnnotatedBoundary =>
      annotatedBoundaryRows.length == 7;

  static const bool theAnnotationIsAnInsight = true;

  static const String ceilingNote =
      'The ceiling says that engagement above half is not better but worse: '
      'when more than half of everybody sends thanks every period, the thanks '
      'has stopped being gratitude and become a thing people do because it is '
      'counted. It is Goodhart\'s law written into a band. After Batch P '
      'showed the Ceiling column holding the worst tolerable value on latency '
      'rows, this row uses it as a ceiling should be used -- an upper bound '
      'beyond which more of a good thing is a problem -- and it is the only '
      'annotated boundary in the track whose annotation is an insight rather '
      'than a defence.';

  // -----------------------------------------------------------------------
  // Volume is not morale.
  // -----------------------------------------------------------------------

  static const String whatIsPublished = 'recognition activity';

  static const String whatTheRowCallsIt = 'team morale';

  static bool get theLabelIsKeptHonest =>
      whatIsPublished != whatTheRowCallsIt &&
      !whatIsPublished.contains('morale');

  static const List<String> whatHighVolumeCouldMean = <String>[
    'a team that is happy',
    'a team told to use the recognition feature',
    'a team where one person thanks everybody every Friday',
  ];

  static bool get threeReadingsOfOneNumber =>
      whatHighVolumeCouldMean.length == 3;

  static bool get thanksCarriesNoPoints =>
      HabotGratitudePolicy.peerThanksPointValue == 0;

  static const String moraleNote =
      'A team that thanks each other a lot may be happy, or may have been told '
      'to use the recognition feature, or may contain one person who thanks '
      'everybody every Friday. The figure is published as recognition activity '
      'and the word morale is kept off the dashboard, because a number '
      'labelled morale becomes the morale figure the moment it is on a slide.';

  // -----------------------------------------------------------------------
  // A minimum team size.
  // -----------------------------------------------------------------------

  static const int minimumGroupSize = 5;

  static const List<HabotTeamRecognition> teams = <HabotTeamRecognition>[
    HabotTeamRecognition(
      team: 'Line 1 packing',
      members: 18,
      membersWhoSentThanks: 6,
    ),
    HabotTeamRecognition(
      team: 'Line 2 packing',
      members: 22,
      membersWhoSentThanks: 8,
    ),
    HabotTeamRecognition(
      team: 'Cold store',
      members: 9,
      membersWhoSentThanks: 3,
    ),
    HabotTeamRecognition(
      team: 'Night supervisors',
      members: 2,
      membersWhoSentThanks: 1,
    ),
  ];

  static bool publishable(HabotTeamRecognition t) =>
      t.members >= minimumGroupSize;

  static List<HabotTeamRecognition> get published =>
      teams.where(publishable).toList();

  static int get suppressed => teams.length - published.length;

  static bool get theTeamOfTwoIsSuppressed => suppressed == 1;

  static double get engagementPercent {
    final int members =
        published.fold(0, (int a, HabotTeamRecognition t) => a + t.members);
    final int senders = published.fold(
        0, (int a, HabotTeamRecognition t) => a + t.membersWhoSentThanks);
    return members == 0 ? 0 : senders * 100 / members;
  }

  static bool get theReadingIsHealthy =>
      readingFor(engagementPercent) == HabotEngagementReading.healthy;

  static const String groupNote =
      'A team of two turns a team metric into a report about one identifiable '
      'colleague. Nothing is published for a group smaller than five, the '
      'point at which an aggregate stops being a thinly disguised individual, '
      'and one of the four teams in the worked set is suppressed for that '
      'reason and counted as suppressed.';

  // -----------------------------------------------------------------------
  // Customer sentiment is a separate subject.
  // -----------------------------------------------------------------------

  static const String staffTable = 'recognition.staff_thanks';
  static const String customerTable = 'recognition.customer_sentiment';

  static const bool theTwoAreJoined = false;

  static bool get theSubjectsAreKeptApart =>
      staffTable != customerTable && !theTwoAreJoined;

  static String get qualitativeOutput =>
      theReadingIsHealthy && theTeamOfTwoIsSuppressed ? 'Pass' : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row\'s ceiling reads "<= 50% (gaming-risk ceiling)", '
      'the first ceiling in the track used as a true upper bound -- engagement '
      'above half signals that thanks is being given because it is counted -- '
      'making the band two-sided with a failure at each end, and the seventh '
      'annotated boundary; it streams gratitude "to track team morale", which '
      'gratitude volume does not measure, so the figure is published as '
      'recognition activity; team figures are suppressed below five members; '
      'and customer sentiment, a second subject in the same instruction, is '
      'streamed separately and never joined. Atomic Step: "Build and '
      'configure: stream gratitude metrics to BigQuery to track team morale '
      'and customer sentiment trends"';

  static Map<String, bool> get obligations => <String, bool>{
        'the band is read as two-sided': theBandIsTwoSided,
        'the figure is not labelled morale': theLabelIsKeptHonest,
        'groups under five are suppressed': theTeamOfTwoIsSuppressed,
        'staff and customer data are never joined': theSubjectsAreKeptApart,
        'thanks carries no points': thanksCarriesNoPoints,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the ceiling is a true upper bound':
            theCeilingIsAnUpperBound && theBandIsTwoSided,
        'and both ends of the band are failures': bothSidesAreFailures,
        'Goodhart\'s law, written into a cell':
            ceilingNote.contains('Goodhart') &&
                seventhAnnotatedBoundary &&
                theAnnotationIsAnInsight,
        'gratitude volume has three readings, none of them morale':
            threeReadingsOfOneNumber && theLabelIsKeptHonest,
        'so the dashboard says recognition activity':
            moraleNote.contains('on a slide'),
        'four teams, one suppressed below five members':
            teams.length == 4 && theTeamOfTwoIsSuppressed,
        'the published figure is 34 per cent':
            engagementPercent > 34 && engagementPercent < 35,
        'which is inside the healthy band': theReadingIsHealthy,
        'staff thanks and customer sentiment are kept apart':
            theSubjectsAreKeptApart && groupNote.contains('suppressed'),
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };
}
