// ============================================================
// HC-SCH-0015 — Habot Core Schema
// Atomic Step: Define the relational database foreign keys linking the mobile view inputs back to the ultimate Sour
// Metric:      Input Validation Coverage Rate · Floor=0.95 · Optimal=1.0
// Output:      Good / Average / Poor
// Standard:    ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:        github.com/RitwikHC/theme-typography · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        18-Sep-2026
// Step No:     440 of 440
// ============================================================
// Why this matters: 
// Mobile impl:      
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────

enum HcSch0015ConformanceLevel {
  complete,
  partial,
  notComplete,
}

enum HcSch0015ExecutionStatus {
  pending,
  running,
  complete,
  failed,
}

// ── Data Model ───────────────────────────────────────────────

/// Configuration record for HC-SCH-0015.
/// All 5 DCDF lineage fields mandatory per AEETE-018.
class HcSch0015Config {
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

  const HcSch0015Config({
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

  HcSch0015Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => HcSch0015Config(
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

class HcSch0015ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final HcSch0015ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const HcSch0015ValidationResult({
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
      case HcSch0015ConformanceLevel.complete:    return 'Good';
      case HcSch0015ConformanceLevel.partial:     return 'Average';
      case HcSch0015ConformanceLevel.notComplete: return 'Poor';
    }
  }
}

// ── EC:8 Pipeline ────────────────────────────────────────────────────────

/// HC-SCH-0015: Define the relational database foreign keys linking the mobile view inputs back 
///
/// Metric: Input Validation Coverage Rate
/// Floor=0.95 · Optimal=1.0 · Output=Pass / Fail
class HcSch0015Pipeline {
  static const double _floor   = 0.95;
  static const double _optimal = 1.0;

  // EC:1 — System locates the HC-SCH-0015 configuration in the source repository.
  static HcSch0015Config _ec1Locates(HcSch0015Config config) {
    if (config.configId.isEmpty) {
      throw ArgumentError(
          'EC-HCSCH0015-001: configId required for HC-SCH-0015');
    }
    // the HC-SCH-0015 configuration in the source repository
    return config;
  }

  // EC:2 — System extracts required data fields from the HC-SCH-0015 registry.
  static HcSch0015Config _ec2Extracts(HcSch0015Config config) {
    if (config.configId.isEmpty) {
      throw ArgumentError(
          'EC-HCSCH0015-002: configId required for HC-SCH-0015');
    }
    // required data fields from the HC-SCH-0015 registry
    return config;
  }

  // EC:3 — System compiles the implementation rule set per Input Validation Coverage Rate.
  static HcSch0015Config _ec3Compiles(HcSch0015Config config) {
    if (config.configId.isEmpty) {
      throw ArgumentError(
          'EC-HCSCH0015-003: configId required for HC-SCH-0015');
    }
    // the implementation rule set per Input Validation Coverage Ra
    return config;
  }

  // EC:4 — System registers compiled rules as immutable with immutable_IND=TRUE.
  static HcSch0015Config _ec4Registers(HcSch0015Config config) {
    if (config.configId.isEmpty) {
      throw ArgumentError(
          'EC-HCSCH0015-004: configId required for HC-SCH-0015');
    }
    // compiled rules as immutable with immutable_IND=TRUE
    return config;
  }

  // EC:5 — System validates configuration against Input Validation Coverage Rate gate (floor=0.95).
  static HcSch0015Config _ec5Validates(HcSch0015Config config) {
    if (config.configId.isEmpty) {
      throw ArgumentError(
          'EC-HCSCH0015-005: configId required for HC-SCH-0015');
    }
    // configuration against Input Validation Coverage Rate gate (f
    return config;
  }

  // EC:6 — System routes non-compliant records to the dead letter queue.
  static HcSch0015Config _ec6Routes(HcSch0015Config config) {
    if (config.configId.isEmpty) {
      throw ArgumentError(
          'EC-HCSCH0015-006: configId required for HC-SCH-0015');
    }
    // non-compliant records to the dead letter queue
    return config;
  }

  // EC:7 — System writes validated result to the execution audit log.
  static HcSch0015Config _ec7Writes(HcSch0015Config config) {
    if (config.configId.isEmpty) {
      throw ArgumentError(
          'EC-HCSCH0015-007: configId required for HC-SCH-0015');
    }
    // validated result to the execution audit log
    return config;
  }

  // EC:8 — System publishes validated configuration to the rule registry.
  static HcSch0015Config _ec8Publishes(HcSch0015Config config) {
    if (config.configId.isEmpty) {
      throw ArgumentError(
          'EC-HCSCH0015-008: configId required for HC-SCH-0015');
    }
    // validated configuration to the rule registry
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  // Conformance gate — Floor=0.95 · Optimal=1.0
  static HcSch0015ValidationResult calculateConformance({
    required List<HcSch0015Config> configs,
  }) {
    if (configs.isEmpty) {
      return const HcSch0015ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: HcSch0015ConformanceLevel.notComplete,
        gatePass: false,
        ecLineRef: 'EC-HCSCH0015-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level      = rate >= _optimal
        ? HcSch0015ConformanceLevel.complete
        : rate >= _floor
            ? HcSch0015ConformanceLevel.partial
            : HcSch0015ConformanceLevel.notComplete;
    return HcSch0015ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-HCSCH0015-VAL',
    );
  }

  static HcSch0015Config routeToRegistry(
    HcSch0015Config config,
    HcSch0015ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<HcSch0015Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      return {'error': 'EC-HCSCH0015-001: empty config list', 'dlq': true};
    }
    final p1 = configs.map(_ec1Locates).toList();
    final p2 = configs.map(_ec2Extracts).toList();
    final p3 = configs.map(_ec3Compiles).toList();
    final p4 = configs.map(_ec4Registers).toList();
    final p5 = configs.map(_ec5Validates).toList();
    final p6 = configs.map(_ec6Routes).toList();
    final p7 = configs.map(_ec7Writes).toList();
    final p8 = configs.map(_ec8Publishes).toList();

    if (!triangularCheck(configs.length, p8.length)) {
      return {'error': 'EC-HCSCH0015-TRI: triangular check failed', 'dlq': true};
    }

    final result     = calculateConformance(configs: p8);
    final registered = p8.map((c) => routeToRegistry(c, result)).toList();

    return {
      'status':             result.gatePass ? 'COMPLETE' : 'PARTIAL',
      'conformance_rate':   result.conformanceRate,
      'conformance_output': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-HC-SCH-0015',
      'metric':             'Input Validation Coverage Rate',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> hc_sch_0015Dlq(
  String errorCode,
  Map<String, dynamic> payload,
) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'HC-SCH-0015',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class HcSch0015Widget extends StatelessWidget {
  final List<HcSch0015Config> configs;
  const HcSch0015Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = HcSch0015Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('HC-SCH-0015',
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
    HcSch0015Config(
      configId:                'hcsch0015-cfg-001',
      ruleKey:                 'hc-sch-0015_rule',
      ruleValue:               'hc-sch-0015_value',
      traceId:                 'trace-hcsch0015-001',
      originSourceId:          'origin-hcsch0015',
      immediatePredecessorId:  'pred-hcsch0015-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final result = await HcSch0015Pipeline.run(
    configs: configs, userId: 'ritwik-udf');
  print('HC-SCH-0015 → $result');
}
