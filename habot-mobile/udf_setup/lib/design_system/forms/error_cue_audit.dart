/// Step 250 (GEN-02071) -- the cues on a broken field, and the fourth thing
/// recovery needs that nothing was measuring.
///
/// The row: "Render multi-cue error states (color, text, and icon) on the
/// broken field."
/// Metric: **Error Recovery Success Rate (%)** -- floor 90, optimal 98,
/// ceiling 100. High/Medium/Low. Standard cited: WCAG 2.1 Error Recovery &
/// ISO/IEC 25010 Recoverability.
///
/// **The three cues the row asks for are already there, and so is a fourth.**
/// `HabotValidationStateColor.carriersFor(error)` returns colour, icon, text
/// and a semantic announcement. The row names three of those four. This step
/// does not render a fifth; it audits what recovery actually requires and
/// finds that the cue count was never the problem.
///
/// **WCAG asks for three things and the repository does two of them well.**
/// SC 1.4.1 Use of Color: satisfied, four carriers. SC 3.3.1 Error
/// Identification: satisfied, the error is attached to the field and
/// announced. SC 3.3.3 Error Suggestion: satisfied on the page -- all thirteen
/// declared messages tell the person what to enter rather than only that they
/// were wrong. Measured, not assumed.
///
/// **The gap is that three of those suggestions cannot be followed.** Step 238
/// found `dateIso`, `dateUs` and `timeOfDay` masked so that the separator
/// their own pattern requires is filtered out as the person types it. The
/// error message on `dateUs` says "Enter a date as MM/DD/YYYY" and the field
/// deletes the slash. That is a perfectly formed, perfectly accessible,
/// four-cue error state instructing somebody to do something the field
/// prevents. Recovery on those fields is not unlikely, it is impossible, and
/// no count of cues detects it.
///
/// **Measured: ten of thirteen fields are recoverable, 76.9, against a floor
/// of 90.** Reported Low. With Step 238's correction adopted it is 100.
library;

import 'field_validation.dart';
import 'mask_binding.dart';
import 'validation_state_color.dart';

/// What an error state has to do before a person can act on it.
enum HabotRecoveryRequirement {
  /// SC 1.4.1: the state is not carried by hue alone.
  notColourAlone,

  /// SC 3.3.1: the field in error is identified, in text, to a screen reader
  /// as well as on screen.
  identified,

  /// SC 3.3.3: the message says what to do, not only that something is
  /// wrong.
  suggestsAFix,

  /// Not in WCAG, and the one that fails here: the suggestion can actually be
  /// carried out in the field it is attached to.
  suggestionIsFollowable,
}

/// The audit.
class HabotErrorCueAudit {
  const HabotErrorCueAudit._();

  /// The cues the row names.
  static const List<String> cuesTheRowNames = <String>[
    'color',
    'text',
    'icon',
  ];

  /// The cues the repository already carries on an error, read from the
  /// declaration rather than restated.
  static Set<HabotStateCarrier> get declaredCues =>
      HabotValidationStateColor.carriersFor(HabotFieldVisualState.error);

  /// The fourth carrier, which the row omits.
  static bool get theRowOmitsOne =>
      declaredCues.length == cuesTheRowNames.length + 1 &&
      declaredCues.contains(HabotStateCarrier.semantics);

  static bool get noCueIsMissing =>
      declaredCues.contains(HabotStateCarrier.colour) &&
      declaredCues.contains(HabotStateCarrier.text) &&
      declaredCues.contains(HabotStateCarrier.icon);

  // -----------------------------------------------------------------------
  // SC 3.3.3: does the message say what to do?
  // -----------------------------------------------------------------------

  /// A message that states an action rather than a verdict. Checked by its
  /// opening verb, which is the difference between "Invalid date" and "Enter
  /// a date as YYYY-MM-DD".
  static bool suggestsAFix(String message) {
    const List<String> instructionOpeners = <String>[
      'Enter ',
      'Use ',
      'Choose ',
      'Select ',
      'Pick ',
    ];
    for (final String opener in instructionOpeners) {
      if (message.startsWith(opener)) {
        return true;
      }
    }
    return false;
  }

  static List<HabotCde> get fieldsWhoseMessageSuggestsAFix => HabotCde.values
      .where((HabotCde c) => suggestsAFix(HabotFieldRules.of(c).errorMessage))
      .toList();

  static double get suggestionRate =>
      fieldsWhoseMessageSuggestsAFix.length / HabotCde.values.length;

  // -----------------------------------------------------------------------
  // The fourth requirement.
  // -----------------------------------------------------------------------

  /// Whether a person can carry out the instruction in the field it is
  /// attached to. Read from Step 238's analysis rather than re-derived.
  static bool suggestionIsFollowable(HabotCde cde) =>
      HabotMaskBinding.agreementFor(cde).agrees;

  static List<HabotCde> get recoverableFields =>
      HabotCde.values.where(suggestionIsFollowable).toList();

  static List<HabotCde> get unrecoverableFields => HabotCde.values
      .where((HabotCde c) => !suggestionIsFollowable(c))
      .toList();

  /// The row's metric, measured over the fields this application declares.
  static double get errorRecoveryRate =>
      recoverableFields.length / HabotCde.values.length * 100;

  static double get errorRecoveryRateAfterCorrection =>
      HabotMaskBinding.correctionMakesEveryFieldReachable
          ? 100
          : errorRecoveryRate;

  /// The clearest single example, quoted rather than paraphrased.
  static String get worstCaseMessage =>
      HabotFieldRules.of(HabotCde.dateUs).errorMessage;

  static bool get worstCaseIsExactlyTheProblem =>
      suggestsAFix(worstCaseMessage) &&
      !suggestionIsFollowable(HabotCde.dateUs) &&
      HabotMaskBinding.agreementFor(HabotCde.dateUs)
          .blockedSeparators
          .contains('/');

  // -----------------------------------------------------------------------
  // The four requirements, scored.
  // -----------------------------------------------------------------------

  static Map<HabotRecoveryRequirement, double> get requirementScores =>
      <HabotRecoveryRequirement, double>{
        HabotRecoveryRequirement.notColourAlone:
            declaredCues.length > 1 ? 1 : 0,
        HabotRecoveryRequirement.identified:
            declaredCues.contains(HabotStateCarrier.semantics) &&
                    declaredCues.contains(HabotStateCarrier.text)
                ? 1
                : 0,
        HabotRecoveryRequirement.suggestsAFix: suggestionRate,
        HabotRecoveryRequirement.suggestionIsFollowable:
            recoverableFields.length / HabotCde.values.length,
      };

  static List<HabotRecoveryRequirement> get requirementsBelowOne =>
      requirementScores.entries
          .where((MapEntry<HabotRecoveryRequirement, double> e) =>
              e.value < 1)
          .map((MapEntry<HabotRecoveryRequirement, double> e) => e.key)
          .toList();

  static bool get exactlyOneRequirementFails =>
      requirementsBelowOne.length == 1 &&
      requirementsBelowOne.single ==
          HabotRecoveryRequirement.suggestionIsFollowable;

  // -----------------------------------------------------------------------
  // Notes.
  // -----------------------------------------------------------------------

  static const String cueCountWasNotTheProblemNote =
      'The three cues the row asks for are already there, and so is a fourth. '
      'carriersFor(error) returns colour, icon, text and a semantic '
      'announcement; the row names three of the four. This step does not '
      'render a fifth. It audits what recovery actually requires and finds '
      'that the cue count was never the problem.';

  static const String followableNote =
      'FINDING: three of the thirteen suggestions cannot be followed. Step '
      '238 found dateIso, dateUs and timeOfDay masked so that the separator '
      'their own pattern requires is filtered out as the person types it. The '
      'message on dateUs says "Enter a date as MM/DD/YYYY" and the field '
      'deletes the slash. That is a perfectly formed, perfectly accessible, '
      'four-cue error state instructing somebody to do something the field '
      'prevents. Recovery there is not unlikely, it is impossible, and no '
      'count of cues detects it -- which is why the fourth requirement in '
      'this audit is not one of the WCAG criteria. Nothing in WCAG says the '
      'suggestion has to be achievable, because nobody writing it imagined a '
      'field that eats the character it just asked for.';

  static const String rateIsAboutThePersonNote =
      '"Error Recovery Success Rate" measures whether people recover, which '
      'happens after the application stops -- the same shape as Step 214\'s '
      'cycle time. What the client controls is whether the error is '
      'identified, described, suggested and followable, so those four are '
      'what is measured. The figure published is the share of declared fields '
      'on which recovery is possible at all, which is the ceiling on any '
      'success rate that could ever be observed.';

  // -----------------------------------------------------------------------
  // Metric: Error Recovery Success Rate (%). High/Medium/Low.
  // -----------------------------------------------------------------------

  static const double floor = 90;
  static const double optimal = 98;
  static const double ceiling = 100;

  static String bandFor(double rate) {
    if (rate >= optimal) {
      return 'High';
    }
    return rate >= floor ? 'Medium' : 'Low';
  }

  /// **Low**, and correctly. Three fields in thirteen cannot be recovered
  /// from at all.
  static String get qualitativeOutput => bandFor(errorRecoveryRate);

  static String get qualitativeOutputAfterCorrection =>
      bandFor(errorRecoveryRateAfterCorrection);

  static Map<String, bool> get checks => <String, bool>{
        'the three cues the row names are all present':
            noCueIsMissing && cuesTheRowNames.length == 3,
        'a fourth carrier the row omits is present too': theRowOmitsOne,
        'every declared message states an action rather than a verdict':
            suggestionRate == 1.0 &&
                fieldsWhoseMessageSuggestsAFix.length == 13,
        'three suggestions cannot be followed in the field they are attached '
            'to': unrecoverableFields.length == 3,
        'the dateUs message is the worked example':
            worstCaseIsExactlyTheProblem &&
                worstCaseMessage.contains('MM/DD/YYYY'),
        'the measured recovery rate is below the row\'s floor':
            errorRecoveryRate < floor &&
                (errorRecoveryRate - 1000 / 13).abs() < 1e-9,
        'the step reports Low, and reports High once Step 238 is adopted':
            qualitativeOutput == 'Low' &&
                qualitativeOutputAfterCorrection == 'High',
        'exactly one of the four requirements is the one that fails':
            exactlyOneRequirementFails,
        'the failing requirement is the one WCAG does not have':
            requirementsBelowOne.single ==
                HabotRecoveryRequirement.suggestionIsFollowable &&
                followableNote.contains('not one of the WCAG criteria'),
        'the rate is described as a ceiling on what could be observed':
            rateIsAboutThePersonNote.contains('ceiling on any'),
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Render multi-cue error states (color, text, and icon) on the broken '
      'field."';
}
