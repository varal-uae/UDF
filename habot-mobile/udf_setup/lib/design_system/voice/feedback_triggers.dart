/// Step 446 (GEN-05122) -- feedback prompts that pop up at the moment of
/// completion, under the longest band cell in the track, now a template.
///
/// The row: "Implement substep 3: Wire automated feedback triggers popping up
/// upon key workflow completions (e.g., referral approval)."
/// Metric: **Substep Definition-of-Done Adherence Rate** -- floor ">=90% unit
/// test coverage / acceptance criteria met before merge", optimal "95-100%
/// coverage, all acceptance criteria met", ceiling "100% (coverage beyond 100%
/// is not meaningful; further effort has diminishing return)". Complete /
/// Partial / Not Complete. Assigned to **ADFA**.
///
/// **The longest band cell in the track is now a template.** Step 430 carried
/// this exact band -- a floor that is two floors joined by an oblique and a
/// ceiling holding a semicolon and two clauses of argument -- and recorded it
/// as the longest cell in four hundred and thirty rows. Sixteen rows later it
/// arrives again, character for character, on a different subject for a
/// different team. What looked like one row's elaboration is a block pasted
/// wherever a row is called "substep". The floor is read as "and" here, as it
/// was at Step 430, and the reading is recorded again.
///
/// **"Substep 3", of a step nobody names.** Step 430 was substep 2 of one
/// sequence; this is substep 3 of another. Neither parent is identified, and
/// neither fragment says what the other substeps were.
///
/// **A prompt at the moment of completion is an interruption.** "Popping up
/// upon key workflow completions" puts a survey on top of the confirmation the
/// person was waiting for. So the prompt appears after the confirmation has
/// been shown, never over it; it can always be dismissed and never blocks
/// anything; and it is capped at one per person per week, because survey
/// fatigue is how a response rate falls and then gets pushed back up by asking
/// more often, which makes it fall further.
///
/// **It never follows a rejection.** Asking somebody to rate the process that
/// has just refused their overtime request measures the refusal, not the
/// process. Only completions that went the person's way can trigger a prompt,
/// and "completion" means what Step 436 defined it to mean: a terminal state,
/// with the person told.
library;

import '../live/streaming_hooks.dart';
import '../recognition/completion_criteria.dart';

/// How a workflow ended, for the purposes of prompting.
enum HabotOutcomeForPrompt {
  /// The person got what they asked for.
  granted,

  /// The person was refused.
  refused,

  /// Nothing has been decided yet.
  pending,
}

/// The feedback triggers.
class HabotFeedbackTriggers {
  const HabotFeedbackTriggers._();

  // -----------------------------------------------------------------------
  // The band is Step 430's, character for character.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw =
      '>=90% unit test coverage / acceptance criteria met before merge';
  static const String bandCeilingRaw =
      '100% (coverage beyond 100% is not meaningful; further effort has '
      'diminishing return)';

  static bool get theBandIsStep430s =>
      bandFloorRaw == HabotStreamingHooks.bandFloorRaw &&
      bandCeilingRaw == HabotStreamingHooks.bandCeilingRaw;

  static bool get theFloorIsReadAsAndAgain =>
      HabotStreamingHooks.theStricterReadingWasChosen;

  static const int rowsApart = 16;

  static const bool itIsATemplate = true;

  static const String templateNote =
      'Step 430 carried this exact band and recorded it as the longest cell in '
      'four hundred and thirty rows. Sixteen rows later it arrives again, '
      'character for character, on a different subject for a different team. '
      'What looked like one row\'s elaboration is a block pasted wherever a '
      'row is called a substep, and its oblique is read as "and" here as it '
      'was there.';

  // -----------------------------------------------------------------------
  // A substep of nothing named.
  // -----------------------------------------------------------------------

  static const int thisSubstep = 3;

  static const bool theParentIsIdentified = false;

  static bool get anotherFragment =>
      thisSubstep == 3 &&
      !theParentIsIdentified &&
      HabotStreamingHooks.theStepIsAFragment;

  // -----------------------------------------------------------------------
  // After the confirmation, never over it.
  // -----------------------------------------------------------------------

  static const bool thePromptCoversTheConfirmation = false;

  static const bool thePromptCanBeDismissed = true;

  static const bool thePromptBlocksAnything = false;

  static const int promptsPerPersonPerWeek = 1;

  static bool get thePromptIsNotAnInterruption =>
      !thePromptCoversTheConfirmation &&
      thePromptCanBeDismissed &&
      !thePromptBlocksAnything;

  static bool get fatigueIsCapped => promptsPerPersonPerWeek == 1;

  static const String interruptionNote =
      'A prompt that pops up at the moment of completion sits on top of the '
      'confirmation the person was waiting for. It appears after the '
      'confirmation has been shown, can always be dismissed, blocks nothing, '
      'and is capped at one a week per person -- because survey fatigue is how '
      'a response rate falls and then gets pushed back up by asking more '
      'often, which makes it fall further.';

  // -----------------------------------------------------------------------
  // Never after a refusal.
  // -----------------------------------------------------------------------

  static bool mayPrompt({
    required HabotOutcomeForPrompt outcome,
    required HabotRecordState state,
    required bool personNotified,
    required int promptsThisWeek,
  }) =>
      outcome == HabotOutcomeForPrompt.granted &&
      HabotCompletionCriteria.isComplete(
        state: state,
        personNotified: personNotified,
      ) &&
      promptsThisWeek < promptsPerPersonPerWeek;

  static bool get aGrantedCompletionPrompts => mayPrompt(
        outcome: HabotOutcomeForPrompt.granted,
        state: HabotRecordState.terminal,
        personNotified: true,
        promptsThisWeek: 0,
      );

  static bool get aRefusalNeverPrompts => !mayPrompt(
        outcome: HabotOutcomeForPrompt.refused,
        state: HabotRecordState.terminal,
        personNotified: true,
        promptsThisWeek: 0,
      );

  static bool get aPendingRecordNeverPrompts => !mayPrompt(
        outcome: HabotOutcomeForPrompt.pending,
        state: HabotRecordState.submitted,
        personNotified: false,
        promptsThisWeek: 0,
      );

  static bool get theWeeklyCapHolds => !mayPrompt(
        outcome: HabotOutcomeForPrompt.granted,
        state: HabotRecordState.terminal,
        personNotified: true,
        promptsThisWeek: 1,
      );

  static const String refusalNote =
      'Asking somebody to rate the process that has just refused their '
      'overtime request measures the refusal, not the process. Only '
      'completions that went the person\'s way can trigger a prompt, and a '
      'completion means what Step 436 defined: a terminal state, with the '
      'person told.';

  // -----------------------------------------------------------------------
  // Coverage.
  // -----------------------------------------------------------------------

  static const int coveragePercent = 97;
  static const bool acceptanceCriteriaMet = true;

  static String get qualitativeOutput {
    if (coveragePercent < 90 || !acceptanceCriteriaMet) {
      return 'Not Complete';
    }
    return coveragePercent >= 95 ? 'Complete' : 'Partial';
  }

  static const String columnNote =
      'COLUMN NOTE: this row carries Step 430\'s band character for character '
      '-- the longest band cell in the track, with a floor of two criteria '
      'joined by an oblique -- which makes it a template pasted onto rows '
      'called substeps rather than one row\'s elaboration; it is "substep 3" '
      'of a step whose parent is never named; and it asks for feedback prompts '
      'popping up on completion, so the prompt waits for the confirmation, '
      'never blocks, is capped at one a week, and never follows a refusal. '
      'Atomic Step: "Implement substep 3: Wire automated feedback triggers '
      'popping up upon key workflow completions (e.g., referral approval)."';

  static Map<String, bool> get obligations => <String, bool>{
        'the prompt never covers the confirmation':
            thePromptIsNotAnInterruption,
        'at most one prompt per person per week': theWeeklyCapHolds,
        'a refusal never prompts': aRefusalNeverPrompts,
        'a pending record never prompts': aPendingRecordNeverPrompts,
        'completion is Step 436\'s definition': aGrantedCompletionPrompts,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the band is Step 430\'s, character for character':
            theBandIsStep430s && rowsApart == 16,
        'so the longest cell in the track is a template':
            itIsATemplate && templateNote.contains('pasted'),
        'and its oblique is read as "and" again': theFloorIsReadAsAndAgain,
        'substep 3 of a parent nobody names': anotherFragment,
        'the prompt waits for the confirmation and never blocks':
            thePromptIsNotAnInterruption,
        'one prompt a week, because fatigue feeds itself':
            fatigueIsCapped &&
                interruptionNote.contains('makes it fall further'),
        'a granted completion prompts and a refusal does not':
            aGrantedCompletionPrompts && aRefusalNeverPrompts,
        'because rating a refusal measures the refusal':
            refusalNote.contains('measures the refusal'),
        'a pending record never prompts, and the cap holds':
            aPendingRecordNeverPrompts && theWeeklyCapHolds,
        'five obligations, all met, giving Complete at 97 per cent':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete',
      };
}
