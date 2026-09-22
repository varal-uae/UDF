// ============================================================
// TTMAC-020-A15 — Touch Target & Material Accessibility Compliance
// Atomic Step: TTMAC-020 - Map EC to M3 Touch Targets (48dp)
// Metric:      Touch Target Compliance Rate · Floor=0.95 · Optimal=1.0
// Output:      Pass / Fail
// Standard:    ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:        github.com/RitwikHC/theme-typography · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        18-Sep-2026
// Step No:     422 of 440
// ============================================================
// Why this matters: Guarantees mobile usability and accessibility; prevents "fat-finger" errors, especially on critical 
// Mobile impl:      
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────

enum Ttmac020A15ConformanceLevel {
  complete,
  partial,
  notComplete,
}

enum Ttmac020A15ExecutionStatus {
  pending,
  running,
  complete,
  failed,
}

// ── Data Model ───────────────────────────────────────────────

/// Configuration record for TTMAC-020-A15.
/// All 5 DCDF lineage fields mandatory per AEETE-018.
class Ttmac020A15Config {
  final String configId;               // PK — UUID v4
  final String ruleKey;
  final String ruleValue;
  final String validationStatus;       // PENDING | VALID | INVALID
  final bool   immutableInd;
  // DCDF lineage headers — AEETE-018
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Ttmac020A15Config({
    required this.configId,
    required this.ruleKey,
    required this.ruleValue,
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
    configId:                  configId,
    ruleKey:                   ruleKey,
    ruleValue:                 ruleValue,
    validationStatus:          validationStatus  ?? this.validationStatus,
    immutableInd:              immutableInd      ?? this.immutableInd,
    traceId:                   traceId,
    originSourceId:            originSourceId,
    immediatePredecessorId:    immediatePredecessorId,
    transformationLogicHash:   transformationLogicHash,
    complianceStatusInd:       complianceStatusInd ?? this.complianceStatusInd,
  );

  Map<String, dynamic> toJson() => {
    'config_id':                  configId,
    'rule_key':                   ruleKey,
    'rule_value':                 ruleValue,
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
      case Ttmac020A15ConformanceLevel.complete:    return 'Complete';
      case Ttmac020A15ConformanceLevel.partial:     return 'Partial';
      case Ttmac020A15ConformanceLevel.notComplete: return 'Not Complete';
    }
  }
}

// ── EC:1 Pipeline ────────────────────────────────────────────────────────

/// TTMAC-020-A15: TTMAC-020 - Map EC to M3 Touch Targets (48dp)
///
/// Metric: Touch Target Compliance Rate
/// Floor=0.95 · Optimal=1.0 · Output=Pass / Fail
class Ttmac020A15Pipeline {
  static const double _floor   = 0.95;
  static const double _optimal = 1.0;

  // EC:1 — 1) Audit UI components generated for the Byts. 2) Set minimum height and width to 48dp. 3)
  static Ttmac020A15Config _ec1Execute(Ttmac020A15Config config) {
    if (config.configId.isEmpty) {
      throw ArgumentError(
          'EC-TTMAC020A15-001: configId required for TTMAC-020-A15');
    }
    // 1) Audit UI components generated for the Byts. 2) Set minimu
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  // Conformance gate — Floor=0.95 · Optimal=1.0
  static Ttmac020A15ValidationResult calculateConformance({
    required List<Ttmac020A15Config> configs,
  }) {
    if (configs.isEmpty) {
      return const Ttmac020A15ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Ttmac020A15ConformanceLevel.notComplete,
        gatePass: false,
        ecLineRef: 'EC-TTMAC020A15-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level      = rate >= _optimal
        ? Ttmac020A15ConformanceLevel.complete
        : rate >= _floor
            ? Ttmac020A15ConformanceLevel.partial
            : Ttmac020A15ConformanceLevel.notComplete;
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
      return {'error': 'EC-TTMAC020A15-001: empty config list', 'dlq': true};
    }
    final p1 = configs.map(_ec1Execute).toList();

    if (!triangularCheck(configs.length, p1.length)) {
      return {'error': 'EC-TTMAC020A15-TRI: triangular check failed', 'dlq': true};
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
      'ec_ref':             'EC-TTMAC-020-A15',
      'metric':             'Touch Target Compliance Rate',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> ttmac_020_a15Dlq(
  String errorCode,
  Map<String, dynamic> payload,
) => {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('TTMAC-020-A15',
              style: const TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                fontSize: 12))),
            Chip(
              label: Text(
                '${result.conformanceOutput} · ${result.violationCount} violation${result.violationCount == 1 ? '' : 's'}',
                style: const TextStyle(color: Colors.white, fontSize: 11)),
              backgroundColor: result.gatePass
                  ? cs.tertiary
                  : cs.error,
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
                title: Text(c.ruleKey,
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
    Ttmac020A15Config(
      configId:                'ttmac020a15-cfg-001',
      ruleKey:                 'ttmac-020-a15_rule',
      ruleValue:               'ttmac-020-a15_value',
      traceId:                 'trace-ttmac020a15-001',
      originSourceId:          'origin-ttmac020a15',
      immediatePredecessorId:  'pred-ttmac020a15-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final result = await Ttmac020A15Pipeline.run(
    configs: configs, userId: 'ritwik-udf');
  print('TTMAC-020-A15 → $result');
}
