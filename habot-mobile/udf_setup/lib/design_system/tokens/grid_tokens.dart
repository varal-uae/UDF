/// AISS: RCGLA-001-A01 -- substep 2 "Implement an adaptive 4-column layout
/// matrix optimized for compact smartphone screens."
/// Also carries the TTMCS-001 rule "Sidebar navigation components auto-collapse
/// smoothly on screen layout sizes under 768px."
///
/// Source of truth: `lib/design_system/tokens/tokens.json`.
library;

/// Material 3 window size classes, named the way the spec sheet names them.
enum HabotWindowClass {
  /// < 600dp -- phones in portrait. 4-column matrix.
  compact,

  /// 600dp .. 839dp -- large phones landscape / small tablets. 8-column matrix.
  medium,

  /// >= 840dp -- tablets and desktop. 12-column matrix.
  expanded,
}

class HabotGrid {
  const HabotGrid._();

  static const double baselineDp = 8;
  static const double subBaselineDp = 4;

  static const int compactColumns = 4;
  static const int mediumColumns = 8;
  static const int expandedColumns = 12;

  static const double outerMargin = 16;

  /// Horizontal space between grid columns.
  ///
  /// RCGLA-012 and RCGLA-032 disagree on this value in the step sheet:
  ///   RCGLA-012 UX row : "explicitly at 16px with an 8px gutter grid system"
  ///   RCGLA-032 sub 1  : "16px outer margin and a 16px column gutter"
  ///
  /// Resolved into two distinct tokens. [gutter] is the *column* gutter and
  /// follows RCGLA-032, which names it explicitly and repeats it in its UI
  /// decision row. [verticalRhythm] is the baseline step, which is what
  /// RCGLA-012's own UX Translation row actually describes ("a continuous 8px
  /// vertical rhythm alignment"). Both are gated; see SSTLA-004-G4.
  static const double gutter = 16;

  /// Vertical baseline step between stacked elements (RCGLA-012).
  static const double verticalRhythm = 8;

  /// Breakpoints, named as RCGLA-012 substep 1 names them ("xs: 0px, sm: 600px").
  static const double breakpointXs = 0;
  static const double breakpointSm = 600;
  static const double breakpointMd = 840;

  static const double breakpointCompact = breakpointXs;
  static const double breakpointMedium = breakpointSm;
  static const double breakpointExpanded = breakpointMd;

  /// RCGLA-012 poka-yoke: "break compilation if outer layout wrappers contain
  /// hardcoded fixed pixel widths over 360px".
  static const double maxHardcodedWrapperWidth = 360;

  /// RCGLA-032: no element may split into more than this many vertical segments
  /// on a compact viewport.
  static const int maxCompactSegments = 4;

  /// TTMCS-001: navigation collapses below this width.
  static const double navigationCollapse = 768;

  /// The narrowest viewport the layout must survive without horizontal overflow.
  static const double minSupportedWidth = 320;

  /// Pure function -- no BuildContext, so it is directly unit-testable.
  static HabotWindowClass windowClassFor(double width) {
    if (width >= breakpointExpanded) {
      return HabotWindowClass.expanded;
    }
    if (width >= breakpointMedium) {
      return HabotWindowClass.medium;
    }
    return HabotWindowClass.compact;
  }

  static int columnsFor(double width) {
    switch (windowClassFor(width)) {
      case HabotWindowClass.compact:
        return compactColumns;
      case HabotWindowClass.medium:
        return mediumColumns;
      case HabotWindowClass.expanded:
        return expandedColumns;
    }
  }

  /// True when side navigation must be collapsed into a drawer / bottom bar.
  static bool navigationIsCollapsed(double width) => width < navigationCollapse;

  /// Width of a single grid column at [width], after removing outer margins and
  /// the gutters between columns. Never returns a negative value.
  static double columnWidth(double width) {
    final int columns = columnsFor(width);
    final double usable =
        width - (outerMargin * 2) - (gutter * (columns - 1));
    final double result = usable / columns;
    return result < 0 ? 0 : result;
  }

  /// Content width available inside the outer margins.
  static double contentWidth(double width) {
    final double result = width - (outerMargin * 2);
    return result < 0 ? 0 : result;
  }

  /// Maximum width a content column is allowed to occupy at [width].
  ///
  /// Compact and medium fill the viewport. Expanded caps at the expanded
  /// breakpoint so line length stays readable on desktop rather than running
  /// the full width of a 27-inch monitor.
  static double maxContentWidthFor(double width) =>
      windowClassFor(width) == HabotWindowClass.expanded
      ? breakpointExpanded
      : double.infinity;

  /// RCGLA-032 substep 2: flags an element trying to split into more vertical
  /// segments than the active matrix allows. Returns the clamped span.
  static int clampSegments(int requested, double width) {
    final int limit = windowClassFor(width) == HabotWindowClass.compact
        ? maxCompactSegments
        : columnsFor(width);
    if (requested < 1) {
      return 1;
    }
    return requested > limit ? limit : requested;
  }

  /// True when [requested] segments would exceed what [width] permits.
  static bool exceedsSegmentLimit(int requested, double width) =>
      requested != clampSegments(requested, width);
}
