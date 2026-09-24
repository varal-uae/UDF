// ============================================================
// SCTSS-018-A15 — Semantic Color Token Styling System
// Atomic Step:  Implement AI Rationale Accordion (Trust Layer) to decide the layout for the collapsible panel explai
// Metric:       Stakeholder Sign-off Rate (%) — sign-off from AI Product Governance le
// Floor:        1.0  ·  Optimal: 1.0
// Output vocab: Complete / Partial / Not Complete
// Standard:     ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:         github.com/varal-uae/UDF · branch: ritwik
// Author:       Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:         25-Sep-2026
// Step No:      973 of 1073
// ============================================================
// Why:          Explainability is mandatory for AI adoption. Hiding the "Why" leads to rejected AI outputs.
// Mobile:       Uses collapsible accordion sections to hide lengthy rationale text from the immediate mobile view, p
// col41:        Yes/No
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Conformance vocabulary: Complete / Partial / Not Complete ─────────────

enum Sctss018A15ConformanceLevel {
  complete,    // ≥ optimal
  partial,     // ≥ floor
  notComplete, // < floor
}

// ── Execution status ─────────────────────────────────────────

enum Sctss018A15ExecutionStatus { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// SCTSS-018-A15 — Semantic Color Token Styling System
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Sctss018A15Config {
  final String configId;
  final String fieldId;
  final String validationRule;
  final String errorMessage;
  final String inputType;
  final String validationStatus;
  final bool   immutableInd;
  // DCDF lineage
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Sctss018A15Config({
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

  Sctss018A15Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Sctss018A15Config(
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

class Sctss018A15ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Sctss018A15ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Sctss018A15ValidationResult({
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
      case Sctss018A15ConformanceLevel.complete:    return 'Complete';
      case Sctss018A15ConformanceLevel.partial:     return 'Partial';
      case Sctss018A15ConformanceLevel.notComplete: return 'Not Complete';
    }
  }
}

// ── EC:4 Pipeline ────────────────────────────────────────

/// SCTSS-018-A15: Implement AI Rationale Accordion (Trust Layer) to decide the layout for the coll
/// Metric: Stakeholder Sign-off Rate (%) — sign-off from AI Product Gov
/// Floor=1.0 · Output=Complete / Partial / Not Complete
class Sctss018A15Pipeline {
  static const double _floor   = 1.0;
  static const double _optimal = 1.0;

  // EC:1 — Design the "Show Reasoning" toggle
  static Sctss018A15Config _ec1Execute(Sctss018A15Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-SCTSS018A15-001: fieldId required for SCTSS-018-A15');
    }
    // Design the "Show Reasoning" toggle
    return config;
  }

  // EC:2 — Define data source citation format
  static Sctss018A15Config _ec2Execute(Sctss018A15Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-SCTSS018A15-002: fieldId required for SCTSS-018-A15');
    }
    // Define data source citation format
    return config;
  }

  // EC:3 — Set max-height and overflow scroll
  static Sctss018A15Config _ec3Execute(Sctss018A15Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-SCTSS018A15-003: fieldId required for SCTSS-018-A15');
    }
    // Set max-height and overflow scroll
    return config;
  }

  // EC:4 — Style confidence score integration
  static Sctss018A15Config _ec4Execute(Sctss018A15Config config) {
    if (config.fieldId.isEmpty) {
      throw ArgumentError(
          'EC-SCTSS018A15-004: fieldId required for SCTSS-018-A15');
    }
    // Style confidence score integration
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Sctss018A15ValidationResult calculateConformance({
    required List<Sctss018A15Config> configs,
  }) {
    if (configs.isEmpty) {
      return Sctss018A15ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Sctss018A15ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-SCTSS018A15-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level = rate >= _optimal
        ? Sctss018A15ConformanceLevel.complete
        : rate >= _floor
            ? Sctss018A15ConformanceLevel.partial
            : Sctss018A15ConformanceLevel.notComplete;
    return Sctss018A15ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-SCTSS018A15-VAL',
    );
  }

  static Sctss018A15Config routeToRegistry(
    Sctss018A15Config config,
    Sctss018A15ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Sctss018A15Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-SCTSS018A15-000: configs must not be empty for SCTSS-018-A15');
    }
    final p1 = configs.map(_ec1Execute).toList();
    final p2 = configs.map(_ec2Execute).toList();
    final p3 = configs.map(_ec3Execute).toList();
    final p4 = configs.map(_ec4Execute).toList();

    if (!triangularCheck(configs.length, p4.length)) {
      throw ArgumentError('EC-SCTSS018A15-TRI: triangular check failed for SCTSS-018-A15');
    }
    final result     = calculateConformance(configs: p4);
    final registered = p4.map((c) => routeToRegistry(c, result)).toList();
    return {
      'status':             result.gatePass ? 'COMPLETE' : 'FAILED',
      'conformance_verdict': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-SCTSS-018-A15',
      'metric':             'Stakeholder Sign-off Rate (%) — sign-off from AI Product Gov',
      'output_vocab':       'Complete / Partial / Not Complete',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> sctss_018_a15Dlq(
    String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'SCTSS-018-A15',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Sctss018A15Widget extends StatelessWidget {
  final List<Sctss018A15Config> configs;
  const Sctss018A15Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Sctss018A15Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    final isGood = result.gatePass;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('SCTSS-018-A15',
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
                title: Text(c.fieldId,
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
    Sctss018A15Config(
      configId: 'sctss018a15-cfg-001',
      fieldId: 'sctss-018-a15_fieldId',
      validationRule: 'sctss-018-a15_validationRule',
      errorMessage: 'sctss-018-a15_errorMessage',
      inputType: 'sctss-018-a15_inputType',
      traceId:                 'trace-sctss018a15-001',
      originSourceId:          'origin-sctss018a15',
      immediatePredecessorId:  'pred-sctss018a15-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final out = await Sctss018A15Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('SCTSS-018-A15 [Complete / Partial / Not Complete] → $out');
}
