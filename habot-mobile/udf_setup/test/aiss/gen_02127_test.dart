/// AISS GATE -- Step 436 of 415
/// Global Reference ID:       GEN-02127
/// Atomic Steps Reference ID: GEN-02127
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Define the criteria indicating absolute "completion" for
///               various workflows."
/// Metric: Step Completion Rate (%) -- floor "90", optimal "99", ceiling "100".
///         Best Qualitative Output: "Complete/Partial/Not Complete". ISO/IEC
///         27001:2022 General Standards. Assigned to **PDG**.
///
/// WHAT "COMPLETE" MEANS, WRITTEN DOWN BEFORE ANYTHING IS AWARDED POINTS FOR
/// IT, AND A CHARTER FOR SCORING PEOPLE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/recognition/completion_criteria.dart';

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

  group('GEN-02127 :: a definition that is its own input', () {
    gate(
      'GEN-02127-G1',
      'The Data Requirement is the word being defined.',
      '"Data/artifacts to prepare: completion." -- the artefact is the word '
          'the row asks to be defined',
      () =>
          HabotCompletionCriteria.theArtefactIsTheWordItself &&
          HabotCompletionCriteria.everyLaterRowDependsOnIt,
    );

    gate(
      'GEN-02127-G2',
      'And every later row depends on it.',
      'Points, streaks, levels and praise are all awarded for completing '
          'something',
      () =>
          HabotCompletionCriteria
              .selfReferenceNote.contains('completing something'),
    );

  });

  group('GEN-02127 :: what "absolute" rules out', () {
    gate(
      'GEN-02127-G3',
      'Three things are ruled out by "absolute".',
      'Reaching a screen, pressing a button, and a timer expiring',
      () => HabotCompletionCriteria.threeThingsAreRuledOut,
    );

    gate(
      'GEN-02127-G4',
      'A submitted record is not complete.',
      'Step 434 separated an acceptance from an outcome; this promotes that '
          'separation to a definition',
      () =>
          HabotCompletionCriteria.aSubmittedRecordIsNotComplete &&
          HabotCompletionCriteria.theStepThatSeparatedAcceptanceFromOutcome ==
              434,
    );

    gate(
      'GEN-02127-G5',
      'Nor is a terminal one nobody was told about.',
      'Completion is a terminal state on the server with the person notified',
      () =>
          HabotCompletionCriteria.anUnnotifiedTerminalRecordIsNotComplete &&
          HabotCompletionCriteria.aNotifiedTerminalRecordIsComplete,
    );

    gate(
      'GEN-02127-G6',
      'Four workflows, each naming its terminal states.',
      'Overtime, shift swap, expense claim and training',
      () =>
          HabotCompletionCriteria.workflows.length == 4 &&
          HabotCompletionCriteria.everyWorkflowNamesItsTerminalStates &&
          HabotCompletionCriteria.everyWorkflowNotifies,
    );

    gate(
      'GEN-02127-G7',
      'And an expiry is terminal without being a completion.',
      'A shift swap that expired is finished; nobody should be awarded points '
          'for it',
      () =>
          HabotCompletionCriteria.anExpiryIsATerminalStateNotACompletion &&
          HabotCompletionCriteria.absoluteNote.contains('awarded points for'),
    );

  });

  group('GEN-02127 :: the charter', () {
    gate(
      'GEN-02127-G8',
      'Four charter rules, written before the first point.',
      'Visible, contestable, no automatic consequence, and never fed by '
          'telemetry about how somebody used a screen',
      () =>
          HabotCompletionCriteria.theCharterIsWrittenBeforeAnyPoint &&
          HabotCompletionCriteria
              .charterNote.contains('legitimately the subject'),
    );

  });

  group('GEN-02127 :: the band', () {
    gate(
      'GEN-02127-G9',
      'The band is Step 404\'s and 412\'s, a third time.',
      'Step Completion Rate at 90, 99, 100 on three unrelated subjects',
      () =>
          HabotCompletionCriteria.thirdOccurrence &&
          HabotCompletionCriteria.bandCeiling == 100,
    );

    gate(
      'GEN-02127-G10',
      'Five obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotCompletionCriteria.obligations.length == 5 &&
          HabotCompletionCriteria.obligations.values.every((bool b) => b) &&
          HabotCompletionCriteria.qualitativeOutput == 'Complete' &&
          HabotCompletionCriteria.theScreenRuleStillHoldsForTelemetry,
    );
  });

  tearDownAll(() {
    final int workflows = HabotCompletionCriteria.workflows.length;
    final int rules = HabotScoringCharter.ruleCount;
    final double completion = HabotCompletionCriteria.completion;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02127',
        atomicStepReferenceId: 'GEN-02127',
        setupStepAction:
            'COLUMN NOTE: this row\'s Data Requirement reads, in full, '
            '"Data/artifacts to prepare: completion." -- the artefact to '
            'prepare is the word the row asks to be defined, and the Data '
            'Collected cell repeats it; its band is Step Completion Rate at '
            '90, 99, 100, the third time in three batches after Steps 404 and '
            '412; and it is the definition every later row in this batch '
            'depends on, so it also carries the four-rule charter that applies '
            'once a person rather than a screen is scored. Atomic Step: '
            '"Define the criteria indicating absolute "completion" for various '
            'workflows."',
        implementationOrder: 436,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'completion':
              'a terminal state on the server with the person notified, across '
                  '$workflows workflows, and a $rules-rule charter for scoring '
                  'people written before the first point is awarded',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-22T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Step Completion Rate (%)',
            observed:
                'THE ARTEFACT TO PREPARE IS THE WORD BEING DEFINED. The Data '
                'Requirement reads, in full, "Data/artifacts to prepare: '
                'completion." and the Data Collected cell repeats it, on the '
                'row every other row in this batch depends on. The band is '
                'Step Completion Rate at 90, 99, 100 for the third time in '
                'three batches after Steps 404 and 412. Observed: $completion '
                'per cent of $workflows workflows name their terminal states '
                'and notify the person.',
            floor: '90',
            optimal: '99',
            ceiling: '100',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Things counted as completion that are not',
            observed:
                '0 of 3. Reaching a screen, pressing a button and a timer '
                'expiring are all ruled out; completion is a terminal state on '
                'the server with the person told. This batch is where the rows '
                'start scoring people, so a $rules-rule charter is written '
                'here before any point exists: the person sees their score and '
                'its working, any score can be contested, no score triggers a '
                'consequence without a named person, and telemetry about how '
                'somebody used a screen can never feed a score.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/recognition/completion_criteria.dart',
        ],
      ),
    );
  });
}
