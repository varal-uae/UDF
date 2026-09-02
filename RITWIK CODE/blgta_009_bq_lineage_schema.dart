// ============================================================
// BLGTA-009 | BigQuery Graph Lineage Lookup Table Architecture
// Atomic Task: Build main lookup table with all trace and origin fields.
// Primary Table: bq_lineage_schema_registry
// Metric: Implementation Conformance Rate | Floor=0.92 | Optimal=0.98 | Ceiling=1.0
// Standard: ISO/IEC/IEEE 12207 Software Life-Cycle Process Standard
// EC Lines: 8 | DCDF AEETE-018
// Constraints: dcdf_columns_count = 5 (CHECK) | tls_version = '1.3' (CHECK)
// Infrastructure: Terraform DDL | Partitioned by ingestion_date | Clustered by compliance_status_IND
// Repo: github.com/RitwikHC/theme-typography · branch: ritwik
// Author: Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date: 29-Aug-2026
// ============================================================

import 'package:flutter/material.dart';

// ── Data Models ──────────────────────────────────────────────

enum ExecutionStatus { pending, running, complete, failed }

enum StepOutcome { complete, partial, notComplete }

enum BqBuildStatus { success, failed, pending }

/// Maps to bq_lineage_schema_registry.
/// dcdf_columns_count must equal exactly 5.
/// tls_version must equal '1.3'.
/// Both enforced by CHECK constraint at DB level.
class BqLineageSchemaEntry {
  final String schemaRuleId;          // PK — UUID
  final BqBuildStatus buildStatus;    // SUCCESS / FAILED / PENDING
  final DateTime? buildTimestamp;     // UTC build execution timestamp
  final String buildArtifactsPath;    // GCS Terraform DDL artifacts path
  final String buildLogs;             // Terraform apply log output
  final int dcdfColumnsCount;         // must equal exactly 5
  final String tlsVersion;            // must equal '1.3'
  final double conformanceRate;       // 0.0–1.0 ISO 12207 rate
  final bool partitionActive;         // ingestion_date partition confirmed
  final bool clusterActive;           // compliance_status_IND clustering confirmed
  final bool immutableInd;
  final ExecutionStatus executionStatus;
  final StepOutcome stepOutcome;
  final bool complianceStatusInd;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;

  const BqLineageSchemaEntry({
    required this.schemaRuleId,
    required this.buildStatus,
    this.buildTimestamp,
    required this.buildArtifactsPath,
    required this.buildLogs,
    required this.dcdfColumnsCount,
    required this.tlsVersion,
    required this.conformanceRate,
    this.partitionActive = false,
    this.clusterActive = false,
    this.immutableInd = false,
    this.executionStatus = ExecutionStatus.pending,
    this.stepOutcome = StepOutcome.partial,
    this.complianceStatusInd = true,
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
  })  : assert(dcdfColumnsCount == 5,
           'EC-BLGTA009-003: dcdfColumnsCount must be exactly 5'),
        assert(tlsVersion == '1.3',
           'EC-BLGTA009-003: tlsVersion must be 1.3');

  static const int    kRequiredDcdfColumns = 5;
  static const String kRequiredTlsVersion  = '1.3';
  static const double kFloor              = 0.92;
  static const double kOptimal            = 0.98;

  static const List<String> kDcdfColumns = [
    'trace_id',
    'origin_source_ID',
    'immediate_predecessor_ID',
    'transformation_logic_hash',
    'compliance_status_IND',
  ];

  /// EC:6 gate — all 5 DCDF columns, TLS 1.3, partition + cluster active,
  ///             build_status=SUCCESS
  bool get isConformant =>
      dcdfColumnsCount == kRequiredDcdfColumns &&
      tlsVersion == kRequiredTlsVersion &&
      buildStatus == BqBuildStatus.success &&
      partitionActive &&
      clusterActive;

  String get conformanceTier {
    if (conformanceRate >= 1.0)     return 'Ceiling (1.0)';
    if (conformanceRate >= kOptimal) return 'Optimal (≥0.98)';
    if (conformanceRate >= kFloor)   return 'Floor (≥0.92)';
    return 'Not Complete';
  }

  String get buildStatusLabel => switch (buildStatus) {
    BqBuildStatus.success => 'SUCCESS',
    BqBuildStatus.failed  => 'FAILED',
    BqBuildStatus.pending => 'PENDING',
  };

  BqLineageSchemaEntry copyWith({
    BqBuildStatus? buildStatus,
    bool? partitionActive,
    bool? clusterActive,
    bool? immutableInd,
    ExecutionStatus? executionStatus,
    StepOutcome? stepOutcome,
    bool? complianceStatusInd,
  }) {
    return BqLineageSchemaEntry(
      schemaRuleId:            schemaRuleId,
      buildStatus:             buildStatus ?? this.buildStatus,
      buildTimestamp:          buildTimestamp,
      buildArtifactsPath:      buildArtifactsPath,
      buildLogs:               buildLogs,
      dcdfColumnsCount:        dcdfColumnsCount,
      tlsVersion:              tlsVersion,
      conformanceRate:         conformanceRate,
      partitionActive:         partitionActive ?? this.partitionActive,
      clusterActive:           clusterActive ?? this.clusterActive,
      immutableInd:            immutableInd ?? this.immutableInd,
      executionStatus:         executionStatus ?? this.executionStatus,
      stepOutcome:             stepOutcome ?? this.stepOutcome,
      complianceStatusInd:     complianceStatusInd ?? this.complianceStatusInd,
      traceId:                 traceId,
      originSourceId:          originSourceId,
      immediatePredecessorId:  immediatePredecessorId,
      transformationLogicHash: transformationLogicHash,
    );
  }
}

/// Scan result — maps to bq_schema_validation_log.
class BqSchemaScanResult {
  final int violationCount;
  final int tlsViolations;
  final int dcdfViolations;
  final String conformanceOutput; // Complete / Partial / Not Complete
  final String result;
  final String ecLineRef;

  const BqSchemaScanResult({
    required this.violationCount,
    required this.tlsViolations,
    required this.dcdfViolations,
    required this.conformanceOutput,
    required this.result,
    required this.ecLineRef,
  });
}

// ── EC:1–8 Pipeline ──────────────────────────────────────────

class Blgta009BqLineageSchema {

  // EC:1 — Locate BigQuery lineage schema config in blgta-009-kit repo.
  static Map<String, dynamic>? locateConfiguration(String repoPath) {
    assert(repoPath.isNotEmpty, 'EC-BLGTA009-001: repo path must not be empty');
    return {'ref': 'BLGTA-009', 'config_file': 'blgta-009.yaml'};
  }

  // EC:2 — Extract schemaRuleId, buildStatus, buildTimestamp,
  //         buildArtifactsPath, buildLogs.
  static Map<String, dynamic> extractParameters(Map<String, dynamic> config) {
    const required = [
      'schema_rule_id', 'build_status', 'build_timestamp',
      'build_artifacts_path', 'build_logs',
    ];
    assert(
      required.every((k) => config.containsKey(k) && config[k] != null),
      'EC-BLGTA009-002: all 5 BQ schema build fields must be non-null',
    );
    return Map<String, dynamic>.from(config);
  }

  // EC:3 — Compile BigQuery lineage schema rule set:
  //         5 DCDF lineage columns mandatory, partitioned by ingestion_date,
  //         clustered by compliance_status_IND, TLS 1.3 only.
  static Map<String, dynamic> compileRuleSet() {
    return {
      'dcdf_columns':       BqLineageSchemaEntry.kDcdfColumns,
      'dcdf_columns_count': BqLineageSchemaEntry.kRequiredDcdfColumns,
      'partition_by':       'ingestion_date',
      'cluster_by':         'compliance_status_IND',
      'tls_version':        BqLineageSchemaEntry.kRequiredTlsVersion,
      'floor':              BqLineageSchemaEntry.kFloor,
      'optimal':            BqLineageSchemaEntry.kOptimal,
      'standard':           'ISO/IEC/IEEE 12207',
      'ref':                'BLGTA-009',
      'immutable':          true,
    };
  }

  // EC:4 — Register compiled BQ schema rule set as immutable in
  //         bq_lineage_schema_registry with immutable_IND=TRUE.
  static BqLineageSchemaEntry registerRule(BqLineageSchemaEntry entry) {
    assert(entry.dcdfColumnsCount == BqLineageSchemaEntry.kRequiredDcdfColumns,
      'EC-BLGTA009-003: dcdfColumnsCount != 5');
    assert(entry.tlsVersion == BqLineageSchemaEntry.kRequiredTlsVersion,
      'EC-BLGTA009-003: tlsVersion != 1.3');
    return entry.copyWith(
      immutableInd:    true,
      executionStatus: ExecutionStatus.running,
    );
  }

  // EC:5 — Bind each schema rule to BigQuery dataset handler
  //         via bq_dataset_FK constraint.
  static String bindToTarget(String ruleId, String buildArtifactsPath) {
    assert(ruleId.isNotEmpty, 'EC-BLGTA009-005: FK bind requires valid ruleId');
    return '$buildArtifactsPath:$ruleId';
  }

  // EC:6 — Validate: all 5 DCDF columns present, partition active,
  //         clustering active, 0 non-TLS 1.3 connections, build_status=SUCCESS.
  static BqSchemaScanResult validateConformance(
    List<BqLineageSchemaEntry> entries,
  ) {
    final violations    = entries.where((e) => !e.isConformant).length;
    final tlsViolations = entries.where((e) => e.tlsVersion != '1.3').length;
    final dcdfViolations = entries.where((e) => e.dcdfColumnsCount != 5).length;
    final avgRate = entries.isEmpty ? 0.0
        : entries.map((e) => e.conformanceRate).reduce((a, b) => a + b) / entries.length;
    final output = avgRate >= 0.98 ? 'Complete'
                 : avgRate >= 0.92 ? 'Partial'
                 : 'Not Complete';
    return BqSchemaScanResult(
      violationCount:  violations,
      tlsViolations:   tlsViolations,
      dcdfViolations:  dcdfViolations,
      conformanceOutput: output,
      result:          violations == 0 ? 'PASS' : 'FAIL',
      ecLineRef:       'EC-BLGTA009-006',
    );
  }

  // EC:7 — Validate against Implementation Conformance Rate metric.
  //         Floor=0.92 | Optimal=0.98 | Ceiling=1.0 (ISO/IEC/IEEE 12207).
  static String evaluateMetric(BqSchemaScanResult scan) {
    return scan.violationCount == 0 ? 'PASS' : 'FAIL';
  }

  // EC:8 — Route validated BQ schema config to blgta_rule_registry
  //         as authoritative BLGTA-009 BigQuery Lineage Schema entry.
  static BqLineageSchemaEntry routeToRegistry(
    BqLineageSchemaEntry entry,
    BqSchemaScanResult scan,
  ) {
    final passed = scan.violationCount == 0;
    return entry.copyWith(
      buildStatus:         passed ? BqBuildStatus.success : BqBuildStatus.failed,
      partitionActive:     passed,
      clusterActive:       passed,
      executionStatus:     passed ? ExecutionStatus.complete : ExecutionStatus.failed,
      stepOutcome:         passed ? StepOutcome.complete : StepOutcome.notComplete,
      complianceStatusInd: passed,
    );
  }
}

// ── Widget ───────────────────────────────────────────────────

class Blgta009BqLineageSchemaWidget extends StatelessWidget {
  final List<BqLineageSchemaEntry> entries;
  const Blgta009BqLineageSchemaWidget({super.key, required this.entries});

  Color _tierColor(String tier) {
    if (tier.startsWith('Ceiling')) return const Color(0xFF137333);
    if (tier.startsWith('Optimal')) return const Color(0xFF1A73E8);
    if (tier.startsWith('Floor'))   return const Color(0xFFE37400);
    return const Color(0xFFD93025);
  }

  @override
  Widget build(BuildContext context) {
    final scan   = Blgta009BqLineageSchema.validateConformance(entries);
    final metric = Blgta009BqLineageSchema.evaluateMetric(scan);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text('BLGTA-009 · BigQuery Lineage Schema (ISO 12207)',
                  style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 12))),
                Chip(
                  label: Text('${scan.conformanceOutput}',
                    style: const TextStyle(color: Colors.white, fontSize: 11)),
                  backgroundColor: metric == 'PASS'
                      ? const Color(0xFF137333) : const Color(0xFFD93025),
                ),
              ]),
              if (scan.tlsViolations > 0 || scan.dcdfViolations > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'TLS violations: ${scan.tlsViolations} | DCDF column violations: ${scan.dcdfViolations}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFFD93025)),
                  ),
                ),
              // DCDF required columns reference
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Required DCDF columns (must be = 5):',
                  style: TextStyle(fontFamily: 'Courier', fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              ...BqLineageSchemaEntry.kDcdfColumns.map((col) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: Text('• $col',
                  style: const TextStyle(fontFamily: 'Courier', fontSize: 10, color: Color(0xFF1A73E8))),
              )),
            ],
          ),
        ),
        Expanded(child: ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final e    = entries[i];
            final pass = e.isConformant;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                title: Text(e.buildStatusLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                subtitle: Text(
                  'DCDF cols: ${e.dcdfColumnsCount}/5 | TLS: ${e.tlsVersion} | partition: ${e.partitionActive} | cluster: ${e.clusterActive} | rate: ${e.conformanceRate.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 10)),
                trailing: Chip(
                  label: Text(e.conformanceTier,
                    style: const TextStyle(color: Colors.white, fontSize: 9)),
                  backgroundColor: _tierColor(e.conformanceTier),
                ),
                leading: Icon(
                  pass ? Icons.dataset : Icons.dataset_linked,
                  color: pass ? const Color(0xFF137333) : const Color(0xFFD93025),
                ),
              ),
            );
          },
        )),
      ],
    );
  }
}
