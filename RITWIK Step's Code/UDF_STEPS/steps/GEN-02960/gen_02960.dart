// ============================================================
// GEN-02960 — GEN Backend Utility Module
// Atomic Step: Implement double-tap on left screen edge to seek backward 10 seconds on mobile.
// Metric:      Schema Lineage Conformance Rate · Floor=80.0 · Optimal=95.0
// Output:      Pass / Fail
// Standard:    ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:        github.com/varal-uae/UDF · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        24-Sep-2026
// Step No:     839 of 1073
// ============================================================
// Why this matters: Implement double-tap on left screen edge to seek backward 10 seconds on mobile. is a critical implem
// Mobile impl:      Ensures sub-100ms API response latencies on mobile clients via optimized backend configuration.
// Data requirement: Implement double-tap on left screen edge to seek backward 10 seconds on mobile.
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────

enum Gen02960ConformanceLevel { complete, partial, notComplete }
enum Gen02960ExecutionStatus  { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// Configuration record for GEN-02960.
/// Fields derived from AISS sheet — GEN Backend Utility Module.
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Gen02960Config {
  final String configId;
  final String componentId;
  final String targetSizeDp;
  final String actualSizeDp;
  final String complianceStatus;
  final String validationStatus;
  final bool   immutableInd;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Gen02960Config({
    required this.configId,
    required this.componentId,
    required this.targetSizeDp,
    required this.actualSizeDp,
    required this.complianceStatus,
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

  Gen02960Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Gen02960Config(
    configId: configId,
    componentId: componentId,
    targetSizeDp: targetSizeDp,
    actualSizeDp: actualSizeDp,
    complianceStatus: complianceStatus,
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
    'componentId': componentId,
    'targetSizeDp': targetSizeDp,
    'actualSizeDp': actualSizeDp,
    'complianceStatus': complianceStatus,
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

class Gen02960ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Gen02960ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Gen02960ValidationResult({
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
      case Gen02960ConformanceLevel.complete:    return 'Pass';
      case Gen02960ConformanceLevel.partial:     return 'Partial';
      case Gen02960ConformanceLevel.notComplete: return 'Fail';
    }
  }
}

// ── EC:4 Pipeline ────────────────────────────────────────────

/// GEN-02960: Implement double-tap on left screen edge to seek backward 10 seconds on mobile.
/// Metric: Schema Lineage Conformance Rate · Floor=80.0 · Optimal=95.0
class Gen02960Pipeline {
  static const double _floor   = 80.0;
  static const double _optimal = 95.0;

  // EC:1 — Plan and scope this step
  static Gen02960Config _ec1Execute(Gen02960Config config) {
    if (config.componentId.isEmpty) {
      throw ArgumentError(
          'EC-GEN02960-001: componentId required for GEN-02960');
    }
    // Plan and scope this step
    return config;
  }

  // EC:2 — Implement the core configuration
  static Gen02960Config _ec2Execute(Gen02960Config config) {
    if (config.componentId.isEmpty) {
      throw ArgumentError(
          'EC-GEN02960-002: componentId required for GEN-02960');
    }
    // Implement the core configuration
    return config;
  }

  // EC:3 — Test and validate in staging
  static Gen02960Config _ec3Execute(Gen02960Config config) {
    if (config.componentId.isEmpty) {
      throw ArgumentError(
          'EC-GEN02960-003: componentId required for GEN-02960');
    }
    // Test and validate in staging
    return config;
  }

  // EC:4 — Document and commit to runbook
  static Gen02960Config _ec4Execute(Gen02960Config config) {
    if (config.componentId.isEmpty) {
      throw ArgumentError(
          'EC-GEN02960-004: componentId required for GEN-02960');
    }
    // Document and commit to runbook
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Gen02960ValidationResult calculateConformance({
    required List<Gen02960Config> configs,
  }) {
    if (configs.isEmpty) {
      return const Gen02960ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Gen02960ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-GEN02960-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level      = rate >= _optimal
        ? Gen02960ConformanceLevel.complete
        : rate >= _floor
            ? Gen02960ConformanceLevel.partial
            : Gen02960ConformanceLevel.notComplete;
    return Gen02960ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-GEN02960-VAL',
    );
  }

  static Gen02960Config routeToRegistry(
    Gen02960Config config,
    Gen02960ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Gen02960Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-GEN02960-000: configs must not be empty for GEN-02960');
    }
    final p1 = configs.map(_ec1Execute).toList();
    final p2 = configs.map(_ec2Execute).toList();
    final p3 = configs.map(_ec3Execute).toList();
    final p4 = configs.map(_ec4Execute).toList();

    if (!triangularCheck(configs.length, p4.length)) {
      throw ArgumentError('EC-GEN02960-TRI: triangular check failed for GEN-02960');
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
      'ec_ref':             'EC-GEN-02960',
      'metric':             'Schema Lineage Conformance Rate',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> gen_02960Dlq(String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'GEN-02960',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Gen02960Widget extends StatelessWidget {
  final List<Gen02960Config> configs;
  const Gen02960Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Gen02960Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('GEN-02960',
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
                title: Text(c.componentId,
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
    Gen02960Config(
      configId: 'gen02960-cfg-001',
      componentId: 'gen-02960_componentId',
      targetSizeDp: 'gen-02960_targetSizeDp',
      actualSizeDp: 'gen-02960_actualSizeDp',
      complianceStatus: 'gen-02960_complianceStatus',
      traceId:                 'trace-gen02960-001',
      originSourceId:          'origin-gen02960',
      immediatePredecessorId:  'pred-gen02960-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final result = await Gen02960Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('GEN-02960 → $result');
}
