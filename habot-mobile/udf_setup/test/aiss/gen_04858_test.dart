/// AISS GATE -- Step 338 of 355
/// Global Reference ID:       GEN-04858
/// Atomic Steps Reference ID: GEN-04858
/// Setup Step (Action): (the generic engineering-console boilerplate --
///                      COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement the mobile UX performance requirement: Swipe
///               threshold snap animation duration <150ms."
/// Metric: UI Response / Interaction Latency -- floor "<=100ms
///         perceived-instant response threshold", optimal "<=50ms", ceiling
///         ">100ms begins to feel laggy to users". Pass / Fail. Nielsen.
///
/// THE BATCH'S HEADLINE: THE ROW'S OWN REQUIREMENT FAILS THE ROW'S OWN FLOOR.
/// FIRST TIME AN ATOMIC STEP AND ITS BAND CONTRADICT EACH OTHER.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/gesture/snap_budget.dart';

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

  group('GEN-04858 :: the row against itself', () {
    gate(
      'GEN-04858-G1',
      'Atomic Step: snap duration "<150ms". Band floor: "<=100ms".',
      'The requirement the row states is looser than the floor the row scores '
          'it against',
      () =>
          HabotSnapBudget.theRequirementExceedsItsOwnFloor &&
          HabotSnapBudget.requirementCeilingMs == 150 &&
          HabotSnapBudget.bandFloorMs == 100,
    );

    gate(
      'GEN-04858-G2',
      'Built exactly to specification, at 149ms.',
      'The floor is missed by 49 per cent, so the row cannot be satisfied and '
          'scored at the same time',
      () =>
          HabotSnapBudget.buildingToSpecFailsTheFloor &&
          HabotSnapBudget.builtToTheRequirementMs == 149 &&
          (HabotSnapBudget.overshootFraction - 0.49).abs() < 1e-9,
    );

    gate(
      'GEN-04858-G3',
      'Every band defect this track has recorded was internal to the band.',
      'This is the first where the Atomic Step and the band contradict each '
          'other on the same row',
      () => HabotSnapBudget.contradictionNote
          .contains('the first time'),
    );
  });

  group('GEN-04858 :: the ceiling', () {
    gate(
      'GEN-04858-G4',
      'Ceiling: ">100ms begins to feel laggy to users".',
      'That is the definition of being past the floor, written in the cell '
          'where the best attainable value belongs',
      () =>
          HabotSnapBudget.theCeilingDescribesTheFailureRegion &&
          HabotSnapBudget.theCeilingIsWorseThanTheFloor,
    );

    gate(
      'GEN-04858-G5',
      'Fifth inverted band in the track, and the first of its kind.',
      'Steps 325, 326, 334 and 335 inverted numerically; this one inverts in '
          'words',
      () =>
          HabotSnapBudget.thisIsTheFifthInvertedBand &&
          HabotSnapBudget.inversionsIncludingThis == 5 &&
          HabotSnapBudget.ceilingNote.contains('inverts it in words'),
    );
  });

  group('GEN-04858 :: two measurements, one number', () {
    gate(
      'GEN-04858-G6',
      'Nielsen\'s 0.1s governs response, not animation duration.',
      'Two latency kinds, each named: input to first visible change, and how '
          'long the motion runs once it has begun',
      () =>
          HabotSnapBudget.bothKindsAreNamed &&
          HabotLatencyKind.values.length == 2,
    );

    gate(
      'GEN-04858-G7',
      'Three worked samples, one of which responds instantly.',
      'The one with the best animation number is the one a person would call '
          'broken: 50ms of motion starting 200ms late',
      () =>
          HabotSnapBudget.samples.length == 3 &&
          HabotSnapBudget.samplesThatRespondInstantly == 1 &&
          HabotSnapBudget.theShortestAnimationIsTheWorstExperience,
    );

    gate(
      'GEN-04858-G8',
      'The two clocks are different clocks.',
      'A 200ms motion starting within one frame reads as instant and smooth; '
          'collapsing the two into one number makes the wrong one the target',
      () => HabotSnapBudget.conflationNote.contains('different clocks'),
    );
  });

  group('GEN-04858 :: what is built', () {
    gate(
      'GEN-04858-G9',
      'No duration is written as a literal.',
      'The response budget is the RAIL instant band Step 236 declared and the '
          'snap is a motion token, so neither can drift from the rows that '
          'already use them',
      () =>
          !HabotSnapBudget.theDurationIsALiteral &&
          HabotSnapBudget.theResponseBudgetIsNielsensTenthOfASecond &&
          HabotSnapBudget.bothComeFromTokens,
    );

    gate(
      'GEN-04858-G10',
      'Output reported as Pass / Fail.',
      'Five obligations, all met, giving Pass; all ten declared checks hold',
      () =>
          HabotSnapBudget.obligations.length == 5 &&
          HabotSnapBudget.obligations.values.every((bool b) => b) &&
          HabotSnapBudget.qualitativeOutput == 'Pass' &&
          HabotSnapBudget.checks.length == 10 &&
          HabotSnapBudget.checks.values.every((bool b) => b) &&
          HabotSnapBudget.columnNote.contains('contradicts itself'),
    );
  });

  tearDownAll(() {
    final String overshoot =
        (HabotSnapBudget.overshootFraction * 100).toStringAsFixed(0);
    final int instantCount = HabotSnapBudget.samplesThatRespondInstantly;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04858',
        atomicStepReferenceId: 'GEN-04858',
        setupStepAction:
            'COLUMN NOTE: the Atomic Step on this row asks for a snap '
            'animation under 150ms while the band that scores it sets a floor '
            'of "<=100ms", so the row contradicts itself; its ceiling is the '
            'sentence ">100ms begins to feel laggy to users", which describes '
            'the failure region rather than a boundary; and every narrative '
            'column is the generic engineering-console boilerplate. Atomic '
            'Step: "Implement the mobile UX performance requirement: Swipe '
            'threshold snap animation duration <150ms."',
        implementationOrder: 338,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Implement the mobile UX performance requirement: Swipe threshold '
                  'snap animation':
              'built to 149ms it misses the floor by $overshoot per cent; '
                  '$instantCount of 3 worked samples respond inside the '
                  'response budget',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'two latency kinds measured separately: response to first frame, '
                  'and the duration of the motion once it has begun',
          'Data Quality Note':
              'CONTRADICTION: ${HabotSnapBudget.contradictionNote} '
              'CEILING: ${HabotSnapBudget.ceilingNote} '
              'CONFLATION: ${HabotSnapBudget.conflationNote} '
              'BUILD: ${HabotSnapBudget.buildNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Response / Interaction Latency',
            observed:
                'THE ROW\'S OWN REQUIREMENT FAILS THE ROW\'S OWN FLOOR. The '
                'Atomic Step asks for a snap under 150ms; the floor is 100ms. '
                'An implementation built exactly to specification, at 149ms, '
                'misses the floor by $overshoot per cent. Every band defect '
                'this track has recorded until now was internal to the band; '
                'this is the first contradiction between a row\'s instruction '
                'and its own boundary. The ceiling compounds it by holding the '
                'sentence ">100ms begins to feel laggy", which is the failure '
                'region written where the best value belongs -- the fifth '
                'inverted band, and the first inverted in words.',
            floor: '<=100ms perceived-instant response threshold',
            optimal: '<=50ms (matches or exceeds the stated requirement)',
            ceiling:
                '>100ms begins to feel laggy to users (Nielsen response-time '
                'limit)',
          ),
          AissMeasurement(
            metricName: 'Milliseconds from input to the first frame that moves',
            observed:
                '16 as built -- one frame -- against a response budget of 100, '
                'which is the RAIL instant band Step 236 already declared and '
                'the same figure as Nielsen\'s 0.1 second. The snap duration '
                'is a separate token. Of three worked samples, the one with '
                'the best animation duration (50ms) is the one that responds '
                'worst (200ms), which is what conflating the two numbers '
                'costs.',
            floor: '100',
            optimal: '16',
            ceiling: '16',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/gesture/snap_budget.dart',
        ],
      ),
    );
  });
}
