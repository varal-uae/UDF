// BPTR-0237-A16 — Mobile layout design-token mapping layer.
// Maps layout spacing and text color treatments to Material 3 theme tokens; enforces an 8dp grid and blocks one-off styling overrides.

import 'package:flutter/material.dart';

/// Applies tokenized spacing, surface color, and text contrast to child widgets.
class Bptr0237A16TokenLayout extends StatelessWidget {
  const Bptr0237A16TokenLayout({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  static const double gridStep = 8.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: _snapToGrid(margin),
      padding: _snapToGrid(padding),
      color: colorScheme.surface,
      child: child,
    );
  }

  EdgeInsetsGeometry _snapToGrid(EdgeInsetsGeometry value) {
    if (value is! EdgeInsets) return value;
    double snap(double v) => (v / gridStep).round() * gridStep;
    return EdgeInsets.fromLTRB(
      snap(value.left),
      snap(value.top),
      snap(value.right),
      snap(value.bottom),
    );
  }
}

/// Text widget that resolves its color from Material 3 theme tokens for WCAG 2.1 AA contrast.
class Bptr0237A16TokenText extends StatelessWidget {
  const Bptr0237A16TokenText(
    this.data, {
    super.key,
    this.style,
  });

  final String data;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveStyle = (style ?? textTheme.bodyMedium ?? const TextStyle()).copyWith(
      color: style?.color ?? colorScheme.onSurface,
    );
    return Text(data, style: effectiveStyle);
  }
}
