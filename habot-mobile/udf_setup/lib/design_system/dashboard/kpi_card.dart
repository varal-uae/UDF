/// AISS: GEN-02654-A01 -- "Design the M3 KPI card layout for each metric
/// category on a mobile viewport of 360px width."
/// Metric: Implementation Completeness Rate -- Floor "90% of defined scope
/// completed", Optimal "100% of scope complete with peer validation".
///
/// 360px is not a new number. It is `HabotReferenceViewport.widthDp`, pinned
/// in Step 39 as 1080x1920 at a device pixel ratio of 3 -- the 5.5-inch
/// reference device the sheet named there. Declaring a second 360 here would
/// create two places to change it.
///
/// The card is a variant of `HabotCard` (Step 29), not a fourth card. That
/// matters more than it sounds: the chassis already carries the rule that a
/// card may have a shadow or a border but never both, and a KPI card that
/// re-implemented its own surface would escape it.
///
/// "For each metric category" is the part worth taking literally. A category
/// is not a colour -- it decides the shape of the card: whether it carries a
/// delta, whether the delta's direction is good or bad, and what a screen
/// reader is told. Those are properties of the metric, so they live on the
/// category rather than at each call site.
library;

import 'package:flutter/material.dart';

import '../a11y/text_fit.dart';
import '../feedback/status_badge.dart';
import '../surfaces/card_chassis.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/surface_tokens.dart';
import '../tokens/dashboard_tokens.dart';
import '../tokens/typography_tokens.dart';

/// The metric categories the sheet asks for a layout "for each" of.
enum HabotMetricCategory {
  /// A plain count. No direction: 148 records is neither good nor bad.
  volume,

  /// A rate or percentage. Up is good.
  rate,

  /// A latency or duration. Down is good -- which is why direction cannot be a
  /// single global "green means up".
  latency,

  /// A count of things that went wrong. Down is good, and any non-zero value
  /// carries a warning role rather than a neutral one.
  fault;

  /// Whether a rising value is an improvement for this category.
  bool get risingIsGood => this == rate || this == volume;

  /// Whether this category shows a period-over-period delta at all.
  bool get carriesDelta => this != volume;

  /// The unit suffix rendered after the value, if any.
  String get unitSuffix {
    switch (this) {
      case HabotMetricCategory.rate:
        return '%';
      case HabotMetricCategory.latency:
        return 'ms';
      case HabotMetricCategory.volume:
      case HabotMetricCategory.fault:
        return '';
    }
  }
}

/// One KPI, as data. Separated from the widget so the gates can assert the
/// derivation -- direction, status role, spoken label -- without pumping a
/// tree, and so Step 65 can hand the same record to a filter.
class HabotKpi {
  const HabotKpi({
    required this.id,
    required this.label,
    required this.value,
    required this.category,
    this.previousValue,
    this.filterKey,
  });

  /// Stable id. Step 65 uses it to work out which filter a tap applies.
  final String id;

  final String label;
  final double value;
  final HabotMetricCategory category;

  /// The comparison period. Null means there is nothing to compare against,
  /// and the card shows no delta rather than showing a zero one.
  final double? previousValue;

  /// The filter this KPI narrows the dashboard to when tapped. Null means the
  /// card is not actionable, and the card renders without a tap target rather
  /// than with a dead one.
  final String? filterKey;

  bool get hasDelta =>
      category.carriesDelta && previousValue != null && previousValue != 0;

  /// Change against the previous period, as a fraction. Zero when there is
  /// nothing to compare.
  double get delta =>
      hasDelta ? (value - previousValue!) / previousValue!.abs() : 0;

  bool get isImproving => category.risingIsGood ? delta > 0 : delta < 0;

  /// The status role this KPI carries, derived rather than passed in.
  ///
  /// WCAG 2.1 SC 1.4.1 is the reason this returns a role and not a colour: the
  /// role brings an icon and a label with it (Step 28), so the direction of a
  /// KPI survives greyscale and a screen reader.
  HabotStatusRole get role {
    if (category == HabotMetricCategory.fault && value > 0) {
      return HabotStatusRole.warning;
    }
    if (!hasDelta) {
      return HabotStatusRole.neutral;
    }
    if (delta.abs() < HabotKpiSpec.materialDeltaFraction) {
      return HabotStatusRole.neutral;
    }
    return isImproving ? HabotStatusRole.success : HabotStatusRole.error;
  }

  /// The value as the card renders it.
  String get displayValue {
    final String number = value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
    return '$number${category.unitSuffix}';
  }

  /// The delta as the card renders it, sign included.
  String get displayDelta {
    if (!hasDelta) {
      return '';
    }
    final double pct = delta * 100;
    final String sign = pct > 0 ? '+' : '';
    return '$sign${pct.toStringAsFixed(1)}%';
  }

  /// What a screen reader hears. One sentence, with the direction spelled out
  /// in words rather than left to the arrow glyph.
  String get semanticsLabel {
    final StringBuffer buffer = StringBuffer('$label, $displayValue');
    if (hasDelta) {
      final String direction = delta > 0 ? 'up' : 'down';
      final String judgement = isImproving ? 'improving' : 'worsening';
      buffer.write(
        ', $direction ${delta.abs() * 100 >= 0.05 ? (delta.abs() * 100).toStringAsFixed(1) : '0'}'
        ' percent, $judgement',
      );
    }
    return buffer.toString();
  }
}

/// The layout numbers, at the 360dp reference viewport the step names.
class HabotKpiSpec {
  const HabotKpiSpec._();

  /// Below this, a change is noise rather than news, and the card stays
  /// neutral instead of flashing red at a rounding error.
  static const double materialDeltaFraction = 0.02;

  /// The card is a variant of the Step 29 chassis. Named here so the gate can
  /// assert the reuse rather than trusting a comment about it.
  static const HabotCardVariant variant = HabotCardVariant.filled;

  /// Content padding comes from the chassis, not from this file.
  static double get contentPadding => HabotCardSpec.contentPadding;

  /// The value line. Large enough to read at a glance from arm's length, which
  /// is the whole point of a KPI card.
  static const HabotTypeToken valueToken = HabotTypography.headlineSmall;
  static const HabotTypeToken labelToken = HabotTypography.labelLarge;
  static const HabotTypeToken deltaToken = HabotTypography.labelMedium;

  /// Minimum card height, so a row of cards is a row rather than a ragged
  /// edge. A multiple of the baseline grid.
  static const double minHeight = 96;

  /// The gap between the label, the value and the delta.
  static const double lineGap = HabotSpacing.xxs;

  /// The label must survive at the reference viewport with the card's padding
  /// and the grid gutters removed. This is the width the fit is audited at.
  static double auditWidthFor(double viewportWidth, int columns) =>
      HabotDashboardTokens.tileWidth(viewportWidth, columns) -
      (HabotCardSpec.contentPadding * 2);

  /// Whether [label] survives at [viewportWidth] in [columns] columns.
  /// Completion-measure arithmetic, not decoration: a KPI label truncated to
  /// four characters is a card that has stopped being a KPI.
  static bool labelFits(String label, double viewportWidth, int columns) =>
      HabotTextFit.audit(
        text: label,
        token: labelToken,
        width: auditWidthFor(viewportWidth, columns),
        maxLines: 2,
      ).fits;
}

/// The card.
class HabotKpiCard extends StatelessWidget {
  const HabotKpiCard({required this.kpi, this.onTap, super.key});

  final HabotKpi kpi;

  /// Step 65 supplies this. Null when the KPI has no filter to apply.
  final void Function(HabotKpi kpi)? onTap;

  static Key keyFor(String id) => Key('habot.kpi.$id');

  bool get isActionable => onTap != null && kpi.filterKey != null;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: keyFor(kpi.id),
      constraints: const BoxConstraints(minHeight: HabotKpiSpec.minHeight),
      child: HabotCard(
        variant: HabotKpiSpec.variant,
        semanticLabel: kpi.semanticsLabel,
        onPressed: isActionable ? () => onTap!(kpi) : null,
        child: _KpiBody(kpi: kpi),
      ),
    );
  }
}

class _KpiBody extends StatelessWidget {
  const _KpiBody({required this.kpi});

  final HabotKpi kpi;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    // The whole card already carries one semantics label; the parts inside it
    // would otherwise be announced a second time, word by word.
    return Semantics(
      container: true,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HabotFittingText(
            kpi.label,
            token: HabotKpiSpec.labelToken,
            maxLines: 2,
          ),
          const SizedBox(height: HabotKpiSpec.lineGap),
          Text(kpi.displayValue, style: text.headlineSmall),
          if (kpi.hasDelta) ...<Widget>[
            const SizedBox(height: HabotKpiSpec.lineGap),
            _Delta(kpi: kpi, scheme: scheme, style: text.labelMedium),
          ],
        ],
      ),
    );
  }
}

/// The delta line: icon, then text, in the KPI's derived status role.
///
/// The icon is not decoration. SC 1.4.1 again -- if the only thing separating
/// "up 4%" from "down 4%" were the colour of the text, the card would fail for
/// a reader who cannot distinguish them.
class _Delta extends StatelessWidget {
  const _Delta({required this.kpi, required this.scheme, required this.style});

  final HabotKpi kpi;
  final ColorScheme scheme;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final Color colour = HabotStatuses.onContainerColor(scheme, kpi.role);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          kpi.delta > 0 ? Icons.arrow_upward : Icons.arrow_downward,
          size: HabotFeedback.badgeIconSize,
          color: colour,
        ),
        const SizedBox(width: HabotSpacing.xxs),
        Text(kpi.displayDelta, style: style?.copyWith(color: colour)),
      ],
    );
  }
}
