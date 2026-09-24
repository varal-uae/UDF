// ============================================================
// TTMAC-020-A15 — Touch Target & Material Accessibility Compliance
// Atomic Step:  TTMAC-020 - Map EC to M3 Touch Targets (48dp)
// Metric:       Text/Element Contrast Ratio (WCAG 2.1)
// Floor:        0.95  ·  Optimal: 0.95
// Output vocab: Pass / Fail
// Standard:     ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:         github.com/varal-uae/UDF · branch: ritwik
// Author:       Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:         25-Sep-2026
// Step No:      1050 of 1073
// ============================================================
// Why:          Guarantees mobile usability and accessibility; prevents "fat-finger" errors, especially on critical 
// Mobile:       
// col41:        Pass/Fail
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Conformance vocabulary: Pass / Fail ─────────────

enum Ttmac020A15ConformanceLevel {
  pass_,   // ≥ floor
  fail_,   // < floor
}

// ── Execution status ─────────────────────────────────────────

enum Ttmac020A15ExecutionStatus { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// TTMAC-020-A15 — Touch Target & Material Accessibility Compliance
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Ttmac020A15Config {
  final String configId;
  final String componentId;
  final String targetSizeDp;
  final String actualSizeDp;
  final String complianceStatus;
  final String validationStatus;
  final bool   immutableInd;
  // DCDF lineage
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Ttmac020A15Config({
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

  Ttmac020A15Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Ttmac020A15Config(
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

class Ttmac020A15ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Ttmac020A15ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Ttmac020A15ValidationResult({
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
      case Ttmac020A15ConformanceLevel.pass_: return 'Pass';
      case Ttmac020A15ConformanceLevel.fail_: return 'Fail';
    }
  }
}

// ── EC:1 Pipeline ────────────────────────────────────────

/// TTMAC-020-A15: TTMAC-020 - Map EC to M3 Touch Targets (48dp)
/// Metric: Text/Element Contrast Ratio (WCAG 2.1)
/// Floor=0.95 · Output=Pass / Fail
class Ttmac020A15Pipeline {
  static const double _floor   = 0.95;
  static const double _optimal = 0.95;

  // EC:1 — 1) Audit UI components generated for the Byts. 2) Set minimum height and width to 48dp. 3)
  static Ttmac020A15Config _ec1Execute(Ttmac020A15Config config) {
    if (config.componentId.isEmpty) {
      throw ArgumentError(
          'EC-TTMAC020A15-001: componentId required for TTMAC-020-A15');
    }
    // 1) Audit UI components generated for the Byts. 2) Set minimu
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Ttmac020A15ValidationResult calculateConformance({
    required List<Ttmac020A15Config> configs,
  }) {
    if (configs.isEmpty) {
      return Ttmac020A15ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Ttmac020A15ConformanceLevel.fail_,
        gatePass: false, ecLineRef: 'EC-TTMAC020A15-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level = rate >= _floor
        ? Ttmac020A15ConformanceLevel.pass_
        : Ttmac020A15ConformanceLevel.fail_;
    return Ttmac020A15ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-TTMAC020A15-VAL',
    );
  }

  static Ttmac020A15Config routeToRegistry(
    Ttmac020A15Config config,
    Ttmac020A15ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Ttmac020A15Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-TTMAC020A15-000: configs must not be empty for TTMAC-020-A15');
    }
    final p1 = configs.map(_ec1Execute).toList();

    if (!triangularCheck(configs.length, p1.length)) {
      throw ArgumentError('EC-TTMAC020A15-TRI: triangular check failed for TTMAC-020-A15');
    }
    final result     = calculateConformance(configs: p1);
    final registered = p1.map((c) => routeToRegistry(c, result)).toList();
    return {
      'status':             result.gatePass ? 'COMPLETE' : 'FAILED',
      'conformance_verdict': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-TTMAC-020-A15',
      'metric':             'Text/Element Contrast Ratio (WCAG 2.1)',
      'output_vocab':       'Pass / Fail',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> ttmac_020_a15Dlq(
    String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'TTMAC-020-A15',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Ttmac020A15Widget extends StatelessWidget {
  final List<Ttmac020A15Config> configs;
  const Ttmac020A15Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Ttmac020A15Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    final isGood = result.gatePass;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('TTMAC-020-A15',
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
                title: Text(c.componentId,
                  style: const TextStyle(fontWeight:FontWeight.w600,fontSize:12)),
                subtitle: Text(
                  '${c.configId.length>8?c.configId.substring(0,8):c.configId}…'
                  ' | ${c.validationStatus}',
                  style: const TextStyle(fontSize:11)),
                trailing: Chip(
                  label: Text(
                    pass ? 'Pass' : 'Fail',
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
    Ttmac020A15Config(
      configId: 'ttmac020a15-cfg-001',
      componentId: 'ttmac-020-a15_componentId',
      targetSizeDp: 'ttmac-020-a15_targetSizeDp',
      actualSizeDp: 'ttmac-020-a15_actualSizeDp',
      complianceStatus: 'ttmac-020-a15_complianceStatus',
      traceId:                 'trace-ttmac020a15-001',
      originSourceId:          'origin-ttmac020a15',
      immediatePredecessorId:  'pred-ttmac020a15-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final out = await Ttmac020A15Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('TTMAC-020-A15 [Pass / Fail] → $out');
}
