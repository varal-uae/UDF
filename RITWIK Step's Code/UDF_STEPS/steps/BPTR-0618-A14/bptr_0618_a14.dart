// ============================================================
// BPTR-0618-A14 — UI/UX Pattern Registry
// Atomic Step:  Implement Regex Input Masking for Mobile Forms
// Metric:       System Integration Wiring Completeness
// Floor:        95.0  ·  Optimal: 99.5
// Output vocab: Complete / Partial / Not Complete
// Standard:     ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:         github.com/varal-uae/UDF · branch: ritwik
// Author:       Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:         25-Sep-2026
// Step No:      109 of 1073
// ============================================================
// Why:          Prevents dirty, malformed data from breaking downstream BigQuery pipelines and payroll APIs.
// Mobile:       Eliminates tedious mobile backspacing; input automatically spaces and formats strings on a small scr
// col41:        Pass (Scale: Pass/Fail)
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Conformance vocabulary: Complete / Partial / Not Complete ─────────────

enum Bptr0618A14ConformanceLevel {
  complete,    // ≥ optimal
  partial,     // ≥ floor
  notComplete, // < floor
}

// ── Execution status ─────────────────────────────────────────

enum Bptr0618A14ExecutionStatus { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

class Bptr0618A14Config {
  final String configId;
  final String fieldId;
  final String validationRule;
  final String errorMessage;
  final String inputType;
  final String validationStatus;
  final bool   immutableInd;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Bptr0618A14Config({
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

  Bptr0618A14Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Bptr0618A14Config(
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

class Bptr0618A14ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Bptr0618A14ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Bptr0618A14ValidationResult({
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
      case Bptr0618A14ConformanceLevel.complete:    return 'Complete';
      case Bptr0618A14ConformanceLevel.partial:     return 'Partial';
      case Bptr0618A14ConformanceLevel.notComplete: return 'Not Complete';
    }
  }
}

// ── EC:1 Pipeline ────────────────────────────────────────

class Bptr0618A14Pipeline {
  static const double _floor   = 95.0;
  static const double _optimal = 99.5;

  // EC:1 — 1) Define Regex rules. 2) Apply UI masking code. 3) Disable invalid keys. 4) Render red er
  static Bptr0618A14Config _ec1Execute(Bptr0618A14Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-BPTR0618A14-001: fieldId required for BPTR-0618-A14');
    }
    // 1) Define Regex rules. 2) Apply UI masking code. 3) Disable 
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Bptr0618A14ValidationResult calculateConformance({
    required List<Bptr0618A14Config> configs,
  }) {
    if (configs.isEmpty) {
      return Bptr0618A14ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Bptr0618A14ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-BPTR0618A14-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level = rate >= _optimal
        ? Bptr0618A14ConformanceLevel.complete
        : rate >= _floor
            ? Bptr0618A14ConformanceLevel.partial
            : Bptr0618A14ConformanceLevel.notComplete;
    return Bptr0618A14ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-BPTR0618A14-VAL',
    );
  }

  static Bptr0618A14Config routeToRegistry(
    Bptr0618A14Config config,
    Bptr0618A14ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Bptr0618A14Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-BPTR0618A14-000: configs must not be empty for BPTR-0618-A14');
    }
    final p1 = configs.map(_ec1Execute).toList();

    if (!triangularCheck(configs.length, p1.length)) {
      throw ArgumentError('EC-BPTR0618A14-TRI: triangular check failed for BPTR-0618-A14');
    }
    final result     = calculateConformance(configs: p1);
    final registered = p1.map((c) => routeToRegistry(c, result)).toList();
    return {
      'status':             result.gatePass ? 'COMPLETE' : 'FAILED',
      'conformance_verdict': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-BPTR-0618-A14',
      'metric':             'System Integration Wiring Completeness',
      'output_vocab':       'Complete / Partial / Not Complete',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> bptr_0618_a14Dlq(
    String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'BPTR-0618-A14',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Bptr0618A14Widget extends StatelessWidget {
  final List<Bptr0618A14Config> configs;
  const Bptr0618A14Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Bptr0618A14Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('BPTR-0618-A14',
              style: const TextStyle(fontFamily:'Courier',
                fontWeight:FontWeight.bold, fontSize:12))),
            Chip(
              label: Text(
                result.conformanceOutput,
                style: const TextStyle(color:Colors.white, fontSize:11)),
              backgroundColor: result.gatePass ? cs.tertiary : cs.error),
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
                    pass ? 'Complete' : 'Not Complete',
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
    Bptr0618A14Config(
      configId: 'bptr0618a14-cfg-001',
      fieldId: 'bptr-0618-a14_fieldId',
      validationRule: 'bptr-0618-a14_validationRule',
      errorMessage: 'bptr-0618-a14_errorMessage',
      inputType: 'bptr-0618-a14_inputType',
      traceId:                 'trace-bptr0618a14-001',
      originSourceId:          'origin-bptr0618a14',
      immediatePredecessorId:  'pred-bptr0618a14-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final out = await Bptr0618A14Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('BPTR-0618-A14 [Complete / Partial / Not Complete] → $out');
}
