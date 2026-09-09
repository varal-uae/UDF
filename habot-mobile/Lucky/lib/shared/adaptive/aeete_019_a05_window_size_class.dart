// AEETE-019-A05 — Material 3 Window Size Classes for responsive, adaptive mobile layouts.
// Implements compact, medium, and expanded breakpoints; exposes Material 3 grid columns, margins, and gutters, plus a layout switcher for medium-class adjustments.
import 'package:flutter/material.dart';

/// Material 3 window size classes for responsive mobile layouts.
enum AdaptiveWindowSizeClass { compact, medium, expanded }

/// Layout specification for Material 3 adaptive grids.
class AdaptiveLayoutSpec {
  const AdaptiveLayoutSpec({
    required this.columns,
    required this.margin,
    required this.gutter,
  });

  final int columns;
  final double margin;
  final double gutter;
}

extension AdaptiveWindowSizeClassX on BuildContext {
  /// Resolves the current window size class from the available width.
  AdaptiveWindowSizeClass get windowSizeClass {
    final double width = MediaQuery.sizeOf(this).width;
    if (width < 600) {
      return AdaptiveWindowSizeClass.compact;
    } else if (width < 840) {
      return AdaptiveWindowSizeClass.medium;
    } else {
      return AdaptiveWindowSizeClass.expanded;
    }
  }

  /// Material 3 grid values for the active window size class.
  AdaptiveLayoutSpec get adaptiveLayoutSpec {
    switch (windowSizeClass) {
      case AdaptiveWindowSizeClass.compact:
        return const AdaptiveLayoutSpec(columns: 4, margin: 16, gutter: 16);
      case AdaptiveWindowSizeClass.medium:
        return const AdaptiveLayoutSpec(columns: 8, margin: 24, gutter: 24);
      case AdaptiveWindowSizeClass.expanded:
        return const AdaptiveLayoutSpec(columns: 12, margin: 24, gutter: 24);
    }
  }

  bool get isMediumWindow => windowSizeClass == AdaptiveWindowSizeClass.medium;
}

/// Switches between layout variants based on the active window size class.
class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  final Widget compact;
  final Widget? medium;
  final Widget? expanded;

  @override
  Widget build(BuildContext context) {
    switch (context.windowSizeClass) {
      case AdaptiveWindowSizeClass.compact:
        return compact;
      case AdaptiveWindowSizeClass.medium:
        return medium ?? compact;
      case AdaptiveWindowSizeClass.expanded:
        return expanded ?? medium ?? compact;
    }
  }
}
