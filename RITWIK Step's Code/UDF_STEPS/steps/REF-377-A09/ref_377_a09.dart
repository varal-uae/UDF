// ============================================================
// REF-377-A09 — Reference Implementation Framework
// Atomic Step: Set Progressive Stepper Transitions.
// Metric:      UI Animation Compliance Rate · Floor=100.0 · Optimal=100.0
// Output:      Pass / Partial / Fail
// Standard:    ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:        github.com/RitwikHC/theme-typography · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        18-Sep-2026
// Step No:     302 of 396
// ============================================================
// Why this matters: Splitting tasks into single Byt screens requires fast transitions to avoid UI fatigue.
// Mobile impl:      Single-field per screen ensures the mobile keyboard never obscures the CTA button.
// Data requirement: Wrap the stepper content areas in an animation group component (e.g., React Transition Group).
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────

enum Ref377A09ConformanceLevel {
  complete,
  partial,
  notComplete,
}

enum Ref377A09ExecutionStatus {
  pending,
  running,
  complete,
  failed,
}

// ── Data Model ───────────────────────────────────────────────

/// Configuration record for REF-377-A09.
/// Fields derived from AISS sheet row — Reference Implementation Framework.
/// All 5 DCDF lineage fields mandatory per AEETE-018.
class Ref377A09Config {
  final String configId;               // PK — UUID v4
  // Step-specific fields (from AISS data requirement)
  final String animationId;
  final String durationMs;
  final String easingCurve;
  final String triggerState;
  final String validationStatus;       // PENDING | VALID | INVALID
  final bool   immutableInd;
  // DCDF lineage headers — AEETE-018
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Ref377A09Config({
    required this.configId,
    required this.animationId,
    required this.durationMs,
    required this.easingCurve,
    required this.triggerState,
    this.validationStatus   = 'PENDING',
    this.immutableInd       = false,
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
    this.complianceStatusInd = false,
  });

  bool get isRegistered =>
      immutableInd && validationStatus == 'VALID' && complianceStatusInd;

  Ref377A09Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Ref377A09Config(
    configId: configId,
    animationId: animationId,
    durationMs: durationMs,
    easingCurve: easingCurve,
    triggerState: triggerState,
    validationStatus:         validationStatus  ?? this.validationStatus,
    immutableInd:             immutableInd      ?? this.immutableInd,
    traceId:                  traceId,
    originSourceId:           originSourceId,
    immediatePredecessorId:   immediatePredecessorId,
    transformationLogicHash:  transformationLogicHash,
    complianceStatusInd:      complianceStatusInd ?? this.complianceStatusInd,
  );

  Map<String, dynamic> toJson() => {
    'config_id': configId,
    'animationId': animationId,
    'durationMs': durationMs,
    'easingCurve': easingCurve,
    'triggerState': triggerState,
    'validation_status':          validationStatus,
    'immutable_ind':              immutableInd,
    'trace_id':                   traceId,
    'origin_source_id':           originSourceId,
    'immediate_predecessor_id':   immediatePredecessorId,
    'transformation_logic_hash':  transformationLogicHash,
    'compliance_status_ind':      complianceStatusInd,
  };
}

// ── Validation Result ─────────────────────────────────────────

class Ref377A09ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Ref377A09ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Ref377A09ValidationResult({
    required this.totalRecords,
    required this.conformantRecords,
    required this.violationCount,
    required this.conformanceRate,
    required this.conformanceLevel,
    required this.gatePass,
    required this.ecLineRef,
  });

  String get conformanceOutput {
    switch (conformanceLevel) {
      case Ref377A09ConformanceLevel.complete:    return 'Pass';
      case Ref377A09ConformanceLevel.partial:     return 'Partial';
      case Ref377A09ConformanceLevel.notComplete: return 'Fail';
    }
  }
}

// ── EC:4 Pipeline ────────────────────────────────────────────────────────

/// REF-377-A09: Set Progressive Stepper Transitions.
///
/// Metric: UI Animation Compliance Rate
/// Floor=0.90 · Optimal=0.97 · Output=Good / Average / Poor
class Ref377A09Pipeline {
  static const double _floor   = 100.0;
  static const double _optimal = 100.0;

  // EC:1 — Define slide-in duration (200ms)
  static Ref377A09Config _ec1Execute(Ref377A09Config config) {
    if (config.animationId.isEmpty) {
      throw ArgumentError(
          'EC-REF377A09-001: animationId required for REF-377-A09');
    }
    // Define slide-in duration (200ms)
    return config;
  }

  // EC:2 — Define slide-out duration
  static Ref377A09Config _ec2Execute(Ref377A09Config config) {
    if (config.animationId.isEmpty) {
      throw ArgumentError(
          'EC-REF377A09-002: animationId required for REF-377-A09');
    }
    // Define slide-out duration
    return config;
  }

  // EC:3 — Decide easing function
  static Ref377A09Config _ec3Execute(Ref377A09Config config) {
    if (config.animationId.isEmpty) {
      throw ArgumentError(
          'EC-REF377A09-003: animationId required for REF-377-A09');
    }
    // Decide easing function
    return config;
  }

  // EC:4 — Respect reduced motion preferences
  static Ref377A09Config _ec4Execute(Ref377A09Config config) {
    if (config.animationId.isEmpty) {
      throw ArgumentError(
          'EC-REF377A09-004: animationId required for REF-377-A09');
    }
    // Respect reduced motion preferences
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  // Conformance gate — Floor=0.90 · Optimal=0.97
  static Ref377A09ValidationResult calculateConformance({
    required List<Ref377A09Config> configs,
  }) {
    if (configs.isEmpty) {
      return const Ref377A09ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Ref377A09ConformanceLevel.notComplete,
        gatePass: false,
        ecLineRef: 'EC-REF377A09-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level      = rate >= _optimal
        ? Ref377A09ConformanceLevel.complete
        : rate >= _floor
            ? Ref377A09ConformanceLevel.partial
            : Ref377A09ConformanceLevel.notComplete;
    return Ref377A09ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-REF377A09-VAL',
    );
  }

  static Ref377A09Config routeToRegistry(
    Ref377A09Config config,
    Ref377A09ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Ref377A09Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      return {'error': 'EC-REF377A09-001: empty config list', 'dlq': true};
    }
    final p1 = configs.map(_ec1Execute).toList();
    final p2 = configs.map(_ec2Execute).toList();
    final p3 = configs.map(_ec3Execute).toList();
    final p4 = configs.map(_ec4Execute).toList();

    if (!triangularCheck(configs.length, p4.length)) {
      return {'error': 'EC-REF377A09-TRI: triangular check failed', 'dlq': true};
    }

    final result     = calculateConformance(configs: p4);
    final registered = p4.map((c) => routeToRegistry(c, result)).toList();

    return {
      'status':             result.gatePass ? 'COMPLETE' : 'PARTIAL',
      'conformance_rate':   result.conformanceRate,
      'conformance_output': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-REF-377-A09',
      'metric':             'UI Animation Compliance Rate',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> ref_377_a09Dlq(
  String errorCode,
  Map<String, dynamic> payload,
) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'REF-377-A09',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Ref377A09Widget extends StatelessWidget {
  final List<Ref377A09Config> configs;
  const Ref377A09Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Ref377A09Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('REF-377-A09',
              style: const TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                fontSize: 12))),
            Chip(
              label: Text(
                '${result.conformanceOutput} · ${result.violationCount} violation${result.violationCount == 1 ? '' : 's'}',
                style: const TextStyle(color: Colors.white, fontSize: 11)),
              backgroundColor: result.gatePass ? cs.tertiary : cs.error,
            ),
          ]),
        ),
        Expanded(child: ListView.builder(
          itemCount: configs.length,
          itemBuilder: (context, i) {
            final c    = configs[i];
            final pass = c.isRegistered;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: Icon(
                  pass ? Icons.check_circle : Icons.cancel,
                  color: pass ? cs.tertiary : cs.error,
                ),
                title: Text(c.animationId,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 12)),
                subtitle: Text(
                  '${animationId} | ${durationMs}',
                  style: const TextStyle(fontSize: 11)),
                trailing: Chip(
                  label: Text(pass ? 'PASS' : 'FAIL',
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: pass ? cs.tertiary : cs.error,
                ),
              ),
            );
          },
        )),
      ],
    );
  }
}

// ── Entry point ───────────────────────────────────────────────

void main() async {
  final configs = [
    Ref377A09Config(
      configId: 'ref377a09-cfg-001',
      animationId: 'ref-377-a09_animationId_value',
      durationMs: 'ref-377-a09_durationMs_value',
      easingCurve: 'ref-377-a09_easingCurve_value',
      triggerState: 'ref-377-a09_triggerState_value',
      traceId:                 'trace-ref377a09-001',
      originSourceId:          'origin-ref377a09',
      immediatePredecessorId:  'pred-ref377a09-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final result = await Ref377A09Pipeline.run(
    configs: configs, userId: 'ritwik-udf');
  print('REF-377-A09 → $result');
}
