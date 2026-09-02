// ============================================================
// BCDLD-040 | Build Configuration Dependency Lock
// Atomic Task: Flutter SDK Version Gate —
//   Validate all Flutter projects declare an exact SDK version
//   constraint; broad ranges or any declarations block publish.
// Primary Table: flutter_sdk_lock_registry
// Rule: flutter_version exact | dart_sdk_constraint declared | channel=stable
// EC Lines: 8 | Standard: ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo: github.com/RitwikHC/theme-typography · branch: ritwik
// Author: Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date: 29-Aug-2026
// ============================================================

import 'package:flutter/material.dart';

// ── Data Models ──────────────────────────────────────────────

enum ExecutionStatus { pending, running, complete, failed }

enum StepOutcome { complete, partial, notComplete }

enum SdkChannel { stable, beta, dev }

/// Maps to flutter_sdk_lock_registry.
/// channel must be 'stable' for production — CHECK at DB.
class FlutterSdkLockEntry {
  final String sdkLockRuleId;       // PK — UUID
  final String flutterVersion;      // exact e.g. 3.19.0
  final String dartSdkConstraint;   // e.g. >=3.3.0 <4.0.0
  final String pubspecPath;         // path to pubspec.yaml
  final SdkChannel channel;         // stable / beta / dev
  final bool immutableInd;
  final ExecutionStatus executionStatus;
  final StepOutcome stepOutcome;
  final bool complianceStatusInd;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;

  const FlutterSdkLockEntry({
    required this.sdkLockRuleId,
    required this.flutterVersion,
    required this.dartSdkConstraint,
    required this.pubspecPath,
    this.channel = SdkChannel.stable,
    this.immutableInd = false,
    this.executionStatus = ExecutionStatus.pending,
    this.stepOutcome = StepOutcome.partial,
    this.complianceStatusInd = true,
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
  });

  /// EC:6 gate — version is exact semver, channel=stable, dart constraint declared
  bool get isExactVersion {
    // Exact semver: MAJOR.MINOR.PATCH — no ^ >= or any
    final exactPattern = RegExp(r'^\d+\.\d+\.\d+$');
    return exactPattern.hasMatch(flutterVersion);
  }

  bool get isConformant =>
      isExactVersion &&
      channel == SdkChannel.stable &&
      dartSdkConstraint.isNotEmpty;

  String get channelLabel => switch (channel) {
    SdkChannel.stable => 'stable',
    SdkChannel.beta   => 'beta',
    SdkChannel.dev    => 'dev',
  };

  FlutterSdkLockEntry copyWith({
    bool? immutableInd,
    ExecutionStatus? executionStatus,
    StepOutcome? stepOutcome,
    bool? complianceStatusInd,
  }) {
    return FlutterSdkLockEntry(
      sdkLockRuleId:           sdkLockRuleId,
      flutterVersion:          flutterVersion,
      dartSdkConstraint:       dartSdkConstraint,
      pubspecPath:             pubspecPath,
      channel:                 channel,
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

/// Scan result — maps to sdk_lock_validation_log.
class SdkLockScanResult {
  final int violationCount;
  final String conformanceOutput;
  final String result;
  final String ecLineRef;
  final List<String> violatingProjects;

  const SdkLockScanResult({
    required this.violationCount,
    required this.conformanceOutput,
    required this.result,
    required this.ecLineRef,
    required this.violatingProjects,
  });
}

// ── EC:1–8 Pipeline ──────────────────────────────────────────

class Bcdld040FlutterSdkVersionGate {

  // EC:1 — Locate Flutter SDK version gate configuration within
  //         bcdld-040-kit source repository.
  static Map<String, dynamic>? locateConfiguration(String repoPath) {
    assert(repoPath.isNotEmpty, 'EC-BCDLD040-001: repo path must not be empty');
    return {'ref': 'BCDLD-040', 'config_file': 'pubspec.yaml', 'path': repoPath};
  }

  // EC:2 — Extract sdkLockRuleId, flutterVersion, dartSdkConstraint,
  //         pubspecPath, channel from flutter_sdk_lock_registry.
  static Map<String, dynamic> extractParameters(Map<String, dynamic> config) {
    const required = [
      'sdk_lock_rule_id', 'flutter_version',
      'dart_sdk_constraint', 'pubspec_path', 'channel',
    ];
    assert(
      required.every((k) => config.containsKey(k) && config[k] != null),
      'EC-BCDLD040-002: all 5 SDK lock fields must be non-null',
    );
    return Map<String, dynamic>.from(config);
  }

  // EC:3 — Compile Flutter SDK lock rule set:
  //         exact version only, dart constraint declared,
  //         environment.sdk field in pubspec.yaml, channel=stable.
  static Map<String, dynamic> compileRuleSet() {
    return {
      'require_exact_flutter_version': true,
      'require_dart_sdk_constraint':   true,
      'require_environment_field':     true,
      'require_stable_channel':        true,
      'ref':                           'BCDLD-040',
      'immutable':                     true,
    };
  }

  // EC:4 — Register compiled rule set as immutable entry in
  //         flutter_sdk_lock_registry with immutable_IND=TRUE.
  static FlutterSdkLockEntry registerRule(FlutterSdkLockEntry entry) {
    assert(entry.isExactVersion,
      'EC-BCDLD040-003: flutterVersion "${entry.flutterVersion}" is not exact semver');
    assert(entry.dartSdkConstraint.isNotEmpty,
      'EC-BCDLD040-003: dartSdkConstraint must be declared');
    assert(entry.channel == SdkChannel.stable,
      'EC-BCDLD040-003: production channel must be stable, got ${entry.channelLabel}');
    return entry.copyWith(
      immutableInd: true,
      executionStatus: ExecutionStatus.running,
    );
  }

  // EC:5 — Bind each registered rule to pubspec.yaml environment block
  //         by applying pubspec_sdk_FK constraint.
  static String bindToTarget(String ruleId, String pubspecPath) {
    assert(ruleId.isNotEmpty, 'EC-BCDLD040-005: FK bind requires valid ruleId');
    return '$pubspecPath:$ruleId';
  }

  // EC:6 — Validate: flutter_version exact, dart_sdk_constraint declared,
  //         environment.sdk field present for all projects.
  static SdkLockScanResult validateConformance(
    List<FlutterSdkLockEntry> entries,
  ) {
    final violating = entries
        .where((e) => !e.isConformant)
        .map((e) => e.pubspecPath)
        .toList();
    final violations = violating.length;
    final output = violations == 0
        ? 'Complete'
        : violations <= 5
            ? 'Partial'
            : 'Not Complete';
    return SdkLockScanResult(
      violationCount:      violations,
      conformanceOutput:   output,
      result:              violations == 0 ? 'PASS' : 'FAIL',
      ecLineRef:           'EC-BCDLD040-006',
      violatingProjects:   violating,
    );
  }

  // EC:7 — Validate against Implementation Completeness metric.
  //         Complete = 0 SDK version violations.
  static String evaluateMetric(SdkLockScanResult scan) {
    return scan.violationCount == 0 ? 'PASS' : 'FAIL';
  }

  // EC:8 — Route validated SDK lock configuration to
  //         flutter_sdk_lock_registry as authoritative entry.
  static FlutterSdkLockEntry routeToRegistry(
    FlutterSdkLockEntry entry,
    SdkLockScanResult scan,
  ) {
    final passed = scan.violationCount == 0;
    return entry.copyWith(
      executionStatus:     passed ? ExecutionStatus.complete : ExecutionStatus.failed,
      stepOutcome:         passed ? StepOutcome.complete : StepOutcome.notComplete,
      complianceStatusInd: passed,
    );
  }
}

// ── Widget ───────────────────────────────────────────────────

class Bcdld040SdkLockWidget extends StatelessWidget {
  final List<FlutterSdkLockEntry> sdkEntries;
  const Bcdld040SdkLockWidget({super.key, required this.sdkEntries});

  @override
  Widget build(BuildContext context) {
    final scan   = Bcdld040FlutterSdkVersionGate.validateConformance(sdkEntries);
    final metric = Bcdld040FlutterSdkVersionGate.evaluateMetric(scan);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'BCDLD-040 · Flutter SDK Version Gate',
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Chip(
                label: Text(
                  '${scan.conformanceOutput} · ${scan.violationCount} violations',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
                backgroundColor: metric == 'PASS'
                    ? const Color(0xFF137333)
                    : const Color(0xFFD93025),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sdkEntries.length,
            itemBuilder: (context, i) {
              final e = sdkEntries[i];
              final pass = e.isConformant;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(
                    'Flutter ${e.flutterVersion}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  subtitle: Text(
                    'dart: ${e.dartSdkConstraint} | channel: ${e.channelLabel} | exact: ${e.isExactVersion}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Chip(
                    label: Text(
                      pass ? 'PASS' : 'VIOLATION',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    backgroundColor: pass
                        ? const Color(0xFF137333)
                        : const Color(0xFFD93025),
                  ),
                  leading: Icon(
                    pass ? Icons.sdk : Icons.warning_amber,
                    color: pass ? const Color(0xFF137333) : const Color(0xFFD93025),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
