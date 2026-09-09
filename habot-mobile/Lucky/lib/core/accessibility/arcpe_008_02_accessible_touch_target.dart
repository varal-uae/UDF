// ARCPE-008-02 — AccessibleTouchTarget wrapper enforcing WCAG 2.1 AA 48dp touch targets and semantic labels.
// Provides a reusable Material 3 component that ensures interactive elements meet minimum touch size, with optional tap handling and accessibility semantics.
import 'package:flutter/material.dart';

/// A wrapper that enforces the optimal 48x48 logical pixel touch target
/// (WCAG 2.1 AA / Google Material Design 3) around its child.
///
/// If [onTap] is provided, the target becomes interactive and uses
/// [InkWell] to provide visual feedback; otherwise it simply constrains
/// the size and merges semantics.
class AccessibleTouchTarget extends StatelessWidget {
  const AccessibleTouchTarget({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.minSize = 48.0,
    this.borderRadius,
  });

  /// The widget to be made accessible.
  final Widget child;

  /// Optional callback when tapped; if null, no tap gesture is added.
  final VoidCallback? onTap;

  /// Optional semantic label for screen readers.
  final String? semanticLabel;

  /// Minimum width and height in logical pixels. Default 48.0 (optimal).
  final double minSize;

  /// Optional border radius for the ink splash.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget result = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: child,
    );

    if (semanticLabel != null) {
      result = Semantics(
        label: semanticLabel,
        button: onTap != null,
        child: result,
      );
    }

    if (onTap != null) {
      result = Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: result,
        ),
      );
    }

    return result;
  }
}
