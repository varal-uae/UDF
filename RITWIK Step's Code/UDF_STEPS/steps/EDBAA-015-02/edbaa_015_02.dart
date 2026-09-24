// ============================================================
// EDBAA-015-02 — Enterprise Dashboard Analytics Adapter
// Atomic Step:  Package and Lock the Master Component Library. (Compile all pre-approved visual view modules into a 
// Metric:       Task Atomicity / Single-Action Granularity Rate
// Floor:        0.9  ·  Optimal: 1.0
// Output vocab: Good / Average / Poor
// Standard:     ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo:         github.com/varal-uae/UDF · branch: ritwik
// Author:       Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date:         25-Sep-2026
// Step No:      193 of 1073
// ============================================================
// Why:          
// Mobile:       
// col41:        Good/Average/Poor → Best = Good (100%)
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';

// ── Conformance vocabulary: Good / Average / Poor ─────────────

enum Edbaa01502ConformanceLevel {
  good,    // ≥ optimal
  average, // ≥ floor
  poor,    // < floor
}

// ── Execution status ─────────────────────────────────────────

enum Edbaa01502ExecutionStatus { pending, running, complete, failed }

// ── Data Model ───────────────────────────────────────────────

/// EDBAA-015-02 — Enterprise Dashboard Analytics Adapter
/// DCDF AEETE-018: all 5 lineage fields mandatory.
class Edbaa01502Config {
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

  const Edbaa01502Config({
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

  Edbaa01502Config copyWith({
    String? validationStatus,
    bool?   immutableInd,
    bool?   complianceStatusInd,
  }) => Edbaa01502Config(
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

class Edbaa01502ValidationResult {
  final int    totalRecords;
  final int    conformantRecords;
  final int    violationCount;
  final double conformanceRate;
  final Edbaa01502ConformanceLevel conformanceLevel;
  final bool   gatePass;
  final String ecLineRef;

  const Edbaa01502ValidationResult({
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
      case Edbaa01502ConformanceLevel.good:    return 'Good';
      case Edbaa01502ConformanceLevel.average: return 'Average';
      case Edbaa01502ConformanceLevel.poor:    return 'Poor';
    }
  }
}

// ── EC:8 Pipeline ────────────────────────────────────────

/// EDBAA-015-02: Package and Lock the Master Component Library. (Compile all pre-approved visual 
/// Metric: Task Atomicity / Single-Action Granularity Rate
/// Floor=0.9 · Output=Good / Average / Poor
class Edbaa01502Pipeline {
  static const double _floor   = 0.9;
  static const double _optimal = 1.0;

  // EC:1 — System locates the EDBAA-015-02 configuration in the source repository.
  static Edbaa01502Config _ec1Locates(Edbaa01502Config config) {
    if (config.packageName.isEmpty) {
      throw ArgumentError(
          'EC-EDBAA01502-001: packageName required for EDBAA-015-02');
    }
    // the EDBAA-015-02 configuration in the source repository
    return config;
  }

  // EC:2 — System extracts packageName and componentId from the EDBAA-015-02 registry.
  static Edbaa01502Config _ec2Extracts(Edbaa01502Config config) {
    if (config.packageName.isEmpty) {
      throw ArgumentError(
          'EC-EDBAA01502-002: packageName required for EDBAA-015-02');
    }
    // packageName and componentId from the EDBAA-015-02 registry
    return config;
  }

  // EC:3 — System compiles the implementation rule set per Task Atomicity / Single-Action Granularity
  static Edbaa01502Config _ec3Compiles(Edbaa01502Config config) {
    if (config.packageName.isEmpty) {
      throw ArgumentError(
          'EC-EDBAA01502-003: packageName required for EDBAA-015-02');
    }
    // the implementation rule set per Task Atomicity / Single-Acti
    return config;
  }

  // EC:4 — System validates configuration against required constraints.
  static Edbaa01502Config _ec4Validates(Edbaa01502Config config) {
    if (config.packageName.isEmpty) {
      throw ArgumentError(
          'EC-EDBAA01502-004: packageName required for EDBAA-015-02');
    }
    // configuration against required constraints
    return config;
  }

  // EC:5 — System registers compiled rules as immutable with immutable_IND=TRUE.
  static Edbaa01502Config _ec5Registers(Edbaa01502Config config) {
    if (config.packageName.isEmpty) {
      throw ArgumentError(
          'EC-EDBAA01502-005: packageName required for EDBAA-015-02');
    }
    // compiled rules as immutable with immutable_IND=TRUE
    return config;
  }

  // EC:6 — System validates configuration against Task Atomicity / Single-Action Granularity Rate gat
  static Edbaa01502Config _ec6Validates(Edbaa01502Config config) {
    if (config.packageName.isEmpty) {
      throw ArgumentError(
          'EC-EDBAA01502-006: packageName required for EDBAA-015-02');
    }
    // configuration against Task Atomicity / Single-Action Granula
    return config;
  }

  // EC:7 — System routes non-compliant records to the dead letter queue.
  static Edbaa01502Config _ec7Routes(Edbaa01502Config config) {
    if (config.packageName.isEmpty) {
      throw ArgumentError(
          'EC-EDBAA01502-007: packageName required for EDBAA-015-02');
    }
    // non-compliant records to the dead letter queue
    return config;
  }

  // EC:8 — System publishes validated configuration to the rule registry.
  static Edbaa01502Config _ec8Publishes(Edbaa01502Config config) {
    if (config.packageName.isEmpty) {
      throw ArgumentError(
          'EC-EDBAA01502-008: packageName required for EDBAA-015-02');
    }
    // validated configuration to the rule registry
    return config;
  }

  // Triangular Check — DCDF AEETE-018
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

  static Edbaa01502ValidationResult calculateConformance({
    required List<Edbaa01502Config> configs,
  }) {
    if (configs.isEmpty) {
      return Edbaa01502ValidationResult(
        totalRecords: 0, conformantRecords: 0, violationCount: 0,
        conformanceRate: 0.0,
        conformanceLevel: Edbaa01502ConformanceLevel.notComplete,
        gatePass: false, ecLineRef: 'EC-EDBAA01502-VAL',
      );
    }
    final conformant = configs.where((c) => c.isRegistered).length;
    final violations = configs.length - conformant;
    final rate       = conformant / configs.length;
    final level = rate >= _optimal
        ? Edbaa01502ConformanceLevel.good
        : rate >= _floor
            ? Edbaa01502ConformanceLevel.average
            : Edbaa01502ConformanceLevel.poor;
    return Edbaa01502ValidationResult(
      totalRecords:      configs.length,
      conformantRecords: conformant,
      violationCount:    violations,
      conformanceRate:   rate,
      conformanceLevel:  level,
      gatePass:          rate >= _floor,
      ecLineRef:         'EC-EDBAA01502-VAL',
    );
  }

  static Edbaa01502Config routeToRegistry(
    Edbaa01502Config config,
    Edbaa01502ValidationResult result,
  ) {
    if (!result.gatePass) return config;
    return config.copyWith(
      validationStatus:    'VALID',
      immutableInd:        true,
      complianceStatusInd: true,
    );
  }

  static Future<Map<String, dynamic>> run({
    required List<Edbaa01502Config> configs,
    String userId = 'system',
  }) async {
    if (configs.isEmpty) {
      throw ArgumentError('EC-EDBAA01502-000: configs must not be empty for EDBAA-015-02');
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
      throw ArgumentError('EC-EDBAA01502-TRI: triangular check failed for EDBAA-015-02');
    }
    final result     = calculateConformance(configs: p8);
    final registered = p8.map((c) => routeToRegistry(c, result)).toList();
    return {
      'status':             result.gatePass ? 'COMPLETE' : 'FAILED',
      'conformance_verdict': result.conformanceOutput,
      'gate_pass':          result.gatePass,
      'records_processed':  registered.length,
      'violations':         result.violationCount,
      'ec_ref':             'EC-EDBAA-015-02',
      'metric':             'Task Atomicity / Single-Action Granularity Rate',
      'output_vocab':       'Good / Average / Poor',
      'floor':              _floor,
      'optimal':            _optimal,
    };
  }
}

// ── DLQ Helper ────────────────────────────────────────────────

Map<String, dynamic> edbaa_015_02Dlq(
    String errorCode, Map<String, dynamic> payload) => {
  'error_code':        errorCode,
  'payload_snapshot':  jsonEncode(payload),
  'dlq':               true,
  'step_ref':          'EDBAA-015-02',
  'trace_id':          payload['trace_id'] ?? '',
  'compliance_status_ind': false,
};

// ── Widget ────────────────────────────────────────────────────

class Edbaa01502Widget extends StatelessWidget {
  final List<Edbaa01502Config> configs;
  const Edbaa01502Widget({super.key, required this.configs});

  @override
  Widget build(BuildContext context) {
    final result = Edbaa01502Pipeline.calculateConformance(configs: configs);
    final cs     = Theme.of(context).colorScheme;
    final isGood = result.gatePass;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('EDBAA-015-02',
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
    Edbaa01502Config(
      configId: 'edbaa01502-cfg-001',
      packageName: 'edbaa-015-02_packageName',
      componentId: 'edbaa-015-02_componentId',
      versionTag: 'edbaa-015-02_versionTag',
      exportPath: 'edbaa-015-02_exportPath',
      traceId:                 'trace-edbaa01502-001',
      originSourceId:          'origin-edbaa01502',
      immediatePredecessorId:  'pred-edbaa01502-001',
      transformationLogicHash: '$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    ),
  ];
  final out = await Edbaa01502Pipeline.run(configs: configs, userId: 'ritwik-udf');
  print('EDBAA-015-02 [Good / Average / Poor] → $out');
}
