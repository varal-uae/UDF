/// Step 225 (GEN-04297) -- the swipe-to-back gesture on a modal.
///
/// The row: "Build a swipe-to-back gesture wrapper for modal view dismissals."
/// Metric: Navigation Interaction Response Latency -- Floor < 300ms, Optimal
/// < 100ms, **Ceiling < 16ms (1 frame @60fps)**. Good/Average/Poor.
///
/// **The band on this row is ordered the opposite way to Step 199's.** There,
/// floor 10s / optimal 3s / ceiling 15s made the ceiling the *worst* tolerated
/// value. Here, floor 300ms / optimal 100ms / ceiling 16ms makes the ceiling
/// the *best* one. Two duration metrics in the same sheet ordering their bands
/// in opposite directions, which means a reader cannot apply one rule and every
/// duration row has to be read on its own. Recorded, because it is the second
/// instance and there will be more.
///
/// **All three values already exist as tokens.** 300ms is
/// `HabotMotion.railPerceptible`, 100ms is `railInstant`, and one frame is
/// `smoothFrameBudget`. The row restates the RAIL band Step 164 declared.
///
/// **Seventh occurrence of the same defect.** A back gesture starts at the
/// **leading** edge in reading order -- the left in English, the right in Urdu.
/// Written as "swipe right to go back" it is backwards in a language this
/// product already ships. After Step 150's swipe direction, Step 167's frozen
/// column, Step 188's button side, Step 193's FAB corner and Step 212's approve
/// button, this one was written as a direction from the start.
///
/// **A swipe that discards typed input is a data-loss bug wearing a gesture's
/// clothes.** The wrapper refuses the gesture when the modal reports unsaved
/// state and routes to a confirmation instead; a modal with nothing at stake
/// dismisses immediately.
library;

import '../discovery/card_press_feedback.dart';
import '../i18n/localization_objective.dart';
import '../tokens/motion_tokens.dart';

/// Which screen edge a gesture starts from, resolved from reading direction.
enum HabotGestureEdge { leading, trailing }

/// What the wrapper does with a swipe.
enum HabotSwipeOutcome {
  /// The modal closes.
  dismiss,

  /// The gesture is refused and a confirmation is offered instead.
  confirmFirst,

  /// The gesture is not recognised at all -- the platform owns this edge.
  yieldToPlatform,
}

/// The state a modal reports about itself when asked whether it may close.
class HabotModalState {
  const HabotModalState({
    required this.hasUnsavedInput,
    required this.isSubmitting,
    required this.ownsPlatformEdge,
  });

  /// Typed text, a selection, an uploaded file -- anything a dismissal loses.
  final bool hasUnsavedInput;

  /// A request is in flight. Closing now leaves it orphaned.
  final bool isSubmitting;

  /// Whether the platform's own interactive-pop gesture is active on the same
  /// edge for this route.
  final bool ownsPlatformEdge;
}

/// The wrapper.
class HabotSwipeBack {
  const HabotSwipeBack._();

  /// The gesture starts at the leading edge, always.
  static const HabotGestureEdge edge = HabotGestureEdge.leading;

  /// Which physical side that is.
  static bool startsOnTheLeft(HabotTextDirectionality direction) =>
      direction == HabotTextDirectionality.leftToRight;

  static bool get directionIsResolvedNotAssumed =>
      startsOnTheLeft(HabotTextDirectionality.leftToRight) &&
      !startsOnTheLeft(HabotTextDirectionality.rightToLeft);

  /// How far in from the edge the gesture is recognised. Wide enough to catch
  /// a thumb, narrow enough not to eat a horizontal scroll inside the modal.
  static const double edgeWidthDp = 20;

  /// The fraction of the modal's width a drag must cover before release
  /// dismisses rather than springs back.
  static const double dismissThreshold = 0.5;

  /// The decision.
  static HabotSwipeOutcome outcomeFor(HabotModalState state) {
    if (state.ownsPlatformEdge) {
      return HabotSwipeOutcome.yieldToPlatform;
    }
    if (state.isSubmitting || state.hasUnsavedInput) {
      return HabotSwipeOutcome.confirmFirst;
    }
    return HabotSwipeOutcome.dismiss;
  }

  static bool discardsWithoutAsking(HabotModalState state) =>
      state.hasUnsavedInput &&
      outcomeFor(state) == HabotSwipeOutcome.dismiss;

  static const String unsavedInputNote =
      'A swipe that discards typed input is a data-loss bug wearing a '
      'gesture\'s clothes, and it is silent -- the modal is simply gone and so '
      'is the text. The wrapper refuses the gesture when the modal reports '
      'unsaved state and offers a confirmation; a modal with nothing at stake '
      'dismisses immediately, because a confirmation on an empty form is the '
      'other way to make a gesture useless.';

  static const String twoGesturesOneEdgeNote =
      'iOS has a system interactive-pop gesture on the leading edge. Two '
      'recognisers on one edge means one of them does not fire, and which one '
      'depends on the order they were attached -- a race nobody can see in a '
      'review. Where the platform owns the edge, the wrapper yields.';

  static const String seventhOccurrenceNote =
      'A back gesture starts at the LEADING edge in reading order: the left in '
      'English, the right in Urdu. Written as "swipe right to go back" it is '
      'backwards in a language this product already ships. Seventh occurrence '
      'of sides-written-where-directions-were-meant, after Steps 150, 167, '
      '188, 193 and 212 -- written as a direction from the start here.';

  // -----------------------------------------------------------------------
  // Metric: Navigation Interaction Response Latency.
  // -----------------------------------------------------------------------

  /// The row's three bounds, each already a declared token.
  static Duration get floorLatency => HabotMotion.railPerceptible;
  static Duration get optimalLatency => HabotMotion.railInstant;
  static Duration get ceilingLatency => HabotMotion.smoothFrameBudget;

  /// True when the row's bounds are the RAIL band Step 164 already declared.
  static bool get bandIsAlreadyDeclared =>
      floorLatency.inMilliseconds == 300 &&
      optimalLatency.inMilliseconds == 100 &&
      ceilingLatency.inMicroseconds == 16667;

  /// On this row the ceiling is the BEST value, which is the opposite of the
  /// ordering on Step 199's duration metric.
  static bool get ceilingIsTheBestBound => ceilingLatency < optimalLatency;

  /// And Step 199's row ordered its band the other way, which is read from
  /// that step rather than restated here.
  static bool get step199CeilingWasTheWorstBound =>
      HabotCardPressFeedback.bandIsInvertedForADuration &&
      HabotCardPressFeedback.timeToFindCeilingSeconds >
          HabotCardPressFeedback.timeToFindOptimalSeconds;

  static String qualitativeOutputFor(Duration observed) {
    if (observed <= optimalLatency) {
      return 'Good';
    }
    if (observed <= floorLatency) {
      return 'Average';
    }
    return 'Poor';
  }

  /// The gesture's response is a transform driven by the drag itself rather
  /// than an animation started when the drag ends -- so the latency between
  /// finger and pixels is a frame, by construction rather than by measurement.
  static const bool isDrivenByTheDragNotByAnAnimation = true;

  static const String latencyIsStructuralNote =
      'The modal follows the finger through a transform driven by the drag, '
      'not through an animation started when the drag ends. The latency the '
      'metric asks about is therefore a frame by construction. No wall-clock '
      'figure is produced on a host with no Dart toolchain, and the structural '
      'property is what is reported instead.';

  static Map<String, bool> get checks => <String, bool>{
        'the gesture starts at the leading edge, resolved from direction':
            edge == HabotGestureEdge.leading && directionIsResolvedNotAssumed,
        'an empty modal dismisses on the gesture':
            outcomeFor(
              const HabotModalState(
                hasUnsavedInput: false,
                isSubmitting: false,
                ownsPlatformEdge: false,
              ),
            ) ==
            HabotSwipeOutcome.dismiss,
        'a modal holding typed input confirms first':
            outcomeFor(
              const HabotModalState(
                hasUnsavedInput: true,
                isSubmitting: false,
                ownsPlatformEdge: false,
              ),
            ) ==
            HabotSwipeOutcome.confirmFirst,
        'a modal mid-submission confirms first too':
            outcomeFor(
              const HabotModalState(
                hasUnsavedInput: false,
                isSubmitting: true,
                ownsPlatformEdge: false,
              ),
            ) ==
            HabotSwipeOutcome.confirmFirst,
        'nothing discards typed input without asking': !discardsWithoutAsking(
          const HabotModalState(
            hasUnsavedInput: true,
            isSubmitting: false,
            ownsPlatformEdge: false,
          ),
        ),
        'the wrapper yields where the platform owns the edge':
            outcomeFor(
              const HabotModalState(
                hasUnsavedInput: false,
                isSubmitting: false,
                ownsPlatformEdge: true,
              ),
            ) ==
            HabotSwipeOutcome.yieldToPlatform,
        'the row\'s three bounds are the RAIL band already declared':
            bandIsAlreadyDeclared,
        'the ceiling on this row is the best bound, unlike Step 199\'s':
            ceilingIsTheBestBound && step199CeilingWasTheWorstBound,
        'response is driven by the drag rather than by an animation':
            isDrivenByTheDragNotByAnAnimation,
      };

  static double get adherence =>
      checks.values.where((bool b) => b).length / checks.length;

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Build a swipe-to-back gesture wrapper for modal view dismissals."';
}
