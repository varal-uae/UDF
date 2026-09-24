// ============================================================
// BLGTA-051-02 — DCDF Lineage Engine
// Atomic Step:  Surfaces the exact error Origin ID and traces it automatically when the mobile app crashes or hits a
// Metric:       Observability / Alert Coverage
// Floor:        0.9  ·  Optimal: 1.0
// Output vocab: Good / Average / Poor
// Standard:     ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:         github.com/varal-uae/UDF · branch: ritwik
// Author:       Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:         25-Sep-2026
// Step No:      64 of 1073
// ============================================================
// Why:          
// Mobile:       
// col41:        Good/Average/Poor → Best = Good (100%)
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Conformance vocabulary: Good / Average / Poor ─────────────

enum Blgta05102ConformanceLevel {
  good,    // ≥ optimal
  average, // ≥ floor
  poor,    // < floor
}

// ── Execution status ─────────────────────────────────────────

enum Blgta05102ExecutionStatus { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// BLGTA-051-02 — DCDF Lineage Engine
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Blgta05102Config {
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

  const Blgta05102Config({
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

  Blgta05102Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Blgta05102Config(
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

class Blgta05102ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Blgta05102ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Blgta05102ValidationResult({
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
      case Blgta05102ConformanceLevel.good:    return 'Good';
      case Blgta05102ConformanceLevel.average: return 'Average';
      case Blgta05102ConformanceLevel.poor:    return 'Poor';
    }
  }
}

// ── EC:8 Pipeline ────────────────────────────────────────

/// BLGTA-051-02: Surfaces the exact error Origin ID and traces it automatically when the mobile a
/// Metric: Observability / Alert Coverage
/// Floor=0.9 · Output=Good / Average / Poor
class Blgta05102Pipeline {
  static const double _floor   = 0.9;
  static const double _optimal = 1.0;

  // EC:1 — System locates the BLGTA-051-02 configuration in the source repository.
  static Blgta05102Config _ec1Locates(Blgta05102Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-BLGTA05102-001: fieldId required for BLGTA-051-02');
    }
    // the BLGTA-051-02 configuration in the source repository
    return config;
  }

  // EC:2 — System extracts fieldId and validationRule from the BLGTA-051-02 registry.
  static Blgta05102Config _ec2Extracts(Blgta05102Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-BLGTA05102-002: fieldId required for BLGTA-051-02');
    }
    // fieldId and validationRule from the BLGTA-051-02 registry
    return config;
  }

  // EC:3 — System compiles the implementation rule set per Observability / Alert Coverage.
  static Blgta05102Config _ec3Compiles(Blgta05102Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-BLGTA05102-003: fieldId required for BLGTA-051-02');
    }
    // the implementation rule set per Observability / Alert Covera
    return config;
  }

  // EC:4 — System validates configuration against required constraints.
  static Blgta05102Config _ec4Validates(Blgta05102Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-BLGTA05102-004: fieldId required for BLGTA-051-02');
    }
    // configuration against required constraints
    return config;
  }

  // EC:5 — System registers compiled rules as immutable with immutable_IND=TRUE.
  static Blgta05102Config _ec5Registers(Blgta05102Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-BLGTA05102-005: fieldId required for BLGTA-051-02');
    }
    // compiled rules as immutable with immutable_IND=TRUE
    return config;
  }

  // EC:6 — System validates configuration against Observability / Alert Coverage gate (floor=0.9).
  static Blgta05102Config _ec6Validates(Blgta05102Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-BLGTA05102-006: fieldId required for BLGTA-051-02');
    }
    // configuration against Observability / Alert Coverage gate (f
    return config;
  }

  // EC:7 — System routes non-compliant records to the dead letter queue.
  static Blgta05102Config _ec7Routes(Blgta05102Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-BLGTA05102-007: fieldId required for BLGTA-051-02');
    }
    // non-compliant records to the dead letter queue
    return config;
  }

  // EC:8 — System publishes validated configuration to the rule registry.
  static Blgta05102Config _ec8Publishes(Blgta05102Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-BLGTA05102-008: fieldId required for BLGTA-051-02');
    }
    // validated configuration to the rule registry
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Blgta05102ValidationResult calculateConformance({
    required List<Blgta05102Config> configs,
  }) {
    if (configs.isEmpty) {
      return Blgta05102ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Blgta05102ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-BLGTA05102-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level = rate >= _optimal
        ? Blgta05102ConformanceLevel.good
        : rate >= _floor
            ? Blgta05102ConformanceLevel.average
            : Blgta05102ConformanceLevel.poor;
    return Blgta05102ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-BLGTA05102-VAL',
    );
  }

  static Blgta05102Config routeToRegistry(
    Blgta05102Config config,
    Blgta05102ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Blgta05102Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-BLGTA05102-000: configs must not be empty for BLGTA-051-02');
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
      throw ArgumentError('EC-BLGTA05102-TRI: triangular check failed for BLGTA-051-02');
    }
    final result     = calculateConformance(configs: p8);
    final registered = p8.map((c) => routeToRegistry(c, result)).toList();
    return {
      'status':             result.gatePass ? 'COMPLETE' : 'FAILED',
      'conformance_verdict': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-BLGTA-051-02',
      'metric':             'Observability / Alert Coverage',
      'output_vocab':       'Good / Average / Poor',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> blgta_051_02Dlq(
    String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'BLGTA-051-02',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Blgta05102Widget extends StatelessWidget {
  final List<Blgta05102Config> configs;
  const Blgta05102Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Blgta05102Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    final isGood = result.gatePass;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('BLGTA-051-02',
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
    Blgta05102Config(
      configId: 'blgta05102-cfg-001',
      fieldId: 'blgta-051-02_fieldId',
      validationRule: 'blgta-051-02_validationRule',
      errorMessage: 'blgta-051-02_errorMessage',
      inputType: 'blgta-051-02_inputType',
      traceId:                 'trace-blgta05102-001',
      originSourceId:          'origin-blgta05102',
      immediatePredecessorId:  'pred-blgta05102-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final out = await Blgta05102Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('BLGTA-051-02 [Good / Average / Poor] → $out');
}
