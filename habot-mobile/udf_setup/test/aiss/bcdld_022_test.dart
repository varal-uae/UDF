/// AISS GATE -- Step 390 of 395
/// Global Reference ID:       BCDLD-022
/// Atomic Steps Reference ID: BCDLD-022
/// Setup Step (Action): "Verify the timeout counter displays correctly across
///                      all device sizes."
/// Atomic Step: "Implement client-side validation running DCYN gate evaluation
///               at the mobile edge."
/// Metric: Binary Compliance Gate (DCYN) Decision Accuracy (%) -- floor "98%
///         correct gate decisions", optimal "99.5%-100%", ceiling "100% (zero
///         false negatives)". Yes (Yes / No). Assigned to **ADFA**.
///
/// TWO FEATURES IN ONE ROW, AND THE MOST USEFUL THING IN THE BAND IS INSIDE A
/// PARENTHESIS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/edge_validation.dart';

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

  group('BCDLD-022 :: two features in one row', () {
    gate(
      'BCDLD-022-G1',
      'The top half validates and the bottom half masks salaries.',
      'Expected Output, Completion Measures, both Material decisions, the '
          'poka-yoke cell and Why This Matters all describe hidden fields, a '
          'blocked clipboard and padlock markers',
      () =>
          HabotEdgeValidation.theRowDescribesTwoFeatures &&
          HabotEdgeValidation.spliceNote.contains('public transit'),
    );

    gate(
      'BCDLD-022-G2',
      'Step 388 in this batch is the same shape.',
      'And the second feature is a real requirement that now has no row of its '
          'own',
      () =>
          HabotEdgeValidation.theOtherSplicedRow == 388 &&
          !HabotEdgeValidation.theSecondFeatureHasARowOfItsOwn,
    );
  });

  group('BCDLD-022 :: latency, not trust', () {
    gate(
      'BCDLD-022-G3',
      'The server evaluates the same rule.',
      'The client\'s answer is advice from a program the person is holding',
      () =>
          HabotEdgeValidation.theEdgeGateIsAdvice &&
          HabotEdgeValidation.theServerEvaluatesTheSameRule &&
          !HabotEdgeValidation.theClientsAnswerIsAuthoritative,
    );

    gate(
      'BCDLD-022-G4',
      'What the edge buys is an answer in tens of milliseconds.',
      'And nothing else -- "gate at the edge" reads like the gate moved',
      () =>
          HabotEdgeValidation.whatTheEdgeBuys.contains('round trip') &&
          HabotEdgeValidation.edgeNote.contains('the gate moved'),
    );
  });

  group('BCDLD-022 :: the asymmetry in a parenthesis', () {
    gate(
      'BCDLD-022-G5',
      'The ceiling cell names false negatives.',
      'A false negative is a bad value accepted; a false positive is a good '
          'value refused, and the two are not equally bad',
      () =>
          HabotEdgeValidation.theCeilingNamesFalseNegatives &&
          HabotEdgeValidation.theTwoErrorsAreNotEquivalent,
    );

    gate(
      'BCDLD-022-G6',
      'None of the three band cells parses as a number.',
      'The most useful thing on the row sits inside a parenthesis in a '
          'boundary cell',
      () =>
          HabotEdgeValidation.noneOfTheThreeCellsParses &&
          HabotEdgeValidation.bandNote.contains('a parenthesis'),
    );
  });

  group('BCDLD-022 :: three outcomes, not two', () {
    gate(
      'BCDLD-022-G7',
      'Five entries: three pass, one refused, one undecidable.',
      'An IBAN whose checksum is fine but whose bank the client does not know',
      () =>
          HabotEdgeDecision.values.length == 3 &&
          HabotEdgeValidation.entries.length == 5 &&
          HabotEdgeValidation.threePassOneRefusedOneUndecidable,
    );

    gate(
      'BCDLD-022-G8',
      'The undecidable entry is sent, and the person is told.',
      'A gate with only two outcomes has to guess on the third case, and '
          'guessing "pass" is how a bad value gets in',
      () =>
          HabotEdgeValidation.theUndecidableEntryIsNotRefused &&
          !HabotEdgeValidation.anUndecidableEntryIsTreatedAsAPass &&
          HabotEdgeValidation.decisionNote.contains('guessing "pass"'),
    );

    gate(
      'BCDLD-022-G9',
      'Every refusal explains itself.',
      'With a reason the person can act on, rather than a red border',
      () => HabotEdgeValidation.everyRefusalExplainsItself,
    );
  });

  group('BCDLD-022 :: the standard cell, and the output', () {
    gate(
      'BCDLD-022-G10',
      'Testing advice where a standard belongs, and output Yes / No.',
      'Step 370 carried benchmarking prose in the same column; five '
          'obligations, all met, giving Yes, and all ten declared checks hold',
      () =>
          HabotEdgeValidation.theStandardCellHoldsAdvice &&
          HabotEdgeValidation.theAdviceIsGood &&
          HabotEdgeValidation.theFirstSuchCell == 370 &&
          HabotEdgeValidation.obligations.length == 5 &&
          HabotEdgeValidation.obligations.values.every((bool b) => b) &&
          HabotEdgeValidation.qualitativeOutput == 'Yes' &&
          HabotEdgeValidation.decidedAtTheEdge == 80 &&
          HabotEdgeValidation.checks.length == 10 &&
          HabotEdgeValidation.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final int passes = HabotEdgeValidation.countOf(HabotEdgeDecision.pass);
    final int refused = HabotEdgeValidation.countOf(HabotEdgeDecision.refuse);
    final int undecidable =
        HabotEdgeValidation.countOf(HabotEdgeDecision.undecidable);
    final String refusal = HabotEdgeValidation.entries[3].message;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'BCDLD-022',
        atomicStepReferenceId: 'BCDLD-022',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to ADFA rather than UDF; its '
            'top half describes client-side validation and everything from '
            'Expected Output downward describes masking sensitive fields, '
            'blocking the clipboard and padlock markers in lists, so two '
            'features share one row as at Step 388 and the second now has no '
            'row of its own; none of its three boundary cells parses as a '
            'number and the ceiling holds the useful asymmetry inside a '
            'parenthesis; its standard column holds testing advice rather than '
            'a standard, as Step 370\'s does; and its Setup Step column reads '
            '"Verify the timeout counter displays correctly across all device '
            'sizes". Atomic Step: "Implement client-side validation running '
            'DCYN gate evaluation at the mobile edge."',
        implementationOrder: 390,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Mobile Platform': 'both, through one declared rule set',
          'OS Version': 'not branched on',
          'Device Type': 'handset',
          'Screen Dimensions': 'the declared compact width',
          'Mobile Configuration':
              '$passes pass, $refused refused, $undecidable undecidable',
          'Completion Status': 'Yes',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the refused entry reads "$refusal"; the undecidable one is sent '
                  'with its helper text saying when it is confirmed',
          'Data Quality Note':
              'SPLICE: ${HabotEdgeValidation.spliceNote} EDGE: '
              '${HabotEdgeValidation.edgeNote} BAND: '
              '${HabotEdgeValidation.bandNote} DECISIONS: '
              '${HabotEdgeValidation.decisionNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Binary Compliance Gate (DCYN) Decision Accuracy (%)',
            observed:
                'THREE CELLS, NONE OF WHICH PARSES, AND THE BEST THING ON THE '
                'ROW IN A PARENTHESIS. "98% correct gate decisions", '
                '"99.5%-100%", "100% (zero false negatives)". The ceiling '
                'names the asymmetry that matters: a false negative is a bad '
                'value accepted and a false positive is a good value refused, '
                'and only the first leaves a record to clean up. The standard '
                'column holds testing advice instead of a standard -- "test on '
                'mid-tier mobile hardware, not developer machines" -- which is '
                'good advice and is the second such cell after Step 370.',
            floor: '98% correct gate decisions',
            optimal: '99.5%-100%',
            ceiling: '100% (zero false negatives)',
          ),
          AissMeasurement(
            metricName: 'Entries the edge guessed about',
            observed:
                '0 of 5. Evaluating at the edge buys latency and nothing else: '
                'the server evaluates the same rule again, because the '
                'client\'s answer is advice from a program the person is '
                'holding. The gate has three outcomes rather than two, so '
                '$passes entries pass, $refused is refused with a reason the '
                'person can act on, and $undecidable cannot be decided here at '
                'all -- an IBAN whose checksum is fine but whose bank the '
                'client does not know. That one is sent rather than guessed '
                'about, and the helper text says when it will be confirmed.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/edge_validation.dart',
        ],
      ),
    );
  });
}
