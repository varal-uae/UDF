/// AISS: GEN-01330-A01 -- "Package chart components into
/// @habot/charts/mobile-spend."
/// Metric: Budget Visualization Data Accuracy -- Floor 0.98, Optimal 0.999,
/// Ceiling 1.0. One of the few GEN-* metrics in this batch that fits its step:
/// a chart that draws a point somewhere other than where its value is has an
/// accuracy problem, and that is measurable.
///
/// On the package name: this is a single-module Flutter app, so there is no
/// separate pub package to publish. What the sheet is asking for is a
/// BOUNDARY -- one public surface for charts, so a screen imports charts from
/// one place and cannot reach inside them. `habot_charts.dart` is that
/// surface; this file is the implementation behind it. The mapping from
/// `@habot/charts/mobile-spend` to `lib/design_system/charts/` is recorded in
/// the gate file rather than assumed, the same way Step 42 took its file name
/// from the sheet.
///
/// The renderer draws vectors, never a raster -- the Mobile App First row is
/// explicit about that ("vector line components rather than un-scalable static
/// images"), and it is also what makes the accuracy metric meaningful: a
/// vector path can be checked against the arithmetic that produced it.
library;

import 'package:flutter/material.dart';

import '../tokens/spacing_tokens.dart';
import 'chart_geometry.dart';

/// A trend line, drawn to the Step 51 geometry.
class HabotTrendChart extends StatelessWidget {
  const HabotTrendChart({
    required this.series,
    this.ratio = HabotChartRatio.wide,
    this.selectedIndex,
    this.onIndexSelected,
    super.key,
  });

  final HabotChartSeries series;
  final HabotChartRatio ratio;

  /// The point currently revealed by a tap. Null means none.
  final int? selectedIndex;

  /// Step 57 supplies this.
  final void Function(int index)? onIndexSelected;

  static const Key chartKey = Key('habot.chart.trend');
  static const Key dropoutNoticeKey = Key('habot.chart.dropoutNotice');

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : HabotChartSpec.minChartWidth;
        final HabotChartGeometry geometry = HabotChartSpec.resolve(
          width: width,
          series: series,
          ratio: ratio,
        );
        return Column(
          key: chartKey,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Self-Chasing: "Analytical stream dropout instances display
            // standard inline notice indicators instead of locking up
            // application frames." The notice sits above the chart, and the
            // chart still draws.
            if (series.needsDropoutNotice)
              _DropoutNotice(series: series),
            SizedBox(
              width: geometry.width,
              height: geometry.height,
              child: _ChartSurface(
                series: series,
                geometry: geometry,
                selectedIndex: selectedIndex,
                onIndexSelected: onIndexSelected,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DropoutNotice extends StatelessWidget {
  const _DropoutNotice({required this.series});

  final HabotChartSeries series;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String text =
        '${series.baselineFillCount} of ${series.points.length} points were '
        'missing and are shown at zero';
    return Padding(
      padding: const EdgeInsets.only(bottom: HabotSpacing.xxs),
      child: Row(
        key: HabotTrendChart.dropoutNoticeKey,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.info_outline,
            size: HabotSpacing.md,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: HabotSpacing.xxs),
          Flexible(
            child: Text(
              text,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartSurface extends StatelessWidget {
  const _ChartSurface({
    required this.series,
    required this.geometry,
    required this.selectedIndex,
    required this.onIndexSelected,
  });

  final HabotChartSeries series;
  final HabotChartGeometry geometry;
  final int? selectedIndex;
  final void Function(int index)? onIndexSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    // Not a const fallback: `HabotChartAxis.labelToken.sizeSp` is a field read
    // on a const object, which Dart will not accept inside a const expression.
    final TextStyle labelStyle =
        Theme.of(context).textTheme.labelSmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ) ??
        TextStyle(
          fontSize: HabotChartAxis.labelToken.sizeSp,
          color: scheme.onSurfaceVariant,
        );

    final Widget painted = CustomPaint(
      painter: _TrendPainter(
        series: series,
        geometry: geometry,
        lineColour: scheme.primary,
        gridColour: scheme.outlineVariant,
        fillColour: scheme.primary,
        baselineColour: scheme.onSurfaceVariant,
        selectedIndex: selectedIndex,
        labelStyle: labelStyle,
        textDirection: Directionality.of(context),
      ),
      size: Size(geometry.width, geometry.height),
    );

    if (onIndexSelected == null) {
      return painted;
    }
    // Flow Impact: "Users TAP anywhere along trend line coordinates to view
    // precise micro-data value overlays." A tap, not a hover -- Step 24
    // removed every hover affordance from lib/, and a chart is not an
    // exception to that.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (TapDownDetails details) {
        final double dx =
            details.localPosition.dx - HabotChartAxis.valueLabelGutter;
        onIndexSelected!(geometry.indexAt(dx, series.points.length));
      },
      child: painted,
    );
  }
}

/// The vector painter. Every coordinate comes from [HabotChartGeometry], so
/// the accuracy metric is a property of the geometry and not of this file.
class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.series,
    required this.geometry,
    required this.lineColour,
    required this.gridColour,
    required this.fillColour,
    required this.baselineColour,
    required this.selectedIndex,
    required this.labelStyle,
    required this.textDirection,
  });

  final HabotChartSeries series;
  final HabotChartGeometry geometry;
  final Color lineColour;
  final Color gridColour;
  final Color fillColour;
  final Color baselineColour;
  final int? selectedIndex;
  final TextStyle labelStyle;
  final TextDirection textDirection;

  /// UI Decision row: "Apply transparent gradient fill tokens underneath data
  /// line paths for clean zoning."
  static const double fillTopOpacity = 0.24;
  static const double fillBottomOpacity = 0.0;
  static const double selectedDotRadius = 4;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(HabotChartAxis.valueLabelGutter, 0);
    _paintGrid(canvas);
    if (series.points.isNotEmpty) {
      _paintFill(canvas);
      _paintLine(canvas);
      _paintSelection(canvas);
    }
    canvas.restore();
    _paintAxisLabels(canvas);
  }

  void _paintGrid(Canvas canvas) {
    final Paint paint = Paint()
      ..color = gridColour
      ..strokeWidth = geometry.gridStrokeWidth;
    for (final double y in HabotChartGrid.linePositions(
      geometry.plotHeight,
      geometry.width,
    )) {
      canvas.drawLine(Offset(0, y), Offset(geometry.plotWidth, y), paint);
    }
  }

  Path _linePath() {
    final Path path = Path();
    for (int i = 0; i < series.points.length; i++) {
      final ({double dx, double dy}) o = geometry.offsetFor(
        series.points[i],
        series.points.length,
      );
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    return path;
  }

  void _paintFill(Canvas canvas) {
    final Path path = _linePath()
      ..lineTo(geometry.plotWidth, geometry.plotHeight)
      ..lineTo(0, geometry.plotHeight)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            fillColour.withValues(alpha: fillTopOpacity),
            fillColour.withValues(alpha: fillBottomOpacity),
          ],
        ).createShader(
          Rect.fromLTWH(0, 0, geometry.plotWidth, geometry.plotHeight),
        ),
    );
  }

  void _paintLine(Canvas canvas) {
    canvas.drawPath(
      _linePath(),
      Paint()
        ..color = lineColour
        ..strokeWidth = geometry.strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    // Poka-Yoke, made visible: points that were materialised at baseline zero
    // are marked, so a flat run is not mistaken for a measured one.
    for (final HabotChartPoint point in series.points) {
      if (!point.isBaselineFill) {
        continue;
      }
      final ({double dx, double dy}) o =
          geometry.offsetFor(point, series.points.length);
      canvas.drawCircle(
        Offset(o.dx, o.dy),
        geometry.strokeWidth,
        Paint()
          ..color = baselineColour
          ..style = PaintingStyle.stroke
          ..strokeWidth = geometry.gridStrokeWidth,
      );
    }
  }

  void _paintSelection(Canvas canvas) {
    final int? index = selectedIndex;
    if (index == null || index < 0 || index >= series.points.length) {
      return;
    }
    final ({double dx, double dy}) o = geometry.offsetFor(
      series.points[index],
      series.points.length,
    );
    canvas.drawLine(
      Offset(o.dx, 0),
      Offset(o.dx, geometry.plotHeight),
      Paint()
        ..color = lineColour
        ..strokeWidth = geometry.gridStrokeWidth,
    );
    canvas.drawCircle(
      Offset(o.dx, o.dy),
      selectedDotRadius,
      Paint()..color = lineColour,
    );
  }

  /// Substep 4: axis value labels, right-aligned in their gutter so digits
  /// line up in a column.
  void _paintAxisLabels(Canvas canvas) {
    final List<double> positions = <double>[0, geometry.plotHeight];
    final List<double> values = <double>[geometry.axisMax, geometry.axisMin];
    for (int i = 0; i < positions.length; i++) {
      final TextPainter painter = TextPainter(
        text: TextSpan(
          text: HabotChartAxis.formatValue(values[i]),
          style: labelStyle,
        ),
        textDirection: textDirection,
        textAlign: TextAlign.right,
      )..layout(maxWidth: HabotChartAxis.valueLabelGutter);
      painter.paint(
        canvas,
        Offset(
          HabotChartAxis.valueLabelGutter - painter.width - HabotSpacing.xxs,
          (positions[i] - (painter.height / 2)).clamp(
            0,
            geometry.height - painter.height,
          ),
        ),
      );
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.series != series ||
      old.selectedIndex != selectedIndex ||
      old.geometry.width != geometry.width ||
      old.lineColour != lineColour;
}
