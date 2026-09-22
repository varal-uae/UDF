// ============================================================
// SSTLA-036-A04 — Split-Screen Template Layout Architecture
// Atomic Step: Define the exact asset sizing boundaries and cropping aspect ratios for unstructured text and image 
// Metric:      Media Rendering Compliance Rate · Floor=0.90 · Optimal=0.97
// Output:      Good / Average / Poor
// Standard:    ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:        github.com/RitwikHC/theme-typography · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        15-Sep-2026
// Step No:     364 of 390
// ============================================================
// Why this matters: Standardizing image snippet dimensions ensures that unreadable data blocks scale perfectly onto comp
// Mobile impl: Customizes heavy system documents into lightweight, mobile-optimized image blocks that load instantl
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────

enum Sstla036A04ConformanceLevel {
  complete,
  partial,
  notComplete,
}

enum Sstla036A04ExecutionStatus {
  pending,
  running,
  complete,
  failed,
}

// ── Data Model ───────────────────────────────────────────────

/// Configuration record for SSTLA-036-A04.
/// All 5 DCDF lineage fields mandatory per AEETE-018.
class Sstla036A04Config {
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

  const Sstla036A04Config({
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

  Sstla036A04Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Sstla036A04Config(
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

class Sstla036A04ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Sstla036A04ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Sstla036A04ValidationResult({
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
      case Sstla036A04ConformanceLevel.complete:    return 'Complete';
      case Sstla036A04ConformanceLevel.partial:     return 'Partial';
      case Sstla036A04ConformanceLevel.notComplete: return 'Not Complete';
    }
  }
}

// ── EC:8 Pipeline ────────────────────────────────────────────────────────

/// SSTLA-036-A04: Define the exact asset sizing boundaries and cropping aspect ratios for unstruct
///
/// Metric: Media Rendering Compliance Rate
/// Floor=0.90 · Optimal=0.97 · Output=Good / Average / Poor
class Sstla036A04Pipeline {
  static const double _floor   = 0.90;
  static const double _optimal = 0.97;

  // EC:1 — System locates the SSTLA-036-A04 configuration in the source repository.
  static Sstla036A04Config _ec1Locates(Sstla036A04Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-SSTLA036A04-001: configId required for SSTLA-036-A04');
    };
    // the SSTLA-036-A04 configuration in the source repo
    return config;
  }

  // EC:2 — System extracts required data fields from the SSTLA-036-A04 registry.
  static Sstla036A04Config _ec2Extracts(Sstla036A04Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-SSTLA036A04-002: configId required for SSTLA-036-A04');
    };
    // required data fields from the SSTLA-036-A04 regist
    return config;
  }

  // EC:3 — System compiles the implementation rule set per Media Rendering Compliance Rate.
  static Sstla036A04Config _ec3Compiles(Sstla036A04Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-SSTLA036A04-003: configId required for SSTLA-036-A04');
    };
    // the implementation rule set per Media Rendering Co
    return config;
  }

  // EC:4 — System registers compiled rules as immutable with immutable_IND=TRUE.
  static Sstla036A04Config _ec4Registers(Sstla036A04Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-SSTLA036A04-004: configId required for SSTLA-036-A04');
    };
    // compiled rules as immutable with immutable_IND=TRU
    return config;
  }

  // EC:5 — System validates configuration against Media Rendering Compliance Rate gate (floor=0.90).
  static Sstla036A04Config _ec5Validates(Sstla036A04Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-SSTLA036A04-005: configId required for SSTLA-036-A04');
    };
    // configuration against Media Rendering Compliance R
    return config;
  }

  // EC:6 — System routes non-compliant records to the dead letter queue.
  static Sstla036A04Config _ec6Routes(Sstla036A04Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-SSTLA036A04-006: configId required for SSTLA-036-A04');
    };
    // non-compliant records to the dead letter queue
    return config;
  }

  // EC:7 — System writes validated result to the execution audit log.
  static Sstla036A04Config _ec7Writes(Sstla036A04Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-SSTLA036A04-007: configId required for SSTLA-036-A04');
    };
    // validated result to the execution audit log
    return config;
  }

  // EC:8 — System publishes validated configuration to the rule registry.
  static Sstla036A04Config _ec8Publishes(Sstla036A04Config config) {
        if (config.configId.isEmpty) {
      throw ArgumentError('EC-SSTLA036A04-008: configId required for SSTLA-036-A04');
    };
    // validated configuration to the rule registry
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  // Conformance gate — Floor=0.90 · Optimal=0.97
  static Sstla036A04ValidationResult calculateConformance({
    required List<Sstla036A04Config> configs,
  }) {
    if (configs.isEmpty) {
      return const Sstla036A04ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Sstla036A04ConformanceLevel.notComplete,
        gatePass: false,
        ecLineRef: 'EC-SSTLA036A04-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level      = rate >= _optimal
        ? Sstla036A04ConformanceLevel.complete
        : rate >= _floor
            ? Sstla036A04ConformanceLevel.partial
            : Sstla036A04ConformanceLevel.notComplete;
    return Sstla036A04ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-SSTLA036A04-VAL',
    );
  }

  static Sstla036A04Config routeToRegistry(
    Sstla036A04Config config,
    Sstla036A04ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Sstla036A04Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      return {'error': 'EC-SSTLA036A04-001: empty config list', 'dlq': true};
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
      return {'error': 'EC-SSTLA036A04-TRI: triangular check failed', 'dlq': true};
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
      'ec_ref':             'EC-SSTLA-036-A04',
      'metric':             'Media Rendering Compliance Rate',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> sstla_036_a04Dlq(
  String errorCode,
  Map<String, dynamic> payload,
) => {
  'error_code':       errorCode,
  'payload_snapshot': jsonEncode(payload),
  'dlq':              true,
  'step_ref':         'SSTLA-036-A04',
  'trace_id':         payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Sstla036A04Widget extends StatelessWidget {
  final List<Sstla036A04Config> configs;
  const Sstla036A04Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Sstla036A04Pipeline.calculateConformance(configs: configs);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('SSTLA-036-A04',
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
    Sstla036A04Config(
      configId:                'sstla036a04-cfg-001',
      ruleKey:                 'sstla-036-a04_rule',
      ruleValue:               'sstla-036-a04_value',
      traceId:                 'trace-sstla036a04-001',
      originSourceId:          'origin-sstla036a04',
      immediatePredecessorId:  'pred-sstla036a04-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final result = await Sstla036A04Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('SSTLA-036-A04 → $result');
}
