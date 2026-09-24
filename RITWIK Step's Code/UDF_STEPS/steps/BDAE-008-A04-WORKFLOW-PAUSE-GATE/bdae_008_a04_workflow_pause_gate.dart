// ============================================================
// BDAE-008-A04 | Inline Secondary Security Validation Forms
// Atomic Task: Implement logic to pause the user workflow when a tagged action is triggered.
// Primary Table: secondary_validation_action_registry
// Metric: Build / Implementation Completeness | Floor=0.9% | Optimal=1.0%
// Library: mobile-secure-auth-lib | Component: <StepUpMFAPrompt>
// EC Lines: 8 | Standard: ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Security: TOTP window=30s | max_attempts=3 | lockout=15min
//           totp_secret_ref = Cloud Secret Manager path ONLY — never raw secret
// Repo: github.com/RitwikHC/theme-typography · branch: ritwik
// Author: Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date: 29-Aug-2026
// ============================================================

import 'package:flutter/material.dart';

// ── Data Models ──────────────────────────────────────────────

enum ExecutionStatus { pending, running, complete, failed }

enum StepOutcome { complete, partial, notComplete }

enum ActionStatus { pending, verified, rejected, locked }

/// Maps to secondary_validation_action_registry.
/// Pause logic gate: tagged high-risk actions must suspend the user
/// workflow and transition action_status=PENDING within 200ms of trigger.
/// totp_secret_ref stores Cloud Secret Manager path ONLY — never raw secret.
class SecondaryValidationActionEntry {
  final String actionRuleId;      // PK — UUID
  final String actionTag;         // tagged high-risk action e.g. DELETE_RECORD
  final String totpSecretRef;     // Cloud Secret Manager path — never raw secret
  final ActionStatus actionStatus; // PENDING / VERIFIED / REJECTED / LOCKED
  final String pauseTriggerType;  // ON_CLICK / ON_SUBMIT / ON_NAVIGATE
  final int pauseLatencyMs;       // measured ms to trigger pause; gate <= 200
  final bool pausedInd;           // TRUE = workflow successfully suspended
  final bool immutableInd;
  final ExecutionStatus executionStatus;
  final StepOutcome stepOutcome;
  final bool complianceStatusInd;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;

  const SecondaryValidationActionEntry({
    required this.actionRuleId,
    required this.actionTag,
    required this.totpSecretRef,
    required this.actionStatus,
    required this.pauseTriggerType,
    required this.pauseLatencyMs,
    this.pausedInd = false,
    this.immutableInd = false,
    this.executionStatus = ExecutionStatus.pending,
    this.stepOutcome = StepOutcome.partial,
    this.complianceStatusInd = true,
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
  })  :     if (!(!totpSecretRef.startsWith('RAW:'))) {
      throw ArgumentError('EC-BDAE008A04-003: totpSecretRef must be a Secret Manager path — never a raw secret');
    },
            if (!(pauseLatencyMs >= 0)) {
      throw ArgumentError('EC-BDAE008A04-002: pauseLatencyMs must be >= 0');
    };

  static const int    kMaxPauseLatencyMs = 200;
  static const double kFloor             = 0.90;
  static const double kOptimal           = 1.00;

  static const String kRequiredSecretPrefix = 'projects/'; // GCP Secret Manager path format

  /// EC:6 gate — workflow paused within 200ms AND status=PENDING
  bool get isConformant =>
      pausedInd &&
      pauseLatencyMs <= kMaxPauseLatencyMs &&
      actionStatus == ActionStatus.pending;

  String get actionStatusLabel => switch (actionStatus) {
    ActionStatus.pending  => 'PENDING',
    ActionStatus.verified => 'VERIFIED',
    ActionStatus.rejected => 'REJECTED',
    ActionStatus.locked   => 'LOCKED',
  };

  /// Confirm totp_secret_ref is a GCP Secret Manager path — never raw value
  bool get secretRefIsValid => totpSecretRef.startsWith(kRequiredSecretPrefix);

  SecondaryValidationActionEntry copyWith({
    ActionStatus? actionStatus,
    bool? pausedInd,
    bool? immutableInd,
    ExecutionStatus? executionStatus,
    StepOutcome? stepOutcome,
    bool? complianceStatusInd,
  }) {
    return SecondaryValidationActionEntry(
      actionRuleId:            actionRuleId,
      actionTag:               actionTag,
      totpSecretRef:           totpSecretRef,
      actionStatus:            actionStatus ?? this.actionStatus,
      pauseTriggerType:        pauseTriggerType,
      pauseLatencyMs:          pauseLatencyMs,
      pausedInd:               pausedInd ?? this.pausedInd,
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

/// Pause gate scan result — maps to action_validation_log.
class WorkflowPauseScanResult {
  final int violationCount;
  final int latencyViolations;
  final int secretRefViolations;
  final String conformanceOutput; // Complete / Partial / Not Complete
  final String result;
  final String ecLineRef;

  const WorkflowPauseScanResult({
    required this.violationCount,
    required this.latencyViolations,
    required this.secretRefViolations,
    required this.conformanceOutput,
    required this.result,
    required this.ecLineRef,
  });
}

// ── EC:1–8 Pipeline ──────────────────────────────────────────

class Bdae008A04WorkflowPauseGate {
  static const double _floor   = 0.9;  // metric floor gate
  static const double _optimal = 1.0; // metric optimal target


  // EC:1 — Locate workflow pause configuration for BDAE-008-A04 within
  //         the bdae-008-kit source repository.
  static Map<String, dynamic>? locateConfiguration(String repoPath) {
        if (!(repoPath.isNotEmpty)) {
      throw ArgumentError('EC-BDAE008A04-001: repo path must not be empty');
    };
    return {'ref': 'BDAE-008-A04', 'config_file': 'workflow_pause.yaml'};
  }

  // EC:2 — Extract actionRuleId, actionTag, totpSecretRef, actionStatus,
  //         pauseTriggerType from secondary_validation_action_registry.
  static Map<String, dynamic> extractParameters(Map<String, dynamic> config) {
    const required = [
      'action_rule_id', 'action_tag',
      'totp_secret_ref', 'action_status', 'pause_trigger_type',
    ];
    if (!(required.every((k) => config.containsKey(k) && config[k] != null))) {
      throw ArgumentError('EC-BDAE008A04-002: all 5 workflow pause fields must be non-null',
    );
    return Map<String, dynamic>.from(config);
  }

  // EC:3 — Compile workflow pause rule set:
  //         tagged actions trigger immediate workflow suspension,
  //         TOTP verification presented within 200ms of pause,
  //         action_status transitions to PENDING on trigger,
  //         TOTP window=30s, max_attempts=3, lockout=15min.
  static Map<String, dynamic> compileRuleSet() {
    return {
      'pause_latency_ms':   SecondaryValidationActionEntry.kMaxPauseLatencyMs,
      'action_status':      'PENDING',
      'totp_window_sec':    30,
      'max_attempts':       3,
      'lockout_min':        15,
      'secret_ref_format':  'projects/<project>/secrets/<name>/versions/<version>',
      'ref':                'BDAE-008-A04',
      'immutable':          true,
    };
  }

  // EC:4 — Register compiled workflow pause rule set as immutable entry in
  //         secondary_validation_action_registry with immutable_IND=TRUE.
  static SecondaryValidationActionEntry registerRule(
    SecondaryValidationActionEntry entry,
  ) {
    // Fail-closed security gate — must hold in release too (asserts are stripped there).
    if (!entry.secretRefIsValid) {
      throw StateError(
        'EC-BDAE008A04-003: totpSecretRef must start with "projects/" (GCP Secret Manager path)');
    }
    }
    if (entry.totpSecretRef.startsWith('RAW:')) {
      throw StateError(
        'EC-BDAE008A04-003: raw TOTP secrets are forbidden — use Secret Manager path');
    }
    return entry.copyWith(
      immutableInd:    true,
      executionStatus: ExecutionStatus.running,
    );
  }

  // EC:5 — Bind each registered pause rule to its corresponding high-risk
  //         action handler by applying the action_handler_FK constraint.
  static String bindToTarget(String ruleId, String actionTag) {
        if (!(ruleId.isNotEmpty)) {
      throw ArgumentError('EC-BDAE008A04-005: FK bind requires valid ruleId');
    };
    return '$actionTag:$ruleId';
  }

  // EC:6 — Validate each bound pause configuration by executing a workflow
  //         suspension test: pausedInd=TRUE within 200ms of high-risk action
  //         trigger, action_status=PENDING for all tagged actions.
  static WorkflowPauseScanResult validateConformance(
    List<SecondaryValidationActionEntry> entries,
  ) {
    final violations      = entries.where((e) => !e.isConformant).length;
    final latencyV        = entries.where((e) =>
      e.pauseLatencyMs > SecondaryValidationActionEntry.kMaxPauseLatencyMs).length;
    final secretRefV      = entries.where((e) => !e.secretRefIsValid).length;
    final total           = entries.length;
    final rate            = total > 0 ? (total - violations) / total : 0.0;
    final output = rate >= 0.98 ? 'Complete'
                 : rate >= 0.90 ? 'Partial'
                 : 'Not Complete';
    return WorkflowPauseScanResult(
      violationCount:      violations,
      latencyViolations:   latencyV,
      secretRefViolations: secretRefV,
      conformanceOutput:   output,
      result:              rate >= SecondaryValidationActionEntry.kFloor ? 'PASS' : 'FAIL',
      ecLineRef:           'EC-BDAE008A04-006',
    );
  }

  // EC:7 — Validate the workflow pause implementation against the
  //         Build/Implementation Completeness metric.
  //         Complete = 90% of acceptance criteria met (Floor).
  //         Optimal = 100% of acceptance criteria met.
  static String evaluateMetric(WorkflowPauseScanResult scan, int total) {
    if (total == 0) return 'FAIL';
    final rate = (total - scan.violationCount) / total;
    return rate >= SecondaryValidationActionEntry.kFloor ? 'PASS' : 'FAIL';
  }

  // EC:8 — Route the validated workflow pause configuration to the
  //         security_rule_registry as the authoritative BDAE-008-A04
  //         Pause Gate entry.
  static SecondaryValidationActionEntry routeToRegistry(
    SecondaryValidationActionEntry entry,
    WorkflowPauseScanResult scan,
  ) {
    final passed = scan.violationCount == 0;
    return entry.copyWith(
      executionStatus:     passed ? ExecutionStatus.complete : ExecutionStatus.failed,
      stepOutcome:         passed ? StepOutcome.complete : StepOutcome.notComplete,
      complianceStatusInd: passed,
    );
  }

  // ── Triangular Check ─────────────────────────────────────
  /// tagged_actions_registered - pause_triggers_confirmed == 0
  static bool triangularCheck(int actionsRegistered, int triggersConfirmed) {
    return (actionsRegistered - triggersConfirmed) == 0;
  }
}

// ── Widget ───────────────────────────────────────────────────

class Bdae008A04WorkflowPauseWidget extends StatelessWidget {
  final List<SecondaryValidationActionEntry> entries;
  const Bdae008A04WorkflowPauseWidget({super.key, required this.entries});

  Color _statusColor(ActionStatus s) => switch (s) {
    ActionStatus.pending  => const Color(0xFF1A73E8),
    ActionStatus.verified => cs.tertiary,
    ActionStatus.rejected => cs.error,
    ActionStatus.locked   => const Color(0xFFE37400),
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scan   = Bdae008A04WorkflowPauseGate.validateConformance(entries);
    final metric = Bdae008A04WorkflowPauseGate.evaluateMetric(scan, entries.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(
                  'BDAE-008-A04 · Workflow Pause Gate',
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                )),
                Chip(
                  label: Text(
                    '${scan.conformanceOutput} · ${scan.violationCount} violations',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  backgroundColor: metric == 'PASS'
                      ? cs.tertiary
                      : cs.error,
                ),
              ]),
              // Latency + secret ref violation callouts
              if (scan.latencyViolations > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '⚠ Pause latency > 200ms: ${scan.latencyViolations} action(s)',
                    style: const TextStyle(
                        fontSize: 11, color: cs.error),
                  ),
                ),
              if (scan.secretRefViolations > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '🔒 Invalid TOTP secret ref (must be Secret Manager path): ${scan.secretRefViolations} action(s)',
                    style: const TextStyle(
                        fontSize: 11, color: cs.error,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, i) {
              final e            = entries[i];
              final pass         = e.isConformant;
              final latencyOk    = e.pauseLatencyMs <= SecondaryValidationActionEntry.kMaxPauseLatencyMs;
              final secretOk     = e.secretRefIsValid;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(
                    '${e.actionTag} · ${e.pauseTriggerType}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'latency: ${e.pauseLatencyMs}ms / ${SecondaryValidationActionEntry.kMaxPauseLatencyMs}ms | paused: ${e.pausedInd} | immutable: ${e.immutableInd}',
                        style: TextStyle(
                          fontSize: 11,
                          color: latencyOk ? null : cs.error,
                        ),
                      ),
                      Text(
                        'secret ref: ${secretOk ? "✓ valid path" : "✗ INVALID — must be Secret Manager path"}',
                        style: TextStyle(
                          fontSize: 10,
                          color: secretOk
                              ? cs.tertiary
                              : cs.error,
                          fontWeight: secretOk
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(
                      e.actionStatusLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    backgroundColor: _statusColor(e.actionStatus),
                  ),
                  leading: Icon(
                    pass ? Icons.pause_circle : Icons.pause_circle_outline,
                    color: pass
                        ? cs.tertiary
                        : cs.error,
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
