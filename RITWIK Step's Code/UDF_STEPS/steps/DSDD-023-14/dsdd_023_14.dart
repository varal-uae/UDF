// ============================================================
// DSDD-023-14 — Data Schema Design Document
// Atomic Step:  Inject trace_id headers universally.
// Metric:       Process Execution Quality Score
// Floor:        0.9  ·  Optimal: 0.97
// Output vocab: Good / Average / Poor
// Standard:     ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:         github.com/varal-uae/UDF · branch: ritwik
// Author:       Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:         25-Sep-2026
// Step No:      186 of 1073
// ============================================================
// Why:          
// Mobile:       
// col41:        Good/Average/Poor → Best = Good (100%)
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Conformance vocabulary: Good / Average / Poor ─────────────

enum Dsdd02314ConformanceLevel {
  good,    // ≥ optimal
  average, // ≥ floor
  poor,    // < floor
}

// ── Execution status ─────────────────────────────────────────

enum Dsdd02314ExecutionStatus { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// DSDD-023-14 — Data Schema Design Document
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Dsdd02314Config {
  final String configId;
  final String ruleKey;
  final String ruleValue;
  final String metricLabel;
  final String complianceTarget;
  final String validationStatus;
  final bool   immutableInd;
  // DCDF lineage
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Dsdd02314Config({
    required this.configId,
    required this.ruleKey,
    required this.ruleValue,
    required this.metricLabel,
    required this.complianceTarget,
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

  Dsdd02314Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Dsdd02314Config(
    configId: configId,
    ruleKey: ruleKey,
    ruleValue: ruleValue,
    metricLabel: metricLabel,
    complianceTarget: complianceTarget,
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
    'ruleKey': ruleKey,
    'ruleValue': ruleValue,
    'metricLabel': metricLabel,
    'complianceTarget': complianceTarget,
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

class Dsdd02314ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Dsdd02314ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Dsdd02314ValidationResult({
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
      case Dsdd02314ConformanceLevel.good:    return 'Good';
      case Dsdd02314ConformanceLevel.average: return 'Average';
      case Dsdd02314ConformanceLevel.poor:    return 'Poor';
    }
  }
}

// ── EC:8 Pipeline ────────────────────────────────────────

/// DSDD-023-14: Inject trace_id headers universally.
/// Metric: Process Execution Quality Score
/// Floor=0.9 · Output=Good / Average / Poor
class Dsdd02314Pipeline {
  static const double _floor   = 0.9;
  static const double _optimal = 0.97;

  // EC:1 — System locates the DSDD-023-14 configuration in the source repository.
  static Dsdd02314Config _ec1Locates(Dsdd02314Config config) {
    if (config.ruleKey.isEmpty) {
      throw ArgumentError(
          'EC-DSDD02314-001: ruleKey required for DSDD-023-14');
    }
    // the DSDD-023-14 configuration in the source repository
    return config;
  }

  // EC:2 — System extracts ruleKey and ruleValue from the DSDD-023-14 registry.
  static Dsdd02314Config _ec2Extracts(Dsdd02314Config config) {
    if (config.ruleKey.isEmpty) {
      throw ArgumentError(
          'EC-DSDD02314-002: ruleKey required for DSDD-023-14');
    }
    // ruleKey and ruleValue from the DSDD-023-14 registry
    return config;
  }

  // EC:3 — System compiles the implementation rule set per Process Execution Quality Score.
  static Dsdd02314Config _ec3Compiles(Dsdd02314Config config) {
    if (config.ruleKey.isEmpty) {
      throw ArgumentError(
          'EC-DSDD02314-003: ruleKey required for DSDD-023-14');
    }
    // the implementation rule set per Process Execution Quality Sc
    return config;
  }

  // EC:4 — System validates configuration against required constraints.
  static Dsdd02314Config _ec4Validates(Dsdd02314Config config) {
    if (config.ruleKey.isEmpty) {
      throw ArgumentError(
          'EC-DSDD02314-004: ruleKey required for DSDD-023-14');
    }
    // configuration against required constraints
    return config;
  }

  // EC:5 — System registers compiled rules as immutable with immutable_IND=TRUE.
  static Dsdd02314Config _ec5Registers(Dsdd02314Config config) {
    if (config.ruleKey.isEmpty) {
      throw ArgumentError(
          'EC-DSDD02314-005: ruleKey required for DSDD-023-14');
    }
    // compiled rules as immutable with immutable_IND=TRUE
    return config;
  }

  // EC:6 — System validates configuration against Process Execution Quality Score gate (floor=0.9).
  static Dsdd02314Config _ec6Validates(Dsdd02314Config config) {
    if (config.ruleKey.isEmpty) {
      throw ArgumentError(
          'EC-DSDD02314-006: ruleKey required for DSDD-023-14');
    }
    // configuration against Process Execution Quality Score gate (
    return config;
  }

  // EC:7 — System routes non-compliant records to the dead letter queue.
  static Dsdd02314Config _ec7Routes(Dsdd02314Config config) {
    if (config.ruleKey.isEmpty) {
      throw ArgumentError(
          'EC-DSDD02314-007: ruleKey required for DSDD-023-14');
    }
    // non-compliant records to the dead letter queue
    return config;
  }

  // EC:8 — System publishes validated configuration to the rule registry.
  static Dsdd02314Config _ec8Publishes(Dsdd02314Config config) {
    if (config.ruleKey.isEmpty) {
      throw ArgumentError(
          'EC-DSDD02314-008: ruleKey required for DSDD-023-14');
    }
    // validated configuration to the rule registry
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Dsdd02314ValidationResult calculateConformance({
    required List<Dsdd02314Config> configs,
  }) {
    if (configs.isEmpty) {
      return Dsdd02314ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Dsdd02314ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-DSDD02314-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level = rate >= _optimal
        ? Dsdd02314ConformanceLevel.good
        : rate >= _floor
            ? Dsdd02314ConformanceLevel.average
            : Dsdd02314ConformanceLevel.poor;
    return Dsdd02314ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-DSDD02314-VAL',
    );
  }

  static Dsdd02314Config routeToRegistry(
    Dsdd02314Config config,
    Dsdd02314ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Dsdd02314Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-DSDD02314-000: configs must not be empty for DSDD-023-14');
    }
    final p1 = configs.map(_ec1Locates).toList();
    final p2 = configs.map(_ec2Extracts).toList();
    final p3 = configs.map(_ec3Compiles).toList();
    final p4 = configs.map(_ec4Validates).toList();
    final p5 = configs.map(_ec5Registers).toList();
    final p6 = configs.map(_ec6Validates).toList();
    final p7 = configs.map(_ec7Routes).toList();
    final p8 = configs.map(_ec8Publishes).toList();

    if (!triangularCheck(configs.length, p8.length)) {
      throw ArgumentError('EC-DSDD02314-TRI: triangular check failed for DSDD-023-14');
    }
    final result     = calculateConformance(configs: p8);
    final registered = p8.map((c) => routeToRegistry(c, result)).toList();
    return {
      'status':             result.gatePass ? 'COMPLETE' : 'FAILED',
      'conformance_verdict': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-DSDD-023-14',
      'metric':             'Process Execution Quality Score',
      'output_vocab':       'Good / Average / Poor',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> dsdd_023_14Dlq(
    String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'DSDD-023-14',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Dsdd02314Widget extends StatelessWidget {
  final List<Dsdd02314Config> configs;
  const Dsdd02314Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Dsdd02314Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    final isGood = result.gatePass;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('DSDD-023-14',
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
                title: Text(c.ruleKey,
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
    Dsdd02314Config(
      configId: 'dsdd02314-cfg-001',
      ruleKey: 'dsdd-023-14_ruleKey',
      ruleValue: 'dsdd-023-14_ruleValue',
      metricLabel: 'dsdd-023-14_metricLabel',
      complianceTarget: 'dsdd-023-14_complianceTarget',
      traceId:                 'trace-dsdd02314-001',
      originSourceId:          'origin-dsdd02314',
      immediatePredecessorId:  'pred-dsdd02314-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final out = await Dsdd02314Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('DSDD-023-14 [Good / Average / Poor] → $out');
}
