/// AISS: LSAV-027-A01 -- dimensions for the dashboard content layer.
/// AISS: GEN-02654-A01, GEN-00168-A01, GEN-02709-A01, GEN-04803-A01.
///
/// Every number the KPI cards, charts, skeletons and summary strip use, in one
/// file that mirrors `tokens.json`. Steps 21-33 got their own
/// `surface_tokens.dart` for the same reason: a dimension declared next to the
/// widget that uses it is a dimension the drift gate cannot see.
library;

import 'grid_tokens.dart';
import 'spacing_tokens.dart';

/// Dashboard layout dimensions.
class HabotDashboardTokens {
  const HabotDashboardTokens._();

  /// Gap between tiles, horizontally and vertically. The column gutter and the
  /// vertical rhythm the grid already defines, not new numbers.
  static const double tileGutter = HabotGrid.gutter;
  static const double tileRowGap = HabotGrid.verticalRhythm;

  /// The summary strip at the top of the dashboard (Step 62).
  static const double summaryStripHeight = 72;
  static const double summaryStripGap = HabotSpacing.sm;

  /// The most metrics the summary strip will show before it stops being a
  /// glance and becomes a table.
  static const int maxSummaryMetrics = 4;

  /// Shimmer skeletons (Step 61).
  static const double skeletonCornerRadius = HabotSpacing.xxs;
  static const double skeletonLineHeight = HabotSpacing.sm;
  static const double skeletonLineGap = HabotSpacing.xxs;

  /// Filter chips (Step 64).
  static const double chipHeight = 32;
  static const double chipGap = HabotSpacing.xs;
  static const double chipIconSize = HabotSpacing.md;

  /// The usable width of one tile at [viewportWidth] in [columns] columns,
  /// after the outer margins and the gutters between tiles are removed.
  ///
  /// One function, so a card, a skeleton and a chart placed in the same cell
  /// cannot disagree about how wide that cell is -- which is the whole
  /// mechanism behind the zero-layout-shift claim in Step 61.
  static double tileWidth(double viewportWidth, int columns) {
    final double content = HabotGrid.contentWidth(viewportWidth);
    if (columns <= 1) {
      return content;
    }
    return (content - (tileGutter * (columns - 1))) / columns;
  }
}
