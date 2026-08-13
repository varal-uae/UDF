/// AISS: SSTLA-010-A01 -- "Formulate the responsive split-screen grid
/// distributions and layout rules for Micro Task Outsourcing (MTO) panels to
/// maximize readability."
///
/// Setup Step Description: "Identify core visual content requirements for MTO
/// mobile interface panels."
/// Why This Matters: "Poorly scaled split viewports on mobile devices lead to
/// constant pinching and zooming, causing fast operator fatigue and input
/// mistakes."
/// Mobile App First Implication: "Replaces wide side-by-side desktop grids
/// with clean, thumb-friendly vertical stacks tailored for mobile
/// interaction."
/// Poka-Yoke: "Key source metrics are pinned immovably at the top of the
/// viewport, keeping important details visible while filling out long fields."
/// Self-Chasing: "Hardcoding layout values across screens creates broken,
/// overlapping UI elements on smaller devices, instantly stalling qa cycles."
///
/// Step 36 decided how the screen divides. This decides what goes where inside
/// the division, and it is where the poka-yoke lives: a metric strip that
/// scrolls away is not pinned, so [HabotPinnedMetrics] sits outside the scroll
/// view by construction rather than by the caller remembering to put it there.
library;

import 'package:flutter/material.dart';

import '../surfaces/card_chassis.dart';
import '../tokens/grid_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/surface_tokens.dart';
import 'contextual_mirror.dart';

/// Column distribution inside a pane, per window class.
///
/// The Self-Chasing row is the reason this is a lookup and not a literal:
/// "hardcoding layout values across screens creates broken, overlapping UI
/// elements on smaller devices". A pane asks for its distribution; it never
/// states one.
class HabotPaneDistribution {
  const HabotPaneDistribution._();

  /// Columns available inside a pane, given the whole viewport width.
  ///
  /// A pane is narrower than the screen, so it does not simply inherit the
  /// screen's column count: on a side-by-side arrangement each pane gets
  /// roughly half the grid, and the count is floored rather than rounded
  /// because half a column cannot hold anything.
  static int columnsFor(double viewportWidth) {
    final int screenColumns = HabotGrid.columnsFor(viewportWidth);
    if (ContextualMirrorSpec.preferredArrangementFor(viewportWidth) ==
        HabotMirrorArrangement.stacked) {
      return screenColumns;
    }
    final int half = screenColumns ~/ 2;
    return half < HabotGrid.compactColumns ? HabotGrid.compactColumns : half;
  }

  /// Mobile-First row: compact viewports stack. A pane on a phone is a single
  /// column of full-width rows, never a miniature desktop grid.
  static bool stacksVertically(double viewportWidth) =>
      ContextualMirrorSpec.preferredArrangementFor(viewportWidth) ==
      HabotMirrorArrangement.stacked;

  /// Fields per row inside a pane. One on compact -- the whole point of the
  /// vertical stack -- and two once there is room, never more, because a
  /// three-across form field on a tablet is unreadable at arm's length.
  static int fieldsPerRow(double viewportWidth) =>
      stacksVertically(viewportWidth) ? 1 : 2;

  /// Readable measure: the maximum line length inside a pane, in characters.
  /// Above this, text is harder to track back to the next line -- which is the
  /// "maximize readability" the Setup Step asks for, expressed as a number.
  static const int maxLineLengthChars = 75;
}

/// The pinned metric strip.
///
/// Poka-Yoke: "Key source metrics are pinned immovably at the top of the
/// viewport, keeping important details visible while filling out long fields."
///
/// The structure enforces it. [metrics] renders above [child], outside any
/// scroll view this widget creates, and the scrolling content is given to
/// [child]. There is no arrangement of the parameters that puts the metrics
/// inside the scrollable region.
class HabotPinnedMetrics extends StatelessWidget {
  const HabotPinnedMetrics({
    required this.metrics,
    required this.child,
    super.key,
  });

  /// The values that must stay visible. Kept short deliberately: a strip that
  /// grows past [maxPinnedMetrics] is a header, and a header that tall defeats
  /// the purpose.
  final List<HabotPinnedMetric> metrics;

  /// The long fields the operator is filling in. This scrolls; the strip
  /// above it does not.
  final Widget child;

  static const int maxPinnedMetrics = 4;

  /// Stable handle for the gate.
  static const Key stripKey = Key('habot.pane.pinnedMetrics');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _MetricStrip(metrics: metrics.take(maxPinnedMetrics).toList()),
        const SizedBox(height: HabotSpacing.xs),
        Expanded(child: SingleChildScrollView(child: child)),
      ],
    );
  }
}

/// One value in the pinned strip.
class HabotPinnedMetric {
  const HabotPinnedMetric({required this.label, required this.value});

  final String label;
  final String value;
}

class _MetricStrip extends StatelessWidget {
  const _MetricStrip({required this.metrics});

  final List<HabotPinnedMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return HabotCard(
      key: HabotPinnedMetrics.stripKey,
      variant: HabotCardVariant.filled,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          for (final HabotPinnedMetric metric in metrics)
            Flexible(child: _MetricCell(metric: metric)),
        ],
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({required this.metric});

  final HabotPinnedMetric metric;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(metric.label, style: text.labelSmall, maxLines: 1),
        Text(metric.value, style: text.titleMedium, maxLines: 1),
      ],
    );
  }
}
