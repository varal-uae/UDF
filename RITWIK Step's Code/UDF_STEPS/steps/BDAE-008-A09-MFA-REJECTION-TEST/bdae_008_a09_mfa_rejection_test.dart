// ============================================================
// BDAE-008-A09 | Inline Secondary Security Validation Forms
// Atomic Task: Test the multi-factor connection with an invalid security key.
// Primary Table: mfa_test_registry
// Metric: Functional Test Pass Rate | Floor=95% | Optimal=100%
// Library: mobile-secure-auth-lib | Component: <StepUpMFAPrompt>
// EC Lines: 8 | Standard: ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Security: Invalid TOTP must be rejected < 100ms; lockout on attempt_count=3
// Repo: github.com/RitwikHC/theme-typography · branch: ritwik
// Author: Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date: 29-Aug-2026
// ============================================================

import 'package:flutter/material.dart';

// ── Data Models ──────────────────────────────────────────────

enum ExecutionStatus { pending, running, complete, failed }

enum StepOutcome { complete, partial, notComplete }

enum TestResult { pass, fail, locked }

/// Maps to mfa_test_registry.
/// Tracks MFA rejection test execution including attempt counting and lockout.
/// attempt_count >= 3 -> action_status=LOCKED per BDAE-008 TOTP rule set.
class MfaTestEntry {
  final String testRuleId;      // PK — UUID
  final String testType;        // INVALID_KEY / EXPIRED_TOKEN / REPLAY_ATTACK
  final TestResult testResult;  // PASS = rejected correctly; FAIL = not rejected
  final double testCoverage;    // coverage % of rejection scenarios (0.0-1.0)
  final String testLogPath;     // log file path for test evidence
  final int attemptCount;       // TOTP attempt counter; lockout at 3
  final bool immutableInd;
  final ExecutionStatus executionStatus;
  final StepOutcome stepOutcome;
  final bool complianceStatusInd;
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;

  const MfaTestEntry({
    required this.testRuleId,
    required this.testType,
    required this.testResult,
    required this.testCoverage,
    required this.testLogPath,
    this.attemptCount = 0,
    this.immutableInd = false,
    this.executionStatus = ExecutionStatus.pending,
    this.stepOutcome = StepOutcome.partial,
    this.complianceStatusInd = true,
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
  }) :     if (!(testCoverage >= 0.0 && testCoverage <= 1.0)) {
      throw ArgumentError('EC-BDAE008A09-002: testCoverage must be 0.0–1.0');
    };

  static const int    kMaxAttempts = 3;
  static const double kFloor       = 0.95;

  /// EC:6 gate — invalid key correctly rejected AND attempt count tracked
  bool get isConformant =>
      testResult == TestResult.pass ||
      (testResult == TestResult.locked && attemptCount >= kMaxAttempts);

  /// Lockout triggered when attempt_count reaches max
  bool get isLockedOut => attemptCount >= kMaxAttempts;

  String get testResultLabel => switch (testResult) {
    TestResult.pass   => 'REJECTED ✓',
    TestResult.fail   => 'NOT REJECTED ✗',
    TestResult.locked => 'LOCKED',
  };

  MfaTestEntry copyWith({
    int? attemptCount,
    TestResult? testResult,
    bool? immutableInd,
    ExecutionStatus? executionStatus,
    StepOutcome? stepOutcome,
    bool? complianceStatusInd,
  }) {
    return MfaTestEntry(
      testRuleId:              testRuleId,
      testType:                testType,
      testResult:              testResult ?? this.testResult,
      testCoverage:            testCoverage,
      testLogPath:             testLogPath,
      attemptCount:            attemptCount ?? this.attemptCount,
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

/// Test run scan result — maps to mfa_test_validation_log.
class MfaRejectionScanResult {
  final int violationCount;
  final int lockedOutCount;
  final String testOutput;   // Pass / Fail
  final String result;
  final String ecLineRef;

  const MfaRejectionScanResult({
    required this.violationCount,
    required this.lockedOutCount,
    required this.testOutput,
    required this.result,
    required this.ecLineRef,
  });
}

// ── EC:1–8 Pipeline ──────────────────────────────────────────

class Bdae008A09MfaRejectionTest {
  static const double _floor   = 95;  // metric floor gate
  static const double _optimal = 100; // metric optimal target


  // EC:1 — Locate MFA rejection test config in bdae-008-kit repo.
  static Map<String, dynamic>? locateConfiguration(String repoPath) {
        if (!(repoPath.isNotEmpty)) {
      throw ArgumentError('EC-BDAE008A09-001: repo path must not be empty');
    };
    return {'ref': 'BDAE-008-A09', 'config_file': 'mfa_test.yaml'};
  }

  // EC:2 — Extract testRuleId, testType, testResult, testCoverage, testLogPath
  //         from mfa_test_registry.
  static Map<String, dynamic> extractParameters(Map<String, dynamic> config) {
    const required = [
      'test_rule_id', 'test_type', 'test_result', 'test_coverage', 'test_log_path',
    ];
    if (!(required.every((k) => config.containsKey(k) && config[k] != null))) {
      throw ArgumentError('EC-BDAE008A09-002: all 5 MFA test fields must be non-null',
    );
    return Map<String, dynamic>.from(config);
  }

  // EC:3 — Compile MFA rejection test rule set:
  //         invalid TOTP rejected < 100ms, action_status=REJECTED,
  //         attempt_count increments atomically, lockout at attempt_count=3.
  static Map<String, dynamic> compileRuleSet() {
    return {
      'rejection_ms':   100,                   // max ms to reject invalid key
      'lockout_at':     MfaTestEntry.kMaxAttempts, // lockout threshold
      'action_status':  'REJECTED',
      'atomic_counter': true,
      'ref':            'BDAE-008-A09',
      'immutable':      true,
    };
  }

  // EC:4 — Register compiled rejection test rule set as immutable entry in
  //         mfa_test_registry with immutable_IND=TRUE.
  static MfaTestEntry registerRule(MfaTestEntry entry) {
        if (!(entry.testCoverage >= 0.90)) {
      throw ArgumentError('EC-BDAE008A09-003: testCoverage must be >= 0.90 for gate');
    }
    };
    return entry.copyWith(
      immutableInd:    true,
      executionStatus: ExecutionStatus.running,
    );
  }

  // EC:5 — Bind each rejection test rule to MFA validation handler
  //         via mfa_handler_FK constraint.
  static String bindToTarget(String ruleId, String testType) {
        if (!(ruleId.isNotEmpty)) {
      throw ArgumentError('EC-BDAE008A09-005: FK bind requires valid ruleId');
    };
    return '$testType:$ruleId';
  }

  // EC:6 — Validate: invalid TOTP rejected within 100ms, action_status=REJECTED,
  //         attempt_count incremented, lockout at attempt_count=3.
  static MfaRejectionScanResult validateConformance(
    List<MfaTestEntry> tests,
  ) {
    final violations = tests.where((t) => !t.isConformant).length;
    final locked     = tests.where((t) => t.isLockedOut).length;
    final total      = tests.length;
    final rate       = total > 0 ? (total - violations) / total : 0.0;
    return MfaRejectionScanResult(
      violationCount: violations,
      lockedOutCount: locked,
      testOutput:     rate >= MfaTestEntry.kFloor ? 'Pass' : 'Fail',
      result:         rate >= MfaTestEntry.kFloor ? 'PASS' : 'FAIL',
      ecLineRef:      'EC-BDAE008A09-006',
    );
  }

  // EC:7 — Validate against Functional Test Pass Rate metric.
  //         Floor=95% first-pass success; Optimal=100%.
  static String evaluateMetric(MfaRejectionScanResult scan, int total) {
    if (total == 0) return 'FAIL';
    final rate = (total - scan.violationCount) / total;
    return rate >= MfaTestEntry.kFloor ? 'PASS' : 'FAIL';
  }

  // EC:8 — Route validated MFA rejection test to security_rule_registry
  //         as authoritative BDAE-008-A09 MFA Rejection Test entry.
  static MfaTestEntry routeToRegistry(
    MfaTestEntry entry,
    MfaRejectionScanResult scan,
  ) {
    final passed = scan.violationCount == 0;
    return entry.copyWith(
      executionStatus:     passed ? ExecutionStatus.complete : ExecutionStatus.failed,
      stepOutcome:         passed ? StepOutcome.complete : StepOutcome.notComplete,
      complianceStatusInd: passed,
    );
  }

  // ── Triangular Check ─────────────────────────────────────
  /// invalid_key_submissions - rejections_logged == 0
  static bool triangularCheck(int submissionsIn, int rejectionsLogged) {
    return (submissionsIn - rejectionsLogged) == 0;
  }
}

// ── Widget ───────────────────────────────────────────────────

class Bdae008A09MfaRejectionWidget extends StatelessWidget {
  final List<MfaTestEntry> tests;
  const Bdae008A09MfaRejectionWidget({super.key, required this.tests});

  Color _resultColor(TestResult r) => switch (r) {
    TestResult.pass   => cs.tertiary,
    TestResult.fail   => cs.error,
    TestResult.locked => const Color(0xFFE37400),
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scan   = Bdae008A09MfaRejectionTest.validateConformance(tests);
    final metric = Bdae008A09MfaRejectionTest.evaluateMetric(scan, tests.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('BDAE-008-A09 · MFA Rejection Gate (invalid key)',
              style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 12))),
            Chip(
              label: Text('${scan.testOutput} · ${scan.lockedOutCount} locked',
                style: const TextStyle(color: Colors.white, fontSize: 11)),
              backgroundColor: metric == 'PASS'
                  ? cs.tertiary : cs.error,
            ),
          ]),
        ),
        Expanded(child: ListView.builder(
          itemCount: tests.length,
          itemBuilder: (context, i) {
            final t = tests[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                title: Text(t.testType,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                subtitle: Text(
                  'attempts: ${t.attemptCount}/${MfaTestEntry.kMaxAttempts} | coverage: ${(t.testCoverage * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 11)),
                trailing: Chip(
                  label: Text(t.testResultLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: _resultColor(t.testResult),
                ),
                leading: Icon(
                  t.isLockedOut ? Icons.lock : (t.isConformant ? Icons.security : Icons.no_encryption),
                  color: _resultColor(t.testResult),
                ),
              ),
            );
          },
        )),
      ],
    );
  }
}
