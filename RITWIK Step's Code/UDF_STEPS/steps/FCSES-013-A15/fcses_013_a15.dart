// ============================================================
// FCSES-013-A15 — Fail-Closed Session Execution System
// Atomic Step: FCSES-013 - Frontend Error Mapping Boundaries
// Metric:      Error Handling Coverage Rate · Floor=0.95 · Optimal=1.0
// Output:      Pass / Fail
// Standard:    ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:        github.com/varal-uae/UDF · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        24-Sep-2026
// Step No:     613 of 1073
// ============================================================
// Why this matters: A backend error should never result in a hard app crash.
// Mobile impl:      Isolates the error to the specific component that failed, leaving the rest functional.
// Data requirement: Document the mapping table for backend and frontend teams to keep in sync.
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────

enum Fcses013A15ConformanceLevel { complete, partial, notComplete }
enum Fcses013A15ExecutionStatus  { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// Configuration record for FCSES-013-A15.
/// Fields derived from AISS sheet — Fail-Closed Session Execution System.
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Fcses013A15Config {
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

  const Fcses013A15Config({
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

  Fcses013A15Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Fcses013A15Config(
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

class Fcses013A15ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Fcses013A15ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Fcses013A15ValidationResult({
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
      case Fcses013A15ConformanceLevel.complete:    return 'Complete';
      case Fcses013A15ConformanceLevel.partial:     return 'Partial';
      case Fcses013A15ConformanceLevel.notComplete: return 'Not Complete';
    }
  }
}

// ── EC:4 Pipeline ────────────────────────────────────────────

/// FCSES-013-A15: FCSES-013 - Frontend Error Mapping Boundaries
/// Metric: Error Handling Coverage Rate · Floor=0.95 · Optimal=1.0
class Fcses013A15Pipeline {
  static const double _floor   = 0.95;
  static const double _optimal = 1.0;

  // EC:1 — Catalog API codes
  static Fcses013A15Config _ec1Execute(Fcses013A15Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-FCSES013A15-001: errorCode required for FCSES-013-A15');
    }
    // Catalog API codes
    return config;
  }

  // EC:2 — Map to components
  static Fcses013A15Config _ec2Execute(Fcses013A15Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-FCSES013A15-002: errorCode required for FCSES-013-A15');
    }
    // Map to components
    return config;
  }

  // EC:3 — Define local text
  static Fcses013A15Config _ec3Execute(Fcses013A15Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-FCSES013A15-003: errorCode required for FCSES-013-A15');
    }
    // Define local text
    return config;
  }

  // EC:4 — Implement Retry blocks
  static Fcses013A15Config _ec4Execute(Fcses013A15Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-FCSES013A15-004: errorCode required for FCSES-013-A15');
    }
    // Implement Retry blocks
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Fcses013A15ValidationResult calculateConformance({
    required List<Fcses013A15Config> configs,
  }) {
    if (configs.isEmpty) {
      return const Fcses013A15ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Fcses013A15ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-FCSES013A15-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level      = rate >= _optimal
        ? Fcses013A15ConformanceLevel.complete
        : rate >= _floor
            ? Fcses013A15ConformanceLevel.partial
            : Fcses013A15ConformanceLevel.notComplete;
    return Fcses013A15ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-FCSES013A15-VAL',
    );
  }

  static Fcses013A15Config routeToRegistry(
    Fcses013A15Config config,
    Fcses013A15ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Fcses013A15Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-FCSES013A15-000: configs must not be empty for FCSES-013-A15');
    }
    final p1 = configs.map(_ec1Execute).toList();
    final p2 = configs.map(_ec2Execute).toList();
    final p3 = configs.map(_ec3Execute).toList();
    final p4 = configs.map(_ec4Execute).toList();

    if (!triangularCheck(configs.length, p4.length)) {
      throw ArgumentError('EC-FCSES013A15-TRI: triangular check failed for FCSES-013-A15');
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
      'ec_ref':             'EC-FCSES-013-A15',
      'metric':             'Error Handling Coverage Rate',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> fcses_013_a15Dlq(String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'FCSES-013-A15',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Fcses013A15Widget extends StatelessWidget {
  final List<Fcses013A15Config> configs;
  const Fcses013A15Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Fcses013A15Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('FCSES-013-A15',
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
    Fcses013A15Config(
      configId: 'fcses013a15-cfg-001',
      errorCode: 'fcses-013-a15_errorCode',
      exceptionType: 'fcses-013-a15_exceptionType',
      fallbackRoute: 'fcses-013-a15_fallbackRoute',
      resolvedBy: 'fcses-013-a15_resolvedBy',
      traceId:                 'trace-fcses013a15-001',
      originSourceId:          'origin-fcses013a15',
      immediatePredecessorId:  'pred-fcses013a15-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final result = await Fcses013A15Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('FCSES-013-A15 → $result');
}
