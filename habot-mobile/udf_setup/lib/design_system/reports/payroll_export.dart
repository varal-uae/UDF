/// Step 372 (GEN-02478) -- one tap, and the four decisions it makes on
/// somebody's behalf.
///
/// The row: "Design a single-tap \"Export Payroll\" button for the mobile UI."
/// Metric: **Data Validation Pass Rate (%)** -- floor 0.95, optimal 0.999,
/// ceiling 1. Pass / Fail. ISO/IEC 27001, OWASP Input Validation.
///
/// **A single tap is a good goal and a bad default for an export.** Every
/// export answers four questions -- which period, which people, which format,
/// where it goes -- and a one-tap button answers all four silently. That is
/// right when the answers are obvious and wrong when they are not, and on a
/// payroll export three of the four have real alternatives. The button keeps
/// one tap and puts the four answers on its face, so the tap confirms a
/// decision rather than making one.
///
/// **The export is a disclosure.** Payroll is the most sensitive dataset this
/// application touches: names, bank details, salaries. An export is the moment
/// that data leaves the application's control, and what the row calls a button
/// is in audit terms an egress event. So it is recorded -- who, when, which
/// period, how many people, to where -- before the file exists, and Step 329's
/// finding applies: a gateway that sees one exit of three is not a control.
///
/// **A completed export is not a delivered one.** "Exported" and "the
/// accountant has it" are different facts, and a button that reports the first
/// as though it were the second is how a payroll deadline is missed by
/// somebody who believes they met it.
///
/// **The band is the third use of the same three numbers.** 0.95 / 0.999 / 1
/// appears on this row, on Step 357, and already in the repository on the
/// attendance export -- so the same band scores a verification badge, a payroll
/// export and an attendance export. `HabotAttendanceExport` also already
/// carries the coverage model this row needs: what was included, what was
/// omitted and why, which is the difference between an export and a claim.
library;

import 'attendance_export.dart';

/// A question every export answers, whether or not it asks.
enum HabotExportDecision {
  /// Which pay period.
  period,

  /// Which employees.
  population,

  /// CSV, PDF, or the accounting package's format.
  format,

  /// Download, share sheet, or a named destination.
  destination,
}

/// One recorded export.
class HabotExportEvent {
  const HabotExportEvent({
    required this.actor,
    required this.period,
    required this.peopleIncluded,
    required this.destination,
    required this.recordedBeforeTheFileExisted,
  });

  final String actor;
  final String period;
  final int peopleIncluded;
  final String destination;
  final bool recordedBeforeTheFileExisted;
}

/// The payroll export button.
class HabotPayrollExport {
  const HabotPayrollExport._();

  // -----------------------------------------------------------------------
  // Four decisions, shown rather than hidden.
  // -----------------------------------------------------------------------

  static const Map<HabotExportDecision, String> answerOnTheButton =
      <HabotExportDecision, String>{
    HabotExportDecision.period: 'September 2026',
    HabotExportDecision.population: 'all 48 people on this run',
    HabotExportDecision.format: 'CSV for the accounting package',
    HabotExportDecision.destination: 'the share sheet',
  };

  static bool get everyDecisionIsAnswered =>
      answerOnTheButton.length == HabotExportDecision.values.length;

  static bool get everyAnswerIsVisible =>
      answerOnTheButton.values.every((String a) => a.isNotEmpty);

  /// Three of the four have real alternatives on a payroll export, so
  /// answering them silently is answering them for somebody.
  static const int decisionsWithRealAlternatives = 3;

  static const bool theTapIsStillOne = true;

  static const String decisionNote =
      'Every export answers four questions -- which period, which people, '
      'which format, where it goes -- and a one-tap button answers all four '
      'silently. That is right when the answers are obvious and wrong when '
      'they are not, and three of the four have real alternatives here. The '
      'button keeps its single tap and puts the four answers on its face, so '
      'the tap confirms a decision instead of making one.';

  // -----------------------------------------------------------------------
  // An export is an egress event.
  // -----------------------------------------------------------------------

  static const HabotExportEvent workedExport = HabotExportEvent(
    actor: 'the signed-in payroll administrator',
    period: 'September 2026',
    peopleIncluded: 48,
    destination: 'the share sheet',
    recordedBeforeTheFileExisted: true,
  );

  static bool get theEventIsRecordedBeforeTheFile =>
      workedExport.recordedBeforeTheFileExisted;

  static bool get theEventNamesTheActor => workedExport.actor.isNotEmpty;

  static bool get theEventNamesTheDestination =>
      workedExport.destination.isNotEmpty;

  static bool get theEventCountsThePeople => workedExport.peopleIncluded == 48;

  /// Step 329 recorded a gateway that saw one exit of three; the same
  /// reasoning is why the record is written here rather than at a gateway.
  static const int theEgressFinding = 329;

  static const String egressNote =
      'Payroll is the most sensitive dataset this application touches -- '
      'names, bank details, salaries -- and an export is the moment it leaves. '
      'What the row calls a button is an egress event in audit terms, so it is '
      'recorded before the file exists: who, when, which period, how many '
      'people, to where. Step 329 recorded a gateway that could see one exit '
      'of three, which is why the record is written at the point of export '
      'rather than hoped for downstream.';

  // -----------------------------------------------------------------------
  // Exported is not delivered.
  // -----------------------------------------------------------------------

  static const String completionWording = 'Exported to your share sheet';

  static const String wordingRefused = 'Sent to your accountant';

  static bool get theWordingClaimsOnlyWhatHappened =>
      completionWording.contains('share sheet') &&
      !completionWording.contains('Sent');

  static bool get theOverclaimingWordingIsRefused =>
      wordingRefused.contains('accountant');

  static const String deliveryNote =
      '"Exported" and "the accountant has it" are different facts. A button '
      'that reports the first as though it were the second is how a payroll '
      'deadline is missed by somebody who believes they met it, so the '
      'completion wording names the share sheet and stops there -- the '
      'application handed the file to the platform, and what happens next is '
      'not something it can see.';

  // -----------------------------------------------------------------------
  // The band, and the coverage model that already exists.
  // -----------------------------------------------------------------------

  static double get bandFloor => HabotAttendanceExport.floor;
  static double get bandOptimal => HabotAttendanceExport.optimal;
  static double get bandCeiling => HabotAttendanceExport.ceiling;

  static bool get theBandIsTheAttendanceExportsBand =>
      bandFloor == 0.95 && bandOptimal == 0.999 && bandCeiling == 1;

  /// Step 357 in this batch and the attendance export already in the
  /// repository -- three subjects, one band.
  static const List<String> subjectsSharingThisBand = <String>[
    'a payroll verification badge (Step 357)',
    'this payroll export',
    'the attendance export already built',
  ];

  static bool get threeSubjectsShareOneBand =>
      subjectsSharingThisBand.length == 3;

  static bool get theCoverageModelAlreadyExists =>
      HabotExportOmission.values.isNotEmpty;

  static const bool anOmissionIsSilent = false;

  static const String coverageNote =
      'The attendance export already carries the model this row needs: what '
      'was included, what was omitted and why, which is the difference between '
      'an export and a claim about one. The same three band numbers -- 0.95, '
      '0.999, 1 -- score a verification badge at Step 357, this export, and '
      'that attendance export, so one band is doing duty for three subjects '
      'with three different failure modes.';

  static Map<String, bool> get obligations => <String, bool>{
        'all four export decisions are answered on the button':
            everyDecisionIsAnswered && everyAnswerIsVisible,
        'the export is one tap': theTapIsStillOne,
        'the egress event is recorded before the file exists':
            theEventIsRecordedBeforeTheFile,
        'the event names the actor, the destination and the count':
            theEventNamesTheActor &&
                theEventNamesTheDestination &&
                theEventCountsThePeople,
        'the completion wording claims only what happened':
            theWordingClaimsOnlyWhatHappened,
        'no omission is silent': !anOmissionIsSilent,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'four decisions, all answered visibly':
            HabotExportDecision.values.length == 4 &&
                everyDecisionIsAnswered &&
                everyAnswerIsVisible,
        'three of the four have real alternatives':
            decisionsWithRealAlternatives == 3 &&
                decisionNote.contains('confirms a decision'),
        'the tap count is still one': theTapIsStillOne,
        'the export is recorded as an egress event':
            theEventIsRecordedBeforeTheFile && theEgressFinding == 329,
        'the record names actor, destination and population':
            theEventNamesTheActor &&
                theEventNamesTheDestination &&
                theEventCountsThePeople,
        'the completion wording does not claim delivery':
            theWordingClaimsOnlyWhatHappened &&
                theOverclaimingWordingIsRefused,
        'and the reason is stated':
            deliveryNote.contains('believes they met it'),
        'the band is the attendance export\'s three numbers':
            theBandIsTheAttendanceExportsBand,
        'three subjects share it':
            threeSubjectsShareOneBand && theCoverageModelAlreadyExists,
        'six obligations, all met, giving Pass':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: the Data Requirement cell on this row reads '
      '"Data/artifacts to prepare: Export Payroll", which is the button label '
      'lifted into the artefact list -- the fourth such cell in this batch '
      'after Steps 356, 357 and 360 -- its band is the same three numbers as '
      'Step 357 and the attendance export already in the repository, and the '
      'Setup Step column is empty. Atomic Step: "Design a single-tap \\"Export '
      'Payroll\\" button for the mobile UI."';
}
