// BPTR-0319-A11 — Minimum 48dp Touch Target Enforcer.
// Enforces 48x48dp interactive areas for all tappable atoms; prevents accidental clicks and keeps controls thumb-friendly.
import 'package:flutter/material.dart';

/// Minimum touch target size per Material Design accessibility guidance.
const double kMinTouchTargetSize = 48.0;

/// Wraps [child] with a minimum 48x48dp interactive area.
/// Use for buttons, toggles, icon buttons, checkboxes, and other tappable atoms.
class MinTouchTarget extends StatelessWidget {
  const MinTouchTarget({super.key, required this.child, this.semanticLabel});

  final Widget child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final Widget content = semanticLabel == null
        ? child
        : Semantics(label: semanticLabel, button: true, child: child);

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: kMinTouchTargetSize,
        minHeight: kMinTouchTargetSize,
      ),
      child: content,
    );
  }
}

/// Extension to quickly enforce 48dp minimum touch targets on any widget.
extension TouchTargetX on Widget {
  Widget minTouchTarget({String? semanticLabel}) =>
      MinTouchTarget(semanticLabel: semanticLabel, child: this);
}
