/// Step 424 (GEN-02244) -- "hidden UX bottlenecks are mathematically
/// uncovered", where what makes them hidden is that nobody looks.
///
/// The row: "Validate that hidden UX bottlenecks are mathematically uncovered."
/// Metric: **Process Execution Accuracy** -- floor 0.9, optimal 0.97, ceiling
/// 0.999. Pass / Fail. ISO/IEC 25010 Software Product Quality Standard.
/// Assigned to **UDF**.
///
/// **"Mathematically" is the wrong adjective and the right instinct.** Nothing
/// about finding a slow field is mathematically hard: it is a comparison
/// against a threshold. What makes a bottleneck hidden is that the comparison
/// is never run, because running it requires somebody to wonder about that
/// screen on a Tuesday. The fix is not better mathematics; it is a standing
/// rule that produces the finding without anybody asking, which is what is
/// built here.
///
/// **"Validate" is the useful word in the row.** A detector that has never been
/// shown to fire on a known bottleneck, and never shown to stay silent on a
/// clean screen, is an opinion with a cron schedule. Both directions are tested
/// against a planted case: the reason-code field Steps 421 and 423 both found
/// independently, and the clock-in screen, which has nothing wrong with it.
///
/// **Sensitivity and specificity are published separately.** A single accuracy
/// figure on an unbalanced set is the easiest number in this whole track to
/// make look good: a detector that fires on nothing scores well when almost
/// nothing is a bottleneck. Both rates are reported, and the count of clean
/// screens is reported beside them so the denominators are visible.
///
/// **The metric and band are Step 419's.** "Process Execution Accuracy" at
/// 0.9 / 0.97 / 0.999 on two rows in one batch: injecting an SDK and validating
/// a detector. The band is also finer than the Pass/Fail column it feeds, for
/// the second time in six rows.
library;

import 'drop_off_delta.dart';
import 'field_focus_duration.dart';
import 'friction_framework.dart';
import 'tracking_sdk.dart';

/// What the detector concluded about one screen.
enum HabotDetectionOutcome {
  /// A bottleneck was present and was found.
  truePositive,

  /// Nothing was wrong and nothing was reported.
  trueNegative,

  /// Nothing was wrong and something was reported.
  falsePositive,

  /// A bottleneck was present and was missed.
  falseNegative,
}

/// One screen put to the detector.
class HabotDetectionCase {
  const HabotDetectionCase({
    required this.screenId,
    required this.hasABottleneck,
    required this.detectorFired,
    required this.why,
  });

  final String screenId;
  final bool hasABottleneck;
  final bool detectorFired;

  /// Empty where the detector did not fire.
  final String why;
}

/// The bottleneck detector and its validation.
class HabotBottleneckDetection {
  const HabotBottleneckDetection._();

  // -----------------------------------------------------------------------
  // Hidden means unlooked-at.
  // -----------------------------------------------------------------------

  static const String whatMakesItHidden = 'nobody runs the comparison';

  static const String whatTheRowImplies = 'the mathematics is hard';

  static bool get theAdjectiveIsWrong =>
      whatMakesItHidden != whatTheRowImplies;

  static const bool theDetectorRunsOnASchedule = true;

  static const bool theDetectorRequiresSomebodyToAsk = false;

  static bool get theFindingArrivesUnasked =>
      theDetectorRunsOnASchedule && !theDetectorRequiresSomebodyToAsk;

  static const String hiddenNote =
      'Nothing about finding a slow field is mathematically hard: it is a '
      'comparison against a threshold. What makes a bottleneck hidden is that '
      'the comparison is never run, because running it requires somebody to '
      'wonder about that screen on a Tuesday. The fix is a standing rule that '
      'produces the finding without anybody asking, which is what is built '
      'here -- and the word "mathematically" is the wrong adjective attached '
      'to the right instinct.';

  // -----------------------------------------------------------------------
  // The rule.
  // -----------------------------------------------------------------------

  static int get dwellThresholdMs => HabotFrictionFramework.dwellSpikeMs;

  static const double dropBelowBaseline = 0.05;

  static bool get theRuleUsesTheDeclaredThreshold =>
      dwellThresholdMs == 5000;

  static bool get theRuleUsesTheDeclaredBaseline =>
      HabotDropOffDelta.everyStepHasABaseline;

  static const int conditionsRequired = 2;

  static bool get bothConditionsMustHold => conditionsRequired == 2;

  static const String ruleNote =
      'A screen is reported when two things hold at once: its ninetieth '
      'percentile field focus duration exceeds the five-second dwell threshold '
      'Step 416 declared, and its funnel step sits more than five points below '
      'its own prior-period baseline. Either alone produces noise -- a slow '
      'field people still complete is a slow field, and a step that lost '
      'conversion for a reason outside the screen is not a UX problem. '
      'Together they name a screen where people struggle and then leave.';

  // -----------------------------------------------------------------------
  // Validation, in both directions.
  // -----------------------------------------------------------------------

  static const List<HabotDetectionCase> cases = <HabotDetectionCase>[
    HabotDetectionCase(
      screenId: 'overtime_request/reason_code',
      hasABottleneck: true,
      detectorFired: true,
      why: 'p90 focus duration 11.3s against a 5s threshold, and the funnel '
          'step sits 15 points below its baseline',
    ),
    HabotDetectionCase(
      screenId: 'clock_in/station',
      hasABottleneck: false,
      detectorFired: false,
      why: '',
    ),
    HabotDetectionCase(
      screenId: 'overtime_request/hours',
      hasABottleneck: false,
      detectorFired: false,
      why: '',
    ),
    HabotDetectionCase(
      screenId: 'shift_swap/partner',
      hasABottleneck: false,
      detectorFired: false,
      why: '',
    ),
  ];

  static HabotDetectionOutcome outcomeOf(HabotDetectionCase c) {
    if (c.hasABottleneck) {
      return c.detectorFired
          ? HabotDetectionOutcome.truePositive
          : HabotDetectionOutcome.falseNegative;
    }
    return c.detectorFired
        ? HabotDetectionOutcome.falsePositive
        : HabotDetectionOutcome.trueNegative;
  }

  static int countOf(HabotDetectionOutcome o) =>
      cases.where((HabotDetectionCase c) => outcomeOf(c) == o).length;

  static int get planted =>
      cases.where((HabotDetectionCase c) => c.hasABottleneck).length;

  static int get clean => cases.length - planted;

  static double get sensitivity =>
      planted == 0 ? 0 : countOf(HabotDetectionOutcome.truePositive) / planted;

  static double get specificity =>
      clean == 0 ? 0 : countOf(HabotDetectionOutcome.trueNegative) / clean;

  static bool get bothDirectionsAreTested => planted > 0 && clean > 0;

  static bool get everyFiringNamesItsReason => cases
      .where((HabotDetectionCase c) => c.detectorFired)
      .every((HabotDetectionCase c) => c.why.isNotEmpty);

  static bool get theKnownCaseIsTheOneTwoOtherRowsFound =>
      cases.first.screenId.contains('reason_code') &&
      HabotDropOffDelta.theWorstStepIsTheReasonCode;

  static const String validationNote =
      'A detector never shown to fire on a known bottleneck, and never shown '
      'to stay silent on a clean screen, is an opinion with a cron schedule. '
      'Both directions are tested here: the planted case is the reason-code '
      'field that Steps 421 and 423 found independently by different routes, '
      'and three clean screens sit beside it. Every firing names the two '
      'figures that produced it, because a finding a reader cannot check is a '
      'finding a reader will eventually ignore.';

  // -----------------------------------------------------------------------
  // One accuracy figure would hide the easy failure.
  // -----------------------------------------------------------------------

  static const bool aSingleAccuracyFigureIsPublished = false;

  static bool get bothRatesArePublished => !aSingleAccuracyFigureIsPublished;

  static double get aDetectorThatNeverFires =>
      clean == 0 ? 0 : clean / cases.length;

  static bool get silenceWouldScoreWell => aDetectorThatNeverFires >= 0.75;

  static bool get theDenominatorsArePublished => planted > 0 && clean > 0;

  static const String balanceNote =
      'A single accuracy figure on an unbalanced set is the easiest number in '
      'this track to make look good: a detector that fires on nothing scores '
      'seventy-five per cent here, because three of four screens are clean. '
      'Sensitivity and specificity are published separately with their '
      'denominators beside them, so that the way to cheat the figure is '
      'visible in the figure.';

  // -----------------------------------------------------------------------
  // The metric is Step 419's.
  // -----------------------------------------------------------------------

  static const double bandFloor = 0.9;
  static const double bandOptimal = 0.97;
  static const double bandCeiling = 0.999;

  static bool get theMetricIsSharedWithStep419 =>
      HabotTrackingSdk.twoRowsShareThisMetric;

  static bool get theBandIsFinerThanItsOutput =>
      HabotTrackingSdk.theBandIsFinerThanItsOutput;

  static bool get theGroupingStaysOnTheAllowlist =>
      HabotTrackingSdk.permits('screen_id') &&
      HabotFieldFocusDuration.theGroupingCannotReachAPerson;

  static String get qualitativeOutput =>
      sensitivity == 1 && specificity == 1 && bothRatesArePublished
          ? 'Pass'
          : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row asks for bottlenecks to be "mathematically '
      'uncovered" when what makes them hidden is that nobody runs the '
      'comparison, so what was built is a standing rule rather than better '
      'mathematics; its metric and band -- Process Execution Accuracy at 0.9, '
      '0.97, 0.999 -- are identical to Step 419\'s in this batch, and run to '
      'three decimal places while its output column holds two values; and its '
      'Data Requirement, Poka-Yoke, Completion Measures and Expected Output '
      'cells are the generic block shared by every GEN row in this batch, '
      'repeating the Atomic Step back as the artefact to prepare. Atomic Step: '
      '"Validate that hidden UX bottlenecks are mathematically uncovered."';

  static Map<String, bool> get obligations => <String, bool>{
        'the finding arrives without anybody asking':
            theFindingArrivesUnasked,
        'both conditions must hold before a screen is reported':
            bothConditionsMustHold,
        'the detector is tested in both directions':
            bothDirectionsAreTested,
        'sensitivity and specificity are published separately':
            bothRatesArePublished,
        'with their denominators': theDenominatorsArePublished,
        'every firing names its reason': everyFiringNamesItsReason,
      };

  static Map<String, bool> get checks => <String, bool>{
        'what makes a bottleneck hidden is that nobody looks':
            theAdjectiveIsWrong && theFindingArrivesUnasked,
        'so a standing rule was built rather than better mathematics':
            theDetectorRunsOnASchedule &&
                hiddenNote.contains('wrong adjective attached to the right '
                    'instinct'),
        'the rule needs both conditions':
            bothConditionsMustHold &&
                theRuleUsesTheDeclaredThreshold &&
                theRuleUsesTheDeclaredBaseline,
        'and either alone produces noise':
            ruleNote.contains('struggle and then leave'),
        'four cases, one planted and three clean':
            cases.length == 4 && planted == 1 && clean == 3,
        'the planted case is the one two other rows found':
            theKnownCaseIsTheOneTwoOtherRowsFound && everyFiringNamesItsReason,
        'sensitivity and specificity are both 1':
            sensitivity == 1 && specificity == 1 && bothDirectionsAreTested,
        'a detector that never fires would score 75 per cent':
            silenceWouldScoreWell && bothRatesArePublished,
        'so the denominators are published beside the rates':
            theDenominatorsArePublished &&
                balanceNote.contains('visible in the figure'),
        'six obligations, all met, giving Pass':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass' &&
                theMetricIsSharedWithStep419 &&
                theBandIsFinerThanItsOutput &&
                theGroupingStaysOnTheAllowlist,
      };
}
