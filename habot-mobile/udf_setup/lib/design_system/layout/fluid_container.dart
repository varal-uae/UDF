/// AISS: TTMCS-001-A01 -- substep 3 "Configure global fluid containers that
/// reflow components dynamically based on screen widths."
/// AISS: TTMCS-001 UI implementation -- "Layout structures enforce strict
/// vertical component stacks on phone profiles."
library;

import 'package:flutter/material.dart';

import '../tokens/grid_tokens.dart';
import '../tokens/spacing_tokens.dart';

/// The one container every screen body is wrapped in.
///
/// It never sets a fixed pixel width: it measures the incoming constraints and
/// applies the token grid. On compact viewports children are forced into a
/// single vertical column, which is the "strict vertical component stacks on
/// phone profiles" rule from the step sheet.
class HabotFluidContainer extends StatelessWidget {
  const HabotFluidContainer({
    required this.children,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    super.key,
  });

  final List<Widget> children;

  /// Defaults to the token outer margin. Override only with token values.
  final EdgeInsetsGeometry? padding;

  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final HabotWindowClass windowClass = HabotGrid.windowClassFor(width);

        // Expanded viewports get a reading-width cap so line length stays
        // comfortable; compact and medium fill the available width.
        final double maxContentWidth = windowClass == HabotWindowClass.expanded
            ? HabotGrid.breakpointExpanded
            : double.infinity;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(
              padding:
                  padding ??
                  const EdgeInsets.symmetric(
                    horizontal: HabotGrid.outerMargin,
                    vertical: HabotSpacing.md,
                  ),
              child: Column(
                crossAxisAlignment: crossAxisAlignment,
                mainAxisSize: MainAxisSize.min,
                children: _withGutters(children),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Insert the token gutter between children instead of letting each child
  /// invent its own margin.
  static List<Widget> _withGutters(List<Widget> children) {
    if (children.length < 2) {
      return children;
    }
    final List<Widget> spaced = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spaced.add(children[i]);
      if (i != children.length - 1) {
        spaced.add(const SizedBox(height: HabotGrid.gutter));
      }
    }
    return spaced;
  }
}

/// Places [children] across the token column matrix: 4 columns on compact,
/// 8 on medium, 12 on expanded. Each child declares how many columns it spans
/// via [HabotGridSpan]; a span wider than the current matrix is clamped, which
/// is what keeps 320dp viewports free of horizontal overflow.
class HabotColumnMatrix extends StatelessWidget {
  const HabotColumnMatrix({required this.children, super.key});

  final List<HabotGridSpan> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final int columns = HabotGrid.columnsFor(width);
        final double columnWidth =
            (width - (HabotGrid.gutter * (columns - 1))) / columns;

        return Wrap(
          spacing: HabotGrid.gutter,
          runSpacing: HabotGrid.gutter,
          children: children.map((HabotGridSpan span) {
            final int effective = span.span > columns ? columns : span.span;
            final double itemWidth =
                (columnWidth * effective) +
                (HabotGrid.gutter * (effective - 1));
            return SizedBox(
              width: itemWidth < 0 ? 0 : itemWidth,
              child: span.child,
            );
          }).toList(),
        );
      },
    );
  }
}

@immutable
class HabotGridSpan {
  const HabotGridSpan({required this.span, required this.child})
    : assert(span > 0, 'A grid span must cover at least one column');

  /// Number of grid columns this child occupies. Clamped to the active matrix.
  final int span;
  final Widget child;
}
