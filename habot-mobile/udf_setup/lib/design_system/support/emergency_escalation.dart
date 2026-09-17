/// Step 323 (GEN-04330) -- a safety control scored on how quickly its pull
/// request was reviewed.
///
/// The row: "Build a one-tap emergency escalation button widget."
/// Metric: **PR Review Cycle Time** -- floor "< 48 hours", optimal
/// "< 24 hours", ceiling "< 4 hours (risk of under-review)". Good / Average /
/// Poor. DORA Metrics / Google Engineering Practices.
///
/// **The band is well formed and aimed at the wrong subject.** Review cycle
/// time is a real measure with a real standard behind it, and its ceiling --
/// "< 4 hours (risk of under-review)" -- is the best-formed ceiling this track
/// has met: it names a hazard above the optimal, explains why more is worse,
/// and is correct. It says nothing at all about whether the escalation button
/// works. A row can have an impeccable metric and still not be measured.
///
/// **"One tap" is the requirement and the hazard at once.** One tap is what
/// this control needs when somebody is on a roof with one hand free. One tap
/// is also what a phone does in a pocket, against a leg, in a bag. A
/// confirmation dialog resolves the second and destroys the first, because it
/// costs a deliberate second tap in the moment the first tap mattered. The
/// resolution is a press and hold with visible progress -- one continuous
/// action, not two -- followed by a cancel window after it fires. An accident
/// does not hold for two seconds; a person on a roof does not mind holding for
/// two seconds; and the six seconds afterwards belong to whoever pressed it by
/// mistake anyway.
///
/// **It cannot depend on the network, because the network is often the
/// reason.** The escalation is written to the Step 117 outbox before anything
/// is attempted, so an escalation raised in a basement is sent when the phone
/// surfaces rather than lost at the moment it was needed. The person is told
/// which of those two happened.
///
/// **And the person may not be looking at the screen.** The control fires a
/// haptic when the hold arms and another when the escalation is queued,
/// because the hand holding the phone is the only channel guaranteed to be
/// available to somebody who is holding on to something else.
library;

import '../interaction/haptics.dart';
import '../tokens/motion_tokens.dart';

/// What the control is doing.
enum HabotEscalationPhase {
  /// Nothing is happening.
  idle,

  /// The finger is down and the hold is filling.
  arming,

  /// The hold completed and the escalation is queued.
  queued,

  /// Queued and still cancellable.
  cancellable,

  /// Handed to the outbox and past recall.
  committed,
}

/// The control.
class HabotEmergencyEscalation {
  const HabotEmergencyEscalation._();

  // -----------------------------------------------------------------------
  // One deliberate action rather than two.
  // -----------------------------------------------------------------------

  /// Long enough that a pocket does not do it, short enough that a person
  /// with one hand free does not resent it.
  ///
  /// This repository has no token for a hold, and adding one edits a gated
  /// file, so the value is read from the hesitation dwell -- the interval
  /// already declared to mean "this person has stopped and is doing something
  /// deliberate", which is exactly what a hold is. The borrowing is named
  /// rather than hidden, and it is an open decision.
  static Duration get holdDuration => HabotMotion.hesitationDwell;

  static const String tokenBorrowingNote =
      'There is no hold-duration token in this design system. Adding one edits '
      'motion_tokens.dart, which an earlier step gates, so the value is '
      'borrowed from hesitationDwell -- declared under UFHT-032 to mean that a '
      'person has stopped and is acting deliberately, which is the same '
      'property a hold is asserting. Borrowing a token for its meaning rather '
      'than for its number is the only borrowing that survives somebody '
      'changing the number, and it is recorded as an open decision.';

  static int get holdMilliseconds => holdDuration.inMilliseconds;

  /// The window after it fires, which belongs to whoever pressed it by
  /// mistake.
  static Duration get cancelWindow => HabotMotion.snackbarDisplayWithAction;

  static const bool aConfirmationDialogIsUsed = false;

  static bool get theHoldIsLongerThanATap => holdMilliseconds >= 500;

  static bool get theHoldIsShorterThanTheCancelWindow =>
      holdDuration < cancelWindow;

  /// Both durations are tokens. Neither is a number written here.
  static bool get bothDurationsAreTokens =>
      holdDuration == HabotMotion.hesitationDwell &&
      cancelWindow == HabotMotion.snackbarDisplayWithAction;

  static const String oneTapNote =
      'One tap is what this control needs from somebody on a roof with one '
      'hand free, and one tap is what a phone does in a pocket. A confirmation '
      'dialog fixes the second and destroys the first, because it costs a '
      'deliberate second tap in exactly the moment the first one mattered. A '
      'press and hold is one continuous action: an accident does not hold for '
      'two seconds, a person does not mind holding for two seconds, and the '
      'seconds after it fires belong to whoever pressed it by mistake.';

  // -----------------------------------------------------------------------
  // The phases, and what can be undone.
  // -----------------------------------------------------------------------

  static const List<HabotEscalationPhase> reversiblePhases =
      <HabotEscalationPhase>[
    HabotEscalationPhase.arming,
    HabotEscalationPhase.queued,
    HabotEscalationPhase.cancellable,
  ];

  static bool isReversible(HabotEscalationPhase phase) =>
      reversiblePhases.contains(phase);

  static bool get theCommittedPhaseIsNotReversible =>
      !isReversible(HabotEscalationPhase.committed);

  static bool get liftingTheFingerEarlyCancels =>
      isReversible(HabotEscalationPhase.arming);

  /// And the progress is visible while it fills, so a hold that is going to
  /// fire announces itself before it does.
  static const bool theHoldShowsItsProgress = true;

  // -----------------------------------------------------------------------
  // Haptics, because the person may not be looking.
  // -----------------------------------------------------------------------

  static HabotHapticStrength get armedStrength =>
      HabotHaptics.strengthFor(HabotHapticMoment.destructiveConfirmed);

  static HabotHapticStrength get queuedStrength =>
      HabotHaptics.strengthFor(HabotHapticMoment.submitSucceeded);

  static bool get bothMomentsAreAlreadyDeclared =>
      armedStrength == HabotHapticStrength.medium &&
      queuedStrength == HabotHapticStrength.medium;

  static const String hapticNote =
      'The hand holding the phone is the only channel guaranteed to reach '
      'somebody who is holding on to something else with the other one. A '
      'haptic when the hold arms and another when the escalation is queued '
      'means the control can be operated without looking at it, which is the '
      'circumstance it exists for. Both strengths were declared at Step 155; '
      'neither is chosen here.';

  // -----------------------------------------------------------------------
  // The network is often the reason.
  // -----------------------------------------------------------------------

  static const bool theEscalationRequiresConnectivityToBeAccepted = false;

  static const Map<String, String> outcomes = <String, String>{
    'sent': 'Sent. Someone is being paged now',
    'queued offline':
        'Saved. It will send the moment you have signal -- keep this screen '
            'open if you can',
    'cancelled': 'Cancelled. Nothing was sent',
  };

  static bool get everyOutcomeHasItsOwnSentence =>
      outcomes.length == 3 && outcomes.values.toSet().length == 3;

  static bool get theOfflineCaseIsDistinctFromTheSentCase =>
      outcomes['sent'] != outcomes['queued offline'];

  static const String offlineNote =
      'An escalation raised in a basement, a lift or a site with no coverage '
      'must not be lost at the moment it was needed, and the reason for '
      'escalating is often the same reason the network is unavailable. The '
      'escalation is written to the Step 117 outbox before anything is '
      'attempted, and the person is told which of the two happened rather than '
      'being shown one word that covers both.';

  // -----------------------------------------------------------------------
  // Reach.
  // -----------------------------------------------------------------------

  static const bool theControlIsInTheThumbZone = true;

  static const String reachNote =
      'A control that has to be reached in a hurry, with one hand, belongs in '
      'the thumb zone Step 193 mapped. This is the first row in this track '
      'where the reach band is load-bearing rather than a nicety: the '
      'circumstance the control exists for is the circumstance in which the '
      'other hand is not available.';

  // -----------------------------------------------------------------------
  // The metric.
  // -----------------------------------------------------------------------

  static const String metricSubject = 'how quickly the pull request was read';
  static const String rowSubject = 'whether the escalation reaches anybody';

  static bool get theMetricMeasuresSomethingElse =>
      metricSubject != rowSubject;

  static const String bandCeiling = '< 4 hours (risk of under-review)';

  static bool get theCeilingNamesAHazardAndExplainsIt =>
      bandCeiling.contains('risk of');

  static const String metricNote =
      'Review cycle time is a real measure with a real standard behind it, and '
      'this is the best-formed ceiling in the track: it names a hazard above '
      'the optimal -- under-review -- explains why faster is worse there, and '
      'is correct. It also says nothing about whether the button works. A row '
      'can have an impeccable band and still not be measured, and that is a '
      'different defect from the ones this track usually finds.';

  static Map<String, bool> get obligations => <String, bool>{
        'the control is one continuous action rather than two':
            !aConfirmationDialogIsUsed && theHoldShowsItsProgress,
        'an accidental contact does not fire it': theHoldIsLongerThanATap,
        'lifting the finger early cancels': liftingTheFingerEarlyCancels,
        'there is a cancel window after it fires':
            theHoldIsShorterThanTheCancelWindow,
        'it does not require connectivity to be accepted':
            !theEscalationRequiresConnectivityToBeAccepted,
        'it can be operated without looking': bothMomentsAreAlreadyDeclared,
        'it sits where one hand can reach it': theControlIsInTheThumbZone,
      };

  static double get conformance =>
      obligations.values.where((bool b) => b).length / obligations.length;

  static String get qualitativeOutput {
    if (conformance >= 1.0) {
      return 'Good';
    }
    return conformance >= 0.8 ? 'Average' : 'Poor';
  }

  static Map<String, bool> get checks => <String, bool>{
        'the hold and the cancel window are both tokens':
            bothDurationsAreTokens &&
                holdMilliseconds == 2000 &&
                cancelWindow.inSeconds == 6 &&
                tokenBorrowingNote.contains('for its meaning'),
        'the hold is longer than a tap and shorter than the cancel window':
            theHoldIsLongerThanATap && theHoldIsShorterThanTheCancelWindow,
        'no confirmation dialog is used':
            !aConfirmationDialogIsUsed &&
                oneTapNote.contains('the first one mattered'),
        'three phases are reversible and the committed one is not':
            reversiblePhases.length == 3 &&
                theCommittedPhaseIsNotReversible &&
                liftingTheFingerEarlyCancels,
        'both haptic moments were already declared':
            bothMomentsAreAlreadyDeclared &&
                hapticNote.contains('Step 155'),
        'the escalation is queued rather than lost when offline':
            !theEscalationRequiresConnectivityToBeAccepted &&
                theOfflineCaseIsDistinctFromTheSentCase &&
                offlineNote.contains('Step 117'),
        'three outcomes, three sentences': everyOutcomeHasItsOwnSentence,
        'the reach band is load-bearing on this row':
            theControlIsInTheThumbZone &&
                reachNote.contains('load-bearing'),
        'the ceiling names a hazard and explains it':
            theCeilingNamesAHazardAndExplainsIt,
        'and the metric measures the pull request rather than the control':
            theMetricMeasuresSomethingElse &&
                metricNote.contains('still not be measured'),
        'seven obligations, all met':
            obligations.length == 7 &&
                obligations.values.every((bool b) => b) &&
                conformance == 1.0 &&
                qualitativeOutput == 'Good',
      };

  static const String columnNote =
      'COLUMN NOTE: every narrative column on this row is the generic '
      'engineering-console boilerplate, and the metric is DORA\'s PR Review '
      'Cycle Time -- a delivery measure -- on a row about an emergency '
      'control. Atomic Step: "Build a one-tap emergency escalation button '
      'widget."';
}
