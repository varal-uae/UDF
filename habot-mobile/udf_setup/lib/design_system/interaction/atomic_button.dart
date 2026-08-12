/// AISS: BPTR-0128-A01 -- "Establish Global Atomic Byt Micro-Interaction
/// Boundaries."
///
/// Substep 2: "Build an abstract, pure AtomicButton component under 20 lines of
///             total functional code."
/// Substep 3: "Code dynamic visual feedback systems simulating rapid
///             interactive state states (active, focus, hover)."
/// Substep 4: "Implement performance-tuned passive touch listeners directly to
///             eradicate 300ms mobile touch-click delays completely."
///
/// Flutter translation note on substep 4: the 300ms tap delay is a *mobile web
/// browser* behaviour, caused by the browser waiting to see whether a tap is
/// the first half of a double-tap-to-zoom. Flutter's gesture arena has no such
/// delay on any target -- a tap resolves as soon as no competing recogniser
/// claims it. The equivalent obligation here is therefore to add no artificial
/// delay of our own, which `BPTR-0128-G4` asserts by measuring the time from
/// pointer-down to callback.
///
/// Poka-Yoke: "compiler constraints instantly flag compile errors if a
/// developer creates a clickable component without specifying explicit touch
/// padding parameters." Dart has no such compiler rule, so the equivalents are
/// a required constructor argument (you cannot omit it) plus a constructor
/// assert on the value.
library;

import 'package:flutter/material.dart';

import '../tokens/spacing_tokens.dart';
import 'interaction_states.dart';

/// The single interactive primitive. Every call-to-action in the app is built
/// from this; nothing else may attach a tap handler.
class AtomicButton extends StatelessWidget {
  const AtomicButton({
    required this.child,
    required this.semanticLabel,
    required this.touchPadding,
    this.onPressed,
    this.onLongPress,
    super.key,
  }) : assert(
         touchPadding >= 0,
         'BPTR-0128: touch padding may not be negative.',
       );

  final Widget child;
  final String semanticLabel;

  /// Required, never defaulted. Poka-Yoke substitute: you cannot construct a
  /// clickable component without stating its touch padding.
  final double touchPadding;

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  /// Convenience for the common case -- the standard safety boundary.
  static const double standardTouchPadding = HabotDensity.touchSafetyMargin;

  // BUILD-BUDGET: BPTR-0128 substep 2 caps this method at 20 lines.
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: InteractionStateBuilder(
        onPressed: onPressed,
        onLongPress: onLongPress,
        minTarget: HabotDensity.minTouchTarget,
        touchPadding: touchPadding,
        builder: (BuildContext context, HabotInteractionState state) =>
            InteractionStateLayer(state: state, child: child),
      ),
    );
  }
}
