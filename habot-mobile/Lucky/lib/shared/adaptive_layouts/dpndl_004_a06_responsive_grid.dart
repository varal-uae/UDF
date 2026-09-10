// DPNDL-004-A06 — Master 12-column responsive grid wrapper for Material 3 expanded layouts.
// Enforces 24dp gutters, breakpoint-aware column counts, and column-span alignment.

import 'package:flutter/material.dart';

class Dpndl004A06ResponsiveGrid extends StatelessWidget {
  const Dpndl004A06ResponsiveGrid({
    super.key,
    required this.children,
    this.runSpacing = 24,
  });

  final List<Dpndl004A06GridItem> children;
  final double runSpacing;

  static const double gutter = 24.0;
  static const int mobileColumns = 4;
  static const int tabletColumns = 8;
  static const int desktopColumns = 12;
  static const double tabletBreakpoint = 600.0;
  static const double desktopBreakpoint = 1440.0;

  int _columnsFor(double width) {
    if (width >= desktopBreakpoint) return desktopColumns;
    if (width >= tabletBreakpoint) return tabletColumns;
    return mobileColumns;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnsFor(constraints.maxWidth);
        final totalGutter = gutter * (columns - 1);
        final cellWidth = (constraints.maxWidth - totalGutter) / columns;

        return Wrap(
          spacing: gutter,
          runSpacing: runSpacing,
          children: children.map((item) {
            final span = item.span.clamp(1, columns).toInt();
            final width = cellWidth * span + gutter * (span - 1);
            return SizedBox(
              width: width,
              child: item.child,
            );
          }).toList(),
        );
      },
    );
  }
}

class Dpndl004A06GridItem {
  const Dpndl004A06GridItem({
    required this.child,
    this.span = 12,
  });

  final Widget child;
  final int span;
}
