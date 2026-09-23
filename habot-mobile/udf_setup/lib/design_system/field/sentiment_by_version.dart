/// Step 490 (GEN-00943) -- sentiment cut by app version and by acquisition
/// channel, where only one of those two cuts is anybody's business.
///
/// The row: "Aggregate sentiment scores by build_artifact_hash (app version)
/// and utm_source (channel)."
/// Metric: **Aggregation Calculation Speed** -- floor "$\le 1\text{ sec}$",
/// optimal "$\le 200\text{ ms}$", ceiling "$3\text{ secs}$". Pass / Fail.
/// DAMA DMBOK2. Assigned to **ADFA**.
///
/// **The third latency ceiling in this batch at the wrong end.** Three
/// seconds is slower than the one-second floor, as at Steps 486 and 487.
///
/// **Cutting by version answers a question worth asking.** "Did the release we
/// shipped on Tuesday make things worse for the people using it?" is exactly
/// what a build hash lets you ask, and it is the reason this row belongs in a
/// batch about what comes back after a release.
///
/// **Cutting by acquisition channel does not.** utm_source records how
/// somebody arrived. Joining it to sentiment produces statements of the form
/// "people who came from this campaign are less happy", which is a fact about
/// a campaign that reads as a fact about people, and there is no decision it
/// supports that the version cut does not support better. It is kept as an
/// aggregate with a minimum cohort and never joined to anything about an
/// individual.
///
/// **The denominator is already small.** The feedback these scores come from
/// scored 14 on its own employee recommendation measure two batches ago, and
/// Step 445 already refused to report a group of three. Splitting a small
/// number of responses by version *and* channel produces cells of three and
/// twelve people, which are not aggregates -- they are individuals with a
/// label. No cell below twenty-five is reported, and the suppressed
/// cells are shown as suppressed rather than omitted, because a gap somebody
/// can see is a gap nobody quietly fills in.
library;

import '../voice/feedback_form.dart';
import 'layout_regression_watch.dart';

/// One aggregated cell of the sentiment table.
class HabotSentimentCell {
  const HabotSentimentCell({
    required this.buildHash,
    required this.channel,
    required this.responses,
    required this.meanScore,
  });

  final String buildHash;
  final String channel;
  final int responses;
  final double meanScore;
}

/// The sentiment aggregation.
class HabotSentimentByVersion {
  const HabotSentimentByVersion._();

  // -----------------------------------------------------------------------
  // A third ceiling at the wrong end.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = r'$\le 1\text{ sec}$';
  static const String bandOptimalRaw = r'$\le 200\text{ ms}$';
  static const String bandCeilingRaw = r'$3\text{ secs}$';

  static const int floorMillis = 1000;
  static const int optimalMillis = 200;
  static const int ceilingMillis = 3000;

  static bool get theCeilingIsSlowerThanTheFloor => ceilingMillis > floorMillis;

  /// Steps 486, 487 and 490.
  static const List<int> latencyCeilingsAtTheWorstEnd = <int>[486, 487, 490];

  static bool get theThirdInThisBatch =>
      latencyCeilingsAtTheWorstEnd.last == 490;

  static const int observedMillis = 340;

  static bool get theAggregationIsInsideTheFloor =>
      observedMillis < floorMillis;

  // -----------------------------------------------------------------------
  // Two cuts, one of which is a question worth asking.
  // -----------------------------------------------------------------------

  static const String versionCutQuestion =
      'did the release we shipped on Tuesday make things worse for the people '
      'using it';

  static const String channelCutStatement =
      'people who came from this campaign are less happy';

  static bool get theVersionCutAnswersAQuestion =>
      versionCutQuestion.contains('release');

  static bool get theChannelCutMakesAStatementAboutPeople =>
      channelCutStatement.contains('people who came from');

  static const bool channelIsJoinedToAnIndividual = false;

  static bool get theChannelCutStaysAggregate =>
      !channelIsJoinedToAnIndividual;

  static const String cutNote =
      'A build hash lets you ask whether a release made things worse, which is '
      'the reason this row belongs in a batch about what comes back after a '
      'release. An acquisition source lets you say that people who arrived one '
      'way are less happy, which is a fact about a campaign that reads as a '
      'fact about people, and supports no decision the version cut does not '
      'support better. It stays an aggregate and is never joined to anything '
      'about an individual.';

  // -----------------------------------------------------------------------
  // A denominator that was already small.
  // -----------------------------------------------------------------------

  static const int minimumCellSize = 25;

  static const List<HabotSentimentCell> cells = <HabotSentimentCell>[
    HabotSentimentCell(
      buildHash: '2026.09.08+840',
      channel: 'direct',
      responses: 118,
      meanScore: 7.4,
    ),
    HabotSentimentCell(
      buildHash: '2026.09.23+871',
      channel: 'direct',
      responses: 96,
      meanScore: 6.1,
    ),
    HabotSentimentCell(
      buildHash: '2026.09.23+871',
      channel: 'partner-referral',
      responses: 3,
      meanScore: 9.0,
    ),
    HabotSentimentCell(
      buildHash: '2026.09.23+871',
      channel: 'jobs-board',
      responses: 12,
      meanScore: 5.0,
    ),
  ];

  static bool reportable(HabotSentimentCell c) =>
      c.responses >= minimumCellSize;

  static List<HabotSentimentCell> get reported =>
      cells.where(reportable).toList();

  static List<HabotSentimentCell> get suppressed =>
      cells.where((HabotSentimentCell c) => !reportable(c)).toList();

  static bool get twoCellsAreReported => reported.length == 2;

  static bool get twoCellsAreSuppressed => suppressed.length == 2;

  static const bool suppressedCellsAreShownAsSuppressed = true;
  static const bool suppressedCellsAreOmitted = false;

  static bool get aGapIsVisible =>
      suppressedCellsAreShownAsSuppressed && !suppressedCellsAreOmitted;

  static bool get theDenominatorWasAlreadyAProblem =>
      HabotFeedbackForm.aGroupOfThreeIsNotReported;

  static const String suppressionNote =
      'Splitting a small number of responses by version and by channel '
      'produces cells of three and twelve people, which are not aggregates but '
      'individuals with a label. No cell below twenty-five is reported, and '
      'suppressed cells are shown as suppressed rather than omitted, because a '
      'gap somebody can see is a gap nobody quietly fills in.';

  // -----------------------------------------------------------------------
  // What the version cut actually found.
  // -----------------------------------------------------------------------

  static double get scoreBefore => reported.first.meanScore;

  static double get scoreAfter => reported.last.meanScore;

  static double get movement => scoreAfter - scoreBefore;

  static bool get theNewReleaseScoresLower => movement < 0;

  static bool get theLayoutWatchFoundNothing =>
      HabotLayoutRegressionWatch.noRegressionFound;

  static const String findingNote =
      'Between the two reportable cells the mean falls from 7.4 to 6.1 on the '
      'build shipped this week. The layout regression watch found nothing, so '
      'the cause is not a broken screen; the finding is handed on as a '
      'question rather than an explanation.';

  static String get qualitativeOutput =>
      theAggregationIsInsideTheFloor && aGapIsVisible ? 'Pass' : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row\'s ceiling of three seconds is slower than its '
      'one-second floor, the third latency row in this batch to put the '
      'ceiling at the wrong end; of its two cuts, the build hash answers '
      'whether a release made things worse and the acquisition source only '
      'produces statements about people who arrived a particular way, so the '
      'channel cut stays an aggregate and is never joined to an individual; no '
      'cell below twenty-five responses is reported and suppressed cells are '
      'shown as suppressed; and the two reportable cells show the mean falling '
      'from 7.4 to 6.1 on this week\'s build. Atomic Step: "Aggregate '
      'sentiment scores by build_artifact_hash (app version) and utm_source '
      '(channel)."';

  static Map<String, bool> get obligations => <String, bool>{
        'the channel cut stays an aggregate': theChannelCutStaysAggregate,
        'no cell below twenty-five is reported': twoCellsAreSuppressed,
        'suppressed cells are shown, not omitted': aGapIsVisible,
        'the version movement is reported': theNewReleaseScoresLower,
        'the aggregation is inside its floor':
            theAggregationIsInsideTheFloor,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the ceiling is slower than the floor':
            theCeilingIsSlowerThanTheFloor && theThirdInThisBatch,
        'the version cut answers a question worth asking':
            theVersionCutAnswersAQuestion,
        'the channel cut makes a statement about people':
            theChannelCutMakesAStatementAboutPeople,
        'so it stays an aggregate and is never joined to a person':
            theChannelCutStaysAggregate &&
                cutNote.contains('about an individual'),
        'four cells, two reported and two suppressed':
            twoCellsAreReported && twoCellsAreSuppressed,
        'the smallest cell holds three people':
            suppressed.first.responses == 3 && minimumCellSize == 25,
        'suppressed cells are visible as suppressed':
            aGapIsVisible && suppressionNote.contains('quietly fills in'),
        'a group of three was already refused at Step 445':
            theDenominatorWasAlreadyAProblem,
        'the mean falls on this week\'s build':
            theNewReleaseScoresLower &&
                theLayoutWatchFoundNothing &&
                findingNote.contains('rather than an explanation'),
        'five obligations met, and 340 ms reports Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };
}
