// ============================================================
// IS21-RIMV-015-AS01-A05 — Implementation System 21
// Atomic Step: Implement Strict Input Masking (Poka-Yoke). Overlay 15-Minute Execution Timer (Self-Chasing).
// Metric:      Input Validation Coverage Rate · Floor=0.95 · Optimal=1.0
// Output:      Pass / Partial / Fail
// Standard:    ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:        github.com/RitwikHC/theme-typography · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        18-Sep-2026
// Step No:     247 of 396
// ============================================================
// Why this matters: Blocks invalid characters from entering the application context, completely removing downstream data
// Mobile impl:      Automatically triggers specific numeric or alphanumeric keyboards on mobile viewports to prevent use
// Data requirement: Set native soft keyboard triggers (numeric, email, telephone) based on input field constraints.
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────

enum Is21Rimv015As01A05ConformanceLevel {
  complete,
  partial,
  notComplete,
}

enum Is21Rimv015As01A05ExecutionStatus {
  pending,
  running,
  complete,
  failed,
}

// ── Data Model ───────────────────────────────────────────────

/// Configuration record for IS21-RIMV-015-AS01-A05.
/// Fields derived from AISS sheet row — Implementation System 21.
/// All 5 DCDF lineage fields mandatory per AEETE-018.
class Is21Rimv015As01A05Config {
  final String configId;               // PK — UUID v4
  // Step-specific fields (from AISS data requirement)
  final String fieldId;
  final String validationRule;
  final String errorMessage;
  final String inputType;
  final String validationStatus;       // PENDING | VALID | INVALID
  final bool   immutableInd;
  // DCDF lineage headers — AEETE-018
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Is21Rimv015As01A05Config({
    required this.configId,
    required this.fieldId,
    required this.validationRule,
    required this.errorMessage,
    required this.inputType,
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

  Is21Rimv015As01A05Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Is21Rimv015As01A05Config(
    configId: configId,
    fieldId: fieldId,
    validationRule: validationRule,
    errorMessage: errorMessage,
    inputType: inputType,
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
    'fieldId': fieldId,
    'validationRule': validationRule,
    'errorMessage': errorMessage,
    'inputType': inputType,
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

class Is21Rimv015As01A05ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Is21Rimv015As01A05ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Is21Rimv015As01A05ValidationResult({
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
      case Is21Rimv015As01A05ConformanceLevel.complete:    return 'Pass';
      case Is21Rimv015As01A05ConformanceLevel.partial:     return 'Partial';
      case Is21Rimv015As01A05ConformanceLevel.notComplete: return 'Fail';
    }
  }
}

// ── EC:4 Pipeline ────────────────────────────────────────────────────────

/// IS21-RIMV-015-AS01-A05: Implement Strict Input Masking (Poka-Yoke). Overlay 15-Minute Execution Timer (S
///
/// Metric: Input Validation Coverage Rate
/// Floor=0.95 · Optimal=1.0 · Output=Pass / Fail
class Is21Rimv015As01A05Pipeline {
  static const double _floor   = 0.95;
  static const double _optimal = 1.0;

  // EC:1 — Map schemas to inputs
  static Is21Rimv015As01A05Config _ec1Execute(Is21Rimv015As01A05Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-IS21RIMV015A-001: fieldId required for IS21-RIMV-015-AS01-A05');
    }
    // Map schemas to inputs
    return config;
  }

  // EC:2 — Implement regex/type masking
  static Is21Rimv015As01A05Config _ec2Execute(Is21Rimv015As01A05Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-IS21RIMV015A-002: fieldId required for IS21-RIMV-015-AS01-A05');
    }
    // Implement regex/type masking
    return config;
  }

  // EC:3 — Disable invalid submission
  static Is21Rimv015As01A05Config _ec3Execute(Is21Rimv015As01A05Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-IS21RIMV015A-003: fieldId required for IS21-RIMV-015-AS01-A05');
    }
    // Disable invalid submission
    return config;
  }

  // EC:4 — Match keyboard type
  static Is21Rimv015As01A05Config _ec4Execute(Is21Rimv015As01A05Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-IS21RIMV015A-004: fieldId required for IS21-RIMV-015-AS01-A05');
    }
    // Match keyboard type
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  // Conformance gate — Floor=0.95 · Optimal=1.0
  static Is21Rimv015As01A05ValidationResult calculateConformance({
    required List<Is21Rimv015As01A05Config> configs,
  }) {
    if (configs.isEmpty) {
      return const Is21Rimv015As01A05ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Is21Rimv015As01A05ConformanceLevel.notComplete,
        gatePass: false,
        ecLineRef: 'EC-IS21RIMV015A-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level      = rate >= _optimal
        ? Is21Rimv015As01A05ConformanceLevel.complete
        : rate >= _floor
            ? Is21Rimv015As01A05ConformanceLevel.partial
            : Is21Rimv015As01A05ConformanceLevel.notComplete;
    return Is21Rimv015As01A05ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-IS21RIMV015A-VAL',
    );
  }

  static Is21Rimv015As01A05Config routeToRegistry(
    Is21Rimv015As01A05Config config,
    Is21Rimv015As01A05ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Is21Rimv015As01A05Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      return {'error': 'EC-IS21RIMV015A-001: empty config list', 'dlq': true};
    }
    final p1 = configs.map(_ec1Execute).toList();
    final p2 = configs.map(_ec2Execute).toList();
    final p3 = configs.map(_ec3Execute).toList();
    final p4 = configs.map(_ec4Execute).toList();

    if (!triangularCheck(configs.length, p4.length)) {
      return {'error': 'EC-IS21RIMV015A-TRI: triangular check failed', 'dlq': true};
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
      'ec_ref':             'EC-IS21-RIMV-015-AS01-A05',
      'metric':             'Input Validation Coverage Rate',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> is21_rimv_015_as01_a05Dlq(
  String errorCode,
  Map<String, dynamic> payload,
) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'IS21-RIMV-015-AS01-A05',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Is21Rimv015As01A05Widget extends StatelessWidget {
  final List<Is21Rimv015As01A05Config> configs;
  const Is21Rimv015As01A05Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Is21Rimv015As01A05Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('IS21-RIMV-015-AS01-A05',
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
                title: Text(c.fieldId,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 12)),
                subtitle: Text(
                  '${fieldId} | ${validationRule}',
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
    Is21Rimv015As01A05Config(
      configId: 'is21rimv015a-cfg-001',
      fieldId: 'is21-rimv-015-as01-a05_fieldId_value',
      validationRule: 'is21-rimv-015-as01-a05_validationRule_value',
      errorMessage: 'is21-rimv-015-as01-a05_errorMessage_value',
      inputType: 'is21-rimv-015-as01-a05_inputType_value',
      traceId:                 'trace-is21rimv015a-001',
      originSourceId:          'origin-is21rimv015a',
      immediatePredecessorId:  'pred-is21rimv015a-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final result = await Is21Rimv015As01A05Pipeline.run(
    configs: configs, userId: 'ritwik-udf');
  print('IS21-RIMV-015-AS01-A05 → $result');
}
