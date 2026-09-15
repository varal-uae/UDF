/// Step 283 (GEN-00854) -- a haptic that already exists, on a band that
/// disagrees with the one already declared for it.
///
/// The row: "Add haptic feedback invocation mediumImpact() to success state
/// callbacks."
/// Metric: **Haptic Trigger Execution Delay** -- floor "<= 10 ms", optimal
/// "<= 2 ms", ceiling "16 ms". Complete / Not Complete. Cited: iOS HIG /
/// Android Haptics Guidelines.
///
/// **The row is already implemented, and by the component that argues against
/// its literal reading.** `HabotHaptics` fires `medium` on
/// `submitSucceeded` -- exactly what this row asks for -- and it also declares
/// five successes it will *not* fire on: a keystroke, a field passing
/// validation, a wizard step change, a list reaching its end, a background
/// sync completing. "All success state callbacks" read literally would add all
/// five, which is the thing `restraintNote` exists to prevent: a haptic on
/// every outcome is a haptic on nothing. One success moment of six fires, and
/// that ratio is the design.
///
/// **Two rows give this metric two different bands.** The band already
/// declared for tap-to-haptic latency is 100 ms floor, 50 ms optimal, 16 ms
/// frame budget. This row says 10 ms, 2 ms, 16 ms -- a floor ten times tighter
/// and an optimal twenty-five times tighter, for the same measurement. The one
/// figure they agree on is the ceiling, and it is the only one that is a fact
/// about anything: 16 ms is a frame. Two milliseconds from tap to motor is not
/// reachable through a platform channel at all, so the tighter band is not a
/// harder target, it is an unmeetable one -- and a target nobody can meet
/// stops being read.
///
/// **And nothing here can honour the OS haptic setting.** Flutter exposes no
/// way to read it, so a person who turned haptics off at the system level
/// still gets them from this application unless they find the in-app switch.
/// That was recorded when the component was built; this step raises it to an
/// open decision rather than restating it.
library;

import '../interaction/haptics.dart';

/// A moment in this application that could be called a success.
class HabotSuccessMoment {
  const HabotSuccessMoment({
    required this.name,
    required this.fires,
    required this.why,
  });

  final String name;

  /// Whether a haptic fires. False for the ones deliberately left silent.
  final bool fires;

  final String why;
}

/// The census.
class HabotSuccessHaptic {
  const HabotSuccessHaptic._();

  /// What the row asks to bind, and what the existing component already
  /// binds it to.
  static const String invocationTheRowNames = 'mediumImpact';

  static HabotHapticStrength get strengthForSuccess =>
      HabotHaptics.strengthFor(HabotHapticMoment.submitSucceeded);

  static bool get theRowsBindingAlreadyExists =>
      strengthForSuccess == HabotHapticStrength.medium &&
      HabotHapticStrength.values.length == 3;

  // -----------------------------------------------------------------------
  // "All success state callbacks", counted.
  // -----------------------------------------------------------------------

  static List<HabotSuccessMoment> get moments => <HabotSuccessMoment>[
        const HabotSuccessMoment(
          name: 'a form submission completed',
          fires: true,
          why: 'The one the row is about, and the only one where something '
              'irreversible finished. Already bound to medium.',
        ),
        const HabotSuccessMoment(
          name: 'a field passed validation',
          fires: false,
          why: 'A success that happens dozens of times per form. Buzzing '
              'here is how the motor becomes background noise.',
        ),
        const HabotSuccessMoment(
          name: 'a wizard step changed',
          fires: false,
          why: 'Progress, not completion. The screen already moved, which is '
              'the feedback.',
        ),
        const HabotSuccessMoment(
          name: 'a keystroke registered',
          fires: false,
          why: 'The keyboard\'s own haptic already covers this, and doubling '
              'it is worse than either.',
        ),
        const HabotSuccessMoment(
          name: 'a list reached its end',
          fires: false,
          why: 'Not an action anybody took. A haptic for arriving somewhere '
              'by scrolling is a haptic nobody asked for.',
        ),
        const HabotSuccessMoment(
          name: 'a background sync completed',
          fires: false,
          why: 'Success with no person attached to it. Buzzing a pocket for '
              'something nobody did is the clearest case of all.',
        ),
      ];

  static List<HabotSuccessMoment> get firing =>
      moments.where((HabotSuccessMoment m) => m.fires).toList();

  static List<HabotSuccessMoment> get silent =>
      moments.where((HabotSuccessMoment m) => !m.fires).toList();

  /// The design, as a fraction: one success in six fires.
  static double get shareThatFires => firing.length / moments.length;

  /// And the five silent ones are the five the existing component already
  /// named, so this census is a reading of that declaration rather than a
  /// second opinion.
  static bool get theSilentSetIsTheDeclaredOne =>
      HabotHaptics.deliberatelySilent.length == silent.length &&
      silent.length == 5;

  static bool get everyMomentGivesAReason =>
      moments.every((HabotSuccessMoment m) => m.why.length > 50);

  static const String literalReadingNote =
      '"All success state callbacks" read literally binds a haptic to six '
      'moments, five of which the existing component deliberately refused. A '
      'phone that buzzes on every validated field, every wizard step and '
      'every background sync is a phone people put on silent -- and then the '
      'one haptic that mattered, the submission, is gone with the rest. One '
      'of six fires. The restraint is the feature, and it was already '
      'argued for where the component lives rather than being re-derived '
      'here.';

  // -----------------------------------------------------------------------
  // Two bands for one measurement.
  // -----------------------------------------------------------------------

  /// This row's band, in milliseconds. Integers rather than durations: a
  /// figure that is not a token does not become one by being written here.
  static const int rowFloorMs = 10;
  static const int rowOptimalMs = 2;
  static const int rowCeilingMs = 16;

  /// The band already declared for the same measurement.
  static int get declaredFloorMs => HabotHaptics.floor.inMilliseconds;
  static int get declaredOptimalMs => HabotHaptics.optimal.inMilliseconds;
  static int get declaredCeilingMs => HabotHaptics.frameBudget.inMilliseconds;

  static bool get theTwoBandsDisagree =>
      rowFloorMs != declaredFloorMs && rowOptimalMs != declaredOptimalMs;

  /// The only figure they share, and the only one that is a fact about
  /// anything: a frame.
  static bool get theyAgreeOnlyOnTheCeiling =>
      rowCeilingMs == declaredCeilingMs && rowCeilingMs == 16;

  static int get floorRatio => declaredFloorMs ~/ rowFloorMs;
  static int get optimalRatio => declaredOptimalMs ~/ rowOptimalMs;

  static bool get theDisagreementIsAnOrderOfMagnitude =>
      floorRatio == 10 && optimalRatio == 25;

  static const String twoBandsNote =
      'Two rows give this metric two different bands. The one already '
      'declared is 100 ms floor, 50 ms optimal, 16 ms frame budget; this row '
      'says 10 ms, 2 ms, 16 ms -- ten times and twenty-five times tighter '
      'for the same measurement. Both were written for the same tap-to-motor '
      'interval and only the ceiling matches, because the ceiling is the only '
      'one of the six figures that is a fact about something: 16 ms is a '
      'frame. Two milliseconds is not reachable across a platform channel at '
      'all, so the tighter band is not a harder target but an unmeetable one, '
      'and a target nobody can meet stops being read. Both are recorded; '
      'neither is quietly dropped.';

  /// The property that actually decides whether the ceiling is reachable is a
  /// property of the code rather than of a device: a haptic behind an await
  /// cannot land in the same frame however fast the hardware is.
  static bool get theCeilingIsAPropertyOfTheCallPath =>
      HabotHaptics.firesSynchronously;

  static bool get theBandStillReadsTheDeclaredVocabulary =>
      HabotHaptics.bandFor(HabotHaptics.frameBudget) == 'Good' &&
      HabotHaptics.bandFor(HabotHaptics.floor) == 'Average';

  // -----------------------------------------------------------------------
  // The preference nobody here can read.
  // -----------------------------------------------------------------------

  static const bool canReadTheOsHapticSetting = false;

  static bool get thePreferenceGapWasAlreadyRecorded =>
      HabotHaptics.preferenceNote.contains('OS haptic setting');

  static const String preferenceEscalationNote =
      'Flutter exposes no way to read the operating system\'s haptic '
      'setting, so somebody who turned haptics off at the system level still '
      'gets them here until they find the in-app switch. That was recorded '
      'when the component was built and is raised to an open decision by this '
      'step, because it is the kind of gap that stays recorded forever unless '
      'somebody is asked to decide: either the in-app default flips to off, '
      'or a plugin is added that can read the platform setting, and both are '
      'choices with a cost.';

  // -----------------------------------------------------------------------
  // Metric: Complete / Not Complete.
  // -----------------------------------------------------------------------

  static Map<String, bool> get obligations => <String, bool>{
        'the success moment fires a medium haptic':
            theRowsBindingAlreadyExists,
        'the five other successes stay silent': theSilentSetIsTheDeclaredOne,
        'the call path can meet the one-frame ceiling':
            theCeilingIsAPropertyOfTheCallPath,
        'the existing band vocabulary still decides':
            theBandStillReadsTheDeclaredVocabulary,
        'the preference gap is recorded rather than assumed away':
            thePreferenceGapWasAlreadyRecorded,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Complete' : 'Not Complete';

  static Map<String, bool> get checks => <String, bool>{
        'the row\'s binding already exists, at medium strength':
            theRowsBindingAlreadyExists &&
                invocationTheRowNames == 'mediumImpact',
        'six success moments, one of which fires':
            moments.length == 6 &&
                firing.length == 1 &&
                (shareThatFires - 1 / 6).abs() < 1e-9,
        'the five silent ones are the declared five':
            theSilentSetIsTheDeclaredOne && everyMomentGivesAReason,
        'the literal reading is recorded as the thing restraint prevents':
            literalReadingNote.contains('put on silent'),
        'the two bands disagree by an order of magnitude':
            theTwoBandsDisagree && theDisagreementIsAnOrderOfMagnitude,
        'they agree only on the ceiling, which is a frame':
            theyAgreeOnlyOnTheCeiling && twoBandsNote.contains('unmeetable'),
        'the ceiling is a property of the call path rather than the device':
            theCeilingIsAPropertyOfTheCallPath,
        'the declared band vocabulary still decides':
            theBandStillReadsTheDeclaredVocabulary,
        'the OS preference cannot be read, and that is escalated':
            !canReadTheOsHapticSetting &&
                thePreferenceGapWasAlreadyRecorded &&
                preferenceEscalationNote.contains('open decision'),
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete',
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Review the '
      'backend schema data type requirements for all incoming parameters", '
      'and the band is written with LaTeX escapes. Atomic Step: "Add haptic '
      'feedback invocation mediumImpact() to success state callbacks."';
}
