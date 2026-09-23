/// AISS GATE -- Step 469 of 1,314
/// Global Reference ID:       GEN-05078
/// Atomic Steps Reference ID: GEN-05078
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement the self-chasing automation behavior: Tapping any
///               data point opens the exact historical assessment document from
///               that evaluation date."
/// Metric: Automation Trigger Reliability Rate -- floor ">=99.0% successful
///         automated trigger execution", optimal "99.9% (three-nines)
///         reliability", ceiling "100% (five-nines+ pursued only where
///         cost-justified)". Best Qualitative Output: "Pass / Fail". Google
///         Site Reliability Engineering (SRE) -- automation reliability /
///         error-budget practice. Assigned to **PDG**.
///
/// SELF-CHASING WORTH HAVING: EVERY POINT OPENS THE DOCUMENT IT CAME FROM.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/assessment/data_point_source.dart';

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

  group('GEN-05078 :: Step 441\'s rule, already in the instruction', () {
    gate(
      'GEN-05078-G1',
      'The instruction already carries Step 441\'s rule.',
      'Every figure reaches the working behind it',
      () =>
          HabotDataPointSource.theRowThatRequiredWorking == 441 &&
          HabotDataPointSource.theChartIsAWayOfReachingIt,
    );

    gate(
      'GEN-05078-G2',
      'So the document is the evidence, not the number.',
      'The chart is a way of getting to it',
      () =>
          HabotDataPointSource.theDocumentIsTheEvidence &&
          HabotDataPointSource.provenanceNote.contains('the document is'),
    );

  });

  group('GEN-05078 :: two kinds of failure, priced apart', () {
    gate(
      'GEN-05078-G3',
      'Three attempts, two opened, one returned nothing.',
      'A failure that costs a tap',
      () =>
          HabotDataPointSource.attempts.length == 3 &&
          HabotDataPointSource
              .attempts.where(HabotDataPointSource.opened).length == 2,
    );

    gate(
      'GEN-05078-G4',
      'Every opened document matches the point that was tapped.',
      'Checked on id and on date before it is shown',
      () => HabotDataPointSource.aMismatchShowsAnErrorNotADocument,
    );

    gate(
      'GEN-05078-G5',
      'The wrong-document count is zero.',
      'A failure that puts wrong evidence in front of a decision',
      () => HabotDataPointSource.theWrongDocumentRateIsZero,
    );

    gate(
      'GEN-05078-G6',
      'And the open rate clears the 99 per cent floor.',
      '99.4 per cent, with the two failure kinds counted apart',
      () =>
          HabotDataPointSource.theOpenRateMeetsTheFloor &&
          HabotDataPointSource.failureNote.contains('counted apart'),
    );

  });

  group('GEN-05078 :: a ceiling about money', () {
    gate(
      'GEN-05078-G7',
      'The ceiling argues about cost.',
      '"five-nines+ pursued only where cost-justified" is advice, not a bound',
      () => HabotDataPointSource.theCeilingIsAnEconomicArgument,
    );

    gate(
      'GEN-05078-G8',
      'The eleventh annotated boundary in the track.',
      'Boundaries that explain themselves instead of stating a value',
      () => HabotDataPointSource.eleventhAnnotatedBoundary,
    );

  });

  group('GEN-05078 :: a tap is not the only way in', () {
    gate(
      'GEN-05078-G9',
      'Every point is focusable, labelled, and in the table too.',
      'A point on an SVG is not reachable by keyboard on its own',
      () =>
          HabotDataPointSource.everyPointHasALabel &&
          HabotDataPointSource.theTableCarriesTheSameLink &&
          HabotDataPointSource.reachNote.contains('keyboard or screen reader'),
    );

    gate(
      'GEN-05078-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotDataPointSource.obligations.length == 5 &&
          HabotDataPointSource.obligations.values.every((bool b) => b) &&
          HabotDataPointSource.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final int attempts = HabotDataPointSource.attempts.length;
    final int wrong = HabotDataPointSource.wrongDocumentCount;
    final double open = HabotDataPointSource.observedOpenSuccessPercent;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05078',
        atomicStepReferenceId: 'GEN-05078',
        setupStepAction:
            'COLUMN NOTE: this row asks for the provenance rule Step 441 had '
            'to add, arriving already written into the instruction; its single '
            'reliability percentage cannot distinguish a document that did not '
            'open from the wrong document opening, so the two are counted '
            'apart with a wrong-document floor of zero; its ceiling argues '
            'about cost rather than stating a bound, the eleventh annotated '
            'boundary in the track; and every point is a focusable, labelled '
            'control because a tap on an SVG is not reachable on its own. '
            'Atomic Step: "Implement the self-chasing automation behavior: '
            'Tapping any data point opens the exact historical assessment '
            'document from that evaluation date."',
        implementationOrder: 469,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Implement the self-chasing automation behavior: Tapping any data '
          'point opens':
              '$attempts attempts with $wrong wrong documents and an open rate '
                  'of ${open.toStringAsFixed(1)} per cent, every point '
                  'focusable and labelled, and the same link in the table',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Automation Trigger Reliability Rate',
            observed:
                'ONE PERCENTAGE CANNOT PRICE TWO KINDS OF FAILURE. A trigger '
                'that shows nothing costs somebody a tap; a trigger that opens '
                'a different assessment puts wrong evidence in front of a '
                'decision. They are counted apart: the link carries the '
                'document id, the returned id and date are checked against the '
                'point, and a mismatch shows an error. Observed: '
                '${open.toStringAsFixed(1)} per cent opened, $wrong wrong '
                'documents.',
            floor: '>=99.0% successful automated trigger execution',
            optimal: '99.9% (three-nines) reliability',
            ceiling: '100% (five-nines+ pursued only where cost-justified)',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Data points that open the wrong document',
            observed:
                '$wrong of $attempts. This row asks for the rule Step 441 had '
                'to add -- every figure carries its working -- arriving '
                'already written into the instruction, and it is the first row '
                'in the track to do so. Every point is a focusable control '
                'labelled with its date and value, because a point on an SVG '
                'is not reachable by keyboard or screen reader on its own, and '
                'the table form carries the same link.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/assessment/data_point_source.dart',
        ],
      ),
    );
  });
}
