// DSDD-007-12 — Mobile Touch Target Size Compliance & 8dp Grid Container.
// Enforces WCAG 2.2 SC 2.5.8 and Material 3 touch target sizing for input fields and interactive controls.

import 'package:flutter/material.dart';

/// DSDD-007-12 — Touch target compliance wrapper.
/// Applies 8dp layout grid padding and enforces 44dp minimum, 48dp optimal target size.
class Dsdd00712TouchTargetCompliance extends StatelessWidget {
  const Dsdd00712TouchTargetCompliance({
    super.key,
    required this.child,
    this.isInputField = false,
    this.alignment = Alignment.center,
  });

  final Widget child;
  final bool isInputField;
  final Alignment alignment;

  static const double floorBoundary = 44.0;
  static const double optimalTarget = 48.0;
  static const double ceilingBoundary = 56.0;
  static const double gridUnit = 8.0;

  static bool isCompliant(double size) => size >= floorBoundary;
  static bool isOptimal(double size) => size >= optimalTarget;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: isInputField ? 'Input field touch target' : 'Touch target',
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: optimalTarget,
          minHeight: optimalTarget,
        ),
        child: Padding(
          padding: const EdgeInsets.all(gridUnit),
          child: Align(
            alignment: alignment,
            child: child,
          ),
        ),
      ),
    );
  }
}
