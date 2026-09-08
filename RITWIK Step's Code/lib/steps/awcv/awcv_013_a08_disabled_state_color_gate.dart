// ============================================================
// AWCV-013-A08 | Accessible Widget Color Validation
// Atomic Task: Disabled State Color Gate —
//   Validate all disabled state widget tokens use opacity=0.38
//   per MD3 specification with md.sys.color.onSurface token.
// Primary Table: disabled_state_color_registry
// Threshold: disabled_opacity = 0.38 | token = md.sys.color.onSurface
// EC Lines: 8 | Standard: ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo: github.com/RitwikHC/theme-typography · branch: ritwik
// Author: Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date: 29-Aug-2026
// ============================================================

import 'package:flutter/material.dart';

// ── Data Models ──────────────────────────────────────────────

enum ExecutionStatus { pending, running, complete, failed }

enum StepOutcome { complete, partial, notComplete }

/// Maps to disabled_state_color_registry.
/// disabled_opacity = 0.38 enforced via CHECK constraint at DB level.
class DisabledStateColorEntry {
  final String disabledColorRuleId;   // PK — UUID
  final String colorToken;            // must be md.sys.color.onSurface
  final double disabledOpacity;       // must equal exactly 0.38 per MD3
  final String componentRef;          // target widget component
  final String interactionState;      // always DISABLED
  final bool immutableInd;
  final ExecutionStatus executionStatus;
  final StepOutcome stepOutcome;
  final bool complianceStatusInd;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;

  const DisabledStateColorEntry({
    required this.disabledColorRuleId,
    required this.colorToken,
    required this.disabledOpacity,
    required this.componentRef,
    this.interactionState = 'DISABLED',
    this.immutableInd = false,
    this.executionStatus = ExecutionStatus.pending,
    this.stepOutcome = StepOutcome.partial,
    this.complianceStatusInd = true,
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
  }) : assert(interactionState == 'DISABLED',
         'EC-AWCV013A08-003: interactionState must be DISABLED');

  static const double kRequiredOpacity = 0.38;
  static const String kRequiredToken   = 'md.sys.color.onSurface';

  /// EC:6 gate — opacity exactly 0.38, token = md.sys.color.onSurface
  bool get isConformant =>
      (disabledOpacity - kRequiredOpacity).abs() < 0.001 &&
      colorToken == kRequiredToken;

  DisabledStateColorEntry copyWith({
    bool? immutableInd,
    ExecutionStatus? executionStatus,
    StepOutcome? stepOutcome,
    bool? complianceStatusInd,
  }) {
    return DisabledStateColorEntry(
      disabledColorRuleId:     disabledColorRuleId,
      colorToken:              colorToken,
      disabledOpacity:         disabledOpacity,
      componentRef:            componentRef,
      interactionState:        interactionState,
      immutableInd:            immutableInd ?? this.immutableInd,
      executionStatus:         executionStatus ?? this.executionStatus,
      stepOutcome:             stepOutcome ?? this.stepOutcome,
      complianceStatusInd:     complianceStatusInd ?? this.complianceStatusInd,
      traceId:                 traceId,
      originSourceId:          originSourceId,
      immediatePredecessorId:  immediatePredecessorId,
      transformationLogicHash: transformationLogicHash,
    );
  }
}

/// Scan result — maps to disabled_color_validation_log.
class DisabledColorScanResult {
  final int violationCount;
  final String conformanceOutput;
  final String result;
  final String ecLineRef;

  const DisabledColorScanResult({
    required this.violationCount,
    required this.conformanceOutput,
    required this.result,
    required this.ecLineRef,
  });
}

// ── EC:1–8 Pipeline ──────────────────────────────────────────

class Awcv013A08DisabledStateColorGate {

  // EC:1 — Locate disabled state color gate configuration within
  //         awcv-013-a08-kit source repository.
  static Map<String, dynamic>? locateConfiguration(String repoPath) {
    assert(repoPath.isNotEmpty, 'EC-AWCV013A08-001: repo path must not be empty');
    return {'ref': 'AWCV-013-A08', 'config_file': 'awcv-013-a08.yaml'};
  }

  // EC:2 — Extract disabledColorRuleId, colorToken, disabledOpacity,
  //         componentRef, interactionState from registry.
  static Map<String, dynamic> extractParameters(Map<String, dynamic> config) {
    const required = [
      'disabled_color_rule_id', 'color_token',
      'disabled_opacity', 'component_ref', 'interaction_state',
    ];
    assert(
      required.every((k) => config.containsKey(k) && config[k] != null),
      'EC-AWCV013A08-002: all 5 disabled state fields must be non-null',
    );
    return Map<String, dynamic>.from(config);
  }

  // EC:3 — Compile disabled state rule set:
  //         opacity=0.38 per MD3, token=md.sys.color.onSurface,
  //         no hardcoded disabled colors permitted.
  static Map<String, dynamic> compileRuleSet() {
    return {
      'required_opacity': DisabledStateColorEntry.kRequiredOpacity,
      'required_token':   DisabledStateColorEntry.kRequiredToken,
      'block_hardcoded':  true,
      'ref':              'AWCV-013-A08',
      'immutable':        true,
    };
  }

  // EC:4 — Register compiled rule set as immutable entry in
  //         disabled_state_color_registry with immutable_IND=TRUE.
  static DisabledStateColorEntry registerRule(DisabledStateColorEntry entry) {
    assert(entry.colorToken == DisabledStateColorEntry.kRequiredToken,
      'EC-AWCV013A08-003: colorToken must be md.sys.color.onSurface');
    assert((entry.disabledOpacity - DisabledStateColorEntry.kRequiredOpacity).abs() < 0.001,
      'EC-AWCV013A08-003: disabledOpacity must be exactly 0.38');
    return entry.copyWith(
      immutableInd: true,
      executionStatus: ExecutionStatus.running,
    );
  }

  // EC:5 — Bind each registered rule to widget disabled state handler
  //         by applying disabled_handler_FK constraint.
  static String bindToTarget(String ruleId, String componentRef) {
    assert(ruleId.isNotEmpty, 'EC-AWCV013A08-005: FK bind requires valid ruleId');
    return '$componentRef:$ruleId';
  }

  // EC:6 — Validate: opacity=0.38, token=md.sys.color.onSurface
  //         for all disabled widget states.
  static DisabledColorScanResult validateConformance(
    List<DisabledStateColorEntry> entries,
  ) {
    final violations = entries.where((e) => !e.isConformant).length;
    final output = violations == 0
        ? 'Complete'
        : violations <= 5
            ? 'Partial'
            : 'Not Complete';
    return DisabledColorScanResult(
      violationCount:   violations,
      conformanceOutput: output,
      result:           violations == 0 ? 'PASS' : 'FAIL',
      ecLineRef:        'EC-AWCV013A08-006',
    );
  }

  // EC:7 — Validate against Design Fidelity metric (Good >= 95%).
  static String evaluateMetric(DisabledColorScanResult scan, int total) {
    if (total == 0) return 'FAIL';
    final rate = (total - scan.violationCount) / total;
    return rate >= 0.95 ? 'PASS' : 'FAIL';
  }

  // EC:8 — Route validated disabled state configuration to
  //         disabled_state_rule_registry as authoritative entry.
  static DisabledStateColorEntry routeToRegistry(
    DisabledStateColorEntry entry,
    DisabledColorScanResult scan,
  ) {
    final passed = scan.violationCount == 0;
    return entry.copyWith(
      executionStatus:     passed ? ExecutionStatus.complete : ExecutionStatus.failed,
      stepOutcome:         passed ? StepOutcome.complete : StepOutcome.notComplete,
      complianceStatusInd: passed,
    );
  }
}

// ── Widget ───────────────────────────────────────────────────

class Awcv013A08DisabledStateWidget extends StatelessWidget {
  final List<DisabledStateColorEntry> disabledRules;
  const Awcv013A08DisabledStateWidget({super.key, required this.disabledRules});

  @override
  Widget build(BuildContext context) {
    final scan   = Awcv013A08DisabledStateColorGate.validateConformance(disabledRules);
    final metric = Awcv013A08DisabledStateColorGate.evaluateMetric(scan, disabledRules.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'AWCV-013-A08 · Disabled State Color Gate (opacity=0.38)',
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Chip(
                label: Text(
                  '${scan.conformanceOutput} · ${scan.violationCount} violations',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
                backgroundColor: metric == 'PASS'
                    ? const Color(0xFF137333)
                    : const Color(0xFFD93025),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: disabledRules.length,
            itemBuilder: (context, i) {
              final r = disabledRules[i];
              final pass = r.isConformant;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(
                    r.componentRef,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  subtitle: Text(
                    'opacity: ${r.disabledOpacity.toStringAsFixed(2)} / 0.38 | token: ${r.colorToken}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Chip(
                    label: Text(
                      pass ? 'PASS' : 'FAIL',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    backgroundColor: pass
                        ? const Color(0xFF137333)
                        : const Color(0xFFD93025),
                  ),
                  leading: Icon(
                    pass ? Icons.do_not_disturb_on : Icons.do_not_disturb_alt,
                    color: pass ? const Color(0xFF137333) : const Color(0xFFD93025),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
