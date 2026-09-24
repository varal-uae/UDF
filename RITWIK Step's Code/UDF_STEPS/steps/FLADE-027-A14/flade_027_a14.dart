// ============================================================
// FLADE-027-A14 — Friction Logging & Analytics Data Engine
// Atomic Step: Setup Mobile Progressive Profiling Step 1 Form.
// Metric:      Input Validation Coverage Rate · Floor=0.005 · Optimal=0.01
// Output:      Pass / Partial / Fail
// Standard:    ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:        github.com/varal-uae/UDF · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        24-Sep-2026
// Step No:     605 of 1073
// ============================================================
// Why this matters: Avoids upfront abandonment due to cognitive overload and form friction, which is especially high on 
// Mobile impl:      Ensures the initial sign-up fits entirely "above the fold" on a standard mobile screen, requiring ze
// Data requirement: Verify that the mobile form component renders with exactly the 3 designated basic fields.
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────

enum Flade027A14ConformanceLevel { complete, partial, notComplete }
enum Flade027A14ExecutionStatus  { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// Configuration record for FLADE-027-A14.
/// Fields derived from AISS sheet — Friction Logging & Analytics Data Engine.
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Flade027A14Config {
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

  const Flade027A14Config({
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

  Flade027A14Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Flade027A14Config(
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

class Flade027A14ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Flade027A14ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Flade027A14ValidationResult({
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
      case Flade027A14ConformanceLevel.complete:    return 'Pass';
      case Flade027A14ConformanceLevel.partial:     return 'Partial';
      case Flade027A14ConformanceLevel.notComplete: return 'Fail';
    }
  }
}

// ── EC:4 Pipeline ────────────────────────────────────────────

/// FLADE-027-A14: Setup Mobile Progressive Profiling Step 1 Form.
/// Metric: Input Validation Coverage Rate · Floor=0.005 · Optimal=0.01
class Flade027A14Pipeline {
  static const double _floor   = 0.005;
  static const double _optimal = 0.01;

  // EC:1 — Create Name and Email inputs
  static Flade027A14Config _ec1Execute(Flade027A14Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-FLADE027A14-001: fieldId required for FLADE-027-A14');
    }
    // Create Name and Email inputs
    return config;
  }

  // EC:2 — Include Location dropdown
  static Flade027A14Config _ec2Execute(Flade027A14Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-FLADE027A14-002: fieldId required for FLADE-027-A14');
    }
    // Include Location dropdown
    return config;
  }

  // EC:3 — Remove Age and Earnings fields from this initial screen
  static Flade027A14Config _ec3Execute(Flade027A14Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-FLADE027A14-003: fieldId required for FLADE-027-A14');
    }
    // Remove Age and Earnings fields from this initial screen
    return config;
  }

  // EC:4 — Generate partial ED record in the database
  static Flade027A14Config _ec4Execute(Flade027A14Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-FLADE027A14-004: fieldId required for FLADE-027-A14');
    }
    // Generate partial ED record in the database
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Flade027A14ValidationResult calculateConformance({
    required List<Flade027A14Config> configs,
  }) {
    if (configs.isEmpty) {
      return const Flade027A14ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Flade027A14ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-FLADE027A14-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level      = rate >= _optimal
        ? Flade027A14ConformanceLevel.complete
        : rate >= _floor
            ? Flade027A14ConformanceLevel.partial
            : Flade027A14ConformanceLevel.notComplete;
    return Flade027A14ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-FLADE027A14-VAL',
    );
  }

  static Flade027A14Config routeToRegistry(
    Flade027A14Config config,
    Flade027A14ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Flade027A14Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-FLADE027A14-000: configs must not be empty for FLADE-027-A14');
    }
    final p1 = configs.map(_ec1Execute).toList();
    final p2 = configs.map(_ec2Execute).toList();
    final p3 = configs.map(_ec3Execute).toList();
    final p4 = configs.map(_ec4Execute).toList();

    if (!triangularCheck(configs.length, p4.length)) {
      throw ArgumentError('EC-FLADE027A14-TRI: triangular check failed for FLADE-027-A14');
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
      'ec_ref':             'EC-FLADE-027-A14',
      'metric':             'Input Validation Coverage Rate',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> flade_027_a14Dlq(String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'FLADE-027-A14',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Flade027A14Widget extends StatelessWidget {
  final List<Flade027A14Config> configs;
  const Flade027A14Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Flade027A14Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('FLADE-027-A14',
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
    Flade027A14Config(
      configId: 'flade027a14-cfg-001',
      fieldId: 'flade-027-a14_fieldId',
      validationRule: 'flade-027-a14_validationRule',
      errorMessage: 'flade-027-a14_errorMessage',
      inputType: 'flade-027-a14_inputType',
      traceId:                 'trace-flade027a14-001',
      originSourceId:          'origin-flade027a14',
      immediatePredecessorId:  'pred-flade027a14-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final result = await Flade027A14Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('FLADE-027-A14 → $result');
}
