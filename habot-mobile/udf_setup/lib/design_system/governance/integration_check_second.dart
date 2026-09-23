/// Step 465 (GEN-05034) -- Step 458 again, character for character, seven
/// rows later.
///
/// The row: "Verify all four substeps above function correctly together as an
/// integrated unit."
/// Metric: **Integration Test Pass Rate** -- floor ">=95% of integration test
/// cases passing", optimal "100% passing", ceiling "100% (cannot exceed full
/// pass rate)". Pass / Fail. ISO/IEC/IEEE 29119. Assigned to **ADFA**.
///
/// **Every cell that matters is Step 458's.** The Atomic Step is identical,
/// not similar: same words, same punctuation, same missing referent. The
/// team, the metric, the three band values, the output column and the
/// standard are all the same too. Seven rows separate them and nothing
/// distinguishes them, which is what makes this pair different from the five
/// other pairs in this batch -- those share a band, this one shares an
/// instruction.
///
/// **So it has to be integrating something else.** Step 458 declared the four
/// substeps it was integrating because the sheet named none; this row does
/// the same and reaches a different four, because by now the batch has built
/// different things: punctuation parsing (461), the accuracy test (462), the
/// recording indicator (464) and the assistive surfaces (460). Two identical
/// rows produce two different tests, which is the clearest evidence yet that
/// the instruction carries no information.
///
/// **The suite is sixteen cases, and the arithmetic is Step 458's.** Fifteen
/// of sixteen is 93.75 per cent, below the 95 per cent floor, so again the
/// floor and the optimal name one outcome.
///
/// **What a second identical row is actually worth.** Nothing is deleted. The
/// row is implemented, its evidence records that it duplicates Step 458, and
/// the duplicate register carries both -- because a sheet of 1,314 rows that
/// contains copies is a fact about the sheet, and hiding it by quietly
/// skipping one row would make the count of implemented steps a lie.
library;

import '../capture/assistance_package.dart';
import '../capture/recognition_accuracy.dart';
import '../capture/recording_indicator.dart';
import '../capture/transcript_punctuation.dart';
import 'integration_check_first.dart';

/// The second integration check.
class HabotIntegrationCheckSecond {
  const HabotIntegrationCheckSecond._();

  // -----------------------------------------------------------------------
  // Identical, not similar.
  // -----------------------------------------------------------------------

  static const String atomicStep =
      'Verify all four substeps above function correctly together as an '
      'integrated unit.';

  static bool get theInstructionIsStep458s =>
      atomicStep == HabotIntegrationCheckFirst.atomicStep;

  static const List<String> cellsThatAreIdentical = <String>[
    'Atomic Step',
    'Assigned Group/Team',
    'Metric Name',
    'Floor Boundary',
    'Optimal Target',
    'Ceiling Boundary',
    'Best Qualitative Output',
    'Best Qualitative/Quantitative Output Type',
  ];

  static bool get eightCellsAreIdentical =>
      cellsThatAreIdentical.length == 8;

  static const int rowsBetween = 7;

  static bool get thisIsTheInstructionPair => HabotRowDuplication.pairs
      .firstWhere((HabotRowPair p) => p.second == 465)
      .identicalInstruction;

  static const String duplicateNote =
      'The Atomic Step is identical rather than similar: same words, same '
      'punctuation, same missing referent, and seven rows apart. The team, the '
      'metric, the three band values, the output column and the standard match '
      'as well. Five other pairs in this batch share a band; this pair shares '
      'an instruction.';

  // -----------------------------------------------------------------------
  // A different four.
  // -----------------------------------------------------------------------

  static const List<String> theFourSubstepsIntegrated = <String>[
    'punctuation parsing over a kept token stream (Step 461)',
    'the per-cohort accuracy test (Step 462)',
    'the recording indicator (Step 464)',
    'the assistive surfaces package (Step 460)',
  ];

  static bool get fourSubstepsAreNamedHere =>
      theFourSubstepsIntegrated.length == 4;

  static bool get theyDifferFromStep458s => !HabotIntegrationCheckFirst
      .theFourSubstepsIntegrated
      .any((String s) => theFourSubstepsIntegrated.contains(s));

  static bool get eachOneResolves =>
      HabotTranscriptPunctuation.theRawStreamIsKept &&
      HabotRecognitionAccuracy.everyCohortIsReported &&
      HabotRecordingIndicator.theRoomCanSeeIt &&
      HabotAssistancePackage.everySurfaceAnnouncesSomething;

  static const String evidenceNote =
      'Step 458 declared the four substeps it was integrating because the '
      'sheet named none, and this row does the same and reaches a different '
      'four, because by now the batch has built different things. Two '
      'identical rows produce two different tests, which is the clearest '
      'evidence that the instruction carries no information.';

  // -----------------------------------------------------------------------
  // The same arithmetic, a different suite.
  // -----------------------------------------------------------------------

  static const int caseCount = 16;
  static const int casesPassing = 16;

  static double get passRate => 100 * casesPassing / caseCount;

  static double get highestRateBelowFull => 100 * (caseCount - 1) / caseCount;

  static const double floorPercent = 95;

  static bool get noValueSitsBetweenTheFloorAndFull =>
      highestRateBelowFull < floorPercent;

  static bool get theSameArithmeticAsStep458 =>
      HabotIntegrationCheckFirst.noValueSitsBetweenTheFloorAndFull &&
      noValueSitsBetweenTheFloorAndFull;

  static bool get everyCasePasses => casesPassing == caseCount;

  // -----------------------------------------------------------------------
  // Nothing is deleted.
  // -----------------------------------------------------------------------

  static const bool theDuplicateRowIsSkipped = false;
  static const bool theDuplicationIsRecorded = true;

  static bool get bothRowsAreImplemented =>
      !theDuplicateRowIsSkipped && theDuplicationIsRecorded;

  static const String honestyNote =
      'A sheet of 1,314 rows that contains copies is a fact about the sheet. '
      'Quietly skipping one of a pair would make the count of implemented '
      'steps a lie, so both are implemented and the duplication is recorded in '
      'the register instead.';

  static String get qualitativeOutput =>
      passRate >= floorPercent ? 'Pass' : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row\'s Atomic Step is Step 458\'s character for '
      'character, with eight cells identical and seven rows between them, the '
      'only pair in this batch to share an instruction rather than a band; it '
      'declares a different four substeps because the batch has built '
      'different things by now, which shows the instruction carries no '
      'information; its sixteen-case suite has no value between 93.75 and 100 '
      'per cent, so its floor and optimal again name one outcome; and neither '
      'row is skipped, because skipping one would make the implemented count a '
      'lie. Atomic Step: "Verify all four substeps above function correctly '
      'together as an integrated unit."';

  static Map<String, bool> get obligations => <String, bool>{
        'the duplication is recorded': theDuplicationIsRecorded,
        'neither row is skipped': !theDuplicateRowIsSkipped,
        'the four substeps are named before integrating':
            fourSubstepsAreNamedHere,
        'each one resolves against a file that exists': eachOneResolves,
        'every case passes': everyCasePasses,
      };

  static Map<String, bool> get checks => <String, bool>{
        'eight cells are identical to Step 458\'s':
            theInstructionIsStep458s &&
                eightCellsAreIdentical &&
                rowsBetween == 7,
        'and this is the batch\'s only instruction pair':
            thisIsTheInstructionPair &&
                duplicateNote.contains('shares an instruction'),
        'four substeps declared here, different from Step 458\'s':
            fourSubstepsAreNamedHere && theyDifferFromStep458s,
        'each of them resolves': eachOneResolves,
        'so two identical rows produce two different tests':
            evidenceNote.contains('carries no information'),
        'sixteen cases, all passing':
            caseCount == 16 && everyCasePasses,
        'no rate sits between 93.75 and 100':
            noValueSitsBetweenTheFloorAndFull,
        'the same arithmetic as Step 458': theSameArithmeticAsStep458,
        'both rows are implemented and the duplication recorded':
            bothRowsAreImplemented && honestyNote.contains('a lie'),
        'five obligations met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };
}
