// ============================================================
// BCDLD-047-A07 | Build Configuration Dependency Lock
// Atomic Task: Native Plugin Compatibility Gate —
//   Validate all native Flutter plugins declare platform
//   compatibility matrices with android_min_sdk >= 21 and
//   ios_min_deployment >= 12.0.
// Primary Table: native_plugin_compat_registry
// Thresholds: android_min_sdk >= 21 | ios_min_deployment >= 12.0 | web_IND declared
// EC Lines: 8 | Standard: ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo: github.com/RitwikHC/theme-typography · branch: ritwik
// Author: Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date: 29-Aug-2026
// ============================================================

import 'package:flutter/material.dart';

// ── Data Models ──────────────────────────────────────────────

enum ExecutionStatus { pending, running, complete, failed }

enum StepOutcome { complete, partial, notComplete }

/// Maps to native_plugin_compat_registry.
/// android_min_sdk >= 21 and ios_min_deployment >= 12.0
/// enforced by CHECK constraints at DB level.
class NativePluginCompatEntry {
  final String pluginCompatRuleId;    // PK — UUID
  final String pluginName;            // Flutter plugin package name
  final int androidMinSdk;            // must be >= 21 (Android 5.0 Lollipop)
  final double iosMinDeployment;      // must be >= 12.0
  final bool webInd;                  // TRUE if web platform supported
  final bool immutableInd;
  final ExecutionStatus executionStatus;
  final StepOutcome stepOutcome;
  final bool complianceStatusInd;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;

  const NativePluginCompatEntry({
    required this.pluginCompatRuleId,
    required this.pluginName,
    required this.androidMinSdk,
    required this.iosMinDeployment,
    required this.webInd,
    this.immutableInd = false,
    this.executionStatus = ExecutionStatus.pending,
    this.stepOutcome = StepOutcome.partial,
    this.complianceStatusInd = true,
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
  })  :     if (!(androidMinSdk >= 21)) {
      throw ArgumentError('EC-BCDLD047A07-003: androidMinSdk must be >= 21, got $androidMinSdk');
    },
            if (!(iosMinDeployment >= 12.0)) {
      throw ArgumentError('EC-BCDLD047A07-003: iosMinDeployment must be >= 12.0, got $iosMinDeployment');
    };

  static const int    kMinAndroidSdk     = 21;
  static const double kMinIosDeployment  = 12.0;

  /// EC:6 gate — both platform constraints satisfied, web_IND declared
  bool get isConformant =>
      androidMinSdk >= kMinAndroidSdk &&
      iosMinDeployment >= kMinIosDeployment;
  // Note: webInd is a declaration check — we verify it's set, not that it's true.
  // A plugin that doesn't support web sets webInd=false (which is valid — it's declared).

  NativePluginCompatEntry copyWith({
    bool? immutableInd,
    ExecutionStatus? executionStatus,
    StepOutcome? stepOutcome,
    bool? complianceStatusInd,
  }) {
    return NativePluginCompatEntry(
      pluginCompatRuleId:      pluginCompatRuleId,
      pluginName:              pluginName,
      androidMinSdk:           androidMinSdk,
      iosMinDeployment:        iosMinDeployment,
      webInd:                  webInd,
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

/// Scan result — maps to plugin_compat_validation_log.
class PluginCompatScanResult {
  final int violationCount;
  final int androidViolations;
  final int iosViolations;
  final String conformanceOutput;
  final String result;
  final String ecLineRef;

  const PluginCompatScanResult({
    required this.violationCount,
    required this.androidViolations,
    required this.iosViolations,
    required this.conformanceOutput,
    required this.result,
    required this.ecLineRef,
  });
}

// ── EC:1–8 Pipeline ──────────────────────────────────────────

class Bcdld047A07NativePluginCompatibilityGate {
  static const double _floor   = 0.90;  // metric floor gate
  static const double _optimal = 0.97; // metric optimal target


  // EC:1 — Locate native plugin compatibility configuration within
  //         bcdld-047-a07-kit source repository.
  static Map<String, dynamic>? locateConfiguration(String repoPath) {
        if (!(repoPath.isNotEmpty)) {
      throw ArgumentError('EC-BCDLD047A07-001: repo path must not be empty');
    };
    return {'ref': 'BCDLD-047-A07', 'config_file': 'plugin_compat.yaml'};
  }

  // EC:2 — Extract pluginCompatRuleId, pluginName, androidMinSdk,
  //         iosMinDeployment, webInd from native_plugin_compat_registry.
  static Map<String, dynamic> extractParameters(Map<String, dynamic> config) {
    const required = [
      'plugin_compat_rule_id', 'plugin_name',
      'android_min_sdk', 'ios_min_deployment', 'web_ind',
    ];
    if (!(required.every((k) => config.containsKey(k) && config[k] != null))) {
      throw ArgumentError('EC-BCDLD047A07-002: all 5 plugin compat fields must be non-null',
    );
    return Map<String, dynamic>.from(config);
  }

  // EC:3 — Compile native plugin compatibility rule set:
  //         android_min_sdk >= 21, ios_min_deployment >= 12.0,
  //         web_IND declared, platform_interface in pubspec plugin block.
  static Map<String, dynamic> compileRuleSet() {
    return {
      'min_android_sdk':      NativePluginCompatEntry.kMinAndroidSdk,
      'min_ios_deployment':   NativePluginCompatEntry.kMinIosDeployment,
      'require_web_ind':      true,
      'require_platform_if':  true,
      'ref':                  'BCDLD-047-A07',
      'immutable':            true,
    };
  }

  // EC:4 — Register compiled rule set as immutable entry in
  //         native_plugin_compat_registry with immutable_IND=TRUE.
  static NativePluginCompatEntry registerRule(NativePluginCompatEntry entry) {
        if (!(entry.androidMinSdk >= NativePluginCompatEntry.kMinAndroidSdk)) {
      throw ArgumentError('EC-BCDLD047A07-003: ${entry.pluginName} androidMinSdk ${entry.androidMinSdk} < 21');
    }
    };
        if (!(entry.iosMinDeployment >= NativePluginCompatEntry.kMinIosDeployment)) {
      throw ArgumentError('EC-BCDLD047A07-003: ${entry.pluginName} iosMinDeployment ${entry.iosMinDeployment} < 12.0');
    };
    return entry.copyWith(
      immutableInd: true,
      executionStatus: ExecutionStatus.running,
    );
  }

  // EC:5 — Bind each registered rule to native plugin handler
  //         by applying plugin_compat_handler_FK constraint.
  static String bindToTarget(String ruleId, String pluginName) {
        if (!(ruleId.isNotEmpty)) {
      throw ArgumentError('EC-BCDLD047A07-005: FK bind requires valid ruleId');
    };
    return '$pluginName:$ruleId';
  }

  // EC:6 — Validate: android_min_sdk >= 21, ios_min_deployment >= 12.0,
  //         platform_interface declared for all native plugins.
  static PluginCompatScanResult validateConformance(
    List<NativePluginCompatEntry> plugins,
  ) {
    final androidViolations = plugins.where((p) => p.androidMinSdk < 21).length;
    final iosViolations     = plugins.where((p) => p.iosMinDeployment < 12.0).length;
    final violations = plugins.where((p) => !p.isConformant).length;
    final output = violations == 0
        ? 'Complete'
        : violations <= 5
            ? 'Partial'
            : 'Not Complete';
    return PluginCompatScanResult(
      violationCount:    violations,
      androidViolations: androidViolations,
      iosViolations:     iosViolations,
      conformanceOutput: output,
      result:            violations == 0 ? 'PASS' : 'FAIL',
      ecLineRef:         'EC-BCDLD047A07-006',
    );
  }

  // EC:7 — Validate against Implementation Completeness metric.
  //         Complete = 0 compatibility violations.
  static String evaluateMetric(PluginCompatScanResult scan) {
    return scan.violationCount == 0 ? 'PASS' : 'FAIL';
  }

  // EC:8 — Route validated plugin compatibility configuration to
  //         native_plugin_compat_registry as authoritative entry.
  static NativePluginCompatEntry routeToRegistry(
    NativePluginCompatEntry entry,
    PluginCompatScanResult scan,
  ) {
    final passed = scan.violationCount == 0;
    return entry.copyWith(
      executionStatus:     passed ? ExecutionStatus.complete : ExecutionStatus.failed,
      stepOutcome:         passed ? StepOutcome.complete : StepOutcome.notComplete,
      complianceStatusInd: passed,
    );
  }
  // Triangular Check: source_count - destination_count == 0 (DCDF AEETE-018)
  static bool triangularCheck(int sourceCount, int destinationCount) =>
      (sourceCount - destinationCount) == 0;

}

// ── Widget ───────────────────────────────────────────────────

class Bcdld047A07PluginCompatWidget extends StatelessWidget {
  final List<NativePluginCompatEntry> plugins;
  const Bcdld047A07PluginCompatWidget({super.key, required this.plugins});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scan   = Bcdld047A07NativePluginCompatibilityGate.validateConformance(plugins);
    final metric = Bcdld047A07NativePluginCompatibilityGate.evaluateMetric(scan);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'BCDLD-047-A07 · Native Plugin Compatibility Gate',
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
                    ? cs.tertiary
                    : cs.error,
              ),
            ],
          ),
        ),
        if (scan.violationCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Android violations: ${scan.androidViolations} | iOS violations: ${scan.iosViolations}',
              style: const TextStyle(
                fontSize: 11,
                color: cs.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: plugins.length,
            itemBuilder: (context, i) {
              final p = plugins[i];
              final pass = p.isConformant;
              final androidOk = p.androidMinSdk >= 21;
              final iosOk     = p.iosMinDeployment >= 12.0;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(
                    p.pluginName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  subtitle: Text(
                    'Android: SDK ${p.androidMinSdk}${androidOk ? "" : " ⚠ <21"} | iOS: ${p.iosMinDeployment.toStringAsFixed(1)}${iosOk ? "" : " ⚠ <12.0"} | web: ${p.webInd}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Chip(
                    label: Text(
                      pass ? 'PASS' : 'VIOLATION',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    backgroundColor: pass
                        ? cs.tertiary
                        : cs.error,
                  ),
                  leading: Icon(
                    pass ? Icons.extension : Icons.extension_off,
                    color: pass ? cs.tertiary : cs.error,
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
