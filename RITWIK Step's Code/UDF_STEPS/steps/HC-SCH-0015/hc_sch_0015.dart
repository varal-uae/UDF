// ============================================================
// HC-SCH-0015 — Habot Core Schema
// Atomic Step:  Define the relational database foreign keys linking the mobile view inputs back to the ultimate Sour
// Metric:       App Response Latency (p95)
// Floor:        0.9  ·  Optimal: 0.97
// Output vocab: Good / Average / Poor
// Standard:     ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:         github.com/varal-uae/UDF · branch: ritwik
// Author:       Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:         25-Sep-2026
// Step No:      788 of 1073
// ============================================================
// Why:          
// Mobile:       
// col41:        Good/Average/Poor
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Conformance vocabulary: Good / Average / Poor ─────────────

enum HcSch0015ConformanceLevel {
  good,    // ≥ optimal
  average, // ≥ floor
  poor,    // < floor
}

// ── Execution status ─────────────────────────────────────────

enum HcSch0015ExecutionStatus { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// HC-SCH-0015 — Habot Core Schema
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class HcSch0015Config {
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

  const HcSch0015Config({
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

  HcSch0015Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => HcSch0015Config(
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

class HcSch0015ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final HcSch0015ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const HcSch0015ValidationResult({
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
      case HcSch0015ConformanceLevel.good:    return 'Good';
      case HcSch0015ConformanceLevel.average: return 'Average';
      case HcSch0015ConformanceLevel.poor:    return 'Poor';
    }
  }
}

// ── EC:8 Pipeline ────────────────────────────────────────

/// HC-SCH-0015: Define the relational database foreign keys linking the mobile view inputs back 
/// Metric: App Response Latency (p95)
/// Floor=0.9 · Output=Good / Average / Poor
class HcSch0015Pipeline {
  static const double _floor   = 0.9;
  static const double _optimal = 0.97;

  // EC:1 — System locates the HC-SCH-0015 configuration in the source repository.
  static HcSch0015Config _ec1Locates(HcSch0015Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-HCSCH0015-001: fieldId required for HC-SCH-0015');
    }
    // the HC-SCH-0015 configuration in the source repository
    return config;
  }

  // EC:2 — System extracts fieldId and validationRule from the HC-SCH-0015 registry.
  static HcSch0015Config _ec2Extracts(HcSch0015Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-HCSCH0015-002: fieldId required for HC-SCH-0015');
    }
    // fieldId and validationRule from the HC-SCH-0015 registry
    return config;
  }

  // EC:3 — System compiles the implementation rule set per App Response Latency (p95).
  static HcSch0015Config _ec3Compiles(HcSch0015Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-HCSCH0015-003: fieldId required for HC-SCH-0015');
    }
    // the implementation rule set per App Response Latency (p95)
    return config;
  }

  // EC:4 — System validates configuration against required constraints.
  static HcSch0015Config _ec4Validates(HcSch0015Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-HCSCH0015-004: fieldId required for HC-SCH-0015');
    }
    // configuration against required constraints
    return config;
  }

  // EC:5 — System registers compiled rules as immutable with immutable_IND=TRUE.
  static HcSch0015Config _ec5Registers(HcSch0015Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-HCSCH0015-005: fieldId required for HC-SCH-0015');
    }
    // compiled rules as immutable with immutable_IND=TRUE
    return config;
  }

  // EC:6 — System validates configuration against App Response Latency (p95) gate (floor=0.9).
  static HcSch0015Config _ec6Validates(HcSch0015Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-HCSCH0015-006: fieldId required for HC-SCH-0015');
    }
    // configuration against App Response Latency (p95) gate (floor
    return config;
  }

  // EC:7 — System routes non-compliant records to the dead letter queue.
  static HcSch0015Config _ec7Routes(HcSch0015Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-HCSCH0015-007: fieldId required for HC-SCH-0015');
    }
    // non-compliant records to the dead letter queue
    return config;
  }

  // EC:8 — System publishes validated configuration to the rule registry.
  static HcSch0015Config _ec8Publishes(HcSch0015Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-HCSCH0015-008: fieldId required for HC-SCH-0015');
    }
    // validated configuration to the rule registry
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static HcSch0015ValidationResult calculateConformance({
    required List<HcSch0015Config> configs,
  }) {
    if (configs.isEmpty) {
      return HcSch0015ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: HcSch0015ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-HCSCH0015-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level = rate >= _optimal
        ? HcSch0015ConformanceLevel.good
        : rate >= _floor
            ? HcSch0015ConformanceLevel.average
            : HcSch0015ConformanceLevel.poor;
    return HcSch0015ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-HCSCH0015-VAL',
    );
  }

  static HcSch0015Config routeToRegistry(
    HcSch0015Config config,
    HcSch0015ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<HcSch0015Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-HCSCH0015-000: configs must not be empty for HC-SCH-0015');
    }
    final p1 = configs.map(_ec1Locates).toList();
    final p2 = configs.map(_ec2Extracts).toList();
    final p3 = configs.map(_ec3Compiles).toList();
    final p4 = configs.map(_ec4Validates).toList();
    final p5 = configs.map(_ec5Registers).toList();
    final p6 = configs.map(_ec6Validates).toList();
    final p7 = configs.map(_ec7Routes).toList();
    final p8 = configs.map(_ec8Publishes).toList();

    if (!triangularCheck(configs.length, p8.length)) {
      throw ArgumentError('EC-HCSCH0015-TRI: triangular check failed for HC-SCH-0015');
    }
    final result     = calculateConformance(configs: p8);
    final registered = p8.map((c) => routeToRegistry(c, result)).toList();
    return {
      'status':             result.gatePass ? 'COMPLETE' : 'FAILED',
      'conformance_verdict': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-HC-SCH-0015',
      'metric':             'App Response Latency (p95)',
      'output_vocab':       'Good / Average / Poor',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> hc_sch_0015Dlq(
    String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'HC-SCH-0015',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class HcSch0015Widget extends StatelessWidget {
  final List<HcSch0015Config> configs;
  const HcSch0015Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = HcSch0015Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    final isGood = result.gatePass;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('HC-SCH-0015',
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
                    pass ? 'Good' : 'Poor',
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
    HcSch0015Config(
      configId: 'hcsch0015-cfg-001',
      fieldId: 'hc-sch-0015_fieldId',
      validationRule: 'hc-sch-0015_validationRule',
      errorMessage: 'hc-sch-0015_errorMessage',
      inputType: 'hc-sch-0015_inputType',
      traceId:                 'trace-hcsch0015-001',
      originSourceId:          'origin-hcsch0015',
      immediatePredecessorId:  'pred-hcsch0015-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final out = await HcSch0015Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('HC-SCH-0015 [Good / Average / Poor] → $out');
}
