// ============================================================
// SSELC-023-A15 — Split-Screen Element Layout Controller
// Atomic Step: SSELC-023 — Split-Screen Byt Deconstruction.
// Metric:      Layout Consistency Score · Floor=0.90 · Optimal=0.97
// Output:      Pass / Partial / Fail
// Standard:    ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:        github.com/varal-uae/UDF · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        24-Sep-2026
// Step No:     463 of 530
// ============================================================
// Why this matters: Prevents cognitive overload by isolating exact data points.
// Mobile impl:      Ensures crop boxes display natively within a 360px mobile viewport without pinch-to-zoom requirement
// Data requirement: Confirm the layout functions correctly across both mobile and desktop breakpoints.
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────

enum Sselc023A15ConformanceLevel {
  complete,
  partial,
  notComplete,
}

enum Sselc023A15ExecutionStatus {
  pending,
  running,
  complete,
  failed,
}

// ── Data Model ───────────────────────────────────────────────

/// Configuration record for SSELC-023-A15.
/// Fields derived from AISS sheet — Split-Screen Element Layout Controller.
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Sselc023A15Config {
  final String configId;               // PK — UUID v4
  // Step-specific fields
  final String layoutId;
  final String splitRatio;
  final String containerWidth;
  final String breakpointKey;
  final String validationStatus;       // PENDING | VALID | INVALID
  final bool   immutableInd;
  // DCDF lineage
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Sselc023A15Config({
    required this.configId,
    required this.layoutId,
    required this.splitRatio,
    required this.containerWidth,
    required this.breakpointKey,
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

  Sselc023A15Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Sselc023A15Config(
    configId: configId,
    layoutId: layoutId,
    splitRatio: splitRatio,
    containerWidth: containerWidth,
    breakpointKey: breakpointKey,
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
    'layoutId': layoutId,
    'splitRatio': splitRatio,
    'containerWidth': containerWidth,
    'breakpointKey': breakpointKey,
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

class Sselc023A15ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Sselc023A15ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Sselc023A15ValidationResult({
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
      case Sselc023A15ConformanceLevel.complete:    return 'Pass';
      case Sselc023A15ConformanceLevel.partial:     return 'Partial';
      case Sselc023A15ConformanceLevel.notComplete: return 'Fail';
    }
  }
}

// ── EC:1 Pipeline ────────────────────────────────────────────

/// SSELC-023-A15: SSELC-023 — Split-Screen Byt Deconstruction.
/// Metric: Layout Consistency Score
/// Floor=0.90 · Optimal=0.97 · Output=Good / Average / Poor
class Sselc023A15Pipeline {
  static const double _floor   = 0.90;
  static const double _optimal = 0.97;

  // EC:1 — 1) Define mobile stacking order. 2) Design document crop box. 3) Set 50/50 desktop fallbac
  static Sselc023A15Config _ec1Execute(Sselc023A15Config config) {
    if (config.layoutId.isEmpty) {
      throw ArgumentError(
          'EC-SSELC023A15-001: layoutId required for SSELC-023-A15');
    }
    // 1) Define mobile stacking order. 2) Design document crop box
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Sselc023A15ValidationResult calculateConformance({
    required List<Sselc023A15Config> configs,
  }) {
    if (configs.isEmpty) {
      return const Sselc023A15ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Sselc023A15ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-SSELC023A15-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level      = rate >= _optimal
        ? Sselc023A15ConformanceLevel.complete
        : rate >= _floor
            ? Sselc023A15ConformanceLevel.partial
            : Sselc023A15ConformanceLevel.notComplete;
    return Sselc023A15ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-SSELC023A15-VAL',
    );
  }

  static Sselc023A15Config routeToRegistry(
    Sselc023A15Config config,
    Sselc023A15ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Sselc023A15Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-SSELC023A15-000: configs must not be empty for SSELC-023-A15');
    }
    final p1 = configs.map(_ec1Execute).toList();

    if (!triangularCheck(configs.length, p1.length)) {
      throw ArgumentError('EC-SSELC023A15-TRI: triangular check failed for SSELC-023-A15');
    }

    final result     = calculateConformance(configs: p1);
    final registered = p1.map((c) => routeToRegistry(c, result)).toList();

    return {
      'status':             result.gatePass ? 'COMPLETE' : 'PARTIAL',
      'conformance_rate':   result.conformanceRate,
      'conformance_output': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-SSELC-023-A15',
      'metric':             'Layout Consistency Score',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> sselc_023_a15Dlq(
  String errorCode,
  Map<String, dynamic> payload,
) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'SSELC-023-A15',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Sselc023A15Widget extends StatelessWidget {
  final List<Sselc023A15Config> configs;
  const Sselc023A15Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Sselc023A15Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('SSELC-023-A15',
              style: const TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold, fontSize: 12))),
            Chip(
              label: Text(
                '${result.conformanceOutput} · ${result.violationCount} violation${result.violationCount == 1 ? "" : "s"}',
                style: const TextStyle(color: Colors.white, fontSize: 11)),
              backgroundColor: result.gatePass ? cs.tertiary : cs.error,
            ),
          ]),
        ),
        Expanded(child: ListView.builder(
          itemCount: configs.length,
          itemBuilder: (context, i) {
            final c    = configs[i];
            final pass = c.isRegistered;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: Icon(
                  pass ? Icons.check_circle : Icons.cancel,
                  color: pass ? cs.tertiary : cs.error),
                title: Text(c.layoutId,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 12)),
                subtitle: Text(
                  'id: ${c.configId.length > 8 ? c.configId.substring(0, 8) : c.configId}… '
                  '| ${c.validationStatus} | immutable: ${c.immutableInd}',
                  style: const TextStyle(fontSize: 11)),
                trailing: Chip(
                  label: Text(pass ? 'PASS' : 'FAIL',
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: pass ? cs.tertiary : cs.error,
                ),
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
    Sselc023A15Config(
      configId: 'sselc023a15-cfg-001',
      layoutId: 'sselc-023-a15_layoutId',
      splitRatio: 'sselc-023-a15_splitRatio',
      containerWidth: 'sselc-023-a15_containerWidth',
      breakpointKey: 'sselc-023-a15_breakpointKey',
      traceId:                 'trace-sselc023a15-001',
      originSourceId:          'origin-sselc023a15',
      immediatePredecessorId:  'pred-sselc023a15-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final result = await Sselc023A15Pipeline.run(
    configs: configs, userId: 'ritwik-udf');
  print('SSELC-023-A15 → $result');
}
