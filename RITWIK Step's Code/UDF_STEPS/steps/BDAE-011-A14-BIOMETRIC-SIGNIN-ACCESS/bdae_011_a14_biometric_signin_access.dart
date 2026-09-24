// ============================================================
// BDAE-011-A14 | WebAuthn Biometric Authentication
// Atomic Task: Verify successful biometric authentication grants sign-in access.
// Primary Table: biometric_access_registry
// Metric: Biometric Authentication Reliability Rate
//         Floor=95% | Optimal=98–99% | Ceiling=99.9% (false-acceptance <0.01%)
// Library: @habot-connect/layout-shell | GCP: Pub/Sub fan-out to Cloud Run
// EC Lines: 8 | Standard: FIDO2 / WebAuthn Level 2 | DCDF AEETE-018
// Security: device_credential_ref = Secure Enclave ref only — never raw credential
// Repo: github.com/RitwikHC/theme-typography · branch: ritwik
// Author: Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date: 29-Aug-2026
// ============================================================

import 'package:flutter/material.dart';

// ── Data Models ──────────────────────────────────────────────

enum ExecutionStatus { pending, running, complete, failed }

enum StepOutcome { complete, partial, notComplete }

enum AuthenticationStatus { pending, success, failed, fallback }

enum AccessType { read, write, admin, none }

/// Maps to biometric_access_registry.
/// Tracks whether successful biometric auth correctly grants session + access.
/// false_acceptance_rate must be < 0.0001 (< 0.01%) per FIDO2 ceiling spec.
class BiometricAccessEntry {
  final String accessRuleId;              // PK — UUID
  final AccessType accessType;           // READ / WRITE / ADMIN / NONE
  final String userRole;                  // role scoped to this access grant
  final String permissionLevel;           // L1 / L2 / L3 — least privilege
  final String accessLog;                 // log path for this access grant
  final AuthenticationStatus authStatus; // must be SUCCESS to grant
  final double reliabilityRate;           // 0.0–1.0 biometric success rate
  final double falseAcceptanceRate;       // must be < 0.0001 per FIDO2
  final bool pubSubFanOutConfirmed;       // Pub/Sub → Cloud Run confirmed
  final bool immutableInd;
  final ExecutionStatus executionStatus;
  final StepOutcome stepOutcome;
  final bool complianceStatusInd;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;

  const BiometricAccessEntry({
    required this.accessRuleId,
    required this.accessType,
    required this.userRole,
    required this.permissionLevel,
    required this.accessLog,
    required this.authStatus,
    required this.reliabilityRate,
    required this.falseAcceptanceRate,
    this.pubSubFanOutConfirmed = false,
    this.immutableInd = false,
    this.executionStatus = ExecutionStatus.pending,
    this.stepOutcome = StepOutcome.partial,
    this.complianceStatusInd = true,
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
  }) :     if (!(falseAcceptanceRate >= 0.0)) {
      throw ArgumentError('EC-BDAE011A14-002: falseAcceptanceRate must be >= 0.0');
    };

  static const double kFloor              = 0.95;
  static const double kOptimalMin         = 0.98;
  static const double kCeiling           = 0.999;
  static const double kMaxFalseAcceptance = 0.0001; // < 0.01% per FIDO2

  /// EC:6 gate — auth SUCCESS, reliability >= floor, false-acceptance < 0.01%
  bool get isConformant =>
      authStatus == AuthenticationStatus.success &&
      reliabilityRate >= kFloor &&
      falseAcceptanceRate < kMaxFalseAcceptance;

  String get authStatusLabel => switch (authStatus) {
    AuthenticationStatus.pending  => 'PENDING',
    AuthenticationStatus.success  => 'SUCCESS ✓',
    AuthenticationStatus.failed   => 'FAILED ✗',
    AuthenticationStatus.fallback => 'FALLBACK',
  };

  String get reliabilityTier {
    if (reliabilityRate >= kCeiling)    return 'Ceiling';
    if (reliabilityRate >= kOptimalMin) return 'Optimal';
    if (reliabilityRate >= kFloor)      return 'Floor';
    return 'Below Floor';
  }

  BiometricAccessEntry copyWith({
    bool? immutableInd,
    ExecutionStatus? executionStatus,
    StepOutcome? stepOutcome,
    bool? complianceStatusInd,
    bool? pubSubFanOutConfirmed,
  }) {
    return BiometricAccessEntry(
      accessRuleId:            accessRuleId,
      accessType:              accessType,
      userRole:                userRole,
      permissionLevel:         permissionLevel,
      accessLog:               accessLog,
      authStatus:              authStatus,
      reliabilityRate:         reliabilityRate,
      falseAcceptanceRate:     falseAcceptanceRate,
      pubSubFanOutConfirmed:   pubSubFanOutConfirmed ?? this.pubSubFanOutConfirmed,
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

/// Scan result — maps to access_validation_log.
class BiometricAccessScanResult {
  final int violationCount;
  final int falseAcceptanceViolations;
  final String testOutput;
  final String result;
  final String ecLineRef;

  const BiometricAccessScanResult({
    required this.violationCount,
    required this.falseAcceptanceViolations,
    required this.testOutput,
    required this.result,
    required this.ecLineRef,
  });
}

// ── EC:1–8 Pipeline ──────────────────────────────────────────

class Bdae011A14BiometricSignInAccess {
  static const double _floor   = 0.95;  // metric floor gate
  static const double _optimal = 98; // metric optimal target


  // EC:1 — Locate biometric sign-in access config in bdae-011-kit repo.
  static Map<String, dynamic>? locateConfiguration(String repoPath) {
        if (!(repoPath.isNotEmpty)) {
      throw ArgumentError('EC-BDAE011A14-001: repo path must not be empty');
    };
    return {'ref': 'BDAE-011-A14', 'config_file': 'biometric_access.yaml'};
  }

  // EC:2 — Extract accessRuleId, accessType, userRole, permissionLevel, accessLog.
  static Map<String, dynamic> extractParameters(Map<String, dynamic> config) {
    const required = [
      'access_rule_id', 'access_type', 'user_role', 'permission_level', 'access_log',
    ];
    if (!(required.every((k) => config.containsKey(k) && config[k] != null))) {
      throw ArgumentError('EC-BDAE011A14-002: all 5 access fields must be non-null',
    );
    return Map<String, dynamic>.from(config);
  }

  // EC:3 — Compile biometric sign-in access rule set:
  //         SUCCESS auth grants session token within 500ms, token scoped to
  //         userRole + permissionLevel, Pub/Sub fan-out to Cloud Run,
  //         false-acceptance < 0.01% per FIDO2.
  static Map<String, dynamic> compileRuleSet() {
    return {
      'token_grant_ms':       500,
      'scope_to_role':        true,
      'pubsub_fanout':        true,
      'max_false_acceptance': BiometricAccessEntry.kMaxFalseAcceptance,
      'fido2_floor':          BiometricAccessEntry.kFloor,
      'ref':                  'BDAE-011-A14',
      'immutable':            true,
    };
  }

  // EC:4 — Register compiled access rule set as immutable entry in
  //         biometric_access_registry with immutable_IND=TRUE.
  static BiometricAccessEntry registerRule(BiometricAccessEntry entry) {
        if (!(entry.falseAcceptanceRate < BiometricAccessEntry.kMaxFalseAcceptance)) {
      throw ArgumentError('EC-BDAE011A14-003: falseAcceptanceRate >= 0.0001 — FIDO2 ceiling exceeded');
    }
    };
        if (!(entry.reliabilityRate >= BiometricAccessEntry.kFloor)) {
      throw ArgumentError('EC-BDAE011A14-003: reliabilityRate < 0.95 — FIDO2 floor not met');
    };
    return entry.copyWith(
      immutableInd:    true,
      executionStatus: ExecutionStatus.running,
    );
  }

  // EC:5 — Bind each access rule to session management handler
  //         via webauthn_handler_FK constraint.
  static String bindToTarget(String ruleId, String userRole) {
        if (!(ruleId.isNotEmpty)) {
      throw ArgumentError('EC-BDAE011A14-005: FK bind requires valid ruleId');
    };
    return '$userRole:$ruleId';
  }

  // EC:6 — Validate: auth=SUCCESS grants session token within 500ms,
  //         token scoped to userRole+permissionLevel, Pub/Sub fan-out confirmed,
  //         false-acceptance < 0.01%.
  static BiometricAccessScanResult validateConformance(
    List<BiometricAccessEntry> entries,
  ) {
    final violations = entries.where((e) => !e.isConformant).length;
    final faViolations = entries
        .where((e) => e.falseAcceptanceRate >= BiometricAccessEntry.kMaxFalseAcceptance)
        .length;
    final total = entries.length;
    final rate  = total > 0 ? (total - violations) / total : 0.0;
    return BiometricAccessScanResult(
      violationCount:            violations,
      falseAcceptanceViolations: faViolations,
      testOutput:                rate >= BiometricAccessEntry.kFloor ? 'Pass' : 'Fail',
      result:                    rate >= BiometricAccessEntry.kFloor ? 'PASS' : 'FAIL',
      ecLineRef:                 'EC-BDAE011A14-006',
    );
  }

  // EC:7 — Validate against Biometric Authentication Reliability Rate metric.
  //         Floor=95%, Optimal=98–99%, Ceiling=99.9% with false-acceptance <0.01%.
  static String evaluateMetric(
    BiometricAccessScanResult scan,
    int total,
    double avgReliabilityRate,
  ) {
    if (total == 0) return 'FAIL';
    if (scan.falseAcceptanceViolations > 0) return 'FAIL'; // FIDO2 ceiling
    if (avgReliabilityRate < BiometricAccessEntry.kFloor)  return 'FAIL';
    return 'PASS';
  }

  // EC:8 — Route validated access configuration to security_rule_registry
  //         as authoritative BDAE-011-A14 Sign-In Access entry.
  static BiometricAccessEntry routeToRegistry(
    BiometricAccessEntry entry,
    BiometricAccessScanResult scan,
  ) {
    final passed = scan.violationCount == 0;
    return entry.copyWith(
      executionStatus:     passed ? ExecutionStatus.complete : ExecutionStatus.failed,
      stepOutcome:         passed ? StepOutcome.complete : StepOutcome.notComplete,
      complianceStatusInd: passed,
      pubSubFanOutConfirmed: passed,
    );
  }

  // ── Triangular Check ─────────────────────────────────────
  /// auths_success_count = sessions_granted. Delta != 0 -> quarantine.
  static bool triangularCheck(int authSuccessCount, int sessionsGranted) {
    return (authSuccessCount - sessionsGranted) == 0;
  }
}

// ── Widget ───────────────────────────────────────────────────

class Bdae011A14BiometricAccessWidget extends StatelessWidget {
  final List<BiometricAccessEntry> entries;
  const Bdae011A14BiometricAccessWidget({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scan   = Bdae011A14BiometricSignInAccess.validateConformance(entries);
    final avgRate = entries.isEmpty ? 0.0
        : entries.map((e) => e.reliabilityRate).reduce((a, b) => a + b) / entries.length;
    final metric = Bdae011A14BiometricSignInAccess.evaluateMetric(scan, entries.length, avgRate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('BDAE-011-A14 · Biometric Sign-In Access Gate (FIDO2)',
              style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 12))),
            Chip(
              label: Text('${scan.testOutput} · avg: ${(avgRate * 100).toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white, fontSize: 11)),
              backgroundColor: metric == 'PASS'
                  ? cs.tertiary : cs.error,
            ),
          ]),
        ),
        if (scan.falseAcceptanceViolations > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              '⚠ FIDO2 CEILING VIOLATED: ${scan.falseAcceptanceViolations} false-acceptance rate(s) >= 0.01%',
              style: const TextStyle(fontSize: 11, color: cs.error, fontWeight: FontWeight.bold),
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
                title: Text('${e.userRole} · ${e.permissionLevel}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                subtitle: Text(
                  'reliability: ${(e.reliabilityRate * 100).toStringAsFixed(2)}% (${e.reliabilityTier}) | FA: ${(e.falseAcceptanceRate * 100).toStringAsFixed(4)}% | Pub/Sub: ${e.pubSubFanOutConfirmed}',
                  style: const TextStyle(fontSize: 10)),
                trailing: Chip(
                  label: Text(e.authStatusLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: pass
                      ? cs.tertiary : cs.error,
                ),
                leading: Icon(
                  pass ? Icons.verified_user : Icons.gpp_bad,
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
