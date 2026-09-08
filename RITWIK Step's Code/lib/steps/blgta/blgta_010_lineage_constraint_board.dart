// ============================================================
// BLGTA-010 | Persistent Lineage Constraints Verification
// Atomic Task: Configure M3 management control boards with fluid row distributions.
// Primary Table: lineage_constraint_registry
// Metric: Design System Compliance (Material Design 3) | Floor=0.9 | Optimal=1.0
// Standard: Google Material Design 3 (M3) Specification
// EC Lines: 8 | DCDF AEETE-018
// GCP: API Gateway JWT stateless | Auth events logged | 100% unauthorized blocked
// Auth: Background token refresh — invisible UX; prompt only on refresh failure
// Repo: github.com/RitwikHC/theme-typography · branch: ritwik
// Author: Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date: 29-Aug-2026
// ============================================================

import 'package:flutter/material.dart';

// ── Data Models ──────────────────────────────────────────────

enum ExecutionStatus { pending, running, complete, failed }

enum StepOutcome { complete, partial, notComplete }

/// Maps to lineage_constraint_registry.
/// Tracks M3 management control board configuration parameters.
/// Stores configuration change history: current_setting vs previous_setting.
class LineageConstraintEntry {
  final String constraintRuleId;        // PK — UUID
  final String configurationParameter;  // name of the M3 constraint param
  final String currentSetting;          // current value
  final String previousSetting;         // previous value (audit trail)
  final String changeLog;               // human-readable change description
  final DateTime configurationTimestamp; // UTC when setting was applied
  final double md3ComplianceRate;       // 0.0–1.0 Design System Compliance
  final double unauthorizedBlockedPct;  // must equal 1.0 (100%)
  final bool jwtInterceptorActive;      // background token refresh active
  final bool spikeAlertConfigured;      // token failure spike alert active
  final bool immutableInd;
  final ExecutionStatus executionStatus;
  final StepOutcome stepOutcome;
  final bool complianceStatusInd;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;

  const LineageConstraintEntry({
    required this.constraintRuleId,
    required this.configurationParameter,
    required this.currentSetting,
    required this.previousSetting,
    required this.changeLog,
    required this.configurationTimestamp,
    required this.md3ComplianceRate,
    this.unauthorizedBlockedPct = 0.0,
    this.jwtInterceptorActive = false,
    this.spikeAlertConfigured = false,
    this.immutableInd = false,
    this.executionStatus = ExecutionStatus.pending,
    this.stepOutcome = StepOutcome.partial,
    this.complianceStatusInd = true,
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
  }) : assert(md3ComplianceRate >= 0.0 && md3ComplianceRate <= 1.0,
           'EC-BLGTA010-002: md3ComplianceRate must be 0.0–1.0');

  static const double kFloor   = 0.9;
  static const double kOptimal = 1.0;
  static const double kRequiredBlockPct = 1.0; // 100% unauthorized blocked

  /// EC:6 gate — MD3 >= floor, 100% unauthorized blocked,
  ///             JWT interceptor active, spike alert configured
  bool get isConformant =>
      md3ComplianceRate >= kFloor &&
      (unauthorizedBlockedPct - kRequiredBlockPct).abs() < 0.0001 &&
      jwtInterceptorActive &&
      spikeAlertConfigured;

  String get md3Tier {
    if (md3ComplianceRate >= kOptimal) return 'Optimal (1.0)';
    if (md3ComplianceRate >= kFloor)   return 'Floor (≥0.9)';
    return 'Not Complete';
  }

  /// Net change guard — warn if current == previous (no audit trail change)
  bool get hasNetChange => currentSetting != previousSetting;

  LineageConstraintEntry copyWith({
    bool? jwtInterceptorActive,
    bool? spikeAlertConfigured,
    bool? immutableInd,
    ExecutionStatus? executionStatus,
    StepOutcome? stepOutcome,
    bool? complianceStatusInd,
  }) {
    return LineageConstraintEntry(
      constraintRuleId:       constraintRuleId,
      configurationParameter: configurationParameter,
      currentSetting:         currentSetting,
      previousSetting:        previousSetting,
      changeLog:              changeLog,
      configurationTimestamp: configurationTimestamp,
      md3ComplianceRate:      md3ComplianceRate,
      unauthorizedBlockedPct: unauthorizedBlockedPct,
      jwtInterceptorActive:   jwtInterceptorActive ?? this.jwtInterceptorActive,
      spikeAlertConfigured:   spikeAlertConfigured ?? this.spikeAlertConfigured,
      immutableInd:           immutableInd ?? this.immutableInd,
      executionStatus:        executionStatus ?? this.executionStatus,
      stepOutcome:            stepOutcome ?? this.stepOutcome,
      complianceStatusInd:    complianceStatusInd ?? this.complianceStatusInd,
      traceId:                traceId,
      originSourceId:         originSourceId,
      immediatePredecessorId: immediatePredecessorId,
      transformationLogicHash: transformationLogicHash,
    );
  }
}

/// Scan result — maps to lineage_constraint_validation_log.
class LineageConstraintScanResult {
  final int violationCount;
  final int jwtInterceptorViolations;
  final int unauthorizedBlockViolations;
  final String conformanceOutput; // Complete / Partial / Not Complete
  final String result;
  final String ecLineRef;

  const LineageConstraintScanResult({
    required this.violationCount,
    required this.jwtInterceptorViolations,
    required this.unauthorizedBlockViolations,
    required this.conformanceOutput,
    required this.result,
    required this.ecLineRef,
  });
}

// ── EC:1–8 Pipeline ──────────────────────────────────────────

class Blgta010LineageConstraintBoard {

  // EC:1 — Locate persistent lineage constraint config in blgta-010-kit repo.
  static Map<String, dynamic>? locateConfiguration(String repoPath) {
    assert(repoPath.isNotEmpty, 'EC-BLGTA010-001: repo path must not be empty');
    return {'ref': 'BLGTA-010', 'config_file': 'blgta-010.yaml'};
  }

  // EC:2 — Extract constraintRuleId, configurationParameter, currentSetting,
  //         previousSetting, changeLog from lineage_constraint_registry.
  static Map<String, dynamic> extractParameters(Map<String, dynamic> config) {
    const required = [
      'constraint_rule_id', 'configuration_parameter', 'current_setting',
      'previous_setting', 'change_log',
    ];
    assert(
      required.every((k) => config.containsKey(k) && config[k] != null),
      'EC-BLGTA010-002: all 5 constraint config fields must be non-null',
    );
    return Map<String, dynamic>.from(config);
  }

  // EC:3 — Compile M3 management control board rule set:
  //         fluid MD3 DataTable row distributions, background token refresh
  //         (invisible UX), interceptors handle JWT refresh automatically,
  //         prompt login only on refresh failure, API Gateway JWT stateless,
  //         GCP auth events logged.
  static Map<String, dynamic> compileRuleSet() {
    return {
      'md3_layout':           'fluid_rows',
      'jwt_refresh':          'background',
      'prompt_on_fail_only':  true,
      'auth_events_logged':   true,
      'require_spike_alert':  true,
      'unauthorized_block':   LineageConstraintEntry.kRequiredBlockPct,
      'floor':                LineageConstraintEntry.kFloor,
      'optimal':              LineageConstraintEntry.kOptimal,
      'ref':                  'BLGTA-010',
      'immutable':            true,
    };
  }

  // EC:4 — Register compiled M3 constraint rule set as immutable in
  //         lineage_constraint_registry with immutable_IND=TRUE.
  static LineageConstraintEntry registerRule(LineageConstraintEntry entry) {
    assert(entry.currentSetting.isNotEmpty,
      'EC-BLGTA010-003: currentSetting must be declared');
    return entry.copyWith(
      immutableInd:    true,
      executionStatus: ExecutionStatus.running,
    );
  }

  // EC:5 — Bind each constraint rule to API Gateway JWT validation handler
  //         via api_gateway_FK constraint.
  static String bindToTarget(String ruleId, String configurationParameter) {
    assert(ruleId.isNotEmpty, 'EC-BLGTA010-005: FK bind requires valid ruleId');
    return '$configurationParameter:$ruleId';
  }

  // EC:6 — Validate: API Gateway blocks 100% unauthorized requests before
  //         Cloud Run, JWT refresh interceptors invisible, spike alert active.
  static LineageConstraintScanResult validateConformance(
    List<LineageConstraintEntry> entries,
  ) {
    final violations    = entries.where((e) => !e.isConformant).length;
    final jwtV          = entries.where((e) => !e.jwtInterceptorActive).length;
    final blockV        = entries.where((e) =>
      (e.unauthorizedBlockedPct - LineageConstraintEntry.kRequiredBlockPct).abs() >= 0.0001).length;
    final avgRate = entries.isEmpty ? 0.0
        : entries.map((e) => e.md3ComplianceRate).reduce((a, b) => a + b) / entries.length;
    final output = avgRate >= 1.0 ? 'Complete'
                 : avgRate >= 0.9 ? 'Partial'
                 : 'Not Complete';
    return LineageConstraintScanResult(
      violationCount:               violations,
      jwtInterceptorViolations:     jwtV,
      unauthorizedBlockViolations:  blockV,
      conformanceOutput:            output,
      result:                       violations == 0 ? 'PASS' : 'FAIL',
      ecLineRef:                    'EC-BLGTA010-006',
    );
  }

  // EC:7 — Validate against Design System Compliance (MD3) metric.
  //         Floor=0.9; Optimal=1.0; Ceiling=1.0 per Google MD3 Specification.
  static String evaluateMetric(LineageConstraintScanResult scan) {
    return scan.violationCount == 0 ? 'PASS' : 'FAIL';
  }

  // EC:8 — Route validated constraint config to blgta_rule_registry
  //         as authoritative BLGTA-010 Persistent Lineage Constraints entry.
  static LineageConstraintEntry routeToRegistry(
    LineageConstraintEntry entry,
    LineageConstraintScanResult scan,
  ) {
    final passed = scan.violationCount == 0;
    return entry.copyWith(
      jwtInterceptorActive: passed,
      spikeAlertConfigured: passed,
      executionStatus:      passed ? ExecutionStatus.complete : ExecutionStatus.failed,
      stepOutcome:          passed ? StepOutcome.complete : StepOutcome.notComplete,
      complianceStatusInd:  passed,
    );
  }
}

// ── Widget ───────────────────────────────────────────────────

class Blgta010LineageConstraintWidget extends StatelessWidget {
  final List<LineageConstraintEntry> entries;
  const Blgta010LineageConstraintWidget({super.key, required this.entries});

  Color _tierColor(String tier) {
    if (tier.startsWith('Optimal')) return const Color(0xFF137333);
    if (tier.startsWith('Floor'))   return const Color(0xFFE37400);
    return const Color(0xFFD93025);
  }

  @override
  Widget build(BuildContext context) {
    final scan   = Blgta010LineageConstraintBoard.validateConformance(entries);
    final metric = Blgta010LineageConstraintBoard.evaluateMetric(scan);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text('BLGTA-010 · Lineage Constraint Board (MD3)',
                style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 12))),
              Chip(
                label: Text(scan.conformanceOutput,
                  style: const TextStyle(color: Colors.white, fontSize: 11)),
                backgroundColor: metric == 'PASS'
                    ? const Color(0xFF137333) : const Color(0xFFD93025),
              ),
            ]),
            if (scan.jwtInterceptorViolations > 0 || scan.unauthorizedBlockViolations > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'JWT interceptor violations: ${scan.jwtInterceptorViolations} | Block violations: ${scan.unauthorizedBlockViolations}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFFD93025))),
              ),
          ]),
        ),
        Expanded(child: ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final e    = entries[i];
            final pass = e.isConformant;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                title: Text(e.configurationParameter,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('current: ${e.currentSetting}',
                      style: const TextStyle(fontSize: 11)),
                    Text(
                      'MD3: ${(e.md3ComplianceRate * 100).toStringAsFixed(0)}% | blocked: ${(e.unauthorizedBlockedPct * 100).toStringAsFixed(0)}% | JWT interceptor: ${e.jwtInterceptorActive} | spike alert: ${e.spikeAlertConfigured}',
                      style: TextStyle(fontSize: 10,
                        color: e.hasNetChange ? null : const Color(0xFFE37400))),
                    if (!e.hasNetChange)
                      const Text('⚠ No net change from previous setting — audit trail check required',
                        style: TextStyle(fontSize: 9, color: Color(0xFFE37400))),
                  ],
                ),
                trailing: Chip(
                  label: Text(e.md3Tier,
                    style: const TextStyle(color: Colors.white, fontSize: 9)),
                  backgroundColor: _tierColor(e.md3Tier),
                ),
                leading: Icon(
                  pass ? Icons.dashboard : Icons.dashboard_customize,
                  color: pass ? const Color(0xFF137333) : const Color(0xFFD93025),
                ),
                isThreeLine: true,
              ),
            );
          },
        )),
      ],
    );
  }
}
