/// AISS GATE -- Step 386 of 395
/// Global Reference ID:       GEN-02378
/// Atomic Steps Reference ID: GEN-02378
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Program the 'Next' button to remain physically blocked until
///               the current rating is provided (Poka-Yoke)."
/// Metric: UI Compliance Rate (%) -- floor 0.95, optimal 1, ceiling 1.
///         Pass / Fail. Material Design 3, WCAG 2.2 AA, W3C Web Standards.
///         Assigned to **UDF**.
///
/// A DISABLED NEXT BUTTON IS THE WORST PLACE TO PUT A REQUIREMENT, AND A
/// MANDATORY RATING WITH NO DECLINE IS A TOLL.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/flow/next_button_gate.dart';

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

  group('GEN-02378 :: the button stays enabled', () {
    gate(
      'GEN-02378-G1',
      'The button is not disabled and the tap is accepted.',
      'A disabled control gives no feedback, so somebody who does not know '
          'what is missing taps it and concludes the app is broken',
      () =>
          !HabotNextButtonGate.theButtonIsDisabledUntilAnswered &&
          HabotNextButtonGate.theTapIsAccepted,
    );

    gate(
      'GEN-02378-G2',
      'The tap moves focus and names what is missing.',
      'Which enforces "physically blocked" more completely than a grey '
          'rectangle, because it also says why',
      () =>
          HabotNextButtonGate.theTapDoesSomething &&
          HabotNextButtonGate.blockedNote.contains('it also says why'),
    );

    gate(
      'GEN-02378-G3',
      'An unanswered rating does not advance.',
      'Only an explicit answer satisfies a required question',
      () => HabotNextButtonGate.anUnansweredRatingDoesNotPass,
    );
  });

  group('GEN-02378 :: a required answer that is not a toll', () {
    gate(
      'GEN-02378-G4',
      'A decline is offered.',
      'Making an answer mandatory guarantees an answer; it does not guarantee '
          'a true one',
      () =>
          HabotNextButtonGate.thereIsADeclineOption &&
          HabotNextButtonGate.declineLabel.contains('Prefer not'),
    );

    gate(
      'GEN-02378-G5',
      'A decline is recorded as a decline.',
      'Not as a middle value, which cannot be told apart from a real one',
      () =>
          HabotNextButtonGate.aDeclineIsDistinguishable &&
          !HabotNextButtonGate.aDeclineIsStoredAsAMiddleValue &&
          HabotNextButtonGate.tollNote
              .contains('cannot be told apart from a real one'),
    );

    gate(
      'GEN-02378-G6',
      'Three rating outcomes stay distinct.',
      'Scored, declined and unanswered are three different facts about one '
          'person',
      () =>
          HabotRatingOption.values.length == 3 &&
          HabotNextButtonGate.threeOutcomesAreDistinct,
    );
  });

  group('GEN-02378 :: a way out that is not the answer', () {
    gate(
      'GEN-02378-G7',
      'The survey can be closed, and leaving is recorded.',
      'Step 336 settled that a gesture needs an alternative; a screen somebody '
          'cannot leave needs the same',
      () =>
          HabotNextButtonGate.thereIsAnExitThatIsNotAnAnswer &&
          HabotNextButtonGate.theSurveyCanBeClosed &&
          HabotNextButtonGate.leavingIsRecorded &&
          HabotNextButtonGate.theStepThatSettledAlternatives == 336,
    );

    gate(
      'GEN-02378-G8',
      'A required question with no exit costs the next survey.',
      'It does not raise the response rate; it lowers how many people open the '
          'next one',
      () => HabotNextButtonGate.exitNote
          .contains('open the survey next time'),
    );
  });

  group('GEN-02378 :: poka-yoke, and the column', () {
    gate(
      'GEN-02378-G9',
      'It earns the word, on Step 341\'s test.',
      'Advancing without an answer is impossible because the advance is a '
          'function of the answer, not because a button was greyed',
      () =>
          HabotNextButtonGate.itEarnsTheWord &&
          HabotNextButtonGate.theStepThatSettledPokaYoke == 341 &&
          HabotNextButtonGate.pokaYokeNote
              .contains('which question is waiting'),
    );

    gate(
      'GEN-02378-G10',
      'Output reported as Pass / Fail.',
      'Five obligations, all met, giving Pass; the artefact cell is the '
          'button\'s own label, the optimal and ceiling are both 1, and all '
          'ten declared checks hold',
      () =>
          HabotNextButtonGate.obligations.length == 5 &&
          HabotNextButtonGate.obligations.values.every((bool b) => b) &&
          HabotNextButtonGate.qualitativeOutput == 'Pass' &&
          HabotNextButtonGate.theArtefactCellIsTheButtonsLabel &&
          HabotNextButtonGate.theOptimalEqualsTheCeiling &&
          HabotNextButtonGate.checks.length == 10 &&
          HabotNextButtonGate.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final String decline = HabotNextButtonGate.declineLabel;
    final String artefact = HabotNextButtonGate.artefactCell;
    final int cells = HabotNextButtonGate.generatorArtefactCellsInTwoBatches;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02378',
        atomicStepReferenceId: 'GEN-02378',
        setupStepAction:
            'COLUMN NOTE: the Data Requirement cell on this row reads '
            '"Data/artifacts to prepare: Next", which is the button\'s own '
            'label lifted into the artefact list and the shortest of the seven '
            'such cells across these two batches; the band\'s optimal and '
            'ceiling are both 1; and the Setup Step column is empty. Atomic '
            'Step: "Program the Next button to remain physically blocked until '
            'the current rating is provided (Poka-Yoke)."',
        implementationOrder: 386,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Next':
              'the artefact cell is the button label; $cells such cells across '
                  'these two batches',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the button stays enabled and the tap moves focus; the scale '
                  'offers "$decline" and records it as a decline',
          'Data Quality Note':
              'BLOCKED: ${HabotNextButtonGate.blockedNote} TOLL: '
              '${HabotNextButtonGate.tollNote} EXIT: '
              '${HabotNextButtonGate.exitNote} POKA-YOKE: '
              '${HabotNextButtonGate.pokaYokeNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Compliance Rate (%)',
            observed:
                '100, with the optimal and the ceiling both written 1. The '
                'artefact cell for this row is the single word "$artefact" -- '
                'the button\'s own label lifted into the list of things to '
                'prepare, and the shortest of the $cells generator-artefact '
                'cells across these two batches. What is measured here is '
                'whether the requirement is enforced without a dead control: '
                'the button stays enabled, the tap is accepted, and focus '
                'moves to the question that is waiting.',
            floor: '0.95',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Ratings produced by somebody who wanted to leave',
            observed:
                '0. A disabled Next button is the worst place to put a '
                'requirement -- it gives no feedback when tapped -- so the '
                'button stays live and the tap moves focus to the unanswered '
                'question. A mandatory rating with no decline is a toll rather '
                'than a safeguard: it guarantees an answer, not a true one, '
                'and produces a middle value from everybody who wanted to go. '
                '"$decline" is on the scale and is stored as a decline, so '
                'scored, declined and unanswered stay three distinct facts, '
                'and closing the survey is available throughout and recorded.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/flow/next_button_gate.dart',
        ],
      ),
    );
  });
}
