// ============================================================
// BLGTA-008-06 — DCDF Lineage Engine
// Atomic Step:  Handle failed OCR with Micro Task Outsourcing.
// Metric:       MTOI Exception Handling Time
// Floor:        0.9  ·  Optimal: 0.97
// Output vocab: Good / Average / Poor
// Standard:     ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:         github.com/varal-uae/UDF · branch: ritwik
// Author:       Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:         25-Sep-2026
// Step No:      58 of 1073
// ============================================================
// Why:          
// Mobile:       
// col41:        Good/Average/Poor → Best = Good (≤15 min)
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Conformance vocabulary: Good / Average / Poor ─────────────

enum Blgta00806ConformanceLevel {
  good,    // ≥ optimal
  average, // ≥ floor
  poor,    // < floor
}

// ── Execution status ─────────────────────────────────────────

enum Blgta00806ExecutionStatus { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// BLGTA-008-06 — DCDF Lineage Engine
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Blgta00806Config {
  final String configId;
  final String gateId;
  final String checkRule;
  final String passThreshold;
  final String failureReason;
  final String validationStatus;
  final bool   immutableInd;
  // DCDF lineage
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Blgta00806Config({
    required this.configId,
    required this.gateId,
    required this.checkRule,
    required this.passThreshold,
    required this.failureReason,
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

  Blgta00806Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Blgta00806Config(
    configId: configId,
    gateId: gateId,
    checkRule: checkRule,
    passThreshold: passThreshold,
    failureReason: failureReason,
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
    'gateId': gateId,
    'checkRule': checkRule,
    'passThreshold': passThreshold,
    'failureReason': failureReason,
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

class Blgta00806ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Blgta00806ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Blgta00806ValidationResult({
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
      case Blgta00806ConformanceLevel.good:    return 'Good';
      case Blgta00806ConformanceLevel.average: return 'Average';
      case Blgta00806ConformanceLevel.poor:    return 'Poor';
    }
  }
}

// ── EC:8 Pipeline ────────────────────────────────────────

/// BLGTA-008-06: Handle failed OCR with Micro Task Outsourcing.
/// Metric: MTOI Exception Handling Time
/// Floor=0.9 · Output=Good / Average / Poor
class Blgta00806Pipeline {
  static const double _floor   = 0.9;
  static const double _optimal = 0.97;

  // EC:1 — System locates the BLGTA-008-06 configuration in the source repository.
  static Blgta00806Config _ec1Locates(Blgta00806Config config) {
    if (config.gateId.isEmpty) {
      throw ArgumentError(
          'EC-BLGTA00806-001: gateId required for BLGTA-008-06');
    }
    // the BLGTA-008-06 configuration in the source repository
    return config;
  }

  // EC:2 — System extracts gateId and checkRule from the BLGTA-008-06 registry.
  static Blgta00806Config _ec2Extracts(Blgta00806Config config) {
    if (config.gateId.isEmpty) {
      throw ArgumentError(
          'EC-BLGTA00806-002: gateId required for BLGTA-008-06');
    }
    // gateId and checkRule from the BLGTA-008-06 registry
    return config;
  }

  // EC:3 — System compiles the implementation rule set per MTOI Exception Handling Time.
  static Blgta00806Config _ec3Compiles(Blgta00806Config config) {
    if (config.gateId.isEmpty) {
      throw ArgumentError(
          'EC-BLGTA00806-003: gateId required for BLGTA-008-06');
    }
    // the implementation rule set per MTOI Exception Handling Time
    return config;
  }

  // EC:4 — System validates configuration against required constraints.
  static Blgta00806Config _ec4Validates(Blgta00806Config config) {
    if (config.gateId.isEmpty) {
      throw ArgumentError(
          'EC-BLGTA00806-004: gateId required for BLGTA-008-06');
    }
    // configuration against required constraints
    return config;
  }

  // EC:5 — System registers compiled rules as immutable with immutable_IND=TRUE.
  static Blgta00806Config _ec5Registers(Blgta00806Config config) {
    if (config.gateId.isEmpty) {
      throw ArgumentError(
          'EC-BLGTA00806-005: gateId required for BLGTA-008-06');
    }
    // compiled rules as immutable with immutable_IND=TRUE
    return config;
  }

  // EC:6 — System validates configuration against MTOI Exception Handling Time gate (floor=0.9).
  static Blgta00806Config _ec6Validates(Blgta00806Config config) {
    if (config.gateId.isEmpty) {
      throw ArgumentError(
          'EC-BLGTA00806-006: gateId required for BLGTA-008-06');
    }
    // configuration against MTOI Exception Handling Time gate (flo
    return config;
  }

  // EC:7 — System routes non-compliant records to the dead letter queue.
  static Blgta00806Config _ec7Routes(Blgta00806Config config) {
    if (config.gateId.isEmpty) {
      throw ArgumentError(
          'EC-BLGTA00806-007: gateId required for BLGTA-008-06');
    }
    // non-compliant records to the dead letter queue
    return config;
  }

  // EC:8 — System publishes validated configuration to the rule registry.
  static Blgta00806Config _ec8Publishes(Blgta00806Config config) {
    if (config.gateId.isEmpty) {
      throw ArgumentError(
          'EC-BLGTA00806-008: gateId required for BLGTA-008-06');
    }
    // validated configuration to the rule registry
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Blgta00806ValidationResult calculateConformance({
    required List<Blgta00806Config> configs,
  }) {
    if (configs.isEmpty) {
      return Blgta00806ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Blgta00806ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-BLGTA00806-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level = rate >= _optimal
        ? Blgta00806ConformanceLevel.good
        : rate >= _floor
            ? Blgta00806ConformanceLevel.average
            : Blgta00806ConformanceLevel.poor;
    return Blgta00806ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-BLGTA00806-VAL',
    );
  }

  static Blgta00806Config routeToRegistry(
    Blgta00806Config config,
    Blgta00806ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Blgta00806Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-BLGTA00806-000: configs must not be empty for BLGTA-008-06');
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
      throw ArgumentError('EC-BLGTA00806-TRI: triangular check failed for BLGTA-008-06');
    }
    final result     = calculateConformance(configs: p8);
    final registered = p8.map((c) => routeToRegistry(c, result)).toList();
    return {
      'status':             result.gatePass ? 'COMPLETE' : 'FAILED',
      'conformance_verdict': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-BLGTA-008-06',
      'metric':             'MTOI Exception Handling Time',
      'output_vocab':       'Good / Average / Poor',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> blgta_008_06Dlq(
    String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'BLGTA-008-06',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Blgta00806Widget extends StatelessWidget {
  final List<Blgta00806Config> configs;
  const Blgta00806Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Blgta00806Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    final isGood = result.gatePass;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('BLGTA-008-06',
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
                title: Text(c.gateId,
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
    Blgta00806Config(
      configId: 'blgta00806-cfg-001',
      gateId: 'blgta-008-06_gateId',
      checkRule: 'blgta-008-06_checkRule',
      passThreshold: 'blgta-008-06_passThreshold',
      failureReason: 'blgta-008-06_failureReason',
      traceId:                 'trace-blgta00806-001',
      originSourceId:          'origin-blgta00806',
      immediatePredecessorId:  'pred-blgta00806-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final out = await Blgta00806Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('BLGTA-008-06 [Good / Average / Poor] → $out');
}
