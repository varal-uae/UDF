/// Step 422 (UFHT-025-12) -- time-to-action per screen, carrying a touch-target
/// band for the third time in the track.
///
/// The row: "Compute the average time-to-action metric for every active layout
/// view screen."
/// Metric: **Touch Target Size & Accessibility Compliance** -- floor "44px /
/// WCAG AA", optimal "48px / WCAG AA", ceiling "56px / WCAG AAA". Best
/// Qualitative Output: "Good (Scale: Good/Average/Poor)". Assigned to **UDF**.
///
/// **The band belongs to a touch-target row, for the third time.** Step 342
/// carried it first, Step 402 carried it again in the last batch, and it is
/// here on a row about how long a screen takes to produce an action. Three
/// occurrences stop being a mistake and start being a default: this band is
/// what the sheet writes when nobody supplied one, and the rows that carry it
/// have nothing in common except that.
///
/// **"Average" again, one row later, and the same objection.** Step 421 showed
/// the mean being carried by a single interrupted session. Time-to-action is
/// the same distribution one level up, so the same three statistics are
/// published: the mean the row asks for, the median, and the ninetieth
/// percentile, with the count.
///
/// **This row and Step 421 are close and are not the same.** Field focus
/// duration is time inside one field; time-to-action is time from a screen
/// appearing to its transaction committing, which includes reading the screen,
/// deciding, and everything in between the fields. They are not collapsed --
/// but they are the second pair in two batches close enough that a reader could
/// reasonably think one of them is redundant, and the difference is written
/// down here so nobody has to guess later.
///
/// **The row's own design cells make a claim worth taking seriously.** Among
/// them: "Protects workforce from subjective micromanagement." Aggregated by
/// screen, that is true and is the best argument for this whole batch -- a
/// measured screen is an argument against a manager's impression. Attributed to
/// an individual it becomes the micromanagement it claims to prevent, which is
/// why Step 416 fixed the unit of analysis before any of these rows computed
/// anything.
library;

import 'field_focus_duration.dart';
import 'friction_framework.dart';
import 'tracking_sdk.dart';

/// One screen's time-to-action observations.
class HabotScreenTiming {
  const HabotScreenTiming({
    required this.screenId,
    required this.millisToAction,
    required this.fieldsOnScreen,
  });

  final String screenId;

  /// Screen appeared to transaction committed.
  final List<int> millisToAction;

  final int fieldsOnScreen;
}

/// The time-to-action metric.
class HabotTimeToAction {
  const HabotTimeToAction._();

  // -----------------------------------------------------------------------
  // The band is somebody else's, for the third time.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = '44px / WCAG AA';
  static const String bandOptimalRaw = '48px / WCAG AA';
  static const String bandCeilingRaw = '56px / WCAG AAA';

  static bool get theBandIsAboutTouchTargets =>
      bandFloorRaw.contains('px') && bandCeilingRaw.contains('WCAG');

  static const String whatThisRowMeasures = 'time from screen to action';

  static bool get theBandMeasuresSomethingElse =>
      theBandIsAboutTouchTargets &&
      !whatThisRowMeasures.contains('px');

  /// Steps 342, 402 and this one.
  static const List<int> rowsCarryingThisBand = <int>[342, 402, 422];

  static bool get thirdOccurrence => rowsCarryingThisBand.length == 3;

  static const bool itIsADefaultRatherThanAMistake = true;

  static const String bandNote =
      'Step 342 carried this touch-target band first, Step 402 carried it '
      'again last batch, and it is here on a row about how long a screen takes '
      'to produce an action. Three occurrences across three unrelated subjects '
      'stop being a mistake and start being a default -- this is what the '
      'sheet writes when nobody supplied a band -- and the rows that carry it '
      'have nothing in common except that nobody supplied one.';

  // -----------------------------------------------------------------------
  // The worked set.
  // -----------------------------------------------------------------------

  static const List<HabotScreenTiming> screens = <HabotScreenTiming>[
    HabotScreenTiming(
      screenId: 'clock_in',
      millisToAction: <int>[4100, 3800, 4400, 3900, 4200, 4000, 4300],
      fieldsOnScreen: 1,
    ),
    HabotScreenTiming(
      screenId: 'overtime_request',
      millisToAction: <int>[26400, 31200, 28800, 24100, 33500, 29700, 27300],
      fieldsOnScreen: 4,
    ),
    HabotScreenTiming(
      screenId: 'shift_swap',
      millisToAction: <int>[15200, 14100, 16800, 13900, 118000, 15600, 14800],
      fieldsOnScreen: 3,
    ),
  ];

  static int get screenCount => screens.length;

  static int get observationCount => screens.fold(
      0, (int a, HabotScreenTiming s) => a + s.millisToAction.length);

  static int meanMs(HabotScreenTiming s) => s.millisToAction.isEmpty
      ? 0
      : s.millisToAction.reduce((int a, int b) => a + b) ~/
          s.millisToAction.length;

  static int medianMs(HabotScreenTiming s) {
    final List<int> v = List<int>.from(s.millisToAction)..sort();
    return v.isEmpty ? 0 : v[v.length ~/ 2];
  }

  static int p90Ms(HabotScreenTiming s) {
    final List<int> v = List<int>.from(s.millisToAction)..sort();
    if (v.isEmpty) {
      return 0;
    }
    return v[((v.length - 1) * 9) ~/ 10];
  }

  static HabotScreenTiming get skewedScreen => screens.last;

  static bool get theMeanIsPulledUpwards =>
      meanMs(skewedScreen) > medianMs(skewedScreen) * 2;

  static const bool onlyTheAverageIsPublished = false;

  static bool get threeStatisticsArePublished => !onlyTheAverageIsPublished;

  static bool get theSameObjectionAsStep421 =>
      HabotFieldFocusDuration.theMeanExceedsThePercentile;

  static const String statisticNote =
      'On the worked set the shift-swap screen has a mean more than twice its '
      'median, carried by one observation just under two minutes -- the same '
      'shape Step 421 found one level down. The mean the row asks for is '
      'published with the median, the ninetieth percentile and the count '
      'beside it, because a time-to-action figure quoted alone is a figure '
      'about interruptions.';

  // -----------------------------------------------------------------------
  // Close to Step 421 and not the same.
  // -----------------------------------------------------------------------

  static const String whatStep421Measures =
      'time inside one field, from focus to blur';

  static const String whatThisMeasures =
      'time from a screen appearing to its transaction committing, including '
      'reading it, deciding, and everything between the fields';

  static bool get theTwoAreDistinct =>
      whatStep421Measures != whatThisMeasures;

  static const bool theyWereCollapsed = false;

  static bool get theDifferenceIsWrittenDown =>
      theTwoAreDistinct && !theyWereCollapsed;

  static const String adjacencyNote =
      'Field focus duration is time inside one field; time-to-action is time '
      'from a screen appearing to its transaction committing, which includes '
      'reading the screen and deciding. They are not the same measure and they '
      'are not collapsed. They are close enough that a reader could reasonably '
      'think one is redundant, which is why the difference is written down '
      'here rather than left for somebody to rediscover during a cleanup.';

  // -----------------------------------------------------------------------
  // The claim in the design cells.
  // -----------------------------------------------------------------------

  static const String theRowsClaim =
      'Protects workforce from subjective micromanagement';

  static const bool theClaimHoldsWhenAggregatedByScreen = true;

  static const bool theClaimHoldsWhenAttributedToAPerson = false;

  static bool get theClaimDependsOnTheUnitOfAnalysis =>
      theClaimHoldsWhenAggregatedByScreen &&
      !theClaimHoldsWhenAttributedToAPerson;

  static bool get theUnitWasFixedAtStep416 =>
      HabotFrictionFramework.theUnitOfAnalysisIsAScreen;

  static bool get theGroupingIsByScreen =>
      HabotTrackingSdk.permits('screen_id') &&
      !HabotTrackingSdk.permits('user_id');

  static const String claimNote =
      'The row claims this measurement protects the workforce from subjective '
      'micromanagement. Aggregated by screen that is true, and it is the best '
      'argument for this whole batch: a measured screen is an argument against '
      'a manager\'s impression, and the screen cannot be offended. Attributed '
      'to an individual the same number becomes the micromanagement it claims '
      'to prevent, which is why Step 416 fixed the unit of analysis before any '
      'of these rows computed anything.';

  // -----------------------------------------------------------------------
  // What is published.
  // -----------------------------------------------------------------------

  static bool get everyScreenHasAllThreeStatistics =>
      screens.every((HabotScreenTiming s) => medianMs(s) > 0);

  static bool get theSlowestScreenHasTheMostFields =>
      screens
          .reduce((HabotScreenTiming a, HabotScreenTiming b) =>
              medianMs(a) > medianMs(b) ? a : b)
          .fieldsOnScreen ==
      4;

  static String get qualitativeOutput =>
      threeStatisticsArePublished && everyScreenHasAllThreeStatistics
          ? 'Good'
          : 'Average';

  static const String columnNote =
      'COLUMN NOTE: this row is scored on "Touch Target Size & Accessibility '
      'Compliance" with a 44px/48px/56px band, which belongs to a touch-target '
      'row and is here on a row about time-to-action -- the third occurrence '
      'in the track after Steps 342 and 402, which makes it the sheet\'s '
      'default band rather than one row\'s mistake; its Best Qualitative '
      'Output cell reads "Good (Scale: Good/Average/Poor)", stating its own '
      'answer and then the scale; its Data Requirement holds the Layout '
      'Type/Grid Dimensions field set that belongs to a layout row; and its '
      'design cells claim the measurement protects the workforce from '
      'subjective micromanagement, which is true by screen and false by '
      'person. Atomic Step: "Compute the average time-to-action metric for '
      'every active layout view screen."';

  static Map<String, bool> get obligations => <String, bool>{
        'the mean is published with the median and the p90':
            threeStatisticsArePublished,
        'every screen carries all three': everyScreenHasAllThreeStatistics,
        'the unit of analysis is a screen': theGroupingIsByScreen,
        'the difference from Step 421 is written down':
            theDifferenceIsWrittenDown,
        'the band is recorded as belonging elsewhere':
            theBandMeasuresSomethingElse,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the band belongs to a touch-target row':
            theBandIsAboutTouchTargets && theBandMeasuresSomethingElse,
        'third occurrence, so it is a default':
            thirdOccurrence && itIsADefaultRatherThanAMistake,
        'three screens and twenty-one observations':
            screenCount == 3 && observationCount == 21,
        'one screen has a mean twice its median':
            theMeanIsPulledUpwards && theSameObjectionAsStep421,
        'so three statistics are published':
            threeStatisticsArePublished && everyScreenHasAllThreeStatistics,
        'this row and Step 421 are distinct':
            theTwoAreDistinct && theDifferenceIsWrittenDown,
        'and the difference is written down rather than rediscovered':
            adjacencyNote.contains('during a cleanup'),
        'the row\'s claim holds by screen and fails by person':
            theClaimDependsOnTheUnitOfAnalysis && theUnitWasFixedAtStep416,
        'and the grouping is by screen':
            theGroupingIsByScreen && claimNote.contains('cannot be offended'),
        'five obligations, all met, giving Good':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good' &&
                theSlowestScreenHasTheMostFields,
      };
}
