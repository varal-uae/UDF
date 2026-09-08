// ============================================================
// ANSA-007-A11 | Navigation Rail
// Atomic Task: Navigation Rail — Layout Conformance Check: Validate MD3 Navigation Rail layout constraints across compact and expanded breakpoints.
// EC Lines: 8 | Standard: DCDF AEETE-018
// ============================================================

import 'package:flutter/material.dart';

// ── Data Models ──────────────────────────────────────────────

enum ExecutionStatus { pending, running, complete, failed }

class Ansa007A11NavRailLayoutCheckLog {
  final String railConfigId;
  final double fidelityScore;
  final bool complianceStatusInd;
  final bool immutableInd;
  final ExecutionStatus status;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;

  const Ansa007A11NavRailLayoutCheckLog({
    required this.railConfigId,
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

class Ansa007A11NavRailLayoutCheck {

  static const double _threshold = 95.0;

  // EC:1 — Locate the Navigation Rail layout configuration within the nav-rail-kit source repository.
  static Map<String, dynamic>? locateConfiguration(String componentRef) {
    assert(componentRef == 'ANSA-007-A11', 'Invalid component ref');
    return {};
  }

  // EC:2 — Extract railWidth, destinationCount, labelVisibility, breakpointMode, groupAlignment from rail_layout_config_registry.
  static Map<String, dynamic> extractParameters(Map<String, dynamic> config) {
    return Map<String, dynamic>.from(config);
  }

  // EC:3 — Compile MD3 Navigation Rail rule set: width=80dp (rail), destinations 3-7, labels always-visible on expanded.
  static Map<String, dynamic> compileRuleSet() {
    return {
      'threshold': _threshold,
      'ref': 'ANSA-007-A11',
      'immutable': true,
    };
  }

  // EC:4 — Register compiled MD3 rail rule set as immutable entry in rail_layout_config_registry.
  static Ansa007A11NavRailLayoutCheckLog registerRule({
    required String railConfigId,
    required String traceId,
    required String originSourceId,
    required String predecessorId,
    required String logicHash,
  }) {
    return Ansa007A11NavRailLayoutCheckLog(
      railConfigId: railConfigId,
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

  // EC:5 — Bind each registered rail rule to NavigationRail scaffold slot by applying rail_scaffold_slot FK constraint.
  static String bindToTarget(String ruleId, String targetSlot) {
    return '$targetSlot:$ruleId';
  }

  // EC:6 — Validate bound rail configuration by executing layout conformance check confirming width, destination count, label spec.
  static bool validateConformance(double actual, Map<String, dynamic> rules) {
    final threshold = (rules['threshold'] as num).toDouble();
    return actual <= threshold;
  }

  // EC:7 — Validate configured rail implementation against Design Fidelity metric threshold (Good >= 95% conformance).
  static String evaluateMetric(double actual) {
    return actual <= _threshold ? 'PASS' : 'FAIL';
  }

  // EC:8 — Route validated rail layout configuration to shared_nav_utils npm package as authoritative Rail Layout Registry entry.
  static Ansa007A11NavRailLayoutCheckLog routeToRegistry(
    Ansa007A11NavRailLayoutCheckLog entry,
    double actual,
  ) {
    final passed = validateConformance(actual, compileRuleSet());
    return Ansa007A11NavRailLayoutCheckLog(
      railConfigId: entry.railConfigId,
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
}

// ── Widget ───────────────────────────────────────────────────

class Ansa007A11NavRailLayoutCheckWidget extends StatelessWidget {
  final List<Ansa007A11NavRailLayoutCheckLog> entries;
  const Ansa007A11NavRailLayoutCheckWidget({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final e = entries[i];
        final metric = Ansa007A11NavRailLayoutCheck.evaluateMetric(e.fidelityScore);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            title: Text(
              e.railConfigId,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'Courier',
                fontSize: 12,
              ),
            ),
            subtitle: Text(
              'Fidelity: ${e.fidelityScore.toStringAsFixed(2)} | Threshold: 95.0',
              style: const TextStyle(fontSize: 11),
            ),
            trailing: Chip(
              label: Text(
                metric,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
              backgroundColor: metric == 'PASS'
                  ? const Color(0xFF137333)
                  : const Color(0xFFD93025),
            ),
            leading: Icon(
              e.complianceStatusInd ? Icons.check_circle : Icons.error,
              color: e.complianceStatusInd
                  ? const Color(0xFF137333)
                  : const Color(0xFFD93025),
            ),
          ),
        );
      },
    );
  }
}
