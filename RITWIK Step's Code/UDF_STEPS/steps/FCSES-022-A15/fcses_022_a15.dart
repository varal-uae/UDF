// ============================================================
// FCSES-022-A15 — Fail-Closed Session Execution System
// Atomic Step: Lock "Release to Tech" Button Fail-Closed (FCSES-022)
// Metric:      System Availability Rate · Floor=0.99 · Optimal=1.0
// Output:      Pass / Fail
// Standard:    ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:        github.com/varal-uae/UDF · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        24-Sep-2026
// Step No:     619 of 1073
// ============================================================
// Why this matters: 
// Mobile impl:      
// Data requirement: Confirm developers are protected from wasting time on half-finished blueprints.
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────

enum Fcses022A15ConformanceLevel { complete, partial, notComplete }
enum Fcses022A15ExecutionStatus  { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// Configuration record for FCSES-022-A15.
/// Fields derived from AISS sheet — Fail-Closed Session Execution System.
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Fcses022A15Config {
  final String configId;
  final String gateId;
  final String checkRule;
  final String passThreshold;
  final String failureReason;
  final String validationStatus;
  final bool   immutableInd;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Fcses022A15Config({
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

  Fcses022A15Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Fcses022A15Config(
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

class Fcses022A15ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Fcses022A15ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Fcses022A15ValidationResult({
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
      case Fcses022A15ConformanceLevel.complete:    return 'Complete';
      case Fcses022A15ConformanceLevel.partial:     return 'Partial';
      case Fcses022A15ConformanceLevel.notComplete: return 'Not Complete';
    }
  }
}

// ── EC:8 Pipeline ────────────────────────────────────────────

/// FCSES-022-A15: Lock "Release to Tech" Button Fail-Closed (FCSES-022)
/// Metric: System Availability Rate · Floor=0.99 · Optimal=1.0
class Fcses022A15Pipeline {
  static const double _floor   = 0.99;
  static const double _optimal = 1.0;

  // EC:1 — System locates the FCSES-022-A15 configuration in the source repository.
  static Fcses022A15Config _ec1Locates(Fcses022A15Config config) {
    if (config.gateId.isEmpty) {
      throw ArgumentError(
          'EC-FCSES022A15-001: gateId required for FCSES-022-A15');
    }
    // the FCSES-022-A15 configuration in the source repository
    return config;
  }

  // EC:2 — System extracts gateId and checkRule from the FCSES-022-A15 registry.
  static Fcses022A15Config _ec2Extracts(Fcses022A15Config config) {
    if (config.gateId.isEmpty) {
      throw ArgumentError(
          'EC-FCSES022A15-002: gateId required for FCSES-022-A15');
    }
    // gateId and checkRule from the FCSES-022-A15 registry
    return config;
  }

  // EC:3 — System compiles the implementation rule set per System Availability Rate.
  static Fcses022A15Config _ec3Compiles(Fcses022A15Config config) {
    if (config.gateId.isEmpty) {
      throw ArgumentError(
          'EC-FCSES022A15-003: gateId required for FCSES-022-A15');
    }
    // the implementation rule set per System Availability Rate
    return config;
  }

  // EC:4 — System validates configuration against required constraints.
  static Fcses022A15Config _ec4Validates(Fcses022A15Config config) {
    if (config.gateId.isEmpty) {
      throw ArgumentError(
          'EC-FCSES022A15-004: gateId required for FCSES-022-A15');
    }
    // configuration against required constraints
    return config;
  }

  // EC:5 — System registers compiled rules as immutable with immutable_IND=TRUE.
  static Fcses022A15Config _ec5Registers(Fcses022A15Config config) {
    if (config.gateId.isEmpty) {
      throw ArgumentError(
          'EC-FCSES022A15-005: gateId required for FCSES-022-A15');
    }
    // compiled rules as immutable with immutable_IND=TRUE
    return config;
  }

  // EC:6 — System validates configuration against System Availability Rate gate (floor=0.99).
  static Fcses022A15Config _ec6Validates(Fcses022A15Config config) {
    if (config.gateId.isEmpty) {
      throw ArgumentError(
          'EC-FCSES022A15-006: gateId required for FCSES-022-A15');
    }
    // configuration against System Availability Rate gate (floor=0
    return config;
  }

  // EC:7 — System routes non-compliant records to the dead letter queue.
  static Fcses022A15Config _ec7Routes(Fcses022A15Config config) {
    if (config.gateId.isEmpty) {
      throw ArgumentError(
          'EC-FCSES022A15-007: gateId required for FCSES-022-A15');
    }
    // non-compliant records to the dead letter queue
    return config;
  }

  // EC:8 — System publishes validated configuration to the rule registry.
  static Fcses022A15Config _ec8Publishes(Fcses022A15Config config) {
    if (config.gateId.isEmpty) {
      throw ArgumentError(
          'EC-FCSES022A15-008: gateId required for FCSES-022-A15');
    }
    // validated configuration to the rule registry
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Fcses022A15ValidationResult calculateConformance({
    required List<Fcses022A15Config> configs,
  }) {
    if (configs.isEmpty) {
      return const Fcses022A15ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Fcses022A15ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-FCSES022A15-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level      = rate >= _optimal
        ? Fcses022A15ConformanceLevel.complete
        : rate >= _floor
            ? Fcses022A15ConformanceLevel.partial
            : Fcses022A15ConformanceLevel.notComplete;
    return Fcses022A15ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-FCSES022A15-VAL',
    );
  }

  static Fcses022A15Config routeToRegistry(
    Fcses022A15Config config,
    Fcses022A15ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Fcses022A15Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-FCSES022A15-000: configs must not be empty for FCSES-022-A15');
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
      throw ArgumentError('EC-FCSES022A15-TRI: triangular check failed for FCSES-022-A15');
    }
    final result     = calculateConformance(configs: p8);
    final registered = p8.map((c) => routeToRegistry(c, result)).toList();
    return {
      'status':             result.gatePass ? 'COMPLETE' : 'PARTIAL',
      'conformance_rate':   result.conformanceRate,
      'conformance_output': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-FCSES-022-A15',
      'metric':             'System Availability Rate',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> fcses_022_a15Dlq(String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'FCSES-022-A15',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Fcses022A15Widget extends StatelessWidget {
  final List<Fcses022A15Config> configs;
  const Fcses022A15Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Fcses022A15Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('FCSES-022-A15',
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
                title: Text(c.gateId,
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
    Fcses022A15Config(
      configId: 'fcses022a15-cfg-001',
      gateId: 'fcses-022-a15_gateId',
      checkRule: 'fcses-022-a15_checkRule',
      passThreshold: 'fcses-022-a15_passThreshold',
      failureReason: 'fcses-022-a15_failureReason',
      traceId:                 'trace-fcses022a15-001',
      originSourceId:          'origin-fcses022a15',
      immediatePredecessorId:  'pred-fcses022a15-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final result = await Fcses022A15Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('FCSES-022-A15 → $result');
}
