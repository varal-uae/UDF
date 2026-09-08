/// AISS Step 137 -- REF-377
/// Atomic Steps Reference ID: REF-377-A02
/// Setup Step (Action): "Set Progressive Stepper Transitions."
/// Atomic Step: "Set the global transition variable for stepper animations
///               (e.g., 0.3s ease-in-out)."
/// Metric: Variable Definition -- Floor "Done", Optimal "Done", Ceiling
///         "Done". Best Qualitative Output: Pass/Fail.
/// Completion Measure: "Transitions feel instantaneous and fluid."
///
/// THE SECOND DEPENDENCY-SATISFIED ROW: serial 466 depends on serial 400,
/// which is REF-377-A01, built at Step 12.
///
/// **THE ROW'S EXAMPLE IS NOT TAKEN, AND THAT IS THE WHOLE OF THIS STEP.**
/// "(e.g., 0.3s ease-in-out)" is an example, not a requirement -- the metric
/// is only "Variable Definition: Done". Taking the example literally would
/// breach two commitments this project has already made and gated:
///
///   1. FIEVR-033's Completion Measure, verbatim: "Forms glide across steps
///      cleanly in under 200ms." 300ms is not under 200ms.
///   2. `HabotMotion.interactiveCeiling`, which encodes exactly that measure
///      and is asserted by FIEVR-033's own gate.
///
/// REF-377-A01 already set the pair -- 200ms in, 160ms out. So the global
/// variable this row asks for is a NAME over that pair, not a third number:
/// `HabotMotion.stepperTransition` and `HabotEasing.stepperTransition`. A
/// "global transition variable" whose value silently contradicts a gated
/// completion measure would be worse than not having one.
///
/// THE EASING HALF IS TAKEN AS WRITTEN. The row says ease-in-out;
/// `HabotEasing.stepperEnter` is `Curves.easeInOutCubicEmphasized`, which is
/// that shape with the curve MD3 specifies rather than a flatter second one.
///
/// REDUCED MOTION IS PART OF THE VARIABLE, NOT A CALLER'S PROBLEM.
/// REF-377-A01 substep 4 says "respect reduced motion preferences". A global
/// transition variable that every stepper reads, and that ignores the OS
/// setting, would push that obligation onto every call site -- which is where
/// it gets forgotten. [HabotStepperTransition.resolve] answers with the
/// setting already applied.
library;

import 'package:flutter/widgets.dart';

import '../tokens/motion_tokens.dart';

/// A resolved stepper transition: what to animate with, right now, on this
/// device, with the user's motion preference already taken into account.
class HabotResolvedTransition {
  const HabotResolvedTransition({
    required this.duration,
    required this.curve,
    required this.reducedMotion,
  });

  final Duration duration;
  final Curve curve;

  /// True when the OS asked for less motion. Reported rather than hidden: a
  /// test that passes only because animation was disabled should say so.
  final bool reducedMotion;

  bool get isInstant => duration == Duration.zero;
}

/// The single global stepper transition.
class HabotStepperTransition {
  const HabotStepperTransition._();

  /// The global variable the row asks for.
  static Duration get duration => HabotMotion.stepperTransition;
  static Curve get curve => HabotEasing.stepperTransition;

  /// The outgoing half. Faster than the entry so the leaving step clears
  /// before the arriving one settles -- REF-377-A01 substep 2.
  static Duration get exitDuration => HabotMotion.stepperSlideOut;
  static Curve get exitCurve => HabotEasing.stepperExit;

  /// The value the row's example would have used.
  static Duration get rowExample => HabotMotion.emphasized;

  /// The commitment the example would have broken.
  static Duration get interactiveCeiling => HabotMotion.interactiveCeiling;

  /// True when the global variable honours the gated completion measure.
  /// This is the check that makes the deviation defensible rather than
  /// merely asserted.
  static bool get withinInteractiveCeiling => duration <= interactiveCeiling;

  /// And the check that the row's own example would NOT have honoured it --
  /// without which the one above proves nothing.
  static bool get rowExampleWouldBreachCeiling => rowExample > interactiveCeiling;

  /// Entry must not be faster than exit, or the incoming step overtakes the
  /// outgoing one and both are on screen moving in opposite directions.
  static bool get entryIsNotFasterThanExit => duration >= exitDuration;

  /// Resolve for a build context, with the OS motion preference applied.
  static HabotResolvedTransition resolve(BuildContext context) {
    final bool reduced = HabotMotionPolicy.prefersReducedMotion(context);
    return HabotResolvedTransition(
      duration: reduced ? HabotMotion.instant : duration,
      curve: HabotMotionPolicy.resolveCurve(context, curve),
      reducedMotion: reduced,
    );
  }

  /// Resolve without a context, for logic that already knows the preference.
  static HabotResolvedTransition resolveWith({required bool reducedMotion}) =>
      HabotResolvedTransition(
        duration: reducedMotion ? HabotMotion.instant : duration,
        curve: reducedMotion ? HabotEasing.reducedMotion : curve,
        reducedMotion: reducedMotion,
      );

  /// "Transitions feel instantaneous and fluid" -- the row's completion
  /// measure. Instantaneous has a number behind it: the ~100ms threshold
  /// below which a change reads as a direct consequence of the tap rather
  /// than as a delay. A step transition is not below that, and pretending
  /// otherwise would be the wrong reading: what the measure asks for is that
  /// the user never WAITS, which is the interactive ceiling, not zero.
  static Duration get perceptualImmediacy => HabotMotion.fast;

  static const String exampleNotTakenNote =
      'The row says "(e.g., 0.3s ease-in-out)". The 0.3s is an example, not a '
      'requirement -- the metric is only "Variable Definition: Done". It is '
      'not taken, because FIEVR-033 states as a Completion Measure that forms '
      'must "glide across steps cleanly in under 200ms", that measure is '
      'encoded as HabotMotion.interactiveCeiling, and 300ms breaches it. The '
      'global variable is a NAME over the 200ms/160ms pair REF-377-A01 '
      'already set, not a third number. The easing half of the row IS taken: '
      'ease-in-out, as MD3 specifies it.';

  static const String reducedMotionNote =
      'REF-377-A01 substep 4 asks that stepper transitions respect reduced '
      'motion. A global variable that every stepper reads and that ignores the '
      'OS setting would push that obligation onto every call site, which is '
      'where it gets forgotten. resolve() answers with the setting applied.';
}
