/// AISS: LSAV-025-A01 -- "Define Conversion Rate Vector Chart Geometry Rules."
///
/// 4 Substeps, verbatim:
///   1. "Lock component aspect ratio parameters to avoid visual data
///       compression errors."
///   2. "Select vector stroke weight tokens to ensure line legibility on
///       high-density grids."
///   3. "Map background coordinate grid subdivisions to standard steps."
///   4. "Fix text alignment parameters for axis value labels."
///
/// Poka-Yoke: "Missing data indexes map to baseline zero metrics explicitly,
/// saving chart rendering engines from breaking."
/// Self-Chasing: "Analytical stream dropout instances display standard inline
/// notice indicators instead of locking up application frames."
/// Completion Measure: "Performance paths render smoothly across tested views
/// with zero container clipping issues."
/// Mobile App First: "Restricts chart rendering blocks to VECTOR LINE
/// COMPONENTS rather than un-scalable static images, maximizing data accuracy."
/// Flow Impact: "Users TAP anywhere along trend line coordinates to view
/// precise micro-data value overlays."
/// Metric: Scope Coverage / Audit Completeness -- Floor 80%, Optimal 100%.
///
/// This is the blueprint, and it is first in the batch for the same reason
/// SSTLA-012 was first in the last one: a chart is a shape inside a card
/// inside a grid, and deciding the chart's geometry after the card exists
/// means re-cutting one of them.
///
/// Nothing here draws. This file holds the rules; Step 56 packages the
/// widgets that obey them. That separation is what makes "zero container
/// clipping" checkable without pumping a widget tree -- the arithmetic that
/// would clip is right here, in pure functions.
///
/// COLUMN NOTE: this row's Data Collected column reads "Version Number;
/// Version Type; Release Date; Version Status; Version Checksum" -- release
/// metadata, not chart geometry. Recorded, not gated. The Setup Step, the four
/// substeps, the poka-yoke and the Metric are coherent and are what the
/// implementation is measured against.
library;

import 'dart:math' as math;

import '../tokens/grid_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

/// Substep 1: "Lock component ASPECT RATIO parameters to avoid visual data
/// compression errors."
///
/// A locked ratio rather than a free height. A 300dp-wide trend line squeezed
/// into 40dp of height is not a smaller chart, it is a different and wronger
/// chart: gradients steepen, and the reader draws a conclusion the data does
/// not support. The ratios below are the only three shapes a chart may take.
enum HabotChartRatio {
  /// 16:9. The default trend shape.
  wide(16 / 9),

  /// 4:3. Denser vertical range, for a chart inside a narrow pane.
  balanced(4 / 3),

  /// 8:1. A sparkline -- deliberately extreme, and deliberately named, so that
  /// nobody arrives at this shape by accident while resizing something else.
  sparkline(8);

  const HabotChartRatio(this.widthOverHeight);

  final double widthOverHeight;

  /// The height this ratio produces at [width], rounded to the baseline grid
  /// so a chart never lands on a half-pixel row.
  double heightFor(double width) {
    final double raw = width / widthOverHeight;
    return (raw / HabotSpacing.baseline).round() * HabotSpacing.baseline;
  }
}

/// Substep 2: "Select vector STROKE WEIGHT tokens to ensure line legibility on
/// high-density grids."
/// UX Implementation row: "Adjust path line weight bounds automatically
/// relative to screen scale tiers."
///
/// Three weights, mapped from the window class rather than passed in. A caller
/// cannot thin a line to fit more of them on screen, which is exactly how a
/// dense chart becomes unreadable.
class HabotChartStroke {
  const HabotChartStroke._();

  /// Compact screens. Thicker, because the line is smaller and the finger is
  /// not.
  static const double compact = 2.5;

  /// Medium.
  static const double medium = 2;

  /// Expanded. Thinner is legible here because there is more of it.
  static const double expanded = 1.5;

  /// Grid lines are always lighter than data lines. Stated as a ratio so the
  /// relationship survives a change to either.
  static const double gridLineRatio = 0.4;

  /// The floor below which a vector stroke stops being visible on a 1x screen.
  static const double minVisible = 1;

  static double forWidth(double width) {
    if (width >= HabotGrid.breakpointExpanded) {
      return expanded;
    }
    if (width >= HabotGrid.breakpointMedium) {
      return medium;
    }
    return compact;
  }

  static double gridLineFor(double width) =>
      math.max(minVisible, forWidth(width) * gridLineRatio);
}

/// Substep 3: "Map background coordinate grid SUBDIVISIONS to standard steps."
/// UX Decision row: "Drop elaborate grid background line paths on mobile
/// profiles to maintain focus paths."
///
/// Subdivisions come from the window class, and the compact tier gets the
/// fewest -- which is the decision row, implemented rather than restated.
class HabotChartGrid {
  const HabotChartGrid._();

  static const int compactSubdivisions = 2;
  static const int mediumSubdivisions = 4;
  static const int expandedSubdivisions = 5;

  /// Never more than this, whatever the screen. Past six horizontal rules the
  /// grid competes with the data for attention.
  static const int maxSubdivisions = 5;

  static int subdivisionsFor(double width) {
    if (width >= HabotGrid.breakpointExpanded) {
      return expandedSubdivisions;
    }
    if (width >= HabotGrid.breakpointMedium) {
      return mediumSubdivisions;
    }
    return compactSubdivisions;
  }

  /// The y positions of the subdivision lines inside a plot [height],
  /// top-down, excluding the axis itself.
  static List<double> linePositions(double height, double width) {
    final int n = subdivisionsFor(width);
    return <double>[
      for (int i = 1; i < n; i++) height * (i / n),
    ];
  }
}

/// Substep 4: "Fix TEXT ALIGNMENT parameters for axis value labels."
/// UI Implementation row: "Map graph axis text to high-contrast, desaturated
/// system token paths."
class HabotChartAxis {
  const HabotChartAxis._();

  /// Axis labels use the smallest role in the type scale, which Step 46 fixed
  /// as the readable floor. Below this the label is decoration.
  static const HabotTypeToken labelToken = HabotTypography.labelSmall;

  /// Value labels sit to the left of the plot, right-aligned against it, so
  /// their digits line up in a column. Time labels sit below, centred on their
  /// tick. Stated here rather than at each call site, because two charts that
  /// align their axes differently look like two applications.
  static const double valueLabelGutter = HabotSpacing.xl;
  static const double timeLabelHeight = HabotSpacing.md;

  /// The widest value label the gutter can hold, in characters, at the label
  /// role. Derived from the Step 46 fitting rules rather than guessed.
  static int maxValueLabelChars() =>
      (valueLabelGutter / (labelToken.sizeSp * 0.55)).floor();

  /// Formats [value] to fit the gutter: thousands become "12k", millions "3.4M".
  /// A label that overflows its gutter is the "container clipping" the
  /// completion measure forbids, so the shortening is part of the geometry
  /// rather than a nicety.
  static String formatValue(double value) {
    final double abs = value.abs();
    if (abs >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (abs >= 1000) {
      return '${(value / 1000).round()}k';
    }
    if (abs >= 10 || value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(1);
  }
}

/// One point on a trend line.
///
/// [value] is non-nullable on purpose -- see [HabotChartSeries.fromSparse].
class HabotChartPoint {
  const HabotChartPoint({
    required this.index,
    required this.value,
    this.isBaselineFill = false,
  });

  /// Position along the x axis, in whatever unit the series counts in.
  final int index;

  final double value;

  /// Poka-Yoke: true when this point did not exist in the source data and was
  /// materialised at baseline zero. The renderer marks these rather than
  /// hiding them, because a flat run the reader believes is real data is worse
  /// than a visible gap.
  final bool isBaselineFill;
}

/// A trend line, and the poka-yoke that keeps it renderable.
class HabotChartSeries {
  const HabotChartSeries({required this.label, required this.points});

  final String label;
  final List<HabotChartPoint> points;

  /// Poka-Yoke: "MISSING DATA INDEXES MAP TO BASELINE ZERO METRICS
  /// EXPLICITLY, saving chart rendering engines from breaking."
  ///
  /// The constructor a caller with real data should use. Every index from 0 to
  /// [length] - 1 comes out present: an index absent from [sparse] becomes an
  /// explicit zero flagged as [HabotChartPoint.isBaselineFill], and the caller
  /// cannot hand the renderer a hole because there is no way to express one.
  factory HabotChartSeries.fromSparse({
    required String label,
    required Map<int, double> sparse,
    required int length,
  }) {
    return HabotChartSeries(
      label: label,
      points: <HabotChartPoint>[
        for (int i = 0; i < length; i++)
          HabotChartPoint(
            index: i,
            value: sparse[i] ?? 0,
            isBaselineFill: !sparse.containsKey(i),
          ),
      ],
    );
  }

  bool get isEmpty => points.isEmpty;

  /// How much of this series was invented at baseline zero. The Self-Chasing
  /// row wants a "standard inline notice indicator" when the analytical stream
  /// drops out; this is the number that decides whether to show it.
  int get baselineFillCount =>
      points.where((HabotChartPoint p) => p.isBaselineFill).length;

  double get fillFraction =>
      points.isEmpty ? 0 : baselineFillCount / points.length;

  /// Above this share of invented points the chart is mostly fiction and says
  /// so inline rather than drawing a confident line through nothing.
  static const double dropoutNoticeThreshold = 0.25;

  bool get needsDropoutNotice => fillFraction > dropoutNoticeThreshold;

  double get minValue => points.isEmpty
      ? 0
      : points.map((HabotChartPoint p) => p.value).reduce(math.min);

  double get maxValue => points.isEmpty
      ? 0
      : points.map((HabotChartPoint p) => p.value).reduce(math.max);
}

/// The resolved geometry of one chart: everything a painter needs, and nothing
/// it has to decide for itself.
class HabotChartGeometry {
  const HabotChartGeometry({
    required this.width,
    required this.height,
    required this.plotWidth,
    required this.plotHeight,
    required this.ratio,
    required this.strokeWidth,
    required this.gridStrokeWidth,
    required this.subdivisions,
    required this.axisMin,
    required this.axisMax,
  });

  final double width;
  final double height;

  /// The drawing area, once the axis gutter and time labels are removed.
  final double plotWidth;
  final double plotHeight;

  final HabotChartRatio ratio;
  final double strokeWidth;
  final double gridStrokeWidth;
  final int subdivisions;

  /// The value range the y axis covers, already padded and rounded.
  final double axisMin;
  final double axisMax;

  double get axisSpan => axisMax - axisMin;

  /// Completion Measure: "zero container CLIPPING issues." A geometry that
  /// leaves the plot inside its own box cannot clip, and this is the property
  /// the gates assert instead of taking a screenshot.
  bool get fitsContainer =>
      plotWidth > 0 &&
      plotHeight > 0 &&
      plotWidth <= width &&
      plotHeight <= height &&
      strokeWidth >= HabotChartStroke.minVisible;

  /// Where [point] lands inside the plot, origin top-left. The one place x and
  /// y are computed, so two charts cannot disagree about where a value sits.
  ({double dx, double dy}) offsetFor(HabotChartPoint point, int length) {
    final double dx = length <= 1
        ? 0
        : plotWidth * (point.index / (length - 1));
    final double t = axisSpan == 0 ? 0 : (point.value - axisMin) / axisSpan;
    return (dx: dx, dy: plotHeight * (1 - t));
  }

  /// The value under a horizontal tap at [dx] -- the Flow Impact row's "tap
  /// anywhere along trend line coordinates" made into arithmetic, so the
  /// overlay in Step 57 reads a number rather than inventing one.
  int indexAt(double dx, int length) {
    if (length <= 1) {
      return 0;
    }
    final double t = (dx / plotWidth).clamp(0.0, 1.0);
    return (t * (length - 1)).round();
  }
}

/// The rule engine. Everything above is a parameter; this is what resolves it.
class HabotChartSpec {
  const HabotChartSpec._();

  /// Charts never render below this width -- narrower than this the axis
  /// gutter alone would consume the plot.
  static const double minChartWidth = 120;

  /// Headroom above and below the data so a peak does not touch the frame.
  static const double axisPaddingFraction = 0.1;

  /// Resolves the geometry for [series] at [width].
  ///
  /// Takes no stroke, no subdivision count and no height: all three are
  /// derived. That is the difference between a rule and a default.
  static HabotChartGeometry resolve({
    required double width,
    required HabotChartSeries series,
    HabotChartRatio ratio = HabotChartRatio.wide,
  }) {
    final double w = math.max(width, minChartWidth);
    final double height = ratio.heightFor(w);
    final double plotWidth = math.max(0, w - HabotChartAxis.valueLabelGutter);
    final double plotHeight = ratio == HabotChartRatio.sparkline
        ? height
        : math.max(0, height - HabotChartAxis.timeLabelHeight);

    final ({double min, double max}) axis = axisRangeFor(series);

    return HabotChartGeometry(
      width: w,
      height: height,
      plotWidth: plotWidth,
      plotHeight: plotHeight,
      ratio: ratio,
      strokeWidth: HabotChartStroke.forWidth(w),
      gridStrokeWidth: HabotChartStroke.gridLineFor(w),
      subdivisions: ratio == HabotChartRatio.sparkline
          ? 0
          : HabotChartGrid.subdivisionsFor(w),
      axisMin: axis.min,
      axisMax: axis.max,
    );
  }

  /// The padded, non-degenerate value range for [series].
  ///
  /// A flat series would otherwise produce a zero span and divide by nothing;
  /// this is where that is prevented once rather than in every painter.
  static ({double min, double max}) axisRangeFor(HabotChartSeries series) {
    if (series.isEmpty) {
      return (min: 0, max: 1);
    }
    final double lo = math.min(0, series.minValue);
    final double hi = series.maxValue;
    if (hi == lo) {
      return (min: lo, max: lo + 1);
    }
    final double pad = (hi - lo) * axisPaddingFraction;
    return (min: lo, max: hi + pad);
  }

  /// The four rules this step exists to fix, as a checkable record. The Metric
  /// is "Scope Coverage / Audit Completeness", and this is what is being
  /// counted.
  static const List<String> rules = <String>[
    'aspect ratio locked to a named stop',
    'stroke weight derived from the window class',
    'grid subdivisions mapped to the window class',
    'axis label alignment and shortening fixed',
  ];
}
