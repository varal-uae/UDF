// ============================================================
// ARCPE-016-06 | Architecture Pattern Enforcement
// Atomic Task: Component Event Propagation Gate —
//   Validate that all frontend component event emissions respect
//   declared propagation boundaries preventing uncontrolled bubbling.
// Primary Table: event_propagation_registry
// EC Lines: 8 | Standard: ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo: github.com/RitwikHC/theme-typography · branch: ritwik
// Author: Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date: 29-Aug-2026
// ============================================================

import 'package:flutter/material.dart';

// ── Data Models ──────────────────────────────────────────────

enum ExecutionStatus { pending, running, complete, failed }

enum StepOutcome { complete, partial, notComplete }

/// Maps to event_propagation_registry.
/// bubble_depth_limit <= 3 enforced via CHECK constraint at DB level.
class EventPropagationEntry {
  final String propagationRuleId;     // PK — UUID
  final String componentRef;          // emitting component identifier
  final String eventType;             // onClick / onSubmit / onScroll
  final bool propagationBoundaryInd;  // TRUE = boundary declared; FALSE = blocked
  final int bubbleDepthLimit;         // max hops; must be <= 3
  final bool immutableInd;            // TRUE after registration
  final ExecutionStatus executionStatus;
  final StepOutcome stepOutcome;
  final bool complianceStatusInd;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;

  const EventPropagationEntry({
    required this.propagationRuleId,
    required this.componentRef,
    required this.eventType,
    required this.propagationBoundaryInd,
    required this.bubbleDepthLimit,
    this.immutableInd = false,
    this.executionStatus = ExecutionStatus.pending,
    this.stepOutcome = StepOutcome.partial,
    this.complianceStatusInd = true,
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
  }) : assert(bubbleDepthLimit <= 3,
         'EC-ARCPE016-06-003: bubble_depth_limit must be <= 3');

  /// EC:6 gate — boundary declared AND depth within limit
  bool get isConformant => propagationBoundaryInd && bubbleDepthLimit <= 3;

  EventPropagationEntry copyWith({
    bool? immutableInd,
    ExecutionStatus? executionStatus,
    StepOutcome? stepOutcome,
    bool? complianceStatusInd,
  }) {
    return EventPropagationEntry(
      propagationRuleId:       propagationRuleId,
      componentRef:            componentRef,
      eventType:               eventType,
      propagationBoundaryInd:  propagationBoundaryInd,
      bubbleDepthLimit:        bubbleDepthLimit,
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

/// Propagation scan result — maps to propagation_validation_log.
class PropagationScanResult {
  final int violationCount;
  final String conformanceOutput; // Complete / Partial / Not Complete
  final String result;            // PASS / FAIL
  final String ecLineRef;

  const PropagationScanResult({
    required this.violationCount,
    required this.conformanceOutput,
    required this.result,
    required this.ecLineRef,
  });
}

// ── EC:1–8 Pipeline ──────────────────────────────────────────

class Arcpe01606ComponentEventPropagationGate {

  // EC:1 — Locate component event propagation configuration within
  //         arcpe-016-06-kit source repository.
  static Map<String, dynamic>? locateConfiguration(String repoPath) {
    assert(repoPath.isNotEmpty, 'EC-ARCPE016-06-001: repo path must not be empty');
    return {'ref': 'ARCPE-016-06', 'config_file': 'event_propagation.yaml'};
  }

  // EC:2 — Extract propagationRuleId, componentRef, eventType,
  //         propagationBoundaryInd, bubbleDepthLimit from registry.
  static Map<String, dynamic> extractParameters(Map<String, dynamic> config) {
    const required = [
      'propagation_rule_id', 'component_ref',
      'event_type', 'propagation_boundary_ind', 'bubble_depth_limit',
    ];
    assert(
      required.every((k) => config.containsKey(k) && config[k] != null),
      'EC-ARCPE016-06-002: all 5 propagation fields must be non-null',
    );
    return Map<String, dynamic>.from(config);
  }

  // EC:3 — Compile event propagation rule set:
  //         boundary=TRUE, depth<=3, stopPropagation at boundary.
  static Map<String, dynamic> compileRuleSet() {
    return {
      'require_boundary':    true,
      'max_bubble_depth':    3,
      'stop_propagation':    true,
      'ref':                 'ARCPE-016-06',
      'immutable':           true,
    };
  }

  // EC:4 — Register compiled propagation rule set as immutable entry
  //         in event_propagation_registry with immutable_IND=TRUE.
  static EventPropagationEntry registerRule(EventPropagationEntry entry) {
    assert(entry.propagationBoundaryInd,
      'EC-ARCPE016-06-003: propagationBoundaryInd=FALSE — uncontrolled bubbling blocked');
    assert(entry.bubbleDepthLimit <= 3,
      'EC-ARCPE016-06-003: bubbleDepthLimit > 3');
    return entry.copyWith(
      immutableInd: true,
      executionStatus: ExecutionStatus.running,
    );
  }

  // EC:5 — Bind each registered rule to component emitter
  //         by applying component_emitter_FK constraint.
  static String bindToTarget(String ruleId, String componentRef) {
    assert(ruleId.isNotEmpty && componentRef.isNotEmpty,
      'EC-ARCPE016-06-005: FK bind requires valid ruleId and componentRef');
    return '$componentRef:$ruleId';
  }

  // EC:6 — Validate by propagation scan:
  //         propagationBoundaryInd=TRUE, depth<=3 for all emitters.
  static PropagationScanResult validateConformance(
    List<EventPropagationEntry> emitters,
  ) {
    final violations = emitters.where((e) => !e.isConformant).length;
    final output = violations == 0
        ? 'Complete'
        : violations <= 5
            ? 'Partial'
            : 'Not Complete';
    return PropagationScanResult(
      violationCount:   violations,
      conformanceOutput: output,
      result:           violations == 0 ? 'PASS' : 'FAIL',
      ecLineRef:        'EC-ARCPE016-06-006',
    );
  }

  // EC:7 — Validate against Implementation Completeness metric.
  //         Complete = 0 propagation violations.
  static String evaluateMetric(PropagationScanResult scan) {
    return scan.violationCount == 0 ? 'PASS' : 'FAIL';
  }

  // EC:8 — Route validated configuration to architecture_rule_registry
  //         as authoritative Event Propagation Registry entry.
  static EventPropagationEntry routeToRegistry(
    EventPropagationEntry entry,
    PropagationScanResult scan,
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

class Arcpe01606EventPropagationWidget extends StatelessWidget {
  final List<EventPropagationEntry> emitters;
  const Arcpe01606EventPropagationWidget({super.key, required this.emitters});

  @override
  Widget build(BuildContext context) {
    final scan = Arcpe01606ComponentEventPropagationGate.validateConformance(emitters);
    final metric = Arcpe01606ComponentEventPropagationGate.evaluateMetric(scan);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'ARCPE-016-06 · Event Propagation Gate',
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
            itemCount: emitters.length,
            itemBuilder: (context, i) {
              final e = emitters[i];
              final pass = e.isConformant;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(
                    '${e.componentRef} · ${e.eventType}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  subtitle: Text(
                    'boundary: ${e.propagationBoundaryInd} | depth: ${e.bubbleDepthLimit}/3 | immutable: ${e.immutableInd}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Chip(
                    label: Text(
                      pass ? 'PASS' : 'VIOLATION',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    backgroundColor: pass
                        ? const Color(0xFF137333)
                        : const Color(0xFFD93025),
                  ),
                  leading: Icon(
                    pass ? Icons.hub : Icons.warning,
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
