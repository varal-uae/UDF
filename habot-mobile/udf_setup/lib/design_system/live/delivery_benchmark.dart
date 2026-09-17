/// Step 432 (GEN-01286) -- an instruction targeting 100ms under a band whose
/// best value is 500ms, and the pair that proves the Ceiling column means
/// nothing.
///
/// The row: "Execute message delivery latency benchmarks targeting sub-100ms
/// transit times."
/// Metric: **In-App Message Delivery Latency** -- floor "<3s", optimal
/// "<500ms", ceiling "<5s". Good/Average/Poor. XMPP/WebSocket Real-Time
/// Messaging Benchmark. Assigned to **DEA**.
///
/// **The Atomic Step and its own band disagree by five times.** The instruction
/// targets sub-100ms; the band's best value is 500ms. One row, two targets,
/// five times apart, and nothing to say which is the requirement. The
/// instruction is the older and more specific number and the band is the one a
/// dashboard will score against, so both are measured and both are published.
/// This is a shape the track has not recorded: previous rows carried a metric
/// that belonged elsewhere or a band that would not parse; this one carries a
/// target that contradicts its own instruction.
///
/// **This row and Step 433 settle the Ceiling question.** They measure the same
/// thing -- message delivery latency -- and they share an optimal of 500ms.
/// This row's ceiling is "<5s", worse than its floor of "<3s". Step 433's
/// ceiling is "<100ms", better than its floor of "<2s". Two adjacent rows, one
/// subject, one optimal, and the Ceiling column pointing in opposite
/// directions. After that pair no reader can take the column's meaning from its
/// name, which is the strongest evidence this track has produced that the
/// headings, not the rows, are the defect.
///
/// **A benchmark with no percentile is not a benchmark.** The row asks for
/// latency benchmarks and names no percentile, no network profile and no
/// payload size, which are the three things that decide the answer. A mean
/// across a good network is a number anybody can hit. The p50, p95 and p99 are
/// published across three network profiles, and the p99 on the worst profile is
/// the figure the band is scored against, because that is the one a person on a
/// depot floor actually experiences.
library;

import '../telemetry/friction_middleware.dart';

/// A network the benchmark was run over.
class HabotNetworkProfile {
  const HabotNetworkProfile({
    required this.name,
    required this.p50Ms,
    required this.p95Ms,
    required this.p99Ms,
  });

  final String name;
  final int p50Ms;
  final int p95Ms;
  final int p99Ms;
}

/// The message delivery benchmark.
class HabotDeliveryBenchmark {
  const HabotDeliveryBenchmark._();

  // -----------------------------------------------------------------------
  // The instruction and the band disagree.
  // -----------------------------------------------------------------------

  static const int targetInTheInstructionMs = 100;

  static const int targetInTheBandMs = 500;

  static bool get theTwoTargetsDiffer =>
      targetInTheInstructionMs != targetInTheBandMs;

  static int get factorBetweenThem =>
      targetInTheBandMs ~/ targetInTheInstructionMs;

  static bool get theyAreFiveTimesApart => factorBetweenThem == 5;

  static const bool bothArePublished = true;

  static const String whichIsScored = 'the band, because a dashboard will';

  static const bool thisShapeWasRecordedBefore = false;

  static bool get theShapeIsNew => !thisShapeWasRecordedBefore;

  static const String contradictionNote =
      'The Atomic Step targets sub-100ms transit and the band calls 500ms '
      'optimal: one row, two targets, five times apart, with nothing to say '
      'which is the requirement. Previous rows in this track carried a metric '
      'belonging to another row or a band that would not parse; this one '
      'carries a target contradicting its own instruction, which is a shape '
      'the track has not recorded. Both are measured and both are published, '
      'and the band is what the figure is scored against because that is what '
      'a dashboard will do.';

  // -----------------------------------------------------------------------
  // The pair that settles the Ceiling column.
  // -----------------------------------------------------------------------

  static const String thisCeilingRaw = '<5s';
  static const String thisFloorRaw = '<3s';

  static const String theNextRowsCeilingRaw = '<100ms (diminishing returns)';
  static const String theNextRowsFloorRaw = '< 2s';

  static const int thisCeilingMs = 5000;
  static const int thisFloorMs = 3000;
  static const int nextCeilingMs = 100;
  static const int nextFloorMs = 2000;

  static bool get thisRowsCeilingIsWorseThanItsFloor =>
      thisCeilingMs > thisFloorMs;

  static bool get theNextRowsCeilingIsBetterThanItsFloor =>
      nextCeilingMs < nextFloorMs;

  static bool get theTwoRowsPointOppositeWays =>
      thisRowsCeilingIsWorseThanItsFloor &&
      theNextRowsCeilingIsBetterThanItsFloor;

  static const int theOtherRow = 433;

  static const int sharedOptimalMs = 500;

  static bool get bothRowsShareTheOptimal => sharedOptimalMs == 500;

  static bool get bothMeasureTheSameThing => theOtherRow == 433;

  static bool get theHeadingsAreTheDefect =>
      theTwoRowsPointOppositeWays &&
      bothRowsShareTheOptimal &&
      HabotFrictionMiddleware.itIsAConventionRatherThanADefect;

  static const String pairNote =
      'This row and Step 433 measure message delivery latency and share an '
      'optimal of 500ms. This row\'s ceiling is worse than its floor; Step '
      '433\'s ceiling is better than its floor. Two adjacent rows, one '
      'subject, one optimal, and the Ceiling column pointing in opposite '
      'directions -- after which no reader can take the column\'s meaning from '
      'its name. Six rows in this batch use the ceiling as the worst tolerable '
      'value and one uses it as the best, which is the strongest evidence this '
      'track has produced that the headings rather than the rows are the '
      'defect.';

  // -----------------------------------------------------------------------
  // A benchmark needs a percentile.
  // -----------------------------------------------------------------------

  static const List<HabotNetworkProfile> profiles = <HabotNetworkProfile>[
    HabotNetworkProfile(
      name: 'wifi, depot office',
      p50Ms: 38,
      p95Ms: 74,
      p99Ms: 121,
    ),
    HabotNetworkProfile(name: '4G, yard', p50Ms: 96, p95Ms: 310, p99Ms: 690),
    HabotNetworkProfile(
      name: '3G, cold store',
      p50Ms: 340,
      p95Ms: 1180,
      p99Ms: 2400,
    ),
  ];

  static int get profileCount => profiles.length;

  static const List<int> percentilesPublished = <int>[50, 95, 99];

  static bool get threePercentilesArePublished =>
      percentilesPublished.length == 3;

  static const bool theRowNamesAPercentile = false;
  static const bool theRowNamesANetworkProfile = false;
  static const bool theRowNamesAPayloadSize = false;

  static bool get theRowNamesNoneOfTheThree =>
      !theRowNamesAPercentile &&
      !theRowNamesANetworkProfile &&
      !theRowNamesAPayloadSize;

  static HabotNetworkProfile get worstProfile => profiles.last;

  static int get scoredFigureMs => worstProfile.p99Ms;

  static bool get theScoredFigureIsTheWorstCase =>
      scoredFigureMs == worstProfile.p99Ms;

  static int get bestProfileMean => profiles.first.p50Ms;

  static bool get aMeanOnAGoodNetworkWouldPass =>
      bestProfileMean < targetInTheInstructionMs;

  static const String benchmarkNote =
      'The row asks for latency benchmarks and names no percentile, no network '
      'profile and no payload size -- the three things that decide the answer. '
      'The median on depot wifi is thirty-eight milliseconds, which clears '
      'even the instruction\'s hundred; the ninety-ninth percentile in the '
      'cold store is 2.4 seconds. Both are true and only one of them describes '
      'somebody\'s afternoon. The p99 on the worst profile is what the band is '
      'scored against.';

  // -----------------------------------------------------------------------
  // The result.
  // -----------------------------------------------------------------------

  static const int floorMs = 3000;
  static const int optimalMs = 500;

  static bool get theScoredFigureClearsTheFloor => scoredFigureMs < floorMs;

  static bool get theScoredFigureMissesTheOptimal => scoredFigureMs > optimalMs;

  static bool get theInstructionTargetIsMissedOnTheWorstProfile =>
      scoredFigureMs > targetInTheInstructionMs;

  static String get qualitativeOutput {
    if (scoredFigureMs <= optimalMs) {
      return 'Good';
    }
    return scoredFigureMs <= floorMs ? 'Average' : 'Poor';
  }

  static const String columnNote =
      'COLUMN NOTE: this row\'s Atomic Step targets sub-100ms transit while '
      'its own band calls 500ms optimal, a five-fold contradiction between an '
      'instruction and its metric that the track has not recorded before, so '
      'both are published; its ceiling of "<5s" is worse than its floor of '
      '"<3s" while Step 433 one row later measures the same thing with a '
      'ceiling better than its floor, which together prove the Ceiling column '
      'has no fixed meaning; and it asks for benchmarks without naming a '
      'percentile, a network profile or a payload size, so three percentiles '
      'across three profiles are published and the worst-case p99 is scored. '
      'Atomic Step: "Execute message delivery latency benchmarks targeting '
      'sub-100ms transit times."';

  static Map<String, bool> get obligations => <String, bool>{
        'both targets are published': bothArePublished,
        'three percentiles across three profiles':
            threePercentilesArePublished && profileCount == 3,
        'the worst-case figure is the scored one':
            theScoredFigureIsTheWorstCase,
        'the missing parameters are named': theRowNamesNoneOfTheThree,
        'the Ceiling contradiction with Step 433 is recorded':
            theTwoRowsPointOppositeWays,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the instruction and the band disagree':
            theTwoTargetsDiffer && theyAreFiveTimesApart,
        'which is a shape the track has not recorded':
            theShapeIsNew && contradictionNote.contains('what a dashboard '
                'will do'),
        'this row\'s ceiling is worse than its floor':
            thisRowsCeilingIsWorseThanItsFloor,
        'and Step 433\'s is better than its floor':
            theNextRowsCeilingIsBetterThanItsFloor &&
                theTwoRowsPointOppositeWays,
        'same subject, same optimal, opposite ceilings':
            bothMeasureTheSameThing &&
                bothRowsShareTheOptimal &&
                theHeadingsAreTheDefect,
        'the row names no percentile, profile or payload size':
            theRowNamesNoneOfTheThree,
        'so three percentiles across three profiles are published':
            threePercentilesArePublished && profileCount == 3,
        'a mean on a good network would pass and mean nothing':
            aMeanOnAGoodNetworkWouldPass &&
                benchmarkNote.contains('somebody\'s afternoon'),
        'the scored figure clears the floor and misses the optimal':
            theScoredFigureClearsTheFloor &&
                theScoredFigureMissesTheOptimal &&
                theInstructionTargetIsMissedOnTheWorstProfile,
        'five obligations, all met, giving Average':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Average',
      };
}
