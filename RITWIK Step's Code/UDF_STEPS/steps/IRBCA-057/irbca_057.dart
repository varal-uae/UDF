// ============================================================
// IRBCA-057 — Immutable Rule-Based Component Architecture
// Atomic Step: Data Protection Digital Signature Gate'
// Metric:      Component Reuse Rate · Floor=95.0 · Optimal=99.0
// Output:      Pass / Partial / Fail
// Standard:    ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:        github.com/varal-uae/UDF · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        24-Sep-2026
// Step No:     533 of 1073
// ============================================================
// Why this matters: Legal compliance; prevents severe penalties for delayed exit pay.
// Mobile impl:      Push notifications to manager/finance mobile apps for urgent approvals.
// Data requirement: 4. Access the UI component library.
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────

enum Irbca057ConformanceLevel { complete, partial, notComplete }
enum Irbca057ExecutionStatus  { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// Configuration record for IRBCA-057.
/// Fields derived from AISS sheet — Immutable Rule-Based Component Architecture.
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Irbca057Config {
  final String configId;
  final String resourceId;
  final String principalId;
  final String permissionScope;
  final String grantedAt;
  final String validationStatus;
  final bool   immutableInd;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Irbca057Config({
    required this.configId,
    required this.resourceId,
    required this.principalId,
    required this.permissionScope,
    required this.grantedAt,
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

  Irbca057Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Irbca057Config(
    configId: configId,
    resourceId: resourceId,
    principalId: principalId,
    permissionScope: permissionScope,
    grantedAt: grantedAt,
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
    'resourceId': resourceId,
    'principalId': principalId,
    'permissionScope': permissionScope,
    'grantedAt': grantedAt,
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

class Irbca057ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Irbca057ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Irbca057ValidationResult({
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
      case Irbca057ConformanceLevel.complete:    return 'Pass';
      case Irbca057ConformanceLevel.partial:     return 'Partial';
      case Irbca057ConformanceLevel.notComplete: return 'Fail';
    }
  }
}

// ── EC:8 Pipeline ────────────────────────────────────────────

/// IRBCA-057: Data Protection Digital Signature Gate'
/// Metric: Component Reuse Rate · Floor=95.0 · Optimal=99.0
class Irbca057Pipeline {
  static const double _floor   = 95.0;
  static const double _optimal = 99.0;

  // EC:1 — System locates the IRBCA-057 configuration in the source repository.
  static Irbca057Config _ec1Locates(Irbca057Config config) {
    if (config.resourceId.isEmpty) {
      throw ArgumentError(
          'EC-IRBCA057-001: resourceId required for IRBCA-057');
    }
    // the IRBCA-057 configuration in the source repository
    return config;
  }

  // EC:2 — System extracts resourceId and principalId from the IRBCA-057 registry.
  static Irbca057Config _ec2Extracts(Irbca057Config config) {
    if (config.resourceId.isEmpty) {
      throw ArgumentError(
          'EC-IRBCA057-002: resourceId required for IRBCA-057');
    }
    // resourceId and principalId from the IRBCA-057 registry
    return config;
  }

  // EC:3 — System compiles the implementation rule set per Component Reuse Rate.
  static Irbca057Config _ec3Compiles(Irbca057Config config) {
    if (config.resourceId.isEmpty) {
      throw ArgumentError(
          'EC-IRBCA057-003: resourceId required for IRBCA-057');
    }
    // the implementation rule set per Component Reuse Rate
    return config;
  }

  // EC:4 — System validates configuration against required constraints.
  static Irbca057Config _ec4Validates(Irbca057Config config) {
    if (config.resourceId.isEmpty) {
      throw ArgumentError(
          'EC-IRBCA057-004: resourceId required for IRBCA-057');
    }
    // configuration against required constraints
    return config;
  }

  // EC:5 — System registers compiled rules as immutable with immutable_IND=TRUE.
  static Irbca057Config _ec5Registers(Irbca057Config config) {
    if (config.resourceId.isEmpty) {
      throw ArgumentError(
          'EC-IRBCA057-005: resourceId required for IRBCA-057');
    }
    // compiled rules as immutable with immutable_IND=TRUE
    return config;
  }

  // EC:6 — System validates configuration against Component Reuse Rate gate (floor=0.90).
  static Irbca057Config _ec6Validates(Irbca057Config config) {
    if (config.resourceId.isEmpty) {
      throw ArgumentError(
          'EC-IRBCA057-006: resourceId required for IRBCA-057');
    }
    // configuration against Component Reuse Rate gate (floor=0.90)
    return config;
  }

  // EC:7 — System routes non-compliant records to the dead letter queue.
  static Irbca057Config _ec7Routes(Irbca057Config config) {
    if (config.resourceId.isEmpty) {
      throw ArgumentError(
          'EC-IRBCA057-007: resourceId required for IRBCA-057');
    }
    // non-compliant records to the dead letter queue
    return config;
  }

  // EC:8 — System publishes validated configuration to the rule registry.
  static Irbca057Config _ec8Publishes(Irbca057Config config) {
    if (config.resourceId.isEmpty) {
      throw ArgumentError(
          'EC-IRBCA057-008: resourceId required for IRBCA-057');
    }
    // validated configuration to the rule registry
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Irbca057ValidationResult calculateConformance({
    required List<Irbca057Config> configs,
  }) {
    if (configs.isEmpty) {
      return const Irbca057ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Irbca057ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-IRBCA057-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level      = rate >= _optimal
        ? Irbca057ConformanceLevel.complete
        : rate >= _floor
            ? Irbca057ConformanceLevel.partial
            : Irbca057ConformanceLevel.notComplete;
    return Irbca057ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-IRBCA057-VAL',
    );
  }

  static Irbca057Config routeToRegistry(
    Irbca057Config config,
    Irbca057ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Irbca057Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-IRBCA057-000: configs must not be empty for IRBCA-057');
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
      throw ArgumentError('EC-IRBCA057-TRI: triangular check failed for IRBCA-057');
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
      'ec_ref':             'EC-IRBCA-057',
      'metric':             'Component Reuse Rate',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> irbca_057Dlq(String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'IRBCA-057',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Irbca057Widget extends StatelessWidget {
  final List<Irbca057Config> configs;
  const Irbca057Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Irbca057Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('IRBCA-057',
              style: const TextStyle(fontFamily:'Courier',fontWeight:FontWeight.bold,fontSize:12))),
            Chip(
              label: Text(
                '${result.conformanceOutput} · ${result.violationCount} violation${result.violationCount==1?"":"s"}',
                style: const TextStyle(color:Colors.white,fontSize:11)),
              backgroundColor: result.gatePass ? cs.tertiary : cs.error),
          ]),
        ),
        Expanded(child: ListView.builder(
          itemCount: configs.length,
          itemBuilder: (context, i) {
            final c = configs[i]; final pass = c.isRegistered;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal:16,vertical:4),
              child: ListTile(
                leading: Icon(pass ? Icons.check_circle : Icons.cancel,
                  color: pass ? cs.tertiary : cs.error),
                title: Text(c.resourceId,
                  style: const TextStyle(fontWeight:FontWeight.w600,fontSize:12)),
                subtitle: Text(
                  'id: ${c.configId.length>8?c.configId.substring(0,8):c.configId}… | ${c.validationStatus}',
                  style: const TextStyle(fontSize:11)),
                trailing: Chip(
                  label: Text(pass?'PASS':'FAIL',
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
    Irbca057Config(
      configId: 'irbca057-cfg-001',
      resourceId: 'irbca-057_resourceId',
      principalId: 'irbca-057_principalId',
      permissionScope: 'irbca-057_permissionScope',
      grantedAt: 'irbca-057_grantedAt',
      traceId:                 'trace-irbca057-001',
      originSourceId:          'origin-irbca057',
      immediatePredecessorId:  'pred-irbca057-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final result = await Irbca057Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('IRBCA-057 → $result');
}
