import 'size_class.dart';

/// SSELC-029-A01 / SSELC-025-A01 — Viewport breakpoint constants.
/// Single source of truth for all adaptive layout width thresholds.
/// Reference: HC-NOM-0007 | Google Material Design window size classes.
abstract class HabotBreakpoints {
  /// Compact mobile — full-screen single-view navigation only. 4-column grid.
  static const double compact = 600;

  /// Expanded — widescreen, full 60/40 split enforced. 12-column grid.
  static const double expanded = 1200;

  static bool isCompact(double width) => width < compact;
  static bool isMedium(double width) => width >= compact && width < expanded;
  static bool isExpanded(double width) => width >= expanded;

  /// Maps a raw pixel width to a [SizeClass].
  /// Falls back to [SizeClass.compact] when width is zero or unclear.
  static SizeClass fromWidth(double width) {
    if (width <= 0)        return SizeClass.compact;
    if (width < compact)   return SizeClass.compact;
    if (width < expanded)  return SizeClass.medium;
    return SizeClass.expanded;
  }
}
