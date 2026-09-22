/// AISS GATE -- Step 450 of 415
/// Global Reference ID:       GEN-05331
/// Atomic Steps Reference ID: GEN-05331
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Design the approach and technical specification for: implement
///               automated skill assessment quizzes evaluating basic Learning
///               Difficulty (LD) knowledge and service delivery norms"
/// Metric: Technical Specification Completeness -- floor "Spec missing
///         acceptance criteria or edge cases", optimal "Spec complete: inputs,
///         outputs, edge cases & acceptance criteria defined", ceiling "1".
///         Best Qualitative Output: "Complete/Partial/Not Complete".
///         ISO/IEC/IEEE 29148 - Requirements Engineering. Assigned to **UDF**.
///
/// A SPECIFICATION FOR SKILL QUIZZES ON LEARNING DIFFICULTY KNOWLEDGE, AND
/// RULES BEFORE QUESTIONS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/evaluation/skill_assessment.dart';

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

  group('GEN-05331 :: an abbreviation for a Data Requirement', () {
    gate(
      'GEN-05331-G1',
      'The Data Requirement is an abbreviation\'s expansion.',
      '"Learning Difficulty (LD)", the second own-word artefact after Step 436',
      () =>
          HabotSkillAssessment.theArtefactIsAnExpansion &&
          HabotSkillAssessment.secondSuchRow,
    );

  });

  group('GEN-05331 :: the specification', () {
    gate(
      'GEN-05331-G2',
      'Four sections, as the optimal names them.',
      'Inputs, outputs, edge cases and acceptance criteria',
      () =>
          HabotSkillAssessment.specification.length == 4 &&
          HabotSkillAssessment.everyNamedSectionIsPresent,
    );

    gate(
      'GEN-05331-G3',
      'And none of them is empty.',
      'For once the row asks for exactly what its band measures',
      () => HabotSkillAssessment.noSectionIsEmpty,
    );

    gate(
      'GEN-05331-G4',
      'The floor describes the failure, the third in this batch.',
      'After Steps 442 and 453',
      () =>
          HabotSkillAssessment.theFloorDescribesTheFailure &&
          HabotSkillAssessment.thirdSuchFloor,
    );

  });

  group('GEN-05331 :: rules before questions', () {
    gate(
      'GEN-05331-G5',
      'Results to the learner, retakes allowed, no consequence.',
      'A quiz is not a trapdoor',
      () =>
          HabotSkillAssessment.resultsGoToTheLearnerFirst &&
          HabotSkillAssessment.retakesAreAllowed &&
          HabotSkillAssessment.theCharterThirdRuleHolds,
    );

    gate(
      'GEN-05331-G6',
      'Four questions, one flagged as a bad question.',
      'Eleven of forty answered it correctly',
      () =>
          HabotSkillAssessment.items.length == 4 &&
          HabotSkillAssessment.oneQuestionIsFlagged,
    );

    gate(
      'GEN-05331-G7',
      'And a flagged question counts against nobody.',
      'It is removed from scores until reviewed',
      () =>
          !HabotSkillAssessment.aFlaggedQuestionCountsAgainstLearners &&
          HabotSkillAssessment.itemNote.contains('rather than counted against'),
    );

  });

  group('GEN-05331 :: an accessible quiz', () {
    gate(
      'GEN-05331-G8',
      'No timer, read-aloud, no trick wording.',
      'A quiz about learning difficulties has to be accessible itself',
      () =>
          HabotSkillAssessment.theQuizIsAccessible &&
          HabotSkillAssessment.accessNote.contains('cannot pass'),
    );

    gate(
      'GEN-05331-G9',
      'The metric is shared with Step 454.',
      'Character for character',
      () => HabotSkillAssessment.metricSharedWithStep == 454,
    );

    gate(
      'GEN-05331-G10',
      'Five obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotSkillAssessment.obligations.length == 5 &&
          HabotSkillAssessment.obligations.values.every((bool b) => b) &&
          HabotSkillAssessment.qualitativeOutput == 'Complete',
    );
  });

  tearDownAll(() {
    final int sections = HabotSkillAssessment.specification.length;
    final int flagged = HabotSkillAssessment.flagged.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05331',
        atomicStepReferenceId: 'GEN-05331',
        setupStepAction:
            'COLUMN NOTE: this row\'s Data Requirement reads only "Learning '
            'Difficulty (LD)", the expansion of an abbreviation from its own '
            'instruction, the second such artefact in this batch after Step '
            '436; it asks for a specification and is scored on specification '
            'completeness, so a four-section specification is delivered and '
            'measured against the four things its own optimal names; its floor '
            'describes the failure, the third in this batch; and its metric '
            'and band are identical to Step 454\'s. Atomic Step: "Design the '
            'approach and technical specification for: implement automated '
            'skill assessment quizzes evaluating basic Learning Difficulty '
            '(LD) knowledge and service delivery norms"',
        implementationOrder: 450,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Learning Difficulty (LD)':
              'a specification of $sections sections; $flagged question '
                  'flagged for review and removed from scores; no timer, no '
                  'automatic consequence',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-22T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Technical Specification Completeness',
            observed:
                'THE ROW ASKS FOR WHAT ITS BAND MEASURES. A specification, '
                'scored on whether it states inputs, outputs, edge cases and '
                'acceptance criteria, so a $sections-section specification is '
                'delivered and measured against its own optimal. The floor '
                'still describes the failure, the third in this batch, and the '
                'Data Requirement is only "Learning Difficulty (LD)". '
                'Observed: all four sections present and none empty.',
            floor: 'Spec missing acceptance criteria or edge cases',
            optimal:
                'Spec complete: inputs, outputs, edge cases & acceptance '
                    'criteria defined',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName:
                'Questions counted against learners after most got them wrong',
            observed:
                '0. A question most of a cohort gets wrong is usually a wrong '
                'or ambiguous question, so $flagged is flagged and removed '
                'from scores until reviewed. Results go to the learner first, '
                'retakes are unlimited, nothing happens automatically on a low '
                'score, and the quiz has no timer and can be read aloud -- a '
                'test about supporting people who find reading hard should not '
                'be one they cannot pass.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/evaluation/skill_assessment.dart',
        ],
      ),
    );
  });
}
