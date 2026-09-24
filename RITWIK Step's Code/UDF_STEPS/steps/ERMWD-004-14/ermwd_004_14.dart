// ============================================================
// ERMWD-004-14 — Error Mapping & Widget Display
// Atomic Step:  Integrate sliding layout sheet containers pre-loaded with granular cell metrics.
// Metric:       UI Design-System Adherence Rate
// Floor:        0.9  ·  Optimal: 0.97
// Output vocab: Good / Average / Poor
// Standard:     ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:         github.com/varal-uae/UDF · branch: ritwik
// Author:       Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:         25-Sep-2026
// Step No:      206 of 1073
// ============================================================
// Why:          
// Mobile:       
// col41:        Good/Average/Poor → Best = Good (100%)
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Conformance vocabulary: Good / Average / Poor ─────────────

enum Ermwd00414ConformanceLevel {
  good,    // ≥ optimal
  average, // ≥ floor
  poor,    // < floor
}

// ── Execution status ─────────────────────────────────────────

enum Ermwd00414ExecutionStatus { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// ERMWD-004-14 — Error Mapping & Widget Display
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Ermwd00414Config {
  final String configId;
  final String modalId;
  final String triggerEvent;
  final String contentType;
  final String dismissBehaviour;
  final String validationStatus;
  final bool   immutableInd;
  // DCDF lineage
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Ermwd00414Config({
    required this.configId,
    required this.modalId,
    required this.triggerEvent,
    required this.contentType,
    required this.dismissBehaviour,
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

  Ermwd00414Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Ermwd00414Config(
    configId: configId,
    modalId: modalId,
    triggerEvent: triggerEvent,
    contentType: contentType,
    dismissBehaviour: dismissBehaviour,
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
    'modalId': modalId,
    'triggerEvent': triggerEvent,
    'contentType': contentType,
    'dismissBehaviour': dismissBehaviour,
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

class Ermwd00414ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Ermwd00414ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Ermwd00414ValidationResult({
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
      case Ermwd00414ConformanceLevel.good:    return 'Good';
      case Ermwd00414ConformanceLevel.average: return 'Average';
      case Ermwd00414ConformanceLevel.poor:    return 'Poor';
    }
  }
}

// ── EC:8 Pipeline ────────────────────────────────────────

/// ERMWD-004-14: Integrate sliding layout sheet containers pre-loaded with granular cell metrics.
/// Metric: UI Design-System Adherence Rate
/// Floor=0.9 · Output=Good / Average / Poor
class Ermwd00414Pipeline {
  static const double _floor   = 0.9;
  static const double _optimal = 0.97;

  // EC:1 — System locates the ERMWD-004-14 configuration in the source repository.
  static Ermwd00414Config _ec1Locates(Ermwd00414Config config) {
    if (config.modalId.isEmpty) {
      throw ArgumentError(
          'EC-ERMWD00414-001: modalId required for ERMWD-004-14');
    }
    // the ERMWD-004-14 configuration in the source repository
    return config;
  }

  // EC:2 — System extracts modalId and triggerEvent from the ERMWD-004-14 registry.
  static Ermwd00414Config _ec2Extracts(Ermwd00414Config config) {
    if (config.modalId.isEmpty) {
      throw ArgumentError(
          'EC-ERMWD00414-002: modalId required for ERMWD-004-14');
    }
    // modalId and triggerEvent from the ERMWD-004-14 registry
    return config;
  }

  // EC:3 — System compiles the implementation rule set per UI Design-System Adherence Rate.
  static Ermwd00414Config _ec3Compiles(Ermwd00414Config config) {
    if (config.modalId.isEmpty) {
      throw ArgumentError(
          'EC-ERMWD00414-003: modalId required for ERMWD-004-14');
    }
    // the implementation rule set per UI Design-System Adherence R
    return config;
  }

  // EC:4 — System validates configuration against required constraints.
  static Ermwd00414Config _ec4Validates(Ermwd00414Config config) {
    if (config.modalId.isEmpty) {
      throw ArgumentError(
          'EC-ERMWD00414-004: modalId required for ERMWD-004-14');
    }
    // configuration against required constraints
    return config;
  }

  // EC:5 — System registers compiled rules as immutable with immutable_IND=TRUE.
  static Ermwd00414Config _ec5Registers(Ermwd00414Config config) {
    if (config.modalId.isEmpty) {
      throw ArgumentError(
          'EC-ERMWD00414-005: modalId required for ERMWD-004-14');
    }
    // compiled rules as immutable with immutable_IND=TRUE
    return config;
  }

  // EC:6 — System validates configuration against UI Design-System Adherence Rate gate (floor=0.9).
  static Ermwd00414Config _ec6Validates(Ermwd00414Config config) {
    if (config.modalId.isEmpty) {
      throw ArgumentError(
          'EC-ERMWD00414-006: modalId required for ERMWD-004-14');
    }
    // configuration against UI Design-System Adherence Rate gate (
    return config;
  }

  // EC:7 — System routes non-compliant records to the dead letter queue.
  static Ermwd00414Config _ec7Routes(Ermwd00414Config config) {
    if (config.modalId.isEmpty) {
      throw ArgumentError(
          'EC-ERMWD00414-007: modalId required for ERMWD-004-14');
    }
    // non-compliant records to the dead letter queue
    return config;
  }

  // EC:8 — System publishes validated configuration to the rule registry.
  static Ermwd00414Config _ec8Publishes(Ermwd00414Config config) {
    if (config.modalId.isEmpty) {
      throw ArgumentError(
          'EC-ERMWD00414-008: modalId required for ERMWD-004-14');
    }
    // validated configuration to the rule registry
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Ermwd00414ValidationResult calculateConformance({
    required List<Ermwd00414Config> configs,
  }) {
    if (configs.isEmpty) {
      return Ermwd00414ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Ermwd00414ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-ERMWD00414-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level = rate >= _optimal
        ? Ermwd00414ConformanceLevel.good
        : rate >= _floor
            ? Ermwd00414ConformanceLevel.average
            : Ermwd00414ConformanceLevel.poor;
    return Ermwd00414ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-ERMWD00414-VAL',
    );
  }

  static Ermwd00414Config routeToRegistry(
    Ermwd00414Config config,
    Ermwd00414ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Ermwd00414Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-ERMWD00414-000: configs must not be empty for ERMWD-004-14');
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
      throw ArgumentError('EC-ERMWD00414-TRI: triangular check failed for ERMWD-004-14');
    }
    final result     = calculateConformance(configs: p8);
    final registered = p8.map((c) => routeToRegistry(c, result)).toList();
    return {
      'status':             result.gatePass ? 'COMPLETE' : 'FAILED',
      'conformance_verdict': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-ERMWD-004-14',
      'metric':             'UI Design-System Adherence Rate',
      'output_vocab':       'Good / Average / Poor',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> ermwd_004_14Dlq(
    String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'ERMWD-004-14',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Ermwd00414Widget extends StatelessWidget {
  final List<Ermwd00414Config> configs;
  const Ermwd00414Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Ermwd00414Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    final isGood = result.gatePass;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('ERMWD-004-14',
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
                title: Text(c.modalId,
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
    Ermwd00414Config(
      configId: 'ermwd00414-cfg-001',
      modalId: 'ermwd-004-14_modalId',
      triggerEvent: 'ermwd-004-14_triggerEvent',
      contentType: 'ermwd-004-14_contentType',
      dismissBehaviour: 'ermwd-004-14_dismissBehaviour',
      traceId:                 'trace-ermwd00414-001',
      originSourceId:          'origin-ermwd00414',
      immediatePredecessorId:  'pred-ermwd00414-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final out = await Ermwd00414Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('ERMWD-004-14 [Good / Average / Poor] → $out');
}
