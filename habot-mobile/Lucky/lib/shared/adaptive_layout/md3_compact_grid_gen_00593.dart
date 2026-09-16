// GEN-00593 - Material Design 3 Compact Mobile Layout Grid System.
// Defines compact viewport rules (0-480px): 4 fluid columns, 16px margins, 8px gutters.

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Material Design 3 compact viewport grid specification.
class Md3CompactGridSpec {
  const Md3CompactGridSpec._();

  static const double minViewportWidth = 0.0;
  static const double maxViewportWidth = 480.0;
  static const int columns = 4;
  static const double margin = 16.0;
  static const double gutter = 8.0;

  static bool isCompact(double width) =>
      width >= minViewportWidth && width <= maxViewportWidth;

  static double columnWidth(double viewportWidth) {
    final effectiveWidth = math.min(viewportWidth, maxViewportWidth);
    final available = effectiveWidth - (margin * 2) - (gutter * (columns - 1));
    return available <= 0 ? 0 : available / columns;
  }
}

/// A Material 3 compact grid that lays out exactly four fluid columns.
class Md3CompactGrid extends StatelessWidget {
  const Md3CompactGrid({
    super.key,
    required this.children,
    this.semanticLabel,
  }) : assert(children.length == Md3CompactGridSpec.columns,
            'Md3CompactGrid requires exactly 4 children.');

  final List<Widget> children;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final rowChildren = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rowChildren.add(Expanded(child: children[i]));
      if (i < children.length - 1) {
        rowChildren.add(const SizedBox(width: Md3CompactGridSpec.gutter));
      }
    }

    return Semantics(
      label: semanticLabel,
      container: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Md3CompactGridSpec.maxViewportWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Md3CompactGridSpec.margin,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rowChildren,
            ),
          ),
        ),
      ),
    );
  }
}
