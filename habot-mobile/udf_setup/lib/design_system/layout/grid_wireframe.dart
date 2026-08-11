/// AISS: SSTLA-004-A01 -- Expected Output: "Approved JSON Token File and an
/// **interactive structural layout wireframe** for compact mobile devices."
///
/// The JSON file is `lib/design_system/tokens/device_matrix.json`. This is the
/// wireframe half: an overlay that draws the live grid -- outer margins,
/// columns, gutters and the 8dp vertical rhythm -- on top of whatever is
/// rendered, at the actual current viewport width.
///
/// It exists so the breakpoint decision can be *seen* rather than argued about,
/// and so a reviewer can score the SSTLA-004 rubric against something concrete.
library;

import 'package:flutter/material.dart';

import '../tokens/grid_tokens.dart';

/// Paints the column/gutter/margin structure. Purely decorative; never
/// intercepts a pointer.
class GridWireframeOverlay extends StatelessWidget {
  const GridWireframeOverlay({
    required this.child,
    this.enabled = false,
    this.showRhythm = true,
    super.key,
  });

  final Widget child;

  /// Off by default. Turned on from the design-system probe screen.
  final bool enabled;

  /// Draw the 8dp vertical rhythm lines as well as the columns.
  final bool showRhythm;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Stack(
      children: <Widget>[
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _GridWireframePainter(
                columnColor: scheme.primary,
                rhythmColor: scheme.tertiary,
                showRhythm: showRhythm,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GridWireframePainter extends CustomPainter {
  const _GridWireframePainter({
    required this.columnColor,
    required this.rhythmColor,
    required this.showRhythm,
  });

  final Color columnColor;
  final Color rhythmColor;
  final bool showRhythm;

  static const double _columnOpacity = 0.14;
  static const double _rhythmOpacity = 0.10;

  @override
  void paint(Canvas canvas, Size size) {
    final int columns = HabotGrid.columnsFor(size.width);
    final double columnWidth = HabotGrid.columnWidth(size.width);
    final Paint columnPaint = Paint()
      ..color = columnColor.withValues(alpha: _columnOpacity);

    double x = HabotGrid.outerMargin;
    for (int i = 0; i < columns; i++) {
      canvas.drawRect(Rect.fromLTWH(x, 0, columnWidth, size.height), columnPaint);
      x += columnWidth + HabotGrid.gutter;
    }

    if (!showRhythm) {
      return;
    }
    final Paint rhythmPaint = Paint()
      ..color = rhythmColor.withValues(alpha: _rhythmOpacity)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += HabotGrid.verticalRhythm) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rhythmPaint);
    }
  }

  @override
  bool shouldRepaint(_GridWireframePainter oldDelegate) =>
      oldDelegate.columnColor != columnColor ||
      oldDelegate.rhythmColor != rhythmColor ||
      oldDelegate.showRhythm != showRhythm;
}

/// A read-only summary of the resolved grid at the current width, shown beside
/// the wireframe so the numbers and the picture are checked against each other.
class GridDecisionReadout extends StatelessWidget {
  const GridDecisionReadout({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double width = MediaQuery.sizeOf(context).width;
    final List<(String, String)> rows = <(String, String)>[
      ('Viewport', '${width.toStringAsFixed(0)}dp'),
      ('Window class', HabotGrid.windowClassFor(width).name),
      ('Columns', '${HabotGrid.columnsFor(width)}'),
      ('Column width', '${HabotGrid.columnWidth(width).toStringAsFixed(1)}dp'),
      ('Outer margin', '${HabotGrid.outerMargin.toStringAsFixed(0)}dp'),
      ('Column gutter', '${HabotGrid.gutter.toStringAsFixed(0)}dp'),
      ('Vertical rhythm', '${HabotGrid.verticalRhythm.toStringAsFixed(0)}dp'),
      ('Nav collapsed', '${HabotGrid.navigationIsCollapsed(width)}'),
    ];

    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
      },
      children: <TableRow>[
        for (final (String label, String value) in rows)
          TableRow(
            children: <Widget>[
              Text(label, style: theme.textTheme.bodySmall),
              Text(
                value,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.end,
              ),
            ],
          ),
      ],
    );
  }
}
