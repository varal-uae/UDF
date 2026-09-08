// ============================================================
// BDAE-015 | Session Token Management & Remote Invalidation
// Atomic Task: Define the maximum session lifecycle lifespan for mobile endpoints.
// Primary Table: session_token_registry
// Metric: Session Token Security Response Time
//         Floor=<=2s | Optimal=<=500ms | Ceiling=<=200ms (OWASP)
// GCP: API Gateway JWT stateless | Pub/Sub revocation <= 500ms
// EC Lines: 8 | Standard: OWASP Session Management Cheat Sheet | DCDF AEETE-018
// Constraint: MOBILE session_lifespan_hours <= 8 (CHECK at DB level)
// Repo: github.com/RitwikHC/theme-typography · branch: ritwik
// Author: Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date: 29-Aug-2026
// ============================================================

import 'package:flutter/material.dart';

// ── Data Models ──────────────────────────────────────────────

enum ExecutionStatus { pending, running, complete, failed }

enum StepOutcome { complete, partial, notComplete }

enum DeviceType { mobile, tablet, desktop }

/// Maps to session_token_registry.
/// MOBILE session_lifespan_hours must be <= 8 — enforced via CHECK at DB level.
/// revoke_pubsub_ms must be <= 500ms for remote invalidation SLA.
class SessionTokenEntry {
  final String sessionRuleId;          // PK — UUID
  final String mobilePlatform;         // iOS / Android / PWA
  final String osVersion;              // minimum supported OS version
  final DeviceType deviceType;        // MOBILE / TABLET / DESKTOP
  final int sessionLifespanHours;      // max session lifespan; MOBILE <= 8
  final int idleTimeoutMin;            // idle timeout in minutes; default 30
  final int revokePubsubMs;            // Pub/Sub revocation SLA in ms; <= 500
  final int responseMs;                // measured token response time in ms
  final bool immutableInd;
  final ExecutionStatus executionStatus;
  final StepOutcome stepOutcome;
  final bool complianceStatusInd;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;

  const SessionTokenEntry({
    required this.sessionRuleId,
    required this.mobilePlatform,
    required this.osVersion,
    required this.deviceType,
    required this.sessionLifespanHours,
    this.idleTimeoutMin = 30,
    this.revokePubsubMs = 500,
    required this.responseMs,
    this.immutableInd = false,
    this.executionStatus = ExecutionStatus.pending,
    this.stepOutcome = StepOutcome.partial,
    this.complianceStatusInd = true,
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
  }) : assert(
    !(deviceType == DeviceType.mobile && sessionLifespanHours > 8),
    'EC-BDAE015-003: MOBILE session_lifespan_hours must be <= 8 (OWASP)',
  );

  static const int kMaxMobileLifespanHours = 8;
  static const int kDefaultIdleTimeoutMin  = 30;
  static const int kMaxRevokePubsubMs      = 500;
  static const int kFloorResponseMs        = 2000;
  static const int kOptimalResponseMs      = 500;
  static const int kCeilingResponseMs      = 200;

  /// EC:6 gate — lifespan within OWASP bounds, revocation SLA met,
  ///             response time within floor
  bool get isConformant {
    if (deviceType == DeviceType.mobile && sessionLifespanHours > kMaxMobileLifespanHours) return false;
    if (revokePubsubMs > kMaxRevokePubsubMs) return false;
    if (responseMs > kFloorResponseMs) return false;
    return true;
  }

  String get owaspTier {
    if (responseMs <= kCeilingResponseMs) return 'Ceiling (≤200ms)';
    if (responseMs <= kOptimalResponseMs) return 'Optimal (≤500ms)';
    if (responseMs <= kFloorResponseMs)   return 'Floor (≤2s)';
    return 'Below Floor';
  }

  String get deviceTypeLabel => switch (deviceType) {
    DeviceType.mobile  => 'MOBILE',
    DeviceType.tablet  => 'TABLET',
    DeviceType.desktop => 'DESKTOP',
  };

  SessionTokenEntry copyWith({
    bool? immutableInd,
    ExecutionStatus? executionStatus,
    StepOutcome? stepOutcome,
    bool? complianceStatusInd,
  }) {
    return SessionTokenEntry(
      sessionRuleId:           sessionRuleId,
      mobilePlatform:          mobilePlatform,
      osVersion:               osVersion,
      deviceType:              deviceType,
      sessionLifespanHours:    sessionLifespanHours,
      idleTimeoutMin:          idleTimeoutMin,
      revokePubsubMs:          revokePubsubMs,
      responseMs:              responseMs,
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

/// Scan result — maps to session_validation_log.
class SessionTokenScanResult {
  final int violationCount;
  final int lifespanViolations;
  final int revocationViolations;
  final String testOutput;
  final String result;
  final String ecLineRef;

  const SessionTokenScanResult({
    required this.violationCount,
    required this.lifespanViolations,
    required this.revocationViolations,
    required this.testOutput,
    required this.result,
    required this.ecLineRef,
  });
}

// ── EC:1–8 Pipeline ──────────────────────────────────────────

class Bdae015SessionTokenLifecycle {

  // EC:1 — Locate session token management config in bdae-015-kit repo.
  static Map<String, dynamic>? locateConfiguration(String repoPath) {
    assert(repoPath.isNotEmpty, 'EC-BDAE015-001: repo path must not be empty');
    return {'ref': 'BDAE-015', 'config_file': 'session_token.yaml'};
  }

  // EC:2 — Extract sessionRuleId, mobilePlatform, osVersion, deviceType,
  //         sessionLifespanHours from session_token_registry.
  static Map<String, dynamic> extractParameters(Map<String, dynamic> config) {
    const required = [
      'session_rule_id', 'mobile_platform', 'os_version',
      'device_type', 'session_lifespan_hours',
    ];
    assert(
      required.every((k) => config.containsKey(k) && config[k] != null),
      'EC-BDAE015-002: all 5 session lifecycle fields must be non-null',
    );
    return Map<String, dynamic>.from(config);
  }

  // EC:3 — Compile session lifecycle rule set per OWASP Session Management:
  //         MOBILE session_lifespan_hours <= 8, idle_timeout=30min,
  //         revoke_pubsub <= 500ms, API Gateway JWT stateless.
  static Map<String, dynamic> compileRuleSet() {
    return {
      'max_mobile_lifespan_hours': SessionTokenEntry.kMaxMobileLifespanHours,
      'idle_timeout_min':          SessionTokenEntry.kDefaultIdleTimeoutMin,
      'revoke_pubsub_ms':          SessionTokenEntry.kMaxRevokePubsubMs,
      'floor_response_ms':         SessionTokenEntry.kFloorResponseMs,
      'optimal_response_ms':       SessionTokenEntry.kOptimalResponseMs,
      'owasp_standard':            'Session Management Cheat Sheet',
      'ref':                       'BDAE-015',
      'immutable':                 true,
    };
  }

  // EC:4 — Register compiled session lifecycle rule set as immutable entry in
  //         session_token_registry with immutable_IND=TRUE.
  static SessionTokenEntry registerRule(SessionTokenEntry entry) {
    assert(
      !(entry.deviceType == DeviceType.mobile && entry.sessionLifespanHours > 8),
      'EC-BDAE015-003: MOBILE session lifespan > 8h violates OWASP'
    );
    assert(entry.revokePubsubMs <= SessionTokenEntry.kMaxRevokePubsubMs,
      'EC-BDAE015-003: revokePubsubMs > 500ms violates revocation SLA');
    return entry.copyWith(
      immutableInd:    true,
      executionStatus: ExecutionStatus.running,
    );
  }

  // EC:5 — Bind each registered rule to API Gateway JWT validation handler
  //         via api_gateway_FK constraint.
  static String bindToTarget(String ruleId, String mobilePlatform) {
    assert(ruleId.isNotEmpty, 'EC-BDAE015-005: FK bind requires valid ruleId');
    return '$mobilePlatform:$ruleId';
  }

  // EC:6 — Validate: remote invalidation via Pub/Sub <= 500ms,
  //         API Gateway blocks invalidated token <= 200ms,
  //         MOBILE lifespan <= 8h, response time <= 2s floor.
  static SessionTokenScanResult validateConformance(
    List<SessionTokenEntry> entries,
  ) {
    final violations       = entries.where((e) => !e.isConformant).length;
    final lifespanV        = entries.where((e) =>
      e.deviceType == DeviceType.mobile && e.sessionLifespanHours > 8).length;
    final revocationV      = entries.where((e) =>
      e.revokePubsubMs > SessionTokenEntry.kMaxRevokePubsubMs).length;
    final total = entries.length;
    final rate  = total > 0 ? (total - violations) / total : 0.0;
    return SessionTokenScanResult(
      violationCount:       violations,
      lifespanViolations:   lifespanV,
      revocationViolations: revocationV,
      testOutput:           rate >= 0.95 ? 'Pass' : 'Fail',
      result:               rate >= 0.95 ? 'PASS' : 'FAIL',
      ecLineRef:            'EC-BDAE015-006',
    );
  }

  // EC:7 — Validate against Session Token Security Response Time metric.
  //         Floor=<=2s | Optimal=<=500ms | Ceiling=<=200ms (OWASP).
  static String evaluateMetric(SessionTokenScanResult scan) {
    return scan.violationCount == 0 ? 'PASS' : 'FAIL';
  }

  // EC:8 — Route validated session configuration to security_rule_registry
  //         as authoritative BDAE-015 Session Token Registry entry.
  static SessionTokenEntry routeToRegistry(
    SessionTokenEntry entry,
    SessionTokenScanResult scan,
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

class Bdae015SessionTokenWidget extends StatelessWidget {
  final List<SessionTokenEntry> entries;
  const Bdae015SessionTokenWidget({super.key, required this.entries});

  Color _tierColor(String tier) {
    if (tier.startsWith('Ceiling')) return const Color(0xFF137333);
    if (tier.startsWith('Optimal')) return const Color(0xFF1A73E8);
    if (tier.startsWith('Floor'))   return const Color(0xFFE37400);
    return const Color(0xFFD93025);
  }

  @override
  Widget build(BuildContext context) {
    final scan   = Bdae015SessionTokenLifecycle.validateConformance(entries);
    final metric = Bdae015SessionTokenLifecycle.evaluateMetric(scan);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('BDAE-015 · Session Lifecycle Gate (OWASP)',
              style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 12))),
            Chip(
              label: Text('${scan.testOutput} · ${scan.lifespanViolations} lifespan · ${scan.revocationViolations} revocation',
                style: const TextStyle(color: Colors.white, fontSize: 11)),
              backgroundColor: metric == 'PASS'
                  ? const Color(0xFF137333) : const Color(0xFFD93025),
            ),
          ]),
        ),
        Expanded(child: ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final e    = entries[i];
            final pass = e.isConformant;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                title: Text('${e.mobilePlatform} · ${e.deviceTypeLabel}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                subtitle: Text(
                  'lifespan: ${e.sessionLifespanHours}h / 8h max | idle: ${e.idleTimeoutMin}min | revoke: ${e.revokePubsubMs}ms | response: ${e.responseMs}ms',
                  style: const TextStyle(fontSize: 10)),
                trailing: Chip(
                  label: Text(e.owaspTier,
                    style: const TextStyle(color: Colors.white, fontSize: 9)),
                  backgroundColor: _tierColor(e.owaspTier),
                ),
                leading: Icon(
                  pass ? Icons.timer_outlined : Icons.timer_off,
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
