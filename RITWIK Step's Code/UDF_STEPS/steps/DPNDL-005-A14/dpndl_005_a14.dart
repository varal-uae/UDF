// ============================================================
// DPNDL-005-A14 — Dynamic Panel Navigation Display Layer
// Atomic Step:  Build Permanent Sidebar Brand Title.
// Metric:       Validation / QA Pass Rate (%)
// Floor:        0.95  ·  Optimal: 0.95
// Output vocab: Pass / Fail
// Standard:     ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:         github.com/varal-uae/UDF · branch: ritwik
// Author:       Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:         25-Sep-2026
// Step No:      173 of 1073
// ============================================================
// Why:          Establishes a predictable, high-visibility branding anchor on large desktop views.
// Mobile:       Completely hidden on mobile to maximize screen room for active text fields.
// col41:        Pass/Fail
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Conformance vocabulary: Pass / Fail ─────────────

enum Dpndl005A14ConformanceLevel {
  pass_,   // ≥ floor
  fail_,   // < floor
}

// ── Execution status ─────────────────────────────────────────

enum Dpndl005A14ExecutionStatus { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// DPNDL-005-A14 — Dynamic Panel Navigation Display Layer
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Dpndl005A14Config {
  final String configId;
  final String gridColumns;
  final String gutterSizePx;
  final String maxWidthPx;
  final String breakpointLabel;
  final String validationStatus;
  final bool   immutableInd;
  // DCDF lineage
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Dpndl005A14Config({
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

  Dpndl005A14Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Dpndl005A14Config(
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

class Dpndl005A14ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Dpndl005A14ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Dpndl005A14ValidationResult({
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
      case Dpndl005A14ConformanceLevel.pass_: return 'Pass';
      case Dpndl005A14ConformanceLevel.fail_: return 'Fail';
    }
  }
}

// ── EC:1 Pipeline ────────────────────────────────────────

/// DPNDL-005-A14: Build Permanent Sidebar Brand Title.
/// Metric: Validation / QA Pass Rate (%)
/// Floor=0.95 · Output=Pass / Fail
class Dpndl005A14Pipeline {
  static const double _floor   = 0.95;
  static const double _optimal = 0.95;

  // EC:1 — Allocate absolute grid tracks across top zones of long desktop menus. Inject crisp vector 
  static Dpndl005A14Config _ec1Execute(Dpndl005A14Config config) {
    if (config.gridColumns.isEmpty) {
      throw ArgumentError(
          'EC-DPNDL005A14-001: gridColumns required for DPNDL-005-A14');
    }
    // Allocate absolute grid tracks across top zones of long deskt
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Dpndl005A14ValidationResult calculateConformance({
    required List<Dpndl005A14Config> configs,
  }) {
    if (configs.isEmpty) {
      return Dpndl005A14ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Dpndl005A14ConformanceLevel.fail_,
        gatePass: false, ecLineRef: 'EC-DPNDL005A14-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level = rate >= _floor
        ? Dpndl005A14ConformanceLevel.pass_
        : Dpndl005A14ConformanceLevel.fail_;
    return Dpndl005A14ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-DPNDL005A14-VAL',
    );
  }

  static Dpndl005A14Config routeToRegistry(
    Dpndl005A14Config config,
    Dpndl005A14ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Dpndl005A14Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-DPNDL005A14-000: configs must not be empty for DPNDL-005-A14');
    }
    final p1 = configs.map(_ec1Execute).toList();

    if (!triangularCheck(configs.length, p1.length)) {
      throw ArgumentError('EC-DPNDL005A14-TRI: triangular check failed for DPNDL-005-A14');
    }
    final result     = calculateConformance(configs: p1);
    final registered = p1.map((c) => routeToRegistry(c, result)).toList();
    return {
      'status':             result.gatePass ? 'COMPLETE' : 'FAILED',
      'conformance_verdict': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-DPNDL-005-A14',
      'metric':             'Validation / QA Pass Rate (%)',
      'output_vocab':       'Pass / Fail',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> dpndl_005_a14Dlq(
    String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'DPNDL-005-A14',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Dpndl005A14Widget extends StatelessWidget {
  final List<Dpndl005A14Config> configs;
  const Dpndl005A14Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Dpndl005A14Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    final isGood = result.gatePass;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('DPNDL-005-A14',
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
                title: Text(c.gridColumns,
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
    Dpndl005A14Config(
      configId: 'dpndl005a14-cfg-001',
      gridColumns: 'dpndl-005-a14_gridColumns',
      gutterSizePx: 'dpndl-005-a14_gutterSizePx',
      maxWidthPx: 'dpndl-005-a14_maxWidthPx',
      breakpointLabel: 'dpndl-005-a14_breakpointLabel',
      traceId:                 'trace-dpndl005a14-001',
      originSourceId:          'origin-dpndl005a14',
      immediatePredecessorId:  'pred-dpndl005a14-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final out = await Dpndl005A14Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('DPNDL-005-A14 [Pass / Fail] → $out');
}
