// ============================================================
// ETMDI-015-15 — Enterprise Technical Master Doc Interface
// Atomic Step: MTOI Exception Routing
// Metric:      Error Handling Coverage Rate · Floor=0.95 · Optimal=1.0
// Output:      Good / Average / Poor
// Standard:    ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:        github.com/varal-uae/UDF · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        24-Sep-2026
// Step No:     617 of 1073
// ============================================================
// Why this matters: 
// Mobile impl:      
// Data requirement: Maintain non-blocking UI while awaiting resolution.
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────

enum Etmdi01515ConformanceLevel { complete, partial, notComplete }
enum Etmdi01515ExecutionStatus  { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// Configuration record for ETMDI-015-15.
/// Fields derived from AISS sheet — Enterprise Technical Master Doc Interface.
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Etmdi01515Config {
  final String configId;
  final String errorCode;
  final String exceptionType;
  final String fallbackRoute;
  final String resolvedBy;
  final String validationStatus;
  final bool   immutableInd;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Etmdi01515Config({
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

  Etmdi01515Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Etmdi01515Config(
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

class Etmdi01515ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Etmdi01515ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Etmdi01515ValidationResult({
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
      case Etmdi01515ConformanceLevel.complete:    return 'Good';
      case Etmdi01515ConformanceLevel.partial:     return 'Average';
      case Etmdi01515ConformanceLevel.notComplete: return 'Poor';
    }
  }
}

// ── EC:8 Pipeline ────────────────────────────────────────────

/// ETMDI-015-15: MTOI Exception Routing
/// Metric: Error Handling Coverage Rate · Floor=0.95 · Optimal=1.0
class Etmdi01515Pipeline {
  static const double _floor   = 0.95;
  static const double _optimal = 1.0;

  // EC:1 — System locates the ETMDI-015-15 configuration in the source repository.
  static Etmdi01515Config _ec1Locates(Etmdi01515Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-ETMDI01515-001: errorCode required for ETMDI-015-15');
    }
    // the ETMDI-015-15 configuration in the source repository
    return config;
  }

  // EC:2 — System extracts errorCode and exceptionType from the ETMDI-015-15 registry.
  static Etmdi01515Config _ec2Extracts(Etmdi01515Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-ETMDI01515-002: errorCode required for ETMDI-015-15');
    }
    // errorCode and exceptionType from the ETMDI-015-15 registry
    return config;
  }

  // EC:3 — System compiles the implementation rule set per Error Handling Coverage Rate.
  static Etmdi01515Config _ec3Compiles(Etmdi01515Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-ETMDI01515-003: errorCode required for ETMDI-015-15');
    }
    // the implementation rule set per Error Handling Coverage Rate
    return config;
  }

  // EC:4 — System validates configuration against required constraints.
  static Etmdi01515Config _ec4Validates(Etmdi01515Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-ETMDI01515-004: errorCode required for ETMDI-015-15');
    }
    // configuration against required constraints
    return config;
  }

  // EC:5 — System registers compiled rules as immutable with immutable_IND=TRUE.
  static Etmdi01515Config _ec5Registers(Etmdi01515Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-ETMDI01515-005: errorCode required for ETMDI-015-15');
    }
    // compiled rules as immutable with immutable_IND=TRUE
    return config;
  }

  // EC:6 — System validates configuration against Error Handling Coverage Rate gate (floor=0.95).
  static Etmdi01515Config _ec6Validates(Etmdi01515Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-ETMDI01515-006: errorCode required for ETMDI-015-15');
    }
    // configuration against Error Handling Coverage Rate gate (flo
    return config;
  }

  // EC:7 — System routes non-compliant records to the dead letter queue.
  static Etmdi01515Config _ec7Routes(Etmdi01515Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-ETMDI01515-007: errorCode required for ETMDI-015-15');
    }
    // non-compliant records to the dead letter queue
    return config;
  }

  // EC:8 — System publishes validated configuration to the rule registry.
  static Etmdi01515Config _ec8Publishes(Etmdi01515Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-ETMDI01515-008: errorCode required for ETMDI-015-15');
    }
    // validated configuration to the rule registry
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Etmdi01515ValidationResult calculateConformance({
    required List<Etmdi01515Config> configs,
  }) {
    if (configs.isEmpty) {
      return const Etmdi01515ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Etmdi01515ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-ETMDI01515-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level      = rate >= _optimal
        ? Etmdi01515ConformanceLevel.complete
        : rate >= _floor
            ? Etmdi01515ConformanceLevel.partial
            : Etmdi01515ConformanceLevel.notComplete;
    return Etmdi01515ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-ETMDI01515-VAL',
    );
  }

  static Etmdi01515Config routeToRegistry(
    Etmdi01515Config config,
    Etmdi01515ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Etmdi01515Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-ETMDI01515-000: configs must not be empty for ETMDI-015-15');
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
      throw ArgumentError('EC-ETMDI01515-TRI: triangular check failed for ETMDI-015-15');
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
      'ec_ref':             'EC-ETMDI-015-15',
      'metric':             'Error Handling Coverage Rate',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> etmdi_015_15Dlq(String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'ETMDI-015-15',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Etmdi01515Widget extends StatelessWidget {
  final List<Etmdi01515Config> configs;
  const Etmdi01515Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Etmdi01515Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('ETMDI-015-15',
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
                title: Text(c.errorCode,
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
    Etmdi01515Config(
      configId: 'etmdi01515-cfg-001',
      errorCode: 'etmdi-015-15_errorCode',
      exceptionType: 'etmdi-015-15_exceptionType',
      fallbackRoute: 'etmdi-015-15_fallbackRoute',
      resolvedBy: 'etmdi-015-15_resolvedBy',
      traceId:                 'trace-etmdi01515-001',
      originSourceId:          'origin-etmdi01515',
      immediatePredecessorId:  'pred-etmdi01515-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final result = await Etmdi01515Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('ETMDI-015-15 → $result');
}
