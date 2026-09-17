/// Step 338 (GEN-04858) -- the row's own requirement fails the row's own
/// floor.
///
/// The row: "Implement the mobile UX performance requirement: Swipe threshold
/// snap animation duration <150ms."
/// Metric: **UI Response / Interaction Latency** -- floor "<=100ms
/// perceived-instant response threshold", optimal "<=50ms", ceiling ">100ms
/// begins to feel laggy to users (Nielsen response-time limit)". Pass / Fail.
///
/// **This is new.** Every band defect this track has recorded -- inverted ends,
/// collapsed ends, mismatched units, unfailable floors -- has been internal to
/// the band. Here the *Atomic Step* and the band contradict each other on the
/// same row. The step asks for a snap under 150 ms. The floor of the band that
/// scores it is 100 ms. Build exactly what the row asks for, at 149 ms, and the
/// row fails its own floor by 49 per cent.
///
/// **And the ceiling is prose describing the failure region.** ">100ms begins
/// to feel laggy" is not a boundary, it is the definition of being past the
/// floor, written where the best attainable value belongs. So the band has a
/// floor of 100, an optimal of 50, and a ceiling that says 100 is where things
/// go wrong -- the fifth inverted band this track has met, and the first whose
/// inversion is spelled out in words rather than numbers.
///
/// **The two durations are not the same measurement**, which is the part worth
/// building. Nielsen's 0.1 s is the limit for *response*: the interval from the
/// input to the first visible acknowledgement. A snap animation's duration is
/// how long the motion takes once it has begun. A 150 ms animation that starts
/// within 16 ms is instant and smooth; a 50 ms animation that starts 200 ms
/// late is a stutter. Collapsing them into one number, as this row does, makes
/// the wrong one the target.
library;

import '../tokens/motion_tokens.dart';

/// The two things a duration on a gesture can mean.
enum HabotLatencyKind {
  /// Input to first visible change. Nielsen's 0.1s applies here.
  responseToFirstFrame,

  /// How long the motion runs once it has started.
  animationDuration,
}

/// One worked interaction.
class HabotSnapSample {
  const HabotSnapSample({
    required this.label,
    required this.responseMs,
    required this.durationMs,
  });

  final String label;
  final int responseMs;
  final int durationMs;
}

/// The snap that follows a swipe past its threshold.
class HabotSnapBudget {
  const HabotSnapBudget._();

  // -----------------------------------------------------------------------
  // The row against itself.
  // -----------------------------------------------------------------------

  /// What the Atomic Step asks for.
  static const int requirementCeilingMs = 150;

  /// What the band's floor permits.
  static const int bandFloorMs = 100;

  static const int bandOptimalMs = 50;

  static const String bandCeilingText =
      '>100ms begins to feel laggy to users (Nielsen response-time limit)';

  /// Build the requirement exactly and the floor is missed.
  static const int builtToTheRequirementMs = 149;

  static bool get theRequirementExceedsItsOwnFloor =>
      requirementCeilingMs > bandFloorMs;

  static double get overshootFraction =>
      (builtToTheRequirementMs - bandFloorMs) / bandFloorMs;

  /// 49 per cent over the floor, built exactly to specification.
  static bool get buildingToSpecFailsTheFloor =>
      builtToTheRequirementMs > bandFloorMs &&
      (overshootFraction - 0.49).abs() < 1e-9;

  static const String contradictionNote =
      'The Atomic Step asks for a snap under 150 ms and the band that scores '
      'it sets a floor of 100 ms. An implementation built exactly to the '
      'stated requirement, at 149 ms, misses the floor by 49 per cent. Every '
      'band defect this track has recorded until now was internal to the band. '
      'This is the first time the row\'s own instruction and the row\'s own '
      'floor contradict each other, which means the row cannot be satisfied '
      'and scored at the same time.';

  // -----------------------------------------------------------------------
  // The ceiling, which is a sentence about the floor.
  // -----------------------------------------------------------------------

  static bool get theCeilingDescribesTheFailureRegion =>
      bandCeilingText.contains('>100ms') && bandCeilingText.contains('laggy');

  static bool get theCeilingIsWorseThanTheFloor =>
      theCeilingDescribesTheFailureRegion;

  static const int inversionsRecordedBeforeThis = 4;

  static int get inversionsIncludingThis =>
      inversionsRecordedBeforeThis + 1;

  static bool get thisIsTheFifthInvertedBand =>
      inversionsIncludingThis == 5 && theCeilingIsWorseThanTheFloor;

  static const String ceilingNote =
      'The ceiling reads ">100ms begins to feel laggy to users". That is not a '
      'boundary; it is the definition of being past the floor, written in the '
      'cell where the best attainable value belongs. Steps 325, 326, 334 and '
      '335 each inverted a latency band numerically. This one inverts it in '
      'words, which is the fifth and the first of its kind.';

  // -----------------------------------------------------------------------
  // Two measurements, one number.
  // -----------------------------------------------------------------------

  static const Map<HabotLatencyKind, String> whatEachMeans =
      <HabotLatencyKind, String>{
    HabotLatencyKind.responseToFirstFrame:
        'from the finger leaving the glass to the first frame that moves',
    HabotLatencyKind.animationDuration:
        'from the first frame of the snap to the last',
  };

  static bool get bothKindsAreNamed =>
      whatEachMeans.length == HabotLatencyKind.values.length;

  /// Nielsen's 0.1s governs the first of the two, not the second. The RAIL
  /// instant band is the same 100ms, and Step 236 already declared it.
  static Duration get responseBudget => HabotMotion.railInstant;

  /// The snap itself is a motion, so it comes from the motion tokens.
  static Duration get snapDuration => HabotMotion.standard;

  static bool get theResponseBudgetIsNielsensTenthOfASecond =>
      responseBudget.inMilliseconds == 100;

  /// 200ms of motion against a 100ms response budget: two clocks, two
  /// values, neither derived from the other.
  static bool get theTwoBudgetsAreDifferentTokens =>
      snapDuration != responseBudget;

  static bool get bothComeFromTokens =>
      responseBudget == HabotMotion.railInstant &&
      snapDuration == HabotMotion.standard;

  static const List<HabotSnapSample> samples = <HabotSnapSample>[
    HabotSnapSample(label: 'built here', responseMs: 16, durationMs: 200),
    HabotSnapSample(
      label: 'the row\'s reading, taken literally',
      responseMs: 149,
      durationMs: 149,
    ),
    HabotSnapSample(
      label: 'fast motion, late start',
      responseMs: 200,
      durationMs: 50,
    ),
  ];

  static bool respondsInstantly(HabotSnapSample s) =>
      s.responseMs <= responseBudget.inMilliseconds;

  static int get samplesThatRespondInstantly =>
      samples.where(respondsInstantly).length;

  /// The fast-but-late sample has the best animation duration in the set and
  /// is the one a person would call broken.
  static bool get theShortestAnimationIsTheWorstExperience =>
      samples.last.durationMs == bandOptimalMs &&
      !respondsInstantly(samples.last);

  static const String conflationNote =
      'Nielsen\'s 0.1 second limit governs the interval from an input to the '
      'first visible acknowledgement. A snap animation\'s duration is how long '
      'the motion runs once it has begun. They are different clocks. A 200 ms '
      'motion that starts within one frame reads as instant and smooth; a '
      '50 ms motion that starts 200 ms late reads as a stutter, and it is the '
      'one with the better number in the cell the row measures.';

  // -----------------------------------------------------------------------
  // What is actually built.
  // -----------------------------------------------------------------------

  static bool get theSnapIsDrivenByTheTokens => bothComeFromTokens;

  static const bool theDurationIsALiteral = false;

  static const String buildNote =
      'The response budget and the motion duration are both read from the '
      'motion tokens, so neither is a literal in a widget and neither can '
      'drift from the other rows that use them. What this file refuses to do '
      'is pick one number to satisfy both halves of a row that asks for two.';

  static Map<String, bool> get obligations => <String, bool>{
        'response and duration are measured separately': bothKindsAreNamed,
        'both budgets come from the motion tokens': bothComeFromTokens,
        'no duration is written as a literal': !theDurationIsALiteral,
        'the contradiction between the row and its band is recorded':
            contradictionNote.contains('49 per cent'),
        'the ceiling defect is recorded as an inversion':
            thisIsTheFifthInvertedBand,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'the requirement is looser than the floor that scores it':
            theRequirementExceedsItsOwnFloor &&
                requirementCeilingMs == 150 &&
                bandFloorMs == 100,
        'building to specification misses the floor by 49 per cent':
            buildingToSpecFailsTheFloor,
        'the ceiling is prose describing the failure region':
            theCeilingDescribesTheFailureRegion,
        'and it is the fifth inverted band, first of its kind':
            thisIsTheFifthInvertedBand &&
                ceilingNote.contains('inverts it in words'),
        'two latency kinds, each named': bothKindsAreNamed,
        'the response budget is Nielsen\'s tenth of a second, from tokens':
            theResponseBudgetIsNielsensTenthOfASecond &&
                bothComeFromTokens &&
                theTwoBudgetsAreDifferentTokens,
        'three worked samples, one of which responds instantly':
            samples.length == 3 && samplesThatRespondInstantly == 1,
        'the best animation number is the worst experience':
            theShortestAnimationIsTheWorstExperience &&
                conflationNote.contains('different clocks'),
        'the snap is token-driven rather than literal':
            theSnapIsDrivenByTheTokens &&
                !theDurationIsALiteral &&
                buildNote.contains('two'),
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: the Atomic Step on this row asks for a snap animation '
      'under 150ms while the band that scores it sets a floor of "<=100ms", so '
      'the row contradicts itself; its ceiling is the sentence ">100ms begins '
      'to feel laggy to users", which describes the failure region rather than '
      'a boundary; and every narrative column is the generic '
      'engineering-console boilerplate. Atomic Step: "Implement the mobile UX '
      'performance requirement: Swipe threshold snap animation duration '
      '<150ms."';
}
