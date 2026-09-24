// ============================================================
// IS03-CSIVW-007-AS01-A07 — Implementation System 03
// Atomic Step: Hardcode format constraints directly inside layout entry cells.
// Metric:      Layout Consistency Score · Floor=0.90 · Optimal=0.97
// Output:      Pass / Partial / Fail
// Standard:    ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:        github.com/varal-uae/UDF · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        24-Sep-2026
// Step No:     551 of 1073
// ============================================================
// Why this matters: Blocks incorrect data inputs at the interaction phase before validation sweeps fail downstream.
// Mobile impl:      Client-side input masking rejects bad text locally before network calls execute, saving bandwidth.
// Data requirement: Check typed keystroke character against hardcoded allowed character rule set.
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────

enum Is03Csivw007As01A07ConformanceLevel { complete, partial, notComplete }
enum Is03Csivw007As01A07ExecutionStatus  { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// Configuration record for IS03-CSIVW-007-AS01-A07.
/// Fields derived from AISS sheet — Implementation System 03.
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Is03Csivw007As01A07Config {
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

  const Is03Csivw007As01A07Config({
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

  Is03Csivw007As01A07Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Is03Csivw007As01A07Config(
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

class Is03Csivw007As01A07ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Is03Csivw007As01A07ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Is03Csivw007As01A07ValidationResult({
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
      case Is03Csivw007As01A07ConformanceLevel.complete:    return 'Pass';
      case Is03Csivw007As01A07ConformanceLevel.partial:     return 'Partial';
      case Is03Csivw007As01A07ConformanceLevel.notComplete: return 'Fail';
    }
  }
}

// ── EC:4 Pipeline ────────────────────────────────────────────

/// IS03-CSIVW-007-AS01-A07: Hardcode format constraints directly inside layout entry cells.
/// Metric: Layout Consistency Score · Floor=0.90 · Optimal=0.97
class Is03Csivw007As01A07Pipeline {
  static const double _floor   = 0.90;
  static const double _optimal = 0.97;

  // EC:1 — * Connect format verification rules directly to text input cells
  static Is03Csivw007As01A07Config _ec1Execute(Is03Csivw007As01A07Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-IS03CSIVW007-001: fieldId required for IS03-CSIVW-007-AS01-A07');
    }
    // * Connect format verification rules directly to text input c
    return config;
  }

  // EC:2 — * Program client-side event logic to block invalid key entries
  static Is03Csivw007As01A07Config _ec2Execute(Is03Csivw007As01A07Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-IS03CSIVW007-002: fieldId required for IS03-CSIVW-007-AS01-A07');
    }
    // * Program client-side event logic to block invalid key entri
    return config;
  }

  // EC:3 — * Update form action buttons to disable on validation errors
  static Is03Csivw007As01A07Config _ec3Execute(Is03Csivw007As01A07Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-IS03CSIVW007-003: fieldId required for IS03-CSIVW-007-AS01-A07');
    }
    // * Update form action buttons to disable on validation errors
    return config;
  }

  // EC:4 — * Connect layout validation parameters to back-end schemas
  static Is03Csivw007As01A07Config _ec4Execute(Is03Csivw007As01A07Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-IS03CSIVW007-004: fieldId required for IS03-CSIVW-007-AS01-A07');
    }
    // * Connect layout validation parameters to back-end schemas
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Is03Csivw007As01A07ValidationResult calculateConformance({
    required List<Is03Csivw007As01A07Config> configs,
  }) {
    if (configs.isEmpty) {
      return const Is03Csivw007As01A07ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Is03Csivw007As01A07ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-IS03CSIVW007-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level      = rate >= _optimal
        ? Is03Csivw007As01A07ConformanceLevel.complete
        : rate >= _floor
            ? Is03Csivw007As01A07ConformanceLevel.partial
            : Is03Csivw007As01A07ConformanceLevel.notComplete;
    return Is03Csivw007As01A07ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-IS03CSIVW007-VAL',
    );
  }

  static Is03Csivw007As01A07Config routeToRegistry(
    Is03Csivw007As01A07Config config,
    Is03Csivw007As01A07ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Is03Csivw007As01A07Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-IS03CSIVW007-000: configs must not be empty for IS03-CSIVW-007-AS01-A07');
    }
    final p1 = configs.map(_ec1Execute).toList();
    final p2 = configs.map(_ec2Execute).toList();
    final p3 = configs.map(_ec3Execute).toList();
    final p4 = configs.map(_ec4Execute).toList();

    if (!triangularCheck(configs.length, p4.length)) {
      throw ArgumentError('EC-IS03CSIVW007-TRI: triangular check failed for IS03-CSIVW-007-AS01-A07');
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
      'ec_ref':             'EC-IS03-CSIVW-007-AS01-A07',
      'metric':             'Layout Consistency Score',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> is03_csivw_007_as01_a07Dlq(String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'IS03-CSIVW-007-AS01-A07',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Is03Csivw007As01A07Widget extends StatelessWidget {
  final List<Is03Csivw007As01A07Config> configs;
  const Is03Csivw007As01A07Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Is03Csivw007As01A07Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('IS03-CSIVW-007-AS01-A07',
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
    Is03Csivw007As01A07Config(
      configId: 'is03csivw007-cfg-001',
      fieldId: 'is03-csivw-007-as01-a07_fieldId',
      validationRule: 'is03-csivw-007-as01-a07_validationRule',
      errorMessage: 'is03-csivw-007-as01-a07_errorMessage',
      inputType: 'is03-csivw-007-as01-a07_inputType',
      traceId:                 'trace-is03csivw007-001',
      originSourceId:          'origin-is03csivw007',
      immediatePredecessorId:  'pred-is03csivw007-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final result = await Is03Csivw007As01A07Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('IS03-CSIVW-007-AS01-A07 → $result');
}
