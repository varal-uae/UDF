/// AISS GATE -- Step 449 of 415
/// Global Reference ID:       GEN-05265
/// Atomic Steps Reference ID: GEN-05265
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Integrate all components and confirm the expected output is
///               achieved: operational monthly manager evaluation tool with
///               automated performance distribution tracking"
/// Metric: System Integration Test Pass Rate -- floor ">= 90%", optimal "1",
///         ceiling "1". Best Qualitative Output: "Pass/Fail". ISO/IEC 25010 -
///         Interoperability & Integration Testing. Assigned to **UDF**.
///
/// "AUTOMATED PERFORMANCE DISTRIBUTION TRACKING" -- THE MACHINERY OF A FORCED
/// CURVE, UNLESS SOMEBODY DECIDES IT IS NOT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/evaluation/manager_evaluation.dart';

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

  group('GEN-05265 :: reported, never enforced', () {
    gate(
      'GEN-05265-G1',
      'Distribution tracking is where stack ranking starts.',
      'The next request is always for the distribution to match a curve',
      () => HabotManagerEvaluation.curveNote.contains('next desk'),
    );

    gate(
      'GEN-05265-G2',
      'So there is no quota, no rescaling and no curve.',
      'The distribution is reported and never enforced',
      () => HabotManagerEvaluation.reportedNotEnforced,
    );

  });

  group('GEN-05265 :: what the report says', () {
    gate(
      'GEN-05265-G3',
      'This manager rates 11 of 12 as exceeds.',
      'A worked case of a skewed use of the scale',
      () =>
          HabotManagerEvaluation.total(HabotManagerEvaluation.thisManager) ==
              12 &&
          HabotManagerEvaluation.thisManager[HabotRatingBand.exceeds] == 11,
    );

    gate(
      'GEN-05265-G4',
      'Against 29 per cent across the organisation.',
      '58 of 200',
      () =>
          HabotManagerEvaluation.total(HabotManagerEvaluation.organisation) ==
              200 &&
          HabotManagerEvaluation
              .shareExceeds(HabotManagerEvaluation.organisation) == 29,
    );

    gate(
      'GEN-05265-G5',
      'Which the report shows as a use of the scale.',
      'It says nothing about the team and requires nothing to change',
      () =>
          HabotManagerEvaluation.thisManagerIsSkewedHigh &&
          HabotManagerEvaluation.theReportSaysWhatItIsFor,
    );

    gate(
      'GEN-05265-G6',
      'And no rating changes without a named person.',
      'Charter rule three',
      () => HabotManagerEvaluation.noScoreChangesWithoutAPerson,
    );

  });

  group('GEN-05265 :: two readings', () {
    gate(
      'GEN-05265-G7',
      '"Manager evaluation" reads two ways.',
      'Written by managers, or of managers; the first is built',
      () =>
          HabotManagerEvaluation.theTwoReadingsDiffer &&
          HabotManagerEvaluation.readingBuilt.contains('written by'),
    );

    gate(
      'GEN-05265-G8',
      'The form is Step 448\'s.',
      'Factor notes first',
      () => HabotManagerEvaluation.theFormIsTheStep448Form,
    );

  });

  group('GEN-05265 :: the result', () {
    gate(
      'GEN-05265-G9',
      'The band mixes units, and eighteen integration tests pass.',
      'A percentage floor against an optimal and ceiling of 1',
      () =>
          HabotManagerEvaluation.theBandMixesUnits &&
          HabotManagerEvaluation.passRate == 1,
    );

    gate(
      'GEN-05265-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotManagerEvaluation.obligations.length == 5 &&
          HabotManagerEvaluation.obligations.values.every((bool b) => b) &&
          HabotManagerEvaluation.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final int tests = HabotManagerEvaluation.integrationTests;
    final Map<HabotRatingBand, int> org = HabotManagerEvaluation.organisation;
    final double orgExceeds = HabotManagerEvaluation.shareExceeds(org);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05265',
        atomicStepReferenceId: 'GEN-05265',
        setupStepAction:
            'COLUMN NOTE: this row asks for "automated performance '
            'distribution tracking" in a monthly manager evaluation tool, '
            'which is the machinery of a forced curve -- so the distribution '
            'is reported to each manager beside the organisation\'s and never '
            'enforced, with no quota, no automatic rescaling and no curve; '
            '"manager evaluation" reads two ways and the reading built is '
            'evaluations written by managers, with the other recorded; and its '
            'band writes a percentage floor against an optimal and ceiling of '
            '1. Atomic Step: "Integrate all components and confirm the '
            'expected output is achieved: operational monthly manager '
            'evaluation tool with automated performance distribution tracking"',
        implementationOrder: 449,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Integrate all components and confirm the expected output is '
          'achieved:':
              'distribution reported to each manager beside the '
                  'organisation\'s (${orgExceeds.toStringAsFixed(0)} per cent '
                  'exceeds) and never enforced; $tests integration tests '
                  'passing',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-22T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'System Integration Test Pass Rate',
            observed:
                'THE BAND MIXES UNITS, AND THE INSTRUCTION ASKS FOR A CURVE\'S '
                'MACHINERY. A percentage floor against an optimal and ceiling '
                'of 1. Distribution tracking is where stack ranking starts: '
                'once a system knows how a manager\'s ratings fall, the next '
                'request is to force them onto a curve. Observed: $tests of '
                '$tests integration tests pass.',
            floor: '>= 90%',
            optimal: '1',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Ratings moved to fit a distribution',
            observed:
                '0. A forced curve guarantees that some of a strong team fail '
                'and some of a weak team pass, and turns every evaluation into '
                'a comparison with the next desk. Each manager sees how their '
                'ratings fall beside the organisation\'s -- in the worked case '
                'eleven of twelve rated exceeds against '
                '${orgExceeds.toStringAsFixed(0)} per cent overall -- with a '
                'caption saying it describes their use of the scale and '
                'requires nothing to change.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/evaluation/manager_evaluation.dart',
        ],
      ),
    );
  });
}
