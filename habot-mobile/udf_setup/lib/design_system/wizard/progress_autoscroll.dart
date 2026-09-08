/// AISS Step 152 -- GEN-01584
/// Setup Step (Action) / Atomic Step: "Implement auto-scroll focus routines
///   that center the view on the active progress node upon status changes."
/// Metric: Real-Time Status Update Latency -- Floor "<30s", Optimal "<5s",
///         Ceiling "<60s". Good / Average / Poor.
///
/// **A MISMATCHED METRIC, READ HONESTLY.** The Atomic Step is a scroll
/// animation; the metric is a status-feed latency in SECONDS. Centring a node
/// takes one transition -- 200ms (Step 137) -- so the metric's optimal of "<5s"
/// is met by a factor of twenty-five, and reporting that as a triumph would be
/// reporting the wrong thing well.
///
/// The reading taken: the row's seconds bound the time from a STATUS CHANGE
/// ARRIVING to the user seeing it, which is the sum of the status arriving
/// (Steps 121-128: the socket, the heartbeat, the reconnect) and this
/// centring. This step owns only the second term, and it is reported as what
/// it is. The alternative -- treating 200ms as if it answered a 5-second
/// requirement -- would let a broken status pipeline hide behind a fast
/// animation.
///
/// **THE DEFECT THIS STEP MUST NOT INTRODUCE: SCROLLING THAT FIGHTS THE USER.**
/// An auto-scroll that fires on every status change moves the view while
/// someone is reading it. Two rules prevent that, and both are checkable:
/// nothing scrolls when the node is ALREADY fully visible, and nothing scrolls
/// while the user's own finger is on the list.
///
/// **REDUCED MOTION COLLAPSES THE ANIMATION, NOT THE BEHAVIOUR** (Step 137).
/// The node still ends up centred; it arrives immediately instead of gliding.
/// Skipping the centring entirely would leave a motion-sensitive user unable
/// to see which step they are on.
library;

import '../motion/stepper_transition.dart';
import '../tokens/motion_tokens.dart';

/// A row of progress nodes laid out along one axis.
class HabotProgressTrack {
  const HabotProgressTrack({
    required this.nodeCount,
    required this.nodeExtent,
    required this.nodeSpacing,
    required this.viewportExtent,
  });

  final int nodeCount;

  /// Size of one node along the scroll axis.
  final double nodeExtent;

  /// Gap between two nodes.
  final double nodeSpacing;

  /// How much of the track is on screen.
  final double viewportExtent;

  double get contentExtent => nodeCount <= 0
      ? 0
      : nodeCount * nodeExtent + (nodeCount - 1) * nodeSpacing;

  double get maxScrollExtent {
    final double over = contentExtent - viewportExtent;
    return over > 0 ? over : 0;
  }

  /// Where node [index] starts.
  double startOf(int index) => index * (nodeExtent + nodeSpacing);

  double endOf(int index) => startOf(index) + nodeExtent;

  bool get fitsWithoutScrolling => contentExtent <= viewportExtent;
}

/// What the controller decided to do.
class HabotScrollDecision {
  const HabotScrollDecision({
    required this.shouldScroll,
    required this.targetOffset,
    required this.duration,
    required this.reason,
  });

  final bool shouldScroll;
  final double targetOffset;
  final Duration duration;

  /// Why it did or did not move. Present so a decision not to scroll is
  /// evidence rather than absence.
  final String reason;
}

/// Centres the active progress node.
class HabotProgressAutoscroll {
  const HabotProgressAutoscroll._();

  /// The offset that puts node [index] in the middle of the viewport,
  /// clamped so the track cannot be scrolled past its own ends.
  static double centeredOffset(HabotProgressTrack track, int index) {
    if (track.nodeCount <= 0) {
      return 0;
    }
    final int i = index < 0
        ? 0
        : (index > track.nodeCount - 1 ? track.nodeCount - 1 : index);
    final double centre = track.startOf(i) + track.nodeExtent / 2;
    final double raw = centre - track.viewportExtent / 2;
    if (raw < 0) {
      return 0;
    }
    return raw > track.maxScrollExtent ? track.maxScrollExtent : raw;
  }

  /// Whether node [index] is already fully on screen at [currentOffset].
  static bool isFullyVisible(
    HabotProgressTrack track,
    int index,
    double currentOffset,
  ) =>
      track.startOf(index) >= currentOffset &&
      track.endOf(index) <= currentOffset + track.viewportExtent;

  /// Decide what to do when the active node changes.
  static HabotScrollDecision decide({
    required HabotProgressTrack track,
    required int activeIndex,
    required double currentOffset,
    required bool userIsDragging,
    required bool reducedMotion,
  }) {
    if (track.nodeCount <= 0) {
      return const HabotScrollDecision(
        shouldScroll: false,
        targetOffset: 0,
        duration: Duration.zero,
        reason: 'There is no track to scroll.',
      );
    }
    if (track.fitsWithoutScrolling) {
      return HabotScrollDecision(
        shouldScroll: false,
        targetOffset: currentOffset,
        duration: Duration.zero,
        reason: 'The whole track is on screen; centring would move a view '
            'that already shows everything.',
      );
    }
    if (userIsDragging) {
      return HabotScrollDecision(
        shouldScroll: false,
        targetOffset: currentOffset,
        duration: Duration.zero,
        reason: 'The user has a finger on the track. Scrolling under it is '
            'the defect this rule exists to prevent.',
      );
    }
    if (isFullyVisible(track, activeIndex, currentOffset)) {
      return HabotScrollDecision(
        shouldScroll: false,
        targetOffset: currentOffset,
        duration: Duration.zero,
        reason: 'The active node is already fully visible; moving the view '
            'would be motion with no information in it.',
      );
    }
    final HabotResolvedTransition t =
        HabotStepperTransition.resolveWith(reducedMotion: reducedMotion);
    return HabotScrollDecision(
      shouldScroll: true,
      targetOffset: centeredOffset(track, activeIndex),
      duration: t.duration,
      reason: reducedMotion
          ? 'Centring the active node immediately: the OS asked for reduced '
              'motion, so the node still arrives centred but does not glide.'
          : 'Centring the active node.',
    );
  }

  // ---- the row's metric ---------------------------------------------------

  /// The part of the row's latency this step owns: from the active node
  /// changing to the view having centred on it.
  static Duration centringLatency({required bool reducedMotion}) =>
      HabotStepperTransition.resolveWith(reducedMotion: reducedMotion)
          .duration;

  /// The row's band, applied to a full status-change-to-visible time. Takes
  /// the figure as an argument because this step owns only one term of it.
  static String bandFor(Duration statusToVisible) {
    if (statusToVisible <= HabotMotion.statusUpdateOptimal) {
      return 'Good';
    }
    if (statusToVisible <= HabotMotion.statusUpdateFloor) {
      return 'Average';
    }
    return statusToVisible <= HabotMotion.statusUpdateCeiling
        ? 'Average'
        : 'Poor';
  }

  static bool withinCeiling(Duration statusToVisible) =>
      statusToVisible <= HabotMotion.statusUpdateCeiling;

  static const String metricReadingNote =
      'The Atomic Step is a scroll animation and the metric is a status-feed '
      'latency in seconds. Centring takes one Step 137 transition -- 200ms -- '
      'so the optimal of "<5s" is met twenty-five times over, and reporting '
      'that as a triumph would be reporting the wrong thing well. The reading '
      'taken: the row bounds status-arrival plus centring, this step owns the '
      'second term only, and it is reported as that. Treating 200ms as an '
      'answer to a 5-second requirement would let a broken status pipeline '
      'hide behind a fast animation.';

  static const String doesNotFightTheUserNote =
      'Nothing scrolls when the active node is already fully visible, and '
      'nothing scrolls while the user has a finger on the track. An '
      'auto-scroll that fires on every status change moves the view while '
      'someone is reading it, which is a worse failure than not centring at '
      'all.';

  static const String reducedMotionNote =
      'Under reduced motion the animation collapses, not the behaviour: the '
      'node still ends up centred, it just arrives immediately. Skipping the '
      'centring would leave a motion-sensitive user unable to see which step '
      'they are on.';
}
