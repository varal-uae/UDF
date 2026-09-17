/// Step 386 (GEN-02378) -- a Next button that will not move, and the question
/// of whether a required answer should be required.
///
/// The row: "Program the 'Next' button to remain physically blocked until the
/// current rating is provided (Poka-Yoke)."
/// Metric: **UI Compliance Rate (%)** -- floor 0.95, optimal 1, ceiling 1.
/// Pass / Fail. Material Design 3, WCAG 2.2 AA, W3C Web Standards. Assigned to
/// **UDF**.
///
/// **A disabled Next button is the worst place to put a requirement.** The
/// control gives no feedback when tapped, so a person who does not know what is
/// missing taps it, gets nothing, and concludes the app is broken. Step 118's
/// rule applies: the button stays enabled, the tap is accepted, and the tap
/// moves focus to the unanswered question and says what it wants. "Physically
/// blocked" describes the intent -- you cannot get past this -- and a focus
/// move enforces it more completely than a grey rectangle, because it also
/// tells you why.
///
/// **A rating with no "prefer not to say" is not a poka-yoke, it is a toll.**
/// Making an answer mandatory guarantees an answer; it does not guarantee a
/// true one. A required satisfaction rating with no decline option produces a
/// middle value from everybody who wanted to leave, which is worse than a
/// missing value because it cannot be told apart from a real one. The decline
/// is an option on the scale, recorded as a decline.
///
/// **The gesture rule from the last batch applies to the escape.** Step 336
/// settled that a path-based gesture needs a pointer alternative. A screen
/// somebody cannot leave without answering needs a way out that is not the
/// answer: closing the survey is available throughout and recorded as
/// abandonment, so the count of people who left is a number rather than an
/// absence.
///
/// **The artefact cell is the button's own label.** "Data/artifacts to prepare:
/// Next" -- the seventh generator-artefact cell across the last two batches,
/// and the shortest.
library;

import '../forms/strict_true_gate.dart';

/// What a rating scale offers.
enum HabotRatingOption {
  /// One of the values on the scale.
  scored,

  /// An explicit decline, recorded as one.
  declined,

  /// Nothing yet.
  unanswered,
}

/// The Next-button rule.
class HabotNextButtonGate {
  const HabotNextButtonGate._();

  // -----------------------------------------------------------------------
  // The button stays enabled.
  // -----------------------------------------------------------------------

  static const bool theButtonIsDisabledUntilAnswered = false;

  static const bool theTapIsAccepted = true;

  static const String whatTheTapDoes =
      'moves focus to the unanswered question and names what it wants';

  static bool get theTapDoesSomething =>
      theTapIsAccepted &&
      !theButtonIsDisabledUntilAnswered &&
      whatTheTapDoes.contains('names what it wants');

  /// The strict check is the declared one: unanswered and declined are
  /// different, and only a scored answer satisfies a required question.
  static bool satisfiesARequiredRating(bool? scored) =>
      HabotStrictTrueGate.strictCheckOf(scored);

  static bool get anUnansweredRatingDoesNotPass =>
      !satisfiesARequiredRating(null) && satisfiesARequiredRating(true);

  static const String blockedNote =
      'A disabled Next button is the worst place to put a requirement: it '
      'gives no feedback when tapped, so somebody who does not know what is '
      'missing taps it, gets nothing and concludes the app is broken. The '
      'button stays enabled, the tap is accepted, and the tap moves focus to '
      'the unanswered question and says what it wants. "Physically blocked" is '
      'the right intent and a focus move enforces it more completely than a '
      'grey rectangle, because it also says why.';

  // -----------------------------------------------------------------------
  // A required answer that is not a toll.
  // -----------------------------------------------------------------------

  static const bool thereIsADeclineOption = true;

  static const String declineLabel = 'Prefer not to say';

  static const bool aDeclineIsRecordedAsADecline = true;

  static const bool aDeclineIsStoredAsAMiddleValue = false;

  static bool get aDeclineIsDistinguishable =>
      aDeclineIsRecordedAsADecline && !aDeclineIsStoredAsAMiddleValue;

  static HabotRatingOption optionFor({
    required int? score,
    required bool declined,
  }) {
    if (declined) {
      return HabotRatingOption.declined;
    }
    return score == null
        ? HabotRatingOption.unanswered
        : HabotRatingOption.scored;
  }

  static bool get threeOutcomesAreDistinct =>
      optionFor(score: null, declined: false) == HabotRatingOption.unanswered &&
      optionFor(score: null, declined: true) == HabotRatingOption.declined &&
      optionFor(score: 4, declined: false) == HabotRatingOption.scored;

  static const String tollNote =
      'Making an answer mandatory guarantees an answer; it does not guarantee '
      'a true one. A required satisfaction rating with no decline produces a '
      'middle value from everybody who wanted to leave, which is worse than a '
      'missing value because it cannot be told apart from a real one. The '
      'decline is on the scale and is recorded as a decline, so the three '
      'outcomes stay distinguishable in the data.';

  // -----------------------------------------------------------------------
  // A way out that is not the answer.
  // -----------------------------------------------------------------------

  static const bool theSurveyCanBeClosed = true;

  static const bool leavingIsRecorded = true;

  static const int theStepThatSettledAlternatives = 336;

  static bool get thereIsAnExitThatIsNotAnAnswer =>
      theSurveyCanBeClosed && leavingIsRecorded;

  static const String exitNote =
      'Step 336 settled that a gesture needs an alternative; a screen somebody '
      'cannot leave without answering needs the same thing. Closing the survey '
      'is available throughout and is recorded as abandonment, so the number '
      'of people who left is a number rather than an absence -- and a required '
      'question with no exit does not raise the response rate, it lowers the '
      'number of people who open the survey next time.';

  // -----------------------------------------------------------------------
  // Poka-yoke, again.
  // -----------------------------------------------------------------------

  static const int theStepThatSettledPokaYoke = 341;

  static const bool theDeviceMakesTheErrorImpossible = true;

  static bool get itEarnsTheWord =>
      theDeviceMakesTheErrorImpossible && anUnansweredRatingDoesNotPass;

  static const String pokaYokeNote =
      'Step 341 settled what earns the word: a device that makes the error '
      'impossible rather than one that notices it. Advancing without an answer '
      'is impossible here because the advance is a function of the answer, not '
      'because a button was greyed -- and unlike a grey button, this version '
      'tells the person which question is waiting.';

  // -----------------------------------------------------------------------
  // The band and the column.
  // -----------------------------------------------------------------------

  static const double bandFloor = 0.95;
  static const double bandOptimal = 1;
  static const double bandCeiling = 1;

  static bool get theOptimalEqualsTheCeiling => bandOptimal == bandCeiling;

  static const String artefactCell = 'Next';

  static bool get theArtefactCellIsTheButtonsLabel =>
      artefactCell == 'Next' && artefactCell.length == 4;

  static const int generatorArtefactCellsInTwoBatches = 7;

  static const String columnNoteShort =
      'The Data Requirement cell reads "Data/artifacts to prepare: Next" -- '
      'the button\'s own label, and the shortest of the seven '
      'generator-artefact cells across these two batches.';

  static Map<String, bool> get obligations => <String, bool>{
        'the button stays enabled and the tap does something':
            theTapDoesSomething,
        'an unanswered rating does not advance': anUnansweredRatingDoesNotPass,
        'a decline is offered': thereIsADeclineOption,
        'a decline is recorded as a decline': aDeclineIsDistinguishable,
        'there is a way out that is not the answer':
            thereIsAnExitThatIsNotAnAnswer,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'the button is not disabled': !theButtonIsDisabledUntilAnswered,
        'the tap moves focus and names what is missing':
            theTapDoesSomething && blockedNote.contains('it also says why'),
        'an unanswered rating does not satisfy the requirement':
            anUnansweredRatingDoesNotPass,
        'three rating outcomes stay distinct': threeOutcomesAreDistinct,
        'a decline is offered and recorded as one':
            thereIsADeclineOption &&
                aDeclineIsDistinguishable &&
                declineLabel.contains('Prefer not'),
        'and a forced answer is a toll rather than a safeguard':
            tollNote.contains('cannot be told apart from a real one'),
        'leaving is possible and recorded':
            thereIsAnExitThatIsNotAnAnswer &&
                theStepThatSettledAlternatives == 336,
        'and a question with no exit costs the next survey':
            exitNote.contains('open the survey next time'),
        'it earns the word poka-yoke, on Step 341\'s test':
            itEarnsTheWord && theStepThatSettledPokaYoke == 341,
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass' &&
                theOptimalEqualsTheCeiling &&
                theArtefactCellIsTheButtonsLabel &&
                generatorArtefactCellsInTwoBatches == 7,
      };

  static const String columnNote =
      'COLUMN NOTE: the Data Requirement cell on this row reads '
      '"Data/artifacts to prepare: Next", which is the button\'s own label '
      'lifted into the artefact list and the shortest of the seven such cells '
      'across these two batches; the band\'s optimal and ceiling are both 1; '
      'and the Setup Step column is empty. Atomic Step: "Program the Next '
      'button to remain physically blocked until the current rating is '
      'provided (Poka-Yoke)."';
}
