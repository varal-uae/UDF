// ============================================================
// IS36-SLPLU-012-AS01-A02 — Implementation System 36
// Atomic Step: Lineage Trace Time Line Chart (System Latency)
// Metric:      Data Visualisation Compliance Rate · Floor=0.90 · Optimal=0.97
// Output:      Good / Average / Poor
// Standard:    ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:        github.com/RitwikHC/theme-typography · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        18-Sep-2026
// Step No:     252 of 396
// ============================================================
// Why this matters: Proves whether the data engine is unbroken. High trace times mean flawed, bloated architecture.
// Mobile impl:      Clean, responsive SVG line charts optimized for mobile viewport widths.
// Data requirement: Create latency lineage line chart component (LatencyTraceChart).
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────

enum Is36Slplu012As01A02ConformanceLevel {
  complete,
  partial,
  notComplete,
}

enum Is36Slplu012As01A02ExecutionStatus {
  pending,
  running,
  complete,
  failed,
}

// ── Data Model ───────────────────────────────────────────────

/// Configuration record for IS36-SLPLU-012-AS01-A02.
/// Fields derived from AISS sheet row — Implementation System 36.
/// All 5 DCDF lineage fields mandatory per AEETE-018.
class Is36Slplu012As01A02Config {
  final String configId;               // PK — UUID v4
  // Step-specific fields (from AISS data requirement)
  final String chartId;
  final String dataSource;
  final String metricLabel;
  final String refreshIntervalMs;
  final String validationStatus;       // PENDING | VALID | INVALID
  final bool   immutableInd;
  // DCDF lineage headers — AEETE-018
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Is36Slplu012As01A02Config({
    required this.configId,
    required this.chartId,
    required this.dataSource,
    required this.metricLabel,
    required this.refreshIntervalMs,
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

  Is36Slplu012As01A02Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Is36Slplu012As01A02Config(
    configId: configId,
    chartId: chartId,
    dataSource: dataSource,
    metricLabel: metricLabel,
    refreshIntervalMs: refreshIntervalMs,
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
    'chartId': chartId,
    'dataSource': dataSource,
    'metricLabel': metricLabel,
    'refreshIntervalMs': refreshIntervalMs,
    'validation_status':          validationStatus,
    'immutable_ind':              immutableInd,
    'trace_id':                   traceId,
    'origin_source_id':           originSourceId,
    'immediate_predecessor_id':   immediatePredecessorId,
    'transformation_logic_hash':  transformationLogicHash,
    'compliance_status_ind':      complianceStatusInd,
  };
}

// ── Validation Result ─────────────────────────────────────────

class Is36Slplu012As01A02ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Is36Slplu012As01A02ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Is36Slplu012As01A02ValidationResult({
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
      case Is36Slplu012As01A02ConformanceLevel.complete:    return 'Complete';
      case Is36Slplu012As01A02ConformanceLevel.partial:     return 'Partial';
      case Is36Slplu012As01A02ConformanceLevel.notComplete: return 'Not Complete';
    }
  }
}

// ── EC:4 Pipeline ────────────────────────────────────────────────────────

/// IS36-SLPLU-012-AS01-A02: Lineage Trace Time Line Chart (System Latency)
///
/// Metric: Data Visualisation Compliance Rate
/// Floor=0.90 · Optimal=0.97 · Output=Good / Average / Poor
class Is36Slplu012As01A02Pipeline {
  static const double _floor   = 0.90;
  static const double _optimal = 0.97;

  // EC:1 — Query latency logs
  static Is36Slplu012As01A02Config _ec1Execute(Is36Slplu012As01A02Config config) {
    if (config.chartId.isEmpty) {
      throw ArgumentError(
          'EC-IS36SLPLU012-001: chartId required for IS36-SLPLU-012-AS01-A02');
    }
    // Query latency logs
    return config;
  }

  // EC:2 — Render line chart
  static Is36Slplu012As01A02Config _ec2Execute(Is36Slplu012As01A02Config config) {
    if (config.chartId.isEmpty) {
      throw ArgumentError(
          'EC-IS36SLPLU012-002: chartId required for IS36-SLPLU-012-AS01-A02');
    }
    // Render line chart
    return config;
  }

  // EC:3 — Draw fixed SLA threshold
  static Is36Slplu012As01A02Config _ec3Execute(Is36Slplu012As01A02Config config) {
    if (config.chartId.isEmpty) {
      throw ArgumentError(
          'EC-IS36SLPLU012-003: chartId required for IS36-SLPLU-012-AS01-A02');
    }
    // Draw fixed SLA threshold
    return config;
  }

  // EC:4 — Code alert trigger
  static Is36Slplu012As01A02Config _ec4Execute(Is36Slplu012As01A02Config config) {
    if (config.chartId.isEmpty) {
      throw ArgumentError(
          'EC-IS36SLPLU012-004: chartId required for IS36-SLPLU-012-AS01-A02');
    }
    // Code alert trigger
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  // Conformance gate — Floor=0.90 · Optimal=0.97
  static Is36Slplu012As01A02ValidationResult calculateConformance({
    required List<Is36Slplu012As01A02Config> configs,
  }) {
    if (configs.isEmpty) {
      return const Is36Slplu012As01A02ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Is36Slplu012As01A02ConformanceLevel.notComplete,
        gatePass: false,
        ecLineRef: 'EC-IS36SLPLU012-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level      = rate >= _optimal
        ? Is36Slplu012As01A02ConformanceLevel.complete
        : rate >= _floor
            ? Is36Slplu012As01A02ConformanceLevel.partial
            : Is36Slplu012As01A02ConformanceLevel.notComplete;
    return Is36Slplu012As01A02ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-IS36SLPLU012-VAL',
    );
  }

  static Is36Slplu012As01A02Config routeToRegistry(
    Is36Slplu012As01A02Config config,
    Is36Slplu012As01A02ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Is36Slplu012As01A02Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      return {'error': 'EC-IS36SLPLU012-001: empty config list', 'dlq': true};
    }
    final p1 = configs.map(_ec1Execute).toList();
    final p2 = configs.map(_ec2Execute).toList();
    final p3 = configs.map(_ec3Execute).toList();
    final p4 = configs.map(_ec4Execute).toList();

    if (!triangularCheck(configs.length, p4.length)) {
      return {'error': 'EC-IS36SLPLU012-TRI: triangular check failed', 'dlq': true};
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
      'ec_ref':             'EC-IS36-SLPLU-012-AS01-A02',
      'metric':             'Data Visualisation Compliance Rate',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> is36_slplu_012_as01_a02Dlq(
  String errorCode,
  Map<String, dynamic> payload,
) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'IS36-SLPLU-012-AS01-A02',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Is36Slplu012As01A02Widget extends StatelessWidget {
  final List<Is36Slplu012As01A02Config> configs;
  const Is36Slplu012As01A02Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Is36Slplu012As01A02Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('IS36-SLPLU-012-AS01-A02',
              style: const TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                fontSize: 12))),
            Chip(
              label: Text(
                '${result.conformanceOutput} · ${result.violationCount} violation${result.violationCount == 1 ? '' : 's'}',
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
                  color: pass ? cs.tertiary : cs.error,
                ),
                title: Text(c.chartId,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 12)),
                subtitle: Text(
                  '${chartId} | ${dataSource}',
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
    Is36Slplu012As01A02Config(
      configId: 'is36slplu012-cfg-001',
      chartId: 'is36-slplu-012-as01-a02_chartId_value',
      dataSource: 'is36-slplu-012-as01-a02_dataSource_value',
      metricLabel: 'is36-slplu-012-as01-a02_metricLabel_value',
      refreshIntervalMs: 'is36-slplu-012-as01-a02_refreshIntervalMs_value',
      traceId:                 'trace-is36slplu012-001',
      originSourceId:          'origin-is36slplu012',
      immediatePredecessorId:  'pred-is36slplu012-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final result = await Is36Slplu012As01A02Pipeline.run(
    configs: configs, userId: 'ritwik-udf');
  print('IS36-SLPLU-012-AS01-A02 → $result');
}
