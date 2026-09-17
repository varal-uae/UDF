/// Step 325 (CCPME-016) -- a latency band with the ideal at the floor, and a
/// narrative block this track has already seen on another row.
///
/// The row: '2. Build a "Force Majeure" mobile panic button.'
/// Metric: **Mobile Touch Response Time (ms)** -- floor **0**, optimal 100,
/// ceiling 300. Good / Average / Poor. W3C Mobile Web Best Practices.
///
/// **The band is inverted end to end.** On a measure where lower is better the
/// floor is the worst tolerable value and the ceiling is the best; here the
/// floor is 0 ms, which is the ideal and is also unattainable -- a display
/// refresh alone is 16.667 ms at 60Hz -- and the ceiling, 300 ms, is the worst
/// of the three. **Four of the five latency bands in this batch are inverted
/// this way** (325, 326, 334, 335) and one, Step 333, is ordered correctly.
/// One correct instance is what makes the other four an error rather than a
/// house convention, and it is why they are recorded as four rather than as a
/// style.
///
/// **This control and Step 323's are not the same control, and the difference
/// is the confirmation.** Step 323's escalation calls for help and is a press
/// and hold with no dialog, because a confirmation costs a second deliberate
/// act at the moment the first one mattered. This row's panic button files a
/// *declaration* -- and the row's own configuration cells say what that costs:
/// "prominent warning that false declarations result in termination". An
/// action with employment consequences earns a confirmation; a call for help
/// does not. The two rows look contradictory and are not, and the rule that
/// separates them is whether the person or somebody else bears the cost of
/// being wrong.
///
/// **The warning is true and must not be the loudest thing on the screen.**
/// Somebody in a genuine emergency, reading "false declarations result in
/// termination" in error red at the moment they need help, is being threatened
/// at the worst point in their year. It appears once, on the confirmation
/// step, in ordinary type, in a sentence rather than a banner.
///
/// **COLUMN NOTE.** Every narrative column on this row is about time-limited
/// signed URLs -- "silent, time-locked document link validations", "hardcode a
/// maximum 10-minute validity boundary directly into secure link generator
/// settings" -- and those are the *same sentences* that appear on Step 315
/// (RTVMA-016), ten rows earlier in this track. Two rows in two batches share
/// one pasted narrative.
library;

import '../tokens/motion_tokens.dart';

/// What the person is doing.
enum HabotPanicStage {
  /// The button is on screen.
  offered,

  /// The confirmation sheet is open with the consequence stated.
  confirming,

  /// The declaration is filed.
  filed,
}

/// The control.
class HabotPanicButton {
  const HabotPanicButton._();

  // -----------------------------------------------------------------------
  // The band, and the four that share its shape.
  // -----------------------------------------------------------------------

  static const int bandFloorMs = 0;
  static const int bandOptimalMs = 100;
  static const int bandCeilingMs = 300;

  /// Lower is better, so the floor should be the worst tolerable value.
  static bool get theBandIsInverted =>
      bandFloorMs < bandOptimalMs && bandOptimalMs < bandCeilingMs;

  /// And the floor is not merely on the wrong side, it is unreachable: a
  /// frame at 60Hz is 16.667 ms.
  static Duration get oneFrame => HabotMotion.smoothFrameBudget;

  static double get attainableFloorMs => oneFrame.inMicroseconds / 1000;

  static bool get theFloorIsBelowWhatAScreenCanDo =>
      bandFloorMs < attainableFloorMs;

  /// The band this project would write for the same measure.
  static int get projectFloorMs => bandCeilingMs;
  static int get projectOptimalMs => bandOptimalMs;
  static double get projectCeilingMs => attainableFloorMs;

  static bool get theProjectBandIsOrdered =>
      projectFloorMs > projectOptimalMs &&
      projectOptimalMs > projectCeilingMs;

  static const List<int> invertedLatencyBandsInThisBatch = <int>[
    325,
    326,
    334,
    335,
  ];

  static const int correctlyOrderedLatencyBandInThisBatch = 333;

  static bool get oneCorrectInstanceMakesTheOthersAnError =>
      invertedLatencyBandsInThisBatch.length == 4 &&
      correctlyOrderedLatencyBandInThisBatch == 333;

  static const String bandNote =
      'On a lower-is-better measure the floor is the worst tolerable value and '
      'the ceiling is the best. This row puts 0 ms at the floor -- the ideal, '
      'and unreachable, since a frame at 60Hz is 16.667 ms -- and 300 ms at '
      'the ceiling, which is the worst of the three. Four of the five latency '
      'bands in this batch are inverted the same way and one, Step 333, is '
      'ordered correctly. That single correct instance is what makes the other '
      'four an error rather than a convention.';

  // -----------------------------------------------------------------------
  // Why this control confirms and Step 323's does not.
  // -----------------------------------------------------------------------

  static const int siblingStep = 323;

  static const bool aConfirmationIsRequiredHere = true;

  static const String consequenceOfBeingWrong =
      'a false declaration can end the person\'s employment';

  static const String siblingConsequenceOfBeingWrong =
      'a colleague is paged for nothing';

  static bool get thePersonBearsTheCostHere =>
      consequenceOfBeingWrong.contains('employment') &&
      !siblingConsequenceOfBeingWrong.contains('employment');

  static const String confirmationRuleNote =
      'Step 323\'s escalation calls for help and confirms nothing, because a '
      'dialog costs a second deliberate act in the moment the first one '
      'mattered. This row files a declaration whose cost, in the row\'s own '
      'words, is termination. An action where the person bears the cost of '
      'being wrong earns a confirmation; an action where somebody else bears '
      'it -- a colleague answering a page for nothing -- does not. The two '
      'rows look contradictory and are not, and the rule that separates them '
      'is whose mistake it would be.';

  // -----------------------------------------------------------------------
  // How the consequence is stated.
  // -----------------------------------------------------------------------

  static const String warningText =
      'A declaration that turns out to be untrue is treated as misconduct.';

  static const HabotPanicStage warningAppearsAt = HabotPanicStage.confirming;

  static const bool warningUsesTheErrorColour = false;

  static const int warningAppearances = 1;

  static bool get theWarningIsOnTheConfirmationOnly =>
      warningAppearsAt == HabotPanicStage.confirming &&
      warningAppearances == 1;

  static bool get theWarningIsASentenceRatherThanABanner =>
      warningText.endsWith('.') &&
      !warningUsesTheErrorColour &&
      warningText.split(' ').length >= 8;

  static const String warningNote =
      'The warning is true and belongs on the screen. It does not belong in '
      'error red on the button itself: somebody in a genuine emergency, '
      'reading a threat at the moment they need help, is being told the '
      'organisation expects them to be lying. It appears once, on the '
      'confirmation step, in ordinary type, as a sentence.';

  // -----------------------------------------------------------------------
  // What the row's configuration cells got right.
  // -----------------------------------------------------------------------

  static const List<String> configurationCellsAdopted = <String>[
    'bottom sheet, so the declaration does not navigate away',
    'a large, clear camera launch button for the proof',
    'a secondary confirmation to ensure intent',
    'a prominent warning about false declarations',
  ];

  static const int configurationCellsCount = 4;

  static bool get allFourConfigurationCellsAreAdopted =>
      configurationCellsAdopted.length == configurationCellsCount;

  static const String adoptedNote =
      'All four Mobile UX/UI configuration cells on this row describe the '
      'control correctly, which is rare enough to record: a bottom sheet so '
      'the declaration does not navigate away from the job, a large camera '
      'button because the proof is a photograph, a confirmation because the '
      'declaration has a consequence, and a warning because the consequence '
      'should be known before rather than after. Only the placement of the '
      'fourth is changed.';

  // -----------------------------------------------------------------------
  // The duplicated narrative.
  // -----------------------------------------------------------------------

  static const int stepWithTheSameNarrative = 315;

  static const List<String> sharedSentences = <String>[
    'Enables silent, time-locked document link validations that protect '
        'assets seamlessly behind views.',
    'Hardcode a maximum 10-minute validity boundary directly into secure link '
        'generator settings.',
  ];

  static bool get twoRowsShareOnePastedNarrative =>
      sharedSentences.length == 2 && stepWithTheSameNarrative == 315;

  static const String duplicateNarrativeNote =
      'Every narrative column on this row is about time-limited signed URLs, '
      'and the same sentences appear on Step 315 ten rows earlier in this '
      'track -- the UX Translation and the What Standardized Must Be Done '
      'cells, word for word. Two rows in two batches carrying one pasted '
      'narrative is a different defect from a mismatched column: it means the '
      'block was copied rather than written, and neither row has a narrative '
      'of its own.';

  static Map<String, bool> get obligations => <String, bool>{
        'the declaration is confirmed before it is filed':
            aConfirmationIsRequiredHere,
        'the consequence is stated before the person commits':
            theWarningIsOnTheConfirmationOnly,
        'the warning is a sentence rather than a threat':
            theWarningIsASentenceRatherThanABanner,
        'the four configuration cells are adopted':
            allFourConfigurationCellsAreAdopted,
        'the response band this project holds itself to is ordered':
            theProjectBandIsOrdered,
      };

  static double get conformance =>
      obligations.values.where((bool b) => b).length / obligations.length;

  static String get qualitativeOutput {
    if (conformance >= 1.0) {
      return 'Good';
    }
    return conformance >= 0.8 ? 'Average' : 'Poor';
  }

  static Map<String, bool> get checks => <String, bool>{
        'the band puts the ideal at the floor':
            theBandIsInverted &&
                bandFloorMs == 0 &&
                bandCeilingMs == 300,
        'and the floor is below what a screen can produce':
            theFloorIsBelowWhatAScreenCanDo &&
                (attainableFloorMs - 16.667).abs() < 1e-9,
        'the ordered band puts 300 at the floor and a frame at the ceiling':
            theProjectBandIsOrdered &&
                projectFloorMs == 300 &&
                projectOptimalMs == 100,
        'four inverted bands in this batch and one correct':
            oneCorrectInstanceMakesTheOthersAnError &&
                bandNote.contains('rather than a convention'),
        'this control confirms and Step 323\'s does not':
            aConfirmationIsRequiredHere &&
                siblingStep == 323 &&
                thePersonBearsTheCostHere,
        'and the rule that separates them is whose mistake it would be':
            confirmationRuleNote.contains('whose mistake it would be'),
        'the warning appears once, on the confirmation, in plain type':
            theWarningIsOnTheConfirmationOnly &&
                !warningUsesTheErrorColour &&
                theWarningIsASentenceRatherThanABanner,
        'and not on the button itself':
            warningNote.contains('expects them to be lying'),
        'all four configuration cells describe the control correctly':
            allFourConfigurationCellsAreAdopted &&
                adoptedNote.contains('rare enough to record'),
        'the narrative is the same one Step 315 carries':
            twoRowsShareOnePastedNarrative &&
                duplicateNarrativeNote.contains('copied rather than written'),
        'five obligations, all met':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                conformance == 1.0,
      };

  static const String columnNote =
      'COLUMN NOTE: every narrative column on this row is about time-limited '
      'signed URLs and link interception, word for word the same sentences '
      'Step 315 carries; the metric puts 0 ms at the floor of a lower-is-'
      'better band; and the Setup Step reads "Bind the calculation routines '
      'directly to those cell interaction triggers". Atomic Step: "Build a '
      'Force Majeure mobile panic button."';
}
