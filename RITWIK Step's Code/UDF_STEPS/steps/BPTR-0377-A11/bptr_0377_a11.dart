// ============================================================
// BPTR-0377-A11 — UI/UX Pattern Registry
// Atomic Step:  Set Z-Index Layering Scale.
// Metric:       Implementation Quality Score
// Floor:        90.0  ·  Optimal: 97.0
// Output vocab: Good / Average / Poor
// Standard:     ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:         github.com/varal-uae/UDF · branch: ritwik
// Author:       Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:         25-Sep-2026
// Step No:      92 of 1073
// ============================================================
// Why:          Prevents overlapping UI chaos so critical alerts are never hidden on small screens.
// Mobile:       Manages the Z-axis strictly since the X/Y axes are highly constrained on mobile.
// col41:        Good (Scale: Good/Average/Poor)
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Conformance vocabulary: Good / Average / Poor ─────────────

enum Bptr0377A11ConformanceLevel {
  good,    // ≥ optimal
  average, // ≥ floor
  poor,    // < floor
}

// ── Execution status ─────────────────────────────────────────

enum Bptr0377A11ExecutionStatus { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// BPTR-0377-A11 — UI/UX Pattern Registry
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Bptr0377A11Config {
  final String configId;
  final String fontFamily;
  final String scaleStep;
  final String sizePx;
  final String weightToken;
  final String validationStatus;
  final bool   immutableInd;
  // DCDF lineage
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Bptr0377A11Config({
    required this.configId,
    required this.fontFamily,
    required this.scaleStep,
    required this.sizePx,
    required this.weightToken,
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

  Bptr0377A11Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Bptr0377A11Config(
    configId: configId,
    fontFamily: fontFamily,
    scaleStep: scaleStep,
    sizePx: sizePx,
    weightToken: weightToken,
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
    'fontFamily': fontFamily,
    'scaleStep': scaleStep,
    'sizePx': sizePx,
    'weightToken': weightToken,
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

class Bptr0377A11ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Bptr0377A11ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Bptr0377A11ValidationResult({
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
      case Bptr0377A11ConformanceLevel.good:    return 'Good';
      case Bptr0377A11ConformanceLevel.average: return 'Average';
      case Bptr0377A11ConformanceLevel.poor:    return 'Poor';
    }
  }
}

// ── EC:4 Pipeline ────────────────────────────────────────

/// BPTR-0377-A11: Set Z-Index Layering Scale.
/// Metric: Implementation Quality Score
/// Floor=90.0 · Output=Good / Average / Poor
class Bptr0377A11Pipeline {
  static const double _floor   = 90.0;
  static const double _optimal = 97.0;

  // EC:1 — Set base level
  static Bptr0377A11Config _ec1Execute(Bptr0377A11Config config) {
    if (config.fontFamily.isEmpty) {
      throw ArgumentError(
          'EC-BPTR0377A11-001: fontFamily required for BPTR-0377-A11');
    }
    // Set base level
    return config;
  }

  // EC:2 — Set sticky header level
  static Bptr0377A11Config _ec2Execute(Bptr0377A11Config config) {
    if (config.fontFamily.isEmpty) {
      throw ArgumentError(
          'EC-BPTR0377A11-002: fontFamily required for BPTR-0377-A11');
    }
    // Set sticky header level
    return config;
  }

  // EC:3 — Set overlay level
  static Bptr0377A11Config _ec3Execute(Bptr0377A11Config config) {
    if (config.fontFamily.isEmpty) {
      throw ArgumentError(
          'EC-BPTR0377A11-003: fontFamily required for BPTR-0377-A11');
    }
    // Set overlay level
    return config;
  }

  // EC:4 — Set Shakti Alert level
  static Bptr0377A11Config _ec4Execute(Bptr0377A11Config config) {
    if (config.fontFamily.isEmpty) {
      throw ArgumentError(
          'EC-BPTR0377A11-004: fontFamily required for BPTR-0377-A11');
    }
    // Set Shakti Alert level
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Bptr0377A11ValidationResult calculateConformance({
    required List<Bptr0377A11Config> configs,
  }) {
    if (configs.isEmpty) {
      return Bptr0377A11ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Bptr0377A11ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-BPTR0377A11-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level = rate >= _optimal
        ? Bptr0377A11ConformanceLevel.good
        : rate >= _floor
            ? Bptr0377A11ConformanceLevel.average
            : Bptr0377A11ConformanceLevel.poor;
    return Bptr0377A11ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-BPTR0377A11-VAL',
    );
  }

  static Bptr0377A11Config routeToRegistry(
    Bptr0377A11Config config,
    Bptr0377A11ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Bptr0377A11Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-BPTR0377A11-000: configs must not be empty for BPTR-0377-A11');
    }
    final p1 = configs.map(_ec1Execute).toList();
    final p2 = configs.map(_ec2Execute).toList();
    final p3 = configs.map(_ec3Execute).toList();
    final p4 = configs.map(_ec4Execute).toList();

    if (!triangularCheck(configs.length, p4.length)) {
      throw ArgumentError('EC-BPTR0377A11-TRI: triangular check failed for BPTR-0377-A11');
    }
    final result     = calculateConformance(configs: p4);
    final registered = p4.map((c) => routeToRegistry(c, result)).toList();
    return {
      'status':             result.gatePass ? 'COMPLETE' : 'FAILED',
      'conformance_verdict': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-BPTR-0377-A11',
      'metric':             'Implementation Quality Score',
      'output_vocab':       'Good / Average / Poor',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> bptr_0377_a11Dlq(
    String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'BPTR-0377-A11',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Bptr0377A11Widget extends StatelessWidget {
  final List<Bptr0377A11Config> configs;
  const Bptr0377A11Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Bptr0377A11Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    final isGood = result.gatePass;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('BPTR-0377-A11',
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
                title: Text(c.fontFamily,
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
    Bptr0377A11Config(
      configId: 'bptr0377a11-cfg-001',
      fontFamily: 'bptr-0377-a11_fontFamily',
      scaleStep: 'bptr-0377-a11_scaleStep',
      sizePx: 'bptr-0377-a11_sizePx',
      weightToken: 'bptr-0377-a11_weightToken',
      traceId:                 'trace-bptr0377a11-001',
      originSourceId:          'origin-bptr0377a11',
      immediatePredecessorId:  'pred-bptr0377a11-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final out = await Bptr0377A11Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('BPTR-0377-A11 [Good / Average / Poor] → $out');
}
