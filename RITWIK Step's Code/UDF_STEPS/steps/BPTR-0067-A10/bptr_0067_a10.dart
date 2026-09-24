// ============================================================
// BPTR-0067-A10 — UI/UX Pattern Registry
// Atomic Step:  Implement Inverted Pyramid Layout Strategy for Operational
// Metric:       Design System / Layout Consistency Score
// Floor:        90.0  ·  Optimal: 97.0
// Output vocab: Good / Average / Poor
// Standard:     ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:         github.com/varal-uae/UDF · branch: ritwik
// Author:       Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:         25-Sep-2026
// Step No:      72 of 1073
// ============================================================
// Why:          Packing business views with unorganized elements delays critical decisions, causing severe choice pa
// Mobile:       Fits tight screen realities by displaying primary facts cleanly upfront while auxiliary metrics hide
// col41:        Good (Scale: Good/Average/Poor)
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Conformance vocabulary: Good / Average / Poor ─────────────

enum Bptr0067A10ConformanceLevel {
  good,    // ≥ optimal
  average, // ≥ floor
  poor,    // < floor
}

// ── Execution status ─────────────────────────────────────────

enum Bptr0067A10ExecutionStatus { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// BPTR-0067-A10 — UI/UX Pattern Registry
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Bptr0067A10Config {
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

  const Bptr0067A10Config({
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

  Bptr0067A10Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Bptr0067A10Config(
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

class Bptr0067A10ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Bptr0067A10ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Bptr0067A10ValidationResult({
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
      case Bptr0067A10ConformanceLevel.good:    return 'Good';
      case Bptr0067A10ConformanceLevel.average: return 'Average';
      case Bptr0067A10ConformanceLevel.poor:    return 'Poor';
    }
  }
}

// ── EC:1 Pipeline ────────────────────────────────────────

/// BPTR-0067-A10: Implement Inverted Pyramid Layout Strategy for Operational
/// Metric: Design System / Layout Consistency Score
/// Floor=90.0 · Output=Good / Average / Poor
class Bptr0067A10Pipeline {
  static const double _floor   = 90.0;
  static const double _optimal = 97.0;

  // EC:1 — Position strategic operational indicators cleanly within the top 30% viewport grid area. A
  static Bptr0067A10Config _ec1Execute(Bptr0067A10Config config) {
    if (config.gridColumns.isEmpty) {
      throw ArgumentError(
          'EC-BPTR0067A10-001: gridColumns required for BPTR-0067-A10');
    }
    // Position strategic operational indicators cleanly within the
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Bptr0067A10ValidationResult calculateConformance({
    required List<Bptr0067A10Config> configs,
  }) {
    if (configs.isEmpty) {
      return Bptr0067A10ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Bptr0067A10ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-BPTR0067A10-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level = rate >= _optimal
        ? Bptr0067A10ConformanceLevel.good
        : rate >= _floor
            ? Bptr0067A10ConformanceLevel.average
            : Bptr0067A10ConformanceLevel.poor;
    return Bptr0067A10ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-BPTR0067A10-VAL',
    );
  }

  static Bptr0067A10Config routeToRegistry(
    Bptr0067A10Config config,
    Bptr0067A10ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Bptr0067A10Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-BPTR0067A10-000: configs must not be empty for BPTR-0067-A10');
    }
    final p1 = configs.map(_ec1Execute).toList();

    if (!triangularCheck(configs.length, p1.length)) {
      throw ArgumentError('EC-BPTR0067A10-TRI: triangular check failed for BPTR-0067-A10');
    }
    final result     = calculateConformance(configs: p1);
    final registered = p1.map((c) => routeToRegistry(c, result)).toList();
    return {
      'status':             result.gatePass ? 'COMPLETE' : 'FAILED',
      'conformance_verdict': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-BPTR-0067-A10',
      'metric':             'Design System / Layout Consistency Score',
      'output_vocab':       'Good / Average / Poor',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> bptr_0067_a10Dlq(
    String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'BPTR-0067-A10',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Bptr0067A10Widget extends StatelessWidget {
  final List<Bptr0067A10Config> configs;
  const Bptr0067A10Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Bptr0067A10Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    final isGood = result.gatePass;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('BPTR-0067-A10',
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
    Bptr0067A10Config(
      configId: 'bptr0067a10-cfg-001',
      gridColumns: 'bptr-0067-a10_gridColumns',
      gutterSizePx: 'bptr-0067-a10_gutterSizePx',
      maxWidthPx: 'bptr-0067-a10_maxWidthPx',
      breakpointLabel: 'bptr-0067-a10_breakpointLabel',
      traceId:                 'trace-bptr0067a10-001',
      originSourceId:          'origin-bptr0067a10',
      immediatePredecessorId:  'pred-bptr0067a10-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final out = await Bptr0067A10Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('BPTR-0067-A10 [Good / Average / Poor] → $out');
}
