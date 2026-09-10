// DPNDL-004-A13 — 12-Column Desktop Grid & Flexbox fallback alignment.
// Provides a Material 3 responsive grid that snaps children to 12 columns on desktop,
// with Wrap-based fallback horizontal alignment inside column slots.

import 'package:flutter/material.dart';

class Dpndl004A13ResponsiveGrid extends StatelessWidget {
  const Dpndl004A13ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.padding = EdgeInsets.zero,
    this.alignment = WrapAlignment.start,
    this.runAlignment = WrapAlignment.start,
  });

  final List<Dpndl004A13GridItem> children;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry padding;
  final WrapAlignment alignment;
  final WrapAlignment runAlignment;

  int _columnsFor(double width) {
    if (width >= 905) return 12;
    if (width >= 600) return 8;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = _columnsFor(width);
        final totalSpacing = spacing * (columns - 1);
        final cellWidth = (width - totalSpacing) / columns;

        return Padding(
          padding: padding,
          child: Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            alignment: alignment,
            runAlignment: runAlignment,
            children: children.map((item) {
              final span = item.spanFor(width, columns).clamp(1, columns).toInt();
              final itemWidth = cellWidth * span + spacing * (span - 1);

              return SizedBox(
                width: itemWidth,
                child: Align(
                  alignment: item.alignment ?? Alignment.centerLeft,
                  child: item.child,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class Dpndl004A13GridItem {
  const Dpndl004A13GridItem({
    required this.child,
    this.mobileSpan = 4,
    this.tabletSpan = 8,
    this.desktopSpan = 12,
    this.alignment,
  });

  final Widget child;
  final int mobileSpan;
  final int tabletSpan;
  final int desktopSpan;
  final AlignmentGeometry? alignment;

  int spanFor(double width, int columns) {
    if (width >= 905) return desktopSpan;
    if (width >= 600) return tabletSpan;
    return mobileSpan;
  }
}
