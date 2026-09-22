// ============================================================
// AWCV-013-A10 | Accessible Widget Color Validation
// Atomic Task: Error State Color Gate —
//   Validate all error state color tokens map to md.sys.color.error
//   with contrast ratio >= 4.5:1 against adjacent surface.
// Primary Table: error_state_color_registry
// Threshold: error_color_token = md.sys.color.error | contrast >= 4.5
// EC Lines: 8 | Standard: ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo: github.com/RitwikHC/theme-typography · branch: ritwik
// Author: Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date: 29-Aug-2026
// ============================================================

import 'package:flutter/material.dart';

// ── Data Models ──────────────────────────────────────────────

enum ExecutionStatus { pending, running, complete, failed }

enum StepOutcome { complete, partial, notComplete }

/// Maps to error_state_color_registry.
/// error_color_token must equal 'md.sys.color.error' — CHECK at DB.
class ErrorStateColorEntry {
  final String errorColorRuleId;      // PK — UUID
  final String errorColorToken;       // must be md.sys.color.error
  final double contrastRatio;         // WCAG contrast; must be >= 4.5
  final String errorContainerToken;   // must be md.sys.color.errorContainer
  final String surfaceToken;          // adjacent surface token
  final bool immutableInd;
  final ExecutionStatus executionStatus;
  final StepOutcome stepOutcome;
  final bool complianceStatusInd;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;

  const ErrorStateColorEntry({
    required this.errorColorRuleId,
    required this.errorColorToken,
    required this.contrastRatio,
    required this.errorContainerToken,
    required this.surfaceToken,
    this.immutableInd = false,
    this.executionStatus = ExecutionStatus.pending,
    this.stepOutcome = StepOutcome.partial,
    this.complianceStatusInd = true,
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
  });

  static const double kMinContrastRatio      = 4.5;
  static const String kRequiredErrorToken    = 'md.sys.color.error';
  static const String kRequiredContainerToken = 'md.sys.color.errorContainer';

  /// EC:6 gate — correct token, correct container, contrast >= 4.5
  bool get isConformant =>
      errorColorToken == kRequiredErrorToken &&
      errorContainerToken == kRequiredContainerToken &&
      contrastRatio >= kMinContrastRatio;

  ErrorStateColorEntry copyWith({
    bool? immutableInd,
    ExecutionStatus? executionStatus,
    StepOutcome? stepOutcome,
    bool? complianceStatusInd,
  }) {
    return ErrorStateColorEntry(
      errorColorRuleId:        errorColorRuleId,
      errorColorToken:         errorColorToken,
      contrastRatio:           contrastRatio,
      errorContainerToken:     errorContainerToken,
      surfaceToken:            surfaceToken,
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

/// Scan result — maps to error_color_validation_log.
class ErrorColorScanResult {
  final int violationCount;
  final String conformanceOutput;
  final String result;
  final String ecLineRef;

  const ErrorColorScanResult({
    required this.violationCount,
    required this.conformanceOutput,
    required this.result,
    required this.ecLineRef,
  });
}

// ── EC:1–8 Pipeline ──────────────────────────────────────────

class Awcv013A10ErrorStateColorGate {
  static const double _floor   = 0.90;  // metric floor gate
  static const double _optimal = 0.97; // metric optimal target


  // EC:1 — Locate error state color gate configuration within
  //         awcv-013-a10-kit source repository.
  static Map<String, dynamic>? locateConfiguration(String repoPath) {
        if (!(repoPath.isNotEmpty)) {
      throw ArgumentError('EC-AWCV013A10-001: repo path must not be empty');
    };
    return {'ref': 'AWCV-013-A10', 'config_file': 'awcv-013-a10.yaml'};
  }

  // EC:2 — Extract errorColorRuleId, errorColorToken, contrastRatio,
  //         errorContainerToken, surfaceToken from registry.
  static Map<String, dynamic> extractParameters(Map<String, dynamic> config) {
    const required = [
      'error_color_rule_id', 'error_color_token',
      'contrast_ratio', 'error_container_token', 'surface_token',
    ];
    if (!(required.every((k) => config.containsKey(k) && config[k] != null))) {
      throw ArgumentError('EC-AWCV013A10-002: all 5 error state fields must be non-null',
    );
    return Map<String, dynamic>.from(config);
  }

  // EC:3 — Compile error state rule set:
  //         token=md.sys.color.error, contrast >= 4.5,
  //         errorContainer=md.sys.color.errorContainer.
  static Map<String, dynamic> compileRuleSet() {
    return {
      'required_error_token':     ErrorStateColorEntry.kRequiredErrorToken,
      'required_container_token': ErrorStateColorEntry.kRequiredContainerToken,
      'min_contrast_ratio':       ErrorStateColorEntry.kMinContrastRatio,
      'ref':                      'AWCV-013-A10',
      'immutable':                true,
    };
  }

  // EC:4 — Register compiled rule set as immutable entry in
  //         error_state_color_registry with immutable_IND=TRUE.
  static ErrorStateColorEntry registerRule(ErrorStateColorEntry entry) {
        if (!(entry.errorColorToken == ErrorStateColorEntry.kRequiredErrorToken)) {
      throw ArgumentError('EC-AWCV013A10-003: errorColorToken must be md.sys.color.error');
    }
    };
        if (!(entry.contrastRatio >= ErrorStateColorEntry.kMinContrastRatio)) {
      throw ArgumentError('EC-AWCV013A10-003: contrastRatio < 4.5');
    };
        if (!(entry.errorContainerToken == ErrorStateColorEntry.kRequiredContainerToken)) {
      throw ArgumentError('EC-AWCV013A10-003: errorContainerToken must be md.sys.color.errorContainer');
    };
    return entry.copyWith(
      immutableInd: true,
      executionStatus: ExecutionStatus.running,
    );
  }

  // EC:5 — Bind each registered rule to error state handler
  //         by applying error_handler_FK constraint.
  static String bindToTarget(String ruleId, String errorColorToken) {
        if (!(ruleId.isNotEmpty)) {
      throw ArgumentError('EC-AWCV013A10-005: FK bind requires valid ruleId');
    };
    return '$errorColorToken:$ruleId';
  }

  // EC:6 — Validate: token=md.sys.color.error, contrast >= 4.5,
  //         errorContainer declared for all error states.
  static ErrorColorScanResult validateConformance(
    List<ErrorStateColorEntry> entries,
  ) {
    final violations = entries.where((e) => !e.isConformant).length;
    final output = violations == 0
        ? 'Complete'
        : violations <= 5
            ? 'Partial'
            : 'Not Complete';
    return ErrorColorScanResult(
      violationCount:   violations,
      conformanceOutput: output,
      result:           violations == 0 ? 'PASS' : 'FAIL',
      ecLineRef:        'EC-AWCV013A10-006',
    );
  }

  // EC:7 — Validate against Design Fidelity metric (Good >= 95%).
  static String evaluateMetric(ErrorColorScanResult scan, int total) {
    if (total == 0) return 'FAIL';
    final rate = (total - scan.violationCount) / total;
    return rate >= 0.95 ? 'PASS' : 'FAIL';
  }

  // EC:8 — Route validated error state configuration to
  //         error_state_rule_registry as authoritative entry.
  static ErrorStateColorEntry routeToRegistry(
    ErrorStateColorEntry entry,
    ErrorColorScanResult scan,
  ) {
    final passed = scan.violationCount == 0;
    return entry.copyWith(
      executionStatus:     passed ? ExecutionStatus.complete : ExecutionStatus.failed,
      stepOutcome:         passed ? StepOutcome.complete : StepOutcome.notComplete,
      complianceStatusInd: passed,
    );
  }
  // Triangular Check: source_count - destination_count == 0 (DCDF AEETE-018)
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

}

// ── Widget ───────────────────────────────────────────────────

class Awcv013A10ErrorStateWidget extends StatelessWidget {
  final List<ErrorStateColorEntry> errorRules;
  const Awcv013A10ErrorStateWidget({super.key, required this.errorRules});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scan   = Awcv013A10ErrorStateColorGate.validateConformance(errorRules);
    final metric = Awcv013A10ErrorStateColorGate.evaluateMetric(scan, errorRules.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'AWCV-013-A10 · Error State Color Gate (≥ 4.5)',
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
                    ? cs.tertiary
                    : cs.error,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: errorRules.length,
            itemBuilder: (context, i) {
              final r = errorRules[i];
              final pass = r.isConformant;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(
                    r.errorColorToken,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  subtitle: Text(
                    'contrast: ${r.contrastRatio.toStringAsFixed(2)} / 4.5 | container: ${r.errorContainerToken} | surface: ${r.surfaceToken}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Chip(
                    label: Text(
                      pass ? 'PASS' : 'FAIL',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    backgroundColor: pass
                        ? cs.tertiary
                        : cs.error,
                  ),
                  leading: Icon(
                    pass ? Icons.error_outline : Icons.error,
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
