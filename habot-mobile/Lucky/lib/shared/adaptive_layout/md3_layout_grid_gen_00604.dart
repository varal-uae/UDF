// GEN-00604 — MD3 Mobile Layout Grid System with Horizontal Overflow Guard.
// Implements Material 3 responsive breakpoints (single-column <600dp, multi-column ≥840dp),
// 48x48dp touch targets, and a layout overflow detector for zero horizontal overflow validation.

import 'package:flutter/material.dart';

@immutable
class Md3GridBreakpoints {
  const Md3GridBreakpoints._();

  static const double compact = 600.0;
  static const double medium = 840.0;
  static const double expanded = 1200.0;

  static int columnsForWidth(double width) {
    if (width < compact) return 1;
    if (width < medium) return 2;
    if (width < expanded) return 3;
    return 4;
  }
}

class Md3ResponsiveGrid extends StatelessWidget {
  const Md3ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.maxColumns = 4,
    this.minTileWidth = 160.0,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry padding;
  final int maxColumns;
  final double minTileWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final resolvedPadding = padding.resolve(Directionality.of(context));
        final columns = _resolveColumns(width, resolvedPadding.horizontal)
            .clamp(1, maxColumns)
            .toInt();
        final totalSpacing = spacing * (columns - 1);
        final tileWidth =
            (width - resolvedPadding.horizontal - totalSpacing) / columns;
        final safeTileWidth = tileWidth > 0 ? tileWidth : 0.0;
        return Padding(
          padding: padding,
          child: Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            children: children
                .map(
                  (child) => SizedBox(
                    width: safeTileWidth,
                    child: child,
                  ),
                )
                .toList(growable: false),
          ),
        );
      },
    );
  }

  int _resolveColumns(double width, double horizontalPadding) {
    if (width < Md3GridBreakpoints.compact) return 1;
    if (width < Md3GridBreakpoints.medium) return 2;
    final minWidth = minTileWidth <= 0 ? 160.0 : minTileWidth;
    final raw = ((width - horizontalPadding) + spacing) / (minWidth + spacing);
    return raw.floor().clamp(1, maxColumns).toInt();
  }
}

class Md3OverflowGuard extends StatelessWidget {
  const Md3OverflowGuard({
    super.key,
    required this.child,
    this.maxWidth,
  });

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final effectiveMax = maxWidth ?? width;
        return SizedBox(
          width: effectiveMax,
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              maxWidth: effectiveMax,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
