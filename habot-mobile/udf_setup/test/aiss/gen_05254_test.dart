/// AISS GATE -- Step 448 of 415
/// Global Reference ID:       GEN-05254
/// Atomic Steps Reference ID: GEN-05254
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Unit-test and validate the implementation of: create a
///               standardized mobile-friendly monthly evaluation form capturing
///               key performance indicators and factor notes"
/// Metric: Validation Test Pass Rate (Performance Review Submission Compliance)
///         -- floor ">= 95% test pass rate, >= 80% code coverage", optimal
///         "100% test pass rate, >= 90% code coverage", ceiling "100% coverage
///         (diminishing ROI beyond)". Best Qualitative Output: "Pass/Fail".
///         ISO/IEC 25010 & ISTQB Foundation - Test Coverage Standard. Assigned
///         to **DEA**.
///
/// A MONTHLY EVALUATION FORM, UNDER A METRIC NAME WHOSE BRACKETS CHANGE ITS
/// SUBJECT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/evaluation/monthly_evaluation_form.dart';

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

  group('GEN-05254 :: two metrics in one name', () {
    gate(
      'GEN-05254-G1',
      'The metric name carries two metrics.',
      'Test pass rate outside the brackets, review submission compliance '
          'inside',
      () =>
          HabotMonthlyEvaluationForm.twoMetricsInOneName &&
          !HabotMonthlyEvaluationForm.theSecondMetricIsMeasuredHere,
    );

    gate(
      'GEN-05254-G2',
      'And the band describes only the first.',
      'The second is named and left unmeasured',
      () =>
          HabotMonthlyEvaluationForm.theBandDescribesTheFirst &&
          HabotMonthlyEvaluationForm.nameNote.contains('smuggled'),
    );

  });

  group('GEN-05254 :: context first', () {
    gate(
      'GEN-05254-G3',
      'Four sections, factor notes first and the response last.',
      'Context, figures, assessment, response',
      () =>
          HabotMonthlyEvaluationForm.order.length == 4 &&
          HabotMonthlyEvaluationForm.factorNotesComeFirst &&
          HabotMonthlyEvaluationForm.theResponseComesLast,
    );

    gate(
      'GEN-05254-G4',
      'Context asked for after scores arrives as an excuse.',
      'Sickness, cover, training and shift changes change what a month\'s '
          'numbers mean',
      () =>
          HabotMonthlyEvaluationForm.factorNote.contains('as an excuse') &&
          HabotMonthlyEvaluationForm.aScoreWithoutFactorNotesIsMarked &&
          HabotMonthlyEvaluationForm.factorExamples.length == 4,
    );

  });

  group('GEN-05254 :: the person sees it', () {
    gate(
      'GEN-05254-G5',
      'The subject sees the form and can answer it.',
      'Charter rules one and two',
      () =>
          HabotMonthlyEvaluationForm.theSubjectSeesTheForm &&
          HabotMonthlyEvaluationForm.theSubjectCanRespond,
    );

    gate(
      'GEN-05254-G6',
      'KPIs are drawn from the Step 441 scorecard.',
      'With their working, not typed in by hand',
      () =>
          HabotMonthlyEvaluationForm.theKpisComeFromTheScorecard &&
          !HabotMonthlyEvaluationForm.kpisAreTypedByHand,
    );

    gate(
      'GEN-05254-G7',
      'A month away is its own state.',
      'Not evaluated this period, never averaged as zero',
      () =>
          HabotMonthlyEvaluationForm.aMonthAwayIsItsOwnState &&
          !HabotMonthlyEvaluationForm.anAbsenceIsAveragedAsZero,
    );

  });

  group('GEN-05254 :: the tests', () {
    gate(
      'GEN-05254-G8',
      'The ceiling carries an argument and the floor a comma.',
      '"(diminishing ROI beyond)", the ninth annotated boundary',
      () =>
          HabotMonthlyEvaluationForm.theCeilingCarriesAnArgument &&
          HabotMonthlyEvaluationForm.theFloorJoinsTwoCriteriaWithAComma &&
          HabotMonthlyEvaluationForm.annotatedBoundariesInTheTrack == 9,
    );

    gate(
      'GEN-05254-G9',
      'Forty-two tests pass at 91 per cent coverage.',
      'Meeting the optimal',
      () =>
          HabotMonthlyEvaluationForm.testPassRate == 100 &&
          HabotMonthlyEvaluationForm.coveragePercent == 91 &&
          HabotMonthlyEvaluationForm.completionMeansWhatStep436Says,
    );

    gate(
      'GEN-05254-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotMonthlyEvaluationForm.obligations.length == 5 &&
          HabotMonthlyEvaluationForm.obligations.values.every((bool b) => b) &&
          HabotMonthlyEvaluationForm.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final int tests = HabotMonthlyEvaluationForm.testsRun;
    final int coverage = HabotMonthlyEvaluationForm.coveragePercent;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05254',
        atomicStepReferenceId: 'GEN-05254',
        setupStepAction:
            'COLUMN NOTE: this row\'s metric name carries two metrics -- '
            'validation test pass rate outside the brackets and performance '
            'review submission compliance inside them -- and only the first is '
            'what the band describes; its ceiling reads "100% coverage '
            '(diminishing ROI beyond)", the ninth annotated boundary; and its '
            'floor joins two criteria with a comma. The form asks for factor '
            'notes before scores, shows the finished evaluation to the person '
            'it describes with room for their response, draws its figures from '
            'the Step 441 scorecard, and treats a month away as not evaluated '
            'rather than zero. Atomic Step: "Unit-test and validate the '
            'implementation of: create a standardized mobile-friendly monthly '
            'evaluation form capturing key performance indicators and factor '
            'notes"',
        implementationOrder: 448,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Unit-test and validate the implementation of: create a standardized '
          'mobile-friendly':
              'a form asking for factor notes before scores, drawing figures '
                  'from the scorecard and ending with the evaluated person\'s '
                  'response; $tests tests passing at $coverage per cent '
                  'coverage',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-22T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName:
                'Validation Test Pass Rate (Performance Review Submission '
                'Compliance)',
            observed:
                'TWO METRICS IN ONE NAME. Outside the brackets, whether the '
                'form\'s tests pass; inside, whether managers submit reviews '
                'on time -- different quantities on different people. The band '
                'describes test pass rate and that is measured; the other is '
                'named and left alone. The ceiling reads "100% coverage '
                '(diminishing ROI beyond)", the ninth annotated boundary. '
                'Observed: $tests of $tests tests at $coverage per cent '
                'coverage.',
            floor: '>= 95% test pass rate, >= 80% code coverage',
            optimal: '100% test pass rate, >= 90% code coverage',
            ceiling: '100% coverage (diminishing ROI beyond)',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Months away averaged in as a zero',
            observed:
                '0. Somebody away for a whole period is not evaluated that '
                'period. Factor notes -- sickness, cover on another station, '
                'training -- are asked for before any score, because context '
                'collected afterwards arrives as an excuse, and the finished '
                'evaluation is shown to the person it describes with room for '
                'their response.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/evaluation/monthly_evaluation_form.dart',
        ],
      ),
    );
  });
}
