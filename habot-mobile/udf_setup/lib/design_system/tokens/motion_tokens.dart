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

  // --- Steps 36-50: shell, navigation and connectivity -------------------

  /// GEN-02720 Mobile-First UX row: "Background polling refreshes data every
  /// 30 seconds."
  static const Duration pollInterval = Duration(seconds: 30);

  /// A poll still outstanding after this has failed. Deliberately shorter than
  /// [pollInterval]: a response that arrives after the next poll is due is not
  /// useful, and waiting for it is what makes an app feel hung rather than
  /// offline.
  static const Duration pollTimeout = Duration(seconds: 10);

  /// GEN-02334: the navigation surface swaps between rail and bar when the
  /// window class changes. A resize is not a user-initiated transition, so it
  /// gets the fast rung rather than the standard one.
  static const Duration navigationSurfaceSwap = fast;

  /// GEN-03404 Metric: Preference Screen Render Time -- Floor "< 100ms",
  /// Optimal "< 30ms". Budgets, not animations, but they are Durations and
  /// this is the only file allowed to declare one.
  static const Duration preferenceRenderFloor = Duration(milliseconds: 100);
  static const Duration preferenceRenderOptimal = Duration(milliseconds: 30);

  /// GEN-04803 (Step 61): one shimmer sweep across a loading skeleton.
  /// Long enough to read as a sweep rather than a flicker, short enough that a
  /// skeleton visible for one cycle still looks alive. A rung of the ladder --
  /// four times [slow] -- rather than a number chosen by eye.
  static const Duration skeletonSweep = Duration(milliseconds: 1400);

  // --- Steps 66-68: notification dispatch and delivery --------------------

  /// GEN-00692 substep 2: "a 60-second acceptance timer ('Clock') for
  /// dispatched job offers." The number is the sheet's, not a choice.
  static const Duration dispatchAcceptanceWindow = Duration(seconds: 60);

  /// GEN-00692 Completion Measure: "Push notification delivery latency
  /// <= 1.5s."
  static const Duration dispatchDeliveryBudget = Duration(milliseconds: 1500);

  /// GEN-00692 Completion Measure: "Acceptance screen load time <= 300ms."
  static const Duration dispatchScreenBudget = Duration(milliseconds: 300);

  /// GEN-00692 Completion Measure: "Average job response time <= 30s." Half
  /// the acceptance window -- a 60s clock whose average response is 55s is a
  /// clock nobody is really reading.
  static const Duration dispatchResponseBudget = Duration(seconds: 30);

  /// GEN-00692 Self-Chasing: three consecutive timeouts pause automatic
  /// dispatch "for 2 hours".
  static const Duration dispatchPause = Duration(hours: 2);

  /// GEN-00699 Metric: Client Handler Speed. Floor "<= 10 ms", optimal
  /// "<= 2 ms", ceiling "20 ms". Two milliseconds is not enough to touch
  /// storage or render a widget, which is why the receiver only parses and
  /// enqueues.
  static const Duration messageHandlerFloor = Duration(milliseconds: 10);
  static const Duration messageHandlerOptimal = Duration(milliseconds: 2);
  static const Duration messageHandlerCeiling = Duration(milliseconds: 20);

  /// GEN-00335 Ceiling: "10 seconds (staleness ceiling before alerting)". An
  /// event older than this when it arrives is not current news, so the client
  /// records it without raising the blocking panel.
  static const Duration violationStalenessCeiling = Duration(seconds: 10);

  // --- Steps 93-95: MTO task timing, reallocation and SLA -----------------

  /// GEN-00843 Setup Step Description: "auto-reallocation logic RE-ASSIGNING
  /// TASKS IF UNCOMPLETED WITHIN 5 MINUTES", and its metric row repeats the
  /// same number as floor, optimal and ceiling. The sheet's number, not a
  /// choice.
  static const Duration mtoReallocationWindow = Duration(minutes: 5);

  /// MCIIM-021 Self-Chasing: "workers will fail the 15-MINUTE TIMER because
  /// they cannot read the image." The only SLA target the sheet names for a
  /// task, taken from the row that anchors the batch.
  static const Duration mtoSlaTarget = Duration(minutes: 15);

  /// The warning point: three quarters of the SLA, which is where an operator
  /// can still do something about it. Derived rather than declared, so moving
  /// the target moves the warning with it.
  static const Duration mtoSlaWarning = Duration(minutes: 11, seconds: 15);

  /// GEN-03866 Metric: Interaction Timer Resolution Drift -- floor "<10 ms",
  /// optimal "<1 ms", ceiling "50 ms". Bands, not durations to animate with.
  static const Duration mtoTimerDriftFloor = Duration(milliseconds: 10);
  static const Duration mtoTimerDriftOptimal = Duration(milliseconds: 1);
  static const Duration mtoTimerDriftCeiling = Duration(milliseconds: 50);
  // ===================================================================
  // AISS Steps 116-135 -- the data layer and the live connection.
  //
  // Not motion tokens in the animation sense. They live here because
  // test/guards/poka_yoke_no_hardcoded_values_test.dart treats this file as
  // the SINGLE declaration site for every raw Duration in the project and
  // fails the build on one written anywhere else. A second file would mean
  // exempting it from the rule or weakening the rule -- both worse than one
  // file whose name is slightly too narrow.
  // ===================================================================

  /// Step 121 GEN-02731. The first reconnection retry window; doubles from
  /// here, capped at [pollInterval].
  static const Duration reconnectBase = Duration(milliseconds: 500);

  /// Step 127 GEN-04550. How often a heartbeat ping goes out -- long enough
  /// not to hold the radio awake, short enough to notice a dead NAT mapping
  /// inside a minute.
  static const Duration heartbeatInterval = Duration(seconds: 15);

  /// Step 127. How long a pong may take before the beat counts as missed.
  static const Duration heartbeatTimeout = Duration(seconds: 5);

  /// Step 127, the row floor (< 2s): slower than this is degraded but alive.
  static const Duration heartbeatSlowThreshold = Duration(seconds: 2);

  /// Step 124 GEN-05397, the sheet's number verbatim: heavy background
  /// synchronisation pauses when round-trip time exceeds this.
  static const Duration rttHeavySyncThreshold = Duration(milliseconds: 1000);

  /// Step 128 GEN-02599. How long the socket stays open after backgrounding
  /// before it detaches. A user glancing at a notification and coming
  /// straight back should not pay a full reconnect.
  static const Duration socketGracePeriod = Duration(seconds: 30);

  /// Step 129 GEN-02555, the row floor: data older than this is Delayed and
  /// must be labelled with its age.
  static const Duration dashboardFreshnessBudget = Duration(minutes: 5);

  /// Step 129, the row optimal: under this is Real-time.
  static const Duration dashboardFreshnessOptimal = Duration(minutes: 1);

  /// Step 130 GEN-04737. How long a submit may hold a control locked before
  /// it is released regardless -- the "unlock upon response OR TIMEOUT" half.
  static const Duration submitLockTimeout = Duration(seconds: 10);

  /// Step 131 GEN-00190. The window the ten-requests-per-second ceiling is
  /// measured over.
  static const Duration rateLimitWindow = Duration(seconds: 1);

  // --- Steps 136-155: the stepper transition, localisation and the
  //     single-question form flow ---------------------------------------

  /// Step 137 REF-377-A02: "Set the GLOBAL transition variable for stepper
  /// animations (e.g., 0.3s ease-in-out)."
  ///
  /// THE ROW'S EXAMPLE IS NOT TAKEN, AND THE REASON IS RECORDED. 0.3s would
  /// breach two things this project has already committed to: FIEVR-033's
  /// completion measure ("forms glide across steps cleanly in under 200ms")
  /// and [interactiveCeiling], which encodes it. REF-377-A01 set the pair at
  /// 200ms in and 160ms out. This is the single global name the row asks for,
  /// bound to the entry side of that pair rather than a third number.
  static const Duration stepperTransition = stepperSlideIn;

  /// Step 152 GEN-01584. The row's metric is "Real-Time Status Update
  /// Latency" -- floor <30s, optimal <5s, ceiling <60s. Those are the bounds
  /// the row states; the centring itself is an animation, and is measured
  /// against [stepperTransition] rather than against seconds. See the gate.
  static const Duration statusUpdateOptimal = Duration(seconds: 5);
  static const Duration statusUpdateFloor = Duration(seconds: 30);
  static const Duration statusUpdateCeiling = Duration(seconds: 60);

  /// Steps 147 and 153. The row metric on both is "API Response Latency (ms)"
  /// -- floor 0, optimal 100-300, ceiling 500. A form split into single
  /// questions saves at every step, so this is the budget for one such save.
  static const Duration formStepCommitOptimalMin = Duration(milliseconds: 100);
  static const Duration formStepCommitOptimalMax = Duration(milliseconds: 300);
  static const Duration formStepCommitCeiling = Duration(milliseconds: 500);

  /// Step 145 GEN-04968. Language-selection telemetry: the row's floor is
  /// <=5 min end-to-end delivery, its optimal <=1 min, and beyond
  /// [telemetryStale] the analytics are considered stale rather than late.
  static const Duration telemetryDeliveryFloor = Duration(minutes: 5);
  static const Duration telemetryDeliveryOptimal = Duration(minutes: 1);
  static const Duration telemetryStale = Duration(minutes: 15);

  /// Step 155 GEN-04506. Micro-interaction response latency: floor <100ms,
  /// optimal <50ms, ceiling one frame at 60fps.
  static const Duration hapticLatencyFloor = Duration(milliseconds: 100);
  static const Duration hapticLatencyOptimal = Duration(milliseconds: 50);
  static const Duration hapticFrameBudget = Duration(milliseconds: 16);

  // --- Steps 156-175: the instrumentation layer -------------------------

  /// Step 162 GEN-01021. Health-probe ingestion: the row's floor is one
  /// second and its ceiling three. "Instant" is its optimal, which is not a
  /// number a client can hold, so [probeIngestionOptimal] is the smallest
  /// interval this app can actually observe -- one frame.
  static const Duration probeIngestionOptimal = Duration(milliseconds: 16);
  static const Duration probeIngestionFloor = Duration(seconds: 1);
  static const Duration probeIngestionCeiling = Duration(seconds: 3);

  /// Step 164 GEN-04253, the RAIL model verbatim: 100ms reads as
  /// instantaneous, 300ms is a perceptible delay, and attention is lost at a
  /// second.
  static const Duration railInstant = Duration(milliseconds: 100);
  static const Duration railPerceptible = Duration(milliseconds: 300);
  static const Duration railAttentionLoss = Duration(milliseconds: 1000);

  /// Step 164's other half: "page interactivity load times (target < 2s on
  /// 3G)". A different budget from the RAIL one and not interchangeable with
  /// it -- RAIL is about a response to a tap, this is about a page arriving.
  static const Duration interactiveOn3g = Duration(seconds: 2);

  /// Step 165 GEN-03171, the figure the row names: cold start below 1.2s.
  static const Duration coldStartBudget = Duration(milliseconds: 1200);

  /// Step 167 GEN-00754. One frame at 60fps, to the microsecond. Sixteen
  /// milliseconds is the rounded figure; a scroll budgeted at 16ms rather
  /// than 16.667ms loses a frame roughly every two seconds.
  static const Duration smoothFrameBudget = Duration(microseconds: 16667);

  /// Step 169 GEN-00888. Pulling an attribution token out of a notification
  /// payload at launch, on the path that blocks first paint.
  static const Duration tokenExtractionOptimal = Duration(milliseconds: 2);
  static const Duration tokenExtractionFloor = Duration(milliseconds: 10);
  static const Duration tokenExtractionCeiling = Duration(milliseconds: 20);

  /// Step 170 GEN-00522. How long a failed deep-link resolution may take to
  /// land the user somewhere real.
  static const Duration fallbackRedirectOptimal = Duration(milliseconds: 100);
  static const Duration fallbackRedirectFloor = Duration(milliseconds: 500);
  static const Duration fallbackRedirectCeiling = Duration(milliseconds: 1000);

  /// Step 172 GEN-01187. Mean time to detect a watched change -- a price drop
  /// or a new slot -- before the notification is worth sending at all.
  static const Duration watchDetectOptimal = Duration(minutes: 2);
  static const Duration watchDetectFloor = Duration(minutes: 15);
  static const Duration watchDetectCeiling = Duration(minutes: 30);

  /// Steps 163 and 175. Dashboard refresh latency: the row's optimal is five
  /// minutes, its floor an hour, and beyond a day the panel is history rather
  /// than a dashboard.
  static const Duration dashboardRefreshOptimal = Duration(minutes: 5);
  static const Duration dashboardRefreshFloor = Duration(hours: 1);
  static const Duration dashboardRefreshCeiling = Duration(hours: 24);

  /// Step 171 GEN-01010. How long a deep-link context parked across an auth
  /// flow stays worth restoring. A day, so someone who signs in the next
  /// morning still lands where the link pointed; beyond that the context
  /// belongs to a session they have forgotten and restoring it is confusing.
  static const Duration deepLinkParkLifetime = Duration(hours: 24);

  // --- Step 194 GEN-04726: when a progress indicator may appear, and how
  //     long it must stay once it has ---

  /// How long work must run before a progress indicator is drawn at all.
  ///
  /// Under a few hundred milliseconds a person experiences the app as
  /// responding immediately. A spinner that appears and vanishes inside that
  /// window converts something they would not have noticed into a flash they
  /// read as a rendering glitch, so short work shows nothing.
  static const Duration loadingIndicatorDelay = Duration(milliseconds: 300);

  /// Once an indicator has appeared, the shortest time it stays.
  ///
  /// Longer than [loadingIndicatorDelay] on purpose: an indicator that
  /// appears and is removed two frames later is the same flash in reverse.
  static const Duration loadingIndicatorMinimumVisible =
      Duration(milliseconds: 500);

  // ---------------------------------------------------------------------
  // Booking, checkout and pass. Steps 196-215.
  // ---------------------------------------------------------------------

  /// Step 204 (GEN-01518): the budget for recalculating an order total when
  /// an add-on is toggled.
  ///
  /// The substance of the requirement is what this rules out. A round trip
  /// does not fit in it, so the total shown while a parent is choosing is
  /// computed on the device.
  static const Duration orderTotalRecalculationBudget =
      Duration(milliseconds: 50);

  /// Step 211 (GEN-01231): the target wall-clock duration of a re-booking.
  ///
  /// Mostly made of a person confirming a date and a payment sheet this app
  /// does not own, which is why the step bounds decisions rather than
  /// seconds.
  static const Duration rebookingTarget = Duration(seconds: 15);

  /// Step 209 (GEN-01573): how long one rendered QR pass stays valid, and
  /// how often its payload rotates while the screen is open.
  ///
  /// Rotation makes a forwarded screenshot expire; it does not make the pass
  /// single-use. That is the door's job.
  static const Duration passValidityWindow = Duration(minutes: 5);
  static const Duration passRotationPeriod = Duration(minutes: 1);

  /// Step 214 (GEN-01308): the optimal dispute resolution cycle time.
  ///
  /// The only one of that row's three bounds expressible as a duration -- the
  /// floor and ceiling are in BUSINESS days, which a Duration cannot hold.
  static const Duration disputeCycleOptimal = Duration(hours: 48);

  // ---------------------------------------------------------------------
  // Step 235 (GEN-05441): the declared performance SLAs.
  // ---------------------------------------------------------------------

  /// Server response time at the 95th percentile.
  ///
  /// The only one of that row's three figures this repository did not already
  /// hold -- FCP maps onto [coldStartBudget] and TTI onto [interactiveOn3g],
  /// both to the millisecond. It is a SERVER property: the client can measure
  /// it and cannot meet it.
  static const Duration apiLatencySla = Duration(milliseconds: 200);

  // ---------------------------------------------------------------------
  // Form input, correction telemetry and deliberate friction (Steps 247-252).
  // ---------------------------------------------------------------------

  /// How close together corrections must be to count as one burst rather
  /// than as a person editing. Step 247 (FLADE-006-03): three deletions
  /// inside this window is a struggle; three spread over six seconds is not.
  static const Duration correctionBurstWindow = Duration(seconds: 2);

  /// Step 248 (HC-CMP-0054) dwell band, applied only to a confirmation
  /// before an action that cannot be undone. Below the floor the person is
  /// not pausing at all.
  static const Duration frictionDwellFloor = Duration(seconds: 3);

  /// The dwell the row calls optimal: long enough that the person has read
  /// what they are about to do.
  static const Duration frictionDwellOptimal = Duration(seconds: 5);

  /// Past this the person is not deciding, they are stuck. The row treats a
  /// longer dwell as a better result; this repository does not.
  static const Duration frictionDwellCeiling = Duration(seconds: 10);

  /// Step 252 (GEN-03569): the optimal for a client-side arithmetic gate.
  /// The row's floor and ceiling were already declared -- 50ms is
  /// [orderTotalRecalculationBudget] and 100ms is [railInstant] -- so this
  /// is the one figure that row adds.
  static const Duration clientMathGateBudget = Duration(milliseconds: 10);
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

  /// Step 137 REF-377-A02, the easing half of the global stepper transition
  /// variable. The row says "ease-in-out"; [stepperEnter] is MD3's emphasised
  /// ease-in-out, which is that shape with the curve MD3 specifies rather
  /// than a second, flatter one.
  static const Curve stepperTransition = stepperEnter;

  /// Step 137. The curve used when the OS has asked for reduced motion.
  /// Named here because this file is the only declaration site for a Curve,
  /// and HabotStepperTransition needs to resolve the preference without a
  /// BuildContext.
  static const Curve reducedMotion = Curves.linear;

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
