// AEETE-019-A04 — MD3 Window Size Classes responsive adaptive layout resolver.
// Establishes Compact (phone) as the baseline and scales to Medium and Expanded using Material 3 breakpoints.
import 'package:flutter/widgets.dart';

/// Material Design 3 window size classes.
enum MaterialWindowSizeClass { compact, medium, expanded }

/// Resolves the current window size class from the available width.
class MaterialWindowSizeClassResolver {
  MaterialWindowSizeClassResolver._();

  /// Compact breakpoint: width < 600 dp.
  static const double compactBreakpoint = 600;

  /// Expanded breakpoint: width >= 840 dp.
  static const double expandedBreakpoint = 840;

  /// Resolves [MaterialWindowSizeClass] for the given [BuildContext].
  static MaterialWindowSizeClass resolve(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < compactBreakpoint) {
      return MaterialWindowSizeClass.compact;
    }
    if (width < expandedBreakpoint) {
      return MaterialWindowSizeClass.medium;
    }
    return MaterialWindowSizeClass.expanded;
  }
}
