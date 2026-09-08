/// AISS Step 150 -- GEN-01396
/// Setup Step (Action) / Atomic Step: "Implement swipe gesture controllers to
///   allow transitions between wizard Byt views."
/// Metric: Entity Decomposition Structural Integrity -- Floor 0.95,
///         Optimal 1.0, Ceiling 1.0. Pass / Fail.
///
/// **THE FINDING THIS STEP EXISTS TO HONOUR.** Step 138 put Urdu in scope;
/// Step 146 traced the consequence: a wizard hardcoded to "swipe left for
/// next" advances BACKWARDS in a right-to-left language. A swipe is a physical
/// direction; "next" is a semantic one; the mapping between them is exactly
/// what reverses. [HabotSwipeController.intentOf] is the one place that
/// mapping exists, so no screen can get it wrong and every screen changes at
/// once when the language does.
///
/// **A REFUSED SWIPE MUST SAY SO** (Step 146, F-2). A forward swipe past an
/// unsatisfied step is refused for the same reason a Next tap is -- but a tap
/// that does nothing looks like a refusal, while a swipe that does nothing
/// looks like the app has frozen. Users force-quit frozen apps, and a
/// force-quit mid-form is precisely the loss Step 153 exists to prevent,
/// arriving through a different door. So a refused swipe returns the same
/// [HabotNavigationOutcome] a refused tap does, carrying the same message key.
///
/// **A HORIZONTAL SWIPE CANNOT SHARE A SCREEN WITH A HORIZONTAL SCROLL**
/// (Step 146, F-5). This app already has a horizontally scrolling surface --
/// the sticky-column table. Two horizontal gestures on one screen means one of
/// them loses, and which one is decided by widget order rather than by intent.
/// [HabotSwipeController.gestureConflicts] makes that a declared, checkable
/// property of a step rather than something a user discovers.
///
/// THRESHOLDS ARE STATED, NOT TUNED BY FEEL. A gesture is a page change when
/// it travels far enough OR fast enough; both, because a short flick and a
/// slow drag are both deliberate, and requiring both would reject half of each.
library;

import '../i18n/localization_objective.dart';
import 'step_machine.dart';
import 'wizard_navigation.dart';

/// The physical direction of a horizontal drag.
enum HabotSwipeDirection { towardsStart, towardsEnd }

/// What the user meant by it, once direction is resolved.
enum HabotSwipeIntent { forward, backward }

/// A completed horizontal gesture.
class HabotSwipeGesture {
  const HabotSwipeGesture({
    required this.horizontalDelta,
    required this.velocityPixelsPerSecond,
  });

  /// Positive is a drag towards increasing x (rightwards on screen).
  final double horizontalDelta;

  /// Signed, same convention as [horizontalDelta].
  final double velocityPixelsPerSecond;

  HabotSwipeDirection get direction => horizontalDelta < 0
      ? HabotSwipeDirection.towardsEnd
      : HabotSwipeDirection.towardsStart;
}

/// Turns gestures into wizard transitions.
class HabotSwipeController {
  const HabotSwipeController({
    required this.navigation,
    required this.direction,
  });

  final HabotWizardNavigation navigation;
  final HabotTextDirectionality direction;

  /// How far a drag must travel to count, in logical pixels.
  static const double distanceThresholdDp = 64;

  /// Or how fast it must be moving when it is released.
  static const double velocityThreshold = 300;

  bool get isRightToLeft =>
      direction == HabotTextDirectionality.rightToLeft;

  /// **The mapping.** In a left-to-right language a drag whose content moves
  /// leftwards reveals the NEXT page. In a right-to-left language it reveals
  /// the previous one. This is the whole of Step 146's finding F-1, and it
  /// exists in exactly one place.
  ///
  /// Static as well as instance, so the four direction cases can be checked
  /// without building a step machine -- a mapping that could only be tested
  /// through a whole wizard would be tested less often.
  static HabotSwipeIntent intentFor(
    HabotSwipeDirection swipe,
    HabotTextDirectionality textDirection,
  ) {
    final bool towardsEnd = swipe == HabotSwipeDirection.towardsEnd;
    if (textDirection == HabotTextDirectionality.rightToLeft) {
      return towardsEnd
          ? HabotSwipeIntent.backward
          : HabotSwipeIntent.forward;
    }
    return towardsEnd ? HabotSwipeIntent.forward : HabotSwipeIntent.backward;
  }

  HabotSwipeIntent intentOf(HabotSwipeDirection swipe) =>
      intentFor(swipe, direction);

  /// Whether a gesture is decisive enough to change page.
  static bool isDecisive(HabotSwipeGesture g) =>
      g.horizontalDelta.abs() >= distanceThresholdDp ||
      g.velocityPixelsPerSecond.abs() >= velocityThreshold;

  /// Apply a gesture.
  ///
  /// An indecisive gesture is not a refusal -- it is not a page change at all,
  /// so it returns [HabotNavigationOutcome] with no block reason and the page
  /// springs back. Conflating "you did not swipe far enough" with "you may not
  /// go forward" would put a validation message on screen for a stray finger.
  HabotNavigationOutcome apply(HabotSwipeGesture gesture) {
    if (!isDecisive(gesture)) {
      return HabotNavigationOutcome(
        moved: false,
        index: navigation.machine.index,
        blockedBy: StepBlockReason.none,
      );
    }
    switch (intentOf(gesture.direction)) {
      case HabotSwipeIntent.forward:
        return navigation.forward();
      case HabotSwipeIntent.backward:
        return navigation.backward();
    }
  }

  /// Whether a step's content would fight the page gesture.
  ///
  /// Declared per step rather than discovered at runtime: a step that contains
  /// a horizontally scrolling child cannot also be swiped, and the correct
  /// resolution is to turn the page gesture off for that step and rely on the
  /// buttons -- not to let widget order decide.
  static bool gestureConflicts({required bool stepScrollsHorizontally}) =>
      stepScrollsHorizontally;

  /// Steps where the page gesture must be disabled.
  static List<String> conflictingSteps(
    Map<String, bool> stepsWithHorizontalScroll,
  ) =>
      stepsWithHorizontalScroll.entries
          .where((MapEntry<String, bool> e) =>
              gestureConflicts(stepScrollsHorizontally: e.value))
          .map((MapEntry<String, bool> e) => e.key)
          .toList();

  // ---- the row's metric ---------------------------------------------------

  /// The direction mapping, checked over every combination rather than
  /// asserted for one. Four cases, and getting any of them wrong is the
  /// defect this step exists to prevent.
  static Map<String, bool> directionIntegrity() {
    const HabotTextDirectionality ltr = HabotTextDirectionality.leftToRight;
    const HabotTextDirectionality rtl = HabotTextDirectionality.rightToLeft;
    return <String, bool>{
      'ltr: dragging content towards the end goes forward':
          intentFor(HabotSwipeDirection.towardsEnd, ltr) ==
              HabotSwipeIntent.forward,
      'ltr: dragging content towards the start goes back':
          intentFor(HabotSwipeDirection.towardsStart, ltr) ==
              HabotSwipeIntent.backward,
      'rtl: dragging content towards the end goes BACK':
          intentFor(HabotSwipeDirection.towardsEnd, rtl) ==
              HabotSwipeIntent.backward,
      'rtl: dragging content towards the start goes FORWARD':
          intentFor(HabotSwipeDirection.towardsStart, rtl) ==
              HabotSwipeIntent.forward,
      'the two directions are mirror images of each other':
          intentFor(HabotSwipeDirection.towardsEnd, ltr) !=
              intentFor(HabotSwipeDirection.towardsEnd, rtl),
    };
  }

  static double get directionalIntegrity {
    final Iterable<bool> r = directionIntegrity().values;
    return r.where((bool b) => b).length / r.length;
  }

  static List<String> get directionalFailures => directionIntegrity()
      .entries
      .where((MapEntry<String, bool> e) => !e.value)
      .map((MapEntry<String, bool> e) => e.key)
      .toList();

  static const double floor = 0.95;
  static const double optimal = 1.0;

  static const String directionMappingNote =
      'A swipe is a physical direction; "next" is a semantic one. In a '
      'right-to-left language the mapping between them reverses, so a wizard '
      'hardcoded to "swipe left for next" advances backwards in Urdu. The '
      'mapping exists in exactly one method, so no screen can get it wrong and '
      'every screen changes at once when the language does.';

  static const String silentRefusalNote =
      'A tap that does nothing looks like a refusal; a swipe that does nothing '
      'looks like the app has frozen. Users force-quit frozen apps, and a '
      'force-quit mid-form is the loss Step 153 exists to prevent arriving '
      'through a different door. A refused swipe returns the same outcome a '
      'refused tap does, carrying the same message key -- while an INDECISIVE '
      'swipe returns no refusal at all, because "you did not swipe far enough" '
      'is not "you may not go forward".';

  static const String gestureConflictNote =
      'A horizontally swipeable page cannot contain a horizontally scrolling '
      'child without the two gestures competing, and this app already has one '
      '-- the sticky-column table. Which gesture wins would otherwise be '
      'decided by widget order rather than by intent, so a step declares '
      'whether it scrolls horizontally and the page gesture is turned off '
      'there, leaving the buttons.';
}
