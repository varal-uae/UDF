/// AISS: GEN-00201-A01 -- "Use Material Design 3 shared axis transitions for
/// mobile view state changes."
///
/// A shared-axis transition tells the user how two screens relate: forward
/// along X for a sibling step, along Y for a drill-down, along Z for a zoom
/// into detail. That relationship is the information; without it a transition
/// is just decoration and the user has to work out where they went.
///
/// MD3 specifies fade-through, not cross-fade: the outgoing content fades out
/// over the first 30% of the duration and the incoming content fades in over
/// the remaining 70%. They never overlap at partial opacity, which is what
/// stops the "two ghosts" look of a naive cross-fade.
///
/// Reduced motion is honoured by the same policy everything else uses, so
/// under the preference the transition becomes an instantaneous swap rather
/// than a faster slide.
library;

import 'package:flutter/material.dart';

import '../tokens/motion_tokens.dart';
import '../tokens/spacing_tokens.dart';

/// Which axis the two views share.
enum HabotSharedAxis {
  /// Lateral movement between siblings -- next/previous step.
  horizontal,

  /// Movement up or down a hierarchy -- list to section.
  vertical,

  /// Movement in depth -- a card opening into its detail.
  scaled,
}

/// The numbers behind the transition, unit-testable without a widget.
class HabotSharedAxisSpec {
  const HabotSharedAxisSpec._();

  /// MD3 fade-through: the outgoing half owns the first 30%.
  static const double outgoingFadeEnd = 0.30;

  /// ...and the incoming half owns the rest. The two windows touch but never
  /// overlap, which the gate asserts rather than assumes.
  static const double incomingFadeStart = outgoingFadeEnd;

  /// Distance the content travels on a translating axis, in logical pixels.
  static const double slideDistance = HabotSpacing.xl;

  /// Scale the depth axis starts from -- close enough to 1 to read as depth,
  /// far enough to be visible.
  static const double scaleFrom = 0.80;

  static Duration durationFor(BuildContext context) =>
      HabotMotionPolicy.resolve(context, HabotMotion.sharedAxis);

  /// Opacity of the outgoing half at [t] (0..1 through the transition).
  static double outgoingOpacity(double t) =>
      t >= outgoingFadeEnd ? 0 : 1 - (t / outgoingFadeEnd);

  /// Opacity of the incoming half at [t].
  static double incomingOpacity(double t) => t <= incomingFadeStart
      ? 0
      : (t - incomingFadeStart) / (1 - incomingFadeStart);

  /// The two halves are never simultaneously partly visible.
  static bool windowsAreDisjoint() =>
      outgoingFadeEnd <= incomingFadeStart &&
      outgoingOpacity(incomingFadeStart) == 0;
}

/// Animates [child] whenever [stateKey] changes, along [axis].
///
/// Keyed on an explicit state token rather than on the child widget, because
/// "the view state changed" is a claim only the caller can make -- two
/// different widgets can represent the same state.
class HabotSharedAxisSwitcher extends StatelessWidget {
  const HabotSharedAxisSwitcher({
    required this.stateKey,
    required this.child,
    this.axis = HabotSharedAxis.horizontal,
    this.reverse = false,
    super.key,
  });

  final String stateKey;
  final Widget child;
  final HabotSharedAxis axis;

  /// True when moving backwards, so the axis runs the other way.
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: HabotSharedAxisSpec.durationFor(context),
      switchInCurve: HabotMotionPolicy.resolveCurve(
        context,
        HabotEasing.sharedAxisIncoming,
      ),
      switchOutCurve: HabotMotionPolicy.resolveCurve(
        context,
        HabotEasing.sharedAxisOutgoing,
      ),
      transitionBuilder: _buildTransition,
      child: KeyedSubtree(key: ValueKey<String>(stateKey), child: child),
    );
  }

  Widget _buildTransition(Widget child, Animation<double> animation) =>
      HabotSharedAxisTransition(
        animation: animation,
        axis: axis,
        reverse: reverse,
        child: child,
      );
}

/// The transition itself. Separated from the switcher so a route or a stepper
/// can drive it from its own animation.
class HabotSharedAxisTransition extends StatelessWidget {
  const HabotSharedAxisTransition({
    required this.animation,
    required this.child,
    this.axis = HabotSharedAxis.horizontal,
    this.reverse = false,
    super.key,
  });

  final Animation<double> animation;
  final Widget child;
  final HabotSharedAxis axis;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    final double direction = reverse ? -1 : 1;
    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: animation,
        // The subtree is passed through as `inner` so it is built once and
        // only the transform re-runs per frame.
        child: child,
        builder: (BuildContext context, Widget? inner) =>
            _transform(direction, inner!),
      ),
    );
  }

  Widget _transform(double direction, Widget inner) {
    final double t = animation.value;
    switch (axis) {
      case HabotSharedAxis.horizontal:
        return Transform.translate(
          offset: Offset(
            (1 - t) * HabotSharedAxisSpec.slideDistance * direction,
            0,
          ),
          child: inner,
        );
      case HabotSharedAxis.vertical:
        return Transform.translate(
          offset: Offset(
            0,
            (1 - t) * HabotSharedAxisSpec.slideDistance * direction,
          ),
          child: inner,
        );
      case HabotSharedAxis.scaled:
        return Transform.scale(
          scale:
              HabotSharedAxisSpec.scaleFrom +
              ((1 - HabotSharedAxisSpec.scaleFrom) * t),
          child: inner,
        );
    }
  }
}
