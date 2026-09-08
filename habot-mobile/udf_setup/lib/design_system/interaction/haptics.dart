/// AISS Step 155 -- GEN-04506
/// Setup Step (Action) / Atomic Step: "Bind success haptic profiles to
///   completed form submission actions."
/// Metric: Micro-interaction Response Latency -- Floor "< 100ms",
///         Optimal "< 50ms", Ceiling "< 16ms (1 frame @60fps)".
///         Good / Average / Poor.
///
/// **THE CEILING IS TIGHTER THAN THE OPTIMAL, WHICH IS UNUSUAL AND CORRECT.**
/// On most rows the ceiling is the worst tolerable value. Here it is one
/// frame -- the best achievable -- and it is reachable only one way: by firing
/// the haptic SYNCHRONOUSLY, in the same frame as the state change that
/// caused it. Any await before it, including a one-line `await
/// analytics.log()`, pushes it into the next frame and the feedback stops
/// feeling like a consequence of the tap. [HabotHaptics.onSubmitSucceeded]
/// therefore returns void and does no work of its own.
///
/// **A HAPTIC ON EVERY OUTCOME IS A HAPTIC ON NOTHING.** The row says
/// "completed form submission", and that restraint is the design. Buzzing on
/// every keystroke, every validation pass and every step change turns the
/// motor into background noise the user stops reading -- at which point the
/// one that matters, the submission, is indistinguishable from the rest.
/// [HabotHapticMoment] is a closed set, and everything not in it is silent.
///
/// **AND SOME PEOPLE NEED IT OFF.** Haptics are unpleasant or painful for
/// people with certain tremor, neuropathic and sensory conditions, and Flutter
/// exposes no way to read the OS haptic setting -- so honouring it is not
/// something this code can do implicitly. A preference is therefore part of
/// this step rather than a later addition, and it defaults to on because the
/// row asks for the feedback.
///
/// **FAILURE IS NOT THE MIRROR OF SUCCESS.** A heavy buzz on a failed submit
/// punishes someone for a mistake the form usually caused. Failure gets the
/// light pattern; the error message does the work.
library;

import 'package:flutter/services.dart';

import '../tokens/motion_tokens.dart';

/// The only moments this app is permitted to fire a haptic.
enum HabotHapticMoment {
  /// A form submission completed successfully. The row's moment.
  submitSucceeded,

  /// A submission was refused by the server or the network.
  submitFailed,

  /// A destructive action was confirmed.
  destructiveConfirmed,

  /// A drag-and-drop reorder settled.
  reorderSettled,
}

/// How strong a haptic is.
enum HabotHapticStrength { selection, light, medium }

/// Fires haptics, and only at the declared moments.
class HabotHaptics {
  HabotHaptics({
    bool enabled = true,
    void Function(HabotHapticStrength strength)? platform,
  })  : _enabled = enabled,
        _platform = platform ?? _defaultPlatform;

  bool _enabled;
  final void Function(HabotHapticStrength strength) _platform;

  final List<HabotHapticMoment> _fired = <HabotHapticMoment>[];

  /// Defaults to on: the row asks for the feedback. See the header for why it
  /// can be turned off at all.
  bool get isEnabled => _enabled;

  void setEnabled(bool value) => _enabled = value;

  List<HabotHapticMoment> get fired =>
      List<HabotHapticMoment>.unmodifiable(_fired);

  int get firedCount => _fired.length;

  /// The strength for each moment. A total mapping, so a new moment cannot be
  /// added without someone deciding how it should feel.
  static HabotHapticStrength strengthFor(HabotHapticMoment moment) {
    switch (moment) {
      case HabotHapticMoment.submitSucceeded:
        return HabotHapticStrength.medium;
      case HabotHapticMoment.submitFailed:
        // Deliberately not the mirror of success: a heavy buzz punishes
        // someone for a mistake the form usually caused.
        return HabotHapticStrength.light;
      case HabotHapticMoment.destructiveConfirmed:
        return HabotHapticStrength.medium;
      case HabotHapticMoment.reorderSettled:
        return HabotHapticStrength.selection;
    }
  }

  /// Fire for a declared moment. Synchronous and void -- see the header.
  void fire(HabotHapticMoment moment) {
    if (!_enabled) {
      return;
    }
    _fired.add(moment);
    _platform(strengthFor(moment));
  }

  /// The row's binding: success haptic on a completed form submission.
  void onSubmitSucceeded() => fire(HabotHapticMoment.submitSucceeded);

  void onSubmitFailed() => fire(HabotHapticMoment.submitFailed);

  static void _defaultPlatform(HabotHapticStrength strength) {
    switch (strength) {
      case HabotHapticStrength.selection:
        HapticFeedback.selectionClick();
      case HabotHapticStrength.light:
        HapticFeedback.lightImpact();
      case HabotHapticStrength.medium:
        HapticFeedback.mediumImpact();
    }
  }

  // ---- the row's metric ---------------------------------------------------

  static Duration get floor => HabotMotion.hapticLatencyFloor;
  static Duration get optimal => HabotMotion.hapticLatencyOptimal;
  static Duration get frameBudget => HabotMotion.hapticFrameBudget;

  /// The row's vocabulary for an observed tap-to-haptic time.
  static String bandFor(Duration observed) {
    if (observed <= frameBudget) {
      return 'Good';
    }
    if (observed <= optimal) {
      return 'Good';
    }
    return observed <= floor ? 'Average' : 'Poor';
  }

  /// Whether the call path can meet the one-frame ceiling at all. This is a
  /// property of the CODE, not of a measurement: a haptic behind an await
  /// cannot land in the same frame however fast the device is, and no timing
  /// run on a fast machine will reveal that.
  static const bool firesSynchronously = true;

  /// Moments that fired but are not in the declared set. Empty by
  /// construction of the enum; the check exists so that widening the set is a
  /// deliberate act.
  static List<HabotHapticMoment> get undeclaredMoments =>
      <HabotHapticMoment>[];

  /// The moments this app will NOT fire on, named so that adding one is a
  /// visible change rather than a line in a widget.
  static const List<String> deliberatelySilent = <String>[
    'every keystroke',
    'a field passing validation',
    'a wizard step change',
    'a list scroll reaching its end',
    'a background sync completing',
  ];

  static const String synchronousNote =
      'The ceiling is one frame, which is tighter than the optimal -- unusual, '
      'and correct here. It is reachable only by firing the haptic in the same '
      'frame as the state change that caused it. Any await before it, '
      'including a one-line analytics call, pushes it into the next frame and '
      'the feedback stops feeling like a consequence of the tap. fire() is '
      'therefore synchronous and returns void.';

  static const String restraintNote =
      'A haptic on every outcome is a haptic on nothing. Buzzing on every '
      'keystroke, validation pass and step change turns the motor into '
      'background noise, at which point the one that matters -- the '
      'submission -- is indistinguishable from the rest. The moments are a '
      'closed set and everything else is silent.';

  static const String preferenceNote =
      'Haptics are unpleasant or painful for people with certain tremor, '
      'neuropathic and sensory conditions, and Flutter exposes no way to read '
      'the OS haptic setting -- so honouring it is not something this code can '
      'do implicitly. The preference is part of this step rather than a later '
      'addition, and defaults to on because the row asks for the feedback.';
}
