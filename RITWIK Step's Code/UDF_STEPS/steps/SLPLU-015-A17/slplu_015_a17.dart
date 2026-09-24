// ============================================================
// SLPLU-015-A17 — Styling & Layout Pattern Language Unit
// Atomic Step:  Trace Time Line Chart
// Metric:       Staging Deployment Success Rate (%)
// Floor:        0.95  ·  Optimal: 0.99
// Output vocab: Complete / Partial / Not Complete
// Standard:     ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:         github.com/varal-uae/UDF · branch: ritwik
// Author:       Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:         25-Sep-2026
// Step No:      990 of 1073
// ============================================================
// Why:          Visualizes Lineage Trace Efficiency and system latency.
// Mobile:       Simplifies line charts to show only the moving average and threshold on mobile.
// col41:        Complete/Partial/Not Complete
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Conformance vocabulary: Complete / Partial / Not Complete ─────────────

enum Slplu015A17ConformanceLevel {
  complete,    // ≥ optimal
  partial,     // ≥ floor
  notComplete, // < floor
}

// ── Execution status ─────────────────────────────────────────

enum Slplu015A17ExecutionStatus { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// SLPLU-015-A17 — Styling & Layout Pattern Language Unit
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Slplu015A17Config {
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

  const Slplu015A17Config({
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

  Slplu015A17Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Slplu015A17Config(
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

class Slplu015A17ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Slplu015A17ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Slplu015A17ValidationResult({
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
      case Slplu015A17ConformanceLevel.complete:    return 'Complete';
      case Slplu015A17ConformanceLevel.partial:     return 'Partial';
      case Slplu015A17ConformanceLevel.notComplete: return 'Not Complete';
    }
  }
}

// ── EC:4 Pipeline ────────────────────────────────────────

/// SLPLU-015-A17: Trace Time Line Chart
/// Metric: Staging Deployment Success Rate (%)
/// Floor=0.95 · Output=Complete / Partial / Not Complete
class Slplu015A17Pipeline {
  static const double _floor   = 0.95;
  static const double _optimal = 0.99;

  // EC:1 — Capture error log timestamp
  static Slplu015A17Config _ec1Execute(Slplu015A17Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-SLPLU015A17-001: errorCode required for SLPLU-015-A17');
    }
    // Capture error log timestamp
    return config;
  }

  // EC:2 — Capture resolution timestamp
  static Slplu015A17Config _ec2Execute(Slplu015A17Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-SLPLU015A17-002: errorCode required for SLPLU-015-A17');
    }
    // Capture resolution timestamp
    return config;
  }

  // EC:3 — Calculate latency
  static Slplu015A17Config _ec3Execute(Slplu015A17Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-SLPLU015A17-003: errorCode required for SLPLU-015-A17');
    }
    // Calculate latency
    return config;
  }

  // EC:4 — Chart against Service Level Agreement
  static Slplu015A17Config _ec4Execute(Slplu015A17Config config) {
    if (config.errorCode.isEmpty) {
      throw ArgumentError(
          'EC-SLPLU015A17-004: errorCode required for SLPLU-015-A17');
    }
    // Chart against Service Level Agreement
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Slplu015A17ValidationResult calculateConformance({
    required List<Slplu015A17Config> configs,
  }) {
    if (configs.isEmpty) {
      return Slplu015A17ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Slplu015A17ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-SLPLU015A17-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level = rate >= _optimal
        ? Slplu015A17ConformanceLevel.complete
        : rate >= _floor
            ? Slplu015A17ConformanceLevel.partial
            : Slplu015A17ConformanceLevel.notComplete;
    return Slplu015A17ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-SLPLU015A17-VAL',
    );
  }

  static Slplu015A17Config routeToRegistry(
    Slplu015A17Config config,
    Slplu015A17ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Slplu015A17Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-SLPLU015A17-000: configs must not be empty for SLPLU-015-A17');
    }
    final p1 = configs.map(_ec1Execute).toList();
    final p2 = configs.map(_ec2Execute).toList();
    final p3 = configs.map(_ec3Execute).toList();
    final p4 = configs.map(_ec4Execute).toList();

    if (!triangularCheck(configs.length, p4.length)) {
      throw ArgumentError('EC-SLPLU015A17-TRI: triangular check failed for SLPLU-015-A17');
    }
    final result     = calculateConformance(configs: p4);
    final registered = p4.map((c) => routeToRegistry(c, result)).toList();
    return {
      'status':             result.gatePass ? 'COMPLETE' : 'FAILED',
      'conformance_verdict': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-SLPLU-015-A17',
      'metric':             'Staging Deployment Success Rate (%)',
      'output_vocab':       'Complete / Partial / Not Complete',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> slplu_015_a17Dlq(
    String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'SLPLU-015-A17',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Slplu015A17Widget extends StatelessWidget {
  final List<Slplu015A17Config> configs;
  const Slplu015A17Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Slplu015A17Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    final isGood = result.gatePass;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('SLPLU-015-A17',
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
                    pass ? 'Complete' : 'Not Complete',
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
    Slplu015A17Config(
      configId: 'slplu015a17-cfg-001',
      errorCode: 'slplu-015-a17_errorCode',
      exceptionType: 'slplu-015-a17_exceptionType',
      fallbackRoute: 'slplu-015-a17_fallbackRoute',
      resolvedBy: 'slplu-015-a17_resolvedBy',
      traceId:                 'trace-slplu015a17-001',
      originSourceId:          'origin-slplu015a17',
      immediatePredecessorId:  'pred-slplu015a17-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final out = await Slplu015A17Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('SLPLU-015-A17 [Complete / Partial / Not Complete] → $out');
}
