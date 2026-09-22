// =============================================================================
// AEETE-023 — Pre-Deployment Lineage Trace Sensor
// Atomic Step: Code tracking sensors to monitor lineage context across UI states
// Metric:      Automated Test Coverage · Floor=0.8 · Optimal=0.95
// Standard:    ISTQB / Google Testing Blog
// Decision Group: G1 (Perimeter Security)
// Module:      lineage_trace_sensor.dart
// Repo:        github.com/RitwikHC/theme-typography · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        25-Aug-2026
// =============================================================================

import 'dart:math';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Enums — mirror Python UIState enum
// ---------------------------------------------------------------------------

/// UI states for lineage capture. 5 states required — all must be instrumented.
enum LineageUIState {
  idle,       // IDLE
  loading,    // LOADING
  success,    // SUCCESS
  error,      // ERROR
  transition, // TRANSITION
}

extension LineageUIStateExt on LineageUIState {
  String get dbValue => name.toUpperCase();
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

/// Lineage capture result for one UI state event.
/// Maps to lineage_sensor_execution_log table.

/// Mandatory DCDF lineage headers — AEETE-018 standard.
/// These fields make this file's outputs traceable backward
/// through the pipeline to their origin source document.
class DcdfLineage {
  static const double _floor   = 0.8;  // metric floor gate
  static const double _optimal = 0.95; // metric optimal target

  final String traceId;                // end-to-end transaction UUID
  final String originSourceId;         // originating system node UUID
  final String immediatePredecessorId; // direct upstream node UUID
  final String transformationLogicHash; // SHA-256 of executing EC logic
  final bool   complianceStatusInd;    // DCDF gate: true = passed

  const DcdfLineage({
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
    this.complianceStatusInd = false,
  });
}

class LineageCapture {
  final String traceId;
  final LineageUIState uiState;
  final bool crossTableAccessDetected; // cross_table_access_IND — G1 trigger
  final bool g1AlertFired;             // g1_alert_fired_IND
  final List<String> tablesAccessed;
  final String timestamp;
  final Map<String, dynamic> context;

  const LineageCapture({
    required this.traceId,
    required this.uiState,
    required this.crossTableAccessDetected,
    required this.g1AlertFired,
    required this.tablesAccessed,
    required this.timestamp,
    required this.context,
  });

  Map<String, dynamic> toJson() => {
    'trace_id':                    traceId,
    'ui_state':                    uiState.dbValue,
    'cross_table_access_ind':      crossTableAccessDetected,
    'g1_alert_fired_ind':          g1AlertFired,
    'tables_accessed':             tablesAccessed,
    'timestamp':                   timestamp,
    'context':                     context,
  };
}

/// Coverage validation result.
class LineageCoverageResult {
  final int statesInstrumented; // out of 5
  final double coverageRate;    // 0.0–1.0
  final bool gatePass;          // >= 0.8

  const LineageCoverageResult({
    required this.statesInstrumented,
    required this.coverageRate,
    required this.gatePass,
  });

  String get coverageOutput =>
      coverageRate >= 0.80 ? 'Pass' : 'Fail';
}

// ---------------------------------------------------------------------------
// UUID v4 generator (Dart — no external package)
// ---------------------------------------------------------------------------
String _generateTraceId() {
  final random = Random.secure();
  final bytes  = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0,8)}-${hex.substring(8,12)}-'
         '${hex.substring(12,16)}-${hex.substring(16,20)}-${hex.substring(20)}';
}

// ---------------------------------------------------------------------------
// AEETE-023: Lineage Trace Sensor mixin
// ---------------------------------------------------------------------------

/// Mixin for stateful widgets that need lineage capture across UI states.
///
/// Mirrors lineage_trace_sensor.py — @capture_lineage decorator pattern
/// and LineageTraceCapture class.
///
/// Usage:
/// ```dart
/// class _MyWidgetState extends State<MyWidget> with LineageTraceSensor {
///   @override
///   void initState() {
///     super.initState();
///     captureState(LineageUIState.idle);
///   }
///   ...
/// }
/// ```
mixin LineageTraceSensor<T extends StatefulWidget> on State<T> {

  /// Log of all captures in this session.
  final List<LineageCapture> captureLog = [];

  /// Optional transports, injected by the host. When null, events are still
  /// recorded to [captureLog] and echoed to the debug console. Production wires
  /// these to the G1 security queue and the BigQuery audit stream respectively.
  void Function(LineageUIState state, List<String> tables)? onG1Alert;
  void Function(LineageCapture capture)? onAuditLog;

  // -------------------------------------------------------------------------
  // EC:3 — Capture lineage on widget state change.  // error: EC-AEETE023-001
  // Attach to setState calls or lifecycle hooks.
  // -------------------------------------------------------------------------
  LineageCapture captureState(
    LineageUIState state, {
    List<String> tablesAccessed = const [],
    Map<String, dynamic> context = const {},
  }) {
    final crossAccess = _detectCrossTableAccess(tablesAccessed);
    bool g1Fired = false;

    if (crossAccess) {
      _fireG1Alert(state, tablesAccessed);
      g1Fired = true;
    }

    final capture = LineageCapture(
      traceId:                  _generateTraceId(),
      uiState:                  state,
      crossTableAccessDetected: crossAccess,
      g1AlertFired:             g1Fired,
      tablesAccessed:           tablesAccessed,
      timestamp:                DateTime.now().toUtc().toIso8601String(),
      context:                  context,
    );

    captureLog.add(capture);
    _logToAuditTrail(capture);
    return capture;
  }

  // -------------------------------------------------------------------------
  // EC:5 — Detect cross-table access pattern (G1 Perimeter Security trigger).  // error: EC-AEETE023-002
  // cross_table_access_IND = TRUE when tablesAccessed.length > 1
  // -------------------------------------------------------------------------
  bool _detectCrossTableAccess(List<String> tables) => tables.length > 1;

  // -------------------------------------------------------------------------
  // EC:5 — Fire G1 Perimeter Security alert.  // error: EC-AEETE023-003
  // In production: publish to G1 security alert queue + BigQuery audit trail.
  // -------------------------------------------------------------------------
  void _fireG1Alert(LineageUIState state, List<String> tables) {
    debugPrint(
      '[G1 ALERT] AEETE-023 | Cross-table access in state: ${state.dbValue} | '
      'Tables: ${tables.join(", ")}',
    );
    // Dispatch to the injected G1 security transport when present.
    onG1Alert?.call(state, tables);
  }

  /// Write capture to the audit trail. Echoes to the debug console and, when a
  /// transport is injected, streams to habot_prod_de.lineage_sensor_log.
  void _logToAuditTrail(LineageCapture capture) {
    debugPrint('[LINEAGE] ${capture.toJson()}');
    onAuditLog?.call(capture);
  }

  // -------------------------------------------------------------------------
  // EC:7 — Calculate Automated Test Coverage.  // error: EC-AEETE023-004
  // statesInstrumented / 5 — Floor=0.8, Optimal=0.95
  // -------------------------------------------------------------------------
  LineageCoverageResult calculateCoverage() {
    final instrumented = captureLog
        .map((c) => c.uiState)
        .toSet()
        .length;
    final rate = instrumented / 5;
    return LineageCoverageResult(
      statesInstrumented: instrumented,
      coverageRate:       rate,
      gatePass:           rate >= 0.8,
    );
  }

  // -------------------------------------------------------------------------
  // Triangular Check: captures_registered == captures_validated (delta=0)
  // -------------------------------------------------------------------------
  bool triangularCheck(int registered, int validated) =>
      registered == validated;

  // -------------------------------------------------------------------------
  // Convenience: capture IDLE state on initState
  // -------------------------------------------------------------------------
  void captureIdle() => captureState(LineageUIState.idle);

  // -------------------------------------------------------------------------
  // Convenience: capture LOADING/SUCCESS/ERROR on async operations
  // -------------------------------------------------------------------------
  Future<T2> captureAsync<T2>(
    Future<T2> Function() operation, {
    List<String> tablesAccessed = const [],
  }) async {
    captureState(LineageUIState.loading, tablesAccessed: tablesAccessed);
    try {
      final result = await operation();
      captureState(LineageUIState.success, tablesAccessed: tablesAccessed);
      return result;
    } catch (e) {
      captureState(LineageUIState.error,
          tablesAccessed: tablesAccessed, context: {'error': e.toString()});
      rethrow;
    }
  }
}

// ---------------------------------------------------------------------------
// Example: widget using LineageTraceSensor mixin
// ---------------------------------------------------------------------------

class LineageTrackedWidget extends StatefulWidget {
  const LineageTrackedWidget({super.key});

  @override
  State<LineageTrackedWidget> createState() => _LineageTrackedWidgetState();
}

class _LineageTrackedWidgetState extends State<LineageTrackedWidget>
    with LineageTraceSensor {

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    captureIdle(); // EC:3 — IDLE state captured  // error: EC-AEETE023-005
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    // EC:3 — LOADING  // error: EC-AEETE023-006/SUCCESS captured with cross-table check
    await captureAsync(
      () => Future.delayed(const Duration(seconds: 1)),
      tablesAccessed: ['enrollment_submissions'], // single table — no G1
    );
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final coverage = calculateCoverage();
    return Column(
      children: [
        Text('States captured: ${captureLog.length}'),
        Text('Coverage: ${(coverage.coverageRate * 100).toStringAsFixed(0)}% '
             '(${coverage.coverageOutput})'),
        if (_loading) const CircularProgressIndicator(),
        ElevatedButton(
          onPressed: _loadData,
          child: const Text('Load Data'),
        ),
      ],
    );
  }
}
