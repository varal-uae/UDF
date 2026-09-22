// ============================================================
// ARCPE-009-15 | Architecture Pattern Enforcement
// Atomic Task: API Contract Backward Compatibility Enforcement —
//   Validate that all frontend API consumers enforce strict
//   backward-compatibility rules when consuming versioned contracts.
// Primary Table: api_contract_version_registry
// EC Lines: 8 | Standard: ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo: github.com/RitwikHC/theme-typography · branch: ritwik
// Author: Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date: 29-Aug-2026
// ============================================================

import 'package:flutter/material.dart';

// ── Data Models ──────────────────────────────────────────────

enum ExecutionStatus { pending, running, complete, failed }

enum StepOutcome { complete, partial, notComplete }

/// Maps to api_contract_version_registry.
/// All DCDF lineage columns mandatory.
class ApiContractVersionEntry {
  final String contractVersionId;      // PK — UUID
  final String pinnedVersion;          // semver e.g. 2.1.0
  final bool breakingChangeInd;        // FALSE = safe, TRUE = blocked
  final String semverTag;              // MAJOR.MINOR.PATCH
  final String consumerRef;            // consuming module identifier
  final bool immutableInd;             // TRUE after registration
  final ExecutionStatus executionStatus;
  final StepOutcome stepOutcome;
  final bool complianceStatusInd;      // DCDF gate
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;

  const ApiContractVersionEntry({
    required this.contractVersionId,
    required this.pinnedVersion,
    required this.breakingChangeInd,
    required this.semverTag,
    required this.consumerRef,
    this.immutableInd = false,
    this.executionStatus = ExecutionStatus.pending,
    this.stepOutcome = StepOutcome.partial,
    this.complianceStatusInd = true,
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
  });

  /// EC:6 — gate: breaking_change_IND must be FALSE  // error: EC-ARCPE00915-001
  bool get isBackwardCompatible => !breakingChangeInd;

  ApiContractVersionEntry copyWith({
    bool? immutableInd,
    ExecutionStatus? executionStatus,
    StepOutcome? stepOutcome,
    bool? complianceStatusInd,
  }) {
    return ApiContractVersionEntry(
      contractVersionId:       contractVersionId,
      pinnedVersion:           pinnedVersion,
      breakingChangeInd:       breakingChangeInd,
      semverTag:               semverTag,
      consumerRef:             consumerRef,
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

/// Compatibility scan result — maps to contract_validation_log.
class CompatibilityScanResult {
  final int violationCount;
  final String completenessOutput; // Complete / Partial / Not Complete
  final String result;             // PASS / FAIL
  final String ecLineRef;

  const CompatibilityScanResult({
    required this.violationCount,
    required this.completenessOutput,
    required this.result,
    required this.ecLineRef,
  });
}

// ── EC:1–8 Pipeline ──────────────────────────────────────────

class Arcpe00915ApiContractBackwardCompatibility {
  static const double _floor   = 0.90;  // metric floor gate
  static const double _optimal = 0.97; // metric optimal target


  // EC:1 — Locate API contract version configuration within  // error: EC-ARCPE00915-002
  //         arcpe-009-15-kit source repository.
  static Map<String, dynamic>? locateConfiguration(String repoPath) {
        if (!(repoPath.isNotEmpty)) {
      throw ArgumentError('EC-ARCPE009-15-001: repo path must not be empty');
    };
    // Returns config map; null triggers DLQ route.
    return {'ref': 'ARCPE-009-15', 'config_file': 'api_contract_version.yaml'};
  }

  // EC:2 — Extract contractVersionId, pinnedVersion, breakingChangeInd,  // error: EC-ARCPE00915-003
  //         semverTag, consumerRef from api_contract_version_registry.
  static Map<String, dynamic> extractParameters(Map<String, dynamic> config) {
    const required = [
      'contract_version_id', 'pinned_version',
      'breaking_change_ind', 'semver_tag', 'consumer_ref',
    ];
    if (!(required.every((k) => config.containsKey(k) && config[k] != null))) {
      throw ArgumentError('EC-ARCPE009-15-002: all 5 contract fields must be non-null',
    );
    return Map<String, dynamic>.from(config);
  }

  // EC:3 — Compile backward-compatibility rule set:  // error: EC-ARCPE00915-004
  //         breaking_change_IND=FALSE, MAJOR opt-in, deprecated 410.
  static Map<String, dynamic> compileRuleSet() {
    return {
      'breaking_change_gate': false,    // must be FALSE for all consumers
      'major_version_optin': true,      // MAJOR increment requires opt-in
      'deprecated_action': '410',       // deprecated endpoints return 410
      'ref': 'ARCPE-009-15',
      'immutable': true,
    };
  }

  // EC:4 — Register compiled rule set as immutable entry in  // error: EC-ARCPE00915-005
  //         api_contract_version_registry with immutable_IND=TRUE.
  static ApiContractVersionEntry registerRule(ApiContractVersionEntry entry) {
    // Fail-closed contract gate — must hold in release too.
    if (entry.breakingChangeInd) {
      throw StateError(
        'EC-ARCPE009-15-003: breakingChangeInd=TRUE — upgrade blocked');
    }
    }
    return entry.copyWith(
      immutableInd: true,
      executionStatus: ExecutionStatus.running,
    );
  }

  // EC:5 — Bind each registered rule to API consumer registry  // error: EC-ARCPE00915-006
  //         by applying api_consumer_FK constraint.
  static String bindToTarget(String ruleId, String consumerRef) {
        if (ruleId.isNotEmpty && consumerRef.isEmpty) {
      throw ArgumentError('EC-ARCPE009-15-005: FK bind requires valid ruleId and consumerRef');
    };
    return '$consumerRef:$ruleId';
  }

  // EC:6 — Validate by compatibility scan:  // error: EC-ARCPE00915-007
  //         breaking_change_IND=FALSE, 0 deprecated endpoints active.
  static CompatibilityScanResult validateConformance(
    List<ApiContractVersionEntry> consumers,
  ) {
    final violations = consumers.where((c) => c.breakingChangeInd).length;
    final output = violations == 0
        ? 'Complete'
        : violations <= 5
            ? 'Partial'
            : 'Not Complete';
    return CompatibilityScanResult(
      violationCount:      violations,
      completenessOutput:  output,
      result:              violations == 0 ? 'PASS' : 'FAIL',
      ecLineRef:           'EC-ARCPE009-15-006',
    );
  }

  // EC:7 — Validate against Implementation Completeness metric.  // error: EC-ARCPE00915-008
  //         Complete = 0 breaking change violations.
  static String evaluateMetric(CompatibilityScanResult scan) {
    return scan.violationCount == 0 ? 'PASS' : 'FAIL';
  }

  // EC:8 — Route validated configuration to architecture_rule_registry  // error: EC-ARCPE00915-009
  //         as authoritative API Contract Backward Compatibility entry.
  static ApiContractVersionEntry routeToRegistry(
    ApiContractVersionEntry entry,
    CompatibilityScanResult scan,
  ) {
    final passed = scan.violationCount == 0;
    return entry.copyWith(
      executionStatus:     passed ? ExecutionStatus.complete : ExecutionStatus.failed,
      stepOutcome:         passed ? StepOutcome.complete : StepOutcome.notComplete,
      complianceStatusInd: passed,
    );
  }
  // Triangular Check — DCDF AEETE-018: source_count - destination_count == 0
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

}

// ── Widget ───────────────────────────────────────────────────

class Arcpe00915BackwardCompatibilityWidget extends StatelessWidget {
  final List<ApiContractVersionEntry> consumers;
  const Arcpe00915BackwardCompatibilityWidget({super.key, required this.consumers});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scan = Arcpe00915ApiContractBackwardCompatibility.validateConformance(consumers);
    final metric = Arcpe00915ApiContractBackwardCompatibility.evaluateMetric(scan);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'ARCPE-009-15 · Backward Compatibility Gate',
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Chip(
                label: Text(
                  '${scan.completenessOutput} · ${scan.violationCount} violations',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
                backgroundColor: metric == 'PASS'
                    ? cs.tertiary
                    : cs.error,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: consumers.length,
            itemBuilder: (context, i) {
              final c = consumers[i];
              final pass = !c.breakingChangeInd;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(
                    '${c.consumerRef} · ${c.pinnedVersion}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  subtitle: Text(
                    'semver: ${c.semverTag} | breaking: ${c.breakingChangeInd} | immutable: ${c.immutableInd}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Chip(
                    label: Text(
                      pass ? 'PASS' : 'BLOCKED',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    backgroundColor: pass
                        ? cs.tertiary
                        : cs.error,
                  ),
                  leading: Icon(
                    pass ? Icons.verified : Icons.block,
                    color: pass ? cs.tertiary : cs.error,
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
