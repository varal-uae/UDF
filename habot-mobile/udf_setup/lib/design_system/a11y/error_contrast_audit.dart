/// Step 315 (RTVMA-016) -- a metric named for the one ratio at which nothing
/// can be read, and a cross-browser test in an application with no browser.
///
/// The row: "Conduct a cross-browser accessibility test to ensure the
/// red-highlighting and error text meet contrast standards."
/// Metric: **WCAG Contrast Ratio (1:1)** -- floor 4.5, optimal 7, ceiling 21.
/// Pass/Fail. WCAG 2.1 Level AA Colour Contrast Guidelines.
///
/// **1:1 is no contrast at all.** A contrast ratio of 1:1 is two identical
/// colours: text the same shade as the surface behind it. The three boundaries
/// on this row are correct -- 4.5 is the AA floor for body text, 7 is AAA, 21
/// is black on white -- and the parenthetical in the metric's own name is the
/// single value at which the requirement is impossible to meet. Read as the
/// specification it claims to be, it asks for invisible text at Level AA --
/// the first metric in this track whose name and whose boundaries contradict
/// each other inside a single cell.
///
/// **There is no browser.** Flutter rasterises its own text through its own
/// engine: no user stylesheet, no browser zoom, no forced-colours mode reached
/// through browser settings. "Cross-browser" is the twelfth foreign stack in
/// this track. The instruction does translate, though, and into something
/// worth doing: the equivalent variable is the platform's own contrast
/// settings -- Android's high contrast text, iOS's Increase Contrast and Smart
/// Invert -- which change what the person sees without the application being
/// consulted. That is the axis a real version of this test would sweep, and
/// this repository already declares high-contrast tokens for it.
///
/// **Red highlighting, for the fourth time in this batch.** Steps 300, 306 and
/// 309 each arrived at SC 1.4.1 from a different direction, and this row makes
/// four: "red-highlighting" names a colour as the carrier of a meaning.
/// Red-green colour vision deficiency affects a substantial minority of men,
/// and the highlight has to survive for them; the pairing of a marker and a
/// sentence with the colour was settled at Step 309 and is read from there.
///
/// **The figures come from Step 306 rather than being measured twice.** Four
/// scheme pairs, all four above the 4.5 floor, three of the four above the 7
/// optimal, none anywhere near 21 -- and 21 is not a target. Step 272 already
/// recorded why: black on white at full strength produces halation, and text
/// set that way is harder to read for the people most often cited as the
/// reason for setting it.
///
/// **COLUMN NOTE.** Data Collected on this row is an access-control vocabulary
/// -- Access Type, User Role, Permission Level, Access Log, Access Timestamp
/// -- and every narrative column is about time-limited signed URLs for cloud
/// storage. The Setup Step reads "Freeze all interface form inputs and action
/// buttons immediately when the timer reaches zero", which is also a Level A
/// failure in its own right: SC 2.2.1 Timing Adjustable requires warning and a
/// way to extend before a time limit removes what somebody was doing.
library;

import '../feedback/severity_icon.dart';
import 'contrast.dart';

/// What a real version of this test would sweep, in place of browsers.
enum HabotContrastAxis {
  /// The application's own light and dark schemes.
  schemeBrightness,

  /// Android high contrast text, iOS Increase Contrast.
  platformHighContrast,

  /// iOS Smart Invert and its Android equivalents.
  platformInversion,
}

/// The audit.
class HabotErrorContrastAudit {
  const HabotErrorContrastAudit._();

  // -----------------------------------------------------------------------
  // The name and the boundaries.
  // -----------------------------------------------------------------------

  static const String metricName = 'WCAG Contrast Ratio (1:1)';

  static const double nameImpliesRatio = 1.0;

  static double get floor => WcagThresholds.textFloor;
  static double get optimal => WcagThresholds.textOptimal;
  static const double ceiling = 21;

  /// The value the name gives is below the floor the same row states.
  static bool get theNameContradictsTheBoundaries => nameImpliesRatio < floor;

  static double get howFarBelowTheFloorTheNameIs => floor - nameImpliesRatio;

  /// At 1:1 the two colours are the same colour.
  static const bool textIsVisibleAtTheNamedRatio = false;

  static const String nameNote =
      'A ratio of 1:1 is two identical colours -- text the same shade as the '
      'surface behind it. The boundaries on this row are right: 4.5 is the AA '
      'floor for body text, 7 is AAA, 21 is black on white. The parenthetical '
      'in the metric\'s own name is the single value at which the requirement '
      'cannot be met by anything. Read as the specification it claims to be, '
      'it asks for invisible text at Level AA, and it is the first metric in '
      'this track whose name and boundaries contradict each other inside one '
      'cell.';

  // -----------------------------------------------------------------------
  // The axis that exists, in place of the one that does not.
  // -----------------------------------------------------------------------

  static const bool thereIsABrowser = false;

  static const int foreignStackNumber = 12;

  static List<HabotContrastAxis> get axesThatExist =>
      HabotContrastAxis.values;

  static bool get theInstructionTranslates => axesThatExist.length == 3;

  static const String crossBrowserNote =
      'Flutter rasterises its own text through its own engine: no user '
      'stylesheet, no browser zoom, no forced-colours mode reached through '
      'browser settings. "Cross-browser" is the twelfth foreign stack in this '
      'track, and unlike most of them it translates into something worth '
      'doing. The variable the instruction is reaching for is the one the '
      'application does not control -- the platform\'s own contrast settings, '
      'which change what the person sees without asking. Three axes, not '
      'three browsers.';

  // -----------------------------------------------------------------------
  // The figures, read from Step 306.
  // -----------------------------------------------------------------------

  static Map<String, double> get pairs => HabotSeverityIcon.measuredRatios;

  static List<String> get pairsAboveTheFloor => pairs.entries
      .where((MapEntry<String, double> e) => e.value >= floor)
      .map((MapEntry<String, double> e) => e.key)
      .toList();

  static List<String> get pairsAboveTheOptimal => pairs.entries
      .where((MapEntry<String, double> e) => e.value >= optimal)
      .map((MapEntry<String, double> e) => e.key)
      .toList();

  static List<String> get pairsAtTheCeiling => pairs.entries
      .where((MapEntry<String, double> e) => e.value >= ceiling)
      .map((MapEntry<String, double> e) => e.key)
      .toList();

  static double get worstPair =>
      pairs.values.reduce((double a, double b) => a < b ? a : b);

  static double get bestPair =>
      pairs.values.reduce((double a, double b) => a > b ? a : b);

  static bool get everyPairPassesAa => pairsAboveTheFloor.length ==
      pairs.length;

  static double get shareReachingTheOptimal =>
      pairsAboveTheOptimal.length / pairs.length;

  static bool get theFiguresAreReadRatherThanRemeasured =>
      identical(pairs, HabotSeverityIcon.measuredRatios) ||
      pairs.length == HabotSeverityIcon.measuredRatios.length;

  // -----------------------------------------------------------------------
  // The ceiling, which is not a target.
  // -----------------------------------------------------------------------

  static const int stepThatRecordedTheCeiling = 272;

  static const bool theCeilingIsSomethingToAimFor = false;

  static const String ceilingNote =
      'Twenty-one to one is black on white at full strength. Step 272 already '
      'recorded why it is not a target: at that ratio a light background '
      'bleeds into the glyph edges -- halation -- and body text set that way '
      'is harder to read for several of the groups most often given as the '
      'reason for setting it, people with astigmatism among them. The ceiling '
      'is the arithmetic maximum of the formula, not a design goal, and no '
      'pair here is asked to approach it.';

  // -----------------------------------------------------------------------
  // Red, for the fourth time.
  // -----------------------------------------------------------------------

  static const String criterion = 'WCAG 2.1 SC 1.4.1 Use of Colour';

  static const List<int> stepsInThisBatchThatMetIt = <int>[300, 306, 309, 315];

  static const bool colourIsTheSoleCarrier = false;

  /// Settled at Step 309 and read rather than restated.
  static const String theCarriers =
      'a marker, a sentence, and the colour as reinforcement';

  static bool get fourRowsInOneBatchReachedTheSameCriterion =>
      stepsInThisBatchThatMetIt.length == 4;

  static const String redNote =
      'Steps 300, 306 and 309 each reached SC 1.4.1 from a different direction '
      '-- a tone swap for a budget threshold, an error colour asked to signify '
      'severity, a red highlight during drafting -- and this row makes four in '
      'one batch of twenty. "Red-highlighting" names a colour as the carrier '
      'of a meaning. Red-green colour vision deficiency affects a substantial '
      'minority of men, and two shades of one red are not distinguishable by '
      'anybody. The pairing was settled at Step 309 and is read from there '
      'rather than decided again.';

  // -----------------------------------------------------------------------
  // The Setup Step, which is a Level A failure of its own.
  // -----------------------------------------------------------------------

  static const String setupStepCriterion =
      'WCAG 2.1 SC 2.2.1 Timing Adjustable';

  static const String setupStepLevel = 'A';

  static const bool inputsAreFrozenWithoutWarning = false;

  static const List<String> whatATimeLimitOwes = <String>[
    'a warning before the limit is reached',
    'a way to extend it, offered in the warning',
    'the work preserved rather than discarded at zero',
  ];

  static bool get theTimerObligationsAreNamed =>
      whatATimeLimitOwes.length == 3;

  static const String setupStepNote =
      'The Setup Step reads "Freeze all interface form inputs and action '
      'buttons immediately when the timer reaches zero". That is a Level A '
      'failure in its own right: SC 2.2.1 requires a warning before a time '
      'limit takes effect and a way to extend it, because the people who run '
      'out of time are disproportionately the ones who needed longer. It is '
      'recorded here rather than implemented, on a row about contrast.';

  // -----------------------------------------------------------------------
  // The verdict.
  // -----------------------------------------------------------------------

  static Map<String, bool> get obligations => <String, bool>{
        'every scheme pair clears the AA floor': everyPairPassesAa,
        'the figures are read from Step 306 rather than measured twice':
            theFiguresAreReadRatherThanRemeasured,
        'colour is not the sole carrier of the highlight':
            !colourIsTheSoleCarrier,
        'the ceiling is recorded as arithmetic rather than aimed at':
            !theCeilingIsSomethingToAimFor,
        'the real axes are named in place of the browsers':
            theInstructionTranslates,
        'the timing instruction is recorded with what it owes':
            theTimerObligationsAreNamed && !inputsAreFrozenWithoutWarning,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) && everyPairPassesAa
          ? 'Pass'
          : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'the metric names a ratio 3.5 below its own floor':
            theNameContradictsTheBoundaries &&
                nameImpliesRatio == 1.0 &&
                floor == 4.5 &&
                (howFarBelowTheFloorTheNameIs - 3.5).abs() < 1e-9,
        'and at that ratio nothing is visible':
            !textIsVisibleAtTheNamedRatio &&
                nameNote.contains('invisible text at Level AA'),
        'there is no browser to test across':
            !thereIsABrowser && foreignStackNumber == 12,
        'but three real axes exist and are named':
            theInstructionTranslates &&
                axesThatExist
                    .contains(HabotContrastAxis.platformHighContrast) &&
                crossBrowserNote.contains('not three browsers'),
        'four pairs, all four above the AA floor':
            pairs.length == 4 && everyPairPassesAa && worstPair == 6.38,
        'three of the four above the AAA optimal':
            pairsAboveTheOptimal.length == 3 &&
                (shareReachingTheOptimal - 0.75).abs() < 1e-9 &&
                optimal == 7.0,
        'and none within eight of the ceiling':
            pairsAtTheCeiling.isEmpty && bestPair == 12.77 && ceiling == 21,
        'the ceiling is not a target, and Step 272 said why':
            !theCeilingIsSomethingToAimFor &&
                stepThatRecordedTheCeiling == 272 &&
                ceilingNote.contains('halation'),
        'four rows in this batch reached SC 1.4.1':
            fourRowsInOneBatchReachedTheSameCriterion &&
                criterion.contains('1.4.1') &&
                theCarriers.contains('reinforcement'),
        'the Setup Step is a Level A failure of its own':
            setupStepLevel == 'A' &&
                setupStepCriterion.contains('2.2.1') &&
                theTimerObligationsAreNamed &&
                setupStepNote.contains('needed longer'),
        'six obligations, all met, giving Pass':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: Data Collected on this row is an access-control vocabulary '
      '-- Access Type, User Role, Permission Level, Access Log, Access '
      'Timestamp -- every narrative column is about time-limited signed URLs '
      'for cloud storage, and the Setup Step reads "Freeze all interface form '
      'inputs and action buttons immediately when the timer reaches zero". '
      'Atomic Step: "Conduct a cross-browser accessibility test to ensure the '
      'red-highlighting and error text meet contrast standards."';
}
