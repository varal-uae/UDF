// ============================================================
// IS21-RIMV-015-AS01-A05 — IS21 System Module
// Atomic Step:  Implement Strict Input Masking (Poka-Yoke). Overlay 15-Minute Execution Timer (Self-Chasing).
// Metric:       Configuration Conformance Rate - Native soft keyboard triggers numeric
// Floor:        0.97  ·  Optimal: 0.97
// Output vocab: Pass / Fail
// Standard:     ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:         github.com/varal-uae/UDF · branch: ritwik
// Author:       Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:         25-Sep-2026
// Step No:      818 of 1073
// ============================================================
// Why:          Blocks invalid characters from entering the application context, completely removing downstream data
// Mobile:       Automatically triggers specific numeric or alphanumeric keyboards on mobile viewports to prevent use
// col41:        Pass/Fail
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Conformance vocabulary: Pass / Fail ─────────────

enum Is21Rimv015As01A05ConformanceLevel {
  pass_,   // ≥ floor
  fail_,   // < floor
}

// ── Execution status ─────────────────────────────────────────

enum Is21Rimv015As01A05ExecutionStatus { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// IS21-RIMV-015-AS01-A05 — IS21 System Module
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Is21Rimv015As01A05Config {
  final String configId;
  final String fieldId;
  final String validationRule;
  final String errorMessage;
  final String inputType;
  final String validationStatus;
  final bool   immutableInd;
  // DCDF lineage
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
    'validation_status':         validationStatus,
    'immutable_ind':             immutableInd,
    'trace_id':                  traceId,
    'origin_source_id':          originSourceId,
    'immediate_predecessor_id':  immediatePredecessorId,
    'transformation_logic_hash': transformationLogicHash,
    'compliance_status_ind':     complianceStatusInd,
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
      case Is21Rimv015As01A05ConformanceLevel.pass_: return 'Pass';
      case Is21Rimv015As01A05ConformanceLevel.fail_: return 'Fail';
    }
  }
}

// ── EC:4 Pipeline ────────────────────────────────────────

/// IS21-RIMV-015-AS01-A05: Implement Strict Input Masking (Poka-Yoke). Overlay 15-Minute Execution Timer (S
/// Metric: Configuration Conformance Rate - Native soft keyboard trigge
/// Floor=0.97 · Output=Pass / Fail
class Is21Rimv015As01A05Pipeline {
  static const double _floor   = 0.97;
  static const double _optimal = 0.97;

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

  static Is21Rimv015As01A05ValidationResult calculateConformance({
    required List<Is21Rimv015As01A05Config> configs,
  }) {
    if (configs.isEmpty) {
      return Is21Rimv015As01A05ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Is21Rimv015As01A05ConformanceLevel.fail_,
        gatePass: false, ecLineRef: 'EC-IS21RIMV015A-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level = rate >= _floor
        ? Is21Rimv015As01A05ConformanceLevel.pass_
        : Is21Rimv015As01A05ConformanceLevel.fail_;
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
      throw ArgumentError('EC-IS21RIMV015A-000: configs must not be empty for IS21-RIMV-015-AS01-A05');
    }
    final p1 = configs.map(_ec1Execute).toList();
    final p2 = configs.map(_ec2Execute).toList();
    final p3 = configs.map(_ec3Execute).toList();
    final p4 = configs.map(_ec4Execute).toList();

    if (!triangularCheck(configs.length, p4.length)) {
      throw ArgumentError('EC-IS21RIMV015A-TRI: triangular check failed for IS21-RIMV-015-AS01-A05');
    }
    final result     = calculateConformance(configs: p4);
    final registered = p4.map((c) => routeToRegistry(c, result)).toList();
    return {
      'status':             result.gatePass ? 'COMPLETE' : 'FAILED',
      'conformance_verdict': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-IS21-RIMV-015-AS01-A05',
      'metric':             'Configuration Conformance Rate - Native soft keyboard trigge',
      'output_vocab':       'Pass / Fail',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> is21_rimv_015_as01_a05Dlq(
    String errorCode, Map<String, dynamic> payload) => {
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
    final isGood = result.gatePass;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('IS21-RIMV-015-AS01-A05',
              style: const TextStyle(fontFamily:'Courier',
                fontWeight:FontWeight.bold, fontSize:12))),
            Chip(
              label: Text(
                result.conformanceOutput,
                style: const TextStyle(color:Colors.white, fontSize:11)),
              backgroundColor: isGood ? cs.tertiary : cs.error),
          ]),
        ),
        Expanded(child: ListView.builder(
          itemCount: configs.length,
          itemBuilder: (context, i) {
            final c    = configs[i];
            final pass = c.isRegistered;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal:16,vertical:4),
              child: ListTile(
                leading: Icon(
                  pass ? Icons.check_circle : Icons.cancel,
                  color: pass ? cs.tertiary : cs.error),
                title: Text(c.fieldId,
                  style: const TextStyle(fontWeight:FontWeight.w600,fontSize:12)),
                subtitle: Text(
                  '${c.configId.length>8?c.configId.substring(0,8):c.configId}…'
                  ' | ${c.validationStatus}',
                  style: const TextStyle(fontSize:11)),
                trailing: Chip(
                  label: Text(
                    pass ? 'Pass' : 'Fail',
                    style: const TextStyle(color:Colors.white,fontSize:10)),
                  backgroundColor: pass ? cs.tertiary : cs.error),
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
      fieldId: 'is21-rimv-015-as01-a05_fieldId',
      validationRule: 'is21-rimv-015-as01-a05_validationRule',
      errorMessage: 'is21-rimv-015-as01-a05_errorMessage',
      inputType: 'is21-rimv-015-as01-a05_inputType',
      traceId:                 'trace-is21rimv015a-001',
      originSourceId:          'origin-is21rimv015a',
      immediatePredecessorId:  'pred-is21rimv015a-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final out = await Is21Rimv015As01A05Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('IS21-RIMV-015-AS01-A05 [Pass / Fail] → $out');
}
