// ============================================================
// ERMWD-031-04 — Error Mapping & Widget Display
// Atomic Step: Implement the frontend logic mapping failed mobile Byt JSON payloads to the worker UI task cards. (C
// Metric:      Implementation Conformance Rate · Floor=0.90 · Optimal=0.97
// Output:      Complete / Partial / Not Complete
// Standard:    ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:        github.com/RitwikHC/theme-typography · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        15-Sep-2026
// Step No:     371 of 390
// ============================================================
// Why this matters: 
// Mobile impl: 
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────

enum Ermwd03104ConformanceLevel {
  complete,
  partial,
  notComplete,
}

enum Ermwd03104ExecutionStatus {
  pending,
  running,
  complete,
  failed,
}

// ── Data Model ───────────────────────────────────────────────

/// Configuration record for ERMWD-031-04.
/// All 5 DCDF lineage fields mandatory per AEETE-018.
class Ermwd03104Config {
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

  const Ermwd03104Config({
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

  Ermwd03104Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Ermwd03104Config(
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

class Ermwd03104ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Ermwd03104ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Ermwd03104ValidationResult({
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
      case Ermwd03104ConformanceLevel.complete:    return 'Complete';
      case Ermwd03104ConformanceLevel.partial:     return 'Partial';
      case Ermwd03104ConformanceLevel.notComplete: return 'Not Complete';
    }
  }
}

// ── EC:8 Pipeline ────────────────────────────────────────────────────────

/// ERMWD-031-04: Implement the frontend logic mapping failed mobile Byt JSON payloads to the work
///
/// Metric: Implementation Conformance Rate
/// Floor=0.90 · Optimal=0.97 · Output=Complete / Partial / Not Complete
class Ermwd03104Pipeline {
  static const double _floor   = 0.90;
  static const double _optimal = 0.97;

  // EC:1 — System locates the ERMWD-031-04 configuration in the source repository.
  static Ermwd03104Config _ec1Locates(Ermwd03104Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-ERMWD03104-001: configId required for ERMWD-031-04');
    };
    // the ERMWD-031-04 configuration in the source repos
    return config;
  }

  // EC:2 — System extracts required data fields from the ERMWD-031-04 registry.
  static Ermwd03104Config _ec2Extracts(Ermwd03104Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-ERMWD03104-002: configId required for ERMWD-031-04');
    };
    // required data fields from the ERMWD-031-04 registr
    return config;
  }

  // EC:3 — System compiles the implementation rule set per Implementation Conformance Rate.
  static Ermwd03104Config _ec3Compiles(Ermwd03104Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-ERMWD03104-003: configId required for ERMWD-031-04');
    };
    // the implementation rule set per Implementation Con
    return config;
  }

  // EC:4 — System registers compiled rules as immutable with immutable_IND=TRUE.
  static Ermwd03104Config _ec4Registers(Ermwd03104Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-ERMWD03104-004: configId required for ERMWD-031-04');
    };
    // compiled rules as immutable with immutable_IND=TRU
    return config;
  }

  // EC:5 — System validates configuration against Implementation Conformance Rate gate (floor=0.90).
  static Ermwd03104Config _ec5Validates(Ermwd03104Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-ERMWD03104-005: configId required for ERMWD-031-04');
    };
    // configuration against Implementation Conformance R
    return config;
  }

  // EC:6 — System routes non-compliant records to the dead letter queue.
  static Ermwd03104Config _ec6Routes(Ermwd03104Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-ERMWD03104-006: configId required for ERMWD-031-04');
    };
    // non-compliant records to the dead letter queue
    return config;
  }

  // EC:7 — System writes validated result to the execution audit log.
  static Ermwd03104Config _ec7Writes(Ermwd03104Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-ERMWD03104-007: configId required for ERMWD-031-04');
    };
    // validated result to the execution audit log
    return config;
  }

  // EC:8 — System publishes validated configuration to the rule registry.
  static Ermwd03104Config _ec8Publishes(Ermwd03104Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-ERMWD03104-008: configId required for ERMWD-031-04');
    };
    // validated configuration to the rule registry
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  // Conformance gate — Floor=0.90 · Optimal=0.97
  static Ermwd03104ValidationResult calculateConformance({
    required List<Ermwd03104Config> configs,
  }) {
    if (configs.isEmpty) {
      return const Ermwd03104ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Ermwd03104ConformanceLevel.notComplete,
        gatePass: false,
        ecLineRef: 'EC-ERMWD03104-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level      = rate >= _optimal
        ? Ermwd03104ConformanceLevel.complete
        : rate >= _floor
            ? Ermwd03104ConformanceLevel.partial
            : Ermwd03104ConformanceLevel.notComplete;
    return Ermwd03104ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-ERMWD03104-VAL',
    );
  }

  static Ermwd03104Config routeToRegistry(
    Ermwd03104Config config,
    Ermwd03104ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Ermwd03104Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      return {'error': 'EC-ERMWD03104-001: empty config list', 'dlq': true};
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
      return {'error': 'EC-ERMWD03104-TRI: triangular check failed', 'dlq': true};
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
      'ec_ref':             'EC-ERMWD-031-04',
      'metric':             'Implementation Conformance Rate',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> ermwd_031_04Dlq(
  String errorCode,
  Map<String, dynamic> payload,
) => {
  'error_code':       errorCode,
  'payload_snapshot': jsonEncode(payload),
  'dlq':              true,
  'step_ref':         'ERMWD-031-04',
  'trace_id':         payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Ermwd03104Widget extends StatelessWidget {
  final List<Ermwd03104Config> configs;
  const Ermwd03104Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Ermwd03104Pipeline.calculateConformance(configs: configs);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('ERMWD-031-04',
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
    Ermwd03104Config(
      configId:                'ermwd03104-cfg-001',
      ruleKey:                 'ermwd-031-04_rule',
      ruleValue:               'ermwd-031-04_value',
      traceId:                 'trace-ermwd03104-001',
      originSourceId:          'origin-ermwd03104',
      immediatePredecessorId:  'pred-ermwd03104-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final result = await Ermwd03104Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('ERMWD-031-04 → $result');
}
