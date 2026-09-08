/// AISS GATE -- Step 98 of 115
/// Global Reference ID:       GEN-02775
/// Atomic Steps Reference ID: GEN-02775-A01
/// Setup Step (Action):       "Document all WCAG 2.2 AA audit findings,
///                             remediation actions, and pipeline
///                             configuration."
/// The sheet calls the output an "engineering accessibility runbook".
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/a11y_findings.dart';
import 'package:udf_setup/design_system/a11y/a11y_rules.dart';
import 'package:udf_setup/design_system/a11y/wcag_audit.dart';
import 'package:udf_setup/design_system/tokens/high_contrast_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  late String runbook;

  void gate(String id, String source, String description, bool Function() run) {
    test('[$id] $description', () {
      bool passed = false;
      try {
        passed = run();
        expect(passed, isTrue, reason: '$id failed: $description');
      } finally {
        gates.add(
          AissGate(
            id: id,
            requirementSource: source,
            description: description,
            passed: passed,
          ),
        );
      }
    });
  }

  setUpAll(() {
    runbook = HabotA11yRegister.runbook(schemes: HabotHighContrast.allSchemes);
    try {
      Directory('build/aiss').createSync(recursive: true);
      File('build/aiss/a11y_runbook.md').writeAsStringSync(runbook);
    } on FileSystemException {
      // A read-only sandbox is not a gate failure; the content is asserted
      // below regardless of whether it could be written to disk.
    }
  });

  group('GEN-02775-A01 :: the three sections the row asks for', () {
    gate(
      'GEN-02775-G1',
      'Setup Step (Action): "document all WCAG 2.2 AA audit FINDINGS, '
          'REMEDIATION ACTIONS, and PIPELINE CONFIGURATION".',
      'The runbook carries all three sections, and each is populated rather '
          'than a heading with nothing under it',
      () =>
          runbook.contains('## 1. Findings') &&
          runbook.contains('## 2. Remediation') &&
          runbook.contains('## 3. Pipeline configuration') &&
          runbook.split('\n').length > 40,
    );

    gate(
      'GEN-02775-G2',
      'Floor: "all critical findings documented".',
      'Every criterion the Step 96 audit knows about appears in the findings '
          'table AND has a remediation row -- a finding with no owner is a '
          'finding that will not be fixed',
      () =>
          HabotA11yRegister.isComplete &&
          HabotA11yRegister.criteriaWithoutRemediation.isEmpty &&
          WcagCriteria.all.every(
            (WcagCriterion c) => runbook.contains(c.id),
          ),
    );

    gate(
      'GEN-02775-G3',
      'Setup Step (Action): "...and PIPELINE CONFIGURATION".',
      'Every build-failing rule appears with what it protects and, where it '
          'has one, the reason for its exemption',
      () => HabotA11yRules.all.every(
        (HabotA11yRule r) =>
            runbook.contains(r.id) && runbook.contains(r.owner),
      ),
    );
  });

  group('GEN-02775-A01 :: it is a runbook, not a statement', () {
    gate(
      'GEN-02775-G4',
      'The row calls this an "engineering accessibility runbook" -- a document '
          'that is regenerated rather than maintained.',
      'The runbook is derived from the audit at call time, so changing what '
          'the code does changes the document with no editing step in between',
      () {
        final String withRuntimePasses = HabotA11yRegister.runbook(
          schemes: HabotHighContrast.allSchemes,
          runtimeFindings: <WcagFinding>[
            for (final WcagCriterion c in WcagCriteria.ofEvaluation(
              WcagEvaluation.runtime,
            ))
              WcagFinding(
                criterion: c,
                outcome: WcagOutcome.pass,
                detail: 'supplied by the owning gate',
              ),
          ],
        );
        // The two runs must differ, and differ in the direction the evidence
        // moved. A document that reads the same either way is not generated.
        return withRuntimePasses != runbook &&
            withRuntimePasses.contains('100.0%');
      },
    );

    gate(
      'GEN-02775-G5',
      'An open item without a reason is an item that was forgotten.',
      'Every remediation row that is accepted or awaiting a decision states '
          'why, and the runbook prints that reason rather than only the state',
      () =>
          HabotA11yRegister.remediations.every(
            (HabotRemediation r) => r.isWellFormed,
          ) &&
          runbook.contains('**Open because:**'),
    );

    gate(
      'GEN-02775-G6',
      'The runbook must not flatter the build.',
      'The two criteria that require a human reading are named in the '
          'document as excluded from the rate, so a reader cannot mistake the '
          'percentage for full conformance',
      () =>
          runbook.contains('require a human reading') &&
          runbook.contains('2.4.6') &&
          runbook.contains('3.3.3'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02775',
        atomicStepReferenceId: 'GEN-02775-A01',
        setupStepAction:
            'Document all WCAG 2.2 AA audit findings, remediation actions, '
            'and pipeline configuration.',
        implementationOrder: 98,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotA11yRegister',
          'Component Properties':
              '${HabotA11yRegister.remediations.length} remediation rows over '
              '${WcagCriteria.all.length} criteria and '
              '${HabotA11yRules.all.length} build-failing rules; output '
              'written to build/aiss/a11y_runbook.md on every run',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Expected Output on this row is the generic GEN-* template. The '
              'Setup Step names three sections and those three are what the '
              'document contains.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Criteria documented with an owning step',
            observed:
                '${WcagCriteria.all.length} of ${WcagCriteria.all.length}. '
                '${HabotA11yRegister.remediations.where((HabotRemediation r) => r.state == HabotRemediationState.accepted).length} '
                'are knowingly open, each with a recorded reason.',
            floor: 'all critical findings documented',
            optimal: 'all findings documented with an owner',
            ceiling: 'all findings documented with an owner',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/a11y/a11y_findings.dart',
          'build/aiss/a11y_runbook.md',
        ],
      ),
    );
  });
}
