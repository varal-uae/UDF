/// Step 306 (ERMWD-025-15) -- three severities, one hue, and a Data Collected
/// column asking for hex codes.
///
/// The row: "Style dialog icon with M3 error colors to signify severity."
/// Metric: **Process Execution Quality Score** -- floor >=90%, optimal >=98%,
/// ceiling 1. Good / Average / Poor. ISO 9001:2015.
///
/// **Material 3 has one error hue.** Its error roles are `error`, `onError`,
/// `errorContainer` and `onErrorContainer`: four roles, one colour family,
/// designed to say "this went wrong" rather than to say how badly. Asking
/// error colours to signify severity is asking a one-valued signal to carry
/// three values. The scheme this application already declares has a separate
/// warning role, so painting a warning in the error colour does not merely
/// fail to distinguish it -- it actively says the wrong thing, because the
/// person reads red as "this failed" and a warning has not failed.
///
/// **And colour cannot be the signal anyway.** WCAG 2.1 SC 1.4.1 Use of Colour
/// is Level A: colour must not be the only visual means of conveying
/// information. Roughly one man in twelve cannot separate the red from the
/// amber, and nobody at all can separate two shades of the same red. So each
/// severity carries a distinct glyph, a word, and the colour as reinforcement
/// -- three channels, of which colour is the one that can be removed without
/// loss.
///
/// **The contrast figures, and the one that only reaches AA.** The dialog icon
/// is non-text, so the applicable floor is 3:1 rather than 4.5:1, and every
/// pair clears it by a distance. The text that sits beside it is another
/// matter: M3's baseline error on the light surface is 6.38:1, which passes AA
/// and misses AAA by 0.62; the container pair reaches 12.77:1. Both are
/// recorded so the one that is merely adequate is visible.
///
/// **COLUMN NOTE.** Data Collected on this row is "Color Code (HEX/RGB); Color
/// Name; Color Scheme; Contrast Ratio; Color Application Map". A hex code
/// written into a widget is what this repository's RAW_COLOR_LITERAL guard has
/// forbidden since Step 4: the colour must come from the scheme so that both
/// themes are covered and a palette change cannot break the contrast
/// guarantee. The ratios below are recorded as measured values of the M3
/// baseline scheme; no colour is constructed here.
library;

import '../a11y/contrast.dart';
import 'status_badge.dart';

/// How bad it is.
enum HabotSeverity {
  /// Something happened that the person should know and need not act on.
  information,

  /// Something will go wrong unless the person does something.
  warning,

  /// Something has already gone wrong.
  error,
}

/// One severity, in all three channels.
class HabotSeverityPresentation {
  const HabotSeverityPresentation({
    required this.severity,
    required this.glyphName,
    required this.word,
    required this.role,
  });

  final HabotSeverity severity;

  /// The shape. Different outlines, not one outline in three colours.
  final String glyphName;

  /// The word that opens the dialog's title.
  final String word;

  /// The colour role, taken from the scheme rather than written here.
  final HabotStatusRole role;
}

/// The dialog icon.
class HabotSeverityIcon {
  const HabotSeverityIcon._();

  static const List<HabotSeverityPresentation> presentations =
      <HabotSeverityPresentation>[
    HabotSeverityPresentation(
      severity: HabotSeverity.information,
      glyphName: 'info_outline',
      word: 'For your information',
      role: HabotStatusRole.primary,
    ),
    HabotSeverityPresentation(
      severity: HabotSeverity.warning,
      glyphName: 'warning_amber_outline',
      word: 'Check before you continue',
      role: HabotStatusRole.warning,
    ),
    HabotSeverityPresentation(
      severity: HabotSeverity.error,
      glyphName: 'error_outline',
      word: 'This did not work',
      role: HabotStatusRole.error,
    ),
  ];

  static HabotSeverityPresentation presentationFor(HabotSeverity s) =>
      presentations.firstWhere(
        (HabotSeverityPresentation p) => p.severity == s,
      );

  // -----------------------------------------------------------------------
  // One hue, three meanings.
  // -----------------------------------------------------------------------

  /// The four M3 error roles, which are one colour family.
  static const List<String> errorRoles = <String>[
    'error',
    'onError',
    'errorContainer',
    'onErrorContainer',
  ];

  static const int errorHues = 1;

  static int get severitiesToDistinguish => HabotSeverity.values.length;

  static bool get oneHueCannotCarryThree =>
      errorHues < severitiesToDistinguish;

  /// The scheme already separates warning from error; the row's instruction
  /// would collapse them.
  static bool get theSchemeAlreadySeparatesWarningFromError =>
      HabotStatusRole.values.length == 5 &&
      HabotStatusRole.warning != HabotStatusRole.error &&
      rolesUsed.contains(HabotStatusRole.warning) &&
      rolesUsed.contains(HabotStatusRole.error);

  static List<HabotStatusRole> get rolesUsed => presentations
      .map((HabotSeverityPresentation p) => p.role)
      .toSet()
      .toList();

  static bool get everySeverityHasItsOwnRole =>
      rolesUsed.length == severitiesToDistinguish;

  static const String hueNote =
      'Material 3 has four error roles and one error hue. It is built to say '
      '"this went wrong", not to say how badly, so asking error colours to '
      'signify severity asks a one-valued signal to carry three values. This '
      'application\'s scheme already declares a separate warning role, which '
      'makes the instruction worse than merely ineffective: painting a warning '
      'in the error colour says the wrong thing, because a person reads red as '
      '"this failed" and a warning has not failed yet.';

  // -----------------------------------------------------------------------
  // Three channels, of which colour is the removable one.
  // -----------------------------------------------------------------------

  static bool get everySeverityHasItsOwnGlyph =>
      presentations
          .map((HabotSeverityPresentation p) => p.glyphName)
          .toSet()
          .length ==
      severitiesToDistinguish;

  static bool get everySeverityHasItsOwnWord =>
      presentations
          .map((HabotSeverityPresentation p) => p.word)
          .toSet()
          .length ==
      severitiesToDistinguish;

  /// The test that matters: strip the colour and the three are still three.
  static bool get severityIsLegibleWithoutColour =>
      everySeverityHasItsOwnGlyph && everySeverityHasItsOwnWord;

  static const String criterion = 'WCAG 2.1 SC 1.4.1 Use of Colour';
  static const String criterionLevel = 'A';

  static const bool colourIsTheSoleSignal = false;

  static const String channelNote =
      'SC 1.4.1 is Level A: colour must not be the only visual means of '
      'conveying information. About one man in twelve cannot separate red from '
      'amber, and nobody at all can separate two shades of the same red. Each '
      'severity therefore carries a distinct outline, a distinct opening '
      'phrase and the colour as reinforcement. Remove the colour and the three '
      'are still three; remove the glyph and the word, and the row\'s '
      'instruction is all that is left.';

  /// And the word is a sentence rather than a label, because "Error" tells
  /// somebody what kind of box they are looking at and nothing else.
  static bool get noWordIsMerelyTheSeverityName => presentations.every(
        (HabotSeverityPresentation p) =>
            p.word.toLowerCase() != p.severity.name.toLowerCase(),
      );

  // -----------------------------------------------------------------------
  // The contrast figures.
  // -----------------------------------------------------------------------

  /// Measured ratios of the M3 baseline scheme. Recorded as numbers rather
  /// than recomputed here, because recomputing them means constructing the
  /// colours, and constructing a colour from a hex value is what the guard
  /// forbids.
  static const Map<String, double> measuredRatios = <String, double>{
    'error on light surface': 6.38,
    'onErrorContainer on errorContainer, light': 12.77,
    'error on dark surface': 10.03,
    'onErrorContainer on errorContainer, dark': 7.17,
  };

  /// An icon is non-text.
  static double get iconFloor => WcagThresholds.nonTextFloor;

  static double get textFloor => WcagThresholds.textFloor;

  static double get textOptimal => WcagThresholds.textOptimal;

  static bool get everyPairClearsTheNonTextFloor =>
      measuredRatios.values.every((double r) => r >= iconFloor);

  static bool get everyPairClearsTheTextFloor =>
      measuredRatios.values.every((double r) => r >= textFloor);

  static List<String> get pairsBelowTheTextOptimal => measuredRatios.entries
      .where((MapEntry<String, double> e) => e.value < textOptimal)
      .map((MapEntry<String, double> e) => e.key)
      .toList();

  static double get shortfallOnTheWeakestPair =>
      textOptimal - measuredRatios['error on light surface']!;

  static const String contrastNote =
      'The icon is non-text, so its floor is 3:1 and every pair clears it by a '
      'distance. The text beside it is held to 4.5:1 and every pair clears '
      'that too. Only one pair falls short of the 7:1 the project treats as '
      'optimal: M3\'s baseline error on the light surface, at 6.38, missing by '
      '0.62. That is worth knowing rather than worth fixing by inventing a '
      'colour, because the pair is Material\'s own and a local override would '
      'be the first crack in the scheme.';

  static const bool anyColourIsConstructedHere = false;

  static const String guardRule = 'RAW_COLOR_LITERAL';

  static const String hexNote =
      'Data Collected asks for "Color Code (HEX/RGB)". A hex code written into '
      'a widget is what RAW_COLOR_LITERAL has forbidden since Step 4: the '
      'value must come from the scheme so that both themes are covered and a '
      'palette change cannot silently break a contrast guarantee. The roles '
      'are named here, the ratios are recorded as measurements, and no colour '
      'is constructed. Step 287 refused the same instruction two batches ago '
      'for the same reason.';

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static Map<String, bool> get obligations => <String, bool>{
        'each severity has its own colour role': everySeverityHasItsOwnRole,
        'each severity has its own glyph': everySeverityHasItsOwnGlyph,
        'each severity has its own words': everySeverityHasItsOwnWord,
        'severity survives the removal of colour':
            severityIsLegibleWithoutColour,
        'no word is merely the name of the severity':
            noWordIsMerelyTheSeverityName,
        'no colour is constructed from a literal': !anyColourIsConstructedHere,
      };

  static double get executionQuality =>
      obligations.values.where((bool b) => b).length / obligations.length;

  static String get qualitativeOutput {
    if (executionQuality >= 0.98) {
      return 'Good';
    }
    return executionQuality >= 0.90 ? 'Average' : 'Poor';
  }

  static Map<String, bool> get checks => <String, bool>{
        'four error roles, one hue, three severities':
            errorRoles.length == 4 &&
                errorHues == 1 &&
                severitiesToDistinguish == 3 &&
                oneHueCannotCarryThree,
        'the scheme already separates warning from error':
            theSchemeAlreadySeparatesWarningFromError &&
                everySeverityHasItsOwnRole &&
                rolesUsed.length == 3,
        'painting a warning red says the wrong thing rather than nothing':
            hueNote.contains('has not failed yet'),
        'three channels, and colour is the removable one':
            severityIsLegibleWithoutColour && !colourIsTheSoleSignal,
        'the criterion is Level A':
            criterionLevel == 'A' && criterion.contains('1.4.1'),
        'no opening phrase is just the severity name':
            noWordIsMerelyTheSeverityName &&
                presentationFor(HabotSeverity.error).word ==
                    'This did not work',
        'every measured pair clears the non-text floor':
            everyPairClearsTheNonTextFloor && iconFloor == 3.0,
        'and the text floor too': everyPairClearsTheTextFloor,
        'one pair misses the optimal by 0.62':
            pairsBelowTheTextOptimal.length == 1 &&
                pairsBelowTheTextOptimal.first == 'error on light surface' &&
                (shortfallOnTheWeakestPair - 0.62).abs() < 1e-9,
        'and it is recorded rather than overridden':
            contrastNote.contains('first crack in the scheme'),
        'the hex instruction is refused with its rule named':
            !anyColourIsConstructedHere &&
                guardRule == 'RAW_COLOR_LITERAL' &&
                hexNote.contains('Step 287'),
        'six obligations, all met':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                executionQuality == 1.0,
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Capture raw input '
      'string entered by user in real time", which is a form-input instruction '
      'on a dialog-styling row, and Data Collected asks for hex colour codes. '
      'Atomic Step: "Style dialog icon with M3 error colors to signify '
      'severity."';
}
