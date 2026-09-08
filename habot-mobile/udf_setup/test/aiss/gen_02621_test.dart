/// AISS GATE -- Step 96 of 115
/// Global Reference ID:       GEN-02621
/// Atomic Steps Reference ID: GEN-02621-A01
/// Setup Step (Action):       "Step 47: WCAG 2.2 AA Accessibility & Screen
///                             Reader Audit."
/// Metric: WCAG 2.2 AA Compliance Rate -- Floor 0.8, Optimal 1.0, Ceiling 1.0.
///
/// TEMPLATE PROSE, RECORDED: Expected Output is "Fully configured and
/// validated implementation of: [the Description]", Completion Measures is
/// "100% CI/CD pass rate ... documentation committed to runbook", and the four
/// substeps are the generic set. None are gated. The Setup Step Description IS
/// specific -- "verify all colour pairings pass the 4.5:1 contrast ratio
/// requirement" -- and the metric fits, so both are used.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/wcag_audit.dart';
import 'package:udf_setup/design_system/tokens/color_tokens.dart';
import 'package:udf_setup/design_system/tokens/high_contrast_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  late WcagAuditReport report;

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
    report = WcagAudit.report(schemes: HabotHighContrast.allSchemes);
  });

  group('GEN-02621-A01 :: the instrument', () {
    gate(
      'GEN-02621-G1',
      'Setup Step Description: "verify all colour pairings pass the 4.5:1 '
          'contrast ratio requirement".',
      'The audit measures every declared pair in every declared scheme, and '
          'reports a number rather than a verdict',
      () {
        final WcagFinding text = report.findings.firstWhere(
          (WcagFinding f) => f.criterion.id == '1.4.3',
        );
        // 16 text pairs x 4 schemes.
        return text.subjectsChecked == 64 &&
            text.subjectsFailing == 0 &&
            text.outcome == WcagOutcome.pass;
      },
    );

    gate(
      'GEN-02621-G2',
      'Setup Step (Action): the audit is a "WCAG 2.2 AA ... & SCREEN READER '
          'Audit" -- wider than colour.',
      'The criterion set reaches past contrast into reflow, resize, target '
          'size and the four screen-reader criteria, and every criterion names '
          'the step that owns it',
      () {
        final Set<String> ids = WcagCriteria.all
            .map((WcagCriterion c) => c.id)
            .toSet();
        return ids.containsAll(<String>{
              '1.4.3',
              '1.4.11',
              '1.4.4',
              '1.4.10',
              '2.5.8',
              '1.1.1',
              '4.1.2',
              '2.4.3',
              '2.1.2',
              '2.4.11',
            }) &&
            WcagCriteria.all.every(
              (WcagCriterion c) => c.owner.isNotEmpty && c.level.isNotEmpty,
            );
      },
    );
  });

  group('GEN-02621-A01 :: the number is honest', () {
    gate(
      'GEN-02621-G3',
      'Metric: WCAG 2.2 AA Compliance Rate, Floor 0.8, Optimal 1.0.',
      'A criterion that cannot be decided by a machine is EXCLUDED from the '
          'rate rather than auto-passed, so the figure cannot be inflated by '
          'the criteria nobody checked',
      () {
        final List<WcagFinding> judgement = report.judgement;
        return judgement.isNotEmpty &&
            judgement.every(
              (WcagFinding f) => f.outcome != WcagOutcome.pass,
            ) &&
            report.counted.every(
              (WcagFinding f) =>
                  f.criterion.evaluation != WcagEvaluation.judgement,
            );
      },
    );

    gate(
      'GEN-02621-G4',
      'Metric floor 0.8: an unmeasured criterion is an unknown, and an '
          'unknown is not a pass.',
      'A criterion left unevaluated counts AGAINST the rate, so forgetting to '
          'run the runtime half lowers the number instead of hiding in it',
      () {
        // With no runtime findings supplied, five runtime criteria are
        // notEvaluated and must drag the rate below 1.0.
        final WcagAuditReport bare = WcagAudit.report(
          schemes: HabotHighContrast.allSchemes,
        );
        final WcagAuditReport withRuntime = WcagAudit.report(
          schemes: HabotHighContrast.allSchemes,
          runtimeFindings: <WcagFinding>[
            for (final WcagCriterion c in WcagCriteria.ofEvaluation(
              WcagEvaluation.runtime,
            ))
              WcagFinding(
                criterion: c,
                outcome: WcagOutcome.pass,
                detail: 'supplied by the gate that owns it',
                subjectsChecked: 1,
              ),
          ],
        );
        return bare.complianceRate < 1.0 &&
            withRuntime.complianceRate > bare.complianceRate &&
            withRuntime.complianceRate == 1.0;
      },
    );

    gate(
      'GEN-02621-G5',
      'Metric floor 0.8 -- the static half must clear it on its own, because '
          'the runtime half is supplied by other steps.',
      'The statically decidable criteria all pass, so the floor is not being '
          'met by rounding',
      () {
        final List<WcagFinding> static_ = WcagAudit.auditStatic(
          schemes: HabotHighContrast.allSchemes,
        );
        return static_.isNotEmpty &&
            static_.every((WcagFinding f) => f.outcome == WcagOutcome.pass);
      },
    );

    gate(
      'GEN-02621-G6',
      'Setup Step (Action) -- the audit must widen when a scheme is added, '
          'not need editing.',
      'Adding the two Step 105 high-contrast schemes doubled the audited pair '
          'count with no change to the instrument',
      () {
        final WcagFinding twoSchemes = WcagAudit.auditStatic(
          schemes: <String, HabotColorScheme>{
            'light': HabotColors.light,
            'dark': HabotColors.dark,
          },
        ).firstWhere((WcagFinding f) => f.criterion.id == '1.4.3');
        final WcagFinding fourSchemes = report.findings.firstWhere(
          (WcagFinding f) => f.criterion.id == '1.4.3',
        );
        return fourSchemes.subjectsChecked == twoSchemes.subjectsChecked * 2;
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02621',
        atomicStepReferenceId: 'GEN-02621-A01',
        setupStepAction:
            'Step 47: WCAG 2.2 AA Accessibility & Screen Reader Audit.',
        implementationOrder: 96,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'WcagAudit / WcagCriteria / WcagAuditReport',
          'Component Properties':
              '${WcagCriteria.all.length} criteria '
              '(${WcagCriteria.ofEvaluation(WcagEvaluation.static_).length} '
              'static, '
              '${WcagCriteria.ofEvaluation(WcagEvaluation.runtime).length} '
              'runtime, '
              '${WcagCriteria.ofEvaluation(WcagEvaluation.judgement).length} '
              'judgement); '
              '${HabotHighContrast.allSchemes.length} colour schemes audited',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Expected Output, Completion Measures and all four substeps on '
              'this row are the generic GEN-* template. None were gated.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'WCAG 2.2 AA Compliance Rate (static half)',
            observed:
                '${(WcagAudit.report(schemes: HabotHighContrast.allSchemes).complianceRate * 100).toStringAsFixed(1)}% '
                'with the runtime criteria left unevaluated, which is the '
                'honest figure for this step alone. Steps 99-101 supply the '
                'runtime findings that raise it.',
            floor: '0.8',
            optimal: '1.0',
            ceiling: '1.0',
          ),
          const AissMeasurement(
            metricName: 'Criteria requiring a human reading',
            observed:
                '2 (SC 2.4.6 Headings and Labels, SC 3.3.3 Error Suggestion). '
                'Excluded from the rate rather than auto-passed. Counting '
                'them would raise the number without raising conformance.',
            floor: 'excluded from the rate',
            optimal: 'excluded from the rate',
            ceiling: 'excluded from the rate',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/a11y/wcag_audit.dart',
        ],
      ),
    );
  });
}
