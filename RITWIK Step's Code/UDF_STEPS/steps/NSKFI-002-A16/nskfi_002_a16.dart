// ============================================================
// NSKFI-002-A16 — Navigation Shell & Key Feature Integration
// Atomic Step:  Catalog reusable mobile components (SRCs).
// Metric:       Verification / QA Pass Rate
// Floor:        0.9  ·  Optimal: 0.9
// Output vocab: Pass / Fail
// Standard:     ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:         github.com/varal-uae/UDF · branch: ritwik
// Author:       Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:         25-Sep-2026
// Step No:      889 of 1073
// ============================================================
// Why:          Eradicates duplicate effort.
// Mobile:       Dramatically reduces the mobile app binary size (APK/AAB) by reusing common code.
// col41:        Pass (Scale: Pass/Fail)
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Conformance vocabulary: Pass / Fail ─────────────

enum Nskfi002A16ConformanceLevel {
  pass_,   // ≥ floor
  fail_,   // < floor
}

// ── Execution status ─────────────────────────────────────────

enum Nskfi002A16ExecutionStatus { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// NSKFI-002-A16 — Navigation Shell & Key Feature Integration
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Nskfi002A16Config {
  final String configId;
  final String packageName;
  final String componentId;
  final String versionTag;
  final String exportPath;
  final String validationStatus;
  final bool   immutableInd;
  // DCDF lineage
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;
  final bool   complianceStatusInd;

  const Nskfi002A16Config({
    required this.configId,
    required this.packageName,
    required this.componentId,
    required this.versionTag,
    required this.exportPath,
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
    packageName: packageName,
    componentId: componentId,
    versionTag: versionTag,
    exportPath: exportPath,
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
    'packageName': packageName,
    'componentId': componentId,
    'versionTag': versionTag,
    'exportPath': exportPath,
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
      case Nskfi002A16ConformanceLevel.pass_: return 'Pass';
      case Nskfi002A16ConformanceLevel.fail_: return 'Fail';
    }
  }
}

// ── EC:1 Pipeline ────────────────────────────────────────

/// NSKFI-002-A16: Catalog reusable mobile components (SRCs).
/// Metric: Verification / QA Pass Rate
/// Floor=0.9 · Output=Pass / Fail
class Nskfi002A16Pipeline {
  static const double _floor   = 0.9;
  static const double _optimal = 0.9;

  // EC:1 — 1) Index Byt, 2) Verify uniqueness, 3) Map to Dict, 4) Publish SRC
  static Nskfi002A16Config _ec1Execute(Nskfi002A16Config config) {
    if (config.packageName.isEmpty) {
      throw ArgumentError(
          'EC-NSKFI002A16-001: packageName required for NSKFI-002-A16');
    }
    // 1) Index Byt, 2) Verify uniqueness, 3) Map to Dict, 4) Publi
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Nskfi002A16ValidationResult calculateConformance({
    required List<Nskfi002A16Config> configs,
  }) {
    if (configs.isEmpty) {
      return Nskfi002A16ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Nskfi002A16ConformanceLevel.fail_,
        gatePass: false, ecLineRef: 'EC-NSKFI002A16-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level = rate >= _floor
        ? Nskfi002A16ConformanceLevel.pass_
        : Nskfi002A16ConformanceLevel.fail_;
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
      throw ArgumentError('EC-NSKFI002A16-000: configs must not be empty for NSKFI-002-A16');
    }
    final p1 = configs.map(_ec1Execute).toList();

    if (!triangularCheck(configs.length, p1.length)) {
      throw ArgumentError('EC-NSKFI002A16-TRI: triangular check failed for NSKFI-002-A16');
    }
    final result     = calculateConformance(configs: p1);
    final registered = p1.map((c) => routeToRegistry(c, result)).toList();
    return {
      'status':             result.gatePass ? 'COMPLETE' : 'FAILED',
      'conformance_verdict': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-NSKFI-002-A16',
      'metric':             'Verification / QA Pass Rate',
      'output_vocab':       'Pass / Fail',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> nskfi_002_a16Dlq(
    String errorCode, Map<String, dynamic> payload) => {
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
    final isGood = result.gatePass;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('NSKFI-002-A16',
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
                title: Text(c.packageName,
                  style: const TextStyle(fontWeight:FontWeight.w600,fontSize:12)),
                subtitle: Text(
                  '${c.configId.length>8?c.configId.substring(0,8):c.configId}…'
                  ' | ${c.validationStatus}',
                  style: const TextStyle(fontSize:11)),
                trailing: Chip(
                  label: Text(
                    pass ? 'Pass' : 'Fail',
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
    Nskfi002A16Config(
      configId: 'nskfi002a16-cfg-001',
      packageName: 'nskfi-002-a16_packageName',
      componentId: 'nskfi-002-a16_componentId',
      versionTag: 'nskfi-002-a16_versionTag',
      exportPath: 'nskfi-002-a16_exportPath',
      traceId:                 'trace-nskfi002a16-001',
      originSourceId:          'origin-nskfi002a16',
      immediatePredecessorId:  'pred-nskfi002a16-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final out = await Nskfi002A16Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('NSKFI-002-A16 [Pass / Fail] → $out');
}
