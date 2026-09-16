// GEN-00439 — Responsive GridContainer for Binary Compliance Gates (DCYN) dashboard surfaces.
// Conditionally renders a single-column M3 card list on mobile (<600dp) or a multi-column
// grid on tablet/desktop (>=600dp, expanded >=840dp) based on the breakpoint hook output.

import 'package:flutter/material.dart';

/// Layout modes resolved by [resolveGridLayoutMode].
enum GridLayoutMode {
  /// Single-column card list — compact mobile widths (<600dp).
  card,

  /// Multi-column grid — medium (>=600dp) and expanded (>=840dp) widths.
  grid,
}

/// Hook-style resolver that maps the available width to a [GridLayoutMode].
///
/// Breakpoints follow Material 3 window size classes:
/// - `<600dp`  -> [GridLayoutMode.card] (single-column mobile layout)
/// - `>=600dp` -> [GridLayoutMode.grid] (multi-column tablet/desktop layout)
GridLayoutMode resolveGridLayoutMode(double maxWidth) {
  if (maxWidth < 600) return GridLayoutMode.card;
  return GridLayoutMode.grid;
}

/// Resolves the grid column count for a given width using M3 responsive
/// guidance: 2 columns on medium, 3 on expanded, 4 on large screens.
int resolveGridColumnCount(double maxWidth) {
  if (maxWidth >= 1240) return 4;
  if (maxWidth >= 840) return 3;
  return 2;
}

/// Responsive container that conditionally renders its children as a
/// single-column M3 card list (mobile) or a multi-column grid
/// (tablet/desktop), driven by the [resolveGridLayoutMode] hook output.
///
/// Used by DCYN compliance-gate dashboards to present KPI/status content
/// with M3 Elevated Cards (Level 2) and 48x48dp minimum touch targets.
class GridContainerGen00439 extends StatelessWidget {
  const GridContainerGen00439({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.spacing = 16,
    this.padding = const EdgeInsets.all(16),
    this.gridChildAspectRatio = 1.1,
    this.scrollController,
  });

  /// Total number of items to lay out.
  final int itemCount;

  /// Builds the content for the item at [index].
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Horizontal/vertical spacing between items.
  final double spacing;

  /// Outer padding applied around the container.
  final EdgeInsetsGeometry padding;

  /// Child aspect ratio used in grid mode.
  final double gridChildAspectRatio;

  /// Optional scroll controller shared by both layout modes.
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final GridLayoutMode mode = resolveGridLayoutMode(
          constraints.maxWidth,
        );

        switch (mode) {
          case GridLayoutMode.card:
            return _CardListLayout(
              itemCount: itemCount,
              itemBuilder: itemBuilder,
              spacing: spacing,
              padding: padding,
              scrollController: scrollController,
            );
          case GridLayoutMode.grid:
            return _GridLayout(
              itemCount: itemCount,
              itemBuilder: itemBuilder,
              spacing: spacing,
              padding: padding,
              columnCount: resolveGridColumnCount(constraints.maxWidth),
              childAspectRatio: gridChildAspectRatio,
              scrollController: scrollController,
            );
        }
      },
    );
  }
}

/// Single-column card list used on compact mobile widths (<600dp).
class _CardListLayout extends StatelessWidget {
  const _CardListLayout({
    required this.itemCount,
    required this.itemBuilder,
    required this.spacing,
    required this.padding,
    this.scrollController,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollController,
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (BuildContext context, int index) =>
          SizedBox(height: spacing),
      itemBuilder: (BuildContext context, int index) {
        return ConstrainedBox(
          // Enforce the M3 minimum 48dp touch target height.
          constraints: const BoxConstraints(minHeight: 48),
          child: Card(
            elevation: 3, // M3 Elevated Card — Level 2 (3dp).
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: itemBuilder(context, index),
            ),
          ),
        );
      },
    );
  }
}

/// Multi-column grid used on medium/expanded widths (>=600dp).
class _GridLayout extends StatelessWidget {
  const _GridLayout({
    required this.itemCount,
    required this.itemBuilder,
    required this.spacing,
    required this.padding,
    required this.columnCount,
    required this.childAspectRatio,
    this.scrollController,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final int columnCount;
  final double childAspectRatio;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: padding,
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (BuildContext context, int index) {
        return Card(
          elevation: 3, // M3 Elevated Card — Level 2 (3dp).
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: itemBuilder(context, index),
          ),
        );
      },
    );
  }
}
