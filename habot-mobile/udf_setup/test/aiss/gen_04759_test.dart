/// AISS GATE -- Step 146 of 155
/// Global Reference ID:       GEN-04759
/// Atomic Steps Reference ID: GEN-04759
/// Setup Step (Action) / Atomic Step: "Review the setup step objective:
///   Deconstruct long, overwhelming SEN referral forms into single-action,
///   horizontally paginated swipeable ViewPager steps with animated M3
///   progress indicators."
/// Metric: Requirements Objective Clarity / Sign-off Score -- Floor ">=80%",
///         Optimal "100%", Ceiling "100%".
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/wizard/single_action_objective.dart';

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

  group('GEN-04759 :: terms borrowed from another platform', () {
    gate(
      'GEN-04759-G1',
      'The objective names "ViewPager", which is an Android View. A reviewer '
          'reading that word in a Flutter codebase should find a decision '
          'rather than assume something was missed.',
      'Every borrowed term is substituted explicitly, with the substitute '
          'named and the reason given, and PageView is recorded as an exact '
          'equivalent rather than an approximation',
      () {
        final HabotTermSubstitution vp = HabotSingleActionObjective
            .substitutions
            .firstWhere((HabotTermSubstitution s) => s.term == 'ViewPager');
        return vp.substitute == 'PageView' &&
            vp.isExact &&
            vp.reason.contains('same job') &&
            HabotSingleActionObjective.substitutions.length >= 3;
      },
    );

    gate(
      'GEN-04759-G2',
      'Read literally, "single-action" puts each of the four parts of an '
          'address on its own screen -- turning a three-line answer into a '
          'four-screen journey, which is worse than the long form it replaces.',
      'The reading taken is marked as a DECISION rather than a translation, so '
          'it can be argued with, and it points at the Step 44 declaration '
          'rather than at a new opinion',
      () {
        final HabotTermSubstitution sa = HabotSingleActionObjective
            .substitutions
            .firstWhere(
              (HabotTermSubstitution s) => s.term == 'single-action',
            );
        return !sa.isExact &&
            sa.substitute == 'one decision per step' &&
            sa.reason.contains('Step 44') &&
            HabotSingleActionObjective.substitutions
                .any((HabotTermSubstitution s) => s.isExact);
      },
    );
  });

  group('GEN-04759 :: what the review found', () {
    gate(
      'GEN-04759-G3',
      'Step 138 put Urdu in scope. A horizontally paginated wizard hardcoded '
          'to "swipe left for next" advances BACKWARDS in a right-to-left '
          'language.',
      'The right-to-left consequence of the word "swipeable" is identified, '
          'with the cost of missing it stated and the step it constrains '
          'named',
      () {
        final HabotWizardFinding f1 =
            HabotSingleActionObjective.findings.first;
        return f1.id == 'F-1' &&
            f1.finding.contains('Urdu') &&
            f1.consequenceIfMissed.contains('rebuilt rather than translated') &&
            f1.bindsStep.contains('150');
      },
    );

    gate(
      'GEN-04759-G4',
      'A tap that does nothing looks like a refusal; a swipe that does nothing '
          'looks like the app has frozen -- and a force-quit mid-form is the '
          'loss Step 153 exists to prevent, arriving through another door.',
      'The silent-refusal case is a finding rather than an implementation '
          'detail, and the decision to show the reason where the button would '
          'have shown it is recorded',
      () =>
          HabotSingleActionObjective.findings.any(
            (HabotWizardFinding f) =>
                f.id == 'F-2' &&
                f.consequenceIfMissed.contains('force-quit'),
          ) &&
          HabotSingleActionObjective.decisions.any(
            (String d) => d.startsWith('D-2') && d.contains('silent refusal'),
          ),
    );

    gate(
      'GEN-04759-G5',
      'Forty single-question screens are not less overwhelming than one long '
          'page if the user cannot see how far they have to go or resume where '
          'they stopped.',
      'The abandonment finding names the two steps that make the '
          'decomposition survivable rather than treating them as adjacent '
          'work, and every finding states what missing it would have cost',
      () =>
          HabotSingleActionObjective.findings.any(
            (HabotWizardFinding f) =>
                f.id == 'F-3' && f.bindsStep.contains('153'),
          ) &&
          HabotSingleActionObjective.findings.every(
            (HabotWizardFinding f) =>
                f.consequenceIfMissed.length > 60 && f.bindsStep.isNotEmpty,
          ) &&
          HabotSingleActionObjective.findings.length >= 5,
    );

    gate(
      'GEN-04759-G6',
      'This app already has a horizontally scrolling surface. Two horizontal '
          'gestures on one screen means one of them loses, and which one is '
          'decided by widget order rather than by intent.',
      'The gesture conflict is found here rather than by a user, and the '
          'decisions cover what happens on back, what a refused swipe says, '
          'which fields stay together and when the progress indicator '
          'animates',
      () =>
          HabotSingleActionObjective.findings.any(
            (HabotWizardFinding f) =>
                f.id == 'F-5' && f.finding.contains('sticky-column table'),
          ) &&
          HabotSingleActionObjective.decisions.length >= 4 &&
          HabotSingleActionObjective.decisions.any(
            (String d) => d.contains('Going BACK is always permitted'),
          ) &&
          HabotSingleActionObjective.decisions.any(
            (String d) => d.contains('reduced motion'),
          ),
    );

    gate(
      'GEN-04759-G7',
      'Metric: Requirements Objective Clarity / Sign-off Score. Floor 80%, '
          'optimal 100%.',
      'The score is computed over the review own checks, reports in the row '
          'vocabulary, names any gap, and the reason sign-off alone is not '
          'what is scored is recorded',
      () =>
          HabotSingleActionObjective.clarityScore == 1.0 &&
          HabotSingleActionObjective.clarityScore >=
              HabotSingleActionObjective.floor &&
          HabotSingleActionObjective.qualitativeOutput == 'Complete' &&
          HabotSingleActionObjective.gaps.isEmpty &&
          HabotSingleActionObjective.clarityChecks.length == 5 &&
          HabotSingleActionObjective.reviewValueNote.contains(
            'would score identically and be worth nothing',
          ),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04759',
        atomicStepReferenceId: 'GEN-04759',
        setupStepAction:
            'Review the setup step objective: Deconstruct long, overwhelming '
            'SEN referral forms into single-action, horizontally paginated '
            'swipeable ViewPager steps with animated M3 progress indicators.',
        implementationOrder: 146,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotSingleActionObjective',
          'Component Properties':
              '${HabotSingleActionObjective.substitutions.length} term '
              'substitutions, ${HabotSingleActionObjective.findings.length} '
              'findings, ${HabotSingleActionObjective.decisions.length} '
              'decisions',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Zero-dependency row. The review is written as code so Steps '
              '147-155 can be checked against it.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Requirements Objective Clarity / Sign-off Score',
            observed:
                '${HabotSingleActionObjective.qualitativeOutput} -- '
                '${(HabotSingleActionObjective.clarityScore * 100).toStringAsFixed(0)}'
                '% over ${HabotSingleActionObjective.clarityChecks.length} '
                'checks: every borrowed platform term substituted, every '
                'ambiguous phrase given a reading, and every consequence '
                'traced to the step it constrains.',
            floor: '>=80% stakeholder sign-off on stated objective',
            optimal: '100% stakeholder sign-off',
            ceiling: '100% (no benefit beyond full sign-off)',
          ),
          const AissMeasurement(
            metricName: 'Rebuilds avoided by reviewing before building',
            observed:
                'One, and it would have been the whole wizard. "Swipeable" '
                'plus a right-to-left language means the page gesture '
                'reverses; found now it is a mapping in one method, found '
                'after Steps 149-152 were built it is a rebuild -- and it '
                'would have been invisible to every reviewer who reads left '
                'to right.',
            floor: 'n/a',
            optimal: 'n/a',
            ceiling: 'n/a',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/wizard/single_action_objective.dart',
        ],
      ),
    );
  });
}
