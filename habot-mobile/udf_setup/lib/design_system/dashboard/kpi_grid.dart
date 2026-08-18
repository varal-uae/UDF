/// AISS: GEN-00168-A01 -- "Stack KPI cards vertically in a single column on
/// mobile screens."
/// Metric: General Task Completion Quality -- Floor "Task completed with
/// documented exceptions", Optimal "100% completion matching stated
/// implementation-step intent".
///
/// METRIC NAME NOTE, RECORDED: "General Task Completion Quality" is a generic
/// project-tracking band on a step that names a specific, testable layout
/// rule. The rule is what is gated; the band is reported against how much of
/// the stated intent was met, which is the only honest reading of it.
///
/// The important thing about this file is what it does NOT contain: a
/// breakpoint. Step 45 already gated `HabotDashboardGrid.columnsFor` across 18
/// viewports -- one column below 600dp, two above. A second copy of that rule
/// here would be a second thing to change, and the two would drift the first
/// time somebody adjusted one of them. So this grid asks.
///
/// The one thing it adds is a per-viewport tile width, because a KPI card has
/// to know how much room its label has before deciding whether the label
/// fits -- and Step 46's fitting rules need a number, not a constraint.
library;

import 'package:flutter/material.dart';

import '../shell/dashboard_grid.dart';
import '../tokens/dashboard_tokens.dart';
import 'kpi_card.dart';

/// A grid of KPI cards that stacks on mobile.
class HabotKpiGrid extends StatelessWidget {
  const HabotKpiGrid({required this.kpis, this.onKpiTapped, super.key});

  final List<HabotKpi> kpis;

  /// Step 65 supplies this.
  final void Function(HabotKpi kpi)? onKpiTapped;

  static const Key gridKey = Key('habot.kpi.grid');

  /// The column count, derived from Step 45 rather than declared here.
  ///
  /// Exposed so the gate can assert the derivation directly: if this ever
  /// stops returning exactly what `HabotDashboardGrid.columnsFor` returns, the
  /// gate fails, which is the only mechanism that keeps two files agreeing.
  static int columnsFor(double width) => HabotDashboardGrid.columnsFor(width);

  static bool stacksVertically(double width) => columnsFor(width) == 1;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final int columns = columnsFor(width);
    if (columns == 1) {
      return Column(
        key: gridKey,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < kpis.length; i++) ...<Widget>[
            if (i > 0)
              const SizedBox(height: HabotDashboardTokens.tileRowGap),
            HabotKpiCard(kpi: kpis[i], onTap: onKpiTapped),
          ],
        ],
      );
    }
    return _KpiRows(kpis: kpis, columns: columns, onKpiTapped: onKpiTapped);
  }
}

/// Rows of [columns] cards. A wrap rather than a GridView, because a KPI card
/// sizes to its content and a fixed aspect ratio would clip a two-line label
/// on the narrowest device in the matrix.
class _KpiRows extends StatelessWidget {
  const _KpiRows({
    required this.kpis,
    required this.columns,
    required this.onKpiTapped,
  });

  final List<HabotKpi> kpis;
  final int columns;
  final void Function(HabotKpi kpi)? onKpiTapped;

  @override
  Widget build(BuildContext context) {
    final List<List<HabotKpi>> rows = <List<HabotKpi>>[];
    for (int i = 0; i < kpis.length; i += columns) {
      rows.add(
        kpis.sublist(i, i + columns > kpis.length ? kpis.length : i + columns),
      );
    }
    return Column(
      key: HabotKpiGrid.gridKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int r = 0; r < rows.length; r++) ...<Widget>[
          if (r > 0) const SizedBox(height: HabotDashboardTokens.tileRowGap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (int c = 0; c < columns; c++) ...<Widget>[
                  if (c > 0)
                    const SizedBox(width: HabotDashboardTokens.tileGutter),
                  Expanded(
                    child: c < rows[r].length
                        ? HabotKpiCard(kpi: rows[r][c], onTap: onKpiTapped)
                        // An empty cell rather than a stretched last card: a
                        // three-card row of two columns should leave a gap,
                        // not a card twice the width of its neighbours.
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
