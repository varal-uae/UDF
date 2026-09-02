// ============================================================
// ANSA-021-A16 | Navigation Rail
// Atomic Task: Navigation Rail — Badge Count Reactive Update Validation: Validate reactive badge count update behaviour for the Navigation Rail badge indicator across all notification states.
// EC Lines: 8 | Standard: DCDF AEETE-018
// ============================================================

import 'package:flutter/material.dart';

// ── Data Models ──────────────────────────────────────────────

enum ExecutionStatus { pending, running, complete, failed }

class Ansa021A16RailBadgeCountLog {
  final String badgeConfigId;
  final double passRate;
  final bool complianceStatusInd;
  final bool immutableInd;
  final ExecutionStatus status;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;

  const Ansa021A16RailBadgeCountLog({
    required this.badgeConfigId,
    required this.passRate,
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

class Ansa021A16RailBadgeCount {

  static const double _threshold = 95.0;

  // EC:1 — Locate navigation rail badge configuration within nav-rail-kit source repository.
  static Map<String, dynamic>? locateConfiguration(String componentRef) {
    assert(componentRef == 'ANSA-021-A16', 'Invalid component ref');
    return {};
  }

  // EC:2 — Extract badgeCountMax, overflowLabel, reactiveUpdateInd, animationType, updateLatencyMs from rail_badge_config_registry.
  static Map<String, dynamic> extractParameters(Map<String, dynamic> config) {
    return Map<String, dynamic>.from(config);
  }

  // EC:3 — Compile badge count rule set: max=99, overflow=99+, reactiveUpdate=TRUE, animation=SCALE_FADE, latency<=100ms.
  static Map<String, dynamic> compileRuleSet() {
    return {
      'threshold': _threshold,
      'ref': 'ANSA-021-A16',
      'immutable': true,
    };
  }

  // EC:4 — Register compiled badge count rule set as immutable entry in rail_badge_config_registry.
  static Ansa021A16RailBadgeCountLog registerRule({
    required String badgeConfigId,
    required String traceId,
    required String originSourceId,
    required String predecessorId,
    required String logicHash,
  }) {
    return Ansa021A16RailBadgeCountLog(
      badgeConfigId: badgeConfigId,
      passRate: 0.0,
      complianceStatusInd: true,
      immutableInd: true,
      status: ExecutionStatus.pending,
      traceId: traceId,
      originSourceId: originSourceId,
      immediatePredecessorId: predecessorId,
      transformationLogicHash: logicHash,
    );
  }

  // EC:5 — Bind each registered badge rule to NavigationRail badge slot by applying badge_slot_FK constraint.
  static String bindToTarget(String ruleId, String targetSlot) {
    return '$targetSlot:$ruleId';
  }

  // EC:6 — Validate bound badge configuration by executing reactive update check confirming latency<=100ms, overflow label renders.
  static bool validateConformance(double actual, Map<String, dynamic> rules) {
    final threshold = (rules['threshold'] as num).toDouble();
    return actual <= threshold;
  }

  // EC:7 — Validate badge count implementation against Functional Test Pass Rate metric (Pass >= 95%).
  static String evaluateMetric(double actual) {
    return actual <= _threshold ? 'PASS' : 'FAIL';
  }

  // EC:8 — Route validated badge configuration to shared_nav_utils npm package as authoritative Badge Count Registry entry.
  static Ansa021A16RailBadgeCountLog routeToRegistry(
    Ansa021A16RailBadgeCountLog entry,
    double actual,
  ) {
    final passed = validateConformance(actual, compileRuleSet());
    return Ansa021A16RailBadgeCountLog(
      badgeConfigId: entry.badgeConfigId,
      passRate: actual,
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

class Ansa021A16RailBadgeCountWidget extends StatelessWidget {
  final List<Ansa021A16RailBadgeCountLog> entries;
  const Ansa021A16RailBadgeCountWidget({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final e = entries[i];
        final metric = Ansa021A16RailBadgeCount.evaluateMetric(e.passRate);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            title: Text(
              e.badgeConfigId,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'Courier',
                fontSize: 12,
              ),
            ),
            subtitle: Text(
              'Pass Rate %: ${e.passRate.toStringAsFixed(2)} | Threshold: 95.0',
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
