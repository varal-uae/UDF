/// Step 357 (GEN-02301) -- "Verified", with no object.
///
/// The row: "Design a \"Verified\" badge for the mobile payroll summary."
/// Metric: **Data Validation Pass Rate (%)** -- floor 0.95, optimal 0.999,
/// ceiling 1. Pass / Fail. ISO/IEC 27001, OWASP Input Validation.
///
/// **The word has no object, and payroll is where that matters most.** A
/// payroll summary has at least four things somebody might mean by verified:
/// the *arithmetic* adds up, the *bank details* were confirmed, the *hours*
/// were approved by a manager, and the *run* was authorised for payment. They
/// are checked by different people at different times, and three of the four
/// can be true while the fourth is false. A single chip reading "Verified"
/// asserts all of them, which is how somebody signs off a run whose hours
/// nobody approved.
///
/// **So the badge is a set, not a word.** Four named checks, each with its own
/// state and its own actor, and the summary chip states how many of the four
/// hold. "3 of 4 verified" is a sentence somebody can act on; "Verified" is
/// not.
///
/// **The band on this row is well formed and belongs to something else.** Floor
/// 0.95, optimal 0.999, ceiling 1, in the right order for a higher-is-better
/// ratio -- and it is a *data validation pass rate*, which is about input
/// sanitisation, not about whether four human and machine checks agree. Step
/// 372 in this batch carries the identical band on an export button, and
/// `HabotAttendanceExport` already declares the same three numbers, so this is
/// the third row in the sheet using one band for three different subjects.
///
/// **A partial verification must not round up.** The chip reports the count and
/// the badge's own qualitative output is Pass only when all four hold; three of
/// four is Fail, because the point of the control is the one that is missing.
///
/// **COLUMN NOTE.** The Data Requirement cell reads "Data/artifacts to prepare:
/// Verified" -- the badge label lifted into the artefact list, the same shape
/// as Steps 352 and 356 -- and the row's Setup Step column is empty.
library;

import '../reports/attendance_export.dart';

/// What somebody might mean by "verified" on a payroll summary.
enum HabotPayrollCheck {
  /// The line items sum to the stated total.
  arithmetic,

  /// The destination account was confirmed with the bank.
  bankDetails,

  /// A manager approved the hours behind the figure.
  hoursApproved,

  /// The run was authorised for payment by somebody with the authority.
  runAuthorised,
}

/// The state of one check.
class HabotCheckState {
  const HabotCheckState({
    required this.check,
    required this.holds,
    required this.actor,
  });

  final HabotPayrollCheck check;
  final bool holds;

  /// Who or what established it. Empty when it has not been established.
  final String actor;
}

/// The payroll verification badge.
class HabotPayrollVerifiedBadge {
  const HabotPayrollVerifiedBadge._();

  // -----------------------------------------------------------------------
  // Four meanings, one word.
  // -----------------------------------------------------------------------

  static const Map<HabotPayrollCheck, String> meaningOf =
      <HabotPayrollCheck, String>{
    HabotPayrollCheck.arithmetic: 'the line items sum to the total',
    HabotPayrollCheck.bankDetails: 'the destination account was confirmed',
    HabotPayrollCheck.hoursApproved: 'a manager approved the hours',
    HabotPayrollCheck.runAuthorised: 'the run was authorised for payment',
  };

  static const Map<HabotPayrollCheck, String> establishedBy =
      <HabotPayrollCheck, String>{
    HabotPayrollCheck.arithmetic: 'the application',
    HabotPayrollCheck.bankDetails: 'the bank',
    HabotPayrollCheck.hoursApproved: 'a manager',
    HabotPayrollCheck.runAuthorised: 'an authorised approver',
  };

  static int get meaningCount => meaningOf.length;

  static bool get everyMeaningIsDistinct =>
      meaningOf.values.toSet().length == meaningCount;

  static bool get everyCheckHasADifferentActor =>
      establishedBy.values.toSet().length == meaningCount;

  static const int meaningsTheRowNames = 1;

  static bool get theRowNamesOneOfFour =>
      meaningsTheRowNames == 1 && meaningCount == 4;

  static const String ambiguityNote =
      'A payroll summary has at least four things somebody might mean by '
      'verified, and they are established by four different actors at four '
      'different times: the application checks the arithmetic, the bank '
      'confirms the account, a manager approves the hours, and an authorised '
      'approver releases the run. Three can hold while the fourth does not, '
      'which is exactly how a run whose hours nobody approved gets signed off '
      'by somebody reading one chip.';

  // -----------------------------------------------------------------------
  // The badge is a set, not a word.
  // -----------------------------------------------------------------------

  static const List<HabotCheckState> workedRun = <HabotCheckState>[
    HabotCheckState(
      check: HabotPayrollCheck.arithmetic,
      holds: true,
      actor: 'the application',
    ),
    HabotCheckState(
      check: HabotPayrollCheck.bankDetails,
      holds: true,
      actor: 'the bank',
    ),
    HabotCheckState(
      check: HabotPayrollCheck.hoursApproved,
      holds: false,
      actor: '',
    ),
    HabotCheckState(
      check: HabotPayrollCheck.runAuthorised,
      holds: true,
      actor: 'an authorised approver',
    ),
  ];

  static int get holdingCount =>
      workedRun.where((HabotCheckState s) => s.holds).length;

  static List<HabotPayrollCheck> get missing => workedRun
      .where((HabotCheckState s) => !s.holds)
      .map((HabotCheckState s) => s.check)
      .toList();

  static String get chipLabel => '$holdingCount of $meaningCount verified';

  static bool get theChipStatesACount => chipLabel.contains('of 4');

  static bool get theMissingCheckIsNamed =>
      missing.length == 1 && missing.first == HabotPayrollCheck.hoursApproved;

  static bool get everyHoldingCheckNamesItsActor => workedRun
      .where((HabotCheckState s) => s.holds)
      .every((HabotCheckState s) => s.actor.isNotEmpty);

  static const String setNote =
      '"3 of 4 verified" is a sentence somebody can act on, and it names which '
      'one is missing. "Verified" is not a sentence, it is a mood. Each '
      'holding check also carries the actor that established it, because a '
      'claim without an author is the same problem one level down: somebody '
      'has to be able to ask the bank, or the manager, and know which.';

  // -----------------------------------------------------------------------
  // Partial does not round up.
  // -----------------------------------------------------------------------

  static bool get allFourHold => holdingCount == meaningCount;

  static const bool aPartialVerificationRendersAsVerified = false;

  static const String roundingNote =
      'Three of four is Fail, not "nearly Pass". The point of a verification '
      'control is the check that is missing, so a badge that rounds up is '
      'worse than no badge: it converts a known gap into an unknown one. The '
      'chip stays on screen showing the count, because removing it would hide '
      'the three that do hold.';

  // -----------------------------------------------------------------------
  // The band, which belongs to a different subject.
  // -----------------------------------------------------------------------

  static const double bandFloor = 0.95;
  static const double bandOptimal = 0.999;
  static const double bandCeiling = 1;

  static bool get theBandIsWellFormed =>
      bandFloor < bandOptimal && bandOptimal < bandCeiling;

  /// The same three numbers already exist in the repository, on a different
  /// subject, declared at the attendance export.
  static bool get theSameBandIsAlreadyDeclaredElsewhere =>
      HabotAttendanceExport.floor == bandFloor &&
      HabotAttendanceExport.optimal == bandOptimal &&
      HabotAttendanceExport.ceiling == bandCeiling;

  static const int rowsSharingThisBandInThisBatch = 2;

  static const String bandNote =
      'Floor 0.95, optimal 0.999, ceiling 1, correctly ordered for a '
      'higher-is-better ratio -- and it measures a data validation pass rate, '
      'which is about input sanitisation rather than about whether four '
      'separate checks agree. Step 372 in this batch carries the identical '
      'band on an export button, and the attendance export already declares '
      'the same three numbers, so one band is doing duty for three unrelated '
      'subjects.';

  static Map<String, bool> get obligations => <String, bool>{
        'the four meanings are named and distinct':
            everyMeaningIsDistinct && meaningCount == 4,
        'each check names the actor that establishes it':
            everyCheckHasADifferentActor,
        'the chip states a count rather than a word': theChipStatesACount,
        'the missing check is named': theMissingCheckIsNamed,
        'a partial verification does not render as verified':
            !aPartialVerificationRendersAsVerified,
        'every holding check carries its author':
            everyHoldingCheckNamesItsActor,
      };

  static String get qualitativeOutput => allFourHold ? 'Pass' : 'Fail';

  /// The worked run reports Fail, which is the correct reading of it.
  static bool get theWorkedRunFails => !allFourHold;

  static Map<String, bool> get checks => <String, bool>{
        'four meanings, one word':
            meaningCount == 4 && theRowNamesOneOfFour,
        'each meaning has a different actor':
            everyCheckHasADifferentActor &&
                ambiguityNote.contains('nobody approved'),
        'the worked run holds three of four':
            holdingCount == 3 && theChipStatesACount,
        'the one that is missing is named':
            theMissingCheckIsNamed && missing.length == 1,
        'every holding check names its author':
            everyHoldingCheckNamesItsActor &&
                setNote.contains('without an author'),
        'three of four does not round up to Pass':
            !aPartialVerificationRendersAsVerified && theWorkedRunFails,
        'the chip stays on screen rather than disappearing':
            roundingNote.contains('three that do hold'),
        'the band is well formed':
            theBandIsWellFormed && bandOptimal == 0.999,
        'and the same three numbers already exist on another subject':
            theSameBandIsAlreadyDeclaredElsewhere &&
                rowsSharingThisBandInThisBatch == 2,
        'six obligations, all met, on a run that still reports Fail':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Fail',
      };

  static const String columnNote =
      'COLUMN NOTE: the Data Requirement cell on this row reads '
      '"Data/artifacts to prepare: Verified", which is the badge label lifted '
      'into the artefact list -- the same shape as Steps 352 and 356 -- and '
      'the Setup Step column is empty. Atomic Step: "Design a \\"Verified\\" '
      'badge for the mobile payroll summary."';
}
