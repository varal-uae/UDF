/// AISS: BPTR-0422-A01 -- "Define Passive Failure Motion Curves."
///   Substeps: 1. Set animation duration (300ms). 2. Define easing curve.
///             3. Decide dimming intensity. 4. Set auto-scroll.
/// AISS: REF-377-A01 -- "Set Progressive Stepper Transitions."
///   Substeps: 1. slide-in duration (200ms). 2. slide-out duration.
///             3. easing function. 4. respect reduced motion preferences.
///
/// Both steps write to the same "Motion & Animation System" library, so they
/// share this file. Nothing outside it may declare a Duration or a Curve --
/// enforced by `test/guards/poka_yoke_no_hardcoded_values_test.dart`.
///
/// Source of truth: `lib/design_system/tokens/tokens.json` -> "motion".
library;

import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';

/// Named motion durations. Every animated value in the app references one.
class HabotMotion {
  const HabotMotion._();

  // --- BPTR-0422: passive failure motion ---------------------------------

  /// Substep 1: "Set animation duration (300ms)." The canonical duration for a
  /// failure state announcing itself.
  static const Duration failureDuration = Duration(milliseconds: 300);

  /// Substep 3: "Decide dimming intensity." Opacity applied to the surrounding
  /// UI while a failure holds focus. 0.32 is dark enough to read as inert but
  /// still lets the user see the context they are being pulled out of.
  static const double failureDimOpacity = 0.32;

  /// Poka-Yoke: "Animation physically locks surrounding UI until acknowledged."
  /// While true, the scrim swallows pointers.
  static const bool failureLocksSurroundingUi = true;

  /// Substep 4: "Set auto-scroll." How long the app takes to bring the failed
  /// element into view, and whether it does so at all.
  static const Duration failureAutoScrollDuration = Duration(milliseconds: 300);
  static const bool failureAutoScrollEnabled = true;

  /// Self-Chasing: "Failed element pulses continuously until resolved."
  static const Duration failurePulsePeriod = Duration(milliseconds: 1200);
  static const double failurePulseMinOpacity = 0.55;
  static const double failurePulseMaxOpacity = 1.0;

  // --- REF-377: progressive stepper transitions --------------------------

  /// Substep 1: "Define slide-in duration (200ms)."
  static const Duration stepperSlideIn = Duration(milliseconds: 200);

  /// Substep 2: "Define slide-out duration." Slightly faster than the entry so
  /// the outgoing step clears before the incoming one settles.
  static const Duration stepperSlideOut = Duration(milliseconds: 160);

  // --- Shared scale -------------------------------------------------------

  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 100);
  static const Duration standard = Duration(milliseconds: 200);
  static const Duration emphasized = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  /// The full duration ladder, in ascending order. The gate walks this.
  static const List<Duration> durationLadder = <Duration>[
    instant,
    fast,
    standard,
    emphasized,
    slow,
  ];

  /// Completion Measure (FIEVR-033): "Forms glide across steps cleanly in under
  /// 200ms." Any transition the user waits on must not exceed this.
  static const Duration interactiveCeiling = Duration(milliseconds: 200);

  /// ANSA-012 Poka-Yoke: window inside which a second back tap is swallowed.
  /// Lives here so every timing constant in the app is in one file.
  static const Duration backTapDebounce = Duration(milliseconds: 500);

  // --- Steps 21-35: surfaces, feedback, discovery, telemetry -------------

  /// GEN-00055 / GEN-00954: the bottom sheet is user-initiated and waited on,
  /// so its entry sits on the [standard] rung and therefore inside
  /// [interactiveCeiling]. Nothing the user is waiting for may be slower.
  static const Duration sheetEnter = standard;

  /// Exit is faster than entry, for the same reason the stepper's is: the
  /// outgoing surface should clear before attention moves on.
  static const Duration sheetExit = stepperSlideOut;

  /// GEN-00235: settling onto a snap point after a drag release.
  static const Duration sheetSnap = fast;

  /// GEN-01363: how long an error snackbar holds the screen. Material's
  /// guidance is 4s for a message with no action and 6s when the user has to
  /// decide something -- long enough to read, short enough not to nag.
  static const Duration snackbarDisplay = Duration(seconds: 4);
  static const Duration snackbarDisplayWithAction = Duration(seconds: 6);

  /// GEN-00201: MD3 shared-axis transition. A rung of the shared ladder
  /// ([emphasized]) rather than a one-off value.
  static const Duration sharedAxis = emphasized;

  /// ANSA-006 substep 2: "brief keypress delay timers to wait for typing
  /// pauses before running queries."
  static const Duration searchDebounce = Duration(milliseconds: 300);

  /// ANSA-006 Completion Measure: "matching assets inside dropdown lists under
  /// 350ms." The debounce is part of that budget, not on top of it.
  static const Duration searchLatencyBudget = Duration(milliseconds: 350);

  /// UFHT-032: dwell on a field beyond this reads as hesitation rather than
  /// ordinary typing.
  static const Duration hesitationDwell = Duration(seconds: 2);

  /// TTMAC-014 / UFHT-032: two taps on the same target inside this window are
  /// one correction, not two intentions.
  static const Duration doubleTapWindow = Duration(milliseconds: 300);
}

/// Named easing curves.
class HabotEasing {
  const HabotEasing._();

  /// BPTR-0422 substep 2: the failure curve. Decelerating, so the element
  /// arrives firmly rather than bouncing -- a failure is not playful.
  static const Curve failure = Curves.easeOutCubic;

  /// REF-377 substep 3: stepper easing. MD3's emphasised curve for a
  /// transition the user initiated and is waiting on.
  static const Curve stepperEnter = Curves.easeInOutCubicEmphasized;
  static const Curve stepperExit = Curves.easeInCubic;

  /// Default for anything not otherwise specified.
  static const Curve standard = Curves.easeInOut;

  /// GEN-00055: sheets rise fast and settle slowly -- MD3's standard
  /// accelerate/decelerate shape for a surface entering from an edge.
  static const Curve sheet = Curves.fastOutSlowIn;

  /// GEN-00201: the two halves of a shared-axis transition. The incoming half
  /// decelerates in, the outgoing half accelerates away, so they never appear
  /// to move at the same speed in opposite directions.
  static const Curve sharedAxisIncoming = Curves.easeOut;
  static const Curve sharedAxisOutgoing = Curves.easeIn;

  static const List<Curve> all = <Curve>[
    failure,
    stepperEnter,
    stepperExit,
    standard,
    sheet,
    sharedAxisIncoming,
    sharedAxisOutgoing,
  ];
}

/// REF-377 substep 4: "Respect reduced motion preferences."
///
/// Flutter translation note: the spec names the CSS
/// `prefers-reduced-motion` media query. The Flutter equivalent is
/// [MediaQueryData.disableAnimations], which is fed by the platform
/// accessibility feature on every target -- same signal, native transport.
///
/// Every animated widget in the design system routes its duration through
/// [resolve], so honouring the preference is not something a component author
/// can forget to do.
class HabotMotionPolicy {
  const HabotMotionPolicy._();

  /// True when the user has asked the OS to reduce motion.
  static bool prefersReducedMotion(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// The duration to actually use. Collapses to zero under reduced motion:
  /// the state change still happens, it just does not animate.
  static Duration resolve(BuildContext context, Duration duration) =>
      prefersReducedMotion(context) ? Duration.zero : duration;

  /// Same, for a curve. Under reduced motion a linear curve over a zero
  /// duration is the cheapest no-op.
  static Curve resolveCurve(BuildContext context, Curve curve) =>
      prefersReducedMotion(context) ? Curves.linear : curve;

  /// Whether a continuous, looping animation (the failure pulse) may run.
  /// A pulse that never stops is exactly what a motion-sensitive user is
  /// asking to be spared, so this is false under the preference even though
  /// the duration collapse alone would not stop a repeating controller.
  static bool allowsLoopingMotion(BuildContext context) =>
      !prefersReducedMotion(context);
}
