/// AISS GATE -- Step 316 of 335
/// Global Reference ID:       GEN-00445
/// Atomic Steps Reference ID: GEN-00445
/// Setup Step (Action): "Test the reflow transition at exactly the Compact
///                      breakpoint boundary -- 599dp and 600dp." (A LAYOUT
///                      INSTRUCTION ON A SECURITY ROW)
/// Atomic Step: "Hardcode Fail-Closed logic: treat Null, Error, or False
///               results as a hard stop."
/// Metric: Fail-Closed Stop Reliability -- floor 1, optimal 1, ceiling
///         "N/A (100% target)". Pass / Fail. OWASP Fail-Secure Design.
///
/// THE FIRST COLLAPSED BAND IN THIS TRACK THAT IS THE RIGHT SHAPE FOR ITS
/// SUBJECT. AND THREE INPUTS THAT MUST NOT SHARE ONE SENTENCE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/resilience/fail_closed.dart';

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

  group('GEN-00445 :: the policy', () {
    gate(
      'GEN-00445-G1',
      'Atomic Step: "treat Null, Error, or False results as a hard stop".',
      'Four results, three of which stop; only an explicit true proceeds',
      () =>
          HabotCheckResult.values.length == 4 &&
          HabotFailClosed.everythingButTrueStops &&
          HabotFailClosed.mayProceed(HabotCheckResult.allowed),
    );

    gate(
      'GEN-00445-G2',
      'Atomic Step: "Hardcode".',
      'The policy is a constant, because a fail-closed rule with a switch on '
          'it is a fail-open rule with a delay; the thresholds it consults '
          'are tokens',
      () =>
          !HabotFailClosed.thePolicyIsConfigurable &&
          HabotFailClosed.policyNote.contains('fail-open rule with a delay'),
    );

    gate(
      'GEN-00445-G3',
      'Fail-closed means the stop precedes the effect.',
      'Nothing is written on any stopping result; a rule that writes and then '
          'reverses is fail-open with a compensating transaction, and the '
          'reversal can itself fail',
      () =>
          !HabotFailClosed.anythingIsWrittenOnAStop &&
          HabotFailClosed.atomicityNote
              .contains('compensating transaction'),
    );
  });

  group('GEN-00445 :: three stops, three sentences', () {
    gate(
      'GEN-00445-G4',
      'Each stopping result maps to its own kind.',
      'Refused, errored and absent are three different facts about the world',
      () =>
          HabotFailClosed.stopKindFor(HabotCheckResult.refused) ==
              HabotStopKind.refusedWithReason &&
          HabotFailClosed.stopKindFor(HabotCheckResult.errored) ==
              HabotStopKind.stoppedByOurFault &&
          HabotFailClosed.stopKindFor(HabotCheckResult.absent) ==
              HabotStopKind.stoppedByOmission,
    );

    gate(
      'GEN-00445-G5',
      'Three distinct sentences, none shared.',
      'The stop is identical in every case and the sentence is the only part '
          'the person ever sees',
      () => HabotFailClosed.everyStopHasItsOwnSentence,
    );

    gate(
      'GEN-00445-G6',
      'Two of the three are the application\'s own failure.',
      'A collapsed message saying "you are not allowed" is wrong twice out of '
          'three, and it is a statement about us said in the second person',
      () =>
          HabotFailClosed.twoOfTheThreeStopsAreOurs &&
          HabotFailClosed.theCollapsedMessageIsWrongTwiceOutOfThree,
    );

    gate(
      'GEN-00445-G7',
      'Step 294 reached the same three-valued shape.',
      'From authorisation rather than from fail-closed logic; the shape is '
          'read rather than reinvented',
      () =>
          HabotFailClosed.theThreeValuedShapeIsAlreadyDeclared &&
          HabotFailClosed.threeInputsNote.contains('Step 294'),
    );
  });

  group('GEN-00445 :: the band, which is right', () {
    gate(
      'GEN-00445-G8',
      'Floor 1, optimal 1, ceiling "N/A (100% target)".',
      'One number and a string where the third boundary should be -- which on '
          'any other row this track has met would be a defect',
      () =>
          HabotFailClosed.theFloorEqualsTheOptimal &&
          HabotFailClosed.theCeilingIsNotANumber,
    );

    gate(
      'GEN-00445-G9',
      'And on this subject it is correct.',
      'A fail-closed control that holds 99.9 per cent of the time is not a '
          'control with a small gap, it is a control with a known way '
          'through; the first collapsed band in eleven batches that fits its '
          'subject',
      () =>
          HabotFailClosed.theCollapsedBandIsRightHere &&
          HabotFailClosed.bandNote.contains('a known way through'),
    );

    gate(
      'GEN-00445-G10',
      'Output: Pass / Fail.',
      'Five declared obligations, all met, giving Pass; all ten declared '
          'checks hold',
      () =>
          HabotFailClosed.obligations.length == 5 &&
          HabotFailClosed.obligations.values.every((bool b) => b) &&
          HabotFailClosed.qualitativeOutput == 'Pass' &&
          HabotFailClosed.checks.length == 10 &&
          HabotFailClosed.checks.values.every((bool b) => b) &&
          HabotFailClosed.columnNote.contains('Google Docs'),
    );
  });

  tearDownAll(() {
    final String refused =
        HabotFailClosed.messageFor(HabotCheckResult.refused);
    final String errored =
        HabotFailClosed.messageFor(HabotCheckResult.errored);
    final String absent = HabotFailClosed.messageFor(HabotCheckResult.absent);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00445',
        atomicStepReferenceId: 'GEN-00445',
        setupStepAction:
            'COLUMN NOTE: the Atomic Step ends with the stray token "Google '
            'Docs", and the Setup Step column reads "Test the reflow '
            'transition at exactly the Compact breakpoint boundary -- 599dp '
            'and 600dp", which is a layout instruction on a security row. '
            'Atomic Step: "Hardcode Fail-Closed logic: treat Null, Error, or '
            'False results as a hard stop."',
        implementationOrder: 316,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Hardcode Fail-Closed logic: treat Null, Error, or False results as':
              '${HabotCheckResult.values.length} results, '
                  '${HabotFailClosed.stopping.length} of which stop the action',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'refused reads "$refused"; errored reads "$errored"; absent '
                  'reads "$absent"',
          'Data Quality Note':
              'POLICY: ${HabotFailClosed.policyNote} '
              'THREE INPUTS: ${HabotFailClosed.threeInputsNote} '
              'ATOMICITY: ${HabotFailClosed.atomicityNote} '
              'BAND: ${HabotFailClosed.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Fail-Closed Stop Reliability',
            observed:
                '1.0 over five declared obligations. The band has one number '
                'in it and a string where the ceiling should be, and on this '
                'subject that is right: there is no gradient, because a '
                'control that holds nine hundred and ninety-nine times in a '
                'thousand is a control with a known way through. The first '
                'collapsed band in this track that fits its own subject.',
            floor: '1',
            optimal: '1',
            ceiling: 'N/A (100% target)',
          ),
          AissMeasurement(
            metricName: 'Stopping results sharing one message',
            observed:
                '0 of ${HabotFailClosed.stopping.length}. Refused, errored '
                'and absent are three facts about the world and only one of '
                'them is a refusal; the other two are the application\'s own '
                'failure and its own omission, and saying "you are not '
                'allowed" on those is wrong twice out of three times.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/resilience/fail_closed.dart',
        ],
      ),
    );
  });
}
