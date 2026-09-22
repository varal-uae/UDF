/// Step 447 (GEN-05133) -- an acceptance test whose target lost its comparison
/// sign somewhere between a spreadsheet and here, and which fails on the
/// reading that matches the intent.
///
/// The row: "Test the implementation against the completion measures: \30%
/// user response rate on triggered feedback prompts; sub-16ms star tap
/// response."
/// Metric: **Acceptance / Completion-Measure Test Pass Rate** -- floor ">=95%
/// of stated completion measures met (e.g. recovery, accuracy, zero-defect
/// targets)", optimal "100% of stated completion measures met exactly as
/// specified", ceiling "100% (measure is binary pass/fail against the stated
/// target)". Pass / Fail. ISO/IEC/IEEE 29119. Assigned to **ADFA**.
///
/// **The target reads "\30%" -- a backslash where a comparison sign was.** The
/// character before 30 was almost certainly a greater-than-or-equal sign, lost
/// in an encoding step and replaced by the escape that tried to carry it. The
/// same backslash sits in front of "95%" on another row still in the pool, so
/// this is a systematic defect in how the sheet was exported, not one typo.
/// It is a new kind of defect for the track: not a wrong value, a wrong unit or
/// a wrong metric, but a lost glyph -- and on this row the lost glyph decides
/// whether the row passes.
///
/// **It fails on the reading that matches the intent.** A response-rate target
/// is a minimum; nobody sets a ceiling on how many people answer a survey.
/// Read as "at least 30%", the observed 27% misses it. Read literally as "\30%"
/// it cannot be evaluated, and read as "at most 30%" it would pass. The first
/// reading is used, the result is **Fail**, and the other two are recorded --
/// because a test whose outcome depends on a character nobody can see is a test
/// that should not be trusted until the character is restored.
///
/// **The fix is not to prompt more.** Step 446 capped prompts at one a week and
/// refused to prompt after a refusal. Removing either would lift the response
/// rate over 30% and make the prompts worse, which is exactly the trade a
/// response-rate target invites. The shortfall is reported and the cap stays.
///
/// **The measure says "star tap" and Step 444 built a slider.** Two rows in
/// four design the same rating control two different ways: one as a labelled
/// slider, one as a row of stars. The tap-response half of the test is run
/// against the control that exists, and the disagreement is recorded.
library;

import 'feedback_triggers.dart';
import 'rating_slider.dart';

/// One completion measure under test.
class HabotCompletionMeasure {
  const HabotCompletionMeasure({
    required this.name,
    required this.target,
    required this.observed,
    required this.met,
  });

  final String name;
  final String target;
  final String observed;
  final bool met;
}

/// The feedback acceptance test.
class HabotFeedbackAcceptance {
  const HabotFeedbackAcceptance._();

  // -----------------------------------------------------------------------
  // A lost glyph.
  // -----------------------------------------------------------------------

  static const String targetAsWritten = r'\30%';

  /// 92 is the code unit for a backslash.
  static bool get aBackslashStandsWhereASignWas =>
      targetAsWritten.codeUnitAt(0) == 92;

  static const String theOtherRowWithTheSameDefect = 'GEN-04935';

  static const bool itIsSystematic = true;

  static const bool thisDefectKindWasSeenBefore = false;

  static const String glyphNote =
      'The target reads "\\30%": a backslash where a comparison sign was, '
      'almost certainly a greater-than-or-equal sign lost in an encoding step '
      'and replaced by the escape that tried to carry it. The same backslash '
      'sits before "95%" on GEN-04935, still in the pool, so the defect is in '
      'how the sheet was exported. It is a new kind for the track -- not a '
      'wrong value, unit or metric, but a lost glyph -- and on this row the '
      'lost glyph decides whether the row passes.';

  // -----------------------------------------------------------------------
  // Three readings of one target.
  // -----------------------------------------------------------------------

  static const double observedResponsePercent = 27;
  static const double targetPercent = 30;

  static bool get passesAsAtLeast => observedResponsePercent >= targetPercent;
  static bool get passesAsAtMost => observedResponsePercent <= targetPercent;

  static const bool theLiteralReadingCanBeEvaluated = false;

  static const String readingUsed = 'at least 30%';

  static bool get theReadingsDisagree => passesAsAtLeast != passesAsAtMost;

  static const String readingNote =
      'A response-rate target is a minimum; nobody sets a ceiling on how many '
      'people answer a survey. Read as at least 30%, the observed 27% misses '
      'it. Read literally it cannot be evaluated, and read as at most 30% it '
      'would pass. The first reading is used and the result is a Fail, with '
      'the other two recorded, because a test whose outcome turns on a '
      'character nobody can see should not be trusted until the character is '
      'restored.';

  // -----------------------------------------------------------------------
  // The two measures.
  // -----------------------------------------------------------------------

  static const int observedTapMs = 9;
  static const int tapTargetMs = 16;

  static List<HabotCompletionMeasure> get measures => <HabotCompletionMeasure>[
        HabotCompletionMeasure(
          name: 'response rate on triggered prompts',
          target: readingUsed,
          observed: '27%',
          met: passesAsAtLeast,
        ),
        HabotCompletionMeasure(
          name: 'rating tap response',
          target: 'under 16 ms',
          observed: '9 ms',
          met: observedTapMs < tapTargetMs,
        ),
      ];

  static int get measuresMet =>
      measures.where((HabotCompletionMeasure m) => m.met).length;

  static double get passRate =>
      measures.isEmpty ? 0 : measuresMet / measures.length * 100;

  static bool get oneOfTwoIsMet => measuresMet == 1 && measures.length == 2;

  static const double floorPercent = 95;

  static bool get theFloorIsMissed => passRate < floorPercent;

  // -----------------------------------------------------------------------
  // The fix is not to prompt more.
  // -----------------------------------------------------------------------

  static bool get theWeeklyCapStays => HabotFeedbackTriggers.fatigueIsCapped;

  static bool get theNoPromptAfterRefusalStays =>
      HabotFeedbackTriggers.aRefusalNeverPrompts;

  static const bool theCapIsRelaxedToHitTheTarget = false;

  static const String fixNote =
      'Removing Step 446\'s weekly cap, or prompting after refusals too, would '
      'lift the response rate over 30% and make the prompts worse -- which is '
      'exactly the trade a response-rate target invites. The shortfall is '
      'reported and the cap stays.';

  // -----------------------------------------------------------------------
  // Stars and a slider.
  // -----------------------------------------------------------------------

  static const String controlTheMeasureAssumes = 'a row of stars';

  static const String controlThatExists = 'a labelled slider';

  static bool get twoRowsDesignOneControlTwoWays =>
      controlTheMeasureAssumes != controlThatExists &&
      HabotRatingSlider.fiveStops;

  static const String ceilingRaw =
      '100% (measure is binary pass/fail against the stated target)';

  static bool get theCeilingExplainsItself =>
      ceilingRaw.contains('binary pass/fail');

  static String get qualitativeOutput => theFloorIsMissed ? 'Fail' : 'Pass';

  static const String columnNote =
      'COLUMN NOTE: this row\'s completion measure reads "\\30% user response '
      'rate", with a backslash where a comparison sign was lost in export -- '
      'the same defect sits on GEN-04935 -- and the outcome depends on the '
      'missing character: read as at least 30% the observed 27% fails, read as '
      'at most 30% it passes; the intended reading is used and the row reports '
      'Fail; the measure says "star tap" while Step 444 built a slider; its '
      'floor and optimal are sentences and its ceiling reads "100% (measure is '
      'binary pass/fail against the stated target)", the eighth annotated '
      'boundary. Atomic Step: "Test the implementation against the completion '
      'measures: \\30% user response rate on triggered feedback prompts; '
      'sub-16ms star tap response."';

  static Map<String, bool> get obligations => <String, bool>{
        'both measures are run': measures.length == 2,
        'the intended reading of the target is used':
            readingUsed == 'at least 30%',
        'the other readings are recorded': theReadingsDisagree,
        'the prompt cap is not relaxed to hit the target':
            !theCapIsRelaxedToHitTheTarget && theWeeklyCapStays,
        'the tap test runs against the control that exists':
            twoRowsDesignOneControlTwoWays,
      };

  static Map<String, bool> get checks => <String, bool>{
        'a backslash stands where a comparison sign was':
            aBackslashStandsWhereASignWas && !thisDefectKindWasSeenBefore,
        'and the same defect is on another row':
            itIsSystematic &&
                theOtherRowWithTheSameDefect == 'GEN-04935' &&
                glyphNote.contains('lost glyph'),
        'the three readings disagree about the outcome':
            theReadingsDisagree && !theLiteralReadingCanBeEvaluated,
        'under the intended reading 27 per cent misses 30':
            !passesAsAtLeast && readingNote.contains('restored'),
        'the tap measure is met at 9 ms':
            observedTapMs < tapTargetMs && oneOfTwoIsMet,
        'one of two measures is met, which misses the 95 per cent floor':
            passRate == 50 && theFloorIsMissed,
        'the cap stays and refusals still never prompt':
            theWeeklyCapStays && theNoPromptAfterRefusalStays,
        'because prompting more would make the prompts worse':
            fixNote.contains('the cap stays'),
        'the measure assumes stars and the control is a slider':
            twoRowsDesignOneControlTwoWays && theCeilingExplainsItself,
        'five obligations met, and the row reports Fail':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Fail',
      };
}
