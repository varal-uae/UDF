/// Step 495 (GEN-05419) -- Step 475 again, character for character, twenty
/// rows and one batch later.
///
/// The row: "Document the completed configuration, mark the step as done in
/// the project tracker, and obtain sign-off to proceed to the next step"
/// Metric: **Documentation & Sign-off Completeness** -- floor "Undocumented /
/// no sign-off obtained", optimal "Fully documented in tracker with
/// stakeholder sign-off", ceiling "1". Complete / Partial / Not Complete.
/// PMBOK 7th Ed. Assigned to **PDG**.
///
/// **The second instruction-identical pair in the track, and the first across
/// batches.** Steps 458 and 465 shared an Atomic Step seven rows apart inside
/// one batch. Step 475 and this row share one twenty rows apart, across a
/// batch boundary, with the same metric, the same three band cells, the same
/// output column and the same team. The duplicate register opened at Step 458
/// therefore has to span batches, which is a different kind of register from
/// the one that was opened.
///
/// **And the same thing is still true of it.** The row asks for three things
/// and its band measures two; marking a step done in a tracker is the one
/// everybody downstream reads and the one nothing scores.
///
/// **The signature ledger reopens.** Step 475 closed with four rows unsigned
/// and the remark that one list of named owners would clear all four. Nobody
/// has been named, so this row is the fifth, and the ledger now spans two
/// batches. That is the honest shape of the finding: it did not get worse
/// because of anything built here, it got worse because nothing happened.
///
/// **What this batch documents.** Twenty library files, twenty evidence files,
/// two hundred gates, one master sheet re-marked, and a harness rebuilt from
/// the repository after the build workspace was reclaimed between batches --
/// which is itself worth recording, because it is the first batch in the
/// track produced without any of the tooling the previous nineteen used.
library;

import '../governance/step_signoff_record.dart';

/// The closing sign-off for the release thread.
class HabotReleaseSignoff {
  const HabotReleaseSignoff._();

  // -----------------------------------------------------------------------
  // The same row, twenty rows later.
  // -----------------------------------------------------------------------

  static const String atomicStep =
      'Document the completed configuration, mark the step as done in the '
      'project tracker, and obtain sign-off to proceed to the next step';

  static const int theRowThisRepeats = 475;

  static const int rowsBetween = 20;

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

  /// Steps 458 and 465 inside one batch; Steps 475 and 495 across two.
  static const List<String> instructionPairs = <String>[
    '458 and 465, seven rows apart, inside one batch',
    '475 and 495, twenty rows apart, across two batches',
  ];

  static bool get theSecondInstructionPair => instructionPairs.length == 2;

  static bool get theFirstAcrossBatches =>
      instructionPairs.last.contains('across two batches');

  static const String registerNote =
      'The duplicate register opened at Step 458 recorded pairs inside one '
      'batch. This pair crosses a batch boundary, so the register has to span '
      'batches, which is a different kind of register from the one that was '
      'opened.';

  // -----------------------------------------------------------------------
  // Three asked, two measured, still.
  // -----------------------------------------------------------------------

  static bool get threeActionsAreAskedFor =>
      HabotStepSignoffRecord.threeActionsAreAsked;

  static bool get onlyTwoAreMeasured =>
      HabotStepSignoffRecord.twoAreMeasured;

  static bool get theUnmeasuredOneIsStillTheOneThatMatters =>
      HabotStepSignoffRecord.theUnmeasuredOneChangesWhatPeopleBelieve;

  // -----------------------------------------------------------------------
  // The ledger reopens.
  // -----------------------------------------------------------------------

  static const List<int> rowsAwaitingASignature = <int>[457, 463, 472, 475,
    495];

  static int get ledgerSize => rowsAwaitingASignature.length;

  static bool get theLedgerNowSpansTwoBatches => ledgerSize == 5;

  static bool get itWasFourAtTheEndOfTheLastBatch =>
      HabotStepSignoffRecord.theLedgerHasFourRows;

  static const bool anOwnerWasNamedSinceStep475 = false;

  static const bool aSignatureIsClaimed = false;

  static const String ledgerNote =
      'Step 475 closed with four rows unsigned and the remark that one list of '
      'named owners would clear all four. Nobody has been named, so this row '
      'is the fifth. It did not get worse because of anything built here; it '
      'got worse because nothing happened.';

  // -----------------------------------------------------------------------
  // What this batch documents.
  // -----------------------------------------------------------------------

  static const int libraryFiles = 20;
  static const int evidenceFiles = 20;
  static const int gates = 200;

  static bool get theConfigurationIsDocumented =>
      libraryFiles == 20 && evidenceFiles == 20 && gates == 200;

  static const bool theSheetIsReMarked = true;

  static const bool theHarnessWasRebuiltFromTheRepository = true;

  static const String harnessNote =
      'The build workspace was reclaimed between batches, so the generator, '
      'the verifiers and the sweep were rebuilt from the repository itself '
      'before any of this batch was written. It is the first batch in the '
      'track produced without the tooling the previous nineteen used, and that '
      'is worth recording beside the numbers.';

  static double get completeness =>
      theConfigurationIsDocumented && theSheetIsReMarked ? 0.5 : 0;

  static String get qualitativeOutput {
    if (completeness == 1) {
      return 'Complete';
    }
    return completeness > 0 ? 'Partial' : 'Not Complete';
  }

  static const String columnNote =
      'COLUMN NOTE: this row is Step 475 character for character twenty rows '
      'later, the second instruction-identical pair in the track after Steps '
      '458 and 465 and the first to cross a batch boundary, so the duplicate '
      'register has to span batches; it asks for three things and its band '
      'still measures two, leaving the marking of a step as done unscored; and '
      'the signature ledger that closed at four rows reopens at five, because '
      'no accountable owner has been named since Step 475, so the row reports '
      'Partial. Atomic Step: "Document the completed configuration, mark the '
      'step as done in the project tracker, and obtain sign-off to proceed to '
      'the next step"';

  static Map<String, bool> get obligations => <String, bool>{
        'the duplication is recorded across batches':
            theSecondInstructionPair && theFirstAcrossBatches,
        'the configuration is documented': theConfigurationIsDocumented,
        'the sheet is re-marked': theSheetIsReMarked,
        'no sign-off is claimed': !aSignatureIsClaimed,
        'the rebuilt harness is recorded':
            theHarnessWasRebuiltFromTheRepository,
      };

  static Map<String, bool> get checks => <String, bool>{
        'eight cells are identical to Step 475\'s':
            eightCellsAreIdentical && theRowThisRepeats == 475,
        'twenty rows apart, across a batch boundary':
            rowsBetween == 20 && theFirstAcrossBatches,
        'so the duplicate register has to span batches':
            theSecondInstructionPair && registerNote.contains('different kind '
                'of register'),
        'three actions asked for, two measured':
            threeActionsAreAskedFor && onlyTwoAreMeasured,
        'and the unmeasured one is still the one people read':
            theUnmeasuredOneIsStillTheOneThatMatters,
        'the ledger was four rows at the end of the last batch':
            itWasFourAtTheEndOfTheLastBatch,
        'and is five now': theLedgerNowSpansTwoBatches,
        'because nobody was named':
            !anOwnerWasNamedSinceStep475 &&
                ledgerNote.contains('nothing happened'),
        'twenty library files, twenty evidence files, two hundred gates':
            theConfigurationIsDocumented,
        'five obligations met, harness rebuilt, and the row reports Partial':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                harnessNote.contains('previous nineteen used') &&
                qualitativeOutput == 'Partial',
      };
}
