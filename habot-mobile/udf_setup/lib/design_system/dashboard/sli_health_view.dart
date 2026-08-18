/// AISS: GEN-03039-A01 -- "Display a mobile SLI health dashboard with latency
/// sparklines and drift counters."
/// Metric: Mobile Response/Load Latency (ms) -- Floor 1000.0, Optimal 300.0,
/// Ceiling 2000.0.
///
/// INVERTED BANDS, RECORDED. Everywhere else in your sheet the Floor is the
/// minimum acceptable value and the Ceiling is the best. For a latency metric
/// lower is better, so these bands run the other way: 300ms is the target,
/// 1000ms is the edge of acceptable, and 2000ms is the failure threshold. The
/// numbers are not wrong; the convention is reversed, and anyone scanning the
/// sheet quickly will read them backwards. The reading used here is stated so
/// it can be argued with.
///
/// A Service Level Indicator is a measurement, not a promise -- the promise is
/// the objective. So this view shows three things per indicator and refuses to
/// collapse them: the current reading, its trend, and how far it has DRIFTED
/// from the objective. A dashboard that shows only the current value cannot
/// distinguish "briefly slow" from "slowly getting worse", and those need
/// different responses.
library;

import 'package:flutter/material.dart';

import '../charts/habot_charts.dart';
import '../feedback/status_badge.dart';
import '../surfaces/card_chassis.dart';
import '../tokens/dashboard_tokens.dart';
import '../tokens/spacing_tokens.dart';
import 'confidence_metric.dart';

/// The latency bands, read in the latency sense.
class HabotLatencyBands {
  const HabotLatencyBands._();

  /// "Optimal" in the sheet: the target.
  static const double optimalMs = 300;

  /// "Floor" in the sheet: the edge of acceptable.
  static const double acceptableMs = 1000;

  /// "Ceiling" in the sheet: the failure threshold.
  static const double failureMs = 2000;

  /// Lower is better here, which is why this is a named function rather than a
  /// comparison written at each call site.
  static bool isBetter(double a, double b) => a < b;

  static HabotStatusRole roleFor(double latencyMs) {
    if (latencyMs <= optimalMs) {
      return HabotStatusRole.success;
    }
    if (latencyMs <= acceptableMs) {
      return HabotStatusRole.neutral;
    }
    if (latencyMs < failureMs) {
      return HabotStatusRole.warning;
    }
    return HabotStatusRole.error;
  }

  static String bandName(double latencyMs) {
    if (latencyMs <= optimalMs) {
      return 'optimal';
    }
    if (latencyMs <= acceptableMs) {
      return 'acceptable';
    }
    if (latencyMs < failureMs) {
      return 'degraded';
    }
    return 'failing';
  }
}

/// One service level indicator.
class HabotSli {
  const HabotSli({
    required this.id,
    required this.name,
    required this.objectiveMs,
    required this.history,
    this.confidence,
  });

  final String id;
  final String name;

  /// The Service Level Objective this indicator is measured against.
  final double objectiveMs;

  /// Recent readings, oldest first. The sparkline draws this.
  final HabotChartSeries history;

  /// The interval around the current reading, when the sampling produces one.
  final HabotConfidenceMetric? confidence;

  double get currentMs =>
      history.points.isEmpty ? 0 : history.points.last.value;

  /// The drift counter the Setup Step names: how far the current reading sits
  /// from the objective, in milliseconds. Signed, because the direction is the
  /// information.
  double get driftMs => currentMs - objectiveMs;

  /// Drift as a share of the objective.
  double get driftFraction => objectiveMs == 0 ? 0 : driftMs / objectiveMs;

  bool get isWithinObjective => currentMs <= objectiveMs;

  HabotStatusRole get role => HabotLatencyBands.roleFor(currentMs);

  String get displayDrift {
    final String sign = driftMs > 0 ? '+' : '';
    return '$sign${driftMs.round()}ms vs objective';
  }

  String get semanticsLabel =>
      '$name, ${currentMs.round()} milliseconds, '
      '${HabotLatencyBands.bandName(currentMs)}, '
      '${driftMs > 0 ? 'over' : 'under'} objective by '
      '${driftMs.abs().round()} milliseconds';
}

/// The health view.
class HabotSliHealthView extends StatelessWidget {
  const HabotSliHealthView({required this.indicators, super.key});

  final List<HabotSli> indicators;

  static const Key viewKey = Key('habot.sli.health');
  static Key rowKeyFor(String id) => Key('habot.sli.$id');

  /// How many indicators are inside their objective. The number worth putting
  /// at the top of a health view, because "four of six" is actionable and a
  /// list of six rows is not.
  static int withinObjective(List<HabotSli> indicators) =>
      indicators.where((HabotSli s) => s.isWithinObjective).length;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: viewKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < indicators.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: HabotDashboardTokens.tileRowGap),
          _SliRow(sli: indicators[i]),
        ],
      ],
    );
  }
}

class _SliRow extends StatelessWidget {
  const _SliRow({required this.sli});

  final HabotSli sli;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent =
        HabotStatuses.onContainerColor(theme.colorScheme, sli.role);
    return HabotCard(
      key: HabotSliHealthView.rowKeyFor(sli.id),
      variant: HabotCardVariant.outlined,
      semanticLabel: sli.semanticsLabel,
      child: Semantics(
        container: true,
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(sli.name, style: theme.textTheme.labelLarge),
                ),
                const SizedBox(width: HabotSpacing.xs),
                HabotSparkline(series: sli.history, colour: accent),
              ],
            ),
            const SizedBox(height: HabotSpacing.xxs),
            Row(
              children: <Widget>[
                Text(
                  '${sli.currentMs.round()}ms',
                  style: theme.textTheme.titleMedium?.copyWith(color: accent),
                ),
                const SizedBox(width: HabotSpacing.xs),
                Icon(
                  sli.isWithinObjective
                      ? Icons.check_circle_outline
                      : Icons.trending_up,
                  size: HabotSpacing.md,
                  color: accent,
                ),
                const SizedBox(width: HabotSpacing.xxs),
                Flexible(
                  child: Text(
                    sli.displayDrift,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            if (sli.confidence != null) ...<Widget>[
              const SizedBox(height: HabotSpacing.xxs),
              HabotConfidenceText(metric: sli.confidence!),
            ],
          ],
        ),
      ),
    );
  }
}
