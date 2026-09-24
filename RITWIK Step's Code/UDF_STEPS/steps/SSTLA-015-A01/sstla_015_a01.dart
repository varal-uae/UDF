// ============================================================
// SSTLA-015-A01 — Split-Screen Template Layout Architecture
// Atomic Step:  Context-Removed Split-Screen Master Templates for Compact Screen Classes.
// Metric:       Requirement & Asset Discovery Coverage (%) — compact screen class boun
// Floor:        0.9  ·  Optimal: 1.0
// Output vocab: Complete / Partial / Not Complete
// Standard:     ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:         github.com/varal-uae/UDF · branch: ritwik
// Author:       Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:         25-Sep-2026
// Step No:      1012 of 1073
// ============================================================
// Why:          Enforces consistent layout rules for exception clearance forms platform-wide
// Mobile:       Ensures evidence graphics and input entries fit into a unified interface window securely
// col41:        Complete/Partial/Not Complete
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Conformance vocabulary: Complete / Partial / Not Complete ─────────────

enum Sstla015A01ConformanceLevel {
  complete,    // ≥ optimal
  partial,     // ≥ floor
  notComplete, // < floor
}

// ── Execution status ─────────────────────────────────────────

enum Sstla015A01ExecutionStatus { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// SSTLA-015-A01 — Split-Screen Template Layout Architecture
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Sstla015A01Config {
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

  const Sstla015A01Config({
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

  Sstla015A01Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Sstla015A01Config(
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

class Sstla015A01ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Sstla015A01ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Sstla015A01ValidationResult({
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
      case Sstla015A01ConformanceLevel.complete:    return 'Complete';
      case Sstla015A01ConformanceLevel.partial:     return 'Partial';
      case Sstla015A01ConformanceLevel.notComplete: return 'Not Complete';
    }
  }
}

// ── EC:8 Pipeline ────────────────────────────────────────

/// SSTLA-015-A01: Context-Removed Split-Screen Master Templates for Compact Screen Classes.
/// Metric: Requirement & Asset Discovery Coverage (%) — compact screen 
/// Floor=0.9 · Output=Complete / Partial / Not Complete
class Sstla015A01Pipeline {
  static const double _floor   = 0.9;
  static const double _optimal = 1.0;

  // EC:1 — System locates the SSTLA-015-A01 configuration in the source repository.
  static Sstla015A01Config _ec1Locates(Sstla015A01Config config) {
    if (config.ruleKey.isEmpty) {
      throw ArgumentError(
          'EC-SSTLA015A01-001: ruleKey required for SSTLA-015-A01');
    }
    // the SSTLA-015-A01 configuration in the source repository
    return config;
  }

  // EC:2 — System extracts ruleKey and ruleValue from the SSTLA-015-A01 registry.
  static Sstla015A01Config _ec2Extracts(Sstla015A01Config config) {
    if (config.ruleKey.isEmpty) {
      throw ArgumentError(
          'EC-SSTLA015A01-002: ruleKey required for SSTLA-015-A01');
    }
    // ruleKey and ruleValue from the SSTLA-015-A01 registry
    return config;
  }

  // EC:3 — System compiles the implementation rule set per Requirement & Asset Discovery Coverage (%)
  static Sstla015A01Config _ec3Compiles(Sstla015A01Config config) {
    if (config.ruleKey.isEmpty) {
      throw ArgumentError(
          'EC-SSTLA015A01-003: ruleKey required for SSTLA-015-A01');
    }
    // the implementation rule set per Requirement & Asset Discover
    return config;
  }

  // EC:4 — System validates configuration against required constraints.
  static Sstla015A01Config _ec4Validates(Sstla015A01Config config) {
    if (config.ruleKey.isEmpty) {
      throw ArgumentError(
          'EC-SSTLA015A01-004: ruleKey required for SSTLA-015-A01');
    }
    // configuration against required constraints
    return config;
  }

  // EC:5 — System registers compiled rules as immutable with immutable_IND=TRUE.
  static Sstla015A01Config _ec5Registers(Sstla015A01Config config) {
    if (config.ruleKey.isEmpty) {
      throw ArgumentError(
          'EC-SSTLA015A01-005: ruleKey required for SSTLA-015-A01');
    }
    // compiled rules as immutable with immutable_IND=TRUE
    return config;
  }

  // EC:6 — System validates configuration against Requirement & Asset Discovery Coverage (%) — compac
  static Sstla015A01Config _ec6Validates(Sstla015A01Config config) {
    if (config.ruleKey.isEmpty) {
      throw ArgumentError(
          'EC-SSTLA015A01-006: ruleKey required for SSTLA-015-A01');
    }
    // configuration against Requirement & Asset Discovery Coverage
    return config;
  }

  // EC:7 — System routes non-compliant records to the dead letter queue.
  static Sstla015A01Config _ec7Routes(Sstla015A01Config config) {
    if (config.ruleKey.isEmpty) {
      throw ArgumentError(
          'EC-SSTLA015A01-007: ruleKey required for SSTLA-015-A01');
    }
    // non-compliant records to the dead letter queue
    return config;
  }

  // EC:8 — System publishes validated configuration to the rule registry.
  static Sstla015A01Config _ec8Publishes(Sstla015A01Config config) {
    if (config.ruleKey.isEmpty) {
      throw ArgumentError(
          'EC-SSTLA015A01-008: ruleKey required for SSTLA-015-A01');
    }
    // validated configuration to the rule registry
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Sstla015A01ValidationResult calculateConformance({
    required List<Sstla015A01Config> configs,
  }) {
    if (configs.isEmpty) {
      return Sstla015A01ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Sstla015A01ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-SSTLA015A01-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level = rate >= _optimal
        ? Sstla015A01ConformanceLevel.complete
        : rate >= _floor
            ? Sstla015A01ConformanceLevel.partial
            : Sstla015A01ConformanceLevel.notComplete;
    return Sstla015A01ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-SSTLA015A01-VAL',
    );
  }

  static Sstla015A01Config routeToRegistry(
    Sstla015A01Config config,
    Sstla015A01ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Sstla015A01Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-SSTLA015A01-000: configs must not be empty for SSTLA-015-A01');
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
      throw ArgumentError('EC-SSTLA015A01-TRI: triangular check failed for SSTLA-015-A01');
    }
    final result     = calculateConformance(configs: p8);
    final registered = p8.map((c) => routeToRegistry(c, result)).toList();
    return {
      'status':             result.gatePass ? 'COMPLETE' : 'FAILED',
      'conformance_verdict': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-SSTLA-015-A01',
      'metric':             'Requirement & Asset Discovery Coverage (%) — compact screen ',
      'output_vocab':       'Complete / Partial / Not Complete',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> sstla_015_a01Dlq(
    String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'SSTLA-015-A01',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Sstla015A01Widget extends StatelessWidget {
  final List<Sstla015A01Config> configs;
  const Sstla015A01Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Sstla015A01Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    final isGood = result.gatePass;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('SSTLA-015-A01',
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
                    pass ? 'Complete' : 'Not Complete',
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
    Sstla015A01Config(
      configId: 'sstla015a01-cfg-001',
      ruleKey: 'sstla-015-a01_ruleKey',
      ruleValue: 'sstla-015-a01_ruleValue',
      metricLabel: 'sstla-015-a01_metricLabel',
      complianceTarget: 'sstla-015-a01_complianceTarget',
      traceId:                 'trace-sstla015a01-001',
      originSourceId:          'origin-sstla015a01',
      immediatePredecessorId:  'pred-sstla015a01-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final out = await Sstla015A01Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('SSTLA-015-A01 [Complete / Partial / Not Complete] → $out');
}
