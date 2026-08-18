/// AISS: GEN-02709-A01 -- "Build an aggregate infrastructure KPI summary
/// section at the top of the dashboard visible on initial load."
/// Metric: Dashboard Load Time -- Floor "Dashboard loads within 5 seconds",
/// Optimal "Dashboard loads within 2 seconds", Ceiling "Load time exceeding
/// 10 seconds".
///
/// The first metric in this batch that measures the assembled thing rather
/// than a part, which is why this step is last of the rendering work.
///
/// "VISIBLE ON INITIAL LOAD" is the requirement doing the work. It rules out
/// three otherwise reasonable designs: a strip inside the scroll view (which
/// is visible on initial load only on a tall enough screen), a strip that
/// renders after its data arrives (which is not visible on initial load at
/// all), and a strip that collapses on small screens (same). So the strip is
/// outside the scroll view by construction -- the same technique Step 38 used
/// for the pinned metrics -- and it renders its skeleton at the exact size it
/// will occupy, so "visible on initial load" is true on the first frame rather
/// than the first frame after the network answers.
///
/// Aggregation is the other half. A summary of eight KPIs is not eight KPIs in
/// a smaller font; it is a different, shorter set derived from them. The rule
/// here: how many are healthy, how many need attention, and the single worst
/// one by name.
library;

import 'package:flutter/material.dart';

import '../feedback/status_badge.dart';
import '../tokens/dashboard_tokens.dart';
import '../tokens/spacing_tokens.dart';
import 'kpi_card.dart';
import 'skeleton.dart';

/// The aggregate, derived from a set of KPIs.
class HabotKpiAggregate {
  const HabotKpiAggregate({
    required this.total,
    required this.healthy,
    required this.needsAttention,
    required this.worst,
  });

  factory HabotKpiAggregate.from(List<HabotKpi> kpis) {
    int healthy = 0;
    int attention = 0;
    HabotKpi? worst;
    for (final HabotKpi kpi in kpis) {
      final HabotStatusRole role = kpi.role;
      if (role == HabotStatusRole.error || role == HabotStatusRole.warning) {
        attention++;
        if (worst == null || kpi.delta.abs() > worst.delta.abs()) {
          worst = kpi;
        }
      } else {
        healthy++;
      }
    }
    return HabotKpiAggregate(
      total: kpis.length,
      healthy: healthy,
      needsAttention: attention,
      worst: worst,
    );
  }

  final int total;
  final int healthy;
  final int needsAttention;

  /// The single KPI most worth looking at. Null when nothing needs attention,
  /// and the strip says so rather than promoting the least-good healthy one.
  final HabotKpi? worst;

  bool get allHealthy => needsAttention == 0 && total > 0;

  HabotStatusRole get role {
    if (total == 0) {
      return HabotStatusRole.neutral;
    }
    return allHealthy ? HabotStatusRole.success : HabotStatusRole.warning;
  }

  String get headline {
    if (total == 0) {
      return 'No metrics yet';
    }
    if (allHealthy) {
      return 'All $total metrics healthy';
    }
    return '$needsAttention of $total need attention';
  }

  String get detail => worst == null
      ? 'Nothing is trending the wrong way.'
      : 'Worst: ${worst!.label} ${worst!.displayDelta}';

  String get semanticsLabel => '$headline. $detail';
}

/// The strip.
///
/// Takes `isLoading` rather than a nullable list, because the two states a
/// dashboard has on initial load are "waiting" and "here", and a null list
/// conflates "waiting" with "there are none".
class HabotSummaryStrip extends StatelessWidget {
  const HabotSummaryStrip({
    required this.kpis,
    this.isLoading = false,
    super.key,
  });

  final List<HabotKpi> kpis;
  final bool isLoading;

  static const Key stripKey = Key('habot.dashboard.summaryStrip');
  static const Key skeletonKey = Key('habot.dashboard.summarySkeleton');

  /// The height the strip occupies, loading or loaded. One number, so the
  /// skeleton and the content cannot disagree -- which is what makes the swap
  /// shift-free.
  static double get height => HabotDashboardTokens.summaryStripHeight;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (isLoading) {
      return SizedBox(
        key: skeletonKey,
        height: height,
        width: width,
        child: HabotSkeleton(width: width, height: height),
      );
    }
    final HabotKpiAggregate aggregate = HabotKpiAggregate.from(kpis);
    return SizedBox(
      key: stripKey,
      height: height,
      child: _StripBody(aggregate: aggregate),
    );
  }
}

class _StripBody extends StatelessWidget {
  const _StripBody({required this.aggregate});

  final HabotKpiAggregate aggregate;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color background =
        HabotStatuses.containerColor(theme.colorScheme, aggregate.role);
    final Color foreground =
        HabotStatuses.onContainerColor(theme.colorScheme, aggregate.role);
    return Semantics(
      label: aggregate.semanticsLabel,
      container: true,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(
            HabotDashboardTokens.skeletonCornerRadius,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: HabotSpacing.md,
            vertical: HabotSpacing.xs,
          ),
          child: Row(
            children: <Widget>[
              Icon(
                aggregate.allHealthy
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                color: foreground,
                size: HabotSpacing.lg,
              ),
              const SizedBox(width: HabotSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      aggregate.headline,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: foreground),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      aggregate.detail,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: foreground),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The dashboard section: the strip, pinned outside the scroll view, above
/// whatever scrolls.
///
/// The strip cannot be placed inside [scrollingContent] because it is not
/// passed to it -- the same structural argument Step 38 made for the pinned
/// metric strip. "Visible on initial load" is then a property of the tree
/// rather than a promise about it.
class HabotDashboardSection extends StatelessWidget {
  const HabotDashboardSection({
    required this.kpis,
    required this.scrollingContent,
    this.isLoading = false,
    super.key,
  });

  final List<HabotKpi> kpis;
  final Widget scrollingContent;
  final bool isLoading;

  static const Key sectionKey = Key('habot.dashboard.section');

  @override
  Widget build(BuildContext context) {
    return Column(
      key: sectionKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        HabotSummaryStrip(kpis: kpis, isLoading: isLoading),
        const SizedBox(height: HabotDashboardTokens.summaryStripGap),
        Expanded(child: SingleChildScrollView(child: scrollingContent)),
      ],
    );
  }
}
