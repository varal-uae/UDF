/// A sparkline: the narrowest chart in the set, and the hardest test of the
/// Step 51 geometry rules.
///
/// AISS: GEN-03039-A01 (the SLI health view that consumes it) and
/// GEN-01330-A01 (the package that contains it).
///
/// It is the same painter as the trend chart with the axis furniture removed,
/// not a second implementation: [HabotChartRatio.sparkline] already tells the
/// geometry to give the whole height to the plot and no subdivisions to the
/// grid, so a sparkline is a configuration of the rules rather than an
/// exception to them.
library;

import 'package:flutter/material.dart';

import 'chart_geometry.dart';

/// A label-free trend line sized to sit inside a table row or a KPI card.
class HabotSparkline extends StatelessWidget {
  const HabotSparkline({
    required this.series,
    this.width = defaultWidth,
    this.colour,
    super.key,
  });

  final HabotChartSeries series;
  final double width;

  /// Null takes the scheme's primary. Passed in when the sparkline sits beside
  /// a status badge and should agree with it.
  final Color? colour;

  static const double defaultWidth = 96;
  static const Key sparklineKey = Key('habot.chart.sparkline');

  /// The height this sparkline will occupy. Public because Step 61's skeleton
  /// has to reserve exactly this much space, and a skeleton that guesses is
  /// the thing that causes layout shift.
  double get height =>
      HabotChartRatio.sparkline.heightFor(width < HabotChartSpec.minChartWidth
          ? HabotChartSpec.minChartWidth
          : width);

  @override
  Widget build(BuildContext context) {
    final HabotChartGeometry geometry = HabotChartSpec.resolve(
      width: width,
      series: series,
      ratio: HabotChartRatio.sparkline,
    );
    return SizedBox(
      key: sparklineKey,
      width: geometry.width,
      height: geometry.height,
      child: CustomPaint(
        painter: _SparklinePainter(
          series: series,
          geometry: geometry,
          colour: colour ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.series,
    required this.geometry,
    required this.colour,
  });

  final HabotChartSeries series;
  final HabotChartGeometry geometry;
  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.points.isEmpty) {
      return;
    }
    canvas.save();
    canvas.translate(HabotChartAxis.valueLabelGutter, 0);
    final Path path = Path();
    for (int i = 0; i < series.points.length; i++) {
      final ({double dx, double dy}) o =
          geometry.offsetFor(series.points[i], series.points.length);
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = colour
        ..strokeWidth = geometry.strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.series != series || old.colour != colour;
}
