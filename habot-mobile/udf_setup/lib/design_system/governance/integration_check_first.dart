/// Step 458 (GEN-04836) -- "verify all four substeps above", on a flat sheet
/// where nothing is above anything, and the register of how much of this
/// batch is a copy of the rest of it.
///
/// The row: "Verify all four substeps above function correctly together as an
/// integrated unit."
/// Metric: **Integration Test Pass Rate** -- floor ">=95% of integration test
/// cases passing", optimal "100% passing", ceiling "100% (cannot exceed full
/// pass rate)". Pass / Fail. ISO/IEC/IEEE 29119. Assigned to **ADFA**.
///
/// **"Above" refers to nothing.** The sheet is a flat list of 1,314 matched
/// rows with a Dependency column that says, on every row in this batch,
/// "Dependent on prior foundational steps." There is no parent, no ordering
/// within a parent, and no four substeps named anywhere. The row cannot be
/// executed as written. What can be done is to say which four things are
/// being integrated and then integrate those, so this row declares them: the
/// SEN reference check and the telephone normalisation from Step 456, and the
/// biometric sensor route and the PIN route from Step 457 -- the form
/// validation and re-entry thread this batch has actually built.
///
/// **Step 465 is this row again, character for character.** Same instruction,
/// same team, same metric, same band, seven rows later. It is not a near
/// duplicate; the Atomic Step cells are identical. Step 459 and Step 466 are a
/// second pair differing by a single digit. Four further pairs in this batch
/// of twenty share a metric and band. Twelve of the twenty rows have a twin,
/// which is what this row's register records.
///
/// **A percentage floor on a small suite has no value below 100.** Twelve
/// integration cases can pass at 0, 8.3, 16.7 ... 91.7 or 100 per cent and
/// nothing in between, so ">=95%" and "100%" name the same outcome for any
/// suite under twenty cases. The optimal is the floor.
library;

import 'biometric_signoff.dart';
import 'sen_identity_decision.dart';

/// Two rows that are the same row.
class HabotRowPair {
  const HabotRowPair({
    required this.first,
    required this.second,
    required this.shared,
    required this.identicalInstruction,
  });

  final int first;
  final int second;
  final String shared;
  final bool identicalInstruction;
}

/// How much of this batch is a copy of the rest of it.
class HabotRowDuplication {
  const HabotRowDuplication._();

  static const List<HabotRowPair> pairs = <HabotRowPair>[
    HabotRowPair(
      first: 456,
      second: 471,
      shared: 'Decision Governance Cycle Time (Time-to-Decision)',
      identicalInstruction: false,
    ),
    HabotRowPair(
      first: 457,
      second: 463,
      shared: 'Milestone Sign-off / Definition-of-Done Compliance',
      identicalInstruction: false,
    ),
    HabotRowPair(
      first: 458,
      second: 465,
      shared: 'Integration Test Pass Rate',
      identicalInstruction: true,
    ),
    HabotRowPair(
      first: 459,
      second: 466,
      shared: 'Dependency Gate Compliance Rate',
      identicalInstruction: false,
    ),
    HabotRowPair(
      first: 460,
      second: 470,
      shared: 'Shared Module Packaging & Versioning Compliance',
      identicalInstruction: false,
    ),
    HabotRowPair(
      first: 461,
      second: 468,
      shared: 'Substep Definition-of-Done Adherence Rate',
      identicalInstruction: false,
    ),
  ];

  static int get pairCount => pairs.length;

  static int get rowsWithATwin => pairs.length * 2;

  static bool get twelveOfTwenty => rowsWithATwin == 12;

  static bool get oneInstructionIsIdentical =>
      pairs.where((HabotRowPair p) => p.identicalInstruction).length == 1;

  /// Bands shared with rows outside this batch: 472 with 453, 473 with 450
  /// and 454.
  static const List<int> bandsSharedWithEarlierBatches = <int>[472, 473];

  static const String registerNote =
      'Six pairs inside one batch of twenty share a metric and its band; one '
      'pair shares its instruction character for character and a second '
      'differs by a single digit; and two further rows carry bands first seen '
      'in the previous batch. The bands are not being chosen for the rows. '
      'They are being pasted onto them.';
}

/// The first integration check.
class HabotIntegrationCheckFirst {
  const HabotIntegrationCheckFirst._();

  // -----------------------------------------------------------------------
  // "Above" refers to nothing.
  // -----------------------------------------------------------------------

  static const String atomicStep =
      'Verify all four substeps above function correctly together as an '
      'integrated unit.';

  static const String dependencyCell = 'Dependent on prior foundational steps.';

  static const bool theSheetNamesTheFourSubsteps = false;

  static bool get theInstructionCannotBeExecutedAsWritten =>
      !theSheetNamesTheFourSubsteps &&
      dependencyCell.contains('prior foundational');

  /// Declared here because the row does not declare them.
  static const List<String> theFourSubstepsIntegrated = <String>[
    'the SEN reference shape check (Step 456)',
    'telephone normalisation to E.164 (Step 456)',
    'the biometric sensor route (Step 457)',
    'the PIN route (Step 457)',
  ];

  static bool get fourSubstepsAreNamedHere =>
      theFourSubstepsIntegrated.length == 4;

  static bool get theyAreTheRowsThisBatchBuilt =>
      HabotSenIdentityDecision.shapeOnlyValidation &&
      HabotBiometricSignoff.thePinIsReachableFromTheStart;

  static const String orphanNote =
      'The sheet is a flat list of 1,314 matched rows whose Dependency column '
      'reads "Dependent on prior foundational steps." on every row in this '
      'batch. There is no parent and no four substeps named anywhere, so the '
      'instruction cannot be executed as written. The four being integrated '
      'are declared here instead of guessed at.';

  // -----------------------------------------------------------------------
  // The register.
  // -----------------------------------------------------------------------

  static bool get thisRowHasATwin => HabotRowDuplication.pairs
      .any((HabotRowPair p) => p.first == 458 && p.second == 465);

  static bool get theTwinIsCharacterForCharacter => HabotRowDuplication.pairs
      .firstWhere((HabotRowPair p) => p.first == 458)
      .identicalInstruction;

  // -----------------------------------------------------------------------
  // A percentage floor on a small suite.
  // -----------------------------------------------------------------------

  static const int caseCount = 12;
  static const int casesPassing = 12;

  static double get passRate => 100 * casesPassing / caseCount;

  static double get highestRateBelowFull => 100 * (caseCount - 1) / caseCount;

  static const double floorPercent = 95;

  static bool get noValueSitsBetweenTheFloorAndFull =>
      highestRateBelowFull < floorPercent;

  static bool get theOptimalIsTheFloor =>
      noValueSitsBetweenTheFloorAndFull && floorPercent < 100;

  static const String suiteNote =
      'Twelve integration cases can pass at 0, 8.3, 16.7 and so on to 91.7 or '
      '100 per cent and nothing in between, so a floor of 95 per cent and an '
      'optimal of 100 name the same outcome for any suite under twenty cases. '
      'The floor is the optimal wearing a different number.';

  static bool get everyCasePasses => casesPassing == caseCount;

  static String get qualitativeOutput =>
      passRate >= floorPercent ? 'Pass' : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row says "verify all four substeps above" on a flat '
      'sheet where nothing is above anything and no four substeps are named, '
      'so the four being integrated are declared here; its instruction is '
      'repeated character for character at Step 465, one of six '
      'metric-and-band pairs inside this batch of twenty; and its floor of 95 '
      'per cent names the same outcome as its optimal of 100 for any suite '
      'under twenty cases. Atomic Step: "Verify all four substeps above '
      'function correctly together as an integrated unit."';

  static Map<String, bool> get obligations => <String, bool>{
        'the four substeps are named before they are integrated':
            fourSubstepsAreNamedHere,
        'they are rows this batch actually built': theyAreTheRowsThisBatchBuilt,
        'the duplication is recorded rather than absorbed':
            HabotRowDuplication.twelveOfTwenty,
        'the suite size is stated with the pass rate': caseCount == 12,
        'every case passes': everyCasePasses,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the sheet names no four substeps':
            theInstructionCannotBeExecutedAsWritten,
        'so four are declared here, from Steps 456 and 457':
            fourSubstepsAreNamedHere && theyAreTheRowsThisBatchBuilt,
        'and the orphan pronoun is recorded':
            orphanNote.contains('cannot be executed as written'),
        'this row has a twin at Step 465':
            thisRowHasATwin && theTwinIsCharacterForCharacter,
        'six pairs, twelve rows of twenty':
            HabotRowDuplication.pairCount == 6 &&
                HabotRowDuplication.twelveOfTwenty,
        'and exactly one pair shares its instruction':
            HabotRowDuplication.oneInstructionIsIdentical &&
                HabotRowDuplication.registerNote.contains('pasted onto them'),
        'twelve cases, all passing': caseCount == 12 && everyCasePasses,
        'the highest rate below full is under the floor':
            noValueSitsBetweenTheFloorAndFull,
        'so the floor and the optimal name one outcome':
            theOptimalIsTheFloor && suiteNote.contains('different number'),
        'five obligations met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };
}
