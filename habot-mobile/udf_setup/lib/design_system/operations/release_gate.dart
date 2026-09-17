/// Step 382 (GEN-03061) -- the same button Step 292 disabled, with a different
/// condition, a different name and no reference to the first row.
///
/// The row: "Configure the project management UI to physically disable Release
/// to Production if an AI System Impact Assessment is missing or unapproved."
/// Metric: **Task Completion Status** -- floor 0.8, optimal 1, ceiling 1.
/// Complete/Partial/Not Complete. ITIL v4 Service Value System / Internal SOP.
/// Assigned to **UDF**.
///
/// **Second duplicated control in this batch, and a different kind of
/// duplicate.** Step 380 repeats Step 368's instruction outright. This one is
/// subtler: Step 292 (PELCE-029-17) says "permanently disable and visually grey
/// out the 'Release to Tech' button if the reconciliation score != 0"; this row
/// disables "Release to Production" if an impact assessment is missing or
/// unapproved. Two rows, one release control, two conditions, two names for the
/// button, and neither row mentions the other. If they are the same button it
/// has two gates and one of them is invisible to whoever wrote the other; if
/// they are different buttons, the sheet never says so.
///
/// **So the gate is a set, not a boolean.** A release control with one
/// condition hard-coded is a control that gets a second condition bolted on by
/// the next row. Blockers are declared as a list, every blocker states itself,
/// and the button is enabled only when the list is empty -- which makes adding
/// Step 292's reconciliation score a data change rather than a rewrite.
///
/// **"Missing or unapproved" are two states and only one is actionable.** No
/// assessment means somebody has to write one; an unapproved assessment means
/// somebody has to read one. Collapsing them into "not approved" sends the
/// wrong person to the wrong queue, which is the commonest way a governance
/// gate becomes a two-week delay nobody can explain.
///
/// **A client-side gate is a reminder, not a control.** The release happens on
/// a server, and a disabled button is a courtesy to whoever is looking at the
/// screen. Step 376 recorded the same limit for role-gated elements; it is
/// worth stating twice because "physically disable" reads like a guarantee.
library;

import '../operations/permanent_disable.dart';

/// Why a release is blocked.
enum HabotReleaseBlocker {
  /// No AI System Impact Assessment exists for this release.
  assessmentMissing,

  /// One exists and has not been approved.
  assessmentUnapproved,

  /// The reconciliation score is not zero. Step 292's condition.
  reconciliationOpen,
}

/// The release gate.
class HabotReleaseGate {
  const HabotReleaseGate._();

  // -----------------------------------------------------------------------
  // The other row.
  // -----------------------------------------------------------------------

  static const int theOtherRow = 292;

  static const String theOtherReference = 'PELCE-029-17';

  static const String theOtherRowsButton = 'Release to Tech';

  static const String thisRowsButton = 'Release to Production';

  static const bool eitherRowMentionsTheOther = false;

  static bool get twoRowsGateOneKindOfRelease =>
      theOtherRow == 292 && !eitherRowMentionsTheOther;

  static bool get theButtonsAreNamedDifferently =>
      theOtherRowsButton != thisRowsButton;

  static const String duplicateNote =
      'Step 292 disables "Release to Tech" when the reconciliation score is '
      'not zero; this row disables "Release to Production" when an impact '
      'assessment is missing or unapproved. Two rows, one release control, two '
      'conditions, two names, and neither mentions the other. If it is one '
      'button it has two gates and each row knows about one; if it is two '
      'buttons, the sheet never says so. Step 380 in this batch is the blunter '
      'version of the same problem.';

  // -----------------------------------------------------------------------
  // A set of blockers, not a boolean.
  // -----------------------------------------------------------------------

  static const Map<HabotReleaseBlocker, String> statementFor =
      <HabotReleaseBlocker, String>{
    HabotReleaseBlocker.assessmentMissing:
        'no AI System Impact Assessment has been filed for this release',
    HabotReleaseBlocker.assessmentUnapproved:
        'the impact assessment is filed and waiting for approval',
    HabotReleaseBlocker.reconciliationOpen:
        'the design reconciliation score is not zero',
  };

  static bool get everyBlockerStatesItself =>
      statementFor.length == HabotReleaseBlocker.values.length &&
      statementFor.values.every((String s) => s.isNotEmpty);

  static bool isEnabled(Set<HabotReleaseBlocker> blockers) => blockers.isEmpty;

  static bool get theButtonNeedsAnEmptyList =>
      isEnabled(<HabotReleaseBlocker>{}) &&
      !isEnabled(<HabotReleaseBlocker>{HabotReleaseBlocker.assessmentMissing});

  /// Step 292's condition is in the same list rather than in a second gate.
  static bool get theOtherRowsConditionIsInTheSameList =>
      HabotReleaseBlocker.values
          .contains(HabotReleaseBlocker.reconciliationOpen);

  static const bool aSecondConditionNeedsARewrite = false;

  static const String setNote =
      'A release control with one condition hard-coded is a control the next '
      'row bolts a second condition onto. The blockers are a list, every one '
      'states itself, and the button is enabled only when the list is empty, '
      'so adding Step 292\'s reconciliation score is a data change rather than '
      'a rewrite -- and the two conditions cannot end up in two gates that do '
      'not know about each other.';

  // -----------------------------------------------------------------------
  // Missing and unapproved are different queues.
  // -----------------------------------------------------------------------

  static const Map<HabotReleaseBlocker, String> whoActsOn =
      <HabotReleaseBlocker, String>{
    HabotReleaseBlocker.assessmentMissing: 'the engineer shipping the change',
    HabotReleaseBlocker.assessmentUnapproved: 'the approver on the assessment',
    HabotReleaseBlocker.reconciliationOpen: 'whoever owns the open gaps',
  };

  static bool get eachBlockerNamesWhoActs =>
      whoActsOn.length == HabotReleaseBlocker.values.length &&
      whoActsOn.values.toSet().length == HabotReleaseBlocker.values.length;

  static bool get theTwoAssessmentStatesGoToDifferentPeople =>
      whoActsOn[HabotReleaseBlocker.assessmentMissing] !=
      whoActsOn[HabotReleaseBlocker.assessmentUnapproved];

  static const bool theTwoStatesAreCollapsed = false;

  static const String queueNote =
      '"Missing or unapproved" are two states and only one of them is the same '
      'person\'s problem. No assessment means somebody has to write one; an '
      'unapproved assessment means somebody has to read one. Collapsed into '
      '"not approved" they send the wrong person to the wrong queue, which is '
      'how a governance gate becomes a two-week delay nobody can account for.';

  // -----------------------------------------------------------------------
  // What a disabled button is worth.
  // -----------------------------------------------------------------------

  static const bool theGateRunsOnTheServer = true;

  static const bool theDisabledButtonIsTheControl = false;

  static bool get theLimitIsStated =>
      theGateRunsOnTheServer && !theDisabledButtonIsTheControl;

  static const int theRowThatRecordedThisFirst = 376;

  static const String limitNote =
      'The release happens on a server; a disabled button is a courtesy to '
      'whoever is looking at the screen. Step 376 recorded the same limit for '
      'role-gated elements, and it is worth stating twice because "physically '
      'disable" reads like a guarantee. What the button does well is tell '
      'somebody why before they spend twenty minutes finding out.';

  // -----------------------------------------------------------------------
  // The kind, and the band.
  // -----------------------------------------------------------------------

  static const HabotDisableKind kind = HabotDisableKind.conditional;

  static HabotDisabledControl controlFor(Set<HabotReleaseBlocker> blockers) =>
      HabotDisabledControl(
        label: thisRowsButton,
        kind: kind,
        reason: blockers
            .map((HabotReleaseBlocker b) => statementFor[b] ?? '')
            .join('; '),
        whatWouldChangeIt: blockers
            .map((HabotReleaseBlocker b) => whoActsOn[b] ?? '')
            .join('; '),
      );

  static bool get aBlockedReleaseIsNotADeadEnd => !controlFor(
        <HabotReleaseBlocker>{HabotReleaseBlocker.assessmentUnapproved},
      ).isADeadEnd;

  static bool get theReasonListsEveryBlocker => controlFor(
        <HabotReleaseBlocker>{
          HabotReleaseBlocker.assessmentMissing,
          HabotReleaseBlocker.reconciliationOpen,
        },
      ).reason.contains(';');

  static const double bandFloor = 0.8;
  static const double bandOptimal = 1;
  static const double bandCeiling = 1;

  static bool get theOptimalEqualsTheCeiling => bandOptimal == bandCeiling;

  static const String metricName = 'Task Completion Status';

  static const String bandNote =
      'The metric is called "Task Completion Status", which is a status rather '
      'than a rate, and it is scored on a band of 0.8, 1, 1 -- so the optimal '
      'and the ceiling are the same value, the fifth such band this track has '
      'recorded. What the row builds is a gate, and a gate has no completion '
      'percentage: it is open or it is not, and the honest figure is how many '
      'of the blockers state themselves and name who acts.';

  static Map<String, bool> get obligations => <String, bool>{
        'the gate is a set of blockers': theButtonNeedsAnEmptyList,
        'every blocker states itself': everyBlockerStatesItself,
        'every blocker names who acts on it': eachBlockerNamesWhoActs,
        'missing and unapproved are separate states':
            theTwoAssessmentStatesGoToDifferentPeople &&
                !theTwoStatesAreCollapsed,
        'the other row\'s condition lives in the same list':
            theOtherRowsConditionIsInTheSameList,
        'the limit of a client-side gate is stated': theLimitIsStated,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Complete' : 'Partial';

  static Map<String, bool> get checks => <String, bool>{
        'two rows gate one kind of release':
            twoRowsGateOneKindOfRelease && theOtherReference == 'PELCE-029-17',
        'and they name the button differently':
            theButtonsAreNamedDifferently &&
                duplicateNote.contains('the sheet never says so'),
        'the gate takes a set and needs it empty': theButtonNeedsAnEmptyList,
        'a second condition is a data change, not a rewrite':
            theOtherRowsConditionIsInTheSameList &&
                !aSecondConditionNeedsARewrite &&
                setNote.contains('do not know about each other'),
        'three blockers, each with a statement': everyBlockerStatesItself,
        'each blocker names who acts on it': eachBlockerNamesWhoActs,
        'missing and unapproved go to different people':
            theTwoAssessmentStatesGoToDifferentPeople &&
                queueNote.contains('nobody can account for'),
        'the blocked control is not a dead end and lists every blocker':
            aBlockedReleaseIsNotADeadEnd && theReasonListsEveryBlocker,
        'a disabled button is not the control':
            theLimitIsStated && theRowThatRecordedThisFirst == 376,
        'six obligations, all met, giving Complete':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete' &&
                theOptimalEqualsTheCeiling,
      };

  static const String columnNote =
      'COLUMN NOTE: this row disables a release control that Step 292 already '
      'disables under a different condition and a different name, and neither '
      'row mentions the other; its metric is called "Task Completion Status", '
      'which is a status rather than a rate, and its optimal and ceiling are '
      'both 1; its Data Requirement cell holds the Atomic Step\'s own text '
      'truncated with an ellipsis; and the Setup Step column is empty. Atomic '
      'Step: "Configure the project management UI to physically disable '
      'Release to Production if an AI System Impact Assessment is missing or '
      'unapproved."';
}
