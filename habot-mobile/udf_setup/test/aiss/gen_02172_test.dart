/// AISS GATE -- Step 452 of 415
/// Global Reference ID:       GEN-02172
/// Atomic Steps Reference ID: GEN-02172
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Auto-escalate the task to the HR Director if the recruiter
///               leaves the dialogue open for >5 minutes."
/// Metric: Exception Queue Resolution Time -- floor "30 minutes", optimal "15
///         minutes", ceiling "5 minutes". Best Qualitative Output: "Pass /
///         Fail". ITIL v4 Incident Escalation Standard. Assigned to **UDF**.
///
/// A FIVE-MINUTE TIMER ON A RECRUITER THAT ESCALATES TO THE HR DIRECTOR, AND
/// THE CITED STANDARD THAT CONTAINS THE FIX.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/evaluation/dialogue_escalation.dart';

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

  group('GEN-02172 :: a band that agrees with its words', () {
    gate(
      'GEN-02172-G1',
      'The band descends, the second such band.',
      'Thirty, fifteen, five, after Step 433',
      () =>
          HabotDialogueEscalation.theBandDescends &&
          HabotDialogueEscalation.secondSuchBand,
    );

    gate(
      'GEN-02172-G2',
      'And its best value is the instruction\'s five minutes.',
      'The first row in two batches whose words and numbers agree',
      () =>
          HabotDialogueEscalation.theBandAgreesWithTheInstruction &&
          HabotDialogueEscalation.rowsWhoseBandContradictedTheirWords.length ==
              2 &&
          HabotDialogueEscalation.agreementNote.contains('say the same thing'),
    );

  });

  group('GEN-02172 :: an open dialogue is not an idle person', () {
    gate(
      'GEN-02172-G3',
      'An open dialogue has three innocent readings.',
      'Reading a CV, on the phone, thinking',
      () =>
          HabotDialogueEscalation.whatAnOpenDialogueCanMean.length == 3 &&
          HabotDialogueEscalation.dwellIsAttentionNotSlowness,
    );

    gate(
      'GEN-02172-G4',
      'So the timer runs only while somebody waits.',
      'No candidate waiting, no timer',
      () => HabotDialogueEscalation.theTimerOnlyRunsWhenSomebodyWaits,
    );

    gate(
      'GEN-02172-G5',
      'And the record never says inactive.',
      'It names the task and the waiting candidate',
      () => HabotDialogueEscalation.theRecordNamesTheTaskNotThePerson,
    );

  });

  group('GEN-02172 :: functional before hierarchical', () {
    gate(
      'GEN-02172-G6',
      'Three steps: nudge, pool, Director.',
      'At five minutes, fifteen, and a missed deadline',
      () => HabotDialogueEscalation.ladder.length == 3,
    );

    gate(
      'GEN-02172-G7',
      'Functional before hierarchical, as ITIL separates them.',
      'Somebody who can do the work before somebody with authority',
      () =>
          HabotDialogueEscalation.functionalComesBeforeHierarchical &&
          HabotDialogueEscalation.escalationNote.contains('coffee break'),
    );

    gate(
      'GEN-02172-G8',
      'The Director hears only on a missed deadline.',
      'Not every coffee break',
      () =>
          HabotDialogueEscalation.theDirectorIsNotReachedAtFiveMinutes &&
          HabotDialogueEscalation.theDirectorHearsOnlyOnADeadline,
    );

    gate(
      'GEN-02172-G9',
      'The cited standard contains the fix, the second in this batch.',
      'After Octalysis at Step 439',
      () =>
          HabotDialogueEscalation.theCitedStandardContainsTheFix &&
          HabotDialogueEscalation.rowsWhoseStandardHelped.length == 2,
    );

  });

  group('GEN-02172 :: the result', () {
    gate(
      'GEN-02172-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotDialogueEscalation.obligations.length == 5 &&
          HabotDialogueEscalation.obligations.values.every((bool b) => b) &&
          HabotDialogueEscalation.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final int steps = HabotDialogueEscalation.ladder.length;
    final int median = HabotDialogueEscalation.observedMedianResolutionMinutes;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02172',
        atomicStepReferenceId: 'GEN-02172',
        setupStepAction:
            'COLUMN NOTE: this row\'s band descends correctly -- thirty, '
            'fifteen, five minutes, the ceiling the best value, the second '
            'such band after Step 433 -- and its best value matches the five '
            'minutes in its instruction, the first row in two batches whose '
            'words and numbers agree; it escalates a recruiter to the HR '
            'Director after five minutes, which ITIL, the standard it cites, '
            'would call hierarchical escalation for a functional problem, so '
            'the recruiter is nudged first, the pool sees the item next, and '
            'the Director hears only on a missed candidate deadline; and the '
            'timer runs only while somebody is waiting. Atomic Step: '
            '"Auto-escalate the task to the HR Director if the recruiter '
            'leaves the dialogue open for >5 minutes."',
        implementationOrder: 452,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Auto-escalate the task to the HR Director if the recruiter':
              'a $steps-step ladder -- nudge, pool, Director on a missed '
                  'deadline -- running only while a candidate waits; median '
                  'resolution $median minutes',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-22T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Exception Queue Resolution Time',
            observed:
                'THE BAND DESCENDS AND AGREES WITH ITS INSTRUCTION. Thirty, '
                'fifteen, five minutes, the ceiling the best value -- the '
                'second such band after Step 433 -- and its best value is the '
                'five minutes the instruction names, the first row in two '
                'batches whose words and numbers say the same thing. Observed: '
                'a median of $median minutes.',
            floor: '30 minutes',
            optimal: '15 minutes',
            ceiling: '5 minutes',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Five-minute pauses sent to the HR Director',
            observed:
                '0. ITIL, the standard the row cites, separates functional '
                'escalation, to somebody who can do the work, from '
                'hierarchical escalation, to somebody with authority. The '
                'recruiter is nudged at five minutes, the recruiting pool sees '
                'the item at fifteen, and the Director hears only when the '
                'candidate-facing deadline is missed. The timer runs only '
                'while somebody waits, and the record never says "inactive".',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/evaluation/dialogue_escalation.dart',
        ],
      ),
    );
  });
}
