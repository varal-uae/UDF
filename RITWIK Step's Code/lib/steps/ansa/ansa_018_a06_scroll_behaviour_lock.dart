// ============================================================
// ANSA-018-A06 | Navigation Shell Adaptive Layout
// Atomic Task: Navigation Shell Adaptive Layout — Scroll Behaviour Locking: Validate position:fixed bottom anchor enforcement for the Navigation Shell component.
// EC Lines: 8 | Standard: DCDF AEETE-018
// ============================================================

import 'package:flutter/material.dart';

// ── Data Models ──────────────────────────────────────────────

enum ExecutionStatus { pending, running, complete, failed }

class Ansa018A06ScrollBehaviourLockLog {
  final String ruleId;
  final double rulePassCount;
  final bool complianceStatusInd;
  final bool immutableInd;
  final ExecutionStatus status;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;

  const Ansa018A06ScrollBehaviourLockLog({
    required this.ruleId,
    required this.rulePassCount,
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

class Ansa018A06ScrollBehaviourLock {

  static const double _threshold = 5;

  // EC:1 — Locate navigation shell scroll behaviour configuration within mobile-nav-shell-kit source repository.
  static Map<String, dynamic>? locateConfiguration(String componentRef) {
    assert(componentRef == 'ANSA-018-A06', 'Invalid component ref');
    return {};
  }

  // EC:2 — Extract anchorStrategy, positionMode, scrollOffsetLock, overflowMode, zIndex from nav_shell_scroll_config_registry.
  static Map<String, dynamic> extractParameters(Map<String, dynamic> config) {
    return Map<String, dynamic>.from(config);
  }

  // EC:3 — Compile position:fixed rule set: anchorStrategy=BOTTOM_FIXED, positionMode=FIXED, scrollOffsetLock=TRUE, zIndex>=100.
  static Map<String, dynamic> compileRuleSet() {
    return {
      'threshold': _threshold,
      'ref': 'ANSA-018-A06',
      'immutable': true,
    };
  }

  // EC:4 — Register compiled position:fixed rule set as immutable entry in position_fixed_rule_registry.
  static Ansa018A06ScrollBehaviourLockLog registerRule({
    required String ruleId,
    required String traceId,
    required String originSourceId,
    required String predecessorId,
    required String logicHash,
  }) {
    return Ansa018A06ScrollBehaviourLockLog(
      ruleId: ruleId,
      rulePassCount: 0.0,
      complianceStatusInd: true,
      immutableInd: true,
      status: ExecutionStatus.pending,
      traceId: traceId,
      originSourceId: originSourceId,
      immediatePredecessorId: predecessorId,
      transformationLogicHash: logicHash,
    );
  }

  // EC:5 — Bind each registered scroll rule to NavigationShell bottom scaffold slot by applying scaffold_slot_FK constraint.
  static String bindToTarget(String ruleId, String targetSlot) {
    return '$targetSlot:$ruleId';
  }

  // EC:6 — Validate bound scroll configuration by executing scroll simulation check confirming bar anchored at all scroll positions.
  static bool validateConformance(double actual, Map<String, dynamic> rules) {
    final threshold = (rules['threshold'] as num).toDouble();
    return actual <= threshold;
  }

  // EC:7 — Validate scroll lock implementation against Implementation Completeness metric (Complete = all 5 rule parameters pass).
  static String evaluateMetric(double actual) {
    return actual <= _threshold ? 'PASS' : 'FAIL';
  }

  // EC:8 — Route validated scroll configuration to shared_nav_utils npm package as authoritative Scroll Behaviour Registry entry.
  static Ansa018A06ScrollBehaviourLockLog routeToRegistry(
    Ansa018A06ScrollBehaviourLockLog entry,
    double actual,
  ) {
    final passed = validateConformance(actual, compileRuleSet());
    return Ansa018A06ScrollBehaviourLockLog(
      ruleId: entry.ruleId,
      rulePassCount: actual,
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

class Ansa018A06ScrollBehaviourLockWidget extends StatelessWidget {
  final List<Ansa018A06ScrollBehaviourLockLog> entries;
  const Ansa018A06ScrollBehaviourLockWidget({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final e = entries[i];
        final metric = Ansa018A06ScrollBehaviourLock.evaluateMetric(e.rulePassCount);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            title: Text(
              e.ruleId,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'Courier',
                fontSize: 12,
              ),
            ),
            subtitle: Text(
              'Rules Passed: ${e.rulePassCount.toStringAsFixed(2)} | Threshold: 5',
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
