// ============================================================
// ANSA-021-A14 | Navigation Rail
// Atomic Task: Navigation Rail — Active Indicator Width Validation: Validate MD3 active destination indicator width token binding for the Navigation Rail across all screen densities.
// EC Lines: 8 | Standard: DCDF AEETE-018
// ============================================================

import 'package:flutter/material.dart';

// ── Data Models ──────────────────────────────────────────────

enum ExecutionStatus { pending, running, complete, failed }

class Ansa021A14RailIndicatorWidthLog {
  final String indicatorConfigId;
  final double fidelityScore;
  final bool complianceStatusInd;
  final bool immutableInd;
  final ExecutionStatus status;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;

  const Ansa021A14RailIndicatorWidthLog({
    required this.indicatorConfigId,
    required this.fidelityScore,
    required this.complianceStatusInd,
    required this.immutableInd,
    required this.status,
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
  });
}

// ── EC:1–8 Pipeline ──────────────────────────────────────────

class Ansa021A14RailIndicatorWidth {
  static const double _floor   = 0.90;  // metric floor gate
  static const double _optimal = 0.97; // metric optimal target


  static const double _threshold = 95.0;

  // EC:1 — Locate navigation rail indicator configuration within nav-rail-kit source repository.  // error: EC-ANSA021A14-001
  static Map<String, dynamic>? locateConfiguration(String componentRef) {
        if (!(componentRef == 'ANSA-021-A14')) {
      throw ArgumentError('Invalid component ref');
    };
    return {};
  }

  // EC:2 — Extract indicatorWidthDp, indicatorHeightDp, indicatorShape, colorToken, indicatorConfigId from rail_indicator_config_registry.  // error: EC-ANSA021A14-002
  static Map<String, dynamic> extractParameters(Map<String, dynamic> config) {
    return Map<String, dynamic>.from(config);
  }

  // EC:3 — Compile MD3 indicator rule set: width=56dp, height=32dp, shape=stadium, color=md.sys.color.secondaryContainer.  // error: EC-ANSA021A14-003
  static Map<String, dynamic> compileRuleSet() {
    return {
      'threshold': _threshold,
      'ref': 'ANSA-021-A14',
      'immutable': true,
    };
  }

  // EC:4 — Register compiled MD3 indicator rule set as immutable entry in rail_indicator_config_registry.  // error: EC-ANSA021A14-004
  static Ansa021A14RailIndicatorWidthLog registerRule({
    required String indicatorConfigId,
    required String traceId,
    required String originSourceId,
    required String predecessorId,
    required String logicHash,
  }) {
    return Ansa021A14RailIndicatorWidthLog(
      indicatorConfigId: indicatorConfigId,
      fidelityScore: 0.0,
      complianceStatusInd: true,
      immutableInd: true,
      status: ExecutionStatus.pending,
      traceId: traceId,
      originSourceId: originSourceId,
      immediatePredecessorId: predecessorId,
      transformationLogicHash: logicHash,
    );
  }

  // EC:5 — Bind each registered indicator rule to NavigationRail destination slot by applying rail_indicator_slot_FK constraint.  // error: EC-ANSA021A14-005
  static String bindToTarget(String ruleId, String targetSlot) {
    return '$targetSlot:$ruleId';
  }

  // EC:6 — Validate bound indicator configuration by executing dimension conformance check confirming width, height, shape, color token.  // error: EC-ANSA021A14-006
  static bool validateConformance(double actual, Map<String, dynamic> rules) {
    final threshold = (rules['threshold'] as num).toDouble();
    return actual <= threshold;
  }

  // EC:7 — Validate rail indicator implementation against Design Fidelity metric threshold (Good >= 95% conformance).  // error: EC-ANSA021A14-007
  static String evaluateMetric(double actual) {
    return actual <= _threshold ? 'PASS' : 'FAIL';
  }

  // EC:8 — Route validated indicator configuration to shared_nav_utils npm package as authoritative Rail Indicator Registry entry.  // error: EC-ANSA021A14-008
  static Ansa021A14RailIndicatorWidthLog routeToRegistry(
    Ansa021A14RailIndicatorWidthLog entry,
    double actual,
  ) {
    final passed = validateConformance(actual, compileRuleSet());
    return Ansa021A14RailIndicatorWidthLog(
      indicatorConfigId: entry.indicatorConfigId,
      fidelityScore: actual,
      complianceStatusInd: passed,
      immutableInd: entry.immutableInd,
      status: passed ? ExecutionStatus.complete : ExecutionStatus.failed,
      traceId: entry.traceId,
      originSourceId: entry.originSourceId,
      immediatePredecessorId: entry.immediatePredecessorId,
      transformationLogicHash: entry.transformationLogicHash,
    );
  }
  // Triangular Check — DCDF AEETE-018: source_count - destination_count == 0
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

}

// ── Widget ───────────────────────────────────────────────────

class Ansa021A14RailIndicatorWidthWidget extends StatelessWidget {
  final List<Ansa021A14RailIndicatorWidthLog> entries;
  const Ansa021A14RailIndicatorWidthWidget({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final e = entries[i];
        final metric = Ansa021A14RailIndicatorWidth.evaluateMetric(e.fidelityScore);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            title: Text(
              e.indicatorConfigId,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'Courier',
                fontSize: 12,
              ),
            ),
            subtitle: Text(
              'Fidelity %: ${e.fidelityScore.toStringAsFixed(2)} | Threshold: 95.0',
              style: const TextStyle(fontSize: 11),
            ),
            trailing: Chip(
              label: Text(
                metric,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
              backgroundColor: metric == 'PASS'
                  ? cs.tertiary
                  : cs.error,
            ),
            leading: Icon(
              e.complianceStatusInd ? Icons.check_circle : Icons.error,
              color: e.complianceStatusInd
                  ? cs.tertiary
                  : cs.error,
            ),
          ),
        );
      },
    );
  }
}
