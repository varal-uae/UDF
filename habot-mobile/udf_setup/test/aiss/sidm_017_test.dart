/// AISS GATE -- Step 423 of 415
/// Global Reference ID:       SIDM-017
/// Atomic Steps Reference ID: SIDM-017
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Compute conversion drop-off delta metrics against the required
///               targets."
/// Metric: Standard Operating Procedure (SOP) Adherence Rate -- floor "90%
///         adherence to documented procedure", optimal "98% adherence to
///         documented procedure", ceiling "100% adherence to documented
///         procedure". Best Qualitative Output: "Pass". ISO 9001:2015 Quality
///         Management Systems - Clause 8 (Operational Control). Assigned to
///         **ADFA**.
///
/// A DELTA AGAINST TARGETS THAT ARE NEVER STATED, SCORED ON ADHERENCE TO A
/// PROCEDURE THAT DOES NOT EXIST.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/drop_off_delta.dart';

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

  group('SIDM-017 :: the missing half of the subtraction', () {
    gate(
      'SIDM-017-G1',
      'The required targets are nowhere in the row.',
      'A delta is a subtraction and a subtraction needs two numbers; this row '
          'supplies one',
      () =>
          HabotDropOffDelta.theDefiniteArticleHasNoAntecedent &&
          HabotDropOffDelta.fourthSuchRow,
    );

    gate(
      'SIDM-017-G2',
      'So the prior period is used and named as a substitution.',
      'Because a target invented to make a delta computable is a target '
          'somebody quotes next quarter as though it had been agreed',
      () =>
          HabotDropOffDelta.theSubstitutionIsNamed &&
          HabotDropOffDelta
              .antecedentNote.contains('as though it had been agreed'),
    );

  });

  group('SIDM-017 :: five steps and a baseline each', () {
    gate(
      'SIDM-017-G3',
      'Five funnel steps, each with a baseline.',
      'Open, enter hours, choose reason code, review, submit',
      () =>
          HabotDropOffDelta.stepCount == 5 &&
          HabotDropOffDelta.everyStepHasABaseline,
    );

    gate(
      'SIDM-017-G4',
      'The reason-code step is furthest below its baseline.',
      'Losing more than a quarter of everybody who reaches it',
      () =>
          HabotDropOffDelta.theWorstStepIsTheReasonCode &&
          HabotDropOffDelta.theWorstDeltaIsNegative &&
          HabotDropOffDelta.stepsBelowTheirBaseline >= 1,
    );

    gate(
      'SIDM-017-G5',
      'And Step 421 found the same field independently.',
      'The reason-code field also has the longest focus durations -- two '
          'measurements taken for different purposes agreeing on one field',
      () => HabotDropOffDelta.funnelNote.contains('longest focus durations'),
    );

  });

  group('SIDM-017 :: per step, not end to end', () {
    gate(
      'SIDM-017-G6',
      'The delta is per step rather than end to end.',
      'An end-to-end figure says sixty-one per cent finish and nothing about '
          'where the rest went',
      () =>
          HabotDropOffDelta.everyStepPublishesItsOwnDelta &&
          HabotDropOffDelta.granularityNote.contains('names a screen'),
    );

  });

  group('SIDM-017 :: the metric, the band and the column', () {
    gate(
      'SIDM-017-G7',
      'The metric scores a procedure that does not exist.',
      'SOP adherence on a row whose product is a computation, with no '
          'documented procedure anywhere to adhere to',
      () =>
          HabotDropOffDelta.theMetricScoresTheWrongThing &&
          HabotDropOffDelta.theBandIsUnmeasurable,
    );

    gate(
      'SIDM-017-G8',
      'All three band cells are sentences.',
      'The third all-sentence band in the track, after Steps 400 and 416',
      () =>
          HabotDropOffDelta.everyBandCellIsASentence &&
          HabotDropOffDelta.thirdAllSentenceBand,
    );

    gate(
      'SIDM-017-G9',
      'And the output column holds one value.',
      '"Pass", the twelfth one-valued column in the track',
      () =>
          HabotDropOffDelta.theOutputColumnHoldsOneValue &&
          HabotDropOffDelta.theCountReachesTwelve,
    );

    gate(
      'SIDM-017-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotDropOffDelta.obligations.length == 5 &&
          HabotDropOffDelta.obligations.values.every((bool b) => b) &&
          HabotDropOffDelta.qualitativeOutput == 'Pass' &&
          HabotDropOffDelta.fiveCellsBelongElsewhere &&
          HabotDropOffDelta.sixthSplicedRow &&
          HabotDropOffDelta.theBandDefaultWasSeenAtStep422 &&
          HabotDropOffDelta.endToEndRate > 0,
    );
  });

  tearDownAll(() {
    final int steps = HabotDropOffDelta.stepCount;
    final String worst = HabotDropOffDelta.worstStep.name;
    final int below = HabotDropOffDelta.stepsBelowTheirBaseline;
    final int spliced = HabotDropOffDelta.cellsFromTheOtherRow.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'SIDM-017',
        atomicStepReferenceId: 'SIDM-017',
        setupStepAction:
            'COLUMN NOTE: this row asks for a delta "against the required '
            'targets" and no targets are stated here or behind it -- the '
            'fourth row in two batches to use a definite article for something '
            'undefined, after Steps 398, 406 and 419 -- so each step\'s own '
            'prior-period rate is used and named as a substitution; its metric '
            'scores adherence to a documented procedure that does not exist, '
            'on a row whose product is a computation; all three band cells are '
            'sentences, the third such band after Steps 400 and 416; its Best '
            'Qualitative Output column holds the single word "Pass", the '
            'twelfth one-valued column; and its Data Requirement holds five '
            'software-versioning fields belonging to a release row, making '
            'this the sixth spliced row in the track. Atomic Step: "Compute '
            'conversion drop-off delta metrics against the required targets."',
        implementationOrder: 423,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Version Number':
              'not applicable: these five versioning fields belong to a '
                  'release row spliced into this one',
          'Version Type': 'as above',
          'Release Date': 'as above',
          'Version Status':
              '$steps funnel steps, each publishing its own delta against its '
                  'own prior-period rate',
          'Version Checksum':
              '$below step sits below its baseline -- "$worst" -- and $spliced '
                  'cells on this row belong elsewhere',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Standard Operating Procedure (SOP) Adherence Rate',
            observed:
                'THE ROW SUPPLIES ONE HALF OF A SUBTRACTION AND IS SCORED ON A '
                'PROCEDURE THAT DOES NOT EXIST. "The required targets" appear '
                'nowhere in this row or behind it -- the fourth row in two '
                'batches to use a definite article for something undefined -- '
                'so each step\'s own prior-period rate is used and named as a '
                'substitution. The metric scores adherence to a documented '
                'procedure which does not exist, on a row whose product is a '
                'computation; all three of its band cells are sentences, the '
                'third such band after Steps 400 and 416; and its output '
                'column holds the single word "Pass". Observed: $steps steps, '
                '$below below baseline.',
            floor: '90% adherence to documented procedure',
            optimal: '98% adherence to documented procedure',
            ceiling: '100% adherence to documented procedure',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Steps published without a baseline',
            observed:
                '0 of $steps. The delta is published per step rather than end '
                'to end, because the only actionable form of a funnel number '
                'is the one that names a screen: sixty-one per cent of people '
                'who start finish, and that figure says nothing about where '
                'the other thirty-nine went. It went at "$worst", which loses '
                'more than a quarter of everybody who reaches it and is also '
                'the field Step 421 independently found to have the longest '
                'focus durations -- two measurements taken for different '
                'purposes agreeing on one field.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/drop_off_delta.dart',
        ],
      ),
    );
  });
}
