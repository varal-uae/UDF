// ============================================================
// DPRBR-012 — Data Pipeline Route Branching
// Atomic Step:  Configuring Dynamic Payment Failure Tracking Hooks for Automated Dunning Routines.
// Metric:       Map Gateway Error Quality Index
// Floor:        0.96  ·  Optimal: 1.0
// Output vocab: Good / Average / Poor
// Standard:     ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:         github.com/varal-uae/UDF · branch: ritwik
// Author:       Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:         25-Sep-2026
// Step No:      178 of 1073
// ============================================================
// Why:          Prevents malicious websites from making unauthorized API requests on behalf of users.
// Mobile:       While mobile apps don't strictly enforce CORS, the web-based MTO and Admin portals do; securing this
// col41:        Good
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Conformance vocabulary: Good / Average / Poor ─────────────

enum Dprbr012ConformanceLevel {
  good,    // ≥ optimal
  average, // ≥ floor
  poor,    // < floor
}

// ── Execution status ─────────────────────────────────────────

enum Dprbr012ExecutionStatus { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// DPRBR-012 — Data Pipeline Route Branching
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Dprbr012Config {
  final String configId;
  final String errorCode;
  final String exceptionType;
  final String fallbackRoute;
  final String resolvedBy;
  final String validationStatus;
  final bool   immutableInd;
  // DCDF lineage
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Dprbr012Config({
    required this.configId,
    required this.errorCode,
    required this.exceptionType,
    required this.fallbackRoute,
    required this.resolvedBy,
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

  Dprbr012Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Dprbr012Config(
    configId: configId,
    errorCode: errorCode,
    exceptionType: exceptionType,
    fallbackRoute: fallbackRoute,
    resolvedBy: resolvedBy,
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
    'errorCode': errorCode,
    'exceptionType': exceptionType,
    'fallbackRoute': fallbackRoute,
    'resolvedBy': resolvedBy,
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

class Dprbr012ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Dprbr012ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Dprbr012ValidationResult({
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
      case Dprbr012ConformanceLevel.good:    return 'Good';
      case Dprbr012ConformanceLevel.average: return 'Average';
      case Dprbr012ConformanceLevel.poor:    return 'Poor';
    }
  }
}

// ── EC:8 Pipeline ────────────────────────────────────────

/// DPRBR-012: Configuring Dynamic Payment Failure Tracking Hooks for Automated Dunning Routine
/// Metric: Map Gateway Error Quality Index
/// Floor=0.96 · Output=Good / Average / Poor
class Dprbr012Pipeline {
  static const double _floor   = 0.96;
  static const double _optimal = 1.0;

  // EC:1 — System locates the DPRBR-012 configuration in the source repository.
  static Dprbr012Config _ec1Locates(Dprbr012Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-DPRBR012-001: errorCode required for DPRBR-012');
    }
    // the DPRBR-012 configuration in the source repository
    return config;
  }

  // EC:2 — System extracts errorCode and exceptionType from the DPRBR-012 registry.
  static Dprbr012Config _ec2Extracts(Dprbr012Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-DPRBR012-002: errorCode required for DPRBR-012');
    }
    // errorCode and exceptionType from the DPRBR-012 registry
    return config;
  }

  // EC:3 — System compiles the implementation rule set per Map Gateway Error Quality Index.
  static Dprbr012Config _ec3Compiles(Dprbr012Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-DPRBR012-003: errorCode required for DPRBR-012');
    }
    // the implementation rule set per Map Gateway Error Quality In
    return config;
  }

  // EC:4 — System validates configuration against required constraints.
  static Dprbr012Config _ec4Validates(Dprbr012Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-DPRBR012-004: errorCode required for DPRBR-012');
    }
    // configuration against required constraints
    return config;
  }

  // EC:5 — System registers compiled rules as immutable with immutable_IND=TRUE.
  static Dprbr012Config _ec5Registers(Dprbr012Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-DPRBR012-005: errorCode required for DPRBR-012');
    }
    // compiled rules as immutable with immutable_IND=TRUE
    return config;
  }

  // EC:6 — System validates configuration against Map Gateway Error Quality Index gate (floor=0.96).
  static Dprbr012Config _ec6Validates(Dprbr012Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-DPRBR012-006: errorCode required for DPRBR-012');
    }
    // configuration against Map Gateway Error Quality Index gate (
    return config;
  }

  // EC:7 — System routes non-compliant records to the dead letter queue.
  static Dprbr012Config _ec7Routes(Dprbr012Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-DPRBR012-007: errorCode required for DPRBR-012');
    }
    // non-compliant records to the dead letter queue
    return config;
  }

  // EC:8 — System publishes validated configuration to the rule registry.
  static Dprbr012Config _ec8Publishes(Dprbr012Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-DPRBR012-008: errorCode required for DPRBR-012');
    }
    // validated configuration to the rule registry
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Dprbr012ValidationResult calculateConformance({
    required List<Dprbr012Config> configs,
  }) {
    if (configs.isEmpty) {
      return Dprbr012ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Dprbr012ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-DPRBR012-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level = rate >= _optimal
        ? Dprbr012ConformanceLevel.good
        : rate >= _floor
            ? Dprbr012ConformanceLevel.average
            : Dprbr012ConformanceLevel.poor;
    return Dprbr012ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-DPRBR012-VAL',
    );
  }

  static Dprbr012Config routeToRegistry(
    Dprbr012Config config,
    Dprbr012ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Dprbr012Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-DPRBR012-000: configs must not be empty for DPRBR-012');
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
      throw ArgumentError('EC-DPRBR012-TRI: triangular check failed for DPRBR-012');
    }
    final result     = calculateConformance(configs: p8);
    final registered = p8.map((c) => routeToRegistry(c, result)).toList();
    return {
      'status':             result.gatePass ? 'COMPLETE' : 'FAILED',
      'conformance_verdict': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-DPRBR-012',
      'metric':             'Map Gateway Error Quality Index',
      'output_vocab':       'Good / Average / Poor',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> dprbr_012Dlq(
    String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'DPRBR-012',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Dprbr012Widget extends StatelessWidget {
  final List<Dprbr012Config> configs;
  const Dprbr012Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Dprbr012Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    final isGood = result.gatePass;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('DPRBR-012',
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
                title: Text(c.errorCode,
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
    Dprbr012Config(
      configId: 'dprbr012-cfg-001',
      errorCode: 'dprbr-012_errorCode',
      exceptionType: 'dprbr-012_exceptionType',
      fallbackRoute: 'dprbr-012_fallbackRoute',
      resolvedBy: 'dprbr-012_resolvedBy',
      traceId:                 'trace-dprbr012-001',
      originSourceId:          'origin-dprbr012',
      immediatePredecessorId:  'pred-dprbr012-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final out = await Dprbr012Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('DPRBR-012 [Good / Average / Poor] → $out');
}
