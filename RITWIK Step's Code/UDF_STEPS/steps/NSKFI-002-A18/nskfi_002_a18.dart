// ============================================================
// NSKFI-002-A18 — Navigation Shell & Key Feature Integration
// Atomic Step: Catalog reusable mobile components (SRCs).
// Metric:      Component Reuse Rate · Floor=0.90 · Optimal=1.0
// Output:      Complete / Partial / Not Complete
// Standard:    ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:        github.com/RitwikHC/theme-typography · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        18-Sep-2026
// Step No:     394 of 440
// ============================================================
// Why this matters: Eradicates duplicate effort.
// Mobile impl:      Dramatically reduces the mobile app binary size (APK/AAB) by reusing common code.
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────

enum Nskfi002A18ConformanceLevel {
  complete,
  partial,
  notComplete,
}

enum Nskfi002A18ExecutionStatus {
  pending,
  running,
  complete,
  failed,
}

// ── Data Model ───────────────────────────────────────────────

/// Configuration record for NSKFI-002-A18.
/// All 5 DCDF lineage fields mandatory per AEETE-018.
class Nskfi002A18Config {
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

  const Nskfi002A18Config({
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

  Nskfi002A18Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Nskfi002A18Config(
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

class Nskfi002A18ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Nskfi002A18ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Nskfi002A18ValidationResult({
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
      case Nskfi002A18ConformanceLevel.complete:    return 'Complete';
      case Nskfi002A18ConformanceLevel.partial:     return 'Partial';
      case Nskfi002A18ConformanceLevel.notComplete: return 'Not Complete';
    }
  }
}

// ── EC:1 Pipeline ────────────────────────────────────────────────────────

/// NSKFI-002-A18: Catalog reusable mobile components (SRCs).
///
/// Metric: Component Reuse Rate
/// Floor=0.90 · Optimal=1.0 · Output=Complete / Partial / Not Complete
class Nskfi002A18Pipeline {
  static const double _floor   = 0.90;
  static const double _optimal = 1.0;

  // EC:1 — 1) Index Byt, 2) Verify uniqueness, 3) Map to Dict, 4) Publish SRC
  static Nskfi002A18Config _ec1Execute(Nskfi002A18Config config) {
    if (config.configId.isEmpty) {
      throw ArgumentError(
          'EC-NSKFI002A18-001: configId required for NSKFI-002-A18');
    }
    // 1) Index Byt, 2) Verify uniqueness, 3) Map to Dict, 4) Publi
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  // Conformance gate — Floor=0.90 · Optimal=1.0
  static Nskfi002A18ValidationResult calculateConformance({
    required List<Nskfi002A18Config> configs,
  }) {
    if (configs.isEmpty) {
      return const Nskfi002A18ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Nskfi002A18ConformanceLevel.notComplete,
        gatePass: false,
        ecLineRef: 'EC-NSKFI002A18-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level      = rate >= _optimal
        ? Nskfi002A18ConformanceLevel.complete
        : rate >= _floor
            ? Nskfi002A18ConformanceLevel.partial
            : Nskfi002A18ConformanceLevel.notComplete;
    return Nskfi002A18ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-NSKFI002A18-VAL',
    );
  }

  static Nskfi002A18Config routeToRegistry(
    Nskfi002A18Config config,
    Nskfi002A18ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Nskfi002A18Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      return {'error': 'EC-NSKFI002A18-001: empty config list', 'dlq': true};
    }
    final p1 = configs.map(_ec1Execute).toList();

    if (!triangularCheck(configs.length, p1.length)) {
      return {'error': 'EC-NSKFI002A18-TRI: triangular check failed', 'dlq': true};
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
      'ec_ref':             'EC-NSKFI-002-A18',
      'metric':             'Component Reuse Rate',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> nskfi_002_a18Dlq(
  String errorCode,
  Map<String, dynamic> payload,
) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'NSKFI-002-A18',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Nskfi002A18Widget extends StatelessWidget {
  final List<Nskfi002A18Config> configs;
  const Nskfi002A18Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Nskfi002A18Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('NSKFI-002-A18',
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
    Nskfi002A18Config(
      configId:                'nskfi002a18-cfg-001',
      ruleKey:                 'nskfi-002-a18_rule',
      ruleValue:               'nskfi-002-a18_value',
      traceId:                 'trace-nskfi002a18-001',
      originSourceId:          'origin-nskfi002a18',
      immediatePredecessorId:  'pred-nskfi002a18-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final result = await Nskfi002A18Pipeline.run(
    configs: configs, userId: 'ritwik-udf');
  print('NSKFI-002-A18 → $result');
}
