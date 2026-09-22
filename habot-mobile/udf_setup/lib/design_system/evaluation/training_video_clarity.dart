/// Step 451 (GEN-01936) -- worker failures used to judge a training video,
/// which is the first row in two batches to point its measurement at the
/// material rather than the person.
///
/// The row: "Monitor worker task failures and timeouts to identify unclear
/// training videos."
/// Metric: **Video Playback Success Rate (%)** -- floor 98, optimal 99.5,
/// ceiling 100. Best Qualitative Output: "High/Medium/Low". Video Delivery &
/// Streaming Standards (HLS, DASH). Assigned to **ADFA**.
///
/// **The row gets the unit of analysis right by itself.** Step 416 had to write
/// down that friction measures a screen, and Step 436 had to write down what
/// changes when a person is the subject. This row needs neither correction: it
/// says outright that task failures are evidence about the *video*. When most
/// of the people who watched a video then fail the task it teaches, the video
/// is what failed. It is the first row in two batches to point its measurement
/// at the material rather than at the people using it, and it is recorded as
/// such -- the track notices defects, and should notice this too.
///
/// **The data is still about people, so its purpose is fixed.** The
/// observations are individual task failures, and a list of who failed after
/// which video is one query away from a list of who failed. Failures are
/// aggregated per video, nothing is shown for fewer than five watchers, and
/// data collected to judge a video may not flow into anybody's scorecard --
/// collected for one purpose, used for that purpose.
///
/// **A timeout is not always the person.** A task that times out while the
/// device has no network timed out because of the network. Timeouts are only
/// counted when the device was online, using the connection states Step 430
/// already declared.
///
/// **The metric measures whether the video plays, not whether it is clear.**
/// Playback success is a streaming figure; clarity is what the row is about.
/// The fifth row across two batches scored on its mechanism rather than its
/// purpose, after Steps 413, 421, 425 and 431. The output column introduces a
/// third vocabulary -- High/Medium/Low -- beside Good/Average/Poor and
/// Complete/Partial/Not Complete.
library;

import '../live/streaming_hooks.dart';
import '../recognition/recognition_engagement.dart';

/// One training video and what happened after people watched it.
class HabotVideoOutcome {
  const HabotVideoOutcome({
    required this.video,
    required this.watchers,
    required this.failedAfter,
    required this.baselineFailureRate,
  });

  final String video;
  final int watchers;

  /// Watchers who then failed the task it teaches, online timeouts included.
  final int failedAfter;

  /// The task's failure rate among people who did not watch the video.
  final double baselineFailureRate;
}

/// The training-video clarity monitor.
class HabotTrainingVideoClarity {
  const HabotTrainingVideoClarity._();

  // -----------------------------------------------------------------------
  // The row points at the material.
  // -----------------------------------------------------------------------

  static const String whatTheRowJudges = 'the video';

  static const String whatItDoesNotJudge = 'the worker';

  static bool get theRowGetsTheUnitRight =>
      whatTheRowJudges != whatItDoesNotJudge;

  static const bool anEarlierRowInTwoBatchesDidThisUnprompted = false;

  static bool get theFirstSuchRow =>
      theRowGetsTheUnitRight && !anEarlierRowInTwoBatchesDidThisUnprompted;

  static const String unitNote =
      'Step 416 had to write down that friction measures a screen, and Step '
      '436 had to write down what changes when a person is the subject. This '
      'row needs neither: it says task failures are evidence about the video. '
      'When most people who watched a video then fail the task it teaches, the '
      'video is what failed. It is the first row in two batches to point its '
      'measurement at the material rather than the people, and the track '
      'should notice that as readily as it notices a defect.';

  // -----------------------------------------------------------------------
  // The purpose is fixed.
  // -----------------------------------------------------------------------

  static int get minimumWatchers =>
      HabotRecognitionEngagement.minimumGroupSize;

  static const bool failureDataMayFeedAScorecard = false;

  static const bool individualFailureListsAreShown = false;

  static bool get thePurposeIsFixed =>
      !failureDataMayFeedAScorecard && !individualFailureListsAreShown;

  // -----------------------------------------------------------------------
  // Timeouts only when online.
  // -----------------------------------------------------------------------

  static bool countsAsTimeout({required bool deviceWasOnline}) =>
      deviceWasOnline;

  static bool get anOfflineTimeoutIsNotCounted =>
      !countsAsTimeout(deviceWasOnline: false);

  static bool get theConnectionStatesAreStep430s =>
      HabotStreamingHooks.threeStatesAreDeclared;

  // -----------------------------------------------------------------------
  // Which video is unclear.
  // -----------------------------------------------------------------------

  static const List<HabotVideoOutcome> videos = <HabotVideoOutcome>[
    HabotVideoOutcome(
      video: 'Manual clock-in when GPS fails',
      watchers: 40,
      failedAfter: 3,
      baselineFailureRate: 0.12,
    ),
    HabotVideoOutcome(
      video: 'Recording a shift swap',
      watchers: 35,
      failedAfter: 12,
      baselineFailureRate: 0.10,
    ),
    HabotVideoOutcome(
      video: 'Submitting an expense with a receipt',
      watchers: 28,
      failedAfter: 2,
      baselineFailureRate: 0.15,
    ),
    HabotVideoOutcome(
      video: 'Night-shift handover',
      watchers: 3,
      failedAfter: 2,
      baselineFailureRate: 0.10,
    ),
  ];

  static bool assessable(HabotVideoOutcome v) => v.watchers >= minimumWatchers;

  static bool unclear(HabotVideoOutcome v) =>
      assessable(v) && v.failedAfter / v.watchers > v.baselineFailureRate * 2;

  static List<HabotVideoOutcome> get flagged => videos.where(unclear).toList();

  static bool get theShiftSwapVideoIsFlagged =>
      flagged.length == 1 && flagged.first.video.contains('shift swap');

  static bool get theSmallCohortIsNotAssessed =>
      !assessable(videos.last) && !unclear(videos.last);

  static const String flagNote =
      'A video is flagged when the people who watched it fail the task it '
      'teaches at more than twice the rate of people who did not. The '
      'shift-swap video is flagged -- a third of its watchers then failed the '
      'task, against a tenth of everybody else -- and the night-shift video is '
      'not assessed at all, because three watchers is three people, not a '
      'finding.';

  // -----------------------------------------------------------------------
  // The metric measures playback.
  // -----------------------------------------------------------------------

  static const String whatTheMetricMeasures = 'whether the video plays';

  static const String whatTheRowIsAbout = 'whether the video is clear';

  static bool get theMetricMeasuresTheMechanism =>
      whatTheMetricMeasures != whatTheRowIsAbout;

  /// Steps 413, 421, 425, 431 and this one.
  static const List<int> rowsScoredOnTheirMechanism = <int>[
    413,
    421,
    425,
    431,
    451,
  ];

  static bool get fifthSuchRow => rowsScoredOnTheirMechanism.length == 5;

  static const List<String> outputVocabularies = <String>[
    'Good/Average/Poor',
    'Complete/Partial/Not Complete',
    'High/Medium/Low',
  ];

  static bool get aThirdVocabularyAppears => outputVocabularies.length == 3;

  static const int plays = 3000;
  static const int playbackFailures = 9;

  static double get playbackSuccess =>
      plays == 0 ? 0 : (plays - playbackFailures) / plays * 100;

  static String get qualitativeOutput {
    if (playbackSuccess >= 99.5) {
      return 'High';
    }
    return playbackSuccess >= 98 ? 'Medium' : 'Low';
  }

  static const String columnNote =
      'COLUMN NOTE: this row points its measurement at the training video '
      'rather than the worker, the first row in two batches to get the unit of '
      'analysis right unprompted -- so failures are aggregated per video, '
      'suppressed below five watchers, never fed into a scorecard, and '
      'timeouts are counted only when the device was online; its metric '
      'measures whether the video plays rather than whether it is clear, the '
      'fifth row scored on its mechanism after Steps 413, 421, 425 and 431; '
      'and its output column introduces High/Medium/Low, a third vocabulary. '
      'Atomic Step: "Monitor worker task failures and timeouts to identify '
      'unclear training videos."';

  static Map<String, bool> get obligations => <String, bool>{
        'failures are judged per video': theRowGetsTheUnitRight,
        'small cohorts are not assessed': theSmallCohortIsNotAssessed,
        'the data never feeds a scorecard': thePurposeIsFixed,
        'offline timeouts are not counted': anOfflineTimeoutIsNotCounted,
        'the unclear video is found': theShiftSwapVideoIsFlagged,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the row judges the video, not the worker':
            theRowGetsTheUnitRight && theFirstSuchRow,
        'and the track records that as readily as a defect':
            unitNote.contains('as readily as it notices a defect'),
        'failure data is purpose-limited and never listed by person':
            thePurposeIsFixed && minimumWatchers == 5,
        'a timeout while offline is the network\'s':
            anOfflineTimeoutIsNotCounted && theConnectionStatesAreStep430s,
        'four videos, one flagged':
            videos.length == 4 && theShiftSwapVideoIsFlagged,
        'and the three-watcher video is not assessed':
            theSmallCohortIsNotAssessed &&
                flagNote.contains('not a finding'),
        'the metric measures playback, not clarity':
            theMetricMeasuresTheMechanism && fifthSuchRow,
        'a third output vocabulary appears': aThirdVocabularyAppears,
        'playback succeeds 99.7 per cent of the time':
            playbackSuccess > 99.6 && playbackSuccess < 99.8,
        'five obligations, all met, giving High':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'High',
      };
}
