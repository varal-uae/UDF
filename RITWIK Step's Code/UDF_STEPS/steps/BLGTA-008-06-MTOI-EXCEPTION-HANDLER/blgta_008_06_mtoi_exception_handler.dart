// ============================================================
// BLGTA-008-06 | OCR Failure MTOI Exception Handler
// Atomic Task: Build simplified, zoomed-in mobile interface for MTOI human workers.
// Primary Table: mtoi_exception_registry
// Metric: MTOI Exception Handling Time
//         Floor=<=60min | Optimal=<=30min | Ceiling=<=15min (BPO SLA)
// Output: Good (≤15min) / Average (≤30min) / Poor (≤60min)
// EC Lines: 8 | Standard: ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Constraints: zoom_min >= 2.0 | contrast_ratio_min >= 4.5 (WCAG AA)
// Lineage: Resolved records must populate origin_source_ID + transformation_logic_hash
// Repo: github.com/RitwikHC/theme-typography · branch: ritwik
// Author: Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date: 29-Aug-2026
// ============================================================

import 'package:flutter/material.dart';

// ── Data Models ──────────────────────────────────────────────

enum ExecutionStatus { pending, running, complete, failed }

enum StepOutcome { complete, partial, notComplete }

enum MtouHandlingOutput { good, average, poor }

enum MtouDeviceType { mobile, tablet }

/// Maps to mtoi_exception_registry.
/// zoom_min >= 2.0 and contrast_ratio_min >= 4.5 enforced by CHECK at DB level.
class MtoiExceptionEntry {
  final String mtoiRuleId;              // PK — UUID
  final String mobilePlatform;          // iOS / Android
  final String osVersion;               // min OS for MTOI worker device
  final MtouDeviceType deviceType;     // MOBILE / TABLET
  final String screenDimensions;        // e.g. 360x800dp
  final double zoomMin;                 // min zoom multiplier; >= 2.0
  final double contrastRatioMin;        // WCAG AA min contrast; >= 4.5
  final int resolutionTimeMin;          // measured BPO SLA time in minutes
  final bool lineageReintegrated;       // origin_source_ID + hash populated
  final bool immutableInd;
  final ExecutionStatus executionStatus;
  final StepOutcome stepOutcome;
  final bool complianceStatusInd;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;

  const MtoiExceptionEntry({
    required this.mtoiRuleId,
    required this.mobilePlatform,
    required this.osVersion,
    required this.deviceType,
    required this.screenDimensions,
    required this.zoomMin,
    required this.contrastRatioMin,
    required this.resolutionTimeMin,
    this.lineageReintegrated = false,
    this.immutableInd = false,
    this.executionStatus = ExecutionStatus.pending,
    this.stepOutcome = StepOutcome.partial,
    this.complianceStatusInd = true,
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
  })  :     if (!(zoomMin >= 2.0)) {
      throw ArgumentError('EC-BLGTA008-06-003: zoomMin must be >= 2.0');
    },
            if (!(contrastRatioMin >= 4.5)) {
      throw ArgumentError('EC-BLGTA008-06-003: contrastRatioMin must be >= 4.5 (WCAG AA)');
    };

  static const double kMinZoom        = 2.0;
  static const double kMinContrast    = 4.5;
  static const int    kCeilingMinutes = 15;
  static const int    kOptimalMinutes = 30;
  static const int    kFloorMinutes   = 60;

  /// EC:6 gate — constraints met AND resolution within floor  // error: EC-BLGTA00806-001
  bool get isConformant =>
      zoomMin >= kMinZoom &&
      contrastRatioMin >= kMinContrast &&
      resolutionTimeMin <= kFloorMinutes;

  MtouHandlingOutput get handlingOutput {
    if (resolutionTimeMin <= kCeilingMinutes) return MtouHandlingOutput.good;
    if (resolutionTimeMin <= kOptimalMinutes) return MtouHandlingOutput.average;
    if (resolutionTimeMin <= kFloorMinutes)   return MtouHandlingOutput.poor;
    return MtouHandlingOutput.poor; // below floor — will fail gate
  }

  String get handlingLabel => switch (handlingOutput) {
    MtouHandlingOutput.good    => 'Good (≤15min) ✓',
    MtouHandlingOutput.average => 'Average (≤30min)',
    MtouHandlingOutput.poor    => 'Poor (≤60min) ✗',
  };

  Color get handlingColor => switch (handlingOutput) {
    MtouHandlingOutput.good    => cs.tertiary,
    MtouHandlingOutput.average => const Color(0xFFE37400),
    MtouHandlingOutput.poor    => cs.error,
  };

  MtoiExceptionEntry copyWith({
    bool? lineageReintegrated,
    bool? immutableInd,
    ExecutionStatus? executionStatus,
    StepOutcome? stepOutcome,
    bool? complianceStatusInd,
  }) {
    return MtoiExceptionEntry(
      mtoiRuleId:              mtoiRuleId,
      mobilePlatform:          mobilePlatform,
      osVersion:               osVersion,
      deviceType:              deviceType,
      screenDimensions:        screenDimensions,
      zoomMin:                 zoomMin,
      contrastRatioMin:        contrastRatioMin,
      resolutionTimeMin:       resolutionTimeMin,
      lineageReintegrated:     lineageReintegrated ?? this.lineageReintegrated,
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

/// Scan result — maps to mtoi_validation_log.
class MtoiExceptionScanResult {
  final int violationCount;
  final int goodCount;
  final int averageCount;
  final int poorCount;
  final int lineagePendingCount;
  final String result;
  final String ecLineRef;

  const MtoiExceptionScanResult({
    required this.violationCount,
    required this.goodCount,
    required this.averageCount,
    required this.poorCount,
    required this.lineagePendingCount,
    required this.result,
    required this.ecLineRef,
  });
}

// ── EC:1–8 Pipeline ──────────────────────────────────────────

class Blgta00806MtoiExceptionHandler {
  static const double _floor   = 0.90;  // metric floor gate
  static const double _optimal = 0.97; // metric optimal target


  // EC:1 — Locate MTOI exception handler config in blgta-008-kit repo.  // error: EC-BLGTA00806-002
  static Map<String, dynamic>? locateConfiguration(String repoPath) {
        if (!(repoPath.isNotEmpty)) {
      throw ArgumentError('EC-BLGTA008-06-001: repo path must not be empty');
    };
    return {'ref': 'BLGTA-008-06', 'config_file': 'blgta-008-06.yaml'};
  }

  // EC:2 — Extract mtoiRuleId, mobilePlatform, osVersion, deviceType, screenDimensions.  // error: EC-BLGTA00806-003
  static Map<String, dynamic> extractParameters(Map<String, dynamic> config) {
    const required = [
      'mtoi_rule_id', 'mobile_platform', 'os_version',
      'device_type', 'screen_dimensions',
    ];
    if (!(required.every((k) => config.containsKey(k) && config[k] != null))) {
      throw ArgumentError('EC-BLGTA008-06-002: all 5 MTOI device fields must be non-null',
    );
    return Map<String, dynamic>.from(config);
  }

  // EC:3 — Compile MTOI interface rule set:  // error: EC-BLGTA00806-004
  //         single-column layout, zoom_min=2x, contrast >= 4.5 (WCAG AA),
  //         MD3 progressive disclosure, typography MD3 hierarchy.
  static Map<String, dynamic> compileRuleSet() {
    return {
      'layout':           'single_column',
      'zoom_min':         MtoiExceptionEntry.kMinZoom,
      'contrast_min':     MtoiExceptionEntry.kMinContrast,
      'md3_progressive':  true,
      'floor_minutes':    MtoiExceptionEntry.kFloorMinutes,
      'optimal_minutes':  MtoiExceptionEntry.kOptimalMinutes,
      'ceiling_minutes':  MtoiExceptionEntry.kCeilingMinutes,
      'ref':              'BLGTA-008-06',
      'immutable':        true,
    };
  }

  // EC:4 — Register compiled MTOI rule set as immutable in  // error: EC-BLGTA00806-005
  //         mtoi_exception_registry with immutable_IND=TRUE.
  static MtoiExceptionEntry registerRule(MtoiExceptionEntry entry) {
        if (!(entry.zoomMin >= MtoiExceptionEntry.kMinZoom)) {
      throw ArgumentError('EC-BLGTA008-06-003: zoomMin < 2.0');
    }
    };
        if (!(entry.contrastRatioMin >= MtoiExceptionEntry.kMinContrast)) {
      throw ArgumentError('EC-BLGTA008-06-003: contrastRatioMin < 4.5 (WCAG AA)');
    };
    return entry.copyWith(
      immutableInd:    true,
      executionStatus: ExecutionStatus.running,
    );
  }

  // EC:5 — Bind each MTOI rule to OCR failure handler  // error: EC-BLGTA00806-006
  //         via ocr_failure_handler_FK constraint.
  static String bindToTarget(String ruleId, String mobilePlatform) {
        if (!(ruleId.isNotEmpty)) {
      throw ArgumentError('EC-BLGTA008-06-005: FK bind requires valid ruleId');
    };
    return '$mobilePlatform:$ruleId';
  }

  // EC:6 — Validate: single-column renders, zoom >= 2x, contrast >= 4.5,  // error: EC-BLGTA00806-007
  //         MTOI worker resolves within BPO SLA.
  static MtoiExceptionScanResult validateConformance(
    List<MtoiExceptionEntry> entries,
  ) {
    final violations = entries.where((e) => !e.isConformant).length;
    final good    = entries.where((e) => e.handlingOutput == MtouHandlingOutput.good).length;
    final average = entries.where((e) => e.handlingOutput == MtouHandlingOutput.average).length;
    final poor    = entries.where((e) => e.handlingOutput == MtouHandlingOutput.poor).length;
    final lineagePending = entries.where((e) => !e.lineageReintegrated).length;
    return MtoiExceptionScanResult(
      violationCount:     violations,
      goodCount:          good,
      averageCount:       average,
      poorCount:          poor,
      lineagePendingCount: lineagePending,
      result:             violations == 0 ? 'PASS' : 'FAIL',
      ecLineRef:          'EC-BLGTA008-06-006',
    );
  }

  // EC:7 — Validate against MTOI Exception Handling Time metric.  // error: EC-BLGTA00806-008
  //         Floor=<=60min; Optimal=<=30min; Ceiling=<=15min (BPO SLA).
  static String evaluateMetric(MtoiExceptionScanResult scan) {
    return scan.violationCount == 0 ? 'PASS' : 'FAIL';
  }

  // EC:8 — Route validated MTOI config to blgta_rule_registry  // error: EC-BLGTA00806-009
  //         as authoritative BLGTA-008-06 MTOI Handler entry.
  static MtoiExceptionEntry routeToRegistry(
    MtoiExceptionEntry entry,
    MtoiExceptionScanResult scan,
  ) {
    final passed = scan.violationCount == 0;
    return entry.copyWith(
      lineageReintegrated: passed,  // flag lineage chain restored
      executionStatus:     passed ? ExecutionStatus.complete : ExecutionStatus.failed,
      stepOutcome:         passed ? StepOutcome.complete : StepOutcome.notComplete,
      complianceStatusInd: passed,
    );
  }
  // Triangular Check — DCDF AEETE-018: source_count - destination_count == 0
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

}

// ── Widget ───────────────────────────────────────────────────

class Blgta00806MtoiExceptionWidget extends StatelessWidget {
  final List<MtoiExceptionEntry> entries;
  const Blgta00806MtoiExceptionWidget({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scan   = Blgta00806MtoiExceptionHandler.validateConformance(entries);
    final metric = Blgta00806MtoiExceptionHandler.evaluateMetric(scan);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('BLGTA-008-06 · MTOI Exception Handler (BPO SLA)',
              style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 12))),
            Chip(
              label: Text('Good:${scan.goodCount} Avg:${scan.averageCount} Poor:${scan.poorCount}',
                style: const TextStyle(color: Colors.white, fontSize: 11)),
              backgroundColor: metric == 'PASS'
                  ? cs.tertiary : cs.error,
            ),
          ]),
        ),
        if (scan.lineagePendingCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              '⚠ Lineage reintegration pending for ${scan.lineagePendingCount} record(s)',
              style: const TextStyle(fontSize: 11, color: Color(0xFFE37400)),
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
                title: Text('${e.mobilePlatform} · ${e.screenDimensions}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                subtitle: Text(
                  'zoom: ${e.zoomMin.toStringAsFixed(1)}x | contrast: ${e.contrastRatioMin.toStringAsFixed(1)} | time: ${e.resolutionTimeMin}min | lineage: ${e.lineageReintegrated ? "✓" : "pending"}',
                  style: const TextStyle(fontSize: 11)),
                trailing: Chip(
                  label: Text(e.handlingLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 9)),
                  backgroundColor: e.handlingColor,
                ),
                leading: Icon(
                  pass ? Icons.assignment_turned_in : Icons.assignment_late,
                  color: pass ? cs.tertiary : cs.error,
                ),
              ),
            );
          },
        )),
      ],
    );
  }
}
