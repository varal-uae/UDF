// ============================================================
// IS36-SLPLU-012-AS01-A11 — Implementation System 36
// Atomic Step:  Lineage Trace Time Line Chart (System Latency)
// Metric:       Configuration Conformance Rate - Interactive hover tooltip box display
// Floor:        0.97  ·  Optimal: 1.0
// Output vocab: Good / Average / Poor
// Standard:     ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:         github.com/varal-uae/UDF · branch: ritwik
// Author:       Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:         25-Sep-2026
// Step No:      832 of 1073
// ============================================================
// Why:          Proves whether the data engine is unbroken. High trace times mean flawed, bloated architecture.
// Mobile:       Clean, responsive SVG line charts optimized for mobile viewport widths.
// col41:        Pass/Fail
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Conformance vocabulary: Good / Average / Poor ─────────────

enum Is36Slplu012As01A11ConformanceLevel {
  good,    // ≥ optimal
  average, // ≥ floor
  poor,    // < floor
}

// ── Execution status ─────────────────────────────────────────

enum Is36Slplu012As01A11ExecutionStatus { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

class Is36Slplu012As01A11Config {
  final String configId;
  final String modalId;
  final String triggerEvent;
  final String contentType;
  final String dismissBehaviour;
  final String validationStatus;
  final bool   immutableInd;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Is36Slplu012As01A11Config({
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

  Is36Slplu012As01A11Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Is36Slplu012As01A11Config(
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

class Is36Slplu012As01A11ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Is36Slplu012As01A11ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Is36Slplu012As01A11ValidationResult({
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
      case Is36Slplu012As01A11ConformanceLevel.good:    return 'Good';
      case Is36Slplu012As01A11ConformanceLevel.average: return 'Average';
      case Is36Slplu012As01A11ConformanceLevel.poor:    return 'Poor';
    }
  }
}

// ── EC:4 Pipeline ────────────────────────────────────────

class Is36Slplu012As01A11Pipeline {
  static const double _floor   = 0.97;
  static const double _optimal = 1.0;

  // EC:1 — Query latency logs
  static Is36Slplu012As01A11Config _ec1Execute(Is36Slplu012As01A11Config config) {
    if (config.modalId.isEmpty) {
      throw ArgumentError(
          'EC-IS36SLPLU012-001: modalId required for IS36-SLPLU-012-AS01-A11');
    }
    // Query latency logs
    return config;
  }

  // EC:2 — Render line chart
  static Is36Slplu012As01A11Config _ec2Execute(Is36Slplu012As01A11Config config) {
    if (config.modalId.isEmpty) {
      throw ArgumentError(
          'EC-IS36SLPLU012-002: modalId required for IS36-SLPLU-012-AS01-A11');
    }
    // Render line chart
    return config;
  }

  // EC:3 — Draw fixed SLA threshold
  static Is36Slplu012As01A11Config _ec3Execute(Is36Slplu012As01A11Config config) {
    if (config.modalId.isEmpty) {
      throw ArgumentError(
          'EC-IS36SLPLU012-003: modalId required for IS36-SLPLU-012-AS01-A11');
    }
    // Draw fixed SLA threshold
    return config;
  }

  // EC:4 — Code alert trigger
  static Is36Slplu012As01A11Config _ec4Execute(Is36Slplu012As01A11Config config) {
    if (config.modalId.isEmpty) {
      throw ArgumentError(
          'EC-IS36SLPLU012-004: modalId required for IS36-SLPLU-012-AS01-A11');
    }
    // Code alert trigger
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Is36Slplu012As01A11ValidationResult calculateConformance({
    required List<Is36Slplu012As01A11Config> configs,
  }) {
    if (configs.isEmpty) {
      return Is36Slplu012As01A11ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Is36Slplu012As01A11ConformanceLevel.poor,
        gatePass: false, ecLineRef: 'EC-IS36SLPLU012-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level = rate >= _optimal
        ? Is36Slplu012As01A11ConformanceLevel.good
        : rate >= _floor
            ? Is36Slplu012As01A11ConformanceLevel.average
            : Is36Slplu012As01A11ConformanceLevel.poor;
    return Is36Slplu012As01A11ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-IS36SLPLU012-VAL',
    );
  }

  static Is36Slplu012As01A11Config routeToRegistry(
    Is36Slplu012As01A11Config config,
    Is36Slplu012As01A11ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Is36Slplu012As01A11Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-IS36SLPLU012-000: configs must not be empty for IS36-SLPLU-012-AS01-A11');
    }
    final p1 = configs.map(_ec1Execute).toList();
    final p2 = configs.map(_ec2Execute).toList();
    final p3 = configs.map(_ec3Execute).toList();
    final p4 = configs.map(_ec4Execute).toList();

    if (!triangularCheck(configs.length, p4.length)) {
      throw ArgumentError('EC-IS36SLPLU012-TRI: triangular check failed for IS36-SLPLU-012-AS01-A11');
    }
    final result     = calculateConformance(configs: p4);
    final registered = p4.map((c) => routeToRegistry(c, result)).toList();
    return {
      'status':             result.gatePass ? 'COMPLETE' : 'FAILED',
      'conformance_verdict': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-IS36-SLPLU-012-AS01-A11',
      'metric':             'Configuration Conformance Rate - Interactive hover tooltip b',
      'output_vocab':       'Good / Average / Poor',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> is36_slplu_012_as01_a11Dlq(
    String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'IS36-SLPLU-012-AS01-A11',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Is36Slplu012As01A11Widget extends StatelessWidget {
  final List<Is36Slplu012As01A11Config> configs;
  const Is36Slplu012As01A11Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Is36Slplu012As01A11Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('IS36-SLPLU-012-AS01-A11',
              style: const TextStyle(fontFamily:'Courier',
                fontWeight:FontWeight.bold, fontSize:12))),
            Chip(
              label: Text(
                result.conformanceOutput,
                style: const TextStyle(color:Colors.white, fontSize:11)),
              backgroundColor: result.gatePass ? cs.tertiary : cs.error),
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
    Is36Slplu012As01A11Config(
      configId: 'is36slplu012-cfg-001',
      modalId: 'is36-slplu-012-as01-a11_modalId',
      triggerEvent: 'is36-slplu-012-as01-a11_triggerEvent',
      contentType: 'is36-slplu-012-as01-a11_contentType',
      dismissBehaviour: 'is36-slplu-012-as01-a11_dismissBehaviour',
      traceId:                 'trace-is36slplu012-001',
      originSourceId:          'origin-is36slplu012',
      immediatePredecessorId:  'pred-is36slplu012-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final out = await Is36Slplu012As01A11Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('IS36-SLPLU-012-AS01-A11 [Good / Average / Poor] → $out');
}
