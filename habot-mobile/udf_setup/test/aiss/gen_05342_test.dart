/// AISS GATE -- Step 349 of 355
/// Global Reference ID:       GEN-05342
/// Atomic Steps Reference ID: GEN-05342
/// Setup Step (Action): (the generic engineering-console boilerplate --
///                      COLUMN NOTE, RECORDED)
/// Atomic Step: "Verify all completion criteria are met: Mobile onboarding
///               completion rate >= 70%; Average time to complete application
///               <= 15 min; Skill test grading latency <= 100ms"
/// Metric: Composite Completion-Criteria Achievement Rate -- floor "Any single
///         stated criterion unmet", optimal "100% of stated criteria met
///         exactly as specified", ceiling "N/A". Pass / Fail. Six Sigma DMAIC.
///
/// THIS STEP REPORTS **FAIL** -- AND NOTHING FAILED. TWO OF THE THREE CRITERIA
/// WERE NEVER OBSERVED, WHICH A PASS/FAIL OUTPUT CANNOT SAY.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/guidance/onboarding_criteria.dart';

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

  group('GEN-05342 :: the floor that names the failing state', () {
    gate(
      'GEN-05342-G1',
      'Floor: "Any single stated criterion unmet".',
      'A floor is the worst value still acceptable; this cell holds the '
          'condition under which the thing fails',
      () => HabotOnboardingCriteria.theFloorNamesTheFailingState,
    );

    gate(
      'GEN-05342-G2',
      'Ceiling: "N/A - full compliance has no diminishing-return ceiling".',
      'Which is the row admitting the measure is binary, in the cell where the '
          'best value belongs',
      () => HabotOnboardingCriteria.theCeilingIsNotAValue,
    );

    gate(
      'GEN-05342-G3',
      'Read the other way round the floor is correct and the band binary.',
      'Fifth misstated floor the track has recorded, after Steps 319, 329, 331 '
          'and 338',
      () =>
          HabotOnboardingCriteria.theBandIsBinaryOnceReadThatWay &&
          HabotOnboardingCriteria.unfailableOrMisstatedFloorsBefore == 4 &&
          HabotOnboardingCriteria.bandNote.contains('Steps 319, 329, 331'),
    );
  });

  group('GEN-05342 :: three incommensurable criteria', () {
    gate(
      'GEN-05342-G4',
      'Three criteria, each declaring its direction.',
      'A rate where higher is better, and two durations where lower is',
      () =>
          HabotCompletionCriterion.values.length == 3 &&
          HabotOnboardingCriteria.everyCriterionDeclaresItsDirection,
    );

    gate(
      'GEN-05342-G5',
      'Each states what kind of thing it measures.',
      'A population statistic, a duration with an undefined clock, and a '
          'machine round trip',
      () => HabotOnboardingCriteria.theThreeAreIncommensurable,
    );

    gate(
      'GEN-05342-G6',
      'No composite rate is published.',
      'Two of three met is not a meaningful 67 per cent when the two are a '
          'population statistic and a machine timing',
      () =>
          !HabotOnboardingCriteria.aCompositeRateIsPublished &&
          HabotOnboardingCriteria.rateNote.contains('do not share one'),
    );
  });

  group('GEN-05342 :: what could be observed', () {
    gate(
      'GEN-05342-G7',
      'One of the three is observable from this repository.',
      'Grading latency is a round trip that can be timed here; the other two '
          'need a cohort definition nobody has written down',
      () =>
          HabotOnboardingCriteria.oneOfThreeIsObservableHere &&
          HabotOnboardingCriteria.observabilityNote.contains('undefined'),
    );

    gate(
      'GEN-05342-G8',
      'Unobserved is distinguished from unmet.',
      'Two not observed, one observed and met, none observed and failing',
      () =>
          HabotOnboardingCriteria.theSplitIsTwoAndOneAndZero &&
          HabotOnboardingCriteria.observedAndUnmet.isEmpty,
    );
  });

  group('GEN-05342 :: the verdict', () {
    gate(
      'GEN-05342-G9',
      'The composite rule is an AND, applied honestly, and it does not pass.',
      'Not because anything fell short -- nothing observed did -- but because '
          'two of the three were never observed',
      () =>
          HabotOnboardingCriteria.theCompositeIsAnAnd &&
          HabotOnboardingCriteria.theFailureIsAbsenceNotShortfall &&
          HabotOnboardingCriteria.verdictNote.contains('why the gate is red'),
    );

    gate(
      'GEN-05342-G10',
      'Output reported as Pass / Fail: **Fail**.',
      'Five obligations, all met -- the obligations are about how the verifier '
          'behaves, and the Fail is about what the world has supplied; all ten '
          'declared checks hold',
      () =>
          HabotOnboardingCriteria.obligations.length == 5 &&
          HabotOnboardingCriteria.obligations.values.every((bool b) => b) &&
          HabotOnboardingCriteria.qualitativeOutput == 'Fail' &&
          HabotOnboardingCriteria.checks.length == 10 &&
          HabotOnboardingCriteria.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final int unobserved = HabotOnboardingCriteria.notObserved.length;
    final int met = HabotOnboardingCriteria.observedAndMet.length;
    final int short = HabotOnboardingCriteria.observedAndUnmet.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05342',
        atomicStepReferenceId: 'GEN-05342',
        setupStepAction:
            'COLUMN NOTE: the floor cell on this row reads "Any single stated '
            'criterion unmet", which is the failure condition written where '
            'the minimum acceptable value belongs; the ceiling cell holds the '
            'string "N/A - full compliance has no diminishing-return ceiling"; '
            'the metric asks for a composite rate over three incommensurable '
            'criteria; and every narrative column is the generic '
            'engineering-console boilerplate. Atomic Step: "Verify all '
            'completion criteria are met: Mobile onboarding completion rate '
            '>= 70%; Average time to complete application <= 15 min; Skill '
            'test grading latency <= 100ms"',
        implementationOrder: 349,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Verify all completion criteria are met: Mobile onboarding '
                  'completion rate':
              '$met of 3 criteria observed and met, $short observed and short, '
                  '$unobserved never observed',
          'Completion Status': 'Fail',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the verifier applies the composite rule as an AND and reports '
                  'the split rather than a composite rate, because three '
                  'criteria in per cent, minutes and milliseconds share no '
                  'denominator',
          'Data Quality Note':
              'OBSERVABILITY: ${HabotOnboardingCriteria.observabilityNote} '
              'VERDICT: ${HabotOnboardingCriteria.verdictNote} '
              'BAND: ${HabotOnboardingCriteria.bandNote} '
              'RATE: ${HabotOnboardingCriteria.rateNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Composite Completion-Criteria Achievement Rate',
            observed:
                'THE FLOOR CELL NAMES THE FAILING STATE. "Any single stated '
                'criterion unmet" is not a value; it is the condition under '
                'which the thing fails, written where the minimum acceptable '
                'reading belongs -- which says the minimum acceptable outcome '
                'is failure. Read as "below this you fail" it is correct and '
                'the band is binary, which is what the ceiling cell admits by '
                'holding "N/A" instead of a number. Fifth misstated floor the '
                'track has recorded, after Steps 319, 329, 331 and 338. The '
                'composite rate the metric names cannot exist: three criteria '
                'in per cent, minutes and milliseconds share no denominator.',
            floor: 'Any single stated criterion unmet',
            optimal: '100% of stated criteria met exactly as specified',
            ceiling: 'N/A - full compliance has no diminishing-return ceiling',
          ),
          AissMeasurement(
            metricName: 'Criteria observed, met, and short',
            observed:
                '$unobserved never observed, $met observed and met, $short '
                'observed and short. Applied as the AND it is, the composite '
                'does not pass -- and the reason is absence rather than '
                'shortfall, which the row\'s Pass/Fail output cannot express '
                'and which is the only thing worth saying when somebody asks '
                'why the gate is red. Grading latency can be timed here; a '
                'completion rate needs a cohort and a window, and an average '
                'application duration needs a decision about when the clock '
                'starts and whether abandonment counts. Neither definition '
                'exists anywhere in this sheet.',
            floor: '1',
            optimal: '3',
            ceiling: '3',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/guidance/onboarding_criteria.dart',
        ],
      ),
    );
  });
}
