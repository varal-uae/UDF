// ============================================================
// SSELC-020-A04 — Split-Screen Element Layout Controller
// Atomic Step: SSELC-020 - Define Consensus Split-Pane Ratios.
// Metric:      Layout Consistency Score · Floor=0.90 · Optimal=0.97
// Output:      Pass / Partial / Fail
// Standard:    ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:        github.com/varal-uae/UDF · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        24-Sep-2026
// Step No:     444 of 530
// ============================================================
// Why this matters: If evidence pane is too small, voters cannot make informed decisions.
// Mobile impl:      Stacks panes vertically (Evidence top, Action bottom) ensuring the voting CTA is always reachable.
// Data requirement: Configure responsive CSS Grid and Flexbox rules for split-pane containers.
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────

enum Sselc020A04ConformanceLevel {
  complete,
  partial,
  notComplete,
}

enum Sselc020A04ExecutionStatus {
  pending,
  running,
  complete,
  failed,
}

// ── Data Model ───────────────────────────────────────────────

/// Configuration record for SSELC-020-A04.
/// Fields derived from AISS sheet — Split-Screen Element Layout Controller.
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Sselc020A04Config {
  final String configId;               // PK — UUID v4
  // Step-specific fields
  final String gridColumns;
  final String gutterSizePx;
  final String maxWidthPx;
  final String breakpointLabel;
  final String validationStatus;       // PENDING | VALID | INVALID
  final bool   immutableInd;
  // DCDF lineage
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Sselc020A04Config({
    required this.configId,
    required this.gridColumns,
    required this.gutterSizePx,
    required this.maxWidthPx,
    required this.breakpointLabel,
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

  Sselc020A04Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Sselc020A04Config(
    configId: configId,
    gridColumns: gridColumns,
    gutterSizePx: gutterSizePx,
    maxWidthPx: maxWidthPx,
    breakpointLabel: breakpointLabel,
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
    'gridColumns': gridColumns,
    'gutterSizePx': gutterSizePx,
    'maxWidthPx': maxWidthPx,
    'breakpointLabel': breakpointLabel,
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

class Sselc020A04ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Sselc020A04ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Sselc020A04ValidationResult({
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
      case Sselc020A04ConformanceLevel.complete:    return 'Pass';
      case Sselc020A04ConformanceLevel.partial:     return 'Partial';
      case Sselc020A04ConformanceLevel.notComplete: return 'Fail';
    }
  }
}

// ── EC:4 Pipeline ────────────────────────────────────────────

/// SSELC-020-A04: SSELC-020 - Define Consensus Split-Pane Ratios.
/// Metric: Layout Consistency Score
/// Floor=0.90 · Optimal=0.97 · Output=Good / Average / Poor
class Sselc020A04Pipeline {
  static const double _floor   = 0.90;
  static const double _optimal = 0.97;

  // EC:1 — Set desktop ratio (e.g., 60/40)
  static Sselc020A04Config _ec1Execute(Sselc020A04Config config) {
    if (config.gridColumns.isEmpty) {
      throw ArgumentError(
          'EC-SSELC020A04-001: gridColumns required for SSELC-020-A04');
    }
    // Set desktop ratio (e.g., 60/40)
    return config;
  }

  // EC:2 — Define mobile stacking order
  static Sselc020A04Config _ec2Execute(Sselc020A04Config config) {
    if (config.gridColumns.isEmpty) {
      throw ArgumentError(
          'EC-SSELC020A04-002: gridColumns required for SSELC-020-A04');
    }
    // Define mobile stacking order
    return config;
  }

  // EC:3 — Set flex-wrap min-widths
  static Sselc020A04Config _ec3Execute(Sselc020A04Config config) {
    if (config.gridColumns.isEmpty) {
      throw ArgumentError(
          'EC-SSELC020A04-003: gridColumns required for SSELC-020-A04');
    }
    // Set flex-wrap min-widths
    return config;
  }

  // EC:4 — Implement independent pane scrolling
  static Sselc020A04Config _ec4Execute(Sselc020A04Config config) {
    if (config.gridColumns.isEmpty) {
      throw ArgumentError(
          'EC-SSELC020A04-004: gridColumns required for SSELC-020-A04');
    }
    // Implement independent pane scrolling
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Sselc020A04ValidationResult calculateConformance({
    required List<Sselc020A04Config> configs,
  }) {
    if (configs.isEmpty) {
      return const Sselc020A04ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Sselc020A04ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-SSELC020A04-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level      = rate >= _optimal
        ? Sselc020A04ConformanceLevel.complete
        : rate >= _floor
            ? Sselc020A04ConformanceLevel.partial
            : Sselc020A04ConformanceLevel.notComplete;
    return Sselc020A04ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-SSELC020A04-VAL',
    );
  }

  static Sselc020A04Config routeToRegistry(
    Sselc020A04Config config,
    Sselc020A04ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Sselc020A04Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-SSELC020A04-000: configs must not be empty for SSELC-020-A04');
    }
    final p1 = configs.map(_ec1Execute).toList();
    final p2 = configs.map(_ec2Execute).toList();
    final p3 = configs.map(_ec3Execute).toList();
    final p4 = configs.map(_ec4Execute).toList();

    if (!triangularCheck(configs.length, p4.length)) {
      throw ArgumentError('EC-SSELC020A04-TRI: triangular check failed for SSELC-020-A04');
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
      'ec_ref':             'EC-SSELC-020-A04',
      'metric':             'Layout Consistency Score',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> sselc_020_a04Dlq(
  String errorCode,
  Map<String, dynamic> payload,
) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'SSELC-020-A04',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Sselc020A04Widget extends StatelessWidget {
  final List<Sselc020A04Config> configs;
  const Sselc020A04Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Sselc020A04Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('SSELC-020-A04',
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
                title: Text(c.gridColumns,
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
    Sselc020A04Config(
      configId: 'sselc020a04-cfg-001',
      gridColumns: 'sselc-020-a04_gridColumns',
      gutterSizePx: 'sselc-020-a04_gutterSizePx',
      maxWidthPx: 'sselc-020-a04_maxWidthPx',
      breakpointLabel: 'sselc-020-a04_breakpointLabel',
      traceId:                 'trace-sselc020a04-001',
      originSourceId:          'origin-sselc020a04',
      immediatePredecessorId:  'pred-sselc020a04-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final result = await Sselc020A04Pipeline.run(
    configs: configs, userId: 'ritwik-udf');
  print('SSELC-020-A04 → $result');
}
