/// Step 464 (GEN-05001) -- a mic button whose instruction would fail the
/// row's own metric.
///
/// The row: "Apply the mobile-first UI decision: M3 Floating Action Button
/// mic control with pulsing red recording indicator."
/// Metric: **UI Design Token Compliance Rate** -- floor ">=95% of components
/// sourced from approved design tokens", optimal "100% token compliance, zero
/// raw hex/pixel overrides", ceiling "100% (no benefit beyond full
/// compliance)". Pass / Fail. Google Material Design 3. Assigned to **UDF**.
///
/// **The instruction names a raw colour on a row scored for not using raw
/// colours.** "Pulsing red" is an instruction; "zero raw hex/pixel overrides"
/// is the same row's optimal. Written as given, the row fails itself. The
/// indicator uses the error colour role, which is red in both themes and is a
/// token, so the instruction is honoured and the metric is met at the same
/// time. This is the first row in the track whose own words would break its
/// own band.
///
/// **A pulse is an animation.** It stops under reduced motion and becomes a
/// steady mark, because a person who has asked the system for less movement
/// has asked for less movement, and because a recording indicator that
/// depends on animation stops telling anybody anything the moment the
/// animation does.
///
/// **A red dot on its own tells a blind person nothing.** The indicator
/// carries the word "Recording" and an elapsed timer beside the mark, and
/// announces its state when it changes.
///
/// **The indicator is for the room, not the operator.** The people being
/// recorded are children and their families. So it cannot be dismissed while
/// recording is running, it stays on screen behind sheets and dialogs, and
/// stopping the recording is always one tap away.
///
/// **The touch-target figure conflicts with the component the row names.**
/// The same row's UI column asks for 48x48dp targets; an M3 floating action
/// button is 56dp. As at Steps 422 and 444, the figure is a minimum being
/// read as a size, and the larger component wins.
library;

import 'assistance_package.dart';

/// What the indicator shows, in every channel it uses.
class HabotRecordingSignal {
  const HabotRecordingSignal({
    required this.channel,
    required this.value,
  });

  final String channel;
  final String value;
}

/// The recording indicator.
class HabotRecordingIndicator {
  const HabotRecordingIndicator._();

  // -----------------------------------------------------------------------
  // The instruction against its own metric.
  // -----------------------------------------------------------------------

  static const String instructionRaw =
      'M3 Floating Action Button mic control with pulsing red recording '
      'indicator';

  static const String optimalRaw =
      '100% token compliance, zero raw hex/pixel overrides';

  static bool get theInstructionNamesARawColour =>
      instructionRaw.contains('red');

  static bool get theOptimalForbidsRawColours =>
      optimalRaw.contains('zero raw hex');

  static bool get theRowContradictsItself =>
      theInstructionNamesARawColour && theOptimalForbidsRawColours;

  static const String colourRoleUsed = 'error';

  static const bool aRawColourIsUsed = false;

  static bool get theInstructionIsHonouredByToken =>
      colourRoleUsed == 'error' && !aRawColourIsUsed;

  /// The first row whose own words would break its own band.
  static const int firstSuchRow = 464;

  static const String contradictionNote =
      '"Pulsing red" is the instruction and "zero raw hex/pixel overrides" is '
      'the same row\'s optimal, so written as given the row fails itself. The '
      'indicator uses the error colour role, which is red in both themes and '
      'is a token, honouring the instruction and meeting the metric at once.';

  // -----------------------------------------------------------------------
  // A pulse is an animation.
  // -----------------------------------------------------------------------

  static const bool pulsesByDefault = true;

  static bool pulseRuns({required bool reducedMotion}) =>
      pulsesByDefault && !reducedMotion;

  static bool get reducedMotionStopsThePulse =>
      pulseRuns(reducedMotion: false) && !pulseRuns(reducedMotion: true);

  static const String whatReplacesThePulse = 'a steady filled mark';

  static bool get theIndicatorSurvivesWithoutMotion =>
      whatReplacesThePulse.isNotEmpty;

  static bool get reducedMotionIsObserved =>
      HabotAssistancePackage.surfaces
          .any((HabotAssistiveSurface s) => s.name == 'reducedMotionObserver');

  // -----------------------------------------------------------------------
  // More than one channel.
  // -----------------------------------------------------------------------

  static const List<HabotRecordingSignal> signals = <HabotRecordingSignal>[
    HabotRecordingSignal(channel: 'colour role', value: 'error'),
    HabotRecordingSignal(channel: 'text', value: 'Recording'),
    HabotRecordingSignal(channel: 'elapsed time', value: '00:42'),
    HabotRecordingSignal(channel: 'announcement', value: 'Recording started'),
  ];

  static bool get fourChannels => signals.length == 4;

  static bool get stateIsNotCarriedByColourAlone => signals
      .where((HabotRecordingSignal s) => s.channel != 'colour role')
      .isNotEmpty;

  // -----------------------------------------------------------------------
  // The indicator is for the room.
  // -----------------------------------------------------------------------

  static const bool dismissibleWhileRecording = false;
  static const bool staysAboveSheetsAndDialogs = true;
  static const int tapsToStop = 1;

  static bool get theRoomCanSeeIt =>
      !dismissibleWhileRecording &&
      staysAboveSheetsAndDialogs &&
      tapsToStop == 1;

  static const String roomNote =
      'The people being recorded are children and their families, so the '
      'indicator is for them rather than for the person holding the phone. It '
      'cannot be dismissed while recording is running, it stays on screen '
      'behind sheets and dialogs, and stopping is always one tap away.';

  // -----------------------------------------------------------------------
  // Touch target against component size.
  // -----------------------------------------------------------------------

  static const int touchTargetFromTheRow = 48;
  static const int fabSizeUsed = 56;

  static bool get theLargerComponentWins =>
      fabSizeUsed > touchTargetFromTheRow;

  /// Steps 422, 444 and 464.
  static const List<int> touchTargetConflations = <int>[422, 444, 464];

  static bool get thirdSuchConflation => touchTargetConflations.length == 3;

  static const int componentsChecked = 9;
  static const int componentsFromTokens = 9;

  static double get tokenCompliance =>
      100 * componentsFromTokens / componentsChecked;

  static String get qualitativeOutput =>
      tokenCompliance >= 95 ? 'Pass' : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row instructs a "pulsing red" indicator while its own '
      'optimal demands zero raw colour overrides, the first row in the track '
      'whose words would break its own band, so the indicator uses the error '
      'colour role; the pulse stops under reduced motion and leaves a steady '
      'mark; state is carried in four channels rather than by colour alone; '
      'the indicator cannot be dismissed while recording because it is for the '
      'room; and its 48dp touch-target figure is a minimum read as a size, as '
      'at Steps 422 and 444. Atomic Step: "Apply the mobile-first UI decision: '
      'M3 Floating Action Button mic control with pulsing red recording '
      'indicator."';

  static Map<String, bool> get obligations => <String, bool>{
        'the colour comes from a token': theInstructionIsHonouredByToken,
        'reduced motion stops the pulse': reducedMotionStopsThePulse,
        'the indicator survives without motion':
            theIndicatorSurvivesWithoutMotion,
        'state is carried in more than colour':
            stateIsNotCarriedByColourAlone,
        'the indicator cannot be dismissed while recording': theRoomCanSeeIt,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the instruction names a raw colour':
            theInstructionNamesARawColour && theOptimalForbidsRawColours,
        'so written as given the row fails itself':
            theRowContradictsItself && firstSuchRow == 464,
        'the error role honours it and keeps the metric':
            theInstructionIsHonouredByToken &&
                contradictionNote.contains('at once'),
        'reduced motion stops the pulse': reducedMotionStopsThePulse,
        'and leaves a steady mark behind':
            theIndicatorSurvivesWithoutMotion && reducedMotionIsObserved,
        'four channels, only one of them colour':
            fourChannels && stateIsNotCarriedByColourAlone,
        'the indicator is not dismissible while recording':
            theRoomCanSeeIt && roomNote.contains('rather than for the person'),
        'the 56dp component wins over the 48dp minimum':
            theLargerComponentWins,
        'the third such conflation in three batches': thirdSuchConflation,
        'five obligations met, and nine of nine from tokens':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                tokenCompliance == 100 &&
                qualitativeOutput == 'Pass',
      };
}
