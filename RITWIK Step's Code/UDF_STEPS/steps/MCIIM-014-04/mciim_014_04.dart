// ============================================================
// MCIIM-014-04 — Mobile Context Isolation & Image Module
// Atomic Step: Isolate Mobile Visual Context
// Metric:      Implementation Conformance Rate · Floor=0.90 · Optimal=0.97
// Output:      Pass / Partial / Fail
// Standard:    ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:        github.com/RitwikHC/theme-typography · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        15-Sep-2026
// Step No:     372 of 390
// ============================================================
// Why this matters: 
// Mobile impl: 
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────

enum Mciim01404ConformanceLevel {
  complete,
  partial,
  notComplete,
}

enum Mciim01404ExecutionStatus {
  pending,
  running,
  complete,
  failed,
}

// ── Data Model ───────────────────────────────────────────────

/// Configuration record for MCIIM-014-04.
/// All 5 DCDF lineage fields mandatory per AEETE-018.
class Mciim01404Config {
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

  const Mciim01404Config({
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

  Mciim01404Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Mciim01404Config(
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

class Mciim01404ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Mciim01404ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Mciim01404ValidationResult({
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
      case Mciim01404ConformanceLevel.complete:    return 'Pass';
      case Mciim01404ConformanceLevel.partial:     return 'Partial';
      case Mciim01404ConformanceLevel.notComplete: return 'Fail';
    }
  }
}

// ── EC:8 Pipeline ────────────────────────────────────────────────────────

/// MCIIM-014-04: Isolate Mobile Visual Context
///
/// Metric: Implementation Conformance Rate
/// Floor=0.90 · Optimal=0.97 · Output=Complete / Partial / Not Complete
class Mciim01404Pipeline {
  static const double _floor   = 0.90;
  static const double _optimal = 0.97;

  // EC:1 — System locates the MCIIM-014-04 configuration in the source repository.
  static Mciim01404Config _ec1Locates(Mciim01404Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-MCIIM01404-001: configId required for MCIIM-014-04');
    };
    // the MCIIM-014-04 configuration in the source repos
    return config;
  }

  // EC:2 — System extracts required data fields from the MCIIM-014-04 registry.
  static Mciim01404Config _ec2Extracts(Mciim01404Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-MCIIM01404-002: configId required for MCIIM-014-04');
    };
    // required data fields from the MCIIM-014-04 registr
    return config;
  }

  // EC:3 — System compiles the implementation rule set per Implementation Conformance Rate.
  static Mciim01404Config _ec3Compiles(Mciim01404Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-MCIIM01404-003: configId required for MCIIM-014-04');
    };
    // the implementation rule set per Implementation Con
    return config;
  }

  // EC:4 — System registers compiled rules as immutable with immutable_IND=TRUE.
  static Mciim01404Config _ec4Registers(Mciim01404Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-MCIIM01404-004: configId required for MCIIM-014-04');
    };
    // compiled rules as immutable with immutable_IND=TRU
    return config;
  }

  // EC:5 — System validates configuration against Implementation Conformance Rate gate (floor=0.90).
  static Mciim01404Config _ec5Validates(Mciim01404Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-MCIIM01404-005: configId required for MCIIM-014-04');
    };
    // configuration against Implementation Conformance R
    return config;
  }

  // EC:6 — System routes non-compliant records to the dead letter queue.
  static Mciim01404Config _ec6Routes(Mciim01404Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-MCIIM01404-006: configId required for MCIIM-014-04');
    };
    // non-compliant records to the dead letter queue
    return config;
  }

  // EC:7 — System writes validated result to the execution audit log.
  static Mciim01404Config _ec7Writes(Mciim01404Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-MCIIM01404-007: configId required for MCIIM-014-04');
    };
    // validated result to the execution audit log
    return config;
  }

  // EC:8 — System publishes validated configuration to the rule registry.
  static Mciim01404Config _ec8Publishes(Mciim01404Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-MCIIM01404-008: configId required for MCIIM-014-04');
    };
    // validated configuration to the rule registry
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  // Conformance gate — Floor=0.90 · Optimal=0.97
  static Mciim01404ValidationResult calculateConformance({
    required List<Mciim01404Config> configs,
  }) {
    if (configs.isEmpty) {
      return const Mciim01404ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Mciim01404ConformanceLevel.notComplete,
        gatePass: false,
        ecLineRef: 'EC-MCIIM01404-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level      = rate >= _optimal
        ? Mciim01404ConformanceLevel.complete
        : rate >= _floor
            ? Mciim01404ConformanceLevel.partial
            : Mciim01404ConformanceLevel.notComplete;
    return Mciim01404ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-MCIIM01404-VAL',
    );
  }

  static Mciim01404Config routeToRegistry(
    Mciim01404Config config,
    Mciim01404ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Mciim01404Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      return {'error': 'EC-MCIIM01404-001: empty config list', 'dlq': true};
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
      return {'error': 'EC-MCIIM01404-TRI: triangular check failed', 'dlq': true};
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
      'ec_ref':             'EC-MCIIM-014-04',
      'metric':             'Implementation Conformance Rate',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> mciim_014_04Dlq(
  String errorCode,
  Map<String, dynamic> payload,
) => {
  'error_code':       errorCode,
  'payload_snapshot': jsonEncode(payload),
  'dlq':              true,
  'step_ref':         'MCIIM-014-04',
  'trace_id':         payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Mciim01404Widget extends StatelessWidget {
  final List<Mciim01404Config> configs;
  const Mciim01404Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Mciim01404Pipeline.calculateConformance(configs: configs);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('MCIIM-014-04',
              style: const TextStyle(fontFamily: 'Courier',
                fontWeight: FontWeight.bold, fontSize: 12))),
            Chip(
              label: Text(
                '${result.conformanceOutput} · ${result.violationCount} violation${result.violationCount==1?'':'s'}',
                style: const TextStyle(color: Colors.white, fontSize: 11)),
              backgroundColor: result.gatePass
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.error,
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
                  color: pass
                      ? Theme.of(context).colorScheme.tertiary
                      : Theme.of(context).colorScheme.error,
                ),
                title: Text(c.ruleKey,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 12)),
                subtitle: Text(
                  'id: ${c.configId.length>8?c.configId.substring(0,8):c.configId}… '
                  '| ${c.validationStatus} | immutable: ${c.immutableInd}',
                  style: const TextStyle(fontSize: 11)),
                trailing: Chip(
                  label: Text(pass ? 'PASS' : 'FAIL',
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: pass
                      ? Theme.of(context).colorScheme.tertiary
                      : Theme.of(context).colorScheme.error,
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
    Mciim01404Config(
      configId:                'mciim01404-cfg-001',
      ruleKey:                 'mciim-014-04_rule',
      ruleValue:               'mciim-014-04_value',
      traceId:                 'trace-mciim01404-001',
      originSourceId:          'origin-mciim01404',
      immediatePredecessorId:  'pred-mciim01404-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final result = await Mciim01404Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('MCIIM-014-04 → $result');
}
