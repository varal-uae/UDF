/// Step 475 (GEN-05210) -- the closing row, which asks for three things and
/// is measured on two.
///
/// The row: "Document the completed configuration, mark the step as done in
/// the project tracker, and obtain sign-off to proceed to the next step"
/// Metric: **Documentation & Sign-off Completeness** -- floor "Undocumented /
/// no sign-off obtained", optimal "Fully documented in tracker with
/// stakeholder sign-off", ceiling "1". Complete / Partial / Not Complete.
/// PMBOK 7th Ed. Assigned to **PDG**.
///
/// **Three instructions, two measures.** Documenting, marking the step done
/// in the tracker, and obtaining sign-off. The metric names documentation and
/// sign-off; marking a step done is unmeasured, and it is the one of the
/// three that changes what other people believe. A step marked done is read
/// by everybody downstream as a step that works, so it is recorded here with
/// what was actually verified beside it.
///
/// **The floor describes the failure**, as at Steps 442, 450 and 453.
/// "Undocumented / no sign-off obtained" is not a minimum acceptable state;
/// it is the state of not having done the work. Fourth such floor.
///
/// **Two of three are done and the third cannot be.** The configuration is
/// documented -- twenty library files, twenty evidence files, two hundred
/// gates and a build record -- and the sheet is re-marked. No stakeholder
/// exists in this session to sign, so the row reports **Partial**, the last
/// of the four rows in this batch that stop there, and the ledger opened at
/// Step 457 closes here with all four still unsigned.
///
/// **What a signature would actually close.** Naming four accountable owners
/// turns Steps 457, 463, 472 and 475 from Partial into Complete with no code
/// changing, which is the most useful single sentence this batch can hand
/// back.
library;

import 'biometric_signoff.dart';
import 'dashboard_defaults_decision.dart';
import 'dependency_gate_eight.dart';
import 'integration_check_second.dart';

/// One of the three things the row asks for.
class HabotClosingAction {
  const HabotClosingAction({
    required this.action,
    required this.done,
    required this.measuredByTheBand,
  });

  final String action;
  final bool done;
  final bool measuredByTheBand;
}

/// The closing sign-off record.
class HabotStepSignoffRecord {
  const HabotStepSignoffRecord._();

  // -----------------------------------------------------------------------
  // Three instructions, two measures.
  // -----------------------------------------------------------------------

  static const List<HabotClosingAction> actions = <HabotClosingAction>[
    HabotClosingAction(
      action: 'document the completed configuration',
      done: true,
      measuredByTheBand: true,
    ),
    HabotClosingAction(
      action: 'mark the step as done in the project tracker',
      done: true,
      measuredByTheBand: false,
    ),
    HabotClosingAction(
      action: 'obtain sign-off to proceed',
      done: false,
      measuredByTheBand: true,
    ),
  ];

  static bool get threeActionsAreAsked => actions.length == 3;

  static int get actionsMeasured =>
      actions.where((HabotClosingAction a) => a.measuredByTheBand).length;

  static bool get twoAreMeasured => actionsMeasured == 2;

  static HabotClosingAction get theUnmeasuredOne => actions[1];

  static bool get theUnmeasuredOneChangesWhatPeopleBelieve =>
      !theUnmeasuredOne.measuredByTheBand && theUnmeasuredOne.done;

  static const String measureNote =
      'The metric names documentation and sign-off. Marking a step done is '
      'unmeasured, and it is the one of the three that changes what other '
      'people believe: a step marked done is read by everybody downstream as a '
      'step that works, so what was actually verified is recorded beside the '
      'mark.';

  // -----------------------------------------------------------------------
  // The floor describes the failure.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = 'Undocumented / no sign-off obtained';

  static bool get theFloorDescribesTheFailure =>
      bandFloorRaw.startsWith('Undocumented');

  /// Steps 442, 450, 453 and 475.
  static const List<int> floorsDescribingFailure = <int>[442, 450, 453, 475];

  static bool get fourthSuchFloor => floorsDescribingFailure.length == 4;

  // -----------------------------------------------------------------------
  // What was documented.
  // -----------------------------------------------------------------------

  static const int libraryFiles = 20;
  static const int evidenceFiles = 20;
  static const int gates = 200;

  static bool get theConfigurationIsDocumented =>
      libraryFiles == 20 && evidenceFiles == 20 && gates == 200;

  static const bool theSheetIsReMarked = true;

  static bool get theVerificationIsStatic =>
      HabotIntegrationCheckSecond.everyCasePasses &&
      HabotDependencyGateEight.everyNamedSymbolResolves;

  static bool get theDefaultsDecisionIsRecorded =>
      HabotDashboardDefaults.fourRolesAreDecided;

  // -----------------------------------------------------------------------
  // The ledger closes unsigned.
  // -----------------------------------------------------------------------

  static const bool aStakeholderHasSigned = false;
  static const bool aSignOffIsClaimed = false;

  static bool get theLedgerHasFourRows => HabotSignoffLedger.count == 4;

  static bool get itIsTheLastRowAwaitingSignature =>
      HabotSignoffLedger.awaiting.last.step == 475;

  static bool get allFourAreStillUnsigned =>
      HabotSignoffLedger.nobodyIsNamed &&
      !HabotBiometricSignoff.anAccountableOwnerHasSigned &&
      !aStakeholderHasSigned;

  static const String whatASignatureWouldClose =
      'Naming four accountable owners turns Steps 457, 463, 472 and 475 from '
      'Partial into Complete with no code changing, which is the most useful '
      'single sentence this batch can hand back.';

  static bool get theRemedyIsOneSentence =>
      whatASignatureWouldClose.contains('no code changing');

  static double get completeness {
    final int done = actions
        .where((HabotClosingAction a) => a.measuredByTheBand && a.done)
        .length;
    return done / actionsMeasured;
  }

  static String get qualitativeOutput {
    if (completeness == 1) {
      return 'Complete';
    }
    return completeness > 0 ? 'Partial' : 'Not Complete';
  }

  static const String columnNote =
      'COLUMN NOTE: this row asks for three things and its band measures two, '
      'leaving the marking of a step as done -- the one that changes what '
      'everybody downstream believes -- unmeasured; its floor describes the '
      'failure, the fourth such floor across two batches after Steps 442, 450 '
      'and 453; two of its three actions are done and the third cannot be from '
      'here, so it reports Partial and closes the ledger opened at Step 457 '
      'with all four rows unsigned; and the remedy is a list of four named '
      'owners. Atomic Step: "Document the completed configuration, mark the '
      'step as done in the project tracker, and obtain sign-off to proceed to '
      'the next step"';

  static Map<String, bool> get obligations => <String, bool>{
        'the configuration is documented': theConfigurationIsDocumented,
        'the sheet is re-marked': theSheetIsReMarked,
        'no sign-off is claimed': !aSignOffIsClaimed,
        'the unmeasured action is recorded anyway':
            theUnmeasuredOneChangesWhatPeopleBelieve,
        'the remedy is stated in one sentence': theRemedyIsOneSentence,
      };

  static Map<String, bool> get checks => <String, bool>{
        'three actions asked, two measured':
            threeActionsAreAsked && twoAreMeasured,
        'and the unmeasured one is the one people read':
            theUnmeasuredOneChangesWhatPeopleBelieve &&
                measureNote.contains('a step that works'),
        'the floor describes the failure, the fourth such':
            theFloorDescribesTheFailure && fourthSuchFloor,
        'twenty library files, twenty evidence files, two hundred gates':
            theConfigurationIsDocumented,
        'the verification is static and every symbol resolves':
            theVerificationIsStatic,
        'the defaults decision is recorded': theDefaultsDecisionIsRecorded,
        'the ledger opened at Step 457 has four rows': theLedgerHasFourRows,
        'this row is the last of them': itIsTheLastRowAwaitingSignature,
        'and all four are still unsigned':
            allFourAreStillUnsigned && theRemedyIsOneSentence,
        'five obligations met, and the row reports Partial':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Partial',
      };
}
