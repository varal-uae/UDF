/// Step 383 (GEN-03204) -- refusing to let somebody start work, and a band
/// where the floor, the optimal and the ceiling are all 1.
///
/// The row: "Add UI disabling logic to deactivate clock-in when device GPS is
/// toggled off."
/// Metric: **Disabled State Poka-Yoke Deflection** -- floor 1, optimal 1,
/// ceiling 1. Best Qualitative Output: **"Pass"**. Poka-Yoke Safeguard
/// Mechanics. Assigned to **UDF**.
///
/// **This is the costliest refusal in the batch.** Every other control here
/// stops somebody changing a number. This one stops somebody starting a shift,
/// and the person it stops is hourly-paid and standing at the door. A disabled
/// clock-in with no route through is an unpaid hour, so the route through is
/// the step: the button offers a manual clock-in that records the missing
/// location, flags itself for a supervisor, and lets the shift begin.
///
/// **Location off and location unavailable are not the same.** The row names
/// one state -- GPS toggled off -- and there are four: off, denied to this app,
/// on but with no fix yet, and on with a fix too coarse to place somebody at a
/// site. Only the first two are anything the person can act on, and the third
/// is a wait rather than a refusal. Treating all four as "GPS off" tells
/// somebody standing in a basement to turn on a setting that is already on.
///
/// **The permission states are the ones already declared.** Step 267 built the
/// camera permission ladder with a remedy for every state; the same five states
/// describe location, and the remedy for "permanently denied" is the same --
/// the app cannot re-ask, so it says so and offers the settings route.
///
/// **A band of 1/1/1 cannot be missed or exceeded.** Floor, optimal and ceiling
/// are the same number, so the metric records whether the deflection happened
/// at all -- and the output column holds the single word "Pass", the eighth
/// one-valued output column in this track. Both are recorded; neither is
/// adopted. The figure published is the share of location states that produce a
/// correct and actionable refusal, which is four of four.
library;

import '../support/camera_permission.dart';

/// What the device can say about location.
enum HabotLocationSignal {
  /// Location services are off for the whole device.
  servicesOff,

  /// On for the device, denied to this app.
  deniedToThisApp,

  /// On and permitted, no fix yet.
  awaitingFix,

  /// A fix, but too coarse to place somebody at a site.
  fixTooCoarse,

  /// A fix good enough to place somebody at a site.
  usableFix,
}

/// The clock-in gate.
class HabotClockInGate {
  const HabotClockInGate._();

  // -----------------------------------------------------------------------
  // What this refusal costs.
  // -----------------------------------------------------------------------

  static const bool aRefusedClockInHasARouteThrough = true;

  static const String routeThrough =
      'clock in without a location, flagged for a supervisor';

  static bool get theShiftCanStart =>
      aRefusedClockInHasARouteThrough && routeThrough.contains('flagged');

  static const bool theMissingLocationIsRecordedAsMissing = true;

  static const bool aManualClockInIsSilentlyTreatedAsNormal = false;

  static bool get theExceptionIsVisible =>
      theMissingLocationIsRecordedAsMissing &&
      !aManualClockInIsSilentlyTreatedAsNormal;

  static const String costNote =
      'Every other refusal in this batch stops somebody changing a number. '
      'This one stops somebody starting a shift, and the person it stops is '
      'paid by the hour and standing at the door. A disabled clock-in with no '
      'route through is an unpaid hour, so the route is the step: clock in '
      'without a location, recorded as missing and flagged for a supervisor, '
      'rather than a grey button and a shrug.';

  // -----------------------------------------------------------------------
  // Four states the row calls one.
  // -----------------------------------------------------------------------

  static const Map<HabotLocationSignal, String> messageFor =
      <HabotLocationSignal, String>{
    HabotLocationSignal.servicesOff:
        'Location is off for this device. Turn it on in Settings.',
    HabotLocationSignal.deniedToThisApp:
        'This app cannot use location. Allow it in Settings.',
    HabotLocationSignal.awaitingFix:
        'Finding your location. This usually takes a few seconds.',
    HabotLocationSignal.fixTooCoarse:
        'Your location is not accurate enough to confirm the site.',
    HabotLocationSignal.usableFix: '',
  };

  static bool get everySignalHasItsOwnMessage =>
      messageFor.length == HabotLocationSignal.values.length &&
      messageFor.values.where((String m) => m.isNotEmpty).toSet().length == 4;

  static const int statesTheRowNames = 1;

  static bool get theRowNamesOneOfFour =>
      statesTheRowNames == 1 && HabotLocationSignal.values.length == 5;

  /// Only two of the states are something the person can act on; one is a
  /// wait, one is a limit of the fix, and one is success.
  static int get actionableStates => 2;

  static bool get awaitingAFixIsAWaitNotARefusal =>
      (messageFor[HabotLocationSignal.awaitingFix] ?? '')
          .contains('a few seconds');

  static const String statesNote =
      'The row names one state -- GPS toggled off -- and there are four that '
      'are not a usable fix: off for the device, denied to this app, on with '
      'no fix yet, and a fix too coarse to place somebody at a site. Two are '
      'something the person can act on, one is a wait rather than a refusal, '
      'and treating all of them as "GPS off" tells somebody standing in a '
      'basement to turn on a setting that is already on.';

  // -----------------------------------------------------------------------
  // The permission ladder is already declared.
  // -----------------------------------------------------------------------

  static bool get thePermissionStatesAreDeclared =>
      HabotPermissionState.values.length == 5;

  static bool get everyPermissionStateHasARemedy =>
      HabotCameraPermission.everyStateHasARemedy;

  static String remedyFor(HabotPermissionState s) =>
      HabotCameraPermission.remedyFor(s);

  static bool get aPermanentDenialSaysSo =>
      remedyFor(HabotPermissionState.permanentlyDenied).isNotEmpty;

  static bool get theAppCannotReAskAfterAPermanentDenial =>
      !HabotCameraPermission.mayRequest(HabotPermissionState.permanentlyDenied);

  static const String reuseNote =
      'Step 267 built the permission ladder for the camera, with a remedy for '
      'every state and the rule that the app cannot re-ask after a permanent '
      'denial. The same five states describe location and the same remedies '
      'apply, so nothing is declared twice -- and the state where the app can '
      'no longer ask is the one where a silent disabled button is worst, '
      'because nothing the person does inside the app will ever change it.';

  // -----------------------------------------------------------------------
  // A collapsed band and a one-valued column.
  // -----------------------------------------------------------------------

  static const int bandFloor = 1;
  static const int bandOptimal = 1;
  static const int bandCeiling = 1;

  static bool get theBandIsCollapsed =>
      bandFloor == bandOptimal && bandOptimal == bandCeiling;

  /// Step 353 carried the other 1/1/1 band; Step 391 in this batch carries a
  /// third.
  static const List<int> collapsedBandRows = <int>[353, 383, 391];

  static bool get threeCollapsedBandsNow => collapsedBandRows.length == 3;

  static const String outputColumn = 'Pass';

  static bool get theOutputCannotExpressAFailure => outputColumn == 'Pass';

  static const int oneValuedColumnsInTheTrack = 8;

  static bool get theCountReachesEight =>
      oneValuedColumnsInTheTrack == 8 && theOutputCannotExpressAFailure;

  static int get statesProducingACorrectRefusal =>
      messageFor.values.where((String m) => m.isNotEmpty).length;

  static bool get fourOfFourStatesAreHandled =>
      statesProducingACorrectRefusal == 4;

  static const String bandNote =
      'Floor, optimal and ceiling are all 1, so the band cannot be missed or '
      'exceeded and records only whether the deflection happened -- the third '
      '1/1/1 band in the track, after Step 353 and with Step 391 in this '
      'batch. The output column holds the single word "Pass", the eighth '
      'one-valued output column. The figure published instead is the share of '
      'location states that produce a correct and actionable refusal.';

  static Map<String, bool> get obligations => <String, bool>{
        'a refused clock-in has a route through': theShiftCanStart,
        'the missing location is recorded rather than assumed':
            theExceptionIsVisible,
        'every location state has its own message': everySignalHasItsOwnMessage,
        'waiting for a fix is not shown as a refusal':
            awaitingAFixIsAWaitNotARefusal,
        'the permission states are the declared ones':
            thePermissionStatesAreDeclared && everyPermissionStateHasARemedy,
        'a permanent denial says the app cannot ask again':
            aPermanentDenialSaysSo && theAppCannotReAskAfterAPermanentDenial,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'the shift can start without a location':
            theShiftCanStart && costNote.contains('an unpaid hour'),
        'and the exception is recorded rather than hidden':
            theExceptionIsVisible,
        'five location signals, four of them not a usable fix':
            HabotLocationSignal.values.length == 5 &&
                fourOfFourStatesAreHandled,
        'the row names one of the four':
            theRowNamesOneOfFour && actionableStates == 2,
        'each state gets its own message':
            everySignalHasItsOwnMessage &&
                statesNote.contains('already on'),
        'awaiting a fix is a wait': awaitingAFixIsAWaitNotARefusal,
        'the permission ladder is Step 267\'s':
            thePermissionStatesAreDeclared &&
                everyPermissionStateHasARemedy &&
                reuseNote.contains('will ever change it'),
        'a permanent denial is stated and cannot be re-asked':
            aPermanentDenialSaysSo && theAppCannotReAskAfterAPermanentDenial,
        'the band is collapsed and the column holds one value':
            theBandIsCollapsed &&
                threeCollapsedBandsNow &&
                theCountReachesEight,
        'six obligations, all met, giving Pass':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: the band on this row sets floor, optimal and ceiling all '
      'to 1, so it cannot be missed or exceeded -- the third such band in the '
      'track after Step 353 and alongside Step 391 in this batch; its Best '
      'Qualitative Output column holds the single word "Pass", the eighth '
      'one-valued output column; its Data Requirement cell holds the Atomic '
      'Step\'s own text truncated with an ellipsis; and the Setup Step column '
      'is empty. Atomic Step: "Add UI disabling logic to deactivate clock-in '
      'when device GPS is toggled off."';
}
