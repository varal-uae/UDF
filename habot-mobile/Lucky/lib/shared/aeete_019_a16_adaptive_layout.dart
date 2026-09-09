// AEETE-019-A16 — Implement MD3 Window Size Classes to create responsive, adaptive mobile layouts.
// Resolves compact (<600dp), medium (600–839dp), and expanded (>=840dp) breakpoints and exposes
// an AdaptiveLayout that rebuilds by the current window size class. Includes a form submit handler
// that invokes a callback when the primary submit button is pressed.

import 'package:flutter/material.dart';

/// Material 3 window size class breakpoints.
enum Md3WindowSizeClass {
  compact,
  medium,
  expanded,
}

extension Md3WindowSizeClassResolution on BuildContext {
  Md3WindowSizeClass get md3WindowSizeClass {
    final width = MediaQuery.sizeOf(this).width;
    if (width < 600) return Md3WindowSizeClass.compact;
    if (width < 840) return Md3WindowSizeClass.medium;
    return Md3WindowSizeClass.expanded;
  }
}

class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  final WidgetBuilder compact;
  final WidgetBuilder? medium;
  final WidgetBuilder? expanded;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final sizeClass = width < 600
            ? Md3WindowSizeClass.compact
            : width < 840
                ? Md3WindowSizeClass.medium
                : Md3WindowSizeClass.expanded;
        switch (sizeClass) {
          case Md3WindowSizeClass.compact:
            return compact(context);
          case Md3WindowSizeClass.medium:
            return medium?.call(context) ?? compact(context);
          case Md3WindowSizeClass.expanded:
            return expanded?.call(context) ?? medium?.call(context) ?? compact(context);
        }
      },
    );
  }
}

/// Attaches a form submit handler to a primary submit button component.
class FormSubmitButton extends StatelessWidget {
  const FormSubmitButton({
    super.key,
    required this.label,
    required this.onSubmit,
    this.icon,
  });

  final String label;
  final VoidCallback onSubmit;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onSubmit,
      icon: icon != null ? Icon(icon) : const Icon(Icons.check),
      label: Text(label),
    );
  }
}
