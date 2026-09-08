/// AISS: GEN-04803-A01 -- "Apply the mobile-first UI decision: M3 Shimmer
/// gradient applying Surface and Surface Variant tokens."
/// Metric: UI Design Token Compliance Rate -- Floor ">=95% of components
/// sourced from approved design tokens", Optimal "100% token compliance".
///
/// COLUMN NOTE, RECORDED: this row's Setup Step (Action) and Setup Step
/// Description columns contain the identical string, so the usual three-column
/// derivation has only two distinct inputs. Gated against the Setup Step, the
/// Metric, and the one property a skeleton exists to provide.
///
/// THAT PROPERTY IS THE POINT OF THIS FILE. A shimmer is not decoration for a
/// wait; it is a promise about size. If the skeleton occupies a different
/// number of pixels from the content that replaces it, everything below jumps
/// when the data lands -- and a user who was reaching for a control taps
/// something else. That jump is Cumulative Layout Shift, and it is what
/// `RCGLA-012-G7` has been deferred on since Step 6.
///
/// WHAT THIS DOES AND DOES NOT CLOSE. It makes the shift measurable and makes
/// it zero for the app's own widgets: [HabotSkeleton.forKpiCard] and
/// [HabotSkeleton.forSparkline] derive their size from the same token
/// functions the real components use, so the two cannot disagree without the
/// gate noticing. It does NOT produce the browser-reported CLS figure for the
/// web build -- that still needs a Lighthouse run against a real page load,
/// and `RCGLA-012-G7` stays deferred for that number. Both halves are recorded
/// on the gate rather than one of them being implied away.
library;

import 'package:flutter/material.dart';

import '../tokens/dashboard_tokens.dart';
import '../tokens/motion_tokens.dart';
import '../tokens/spacing_tokens.dart';
import 'kpi_card.dart';

/// The shimmer.
///
/// Surface and Surface Variant, as the Setup Step names -- two adjacent
/// surfaces from the audited scheme rather than a grey and a lighter grey. The
/// pair is deliberately low contrast: a skeleton that competes with the
/// content around it for attention is a worse wait than a blank space.
class HabotSkeleton extends StatefulWidget {
  const HabotSkeleton({
    required this.width,
    required this.height,
    this.borderRadius,
    super.key,
  });

  /// A skeleton sized for one KPI card at [viewportWidth] in [columns]
  /// columns. Both numbers come from the same token functions
  /// `HabotKpiCard` uses, which is the whole mechanism.
  factory HabotSkeleton.forKpiCard({
    required double viewportWidth,
    required int columns,
    Key? key,
  }) {
    return HabotSkeleton(
      key: key,
      width: HabotDashboardTokens.tileWidth(viewportWidth, columns),
      height: HabotKpiSpec.minHeight,
    );
  }

  /// A skeleton sized for one sparkline.
  factory HabotSkeleton.forSparkline({
    required double width,
    required double height,
    Key? key,
  }) {
    return HabotSkeleton(key: key, width: width, height: height);
  }

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  static const Key skeletonKey = Key('habot.skeleton');

  /// One shimmer sweep. On the ladder already, not a new duration.
  static const Duration sweepPeriod = HabotMotion.skeletonSweep;

  @override
  State<HabotSkeleton> createState() => _HabotSkeletonState();
}

class _HabotSkeletonState extends State<HabotSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: HabotSkeleton.sweepPeriod,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reduced motion: a shimmer is a decorative loop, and Step 11's policy
    // says a decorative loop stops. The block still reserves its space, which
    // is the half that matters. Read here rather than in initState because
    // MediaQuery is not available before the first dependency resolution.
    if (HabotMotionPolicy.allowsLoopingMotion(context)) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    // AISS Step 97 (GEN-04242) A11Y_SEMANTICS_EXCLUDED_AT_ROOT: this returned
    // ExcludeSemantics at its root, so a screen reader was told NOTHING while
    // the screen was loading -- neither the placeholder nor the fact that
    // anything was happening. The shimmer itself is still excluded (it is
    // decoration); what is added is the announcement that a load is in
    // progress, as a live region so it is spoken when it appears.
    return Semantics(
      label: 'Loading',
      liveRegion: true,
      excludeSemantics: true,
      child: SizedBox(
        key: HabotSkeleton.skeletonKey,
        width: widget.width,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) => DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ??
                  BorderRadius.circular(
                    HabotDashboardTokens.skeletonCornerRadius,
                  ),
              gradient: LinearGradient(
                begin: Alignment(-1 - (2 * (1 - _controller.value)), 0),
                end: Alignment(1 + (2 * _controller.value), 0),
                colors: <Color>[
                  scheme.surface,
                  scheme.surfaceContainerHighest,
                  scheme.surface,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The size a placeholder must reserve for a given piece of content.
///
/// One function per component, each deriving from the same tokens the
/// component uses. Nothing here measures a rendered widget: if it did, the
/// skeleton could only be correct after the content it replaces had already
/// been laid out, which is the wrong way round.
class HabotSkeletonReservation {
  const HabotSkeletonReservation._();

  static Size kpiCard({required double viewportWidth, required int columns}) =>
      Size(
        HabotDashboardTokens.tileWidth(viewportWidth, columns),
        HabotKpiSpec.minHeight,
      );

  static Size summaryStrip(double viewportWidth) => Size(
    viewportWidth,
    HabotDashboardTokens.summaryStripHeight,
  );

  /// The layout shift between a reservation and the size the real content
  /// turned out to be, in device-independent pixels. Zero is the target and
  /// the only passing value.
  ///
  /// This is the app-side equivalent of Cumulative Layout Shift: CLS scores a
  /// browser's unexpected movement of laid-out content, and this measures the
  /// same event at its source.
  static double shiftBetween(Size reserved, Size actual) =>
      (reserved.width - actual.width).abs() +
      (reserved.height - actual.height).abs();

  static bool isShiftFree(Size reserved, Size actual) =>
      shiftBetween(reserved, actual) == 0;
}

/// A dashboard's worth of skeletons, laid out on the same grid the real cards
/// use so the whole page reserves its shape rather than one card at a time.
class HabotSkeletonGrid extends StatelessWidget {
  const HabotSkeletonGrid({required this.count, required this.columns, super.key});

  final int count;
  final int columns;

  static const Key gridKey = Key('habot.skeleton.grid');

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final List<List<int>> rows = <List<int>>[];
    for (int i = 0; i < count; i += columns) {
      rows.add(<int>[
        for (int c = 0; c < columns && i + c < count; c++) i + c,
      ]);
    }
    return Column(
      key: gridKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int r = 0; r < rows.length; r++) ...<Widget>[
          if (r > 0) const SizedBox(height: HabotDashboardTokens.tileRowGap),
          Row(
            children: <Widget>[
              for (int c = 0; c < columns; c++) ...<Widget>[
                if (c > 0)
                  const SizedBox(width: HabotDashboardTokens.tileGutter),
                Expanded(
                  child: c < rows[r].length
                      ? SizedBox(
                          height: HabotKpiSpec.minHeight,
                          child: HabotSkeleton(
                            width: HabotDashboardTokens.tileWidth(
                              width,
                              columns,
                            ),
                            height: HabotKpiSpec.minHeight,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// Swaps a skeleton for its content without moving anything.
///
/// Takes the reservation, not a guess: the placeholder occupies exactly what
/// [child] will occupy, so the frame the data arrives on is the first frame
/// that draws it and not the first frame that moves everything below it.
class HabotSkeletonSwap extends StatelessWidget {
  const HabotSkeletonSwap({
    required this.isLoading,
    required this.reservation,
    required this.child,
    super.key,
  });

  final bool isLoading;
  final Size reservation;
  final Widget child;

  static const Key swapKey = Key('habot.skeleton.swap');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: swapKey,
      width: reservation.width,
      height: reservation.height,
      child: isLoading
          ? HabotSkeleton(
              width: reservation.width,
              height: reservation.height,
            )
          : child,
    );
  }
}
