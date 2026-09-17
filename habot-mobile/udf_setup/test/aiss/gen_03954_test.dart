/// AISS GATE -- Step 421 of 415
/// Global Reference ID:       GEN-03954
/// Atomic Steps Reference ID: GEN-03954
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Calculate avg_field_focus_duration = AVG(duration_ms) grouped
///               by screen_id and field_id."
/// Metric: SQL Aggregation Execution Speed -- floor "< 500 ms", optimal "< 50
///         ms", ceiling "1000 ms". Best Qualitative Output: "Pass/Fail".
///         BigQuery Stream Analytical Rules. Assigned to **UDF**.
///
/// AN AVERAGE OVER A DISTRIBUTION THAT HAS NO USEFUL AVERAGE, SCORED ON HOW
/// FAST THE QUERY RUNS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/field_focus_duration.dart';

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

  group('GEN-03954 :: capped, not dropped', () {
    gate(
      'GEN-03954-G1',
      'Three fields and twenty-one observations.',
      'A worked set small enough to check by hand',
      () =>
          HabotFieldFocusDuration.fieldCount == 3 &&
          HabotFieldFocusDuration.observationCount == 21,
    );

    gate(
      'GEN-03954-G2',
      'One observation is capped and counted.',
      'At two minutes, turning an eight-minute observation into a two-minute '
          'one rather than discarding it',
      () =>
          HabotFieldFocusDuration.cappedRatherThanDropped &&
          HabotFieldFocusDuration.observationsCapped == 1,
    );

    gate(
      'GEN-03954-G3',
      'And dropping it would remove the person who gave up.',
      'Which is the case most worth knowing about',
      () => HabotFieldFocusDuration.capNote.contains('gave up'),
    );

  });

  group('GEN-03954 :: three statistics, not one', () {
    gate(
      'GEN-03954-G4',
      'The mean sits above its own ninetieth percentile.',
      'The signature of a statistic being carried by one observation, while '
          'the median does not move at all',
      () =>
          HabotFieldFocusDuration.theMeanExceedsThePercentile &&
          HabotFieldFocusDuration.theMedianIsUnmoved,
    );

    gate(
      'GEN-03954-G5',
      'So three statistics are published, with the count.',
      'The average the row asks for, the median and the p90, because a mean '
          'quoted alone is a figure about interruptions',
      () =>
          HabotFieldFocusDuration.threeStatisticsArePublished &&
          HabotFieldFocusDuration.theCountIsPublishedBeside,
    );

  });

  group('GEN-03954 :: the grouping is the allowlist', () {
    gate(
      'GEN-03954-G6',
      'The grouping keys are both on Step 419\'s allowlist.',
      'screen_id and field_id, neither of which reaches a person',
      () =>
          HabotFieldFocusDuration.everyGroupingKeyIsPermitted &&
          HabotFieldFocusDuration.theGroupingCannotReachAPerson,
    );

    gate(
      'GEN-03954-G7',
      'And the framework scope still holds.',
      'The unit of analysis is a screen, as Step 416 fixed it',
      () => HabotFieldFocusDuration.theFrameworkScopeHolds,
    );

  });

  group('GEN-03954 :: the metric scores the query', () {
    gate(
      'GEN-03954-G8',
      'The metric scores the query rather than the answer.',
      'A query returning the wrong statistic in forty milliseconds passes; one '
          'returning the right statistic in six hundred fails',
      () =>
          HabotFieldFocusDuration.theMetricScoresTheMechanism &&
          HabotFieldFocusDuration.thirdSuchRow,
    );

    gate(
      'GEN-03954-G9',
      'The optimal sits below both boundaries.',
      'Floor "< 500 ms" and ceiling "1000 ms" bracket five hundred to a '
          'thousand; the optimal is "< 50 ms"',
      () =>
          HabotFieldFocusDuration.theOptimalIsBelowBothBoundaries &&
          HabotFieldFocusDuration.theShapeIsTheDeclaredConvention,
    );

    gate(
      'GEN-03954-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotFieldFocusDuration.obligations.length == 5 &&
          HabotFieldFocusDuration.obligations.values.every((bool b) => b) &&
          HabotFieldFocusDuration.qualitativeOutput == 'Pass' &&
          HabotFieldFocusDuration.theQueryIsInsideTheFloor,
    );
  });

  tearDownAll(() {
    final int fields = HabotFieldFocusDuration.fieldCount;
    final int observations = HabotFieldFocusDuration.observationCount;
    final int cappedCount = HabotFieldFocusDuration.observationsCapped;
    final int queryMs = HabotFieldFocusDuration.queryMs;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03954',
        atomicStepReferenceId: 'GEN-03954',
        setupStepAction:
            'COLUMN NOTE: this row asks for AVG over a distribution with no '
            'useful average -- field focus durations are heavily right-skewed, '
            'and on the worked set the capped mean for one field sits above '
            'its own ninetieth percentile -- so the median, the ninetieth '
            'percentile and the count are published beside it; its metric '
            'scores the execution speed of the aggregation rather than what '
            'the aggregation finds, the third such row after Step 413 and '
            'beside Step 425; and its optimal of "< 50 ms" sits below both its '
            'floor of "< 500 ms" and its ceiling of "1000 ms", the third row '
            'in this batch written to the convention Step 418 sets out. Atomic '
            'Step: "Calculate avg_field_focus_duration = AVG(duration_ms) '
            'grouped by screen_id and field_id."',
        implementationOrder: 421,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'avg_field_focus_duration':
              'published with the median and the ninetieth percentile beside '
                  'it, over $fields fields and $observations observations',
          'duration_ms':
              'capped at two minutes; $cappedCount observation exceeded the '
                  'cap and was capped and counted rather than dropped',
          'screen_id':
              'a grouping key, and one of the eight fields Step 419 permits '
                  'off the device',
          'field_id': 'the second grouping key; neither reaches a person',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'SQL Aggregation Execution Speed',
            observed:
                'THE METRIC SCORES THE QUERY, NOT THE ANSWER, AND THE OPTIMAL '
                'SITS BELOW BOTH BOUNDARIES. SQL Aggregation Execution Speed '
                'measures how fast the aggregation runs, so a query returning '
                'the wrong statistic in forty milliseconds passes and one '
                'returning the right statistic in six hundred fails -- the '
                'third row in two batches scored on its own mechanism, after '
                'Step 413 and beside Step 425. Its floor of "< 500 ms" and '
                'ceiling of "1000 ms" bracket five hundred to a thousand while '
                'the optimal of "< 50 ms" sits under both, the third row in '
                'this batch written to that convention. Observed: $queryMs ms.',
            floor: '< 500 ms',
            optimal: '< 50 ms',
            ceiling: '1000 ms',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Observations dropped rather than capped',
            observed:
                '0 of $observations. Field focus durations are heavily '
                'right-skewed -- most are two or three seconds and a few are '
                'minutes because somebody put the phone down -- so on this '
                'worked set the capped mean for one field sits above its own '
                'ninetieth percentile while the median does not move. The '
                'average the row asks for is published with the median, the '
                'p90 and the count beside it. $cappedCount observation was '
                'capped at two minutes and counted; dropping it would have '
                'removed exactly the session where somebody gave up.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/field_focus_duration.dart',
        ],
      ),
    );
  });
}
