/// AISS: GEN-00213-A01 -- "Programmatically translate bounding coordinates
/// into fluid CSS grid containers."
/// METRIC MISMATCH, RECORDED: this row's metric is "Service Availability /
/// Failover Recovery Time" (Floor <= 30s automatic rollback RTO, Optimal <= 1s
/// failover). That is an SRE reliability measure. Coordinate arithmetic has no
/// RTO, and none is invented here -- the metric is reported as NOT PRODUCED,
/// and what the step actually names IS measurable and is what the gates
/// defend: the same box resolves to the same container, on every device.
///
/// AISS: GEN-00280-A01 -- "Scale the cropped image snippet to span 100% of the
/// 4-column mobile grid width."
/// Metric: Cross-Viewport Rendering Consistency -- Floor "zero regressions on
/// primary breakpoints (360/390/412px)", Optimal "zero regressions across full
/// tested device matrix".
///
/// This is one of the few metrics in this batch that both fits its step and is
/// directly measurable: resolve the snippet across the device matrix from Step
/// 5 and count the regressions. The answer should be zero, and the gate says
/// how many it actually found rather than asserting the intent.
///
/// TRANSLATION, RECORDED: "fluid CSS grid containers" is CSS. In Flutter that
/// is a rect resolved against `HabotGrid` -- the 4-column compact grid with a
/// 16dp outer margin that Step 7 already gated. This file READS those tokens;
/// it does not restate them, because a second set of column rules is a second
/// answer to the same question.
library;

import 'dart:math' as math;
import 'dart:ui' show Rect, Size;

import 'package:flutter/foundation.dart';

import '../tokens/grid_tokens.dart';
import 'byt_isolation.dart';

/// The geometry of one crop, resolved for one viewport.
@immutable
class HabotSnippetLayout {
  const HabotSnippetLayout({
    required this.container,
    required this.scale,
    required this.clipped,
    required this.fillsContentWidth,
    required this.columns,
  });

  /// Where the snippet goes, in screen coordinates.
  final Rect container;

  /// Rendered pixels per source pixel. Below
  /// [HabotCropPadding.minLegibleScale] the worker has to pinch, which the
  /// Step 82 constraint set counts as a failure.
  final double scale;

  /// True when the snippet had to be trimmed to fit the pane it was given.
  /// A clipped snippet is a regression: the worker is missing part of the
  /// evidence and has no way to know it.
  final bool clipped;

  /// True when the snippet spans the full 4-column content width -- what
  /// GEN-00280 asks for. False when the pane's height bound it first, which
  /// happens on a phone held sideways and is recorded rather than hidden.
  final bool fillsContentWidth;

  /// How many grid columns the container spans. Compact screens have four, and
  /// the step asks for all of them.
  final int columns;

  double get width => container.width;
  double get height => container.height;
}

/// GEN-00213 + GEN-00280: box in, container out.
class HabotIsolationGeometry {
  const HabotIsolationGeometry._();

  /// The primary breakpoints the Cross-Viewport metric names by width.
  static const List<double> primaryBreakpoints = <double>[360, 390, 412];

  /// The snippet spans the full content width: the viewport minus the grid's
  /// own margins on both sides. On a 360dp phone that is 328dp, which is
  /// "100% of the 4-column mobile grid width" expressed in the units the rest
  /// of the app already uses.
  static double contentWidthFor(double viewportWidth) =>
      viewportWidth - (HabotGrid.outerMargin * 2);

  /// How many columns the content width spans, from the same breakpoint table
  /// Step 7 gated. Compact returns 4, which is what GEN-00280 asks for.
  static int columnsFor(double viewportWidth) {
    if (viewportWidth >= HabotGrid.breakpointExpanded) {
      return HabotGrid.expandedColumns;
    }
    if (viewportWidth >= HabotGrid.breakpointMedium) {
      return HabotGrid.mediumColumns;
    }
    return HabotGrid.compactColumns;
  }

  /// Resolves [box] into a container inside a pane of [paneSize], anchored at
  /// [origin].
  ///
  /// PURE. Same box, same pane, same answer -- every time, on every device.
  /// That property is what GEN-00213 is really asking for, and the gate
  /// asserts it by resolving the same input twice and comparing.
  ///
  /// WIDTH FIRST, HEIGHT AS A LIMIT. GEN-00280 asks the snippet to span the
  /// full 4-column content width, and on every portrait phone it does. On a
  /// phone held sideways the evidence pane is barely 180dp tall, and a
  /// full-width snippet would not fit in it -- so the width is reduced to
  /// whatever the pane's HEIGHT allows, preserving the crop's aspect ratio.
  ///
  /// That trade is deliberate and is recorded on the layout: [fillsContentWidth]
  /// says which of the two happened. Clipping was the alternative, and clipping
  /// hides part of the evidence from a worker who has no way to know it is
  /// missing -- which is the one thing this whole batch exists to prevent.
  static HabotSnippetLayout resolve({
    required HabotBoundingBox box,
    required Size paneSize,
    required double viewportWidth,
    double originX = HabotGrid.outerMargin,
    double originY = 0,
  }) {
    final double contentWidth = math.min(
      contentWidthFor(viewportWidth),
      paneSize.width,
    );
    final double aspect = box.aspectRatio;
    if (aspect <= 0) {
      return HabotSnippetLayout(
        container: Rect.fromLTWH(originX, originY, contentWidth, 0),
        scale: 0,
        clipped: true,
        fillsContentWidth: false,
        columns: columnsFor(viewportWidth),
      );
    }
    final double heightLimitedWidth = paneSize.height * aspect;
    final double width = math.min(contentWidth, heightLimitedWidth);
    final double height = width / aspect;
    final double scale = box.width == 0 ? 0 : width / box.width;
    return HabotSnippetLayout(
      container: Rect.fromLTWH(originX, originY, width, height),
      scale: scale,
      // Fitting means nothing is ever cut off; a clipped layout would now be
      // an arithmetic bug rather than a narrow screen.
      clipped: height > paneSize.height + 0.5,
      fillsContentWidth: (contentWidth - width).abs() <= 0.5,
      columns: columnsFor(viewportWidth),
    );
  }

  /// Resolves the same box across a set of viewports and reports how many of
  /// them regressed.
  ///
  /// A regression is any of: the container not spanning the full content
  /// width, the snippet being clipped, or the scale dropping below the
  /// legibility floor. Counting them is the metric; the gate reports the
  /// count rather than asserting the intent.
  static HabotViewportSweep sweep({
    required HabotBoundingBox box,
    required List<Size> viewports,
    double paneHeightFraction = 0.5,
  }) {
    final List<String> regressions = <String>[];
    int fullWidth = 0;
    for (final Size viewport in viewports) {
      final Size pane = Size(
        viewport.width,
        viewport.height * paneHeightFraction,
      );
      final HabotSnippetLayout layout = resolve(
        box: box,
        paneSize: pane,
        viewportWidth: viewport.width,
      );
      final double expected = contentWidthFor(viewport.width);
      final bool heightBound = pane.height * box.aspectRatio < expected;
      if (!heightBound && (layout.width - expected).abs() > 0.5) {
        regressions.add(
          '${viewport.width.toStringAsFixed(0)}dp: width '
          '${layout.width.toStringAsFixed(1)} != '
          '${expected.toStringAsFixed(1)}',
        );
        continue;
      }
      if (layout.clipped) {
        regressions.add(
          '${viewport.width.toStringAsFixed(0)}x'
          '${viewport.height.toStringAsFixed(0)}dp: snippet clipped',
        );
        continue;
      }
      if (layout.scale < HabotCropPadding.minLegibleScale) {
        regressions.add(
          '${viewport.width.toStringAsFixed(0)}dp: scale '
          '${layout.scale.toStringAsFixed(2)} below legibility floor',
        );
        continue;
      }
      if (layout.fillsContentWidth) {
        fullWidth++;
      }
    }
    return HabotViewportSweep(
      checked: viewports.length,
      regressions: List<String>.unmodifiable(regressions),
      fullWidthCount: fullWidth,
    );
  }
}

/// The result of sweeping one crop across a set of viewports.
@immutable
class HabotViewportSweep {
  const HabotViewportSweep({
    required this.checked,
    required this.regressions,
    required this.fullWidthCount,
  });

  final int checked;
  final List<String> regressions;

  /// How many of the swept viewports rendered the snippet at the full
  /// 4-column content width. The rest were bound by pane height, which is
  /// reported rather than counted as a failure.
  final int fullWidthCount;

  int get regressionCount => regressions.length;

  /// Metric: Cross-Viewport Rendering Consistency. Zero-tolerance -- the sheet
  /// gives no upper bound because there is no acceptable number above zero.
  bool get isConsistent => regressions.isEmpty;

  double get passRate =>
      checked == 0 ? 1 : (checked - regressions.length) / checked;

  @override
  String toString() =>
      '$checked viewports, $regressionCount regressions'
      '${regressions.isEmpty ? '' : ': ${regressions.join('; ')}'}';
}
