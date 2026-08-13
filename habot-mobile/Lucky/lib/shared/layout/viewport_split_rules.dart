import 'size_class.dart';
import 'breakpoints.dart';

// SSTLA-020-A01 — Viewport-Linked Split Routing Rules.
// Master rule sheet: defines the precise breakpoints that shift the app from
// single-screen mobile navigation grids into side-by-side desktop tables.
// Reference: Material Design 3 adaptive layout · HC-NOM-0007
//
// Rule evaluation order:
//   1. Read SizeClass from ScreenSizeProvider (live, rotation-aware)
//   2. Look up SplitRoutingRule for that SizeClass
//   3. Apply NavigationMode and PaneRatio to the layout shell

// ─── NAVIGATION MODE ──────────────────────────────────────────────────────────

enum NavigationMode {
  /// Single-screen stack. Row tap pushes detail as a new full-screen route.
  /// Mobile only. 4-column grid. Clean, uncluttered list view.
  singleStack,

  /// Side-by-side split. Row tap updates detail pane in-place.
  /// No route push. Selected row stays highlighted.
  splitPane,
}

// ─── PANE RATIO ───────────────────────────────────────────────────────────────

/// Defines the flex ratio of list pane : detail pane in split mode.
class PaneRatio {
  const PaneRatio({required this.list, required this.detail});
  final int list;
  final int detail;

  /// e.g. PaneRatio(list: 6, detail: 4) → 60/40 split
  double get listFraction => list / (list + detail);
  double get detailFraction => detail / (list + detail);

  @override
  String toString() => '${(listFraction * 100).round()}/${(detailFraction * 100).round()}';
}

// ─── SPLIT ROUTING RULE ───────────────────────────────────────────────────────

class SplitRoutingRule {
  const SplitRoutingRule({
    required this.sizeClass,
    required this.minWidth,
    required this.maxWidth,
    required this.navigationMode,
    required this.paneRatio,
    required this.gridColumns,
    required this.lazyLoadDetail,
    required this.autoCloseDetailOnDelete,
    required this.trackPathOnRotation,
  });

  final SizeClass      sizeClass;
  final double         minWidth;
  final double         maxWidth;           // double.infinity for expanded
  final NavigationMode navigationMode;
  final PaneRatio      paneRatio;
  final int            gridColumns;

  /// Spec: load deep details only when a row is clicked — saves network bandwidth.
  final bool lazyLoadDetail;

  /// Spec: close active detail screen if selected row is deleted by another session.
  final bool autoCloseDetailOnDelete;

  /// Spec: layout tracking tools keep correct details open during screen rotations.
  final bool trackPathOnRotation;
}

// ─── RULE REGISTRY ────────────────────────────────────────────────────────────

abstract class ViewportSplitRules {

  /// Compact — single-screen mobile navigation grid.
  /// < 600dp · 4-column grid · full-screen stack navigation.
  static const SplitRoutingRule compact = SplitRoutingRule(
    sizeClass:              SizeClass.compact,
    minWidth:               0,
    maxWidth:               HabotBreakpoints.compact,
    navigationMode:         NavigationMode.singleStack,
    paneRatio:              PaneRatio(list: 1, detail: 0), // no split
    gridColumns:            4,
    lazyLoadDetail:         true,
    autoCloseDetailOnDelete: true,
    trackPathOnRotation:    true,
  );

  /// Medium — tablet split panel.
  /// 600–1200dp · 8-column grid · 50/50 side-by-side split.
  static const SplitRoutingRule medium = SplitRoutingRule(
    sizeClass:              SizeClass.medium,
    minWidth:               HabotBreakpoints.compact,
    maxWidth:               HabotBreakpoints.expanded,
    navigationMode:         NavigationMode.splitPane,
    paneRatio:              PaneRatio(list: 5, detail: 5), // 50/50
    gridColumns:            8,
    lazyLoadDetail:         true,
    autoCloseDetailOnDelete: true,
    trackPathOnRotation:    true,
  );

  /// Expanded — widescreen desktop table.
  /// ≥ 1200dp · 12-column grid · 60/40 side-by-side split.
  static const SplitRoutingRule expanded = SplitRoutingRule(
    sizeClass:              SizeClass.expanded,
    minWidth:               HabotBreakpoints.expanded,
    maxWidth:               double.infinity,
    navigationMode:         NavigationMode.splitPane,
    paneRatio:              PaneRatio(list: 6, detail: 4), // 60/40
    gridColumns:            12,
    lazyLoadDetail:         true,
    autoCloseDetailOnDelete: true,
    trackPathOnRotation:    true,
  );

  /// Returns the correct rule for a given [SizeClass].
  static SplitRoutingRule forSizeClass(SizeClass sizeClass) {
    switch (sizeClass) {
      case SizeClass.compact:  return compact;
      case SizeClass.medium:   return medium;
      case SizeClass.expanded: return expanded;
    }
  }

  /// All rules — used for QA matrix validation.
  static const List<SplitRoutingRule> all = [compact, medium, expanded];
}
