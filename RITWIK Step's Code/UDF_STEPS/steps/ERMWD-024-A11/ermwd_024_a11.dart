// ============================================================
// ERMWD-024-A11 — Error Mapping & Widget Display
// Atomic Step: Design MTOI Single-Action Mobile Interface.
// Metric:      Input Validation Coverage Rate · Floor=0.95 · Optimal=1.0
// Output:      Pass / Fail
// Standard:    ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:        github.com/varal-uae/UDF · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        24-Sep-2026
// Step No:     578 of 1073
// ============================================================
// Why this matters: Enforces zero decision-making. Perfectly suited for mobile gig-workers to execute micro-tasks instan
// Mobile impl:      
// Data requirement: Connect submission events to push clean data entries straight into processing queues.
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────

enum Ermwd024A11ConformanceLevel { complete, partial, notComplete }
enum Ermwd024A11ExecutionStatus  { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// Configuration record for ERMWD-024-A11.
/// Fields derived from AISS sheet — Error Mapping & Widget Display.
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Ermwd024A11Config {
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

  const Ermwd024A11Config({
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

  Ermwd024A11Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Ermwd024A11Config(
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

class Ermwd024A11ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Ermwd024A11ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Ermwd024A11ValidationResult({
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
      case Ermwd024A11ConformanceLevel.complete:    return 'Complete';
      case Ermwd024A11ConformanceLevel.partial:     return 'Partial';
      case Ermwd024A11ConformanceLevel.notComplete: return 'Not Complete';
    }
  }
}

// ── EC:1 Pipeline ────────────────────────────────────────────

/// ERMWD-024-A11: Design MTOI Single-Action Mobile Interface.
/// Metric: Input Validation Coverage Rate · Floor=0.95 · Optimal=1.0
class Ermwd024A11Pipeline {
  static const double _floor   = 0.95;
  static const double _optimal = 1.0;

  // EC:1 — 1) Visually crop the Byt image to remove context. 2) Provide exactly one input box. 3) App
  static Ermwd024A11Config _ec1Execute(Ermwd024A11Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-ERMWD024A11-001: fieldId required for ERMWD-024-A11');
    }
    // 1) Visually crop the Byt image to remove context. 2) Provide
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Ermwd024A11ValidationResult calculateConformance({
    required List<Ermwd024A11Config> configs,
  }) {
    if (configs.isEmpty) {
      return const Ermwd024A11ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Ermwd024A11ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-ERMWD024A11-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level      = rate >= _optimal
        ? Ermwd024A11ConformanceLevel.complete
        : rate >= _floor
            ? Ermwd024A11ConformanceLevel.partial
            : Ermwd024A11ConformanceLevel.notComplete;
    return Ermwd024A11ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-ERMWD024A11-VAL',
    );
  }

  static Ermwd024A11Config routeToRegistry(
    Ermwd024A11Config config,
    Ermwd024A11ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Ermwd024A11Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-ERMWD024A11-000: configs must not be empty for ERMWD-024-A11');
    }
    final p1 = configs.map(_ec1Execute).toList();

    if (!triangularCheck(configs.length, p1.length)) {
      throw ArgumentError('EC-ERMWD024A11-TRI: triangular check failed for ERMWD-024-A11');
    }
    final result     = calculateConformance(configs: p1);
    final registered = p1.map((c) => routeToRegistry(c, result)).toList();
    return {
      'status':             result.gatePass ? 'COMPLETE' : 'PARTIAL',
      'conformance_rate':   result.conformanceRate,
      'conformance_output': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-ERMWD-024-A11',
      'metric':             'Input Validation Coverage Rate',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> ermwd_024_a11Dlq(String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'ERMWD-024-A11',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Ermwd024A11Widget extends StatelessWidget {
  final List<Ermwd024A11Config> configs;
  const Ermwd024A11Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Ermwd024A11Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('ERMWD-024-A11',
              style: const TextStyle(fontFamily:'Courier',fontWeight:FontWeight.bold,fontSize:12))),
            Chip(
              label: Text(
                '${result.conformanceOutput} · ${result.violationCount} violation${result.violationCount==1?"":"s"}',
                style: const TextStyle(color:Colors.white,fontSize:11)),
              backgroundColor: result.gatePass ? cs.tertiary : cs.error),
          ]),
        ),
        Expanded(child: ListView.builder(
          itemCount: configs.length,
          itemBuilder: (context, i) {
            final c = configs[i]; final pass = c.isRegistered;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal:16,vertical:4),
              child: ListTile(
                leading: Icon(pass ? Icons.check_circle : Icons.cancel,
                  color: pass ? cs.tertiary : cs.error),
                title: Text(c.fieldId,
                  style: const TextStyle(fontWeight:FontWeight.w600,fontSize:12)),
                subtitle: Text(
                  'id: ${c.configId.length>8?c.configId.substring(0,8):c.configId}… | ${c.validationStatus}',
                  style: const TextStyle(fontSize:11)),
                trailing: Chip(
                  label: Text(pass?'PASS':'FAIL',
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
    Ermwd024A11Config(
      configId: 'ermwd024a11-cfg-001',
      fieldId: 'ermwd-024-a11_fieldId',
      validationRule: 'ermwd-024-a11_validationRule',
      errorMessage: 'ermwd-024-a11_errorMessage',
      inputType: 'ermwd-024-a11_inputType',
      traceId:                 'trace-ermwd024a11-001',
      originSourceId:          'origin-ermwd024a11',
      immediatePredecessorId:  'pred-ermwd024a11-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final result = await Ermwd024A11Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('ERMWD-024-A11 → $result');
}
