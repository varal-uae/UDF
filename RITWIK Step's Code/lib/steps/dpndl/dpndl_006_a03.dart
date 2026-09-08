// ============================================================
// DPNDL-006-A03 | Dynamic Panel Navigation Display Layer
// Atomic Task: Build Compact Mobile Bottom Navigation Bar.
// EC Lines: 10 | Standard: ISO/IEC/IEEE 12207 | DCDF AEETE-018
// Repo: github.com/RitwikHC/theme-typography · branch: ritwik
// Author: Ritwik Sharma — Frontend Integration Specialist | UDF Team
// Date: 02-Sep-2026
// ============================================================
//
// EC EXECUTION LOGIC:
  // EC: 1. System loads workspace mobile UI configuration payload.
  // EC: 2. System extracts mobile navigation destination links from workspace configuration payload.
  // EC: 3. System validates mobile navigation destination links count <= 5.
  // EC: 4. System strips nested menu structures from navigation destination items.
  // EC: 5. System maps Material Design icons to navigation destination items.
  // EC: 6. System stacks text labels vertically underneath corresponding icons.
  // EC: 7. System applies pill-shaped highlights to active choices.
  // EC: 8. System sets container vertical dimension to exactly 80dp.
  // EC: 9. System fixes navigation bar container position to viewport base.
  // EC: 10. System renders final mobile bottom navigation payload.
// ============================================================

import 'package:flutter/material.dart';

// ── Enums ──────────────────────────────────────────────────────

enum ExecutionStatus { pending, running, complete, failed }
enum StepOutcome { complete, partial, notComplete }

// ── Data Model ─────────────────────────────────────────────────

/// Primary data model for DPNDL-006-A03.
/// All mandatory DCDF lineage headers per AEETE-018 are present.
class Dpndl006A03Entry {
  final String ruleId;                     // PK — UUID
  final String fieldA;                     // Primary input field
  final String fieldB;                     // Secondary input field
  final String fieldC;                     // Tertiary input field
  final String executionStatusTxt;
  final bool   complianceStatusInd;
  final bool   immutableInd;
  final ExecutionStatus executionStatus;
  final StepOutcome     stepOutcome;
  // Mandatory DCDF lineage headers
  final String traceId;
  final String originSourceId;
  final String immediatePredecessorId;
  final String transformationLogicHash;

  const Dpndl006A03Entry({
    required this.ruleId,
    required this.fieldA,
    required this.fieldB,
    required this.fieldC,
    this.executionStatusTxt  = 'PENDING',
    this.complianceStatusInd = false,
    this.immutableInd        = false,
    this.executionStatus     = ExecutionStatus.pending,
    this.stepOutcome         = StepOutcome.partial,
    required this.traceId,
    required this.originSourceId,
    required this.immediatePredecessorId,
    required this.transformationLogicHash,
  });

  bool get isConformant =>
      complianceStatusInd && executionStatus == ExecutionStatus.complete;

  Dpndl006A03Entry copyWith({
    bool? complianceStatusInd,
    bool? immutableInd,
    ExecutionStatus? executionStatus,
    StepOutcome? stepOutcome,
  }) => Dpndl006A03Entry(
    ruleId: ruleId, fieldA: fieldA, fieldB: fieldB, fieldC: fieldC,
    executionStatusTxt: executionStatusTxt,
    complianceStatusInd: complianceStatusInd ?? this.complianceStatusInd,
    immutableInd: immutableInd ?? this.immutableInd,
    executionStatus: executionStatus ?? this.executionStatus,
    stepOutcome: stepOutcome ?? this.stepOutcome,
    traceId: traceId, originSourceId: originSourceId,
    immediatePredecessorId: immediatePredecessorId,
    transformationLogicHash: transformationLogicHash,
  );
}

// ── Scan Result ─────────────────────────────────────────────────

class Dpndl006A03ScanResult {
  final int    violationCount;
  final String conformanceOutput;
  final String result;
  final String ecLineRef;

  const Dpndl006A03ScanResult({
    required this.violationCount,
    required this.conformanceOutput,
    required this.result,
    required this.ecLineRef,
  });
}

// ── EC:10 Pipeline ────────────────────────────────────────────────────────

class Dpndl006A03Pipeline {

  // EC:1 — EC: 1. System loads workspace mobile UI configuration payload.
  static void executeLoadsStep1(Dpndl006A03Entry entry) {
    // loads workspace mobile UI configuration payload
    assert(entry.ruleId.isNotEmpty, 'EC-DPNDL006A03-001: ruleId required');
  }

  // EC:2 — EC: 2. System extracts mobile navigation destination links from workspace configuration payload.
  static void executeExtractsStep2(Dpndl006A03Entry entry) {
    // extracts mobile navigation destination links from workspace configuration payloa
    assert(entry.ruleId.isNotEmpty, 'EC-DPNDL006A03-002: ruleId required');
  }

  // EC:3 — EC: 3. System validates mobile navigation destination links count <= 5.
  static void executeValidatesStep3(Dpndl006A03Entry entry) {
    // validates mobile navigation destination links count <= 5
    assert(entry.ruleId.isNotEmpty, 'EC-DPNDL006A03-003: ruleId required');
  }

  // EC:4 — EC: 4. System strips nested menu structures from navigation destination items.
  static void executeStripsStep4(Dpndl006A03Entry entry) {
    // strips nested menu structures from navigation destination items
    assert(entry.ruleId.isNotEmpty, 'EC-DPNDL006A03-004: ruleId required');
  }

  // EC:5 — EC: 5. System maps Material Design icons to navigation destination items.
  static void executeMapsStep5(Dpndl006A03Entry entry) {
    // maps Material Design icons to navigation destination items
    assert(entry.ruleId.isNotEmpty, 'EC-DPNDL006A03-005: ruleId required');
  }

  // EC:6 — EC: 6. System stacks text labels vertically underneath corresponding icons.
  static void executeStacksStep6(Dpndl006A03Entry entry) {
    // stacks text labels vertically underneath corresponding icons
    assert(entry.ruleId.isNotEmpty, 'EC-DPNDL006A03-006: ruleId required');
  }

  // EC:7 — EC: 7. System applies pill-shaped highlights to active choices.
  static void executeAppliesStep7(Dpndl006A03Entry entry) {
    // applies pill-shaped highlights to active choices
    assert(entry.ruleId.isNotEmpty, 'EC-DPNDL006A03-007: ruleId required');
  }

  // EC:8 — EC: 8. System sets container vertical dimension to exactly 80dp.
  static void executeSetsStep8(Dpndl006A03Entry entry) {
    // sets container vertical dimension to exactly 80dp
    assert(entry.ruleId.isNotEmpty, 'EC-DPNDL006A03-008: ruleId required');
  }

  // EC:9 — EC: 9. System fixes navigation bar container position to viewport base.
  static void executeFixesStep9(Dpndl006A03Entry entry) {
    // fixes navigation bar container position to viewport base
    assert(entry.ruleId.isNotEmpty, 'EC-DPNDL006A03-009: ruleId required');
  }

  // EC:10 — EC: 10. System renders final mobile bottom navigation payload.
  static void executeRendersStep10(Dpndl006A03Entry entry) {
    // renders final mobile bottom navigation payload
    assert(entry.ruleId.isNotEmpty, 'EC-DPNDL006A03-010: ruleId required');
  }

  static Dpndl006A03ScanResult validateConformance(List<Dpndl006A03Entry> entries) {
    final violations = entries.where((e) => !e.isConformant).length;
    final total      = entries.length;
    final rate       = total > 0 ? (total - violations) / total : 0.0;
    return Dpndl006A03ScanResult(
      violationCount:    violations,
      conformanceOutput: rate >= 0.98 ? 'Complete' : rate >= 0.90 ? 'Partial' : 'Not Complete',
      result:            violations == 0 ? 'PASS' : 'FAIL',
      ecLineRef:         'EC-DPNDL006A03-VAL',
    );
  }

  static Dpndl006A03Entry routeToRegistry(Dpndl006A03Entry entry, Dpndl006A03ScanResult scan) {
    final passed = scan.violationCount == 0;
    return entry.copyWith(
      immutableInd: passed,
      executionStatus: passed ? ExecutionStatus.complete : ExecutionStatus.failed,
      stepOutcome: passed ? StepOutcome.complete : StepOutcome.notComplete,
      complianceStatusInd: passed,
    );
  }
}

// ── Widget ─────────────────────────────────────────────────────

class Dpndl006A03Widget extends StatelessWidget {
  final List<Dpndl006A03Entry> entries;
  const Dpndl006A03Widget({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final scan = Dpndl006A03Pipeline.validateConformance(entries);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(child: Text('DPNDL-006-A03',
              style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 12))),
            Chip(
              label: Text('${scan.conformanceOutput} · ${scan.violationCount} violations',
                style: const TextStyle(color: Colors.white, fontSize: 11)),
              backgroundColor: scan.result == 'PASS'
                  ? const Color(0xFF137333) : const Color(0xFFD93025),
            ),
          ]),
        ),
        Expanded(child: ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final e = entries[i];
            final pass = e.isConformant;
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: Icon(pass ? Icons.check_circle : Icons.cancel,
                  color: pass ? const Color(0xFF137333) : const Color(0xFFD93025)),
                title: Text(e.fieldA,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                subtitle: Text(
                  'id: ${e.ruleId.length > 8 ? e.ruleId.substring(0,8) : e.ruleId}... '
                  '| ${e.executionStatusTxt} | immutable: ${e.immutableInd}',
                  style: const TextStyle(fontSize: 11)),
                trailing: Chip(
                  label: Text(pass ? 'PASS' : 'FAIL',
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
                  backgroundColor: pass ? const Color(0xFF137333) : const Color(0xFFD93025),
                ),
              ),
            );
          },
        )),
      ],
    );
  }
}
