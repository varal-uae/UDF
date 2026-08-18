/// AISS: BPTR-0128-A01 substep 3 -- "Code dynamic visual feedback systems
/// simulating rapid interactive state states (active, focus, hover)."
/// AISS: TTMAC-014-A01 -- "Include clear visual feedback states immediately
/// upon registering a tap action" and "Apply clean background expansion effects
/// to indicate successful button activations."
///
/// Material 3 state layers: a translucent overlay of the content colour, at an
/// opacity that depends on the interaction state. Encoded once here so no
/// component invents its own hover tint.
library;

import 'package:flutter/material.dart';

import '../tokens/motion_tokens.dart';
import '../tokens/shape_tokens.dart';
import '../tokens/spacing_tokens.dart';

/// The interaction states MD3 defines a state-layer opacity for.
enum HabotInteractionState { enabled, hovered, focused, pressed, disabled }

/// MD3 state-layer opacities. These are the published Material 3 values.
class HabotStateLayer {
  const HabotStateLayer._();

  static const double enabled = 0.0;
  static const double hovered = 0.08;
  static const double focused = 0.10;
  static const double pressed = 0.10;
  static const double disabled = 0.0;

  /// Content opacity when the control is disabled (MD3 uses 38%).
  static const double disabledContentOpacity = 0.38;

  static const Map<HabotInteractionState, double> opacity =
      <HabotInteractionState, double>{
        HabotInteractionState.enabled: enabled,
        HabotInteractionState.hovered: hovered,
        HabotInteractionState.focused: focused,
        HabotInteractionState.pressed: pressed,
        HabotInteractionState.disabled: disabled,
      };

  static double opacityFor(HabotInteractionState state) => opacity[state]!;
}

/// Tracks pointer and focus state and hands the resolved
/// [HabotInteractionState] to a builder, guaranteeing the minimum target size
/// and safety padding while doing so.
class InteractionStateBuilder extends StatefulWidget {
  const InteractionStateBuilder({
    required this.builder,
    required this.minTarget,
    required this.touchPadding,
    this.onPressed,
    this.onLongPress,
    super.key,
  });

  final Widget Function(BuildContext, HabotInteractionState) builder;
  final double minTarget;
  final double touchPadding;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  @override
  State<InteractionStateBuilder> createState() =>
      _InteractionStateBuilderState();
}

class _InteractionStateBuilderState extends State<InteractionStateBuilder> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  HabotInteractionState get _state {
    if (widget.onPressed == null && widget.onLongPress == null) {
      return HabotInteractionState.disabled;
    }
    if (_pressed) {
      return HabotInteractionState.pressed;
    }
    if (_focused) {
      return HabotInteractionState.focused;
    }
    if (_hovered) {
      return HabotInteractionState.hovered;
    }
    return HabotInteractionState.enabled;
  }

  void _set(void Function() mutate) {
    if (!mounted) {
      return;
    }
    setState(mutate);
  }

  @override
  Widget build(BuildContext context) {
    final bool interactive =
        widget.onPressed != null || widget.onLongPress != null;

    return FocusableActionDetector(
      enabled: interactive,
      onShowHoverHighlight: (bool v) => _set(() => _hovered = v),
      onShowFocusHighlight: (bool v) => _set(() => _focused = v),
      mouseCursor: interactive
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Substep 4 equivalent: the tap fires on the raw pointer events with no
        // artificial delay of our own layered on top.
        onTapDown: interactive ? (TapDownDetails _) => _set(() => _pressed = true) : null,
        onTapCancel: interactive ? () => _set(() => _pressed = false) : null,
        onTapUp: interactive
            ? (TapUpDetails _) {
                _set(() => _pressed = false);
                widget.onPressed?.call();
              }
            : null,
        onLongPress: widget.onLongPress,
        child: Padding(
          padding: EdgeInsets.all(widget.touchPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: widget.minTarget,
              minHeight: widget.minTarget,
            ),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: widget.builder(context, _state),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the MD3 state layer over [child] and animates between states.
class InteractionStateLayer extends StatelessWidget {
  const InteractionStateLayer({
    required this.state,
    required this.child,
    super.key,
  });

  final HabotInteractionState state;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double layerOpacity = HabotStateLayer.opacityFor(state);
    final bool disabled = state == HabotInteractionState.disabled;

    return AnimatedContainer(
      // Reduced motion is honoured here, once, for every control in the app.
      duration: HabotMotionPolicy.resolve(context, HabotMotion.fast),
      curve: HabotMotionPolicy.resolveCurve(context, HabotEasing.standard),
      padding: const EdgeInsets.all(HabotSpacing.xxs),
      decoration: BoxDecoration(
        color: scheme.onSurface.withValues(alpha: layerOpacity),
        borderRadius: BorderRadius.circular(HabotShape.full),
      ),
      child: Opacity(
        opacity: disabled ? HabotStateLayer.disabledContentOpacity : 1.0,
        child: child,
      ),
    );
  }
}
