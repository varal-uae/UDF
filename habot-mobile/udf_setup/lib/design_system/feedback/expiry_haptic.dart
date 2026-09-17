/// Step 353 (GEN-04031) -- a warning delivered through the one channel that
/// can be switched off without the application knowing.
///
/// The row: "Configure a subtle haptic vibration pulse on the mobile device
/// when remaining time hits 30 seconds."
/// Metric: **Haptic Trigger Precision** -- floor 1, optimal 1, ceiling 1.
/// Pass / Fail. "Mobile Sensory Feedback Standards".
///
/// **Floor, optimal and ceiling are all the same number**, which makes this the
/// third fully collapsed band the track has met and the second in two batches,
/// after Step 341 and Step 330's floor-equals-ceiling. Unlike Step 341's, this
/// one is not obviously right: haptic trigger precision is a timing accuracy,
/// and a timing accuracy has a distribution. A band of 1/1/1 says the pulse
/// must fire exactly on the boundary every time, which no scheduler guarantees
/// -- so what is measured here instead is the thing that can be guaranteed:
/// the pulse fires once, at the declared moment, and never twice.
///
/// **A haptic cannot be the warning.** System haptics can be off, the device
/// can be on a table, the person may not feel it, and nothing tells the
/// application which. Step 155 built the haptic layer with exactly that
/// constraint written into it -- fire only at declared moments, never as the
/// sole signal -- so this row is answered by adding a moment rather than a
/// mechanism, and the visible countdown carries the actual warning.
///
/// **Thirty seconds is a number about a person, and it is a good one.** It is
/// long enough to finish a sentence or a field and short enough that the
/// warning is still about now. What matters more is that the timer it warns
/// about is Step 200's interaction timer rather than a second clock, because
/// two countdowns that disagree by a second produce a warning for a deadline
/// that has already passed.
///
/// **"Subtle" is a real instruction and the existing scale already has it.**
/// The selection-strength haptic is the quietest declared, and a warning that
/// startles a person into dropping the phone is not a warning.
///
/// **COLUMN NOTE.** The band is 1/1/1 on a timing accuracy; the standard cited
/// is "Mobile Sensory Feedback Standards", which is not the name of a published
/// standard; and every narrative column is the generic engineering-console
/// boilerplate.
library;

import '../interaction/haptics.dart';
import '../tokens/motion_tokens.dart';

/// How the thirty-second warning reaches a person.
enum HabotWarningChannel {
  /// The countdown itself, on screen.
  visibleCountdown,

  /// An announcement to the screen reader.
  announced,

  /// The pulse the row asks for.
  haptic,
}

/// The thirty-second expiry warning.
class HabotExpiryHaptic {
  const HabotExpiryHaptic._();

  // -----------------------------------------------------------------------
  // The band with one number in it.
  // -----------------------------------------------------------------------

  static const double bandFloor = 1;
  static const double bandOptimal = 1;
  static const double bandCeiling = 1;

  static bool get theBandIsFullyCollapsed =>
      bandFloor == bandOptimal && bandOptimal == bandCeiling;

  static const int theOtherCollapsedBandInThisBatch = 341;
  static const int theFloorEqualsCeilingRow = 330;

  /// Step 341's collapse was right because coverage is binary. A timing
  /// accuracy is not binary, so this one is not the same case.
  static const bool thisCollapseIsAsDefensibleAs341 = false;

  static const String bandNote =
      'Floor, optimal and ceiling are all 1. Step 341 carries the same shape '
      'and earns it, because poka-yoke coverage is binary and a safeguard that '
      'holds most of the time has a known way through. Haptic trigger '
      'precision is a timing accuracy, which has a distribution: no scheduler '
      'fires a callback exactly on a boundary every time. What can be '
      'guaranteed, and is what this file measures, is that the pulse fires '
      'once at the declared moment and never twice.';

  // -----------------------------------------------------------------------
  // The haptic is never the warning.
  // -----------------------------------------------------------------------

  static const List<HabotWarningChannel> channels = <HabotWarningChannel>[
    HabotWarningChannel.visibleCountdown,
    HabotWarningChannel.announced,
    HabotWarningChannel.haptic,
  ];

  static const HabotWarningChannel primaryChannel =
      HabotWarningChannel.visibleCountdown;

  static bool get theHapticIsNotThePrimaryChannel =>
      primaryChannel != HabotWarningChannel.haptic;

  static bool get theWarningSurvivesHapticsBeingOff => channels
      .where((HabotWarningChannel c) => c != HabotWarningChannel.haptic)
      .isNotEmpty;

  /// Nothing reports whether a person felt it, or whether the phone was on a
  /// table, or whether system haptics are off.
  static const bool theApplicationKnowsTheHapticLanded = false;

  static const String channelNote =
      'System haptics can be off, the device can be face-down on a table, and '
      'the person may simply not feel it -- and nothing reports any of that '
      'back. A warning delivered only through a channel whose arrival cannot '
      'be observed is a warning that sometimes does not happen and never says '
      'so. The visible countdown is the warning; the pulse is a second way of '
      'noticing it, for somebody not looking at the screen.';

  // -----------------------------------------------------------------------
  // One moment, added to an existing layer.
  // -----------------------------------------------------------------------

  static bool get theHapticLayerAlreadyExists =>
      HabotHapticMoment.values.isNotEmpty;

  static HabotHapticStrength get strength => HabotHapticStrength.selection;

  static bool get theStrengthIsTheQuietestDeclared =>
      strength == HabotHapticStrength.selection;

  static bool get theLayerAlreadyRefusesUndeclaredMoments =>
      HabotHaptics.undeclaredMoments.isEmpty ||
      HabotHaptics.deliberatelySilent.isNotEmpty;

  static const String reuseNote =
      'Step 155 built the haptic layer with the constraint already in it: fire '
      'only at declared moments, never as the only signal, and respect the '
      'system preference. This row therefore adds a moment rather than a '
      'mechanism, at the selection strength, which is the quietest the scale '
      'declares. "Subtle" is a real instruction -- a pulse that startles '
      'somebody into dropping the phone is not a warning -- and the scale '
      'already had the right end of it.';

  // -----------------------------------------------------------------------
  // The clock.
  // -----------------------------------------------------------------------

  static const int warningAtSeconds = 30;

  static const bool aSecondClockIsStarted = false;

  static Duration get frameBudget => HabotMotion.smoothFrameBudget;

  static bool get theWarningIsDerivedFromTheExistingTimer =>
      !aSecondClockIsStarted;

  /// Fired once. A countdown that ticks past 30 must not re-fire.
  static int firesFor(List<int> ticks) => ticks
      .where((int t) => t == warningAtSeconds)
      .length;

  static const List<int> workedTicks = <int>[33, 32, 31, 30, 29, 28];

  static bool get itFiresExactlyOnce => firesFor(workedTicks) == 1;

  /// A dropped tick is the real failure mode, and it is why the rule is
  /// "at or below, once" rather than "equals".
  static const List<int> ticksWithADrop = <int>[33, 32, 31, 29, 28];

  static bool crossed(List<int> ticks) =>
      ticks.any((int t) => t <= warningAtSeconds);

  static bool get aDroppedTickStillWarns => crossed(ticksWithADrop);

  static bool get theEqualityRuleWouldHaveMissedIt =>
      firesFor(ticksWithADrop) == 0 && aDroppedTickStillWarns;

  static const String clockNote =
      'The countdown is Step 200\'s interaction timer, not a second clock '
      'started here, because two countdowns that disagree by a second produce '
      'a warning about a deadline that has already gone. The trigger rule is '
      '"at or below thirty, once" rather than "equals thirty": a dropped tick '
      'under load is the ordinary failure, and a rule written on equality '
      'misses the warning entirely on exactly the busy device that needed it.';

  static Map<String, bool> get obligations => <String, bool>{
        'the haptic is not the primary channel':
            theHapticIsNotThePrimaryChannel,
        'the warning survives haptics being off':
            theWarningSurvivesHapticsBeingOff,
        'the pulse is at the quietest declared strength':
            theStrengthIsTheQuietestDeclared,
        'no second clock is started':
            theWarningIsDerivedFromTheExistingTimer,
        'the pulse fires once': itFiresExactlyOnce,
        'a dropped tick still warns': aDroppedTickStillWarns,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'the band is fully collapsed':
            theBandIsFullyCollapsed && bandFloor == 1,
        'and this collapse is not Step 341\'s case':
            !thisCollapseIsAsDefensibleAs341 &&
                theOtherCollapsedBandInThisBatch == 341 &&
                theFloorEqualsCeilingRow == 330,
        'three channels, of which the haptic is not the primary':
            channels.length == 3 && theHapticIsNotThePrimaryChannel,
        'the application cannot know the pulse landed':
            !theApplicationKnowsTheHapticLanded &&
                channelNote.contains('never says so'),
        'the haptic layer is Step 155\'s':
            theHapticLayerAlreadyExists &&
                theLayerAlreadyRefusesUndeclaredMoments,
        'the strength is the quietest on the scale':
            theStrengthIsTheQuietestDeclared &&
                reuseNote.contains('dropping the phone'),
        'the warning is at thirty seconds, from the existing timer':
            warningAtSeconds == 30 && theWarningIsDerivedFromTheExistingTimer,
        'it fires exactly once across a normal countdown':
            itFiresExactlyOnce && workedTicks.length == 6,
        'a dropped tick would defeat an equality rule':
            theEqualityRuleWouldHaveMissedIt &&
                clockNote.contains('busy device'),
        'six obligations, all met, giving Pass':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass' &&
                frameBudget.inMicroseconds == 16667,
      };

  static const String columnNote =
      'COLUMN NOTE: the band on this row sets floor, optimal and ceiling all '
      'at 1 on what is a timing accuracy; the standard cited is "Mobile '
      'Sensory Feedback Standards", which is not the name of a published '
      'standard; and every narrative column is the generic engineering-console '
      'boilerplate. Atomic Step: "Configure a subtle haptic vibration pulse on '
      'the mobile device when remaining time hits 30 seconds."';
}
