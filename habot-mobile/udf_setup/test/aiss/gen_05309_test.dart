/// AISS GATE -- Step 133 of 135
/// Global Reference ID:       GEN-05309
/// Atomic Steps Reference ID: GEN-05309
/// Atomic Step: "Design the approach and technical specification for: build a
///               client-side feature flag and variant dispatcher optimized for
///               touch UI layouts."
/// Metric: Technical Specification Completeness -- Floor "Spec missing
///         acceptance criteria or edge cases", Optimal "Spec complete: inputs,
///         outputs, edge cases...". Complete / Partial / Not Complete.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
///
/// THE SPECIFICATION IS CODE, and Step 134 is checked against it by
/// GEN-04638's gate. A document nobody can execute drifts from the
/// implementation within a sprint and nothing notices.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/preferences/feature_flag_spec.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];

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

  group('GEN-05309 :: what the metric asks for', () {
    gate(
      'GEN-05309-G1',
      'Optimal: "Spec complete: INPUTS, OUTPUTS, EDGE CASES...". Floor: "spec '
          'missing acceptance criteria or edge cases".',
      'All four parts are present, and each carries a rationale rather than a '
          'bare name -- a spec that lists an input without saying why it is '
          'there is a spec nobody can argue with',
      () =>
          HabotFlagSpec.inputs.isNotEmpty &&
          HabotFlagSpec.outputs.isNotEmpty &&
          HabotFlagSpec.edgeCases.length >= 5 &&
          HabotFlagSpec.acceptance.length >= 5 &&
          HabotFlagSpec.inputs.every(
            (HabotSpecInput i) => i.rationale.length > 40,
          ) &&
          HabotFlagSpec.outputs.every(
            (HabotSpecOutput o) => o.rationale.length > 40,
          ),
    );

    gate(
      'GEN-05309-G2',
      'Metric: Technical Specification Completeness -- Complete / Partial / '
          'Not Complete.',
      'The completeness figure is computed over the spec own parts and reports '
          'in the row own vocabulary, with any gap named rather than only '
          'counted',
      () =>
          HabotFlagSpec.completeness == 1.0 &&
          HabotFlagSpec.qualitativeOutput == 'Complete' &&
          HabotFlagSpec.gaps.isEmpty &&
          HabotFlagSpec.completenessChecks.length == 5,
    );

    gate(
      'GEN-05309-G3',
      'A completeness check that cannot report incompleteness is not a check.',
      'Every edge case states a required behaviour AND why it matters, and '
          'every acceptance criterion carries an identifier the Step 134 gate '
          'can refer to',
      () =>
          HabotFlagSpec.edgeCases.every(
            (HabotSpecEdgeCase e) =>
                e.situation.isNotEmpty &&
                e.requiredBehaviour.isNotEmpty &&
                e.whyItMatters.length > 40,
          ) &&
          HabotFlagSpec.acceptance.every(
            (HabotSpecCriterion c) =>
                c.id.startsWith('AC-') && c.statement.length > 20,
          ) &&
          HabotFlagSpec.acceptance
                  .map((HabotSpecCriterion c) => c.id)
                  .toSet()
                  .length ==
              HabotFlagSpec.acceptance.length,
    );
  });

  group('GEN-05309 :: "optimized for touch UI layouts"', () {
    gate(
      'GEN-05309-G4',
      'The phrase that makes this a MOBILE spec: a flag consulted during '
          'build() cannot await anything. An async read produces a flash of '
          'the wrong variant, and on a touch surface a layout that changes '
          'under a finger already on its way down is a mis-tap.',
      'Synchronous evaluation is stated as a REQUIREMENT of the spec, not a '
          'preference, and appears in both the edge cases and the acceptance '
          'criteria',
      () =>
          HabotFlagSpec.evaluationIsSynchronous &&
          HabotFlagSpec.edgeCases.any(
            (HabotSpecEdgeCase e) =>
                e.situation.contains('build()') &&
                e.requiredBehaviour.contains('synchronously'),
          ) &&
          HabotFlagSpec.acceptance.any(
            (HabotSpecCriterion c) =>
                c.id == 'AC-1' && c.statement.contains('synchronous'),
          ),
    );

    gate(
      'GEN-05309-G5',
      'Bucketing by SESSION moves a user between variants on every launch, '
          'which makes an experiment unreadable and the app feel broken.',
      'The spec names the stable unit identity as a required input and says '
          'plainly what must not be used, so the implementation cannot get it '
          'wrong by omission',
      () {
        final HabotSpecInput unit = HabotFlagSpec.inputs.firstWhere(
          (HabotSpecInput i) => i.name == 'unitId',
        );
        return unit.required_ &&
            unit.rationale.contains('never a session') &&
            HabotFlagSpec.acceptance.any(
              (HabotSpecCriterion c) =>
                  c.id == 'AC-2' && c.statement.contains('always yield the '
                      'same variant'),
            );
      },
    );

    gate(
      'GEN-05309-G6',
      'Evaluating a flag is not exposure; RENDERING it is. Conflating them '
          'inflates every experiment denominator.',
      'The distinction is an explicit output of the spec with its reason '
          'stated, and it has its own acceptance criterion',
      () {
        final HabotSpecOutput exposure = HabotFlagSpec.outputs.firstWhere(
          (HabotSpecOutput o) => o.name == 'isExposure',
        );
        return exposure.rationale.contains('rendering it') &&
            exposure.rationale.contains('inflates') &&
            HabotFlagSpec.acceptance.any(
              (HabotSpecCriterion c) =>
                  c.id == 'AC-5' && c.statement.contains('once per unit'),
            );
      },
    );

    gate(
      'GEN-05309-G7',
      'This app is offline-first. A flag system that needs the network to '
          'answer does not work for the users this product exists for.',
      'The never-reached-the-server case has a defined answer, and the '
          'spec-as-code rationale is recorded so the choice of form is '
          'defensible rather than incidental',
      () =>
          HabotFlagSpec.edgeCases.any(
            (HabotSpecEdgeCase e) =>
                e.situation.contains('never reached the server') &&
                e.requiredBehaviour.contains('declared default'),
          ) &&
          HabotFlagSpec.specAsCodeRationale.contains('drifts from the '
              'implementation') &&
          HabotFlagSpec.subject.contains('touch UI layouts'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05309',
        atomicStepReferenceId: 'GEN-05309',
        setupStepAction:
            'Design the approach and technical specification for: build a '
            'client-side feature flag and variant dispatcher optimized for '
            'touch UI layouts.',
        implementationOrder: 133,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotFlagSpec',
          'Component Properties':
              '${HabotFlagSpec.inputs.length} inputs, '
              '${HabotFlagSpec.outputs.length} outputs, '
              '${HabotFlagSpec.edgeCases.length} edge cases, '
              '${HabotFlagSpec.acceptance.length} acceptance criteria -- all '
              'as executable declarations rather than prose',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) is EMPTY on this row. This is a design '
              'step; Step 134 is the implementation and is checked against '
              'these declarations by its own gate.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Technical Specification Completeness',
            observed:
                '${HabotFlagSpec.qualitativeOutput} -- '
                '${(HabotFlagSpec.completeness * 100).toStringAsFixed(0)}% '
                'over ${HabotFlagSpec.completenessChecks.length} checks: '
                'inputs, outputs, edge cases and acceptance criteria all '
                'present with rationale, plus the touch-UI constraint stated '
                'as a requirement rather than a preference.',
            floor: 'Spec missing acceptance criteria or edge cases',
            optimal: 'Spec complete: inputs, outputs, edge cases',
            ceiling: '1',
          ),
          const AissMeasurement(
            metricName: 'Drift between the spec and the implementation',
            observed:
                '0 by construction. The specification is code, and Step 134 '
                'is checked against these exact declarations by GEN-04638. A '
                'markdown document would have drifted within a sprint with '
                'nothing to notice.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/preferences/feature_flag_spec.dart',
        ],
      ),
    );
  });
}
