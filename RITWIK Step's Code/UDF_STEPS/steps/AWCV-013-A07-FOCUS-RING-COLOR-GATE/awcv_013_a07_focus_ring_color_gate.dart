// ============================================================
// AWCV-013-A07 | Accessible Widget Color Validation
// Atomic Task: Focus Ring Color Gate —
//   Validate all focus ring color tokens achieve WCAG 2.1 §1.4.11
//   contrast ratio >= 3.0:1 with width >= 2px.
// Primary Table: focus_ring_color_registry
// Thresholds: contrast_ratio >= 3.0 | width >= 2px | md.sys.color.outline
// EC Lines: 8 | Standard: ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo: github.com/RitwikHC/theme-typography · branch: ritwik
// Author: Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date: 29-Aug-2026
// ============================================================

import 'package:flutter/material.dart';

// ── Data Models ──────────────────────────────────────────────

enum ExecutionStatus { pending, running, complete, failed }

enum StepOutcome { complete, partial, notComplete }

/// Maps to focus_ring_color_registry.
/// focus_ring_width_px >= 2 enforced by CHECK constraint at DB level.
class FocusRingColorEntry {
  final String focusRingRuleId;     // PK — UUID
  final String focusRingToken;      // must be md.sys.color.outline
  final double contrastRatio;       // WCAG computed; must be >= 3.0
  final int focusRingWidthPx;       // focus ring width; must be >= 2px
  final String surfaceToken;        // adjacent surface token
  final bool immutableInd;
  final ExecutionStatus executionStatus;
  final StepOutcome stepOutcome;
  final bool complianceStatusInd;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;

  const FocusRingColorEntry({
    required this.focusRingRuleId,
    required this.focusRingToken,
    required this.contrastRatio,
    required this.focusRingWidthPx,
    required this.surfaceToken,
    this.immutableInd = false,
    this.executionStatus = ExecutionStatus.pending,
    this.stepOutcome = StepOutcome.partial,
    this.complianceStatusInd = true,
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
  }) :     if (!(focusRingWidthPx >= 2)) {
      throw ArgumentError('EC-AWCV013A07-003: focusRingWidthPx must be >= 2px');
    };

  static const double kMinContrastRatio = 3.0;
  static const int    kMinWidthPx       = 2;
  static const String kRequiredToken    = 'md.sys.color.outline';

  /// EC:6 gate — ratio >= 3.0, width >= 2px, correct token
  bool get isConformant =>
      contrastRatio >= kMinContrastRatio &&
      focusRingWidthPx >= kMinWidthPx &&
      focusRingToken == kRequiredToken;

  FocusRingColorEntry copyWith({
    bool? immutableInd,
    ExecutionStatus? executionStatus,
    StepOutcome? stepOutcome,
    bool? complianceStatusInd,
  }) {
    return FocusRingColorEntry(
      focusRingRuleId:         focusRingRuleId,
      focusRingToken:          focusRingToken,
      contrastRatio:           contrastRatio,
      focusRingWidthPx:        focusRingWidthPx,
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

/// Scan result — maps to focus_ring_validation_log.
class FocusRingScanResult {
  final int violationCount;
  final String conformanceOutput;
  final String result;
  final String ecLineRef;

  const FocusRingScanResult({
    required this.violationCount,
    required this.conformanceOutput,
    required this.result,
    required this.ecLineRef,
  });
}

// ── EC:1–8 Pipeline ──────────────────────────────────────────

class Awcv013A07FocusRingColorGate {
  static const double _floor   = 0.90;  // metric floor gate
  static const double _optimal = 0.97; // metric optimal target


  // EC:1 — Locate focus ring color gate configuration within
  //         awcv-013-a07-kit source repository.
  static Map<String, dynamic>? locateConfiguration(String repoPath) {
        if (!(repoPath.isNotEmpty)) {
      throw ArgumentError('EC-AWCV013A07-001: repo path must not be empty');
    };
    return {'ref': 'AWCV-013-A07', 'config_file': 'awcv-013-a07.yaml'};
  }

  // EC:2 — Extract focusRingRuleId, focusRingToken, contrastRatio,
  //         focusRingWidthPx, surfaceToken from focus_ring_color_registry.
  static Map<String, dynamic> extractParameters(Map<String, dynamic> config) {
    const required = [
      'focus_ring_rule_id', 'focus_ring_token',
      'contrast_ratio', 'focus_ring_width_px', 'surface_token',
    ];
    if (!(required.every((k) => config.containsKey(k) && config[k] != null))) {
      throw ArgumentError('EC-AWCV013A07-002: all 5 focus ring fields must be non-null',
    );
    return Map<String, dynamic>.from(config);
  }

  // EC:3 — Compile focus ring rule set:
  //         contrast >= 3.0 (WCAG 2.1 §1.4.11), width >= 2px,
  //         token must be md.sys.color.outline.
  static Map<String, dynamic> compileRuleSet() {
    return {
      'min_contrast_ratio': FocusRingColorEntry.kMinContrastRatio,
      'min_width_px':       FocusRingColorEntry.kMinWidthPx,
      'required_token':     FocusRingColorEntry.kRequiredToken,
      'wcag_section':       '2.1 §1.4.11',
      'ref':                'AWCV-013-A07',
      'immutable':          true,
    };
  }

  // EC:4 — Register compiled rule set as immutable entry in
  //         focus_ring_color_registry with immutable_IND=TRUE.
  static FocusRingColorEntry registerRule(FocusRingColorEntry entry) {
        if (!(entry.focusRingToken == FocusRingColorEntry.kRequiredToken)) {
      throw ArgumentError('EC-AWCV013A07-003: focusRingToken must be md.sys.color.outline');
    }
    };
        if (!(entry.contrastRatio >= FocusRingColorEntry.kMinContrastRatio)) {
      throw ArgumentError('EC-AWCV013A07-003: contrastRatio < 3.0');
    };
        if (!(entry.focusRingWidthPx >= FocusRingColorEntry.kMinWidthPx)) {
      throw ArgumentError('EC-AWCV013A07-003: focusRingWidthPx < 2px');
    };
    return entry.copyWith(
      immutableInd: true,
      executionStatus: ExecutionStatus.running,
    );
  }

  // EC:5 — Bind each registered rule to focusable widget handler
  //         by applying focus_ring_handler_FK constraint.
  static String bindToTarget(String ruleId, String focusRingToken) {
        if (!(ruleId.isNotEmpty)) {
      throw ArgumentError('EC-AWCV013A07-005: FK bind requires valid ruleId');
    };
    return '$focusRingToken:$ruleId';
  }

  // EC:6 — Validate: contrast >= 3.0, width >= 2px, token = md.sys.color.outline.
  static FocusRingScanResult validateConformance(
    List<FocusRingColorEntry> entries,
  ) {
    final violations = entries.where((e) => !e.isConformant).length;
    final output = violations == 0
        ? 'Complete'
        : violations <= 5
            ? 'Partial'
            : 'Not Complete';
    return FocusRingScanResult(
      violationCount:   violations,
      conformanceOutput: output,
      result:           violations == 0 ? 'PASS' : 'FAIL',
      ecLineRef:        'EC-AWCV013A07-006',
    );
  }

  // EC:7 — Validate against Design Fidelity metric (Good >= 95%).
  static String evaluateMetric(FocusRingScanResult scan, int total) {
    if (total == 0) return 'FAIL';
    final rate = (total - scan.violationCount) / total;
    return rate >= 0.95 ? 'PASS' : 'FAIL';
  }

  // EC:8 — Route validated focus ring configuration to
  //         focus_ring_rule_registry as authoritative entry.
  static FocusRingColorEntry routeToRegistry(
    FocusRingColorEntry entry,
    FocusRingScanResult scan,
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

class Awcv013A07FocusRingWidget extends StatelessWidget {
  final List<FocusRingColorEntry> focusRules;
  const Awcv013A07FocusRingWidget({super.key, required this.focusRules});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scan   = Awcv013A07FocusRingColorGate.validateConformance(focusRules);
    final metric = Awcv013A07FocusRingColorGate.evaluateMetric(scan, focusRules.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'AWCV-013-A07 · Focus Ring Color Gate (≥ 3.0, ≥ 2px)',
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
            itemCount: focusRules.length,
            itemBuilder: (context, i) {
              final r = focusRules[i];
              final pass = r.isConformant;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(
                    r.focusRingToken,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  subtitle: Text(
                    'contrast: ${r.contrastRatio.toStringAsFixed(2)} / 3.0 | width: ${r.focusRingWidthPx}px / 2px | surface: ${r.surfaceToken}',
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
                    pass ? Icons.radio_button_checked : Icons.radio_button_unchecked,
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
