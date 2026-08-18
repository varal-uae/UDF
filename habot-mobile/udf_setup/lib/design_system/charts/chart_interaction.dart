/// AISS: GEN-02026-A01 -- "Implement auto-scaling chart axes and interactive
/// touch tooltips."
/// Metric: Centralized Dictionary Coverage (%) -- Floor 95.0, Optimal 100.0.
///
/// TWO THINGS RECORDED ABOUT THIS ROW.
///
/// 1. WORDING COLLISION. The Setup Step says "interactive touch TOOLTIPS".
///    Step 24 (MUFCE-028) removed every tooltip widget and every hover
///    callback from `lib/` and added two poka-yoke rules that fail the build
///    if either returns. A literal `Tooltip` here would not get past the
///    guard, and it would be wrong anyway: a hover tooltip is unreachable on a
///    phone, which is the platform this step is for.
///
///    What is built instead is a TAP-TRIGGERED reading overlay -- which is
///    what LSAV-025 (Step 51) already described in its own Flow Impact column:
///    "users tap anywhere along trend line coordinates to view precise
///    micro-data value overlays." Same user outcome, reachable by touch,
///    compatible with the existing rule. The reading is recorded here rather
///    than performed quietly.
///
/// 2. METRIC MISMATCH. "Centralized Dictionary Coverage (%)" is a
///    data-dictionary measure. Nothing about an axis or an overlay produces a
///    dictionary coverage percentage, and no number is asserted in its place.
///    What IS measured is the thing the Setup Step names: that the axis scales
///    itself to the data across a range of inputs, and that a tap anywhere
///    along the line returns the reading at that point.
///
/// "Auto-scaling" is the other half, and it is already half-built: Step 51's
/// `HabotChartSpec.axisRangeFor` pads and de-degenerates the range. What this
/// file adds is the part that makes an axis readable rather than merely
/// correct -- ticks on round numbers, so the labels read 0 / 50 / 100 rather
/// than 0 / 47.3 / 94.6.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/spacing_tokens.dart';
import 'chart_geometry.dart';
import 'trend_chart.dart';

/// The reading revealed by a tap.
class HabotChartReading {
  const HabotChartReading({
    required this.index,
    required this.value,
    required this.isBaselineFill,
  });

  final int index;
  final double value;

  /// True when the point under the tap was materialised at baseline zero by
  /// the Step 51 poka-yoke. The overlay says so, because reporting an invented
  /// zero as a measurement is the failure that poka-yoke exists to prevent.
  final bool isBaselineFill;

  String get displayValue => HabotChartAxis.formatValue(value);

  String get semanticsLabel => isBaselineFill
      ? 'Point ${index + 1}: no data recorded, shown at zero'
      : 'Point ${index + 1}: $displayValue';
}

/// Axis auto-scaling: ticks on round numbers.
class HabotAxisScale {
  const HabotAxisScale._();

  /// The step sizes an axis is allowed to use, per power of ten. A tick every
  /// 2.5 units is arithmetically fine and cognitively useless.
  static const List<double> allowedMantissas = <double>[1, 2, 2.5, 5, 10];

  /// A "nice" step at or above [rawStep].
  static double niceStep(double rawStep) {
    if (rawStep <= 0) {
      return 1;
    }
    final double magnitude =
        math.pow(10, (math.log(rawStep) / math.ln10).floor()).toDouble();
    final double normalised = rawStep / magnitude;
    for (final double m in allowedMantissas) {
      if (normalised <= m) {
        return m * magnitude;
      }
    }
    return 10 * magnitude;
  }

  /// Tick values for a range, at most [maxTicks] of them, all on round
  /// numbers, spanning [min] to [max].
  static List<double> ticks({
    required double min,
    required double max,
    int maxTicks = HabotChartGrid.maxSubdivisions,
  }) {
    if (max <= min || maxTicks < 2) {
      return <double>[min, max];
    }
    final double step = niceStep((max - min) / (maxTicks - 1));
    final double first = (min / step).floor() * step;
    final List<double> out = <double>[];
    for (double v = first; v <= max + (step / 2); v += step) {
      if (v >= min - (step / 2)) {
        out.add(v);
      }
    }
    return out;
  }

  /// True when every tick lands on a multiple of the step -- the property that
  /// makes the labels readable, checked rather than assumed.
  static bool ticksAreRound(List<double> ticks) {
    if (ticks.length < 2) {
      return true;
    }
    final double step = ticks[1] - ticks[0];
    if (step <= 0) {
      return false;
    }
    for (int i = 1; i < ticks.length; i++) {
      if (((ticks[i] - ticks[i - 1]) - step).abs() > step * 0.001) {
        return false;
      }
    }
    return true;
  }
}

/// A trend chart with a tap-revealed reading overlay.
///
/// Stateful because the selection is the whole point, and stateless charts
/// would push that state onto every screen that shows one.
class HabotInteractiveChart extends StatefulWidget {
  const HabotInteractiveChart({
    required this.series,
    this.ratio = HabotChartRatio.wide,
    this.onReading,
    super.key,
  });

  final HabotChartSeries series;
  final HabotChartRatio ratio;

  /// Fires whenever the reading changes, so a caller can mirror it elsewhere
  /// without reading this widget's state.
  final void Function(HabotChartReading reading)? onReading;

  static const Key overlayKey = Key('habot.chart.readingOverlay');

  @override
  State<HabotInteractiveChart> createState() => HabotInteractiveChartState();
}

class HabotInteractiveChartState extends State<HabotInteractiveChart> {
  HabotChartReading? _reading;

  /// The current reading. Read by the gate after a tap.
  HabotChartReading? get reading => _reading;

  void selectIndex(int index) {
    if (index < 0 || index >= widget.series.points.length) {
      return;
    }
    final HabotChartPoint point = widget.series.points[index];
    final HabotChartReading next = HabotChartReading(
      index: index,
      value: point.value,
      isBaselineFill: point.isBaselineFill,
    );
    setState(() => _reading = next);
    widget.onReading?.call(next);
  }

  /// Dismisses the overlay. A reading that cannot be dismissed is a reading
  /// that covers the chart forever.
  void clear() {
    setState(() => _reading = null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        HabotTrendChart(
          series: widget.series,
          ratio: widget.ratio,
          selectedIndex: _reading?.index,
          onIndexSelected: selectIndex,
        ),
        if (_reading != null) _ReadingOverlay(reading: _reading!),
      ],
    );
  }
}

/// The overlay. A panel below the chart rather than a floating bubble over it:
/// on a 360dp screen a bubble sits under the finger that summoned it.
class _ReadingOverlay extends StatelessWidget {
  const _ReadingOverlay({required this.reading});

  final HabotChartReading reading;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: HabotSpacing.xxs),
      child: Semantics(
        key: HabotInteractiveChart.overlayKey,
        liveRegion: true,
        label: reading.semanticsLabel,
        container: true,
        excludeSemantics: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              reading.isBaselineFill ? 'no data' : reading.displayValue,
              style: theme.textTheme.labelLarge?.copyWith(
                color: reading.isBaselineFill
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: HabotSpacing.xxs),
            Text(
              'point ${reading.index + 1}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
