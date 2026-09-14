/// AISS Step 167 -- GEN-00754
/// Setup Step (Action): "Implement Automated Mobile Cohort Retention Matrix
///                       Engine in BigQuery"
/// Atomic Step: "Enable horizontal table scrolling with sticky first columns
///               on compact mobile viewports."
/// Metric: Smooth Scroll Frame Rate -- 60 fps at floor, optimal and ceiling
///         alike. Pass / Fail.
///
/// **60 fps AT EVERY BOUND MEANS THE BUDGET IS 16.667ms, NOT 16ms.** Ticking
/// on a 16ms period against a 16.667ms display refresh drifts two thirds of a
/// millisecond per frame, which accumulates to a whole frame every 25 frames
/// -- roughly twice a second. That is a periodic hitch which is maddening to
/// reproduce and trivial to avoid. [HabotMotion.smoothFrameBudget] holds the
/// real value, and [HabotStickyColumnTable.framesLostToRounding] makes the
/// arithmetic concrete rather than pedantic.
///
/// **A FRAME BUDGET IS A COMPLEXITY CLAIM, NOT A TIMING.** You cannot hold 60
/// fps by measuring; you hold it by doing work proportional to what is on
/// screen. The failure mode of a sticky column is exactly this: an
/// implementation that rebuilds every row on each scroll offset change is O(all
/// rows) per frame, which is fine on the fifty-row fixture and drops frames on
/// the real cohort matrix. [HabotStickyColumnTable.workPerFrame] states the
/// claim so it can be checked rather than hoped for.
///
/// **A FROZEN COLUMN TOO WIDE LEAVES NOTHING TO SCROLL.** On a 360dp screen a
/// frozen column of 200dp leaves 160dp of scrollable area — the table becomes
/// a label with a keyhole. The constraint is a fraction of the viewport, and
/// it is refused rather than clamped, because a silently narrowed column is a
/// truncated label and the caller never finds out.
///
/// **"FIRST COLUMN" IS A DIRECTION, NOT A SIDE.** In Urdu the first column is
/// on the right (Step 138 F-1, Step 150). Freezing "the left column" would
/// pin the wrong one and scroll the labels away.
library;

import '../i18n/localization_objective.dart';
import '../tokens/grid_tokens.dart';
import '../tokens/motion_tokens.dart';

/// One column in the matrix.
class HabotTableColumn {
  const HabotTableColumn({
    required this.id,
    required this.label,
    required this.widthDp,
  });

  final String id;
  final String label;
  final double widthDp;
}

/// Thrown when a layout would leave the table unusable.
class HabotFrozenColumnTooWide implements Exception {
  const HabotFrozenColumnTooWide(this.frozenDp, this.viewportDp);

  final double frozenDp;
  final double viewportDp;

  @override
  String toString() =>
      'Frozen columns take ${frozenDp.toStringAsFixed(0)}dp of a '
      '${viewportDp.toStringAsFixed(0)}dp viewport, past the '
      '${(HabotStickyColumnTable.maxFrozenFraction * 100).toStringAsFixed(0)}% '
      'limit. The scrollable area would be narrower than the labels, which '
      'makes the table a label with a keyhole. Refused rather than clamped: a '
      'silently narrowed column is a truncated label the caller never learns '
      'about.';
}

/// The scroll geometry of a sticky-column table.
class HabotStickyColumnTable {
  const HabotStickyColumnTable({
    required this.columns,
    required this.frozenCount,
    required this.viewportDp,
    required this.direction,
  });

  final List<HabotTableColumn> columns;

  /// How many leading columns stay put. One, in practice -- see
  /// [maxFrozenFraction].
  final int frozenCount;

  final double viewportDp;
  final HabotTextDirectionality direction;

  /// The most of the viewport the frozen columns may occupy.
  static const double maxFrozenFraction = 0.45;

  /// Compact viewports are the ones the row is about.
  static bool isCompact(double widthDp) => widthDp < HabotGrid.breakpointSm;

  bool get isRightToLeft =>
      direction == HabotTextDirectionality.rightToLeft;

  /// Which side the frozen columns pin to. A direction, not a side.
  String get frozenSide => isRightToLeft ? 'right' : 'left';

  double get frozenWidthDp => columns
      .take(frozenCount)
      .fold(0, (double a, HabotTableColumn c) => a + c.widthDp);

  double get scrollableWidthDp => columns
      .skip(frozenCount)
      .fold(0, (double a, HabotTableColumn c) => a + c.widthDp);

  double get visibleScrollAreaDp => viewportDp - frozenWidthDp;

  double get maxScrollExtentDp {
    final double over = scrollableWidthDp - visibleScrollAreaDp;
    return over > 0 ? over : 0;
  }

  bool get isWithinFrozenLimit =>
      frozenWidthDp <= viewportDp * maxFrozenFraction;

  /// Refuses a layout that would leave the table unusable.
  void assertUsable() {
    if (!isWithinFrozenLimit) {
      throw HabotFrozenColumnTooWide(frozenWidthDp, viewportDp);
    }
  }

  /// Columns actually on screen at [scrollOffset]. The set a frame's work
  /// must be proportional to.
  List<HabotTableColumn> visibleColumnsAt(double scrollOffset) {
    final List<HabotTableColumn> out =
        columns.take(frozenCount).toList();
    double x = 0;
    for (final HabotTableColumn c in columns.skip(frozenCount)) {
      final double start = x;
      final double end = x + c.widthDp;
      x = end;
      if (end <= scrollOffset) {
        continue;
      }
      if (start >= scrollOffset + visibleScrollAreaDp) {
        break;
      }
      out.add(c);
    }
    return out;
  }

  // ---- the row's metric ---------------------------------------------------

  /// One frame at 60fps, to the microsecond.
  static Duration get frameBudget => HabotMotion.smoothFrameBudget;

  /// The figure somebody gets when they round, kept so the difference is
  /// demonstrable rather than argued.
  ///
  /// **Derived, not written down.** It is literally the budget truncated to
  /// whole milliseconds, which is the mistake this names -- and deriving it
  /// means there is still exactly one duration literal behind both figures,
  /// which is what the poka-yoke guard is for.
  static Duration get roundedFrameBudget =>
      Duration(milliseconds: frameBudget.inMilliseconds);

  /// How many frames the rounding costs over [seconds] of continuous
  /// scrolling. About 2.4 a second, which is the number that makes the 16 vs
  /// 16.667 argument concrete rather than pedantic.
  static double framesLostToRounding(int seconds) {
    final double budgetUs = frameBudget.inMicroseconds.toDouble();
    final double roundedUs = roundedFrameBudget.inMicroseconds.toDouble();
    final double driftPerFrame = budgetUs - roundedUs;
    final double framesPerSecond = 1000000 / budgetUs;
    return (driftPerFrame * framesPerSecond * seconds) / budgetUs;
  }

  /// **The complexity claim.** Per-frame work is proportional to the cells on
  /// screen, never to the rows in the table.
  ///
  /// Returns the number of cells a frame must touch, given the visible rows.
  /// A scroll that returns the same figure for a 50-row and a 5,000-row table
  /// is one that can hold the budget; one that does not, cannot, whatever a
  /// timing on a fast device says.
  int workPerFrame({
    required double scrollOffset,
    required int visibleRows,
  }) =>
      visibleColumnsAt(scrollOffset).length * visibleRows;

  static const String frameBudgetNote =
      '60fps at every bound means 16.667ms, not 16ms. Two thirds of a '
      'millisecond of drift per frame accumulates to a whole frame every 25 '
      'frames -- roughly twice a second -- which is a periodic hitch that is '
      'maddening to reproduce and trivial to avoid.';

  static const String complexityNote =
      'A frame budget is a complexity claim, not a timing. You hold 60fps by '
      'doing work proportional to what is on screen. The failure mode of a '
      'sticky column is an implementation that rebuilds every row on each '
      'scroll offset change: O(all rows) per frame, fine on the fifty-row '
      'fixture, dropping frames on the real cohort matrix.';

  static const String frozenWidthNote =
      'On a 360dp screen a frozen column of 200dp leaves 160dp to scroll in -- '
      'the table becomes a label with a keyhole. The limit is a fraction of '
      'the viewport and it is REFUSED rather than clamped, because a silently '
      'narrowed column is a truncated label the caller never finds out about.';

  static const String directionNote =
      '"First column" is a direction, not a side. In Urdu it is on the right '
      '(Step 138 F-1, Step 150). Freezing "the left column" would pin the '
      'wrong one and scroll the labels away.';
}
