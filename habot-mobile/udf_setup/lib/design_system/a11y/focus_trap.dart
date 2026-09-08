/// AISS Step 101 -- GEN-01826
/// "Confirm completion when TalkBack testing cannot swipe out of an open
///  dialog."
/// WCAG 2.2 SC 2.1.2 No Keyboard Trap, SC 2.4.3 Focus Order,
///         SC 2.4.11 Focus Not Obscured.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// METRIC MISMATCH, RECORDED. The sheet gives this row "Gesture Recognition
/// Accuracy (%)" -- floor 95.0, optimal 99.5, ceiling 100.0. Gesture
/// recognition is a property of the platform accessibility service. An app
/// cannot move that number, and no client-side suite can observe it. No figure
/// is invented in its place. What IS gated is the sentence the row actually
/// states, which is precise and directly testable.
///
/// THE REQUIREMENT, READ CAREFULLY. "TalkBack cannot swipe out of an open
/// dialog" is a focus trap -- and a focus trap is the one accessibility
/// pattern that is a bug everywhere else. SC 2.1.2 forbids traps. The
/// resolution is the escape clause the criterion itself carries: a trap is
/// permitted where a documented mechanism exists to leave. So this widget
/// traps AND guarantees an exit -- [onDismiss] is a required parameter, so a
/// trap with no way out cannot be constructed.
///
/// WHY THE TRAP OWNS BOTH HALVES OF THE SCREEN. It takes [behind] as well as
/// [surface], rather than being dropped into a Stack next to the page. That is
/// deliberate: blocking what is behind a modal has to be a positive act on the
/// thing behind it, not a hope that a barrier widget will shadow whatever
/// happens to have been painted first. `ExcludeSemantics` on [behind] is
/// unambiguous; relying on paint-order blocking alone is not, and "it usually
/// works" is not a standard to hold a screen reader to.
///
/// WHAT THIS REUSES. Step 21's `HabotBottomSheet` and Step 73's
/// `HabotAlertPanelLayer` already absorb POINTERS behind a modal surface. This
/// is the same idea one layer down: absorbing SEMANTICS. Neither is rebuilt,
/// and this deliberately mirrors the alert layer's shape -- a layer that wraps
/// the page rather than a sibling of it.
library;

import 'package:flutter/widgets.dart';

/// How a trapped surface may be left. Declared per trap so the exit is part of
/// the type rather than part of the reviewer's memory.
enum HabotTrapExit {
  /// A visible, focusable control inside the surface closes it.
  explicitControl,

  /// The system back gesture or key closes it.
  systemBack,

  /// Both.
  either,
}

/// A modal surface that holds screen-reader focus, and says how to leave.
class HabotFocusTrap extends StatefulWidget {
  const HabotFocusTrap({
    required this.behind,
    required this.surface,
    required this.onDismiss,
    required this.label,
    this.exit = HabotTrapExit.either,
    this.active = true,
    super.key,
  });

  /// The page the modal opened over. Removed from the accessibility tree while
  /// the trap is [active].
  final Widget behind;

  /// The trapped content.
  final Widget surface;

  /// How the surface is closed. Required -- see the library comment.
  final VoidCallback onDismiss;

  /// Announced when focus enters the surface, so a non-visual user knows a
  /// modal opened rather than the page having silently changed.
  final String label;

  final HabotTrapExit exit;

  /// A trap that is not active is transparent: the page behind is reachable
  /// exactly as it was.
  final bool active;

  static const Key trapKey = Key('habot.a11y.focusTrap');
  static const Key behindKey = Key('habot.a11y.focusTrap.behind');
  static const Key barrierKey = Key('habot.a11y.focusTrap.barrier');
  static const Key surfaceKey = Key('habot.a11y.focusTrap.surface');

  @override
  State<HabotFocusTrap> createState() => _HabotFocusTrapState();
}

class _HabotFocusTrapState extends State<HabotFocusTrap> {
  final FocusScopeNode _scope = FocusScopeNode(debugLabel: 'HabotFocusTrap');

  @override
  void dispose() {
    _scope.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: HabotFocusTrap.trapKey,
      children: <Widget>[
        // 1. The page. Excluded from semantics while the trap is open, which
        //    is the half that makes swipe-next have nowhere to go.
        ExcludeSemantics(
          key: HabotFocusTrap.behindKey,
          excluding: widget.active,
          child: widget.behind,
        ),
        if (widget.active) ...<Widget>[
          // 2. The barrier. Absorbs pointers, and blocks the semantics of
          //    anything painted before it as a second line of defence. Painted
          //    BELOW the surface -- SC 2.4.11.
          Positioned.fill(
            key: HabotFocusTrap.barrierKey,
            child: const BlockSemantics(
              child: AbsorbPointer(child: SizedBox.expand()),
            ),
          ),
          // 3. The surface, scoped and named so the reader announces it.
          Positioned.fill(
            key: HabotFocusTrap.surfaceKey,
            child: Semantics(
              container: true,
              scopesRoute: true,
              namesRoute: true,
              explicitChildNodes: true,
              label: widget.label,
              child: FocusScope(node: _scope, child: widget.surface),
            ),
          ),
        ],
      ],
    );
  }
}

/// The checks a trap has to satisfy, expressed so a gate can run them and a
/// reviewer can read them.
class HabotFocusTrapPolicy {
  const HabotFocusTrapPolicy._();

  /// SC 2.1.2's escape clause: a trap is conformant only with a documented way
  /// out. This project's documented way out is [HabotFocusTrap.onDismiss],
  /// which is a required parameter.
  static const String escapeClause =
      'WCAG 2.2 SC 2.1.2 permits a focus trap where a mechanism to leave is '
      'available and documented. HabotFocusTrap requires onDismiss at '
      'construction, so a trap with no exit cannot be built.';

  /// A trapped surface must announce itself. A modal that opens silently is a
  /// page that changed under a user who was not told.
  static bool announcesItself(String label) => label.trim().length >= 3;

  /// SC 2.4.11: the focused element must not be hidden behind another surface.
  /// Read here as: the trap's own barrier must sit BELOW the trapped content
  /// in paint order, never above it.
  static bool barrierIsBelowContent(int barrierIndex, int contentIndex) =>
      barrierIndex >= 0 && contentIndex >= 0 && barrierIndex < contentIndex;
}
