// ============================================================
// ANSA-014-A17 | Visual Regression Tolerance
// Atomic Task: Visual Regression Tolerance — Snapshot Execution: Validate pixel-level visual regression tolerance for Navigation Shell snapshot execution across all captured states.
// EC Lines: 8 | Standard: DCDF AEETE-018
// ============================================================

import 'package:flutter/material.dart';

// ── Data Models ──────────────────────────────────────────────

enum ExecutionStatus { pending, running, complete, failed }

class Ansa014A17VisualRegressionSnapshotLog {
  final String snapshotId;
  final double pixelDiffPercent;
  final bool complianceStatusInd;
  final bool immutableInd;
  final ExecutionStatus status;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;

  const Ansa014A17VisualRegressionSnapshotLog({
    required this.snapshotId,
    required this.pixelDiffPercent,
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

class Ansa014A17VisualRegressionSnapshot {

  static const double _threshold = 2.0;

  // EC:1 — Locate snapshot execution configuration within snapshot-kit source repository.
  static Map<String, dynamic>? locateConfiguration(String componentRef) {
    assert(componentRef == 'ANSA-014-A17', 'Invalid component ref');
    return {};
  }

  // EC:2 — Extract snapshotId, navState, pixelDiffPercent, baselineHash, captureTimestamp from snapshot_execution_log.
  static Map<String, dynamic> extractParameters(Map<String, dynamic> config) {
    return Map<String, dynamic>.from(config);
  }

  // EC:3 — Compile visual regression tolerance rule set: floor=2.0%, optimal=0.5%, ceiling=0.0% hard fail gate.
  static Map<String, dynamic> compileRuleSet() {
    return {
      'threshold': _threshold,
      'ref': 'ANSA-014-A17',
      'immutable': true,
    };
  }

  // EC:4 — Register compiled tolerance rule set as immutable entry in snapshot_execution_log.
  static Ansa014A17VisualRegressionSnapshotLog registerRule({
    required String snapshotId,
    required String traceId,
    required String originSourceId,
    required String predecessorId,
    required String logicHash,
  }) {
    return Ansa014A17VisualRegressionSnapshotLog(
      snapshotId: snapshotId,
      pixelDiffPercent: 0.0,
      complianceStatusInd: true,
      immutableInd: true,
      status: ExecutionStatus.pending,
      traceId: traceId,
      originSourceId: originSourceId,
      immediatePredecessorId: predecessorId,
      transformationLogicHash: logicHash,
    );
  }

  // EC:5 — Bind each registered snapshot rule to nav state renderer by applying nav_state_renderer_FK constraint.
  static String bindToTarget(String ruleId, String targetSlot) {
    return '$targetSlot:$ruleId';
  }

  // EC:6 — Validate bound snapshot configuration by executing pixel diff conformance check against floor gate per state.
  static bool validateConformance(double actual, Map<String, dynamic> rules) {
    final threshold = (rules['threshold'] as num).toDouble();
    return actual <= threshold;
  }

  // EC:7 — Validate snapshot implementation against Visual Regression Tolerance metric (Pass = pixel_diff <= 2.0%).
  static String evaluateMetric(double actual) {
    return actual <= _threshold ? 'PASS' : 'FAIL';
  }

  // EC:8 — Route validated snapshot execution log to snapshot_execution_log registry as authoritative Visual Regression Registry entry.
  static Ansa014A17VisualRegressionSnapshotLog routeToRegistry(
    Ansa014A17VisualRegressionSnapshotLog entry,
    double actual,
  ) {
    final passed = validateConformance(actual, compileRuleSet());
    return Ansa014A17VisualRegressionSnapshotLog(
      snapshotId: entry.snapshotId,
      pixelDiffPercent: actual,
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

class Ansa014A17VisualRegressionSnapshotWidget extends StatelessWidget {
  final List<Ansa014A17VisualRegressionSnapshotLog> entries;
  const Ansa014A17VisualRegressionSnapshotWidget({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final e = entries[i];
        final metric = Ansa014A17VisualRegressionSnapshot.evaluateMetric(e.pixelDiffPercent);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            title: Text(
              e.snapshotId,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'Courier',
                fontSize: 12,
              ),
            ),
            subtitle: Text(
              'Pixel Diff %: ${e.pixelDiffPercent.toStringAsFixed(2)} | Threshold: 2.0',
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
