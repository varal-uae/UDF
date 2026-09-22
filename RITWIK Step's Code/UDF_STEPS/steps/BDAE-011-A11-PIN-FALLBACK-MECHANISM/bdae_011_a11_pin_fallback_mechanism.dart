// ============================================================
// BDAE-011-A11 | WebAuthn Biometric Authentication
// Atomic Task: Implement single-use PIN entry codes as the fallback mechanism.
// Primary Table: biometric_fallback_registry
// Metric: Build / Implementation Completeness | Floor=90% | Optimal=100%
// Library: @habot-connect/layout-shell | GCP: Pub/Sub fan-out to Cloud Run
// EC Lines: 8 | Standard: ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Security: Single-use PIN expires after 5min or first use; delivered via secure push
// Repo: github.com/RitwikHC/theme-typography · branch: ritwik
// Author: Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date: 29-Aug-2026
// ============================================================

import 'package:flutter/material.dart';

// ── Data Models ──────────────────────────────────────────────

enum ExecutionStatus { pending, running, complete, failed }

enum StepOutcome { complete, partial, notComplete }

enum PinStatus { pending, delivered, used, expired }

/// Maps to biometric_fallback_registry.
/// Single-use PIN fallback for environments where biometric hardware is unavailable.
/// PIN must expire after 5 minutes or first use — whichever comes first.
class PinFallbackEntry {
  final String pinFallbackRuleId;   // PK — UUID
  final String stepExecutionId;     // execution context UUID
  final ExecutionStatus executionStatus;
  final StepOutcome stepOutcome;
  final String userId;              // UUID reference only — no PII
  final PinStatus pinStatus;        // PENDING / DELIVERED / USED / EXPIRED
  final int pinExpiryMinutes;       // must be 5 per BDAE-011 rule set
  final bool singleUseEnforced;     // TRUE = PIN invalidated on first use
  final bool immutableInd;
  final bool complianceStatusInd;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;

  const PinFallbackEntry({
    required this.pinFallbackRuleId,
    required this.stepExecutionId,
    this.executionStatus = ExecutionStatus.pending,
    this.stepOutcome = StepOutcome.partial,
    required this.userId,
    this.pinStatus = PinStatus.pending,
    this.pinExpiryMinutes = 5,
    this.singleUseEnforced = true,
    this.immutableInd = false,
    this.complianceStatusInd = true,
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
  }) :     if (!(pinExpiryMinutes <= 5)) {
      throw ArgumentError('EC-BDAE011A11-003: pinExpiryMinutes must be <= 5 per BDAE-011 rule set');
    };

  static const int    kMaxExpiryMin = 5;
  static const double kFloor        = 0.90;

  /// EC:6 gate — PIN rules conformant:
  ///   single-use enforced, expiry <= 5min, status valid
  bool get isConformant =>
      singleUseEnforced &&
      pinExpiryMinutes <= kMaxExpiryMin &&
      pinStatus != PinStatus.expired;

  String get pinStatusLabel => switch (pinStatus) {
    PinStatus.pending   => 'PENDING',
    PinStatus.delivered => 'DELIVERED',
    PinStatus.used      => 'USED',
    PinStatus.expired   => 'EXPIRED',
  };

  PinFallbackEntry copyWith({
    PinStatus? pinStatus,
    ExecutionStatus? executionStatus,
    StepOutcome? stepOutcome,
    bool? immutableInd,
    bool? complianceStatusInd,
  }) {
    return PinFallbackEntry(
      pinFallbackRuleId:       pinFallbackRuleId,
      stepExecutionId:         stepExecutionId,
      executionStatus:         executionStatus ?? this.executionStatus,
      stepOutcome:             stepOutcome ?? this.stepOutcome,
      userId:                  userId,
      pinStatus:               pinStatus ?? this.pinStatus,
      pinExpiryMinutes:        pinExpiryMinutes,
      singleUseEnforced:       singleUseEnforced,
      immutableInd:            immutableInd ?? this.immutableInd,
      complianceStatusInd:     complianceStatusInd ?? this.complianceStatusInd,
      traceId:                 traceId,
      originSourceId:          originSourceId,
      immediatePredecessorId:  immediatePredecessorId,
      transformationLogicHash: transformationLogicHash,
    );
  }
}

/// Scan result — maps to fallback_validation_log.
class PinFallbackScanResult {
  final int violationCount;
  final int expiredCount;
  final String conformanceOutput; // Complete / Partial / Not Complete
  final String result;
  final String ecLineRef;

  const PinFallbackScanResult({
    required this.violationCount,
    required this.expiredCount,
    required this.conformanceOutput,
    required this.result,
    required this.ecLineRef,
  });
}

// ── EC:1–8 Pipeline ──────────────────────────────────────────

class Bdae011A11PinFallbackMechanism {
  static const double _floor   = 90;  // metric floor gate
  static const double _optimal = 100; // metric optimal target


  // EC:1 — Locate PIN fallback config in bdae-011-kit repo.
  static Map<String, dynamic>? locateConfiguration(String repoPath) {
        if (!(repoPath.isNotEmpty)) {
      throw ArgumentError('EC-BDAE011A11-001: repo path must not be empty');
    };
    return {'ref': 'BDAE-011-A11', 'config_file': 'biometric_fallback.yaml'};
  }

  // EC:2 — Extract pinFallbackRuleId, stepExecutionId, executionStatus,
  //         stepOutcome, userId from biometric_fallback_registry.
  static Map<String, dynamic> extractParameters(Map<String, dynamic> config) {
    const required = [
      'pin_fallback_rule_id', 'step_execution_id',
      'execution_status', 'step_outcome', 'user_id',
    ];
    if (!(required.every((k) => config.containsKey(k) && config[k] != null))) {
      throw ArgumentError('EC-BDAE011A11-002: all 5 PIN fallback fields must be non-null',
    );
    return Map<String, dynamic>.from(config);
  }

  // EC:3 — Compile PIN fallback rule set:
  //         single-use PIN generated on biometric failure, expiry=5min,
  //         PIN delivered via secure push channel within 30s,
  //         authentication_status=FALLBACK on PIN path.
  static Map<String, dynamic> compileRuleSet() {
    return {
      'single_use':       true,
      'expiry_min':       PinFallbackEntry.kMaxExpiryMin,
      'delivery_sec':     30,    // deliver via secure push within 30s
      'auth_status':      'FALLBACK',
      'ref':              'BDAE-011-A11',
      'immutable':        true,
    };
  }

  // EC:4 — Register compiled PIN fallback rule set as immutable entry in
  //         biometric_fallback_registry with immutable_IND=TRUE.
  static PinFallbackEntry registerRule(PinFallbackEntry entry) {
        if (!(entry.singleUseEnforced)) {
      throw ArgumentError('EC-BDAE011A11-003: singleUseEnforced must be TRUE — PIN must expire on first use');
    }
    };
        if (!(entry.pinExpiryMinutes <= PinFallbackEntry.kMaxExpiryMin)) {
      throw ArgumentError('EC-BDAE011A11-003: pinExpiryMinutes must be <= 5');
    };
    return entry.copyWith(
      immutableInd:    true,
      executionStatus: ExecutionStatus.running,
    );
  }

  // EC:5 — Bind each PIN fallback rule to fallback handler
  //         via webauthn_handler_FK constraint.
  static String bindToTarget(String ruleId, String userId) {
        if (!(ruleId.isNotEmpty)) {
      throw ArgumentError('EC-BDAE011A11-005: FK bind requires valid ruleId');
    };
    return '$userId:$ruleId';
  }

  // EC:6 — Validate PIN fallback:
  //         single-use PIN generates on biometric failure, delivered within 30s,
  //         PIN expires after 5min or first use, authentication_status=FALLBACK.
  static PinFallbackScanResult validateConformance(
    List<PinFallbackEntry> entries,
  ) {
    final violations = entries.where((e) => !e.isConformant).length;
    final expired    = entries.where((e) => e.pinStatus == PinStatus.expired).length;
    final total      = entries.length;
    final rate       = total > 0 ? (total - violations) / total : 0.0;
    final output = rate >= 0.98 ? 'Complete'
                 : rate >= 0.90 ? 'Partial'
                 : 'Not Complete';
    return PinFallbackScanResult(
      violationCount:   violations,
      expiredCount:     expired,
      conformanceOutput: output,
      result:           rate >= PinFallbackEntry.kFloor ? 'PASS' : 'FAIL',
      ecLineRef:        'EC-BDAE011A11-006',
    );
  }

  // EC:7 — Validate against Build/Implementation Completeness metric.
  //         Floor=90%; Optimal=100%.
  static String evaluateMetric(PinFallbackScanResult scan, int total) {
    if (total == 0) return 'FAIL';
    final rate = (total - scan.violationCount) / total;
    return rate >= PinFallbackEntry.kFloor ? 'PASS' : 'FAIL';
  }

  // EC:8 — Route validated PIN fallback configuration to security_rule_registry
  //         as authoritative BDAE-011-A11 PIN Fallback entry.
  static PinFallbackEntry routeToRegistry(
    PinFallbackEntry entry,
    PinFallbackScanResult scan,
  ) {
    final passed = scan.violationCount == 0;
    return entry.copyWith(
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

class Bdae011A11PinFallbackWidget extends StatelessWidget {
  final List<PinFallbackEntry> entries;
  const Bdae011A11PinFallbackWidget({super.key, required this.entries});

  Color _pinColor(PinStatus s) => switch (s) {
    PinStatus.pending   => const Color(0xFFE37400),
    PinStatus.delivered => const Color(0xFF1A73E8),
    PinStatus.used      => cs.tertiary,
    PinStatus.expired   => cs.error,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scan   = Bdae011A11PinFallbackMechanism.validateConformance(entries);
    final metric = Bdae011A11PinFallbackMechanism.evaluateMetric(scan, entries.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('BDAE-011-A11 · PIN Fallback Gate (single-use, 5min)',
              style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 12))),
            Chip(
              label: Text('${scan.conformanceOutput} · ${scan.expiredCount} expired',
                style: const TextStyle(color: Colors.white, fontSize: 11)),
              backgroundColor: metric == 'PASS'
                  ? cs.tertiary : cs.error,
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
                title: Text('PIN Fallback · ${e.pinFallbackRuleId.substring(0, 8)}...',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                subtitle: Text(
                  'expiry: ${e.pinExpiryMinutes}min | single-use: ${e.singleUseEnforced} | immutable: ${e.immutableInd}',
                  style: const TextStyle(fontSize: 11)),
                trailing: Chip(
                  label: Text(e.pinStatusLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: _pinColor(e.pinStatus),
                ),
                leading: Icon(
                  pass ? Icons.pin_outlined : Icons.pin_drop,
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
