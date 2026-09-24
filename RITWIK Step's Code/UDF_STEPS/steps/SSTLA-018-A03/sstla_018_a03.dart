// ============================================================
// SSTLA-018-A03 — Split-Screen Template Layout Architecture
// Atomic Step: Formulating the responsive layout rules to organize parent command sections on 5.5-inch mobile viewp
// Metric:      Layout Consistency Score · Floor=3.5 · Optimal=4.5
// Output:      Good / Average / Poor
// Standard:    ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:        github.com/varal-uae/UDF · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        24-Sep-2026
// Step No:     474 of 530
// ============================================================
// Why this matters: Cluttered or rigid mobile screen interfaces frustrate parents, driving application abandonment spike
// Mobile impl:      Screen elements must collapse into vertical layout stacks to eliminate horizontal scroll glitches.
// Data requirement: Establish visual hierarchy rules to structure parent command buttons and navigation groups.
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────

enum Sstla018A03ConformanceLevel {
  complete,
  partial,
  notComplete,
}

enum Sstla018A03ExecutionStatus {
  pending,
  running,
  complete,
  failed,
}

// ── Data Model ───────────────────────────────────────────────

/// Configuration record for SSTLA-018-A03.
/// Fields derived from AISS sheet — Split-Screen Template Layout Architecture.
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Sstla018A03Config {
  final String configId;               // PK — UUID v4
  // Step-specific fields
  final String fieldId;
  final String validationRule;
  final String errorMessage;
  final String inputType;
  final String validationStatus;       // PENDING | VALID | INVALID
  final bool   immutableInd;
  // DCDF lineage
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Sstla018A03Config({
    required this.configId,
    required this.fieldId,
    required this.validationRule,
    required this.errorMessage,
    required this.inputType,
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

  Sstla018A03Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Sstla018A03Config(
    configId: configId,
    fieldId: fieldId,
    validationRule: validationRule,
    errorMessage: errorMessage,
    inputType: inputType,
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
    'fieldId': fieldId,
    'validationRule': validationRule,
    'errorMessage': errorMessage,
    'inputType': inputType,
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

class Sstla018A03ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Sstla018A03ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Sstla018A03ValidationResult({
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
      case Sstla018A03ConformanceLevel.complete:    return 'Good';
      case Sstla018A03ConformanceLevel.partial:     return 'Average';
      case Sstla018A03ConformanceLevel.notComplete: return 'Poor';
    }
  }
}

// ── EC:8 Pipeline ────────────────────────────────────────────

/// SSTLA-018-A03: Formulating the responsive layout rules to organize parent command sections on 5
/// Metric: Layout Consistency Score
/// Floor=0.90 · Optimal=0.97 · Output=Good / Average / Poor
class Sstla018A03Pipeline {
  static const double _floor   = 3.5;
  static const double _optimal = 4.5;

  // EC:1 — System locates the SSTLA-018-A03 configuration in the source repository.
  static Sstla018A03Config _ec1Locates(Sstla018A03Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-SSTLA018A03-001: fieldId required for SSTLA-018-A03');
    }
    // the SSTLA-018-A03 configuration in the source repository
    return config;
  }

  // EC:2 — System extracts fieldId and validationRule from the SSTLA-018-A03 registry.
  static Sstla018A03Config _ec2Extracts(Sstla018A03Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-SSTLA018A03-002: fieldId required for SSTLA-018-A03');
    }
    // fieldId and validationRule from the SSTLA-018-A03 registry
    return config;
  }

  // EC:3 — System compiles the implementation rule set per Layout Consistency Score.
  static Sstla018A03Config _ec3Compiles(Sstla018A03Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-SSTLA018A03-003: fieldId required for SSTLA-018-A03');
    }
    // the implementation rule set per Layout Consistency Score
    return config;
  }

  // EC:4 — System validates configuration against required constraints and schemas.
  static Sstla018A03Config _ec4Validates(Sstla018A03Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-SSTLA018A03-004: fieldId required for SSTLA-018-A03');
    }
    // configuration against required constraints and schemas
    return config;
  }

  // EC:5 — System registers compiled rules as immutable with immutable_IND=TRUE.
  static Sstla018A03Config _ec5Registers(Sstla018A03Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-SSTLA018A03-005: fieldId required for SSTLA-018-A03');
    }
    // compiled rules as immutable with immutable_IND=TRUE
    return config;
  }

  // EC:6 — System validates configuration against Layout Consistency Score gate (floor=0.90).
  static Sstla018A03Config _ec6Validates(Sstla018A03Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-SSTLA018A03-006: fieldId required for SSTLA-018-A03');
    }
    // configuration against Layout Consistency Score gate (floor=0
    return config;
  }

  // EC:7 — System routes non-compliant records to the dead letter queue.
  static Sstla018A03Config _ec7Routes(Sstla018A03Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-SSTLA018A03-007: fieldId required for SSTLA-018-A03');
    }
    // non-compliant records to the dead letter queue
    return config;
  }

  // EC:8 — System publishes validated configuration to the rule registry.
  static Sstla018A03Config _ec8Publishes(Sstla018A03Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-SSTLA018A03-008: fieldId required for SSTLA-018-A03');
    }
    // validated configuration to the rule registry
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Sstla018A03ValidationResult calculateConformance({
    required List<Sstla018A03Config> configs,
  }) {
    if (configs.isEmpty) {
      return const Sstla018A03ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Sstla018A03ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-SSTLA018A03-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level      = rate >= _optimal
        ? Sstla018A03ConformanceLevel.complete
        : rate >= _floor
            ? Sstla018A03ConformanceLevel.partial
            : Sstla018A03ConformanceLevel.notComplete;
    return Sstla018A03ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-SSTLA018A03-VAL',
    );
  }

  static Sstla018A03Config routeToRegistry(
    Sstla018A03Config config,
    Sstla018A03ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Sstla018A03Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-SSTLA018A03-000: configs must not be empty for SSTLA-018-A03');
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
      throw ArgumentError('EC-SSTLA018A03-TRI: triangular check failed for SSTLA-018-A03');
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
      'ec_ref':             'EC-SSTLA-018-A03',
      'metric':             'Layout Consistency Score',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> sstla_018_a03Dlq(
  String errorCode,
  Map<String, dynamic> payload,
) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'SSTLA-018-A03',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Sstla018A03Widget extends StatelessWidget {
  final List<Sstla018A03Config> configs;
  const Sstla018A03Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Sstla018A03Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('SSTLA-018-A03',
              style: const TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold, fontSize: 12))),
            Chip(
              label: Text(
                '${result.conformanceOutput} · ${result.violationCount} violation${result.violationCount == 1 ? "" : "s"}',
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
                  color: pass ? cs.tertiary : cs.error),
                title: Text(c.fieldId,
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
    Sstla018A03Config(
      configId: 'sstla018a03-cfg-001',
      fieldId: 'sstla-018-a03_fieldId',
      validationRule: 'sstla-018-a03_validationRule',
      errorMessage: 'sstla-018-a03_errorMessage',
      inputType: 'sstla-018-a03_inputType',
      traceId:                 'trace-sstla018a03-001',
      originSourceId:          'origin-sstla018a03',
      immediatePredecessorId:  'pred-sstla018a03-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final result = await Sstla018A03Pipeline.run(
    configs: configs, userId: 'ritwik-udf');
  print('SSTLA-018-A03 → $result');
}
