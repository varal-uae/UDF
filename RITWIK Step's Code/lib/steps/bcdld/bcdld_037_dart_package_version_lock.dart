// ============================================================
// BCDLD-037 | Build Configuration Dependency Lock
// Atomic Task: Dart Package Version Lock —
//   Validate all pubspec.yaml dependencies declare exact version
//   pins; range constraints and any_version declarations block publish.
// Primary Table: dart_package_lock_registry
// Rule: exact pins only (e.g. 1.2.3) | dependency_override_IND=FALSE
// EC Lines: 8 | Standard: ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo: github.com/RitwikHC/theme-typography · branch: ritwik
// Author: Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date: 29-Aug-2026
// ============================================================

import 'package:flutter/material.dart';

// ── Data Models ──────────────────────────────────────────────

enum ExecutionStatus { pending, running, complete, failed }

enum StepOutcome { complete, partial, notComplete }

/// Version pin classification — exactly one type permitted per package.
enum VersionPinType { exact, caret, range, any }

/// Maps to dart_package_lock_registry.
/// dependency_override_IND=FALSE mandatory for production builds.
class DartPackageLockEntry {
  final String packageLockRuleId;     // PK — UUID
  final String packageName;           // dart package e.g. flutter_riverpod
  final String pinnedVersion;         // exact version e.g. 2.3.6
  final VersionPinType pinType;       // must be VersionPinType.exact
  final bool dependencyOverrideInd;   // FALSE for production
  final String pubspecPath;           // path to pubspec.yaml
  final bool immutableInd;
  final ExecutionStatus executionStatus;
  final StepOutcome stepOutcome;
  final bool complianceStatusInd;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;

  const DartPackageLockEntry({
    required this.packageLockRuleId,
    required this.packageName,
    required this.pinnedVersion,
    required this.pinType,
    this.dependencyOverrideInd = false,
    required this.pubspecPath,
    this.immutableInd = false,
    this.executionStatus = ExecutionStatus.pending,
    this.stepOutcome = StepOutcome.partial,
    this.complianceStatusInd = true,
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
  });

  /// EC:6 gate — exact pin, no override in production
  bool get isConformant =>
      pinType == VersionPinType.exact && !dependencyOverrideInd;

  /// Classify a raw version string from pubspec.yaml
  static VersionPinType classifyVersionString(String version) {
    if (version == 'any') return VersionPinType.any;
    if (version.startsWith('^')) return VersionPinType.caret;
    if (version.contains('>=') || version.contains('<') || version.contains('>'))
      return VersionPinType.range;
    // Exact: e.g. "2.3.6" or "0.1.0+1"
    return VersionPinType.exact;
  }

  String get pinTypeLabel => switch (pinType) {
    VersionPinType.exact  => 'EXACT',
    VersionPinType.caret  => 'CARET (^)',
    VersionPinType.range  => 'RANGE',
    VersionPinType.any    => 'ANY',
  };

  DartPackageLockEntry copyWith({
    bool? immutableInd,
    ExecutionStatus? executionStatus,
    StepOutcome? stepOutcome,
    bool? complianceStatusInd,
  }) {
    return DartPackageLockEntry(
      packageLockRuleId:       packageLockRuleId,
      packageName:             packageName,
      pinnedVersion:           pinnedVersion,
      pinType:                 pinType,
      dependencyOverrideInd:   dependencyOverrideInd,
      pubspecPath:             pubspecPath,
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

/// Scan result — maps to package_lock_validation_log.
class PackageLockScanResult {
  final int violationCount;
  final int unpinnedCount;
  final int overrideCount;
  final String conformanceOutput;
  final String result;
  final String ecLineRef;

  const PackageLockScanResult({
    required this.violationCount,
    required this.unpinnedCount,
    required this.overrideCount,
    required this.conformanceOutput,
    required this.result,
    required this.ecLineRef,
  });
}

// ── EC:1–8 Pipeline ──────────────────────────────────────────

class Bcdld037DartPackageVersionLock {

  // EC:1 — Locate Dart package version lock configuration within
  //         bcdld-037-kit source repository (pubspec.yaml).
  static Map<String, dynamic>? locateConfiguration(String repoPath) {
    assert(repoPath.isNotEmpty, 'EC-BCDLD037-001: repo path must not be empty');
    return {'ref': 'BCDLD-037', 'config_file': 'pubspec.yaml', 'path': repoPath};
  }

  // EC:2 — Extract packageLockRuleId, packageName, pinnedVersion,
  //         dependencyOverrideInd, pubspecPath from registry.
  static Map<String, dynamic> extractParameters(Map<String, dynamic> config) {
    const required = [
      'package_lock_rule_id', 'package_name',
      'pinned_version', 'dependency_override_ind', 'pubspec_path',
    ];
    assert(
      required.every((k) => config.containsKey(k) && config[k] != null),
      'EC-BCDLD037-002: all 5 package lock fields must be non-null',
    );
    return Map<String, dynamic>.from(config);
  }

  // EC:3 — Compile package version lock rule set:
  //         exact pins only (no ^, >=, any), dependencyOverrideInd=FALSE.
  static Map<String, dynamic> compileRuleSet() {
    return {
      'require_exact_pin':        true,
      'block_caret':              true,
      'block_range':              true,
      'block_any':                true,
      'require_override_false':   true,
      'ref':                      'BCDLD-037',
      'immutable':                true,
    };
  }

  // EC:4 — Register compiled rule set as immutable entry in
  //         dart_package_lock_registry with immutable_IND=TRUE.
  static DartPackageLockEntry registerRule(DartPackageLockEntry entry) {
    assert(entry.pinType == VersionPinType.exact,
      'EC-BCDLD037-003: ${entry.packageName} uses ${entry.pinTypeLabel} — exact pin required');
    assert(!entry.dependencyOverrideInd,
      'EC-BCDLD037-003: dependency_override_IND=TRUE not permitted for production');
    return entry.copyWith(
      immutableInd: true,
      executionStatus: ExecutionStatus.running,
    );
  }

  // EC:5 — Bind each registered rule to pubspec.yaml package entry
  //         by applying pubspec_package_FK constraint.
  static String bindToTarget(String ruleId, String packageName) {
    assert(ruleId.isNotEmpty, 'EC-BCDLD037-005: FK bind requires valid ruleId');
    return '$packageName:$ruleId';
  }

  // EC:6 — Validate: 0 range constraints, 0 any_version declarations,
  //         dependencyOverrideInd=FALSE for all production packages.
  static PackageLockScanResult validateConformance(
    List<DartPackageLockEntry> packages,
  ) {
    final unpinned  = packages.where((p) => p.pinType != VersionPinType.exact).length;
    final overrides = packages.where((p) => p.dependencyOverrideInd).length;
    final violations = unpinned + overrides;
    final output = violations == 0
        ? 'Complete'
        : violations <= 5
            ? 'Partial'
            : 'Not Complete';
    return PackageLockScanResult(
      violationCount:   violations,
      unpinnedCount:    unpinned,
      overrideCount:    overrides,
      conformanceOutput: output,
      result:           violations == 0 ? 'PASS' : 'FAIL',
      ecLineRef:        'EC-BCDLD037-006',
    );
  }

  // EC:7 — Validate against Implementation Completeness metric.
  //         Complete = 0 unpinned dependencies.
  static String evaluateMetric(PackageLockScanResult scan) {
    return scan.violationCount == 0 ? 'PASS' : 'FAIL';
  }

  // EC:8 — Route validated package lock configuration to
  //         dart_package_lock_registry as authoritative entry.
  static DartPackageLockEntry routeToRegistry(
    DartPackageLockEntry entry,
    PackageLockScanResult scan,
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

class Bcdld037PackageLockWidget extends StatelessWidget {
  final List<DartPackageLockEntry> packages;
  const Bcdld037PackageLockWidget({super.key, required this.packages});

  Color _pinColor(VersionPinType type) => switch (type) {
    VersionPinType.exact  => const Color(0xFF137333),
    VersionPinType.caret  => const Color(0xFFE37400),
    VersionPinType.range  => const Color(0xFFD93025),
    VersionPinType.any    => const Color(0xFFD93025),
  };

  @override
  Widget build(BuildContext context) {
    final scan   = Bcdld037DartPackageVersionLock.validateConformance(packages);
    final metric = Bcdld037DartPackageVersionLock.evaluateMetric(scan);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'BCDLD-037 · Dart Package Version Lock',
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Chip(
                label: Text(
                  '${scan.conformanceOutput} · ${scan.unpinnedCount} unpinned · ${scan.overrideCount} overrides',
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
            itemCount: packages.length,
            itemBuilder: (context, i) {
              final p = packages[i];
              final pass = p.isConformant;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(
                    p.packageName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  subtitle: Text(
                    'version: ${p.pinnedVersion} | pin: ${p.pinTypeLabel} | override: ${p.dependencyOverrideInd}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Chip(
                    label: Text(
                      p.pinTypeLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    backgroundColor: _pinColor(p.pinType),
                  ),
                  leading: Icon(
                    pass ? Icons.lock : Icons.lock_open,
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
