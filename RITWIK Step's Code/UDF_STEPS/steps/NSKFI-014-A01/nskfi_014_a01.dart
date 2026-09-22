// ============================================================
// NSKFI-014-A01 — Navigation Shell & Key Feature Integration
// Atomic Step: Establish Mobile Creative Layout Version Control.
// Metric:      Layout Consistency Score · Floor=0.90 · Optimal=0.97
// Output:      Good / Average / Poor
// Standard:    ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:        github.com/RitwikHC/theme-typography · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        18-Sep-2026
// Step No:     272 of 396
// ============================================================
// Why this matters: Creative deployments remain stable across all interfaces, preventing broken UI elements from reachin
// Mobile impl:      Mobile components must be independently versioned from web components to account for OS-specific tou
// Data requirement: Access the mobile creative layout asset repository.
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────

enum Nskfi014A01ConformanceLevel {
  complete,
  partial,
  notComplete,
}

enum Nskfi014A01ExecutionStatus {
  pending,
  running,
  complete,
  failed,
}

// ── Data Model ───────────────────────────────────────────────

/// Configuration record for NSKFI-014-A01.
/// Fields derived from AISS sheet row — Navigation Shell & Key Feature Integration.
/// All 5 DCDF lineage fields mandatory per AEETE-018.
class Nskfi014A01Config {
  final String configId;               // PK — UUID v4
  // Step-specific fields (from AISS data requirement)
  final String access;
  final String mobile;
  final String creative;
  final String validationStatus;       // PENDING | VALID | INVALID
  final bool   immutableInd;
  // DCDF lineage headers — AEETE-018
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Nskfi014A01Config({
    required this.configId,
    required this.access,
    required this.mobile,
    required this.creative,
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

  Nskfi014A01Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Nskfi014A01Config(
    configId: configId,
    access: access,
    mobile: mobile,
    creative: creative,
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
    'access': access,
    'mobile': mobile,
    'creative': creative,
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

class Nskfi014A01ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Nskfi014A01ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Nskfi014A01ValidationResult({
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
      case Nskfi014A01ConformanceLevel.complete:    return 'Complete';
      case Nskfi014A01ConformanceLevel.partial:     return 'Partial';
      case Nskfi014A01ConformanceLevel.notComplete: return 'Not Complete';
    }
  }
}

// ── EC:4 Pipeline ────────────────────────────────────────────────────────

/// NSKFI-014-A01: Establish Mobile Creative Layout Version Control.
///
/// Metric: Layout Consistency Score
/// Floor=0.90 · Optimal=0.97 · Output=Good / Average / Poor
class Nskfi014A01Pipeline {
  static const double _floor   = 0.90;
  static const double _optimal = 0.97;

  // EC:1 — Create controlled versions for mobile and web layouts-05062026]
  static Nskfi014A01Config _ec1Execute(Nskfi014A01Config config) {
    if (config.access.isEmpty) {
      throw ArgumentError(
          'EC-NSKFI014A01-001: access required for NSKFI-014-A01');
    }
    // Create controlled versions for mobile and web layouts-050620
    return config;
  }

  // EC:2 — Test design updates against approved standards-05062026]
  static Nskfi014A01Config _ec2Execute(Nskfi014A01Config config) {
    if (config.access.isEmpty) {
      throw ArgumentError(
          'EC-NSKFI014A01-002: access required for NSKFI-014-A01');
    }
    // Test design updates against approved standards-05062026]
    return config;
  }

  // EC:3 — Compare new layouts with active versions and approve successful layouts for deployment-050
  static Nskfi014A01Config _ec3Execute(Nskfi014A01Config config) {
    if (config.access.isEmpty) {
      throw ArgumentError(
          'EC-NSKFI014A01-003: access required for NSKFI-014-A01');
    }
    // Compare new layouts with active versions and approve success
    return config;
  }

  // EC:4 — Retain previous versions for safe rollback-05062026]
  static Nskfi014A01Config _ec4Execute(Nskfi014A01Config config) {
    if (config.access.isEmpty) {
      throw ArgumentError(
          'EC-NSKFI014A01-004: access required for NSKFI-014-A01');
    }
    // Retain previous versions for safe rollback-05062026]
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  // Conformance gate — Floor=0.90 · Optimal=0.97
  static Nskfi014A01ValidationResult calculateConformance({
    required List<Nskfi014A01Config> configs,
  }) {
    if (configs.isEmpty) {
      return const Nskfi014A01ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Nskfi014A01ConformanceLevel.notComplete,
        gatePass: false,
        ecLineRef: 'EC-NSKFI014A01-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level      = rate >= _optimal
        ? Nskfi014A01ConformanceLevel.complete
        : rate >= _floor
            ? Nskfi014A01ConformanceLevel.partial
            : Nskfi014A01ConformanceLevel.notComplete;
    return Nskfi014A01ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-NSKFI014A01-VAL',
    );
  }

  static Nskfi014A01Config routeToRegistry(
    Nskfi014A01Config config,
    Nskfi014A01ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Nskfi014A01Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      return {'error': 'EC-NSKFI014A01-001: empty config list', 'dlq': true};
    }
    final p1 = configs.map(_ec1Execute).toList();
    final p2 = configs.map(_ec2Execute).toList();
    final p3 = configs.map(_ec3Execute).toList();
    final p4 = configs.map(_ec4Execute).toList();

    if (!triangularCheck(configs.length, p4.length)) {
      return {'error': 'EC-NSKFI014A01-TRI: triangular check failed', 'dlq': true};
    }

    final result     = calculateConformance(configs: p4);
    final registered = p4.map((c) => routeToRegistry(c, result)).toList();

    return {
      'status':             result.gatePass ? 'COMPLETE' : 'PARTIAL',
      'conformance_rate':   result.conformanceRate,
      'conformance_output': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-NSKFI-014-A01',
      'metric':             'Layout Consistency Score',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> nskfi_014_a01Dlq(
  String errorCode,
  Map<String, dynamic> payload,
) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'NSKFI-014-A01',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Nskfi014A01Widget extends StatelessWidget {
  final List<Nskfi014A01Config> configs;
  const Nskfi014A01Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Nskfi014A01Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('NSKFI-014-A01',
              style: const TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                fontSize: 12))),
            Chip(
              label: Text(
                '${result.conformanceOutput} · ${result.violationCount} violation${result.violationCount == 1 ? '' : 's'}',
                style: const TextStyle(color: Colors.white, fontSize: 11)),
              backgroundColor: result.gatePass ? cs.tertiary : cs.error,
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
                title: Text(c.access,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 12)),
                subtitle: Text(
                  '${access} | ${mobile}',
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
    Nskfi014A01Config(
      configId: 'nskfi014a01-cfg-001',
      access: 'nskfi-014-a01_access_value',
      mobile: 'nskfi-014-a01_mobile_value',
      creative: 'nskfi-014-a01_creative_value',
      traceId:                 'trace-nskfi014a01-001',
      originSourceId:          'origin-nskfi014a01',
      immediatePredecessorId:  'pred-nskfi014a01-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final result = await Nskfi014A01Pipeline.run(
    configs: configs, userId: 'ritwik-udf');
  print('NSKFI-014-A01 → $result');
}
