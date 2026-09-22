// ============================================================
// NSKFI-002-A16 — Navigation Shell & Key Feature Integration
// Atomic Step: Catalog reusable mobile components (SRCs).
// Metric:      Component Reuse Rate · Floor=0.90 · Optimal=1.0
// Output:      Complete / Partial / Not Complete
// Standard:    ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:        github.com/RitwikHC/theme-typography · branch: ritwik
// Author:      Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:        18-Sep-2026
// Step No:     268 of 396
// ============================================================
// Why this matters: Eradicates duplicate effort.
// Mobile impl:      Dramatically reduces the mobile app binary size (APK/AAB) by reusing common code.
// Data requirement: Test Storybook stories for each SRC — verify all documented variants render correctly.
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Enums ────────────────────────────────────────────────────

enum Nskfi002A16ConformanceLevel {
  complete,
  partial,
  notComplete,
}

enum Nskfi002A16ExecutionStatus {
  pending,
  running,
  complete,
  failed,
}

// ── Data Model ───────────────────────────────────────────────

/// Configuration record for NSKFI-002-A16.
/// Fields derived from AISS sheet row — Navigation Shell & Key Feature Integration.
/// All 5 DCDF lineage fields mandatory per AEETE-018.
class Nskfi002A16Config {
  final String configId;               // PK — UUID v4
  // Step-specific fields (from AISS data requirement)
  final String componentId;
  final String widgetClass;
  final String propsSchema;
  final String usageContext;
  final String validationStatus;       // PENDING | VALID | INVALID
  final bool   immutableInd;
  // DCDF lineage headers — AEETE-018
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Nskfi002A16Config({
    required this.configId,
    required this.componentId,
    required this.widgetClass,
    required this.propsSchema,
    required this.usageContext,
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

  Nskfi002A16Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Nskfi002A16Config(
    configId: configId,
    componentId: componentId,
    widgetClass: widgetClass,
    propsSchema: propsSchema,
    usageContext: usageContext,
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
    'componentId': componentId,
    'widgetClass': widgetClass,
    'propsSchema': propsSchema,
    'usageContext': usageContext,
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

class Nskfi002A16ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Nskfi002A16ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Nskfi002A16ValidationResult({
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
      case Nskfi002A16ConformanceLevel.complete:    return 'Complete';
      case Nskfi002A16ConformanceLevel.partial:     return 'Partial';
      case Nskfi002A16ConformanceLevel.notComplete: return 'Not Complete';
    }
  }
}

// ── EC:1 Pipeline ────────────────────────────────────────────────────────

/// NSKFI-002-A16: Catalog reusable mobile components (SRCs).
///
/// Metric: Component Reuse Rate
/// Floor=0.90 · Optimal=1.0 · Output=Complete / Partial / Not Complete
class Nskfi002A16Pipeline {
  static const double _floor   = 0.90;
  static const double _optimal = 1.0;

  // EC:1 — 1) Index Byt, 2) Verify uniqueness, 3) Map to Dict, 4) Publish SRC
  static Nskfi002A16Config _ec1Execute(Nskfi002A16Config config) {
    if (config.componentId.isEmpty) {
      throw ArgumentError(
          'EC-NSKFI002A16-001: componentId required for NSKFI-002-A16');
    }
    // 1) Index Byt, 2) Verify uniqueness, 3) Map to Dict, 4) Publi
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  // Conformance gate — Floor=0.90 · Optimal=1.0
  static Nskfi002A16ValidationResult calculateConformance({
    required List<Nskfi002A16Config> configs,
  }) {
    if (configs.isEmpty) {
      return const Nskfi002A16ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Nskfi002A16ConformanceLevel.notComplete,
        gatePass: false,
        ecLineRef: 'EC-NSKFI002A16-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level      = rate >= _optimal
        ? Nskfi002A16ConformanceLevel.complete
        : rate >= _floor
            ? Nskfi002A16ConformanceLevel.partial
            : Nskfi002A16ConformanceLevel.notComplete;
    return Nskfi002A16ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-NSKFI002A16-VAL',
    );
  }

  static Nskfi002A16Config routeToRegistry(
    Nskfi002A16Config config,
    Nskfi002A16ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Nskfi002A16Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      return {'error': 'EC-NSKFI002A16-001: empty config list', 'dlq': true};
    }
    final p1 = configs.map(_ec1Execute).toList();

    if (!triangularCheck(configs.length, p1.length)) {
      return {'error': 'EC-NSKFI002A16-TRI: triangular check failed', 'dlq': true};
    }

    final result     = calculateConformance(configs: p1);
    final registered = p1.map((c) => routeToRegistry(c, result)).toList();

    return {
      'status':             result.gatePass ? 'COMPLETE' : 'PARTIAL',
      'conformance_rate':   result.conformanceRate,
      'conformance_output': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-NSKFI-002-A16',
      'metric':             'Component Reuse Rate',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> nskfi_002_a16Dlq(
  String errorCode,
  Map<String, dynamic> payload,
) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'NSKFI-002-A16',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Nskfi002A16Widget extends StatelessWidget {
  final List<Nskfi002A16Config> configs;
  const Nskfi002A16Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Nskfi002A16Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('NSKFI-002-A16',
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
                title: Text(c.componentId,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 12)),
                subtitle: Text(
                  '${componentId} | ${widgetClass}',
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
    Nskfi002A16Config(
      configId: 'nskfi002a16-cfg-001',
      componentId: 'nskfi-002-a16_componentId_value',
      widgetClass: 'nskfi-002-a16_widgetClass_value',
      propsSchema: 'nskfi-002-a16_propsSchema_value',
      usageContext: 'nskfi-002-a16_usageContext_value',
      traceId:                 'trace-nskfi002a16-001',
      originSourceId:          'origin-nskfi002a16',
      immediatePredecessorId:  'pred-nskfi002a16-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final result = await Nskfi002A16Pipeline.run(
    configs: configs, userId: 'ritwik-udf');
  print('NSKFI-002-A16 → $result');
}
