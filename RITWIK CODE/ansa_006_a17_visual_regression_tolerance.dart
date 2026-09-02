// ============================================================
// ANSA-006-A17 | Visual Regression Tolerance Gate
// Atomic Task: Validate pixel-level visual regression
//   tolerance thresholds for the Navigation Shell component
//   across all captured snapshot states.
// EC Lines: 8 | Standard: DCDF AEETE-018
// ============================================================

import 'package:flutter/material.dart';

// ── Data Models ──────────────────────────────────────────────

enum SnapshotStatus { pending, running, complete, failed }

class SnapshotExecutionLog {
  final String snapshotId;
  final String componentRef;       // ANSA-006-A17
  final String navState;           // e.g. home / search / profile
  final double pixelDiffPercent;   // actual diff %
  final double floorThreshold;     // 2.0%
  final double optimalThreshold;   // 0.5%
  final double ceilingThreshold;   // 0.0% — hard fail
  final bool passedInd;
  final SnapshotStatus status;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool complianceStatusInd;

  const SnapshotExecutionLog({
    required this.snapshotId,
    required this.componentRef,
    required this.navState,
    required this.pixelDiffPercent,
    required this.floorThreshold,
    required this.optimalThreshold,
    required this.ceilingThreshold,
    required this.passedInd,
    required this.status,
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
    required this.complianceStatusInd,
  });
}

// ── EC:1–8 Pipeline ──────────────────────────────────────────

class Ansa006A17VisualRegressionTolerance {

  static const double _floor   = 2.0;   // EC:3 — floor gate
  static const double _optimal = 0.5;   // EC:3 — optimal
  static const double _ceiling = 0.0;   // EC:3 — ceiling (hard fail if exceeded downward)

  // EC:1 — Locate snapshot baseline registry
  static Map<String, Uint8List>? locateBaselineRegistry(String componentRef) {
    // Queries snapshot_execution_log for baseline images per nav state
    assert(componentRef == 'ANSA-006-A17', 'Invalid component ref');
    return {}; // resolved from registry at runtime
  }

  // EC:2 — Extract nav states for capture
  static List<String> extractNavStates(Map<String, dynamic> config) {
    return List<String>.from(config['nav_states'] ?? ['home','search','profile','settings']);
  }

  // EC:3 — Compile tolerance rule set
  static Map<String, double> compileToleranceRules() {
    return {
      'floor':   _floor,
      'optimal': _optimal,
      'ceiling': _ceiling,
    };
  }

  // EC:4 — Register rules as immutable in snapshot_execution_log
  static SnapshotExecutionLog registerToleranceRule({
    required String snapshotId,
    required String navState,
    required String traceId,
    required String originSourceId,
    required String predecessorId,
    required String logicHash,
  }) {
    return SnapshotExecutionLog(
      snapshotId: snapshotId,
      componentRef: 'ANSA-006-A17',
      navState: navState,
      pixelDiffPercent: 0.0,
      floorThreshold: _floor,
      optimalThreshold: _optimal,
      ceilingThreshold: _ceiling,
      passedInd: false,
      status: SnapshotStatus.pending,
      traceId: traceId,
      originSourceId: originSourceId,
      immediatePredecessorId: predecessorId,
      transformationLogicHash: logicHash,
      complianceStatusInd: true,
    );
  }

  // EC:5 — Bind snapshot to nav state renderer
  static String bindToNavStateRenderer(String snapshotId, String navState) {
    return '${navState}_renderer:$snapshotId';
  }

  // EC:6 — Validate pixel diff against floor gate
  static bool validatePixelDiff(double actualDiff, Map<String, double> rules) {
    // Pass if actualDiff <= floor; fail if actualDiff > floor
    return actualDiff <= rules['floor']!;
  }

  // EC:7 — Validate Visual Regression Tolerance metric
  static String evaluateToleranceMetric(double actualDiff) {
    if (actualDiff <= _optimal)  return 'OPTIMAL';
    if (actualDiff <= _floor)    return 'PASS';
    return 'FAIL';
  }

  // EC:8 — Route validated snapshot log to snapshot_execution_log registry
  static SnapshotExecutionLog routeToRegistry(
    SnapshotExecutionLog entry,
    double actualDiff,
  ) {
    final passed = validatePixelDiff(actualDiff, compileToleranceRules());
    return SnapshotExecutionLog(
      snapshotId: entry.snapshotId,
      componentRef: entry.componentRef,
      navState: entry.navState,
      pixelDiffPercent: actualDiff,
      floorThreshold: entry.floorThreshold,
      optimalThreshold: entry.optimalThreshold,
      ceilingThreshold: entry.ceilingThreshold,
      passedInd: passed,
      status: passed ? SnapshotStatus.complete : SnapshotStatus.failed,
      traceId: entry.traceId,
      originSourceId: entry.originSourceId,
      immediatePredecessorId: entry.immediatePredecessorId,
      transformationLogicHash: entry.transformationLogicHash,
      complianceStatusInd: passed,
    );
  }
}

// ── Widget ───────────────────────────────────────────────────

class VisualRegressionToleranceWidget extends StatelessWidget {
  final List<SnapshotExecutionLog> snapshots;
  const VisualRegressionToleranceWidget({super.key, required this.snapshots});

  Color _statusColor(String metric) {
    switch (metric) {
      case 'OPTIMAL': return const Color(0xFF137333);
      case 'PASS':    return const Color(0xFF1A73E8);
      default:        return const Color(0xFFD93025);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: snapshots.map((s) {
        final metric = Ansa006A17VisualRegressionTolerance.evaluateToleranceMetric(
          s.pixelDiffPercent,
        );
        return ListTile(
          title: Text(s.navState, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('Diff: ${s.pixelDiffPercent.toStringAsFixed(2)}% | Floor: ${s.floorThreshold}%'),
          trailing: Chip(
            label: Text(metric, style: const TextStyle(color: Colors.white, fontSize: 11)),
            backgroundColor: _statusColor(metric),
          ),
        );
      }).toList(),
    );
  }
}

// ignore_for_file: undefined_class
typedef Uint8List = List<int>;
