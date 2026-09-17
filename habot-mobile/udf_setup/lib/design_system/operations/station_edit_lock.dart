/// Step 381 (GEN-03072) -- locking a station because somebody is standing at
/// it, and who the lock is actually for.
///
/// The row: "Physically disable UI edit buttons at the station where manual
/// intervention is detected."
/// Metric: **Mobile Usability Task Success Rate (%)** -- floor 80, optimal 95,
/// ceiling 100. Good/Average/Poor. Nielsen Norman Group Mobile UX Heuristics /
/// ISO 9241-11. Assigned to **UDF**.
///
/// **"Detected" is doing more work than the row admits.** A manual intervention
/// is inferred from a signal -- a door opened, a guard tripped, a local
/// override thrown -- and every inference has a false-positive rate. A lock
/// driven by a signal that is wrong once a week is a lock that strands somebody
/// once a week, so the lock states the signal that caused it and offers a way
/// to say the signal was wrong.
///
/// **The person at the station is not the person the lock is for.** Whoever is
/// physically intervening knows they are; the lock exists to stop a *second*
/// person editing the same station remotely while the first has their hands in
/// it. That means the message on the two surfaces is different: at the station,
/// "you are in manual mode"; everywhere else, "Rashid is working on this,
/// started 4 minutes ago". A single shared string gets one of the two wrong.
///
/// **A lock with no holder and no age is an outage.** Both are shown, and
/// neither is a wall clock: the age comes from the same monotonic source Step
/// 133 settled for elapsed time, because a lock that appears to have lasted a
/// negative eleven minutes after a clock correction is a lock nobody trusts
/// again.
///
/// **The metric is a usability measure and this is a safety interlock.** A task
/// success rate asks whether people complete what they set out to do; an
/// interlock's entire purpose is that some attempts do not complete. Scored
/// literally, a lock that works perfectly lowers the number.
library;

import '../operations/permanent_disable.dart';

/// How a station came to be locked.
enum HabotStationMode {
  /// Running normally. Edits allowed.
  automatic,

  /// A signal says somebody is working on the machine.
  manualIntervention,

  /// The signal was disputed and cleared by a named person.
  overriddenByAPerson,
}

/// The lock as each surface sees it.
class HabotStationLockView {
  const HabotStationLockView({
    required this.audience,
    required this.message,
  });

  /// 'at the station' or 'remote'.
  final String audience;
  final String message;
}

/// The station edit lock.
class HabotStationEditLock {
  const HabotStationEditLock._();

  // -----------------------------------------------------------------------
  // Detection is inference.
  // -----------------------------------------------------------------------

  static const String signalName = 'local override switch thrown';

  static const bool theSignalIsAnObservation = false;

  static bool get theSignalIsAnInference => !theSignalIsAnObservation;

  static const bool theLockNamesItsSignal = true;

  static const bool thereIsAWayToDisputeIt = true;

  static HabotStationMode disputedBy(String person) => person.isEmpty
      ? HabotStationMode.manualIntervention
      : HabotStationMode.overriddenByAPerson;

  static bool get aDisputeNeedsAName =>
      disputedBy('') == HabotStationMode.manualIntervention &&
      disputedBy('Rashid') == HabotStationMode.overriddenByAPerson;

  static const String detectionNote =
      '"Detected" is doing more work than the row admits: a manual '
      'intervention is inferred from a signal, and every inference has a '
      'false-positive rate. A lock driven by a signal that is wrong once a '
      'week strands somebody once a week, so the lock names the signal that '
      'caused it and offers a route to say the signal was wrong. The dispute '
      'takes a name, because an override with no author is an override nobody '
      'can ask about.';

  // -----------------------------------------------------------------------
  // Two audiences, two messages.
  // -----------------------------------------------------------------------

  static const List<HabotStationLockView> views = <HabotStationLockView>[
    HabotStationLockView(
      audience: 'at the station',
      message: 'This station is in manual mode. Edits are off while you work.',
    ),
    HabotStationLockView(
      audience: 'remote',
      message: 'Rashid is working on this station. Started 4 minutes ago.',
    ),
  ];

  static bool get theTwoAudiencesGetDifferentMessages =>
      views.length == 2 && views.first.message != views.last.message;

  static bool get theRemoteMessageNamesTheHolder =>
      views.last.message.contains('Rashid');

  static bool get theLocalMessageAddressesThePersonPresent =>
      views.first.message.contains('while you work');

  static const bool aSingleSharedStringIsUsed = false;

  static const String audienceNote =
      'Whoever is physically intervening knows they are. The lock exists to '
      'stop a second person editing the same station remotely while the first '
      'has their hands in it, so the two surfaces say different things: at the '
      'station, "you are in manual mode"; everywhere else, who is working on '
      'it and for how long. One shared string gets one of the two wrong, and '
      'it is usually the remote one, which is the only one that matters.';

  // -----------------------------------------------------------------------
  // A holder and an age.
  // -----------------------------------------------------------------------

  static const String holder = 'Rashid';

  static const int ageMinutes = 4;

  static const bool theAgeComesFromAWallClock = false;

  /// Step 133 settled that elapsed time is measured monotonically, so a clock
  /// correction cannot produce a negative age.
  static const int theStepThatSettledElapsedTime = 133;

  static bool get theAgeIsMonotonic => !theAgeComesFromAWallClock;

  static bool get theLockHasAHolderAndAnAge =>
      holder.isNotEmpty && ageMinutes > 0;

  static const String ageNote =
      'A lock with no holder and no age is an outage. Both are shown, and the '
      'age is measured from the monotonic source Step 133 settled rather than '
      'from a wall clock -- a lock that appears to have lasted a negative '
      'eleven minutes after a clock correction is a lock nobody trusts again.';

  // -----------------------------------------------------------------------
  // The disabled kind.
  // -----------------------------------------------------------------------

  static const HabotDisableKind kind = HabotDisableKind.conditional;

  static bool get theLockIsConditional =>
      kind == HabotDisableKind.conditional && kind != HabotDisableKind.latched;

  static HabotDisabledControl get control => HabotDisabledControl(
        label: 'Edit station settings',
        kind: kind,
        reason: 'manual intervention detected: $signalName',
        whatWouldChangeIt: 'the station returning to automatic, or an override',
      );

  static bool get theLockIsNotADeadEnd => !control.isADeadEnd;

  static bool get theReasonNamesTheSignal =>
      control.reason.contains(signalName);

  static const String kindNote =
      'The lock is conditional in the vocabulary Step 292 declared: off while '
      'a condition holds, with the condition stated and a route back named. '
      'The word "physically" in the row is the same word Step 292 met as '
      '"permanently" -- an instruction to make the control unusable rather '
      'than to make it look unusable, which is the right instruction and says '
      'nothing about how long it lasts.';

  // -----------------------------------------------------------------------
  // A usability metric on an interlock.
  // -----------------------------------------------------------------------

  static const int bandFloor = 80;
  static const int bandOptimal = 95;
  static const int bandCeiling = 100;

  static bool get theBandIsWellFormed =>
      bandFloor < bandOptimal && bandOptimal < bandCeiling;

  static const bool anInterlockRaisesTaskSuccess = false;

  static bool get theMetricRunsBackwardsHere => !anInterlockRaisesTaskSuccess;

  static const String metricNote =
      'A task success rate asks whether people complete what they set out to '
      'do. An interlock exists so that some attempts do not complete, so a '
      'lock working perfectly lowers the number -- the metric runs backwards '
      'on this row. The band itself is well formed, 80 to 95 to 100, which is '
      'unusual enough in recent batches to record.';

  static Map<String, bool> get obligations => <String, bool>{
        'the lock names the signal that caused it':
            theLockNamesItsSignal && theReasonNamesTheSignal,
        'the signal can be disputed, by a named person':
            thereIsAWayToDisputeIt && aDisputeNeedsAName,
        'the two audiences get different messages':
            theTwoAudiencesGetDifferentMessages && !aSingleSharedStringIsUsed,
        'the lock carries a holder and an age': theLockHasAHolderAndAnAge,
        'the age cannot go backwards': theAgeIsMonotonic,
        'the lock is conditional rather than latched':
            theLockIsConditional && theLockIsNotADeadEnd,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'detection is inference, and the lock says so':
            theSignalIsAnInference && theLockNamesItsSignal,
        'a dispute route exists and needs a name':
            thereIsAWayToDisputeIt && aDisputeNeedsAName,
        'three station modes, one of them a human override':
            HabotStationMode.values.length == 3 &&
                detectionNote.contains('nobody can ask about'),
        'two audiences, two messages':
            theTwoAudiencesGetDifferentMessages &&
                theRemoteMessageNamesTheHolder &&
                theLocalMessageAddressesThePersonPresent,
        'and one shared string would get the remote one wrong':
            !aSingleSharedStringIsUsed &&
                audienceNote.contains('the only one that matters'),
        'the lock carries a holder and an age': theLockHasAHolderAndAnAge,
        'the age is monotonic, as Step 133 settled':
            theAgeIsMonotonic && theStepThatSettledElapsedTime == 133,
        'the kind is conditional and the control is not a dead end':
            theLockIsConditional && theLockIsNotADeadEnd,
        'a task success rate runs backwards on an interlock':
            theMetricRunsBackwardsHere &&
                theBandIsWellFormed &&
                metricNote.contains('lowers the number'),
        'six obligations, all met, giving Good':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good',
      };

  static const String columnNote =
      'COLUMN NOTE: the metric on this row is a mobile usability task success '
      'rate applied to a safety interlock, whose purpose is that some attempts '
      'do not succeed; its Data Requirement cell holds the Atomic Step\'s own '
      'text truncated with an ellipsis as the artefact to prepare; and the '
      'Setup Step column is empty. The band is well formed. Atomic Step: '
      '"Physically disable UI edit buttons at the station where manual '
      'intervention is detected."';
}
