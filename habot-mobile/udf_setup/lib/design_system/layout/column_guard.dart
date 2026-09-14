/// AISS Step 168 -- GEN-01065
/// Setup Step (Action) / Atomic Step: "Implement structural viewport
///   constraints that block multi-column layout rendering on screen widths
///   below mobile thresholds."
/// Metric: Mobile Conversion Funnel Completion Rate -- Floor 0.6, Optimal 0.8,
///         Ceiling 0.95. Good / Average / Poor.
///
/// **A FUNNEL METRIC ON A LAYOUT STEP, AND THE CLIENT CANNOT COMPUTE IT.**
/// A conversion funnel completion rate is a ratio across many users' sessions.
/// One device knows only its own, so a client reporting "completion: 1.0"
/// would be reporting a denominator of one. The rate is a query over the
/// Step 161 event stream, and saying so is more useful than inventing a
/// number. What the client CAN report, and what this step is actually
/// accountable for, is conformance: the share of layouts that obey the
/// constraint the funnel depends on.
///
/// **"BLOCK" MEANS REFUSE, NOT WRAP.** A constraint that quietly collapses a
/// two-column request into one column is a convention: the caller keeps asking
/// for two, the layout keeps silently disagreeing, and the next person adds a
/// third. [HabotColumnGuard.columnsFor] returns what is permitted, and
/// [HabotColumnGuard.demand] throws when a caller insists — so the disagreement
/// surfaces at the call site where it can be fixed.
///
/// **THE THRESHOLD IS THE STEP 2 BREAKPOINT, NOT A NEW NUMBER.** `HabotGrid`
/// already declares the compact/medium/expanded boundaries and the 4/8/12
/// column counts. A second opinion about what "below mobile thresholds" means
/// is exactly the drift these steps exist to prevent.
///
/// **WHY THE CONSTRAINT AND THE FUNNEL ARE CONNECTED AT ALL.** Two columns on
/// a 360dp screen gives each about 170dp. A form field in 170dp shows roughly
/// eight characters of its own label, and a two-column form is where mobile
/// conversion goes to die. The constraint is not an aesthetic preference; it
/// is the thing the row's metric is measuring the absence of.
library;

import '../tokens/grid_tokens.dart';

/// Thrown when a caller insists on more columns than the viewport permits.
class HabotColumnCountRefused implements Exception {
  const HabotColumnCountRefused(this.requested, this.permitted, this.widthDp);

  final int requested;
  final int permitted;
  final double widthDp;

  @override
  String toString() =>
      'A $requested-column layout was requested at '
      '${widthDp.toStringAsFixed(0)}dp, where $permitted is permitted. '
      'Refused rather than collapsed: a constraint that silently disagrees '
      'with its caller is a convention, and the next person adds a third '
      'column. Two columns at this width gives each about '
      '${(widthDp / 2).toStringAsFixed(0)}dp, which is roughly eight '
      'characters of a form label.';
}

/// The viewport class a width falls in.
enum HabotViewportClass { compact, medium, expanded }

/// Structural constraint on how many columns a layout may use.
class HabotColumnGuard {
  const HabotColumnGuard._();

  /// Below this, multi-column layout is refused. The Step 2 breakpoint, read
  /// rather than restated.
  static double get multiColumnThreshold => HabotGrid.breakpointSm;

  static HabotViewportClass classOf(double widthDp) {
    if (widthDp < HabotGrid.breakpointSm) {
      return HabotViewportClass.compact;
    }
    return widthDp < HabotGrid.breakpointMd
        ? HabotViewportClass.medium
        : HabotViewportClass.expanded;
  }

  /// How many content columns are permitted at [widthDp].
  ///
  /// One on compact, whatever the caller had in mind.
  static int columnsFor(double widthDp, {int requested = 1}) {
    if (classOf(widthDp) == HabotViewportClass.compact) {
      return 1;
    }
    final int ceiling = gridColumnsFor(widthDp);
    if (requested < 1) {
      return 1;
    }
    return requested > ceiling ? ceiling : requested;
  }

  /// The underlying grid column count, from Step 2.
  static int gridColumnsFor(double widthDp) {
    switch (classOf(widthDp)) {
      case HabotViewportClass.compact:
        return HabotGrid.compactColumns;
      case HabotViewportClass.medium:
        return HabotGrid.mediumColumns;
      case HabotViewportClass.expanded:
        return HabotGrid.expandedColumns;
    }
  }

  /// True when a multi-column content layout is permitted at all.
  static bool permitsMultiColumn(double widthDp) =>
      classOf(widthDp) != HabotViewportClass.compact;

  /// Assert a column count, refusing rather than collapsing.
  static int demand(double widthDp, int requested) {
    final int permitted = columnsFor(widthDp, requested: requested);
    if (permitted != requested) {
      throw HabotColumnCountRefused(requested, permitted, widthDp);
    }
    return permitted;
  }

  /// Width each content column gets at [widthDp], after the outer margins
  /// and the gutters between them.
  static double columnWidthAt(double widthDp, int columns) {
    if (columns <= 0) {
      return 0;
    }
    final double usable = widthDp -
        (HabotGrid.outerMargin * 2) -
        (HabotGrid.gutter * (columns - 1));
    return usable / columns;
  }

  /// The narrowest a content column may be and still hold a form label.
  ///
  /// Eight characters at body size is roughly this wide, and a label that
  /// truncates is a field nobody can answer -- which is the funnel failure
  /// the row's metric describes.
  static const double minUsableColumnDp = 200;

  /// Widths at which a given column count would produce unusable columns.
  static bool wouldBeUnusable(double widthDp, int columns) =>
      columnWidthAt(widthDp, columns) < minUsableColumnDp;

  // ---- conformance, which is what the client can actually report ----------

  /// The share of declared layouts that obey the constraint.
  static double conformanceRate(Map<double, int> layoutsByWidth) {
    if (layoutsByWidth.isEmpty) {
      return 1;
    }
    int ok = 0;
    for (final MapEntry<double, int> e in layoutsByWidth.entries) {
      if (columnsFor(e.key, requested: e.value) == e.value) {
        ok++;
      }
    }
    return ok / layoutsByWidth.length;
  }

  /// Layouts that break it, named.
  static List<String> violations(Map<double, int> layoutsByWidth) =>
      layoutsByWidth.entries
          .where((MapEntry<double, int> e) =>
              columnsFor(e.key, requested: e.value) != e.value)
          .map((MapEntry<double, int> e) =>
              '${e.value} columns at ${e.key.toStringAsFixed(0)}dp '
              '(permitted: ${columnsFor(e.key, requested: e.value)})')
          .toList();

  static const double funnelFloor = 0.6;
  static const double funnelOptimal = 0.8;
  static const double funnelCeiling = 0.95;

  /// The row's vocabulary, for a funnel rate the SERVER supplies.
  static String bandFor(double funnelRate) {
    if (funnelRate >= funnelOptimal) {
      return 'Good';
    }
    return funnelRate >= funnelFloor ? 'Average' : 'Poor';
  }

  static const String funnelIsServerSide =
      'A conversion funnel completion rate is a ratio across many users. One '
      'device knows only its own sessions, so a client reporting it would be '
      'reporting a denominator of one. The rate is a query over the Step 161 '
      'event stream. What the client is accountable for, and reports, is '
      'conformance to the constraint the funnel depends on.';

  static const String refuseNotWrapNote =
      '"Block" means refuse, not wrap. A constraint that quietly collapses a '
      'two-column request into one is a convention: the caller keeps asking '
      'for two, the layout keeps silently disagreeing, and the next person '
      'adds a third. demand() throws, so the disagreement surfaces at the call '
      'site where it can be fixed.';

  static const String whyItMattersNote =
      'Two columns on a 360dp screen gives each about 170dp. A form field in '
      '170dp shows roughly eight characters of its own label, and a two-column '
      'form is where mobile conversion goes to die. The constraint is not an '
      'aesthetic preference; it is the thing the row\'s metric measures the '
      'absence of.';

  static const String thresholdNote =
      'The threshold is HabotGrid.breakpointSm, declared at Step 2. A second '
      'opinion about what "below mobile thresholds" means is exactly the drift '
      'these steps exist to prevent.';
}
