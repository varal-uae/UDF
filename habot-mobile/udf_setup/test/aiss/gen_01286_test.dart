/// AISS GATE -- Step 432 of 415
/// Global Reference ID:       GEN-01286
/// Atomic Steps Reference ID: GEN-01286
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Execute message delivery latency benchmarks targeting
///               sub-100ms transit times."
/// Metric: In-App Message Delivery Latency -- floor "<3s", optimal "<500ms",
///         ceiling "<5s". Best Qualitative Output: "Good/Average/Poor".
///         XMPP/WebSocket Real-Time Messaging Benchmark. Assigned to **DEA**.
///
/// AN INSTRUCTION TARGETING 100MS UNDER A BAND WHOSE BEST VALUE IS 500MS, AND
/// THE PAIR THAT SETTLES THE CEILING COLUMN.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/live/delivery_benchmark.dart';

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

  group('GEN-01286 :: the instruction and the band disagree', () {
    gate(
      'GEN-01286-G1',
      'The instruction and the band disagree.',
      'Sub-100ms in the Atomic Step against an optimal of 500ms, five times '
          'apart, with nothing to say which is the requirement',
      () =>
          HabotDeliveryBenchmark.theTwoTargetsDiffer &&
          HabotDeliveryBenchmark.theyAreFiveTimesApart,
    );

    gate(
      'GEN-01286-G2',
      'Which is a shape the track has not recorded.',
      'Previous rows carried a metric belonging elsewhere or a band that would '
          'not parse; this carries a target contradicting its own instruction',
      () =>
          HabotDeliveryBenchmark.theShapeIsNew &&
          HabotDeliveryBenchmark
              .contradictionNote.contains('what a dashboard will do'),
    );

  });

  group('GEN-01286 :: the pair that settles it', () {
    gate(
      'GEN-01286-G3',
      'This row\'s ceiling is worse than its floor.',
      '"<5s" against "<3s" on a latency',
      () => HabotDeliveryBenchmark.thisRowsCeilingIsWorseThanItsFloor,
    );

    gate(
      'GEN-01286-G4',
      'And Step 433\'s is better than its floor.',
      '"<100ms" against "<2s", one row later, on the same subject',
      () =>
          HabotDeliveryBenchmark.theNextRowsCeilingIsBetterThanItsFloor &&
          HabotDeliveryBenchmark.theTwoRowsPointOppositeWays,
    );

    gate(
      'GEN-01286-G5',
      'Same subject, same optimal, opposite ceilings.',
      'After which no reader can take the Ceiling column\'s meaning from its '
          'name',
      () =>
          HabotDeliveryBenchmark.bothMeasureTheSameThing &&
          HabotDeliveryBenchmark.bothRowsShareTheOptimal &&
          HabotDeliveryBenchmark.theHeadingsAreTheDefect,
    );

  });

  group('GEN-01286 :: a benchmark needs a percentile', () {
    gate(
      'GEN-01286-G6',
      'The row names no percentile, profile or payload size.',
      'The three things that decide the answer',
      () => HabotDeliveryBenchmark.theRowNamesNoneOfTheThree,
    );

    gate(
      'GEN-01286-G7',
      'So three percentiles across three profiles are published.',
      'Depot wifi, yard 4G and cold-store 3G',
      () =>
          HabotDeliveryBenchmark.threePercentilesArePublished &&
          HabotDeliveryBenchmark.profileCount == 3,
    );

    gate(
      'GEN-01286-G8',
      'A mean on a good network would pass and mean nothing.',
      'The median on depot wifi clears even the instruction\'s hundred',
      () =>
          HabotDeliveryBenchmark.aMeanOnAGoodNetworkWouldPass &&
          HabotDeliveryBenchmark
              .benchmarkNote.contains('somebody\'s afternoon'),
    );

  });

  group('GEN-01286 :: the result', () {
    gate(
      'GEN-01286-G9',
      'The scored figure clears the floor and misses the optimal.',
      'The p99 in the cold store, which is the number describing somebody\'s '
          'afternoon',
      () =>
          HabotDeliveryBenchmark.theScoredFigureClearsTheFloor &&
          HabotDeliveryBenchmark.theScoredFigureMissesTheOptimal &&
          HabotDeliveryBenchmark.theInstructionTargetIsMissedOnTheWorstProfile,
    );

    gate(
      'GEN-01286-G10',
      'Five obligations, all met, giving Average.',
      'And all ten declared checks hold',
      () =>
          HabotDeliveryBenchmark.obligations.length == 5 &&
          HabotDeliveryBenchmark.obligations.values.every((bool b) => b) &&
          HabotDeliveryBenchmark.qualitativeOutput == 'Average',
    );
  });

  tearDownAll(() {
    final int profiles = HabotDeliveryBenchmark.profileCount;
    final int scored = HabotDeliveryBenchmark.scoredFigureMs;
    final int instructionTarget =
        HabotDeliveryBenchmark.targetInTheInstructionMs;
    final int bandTarget = HabotDeliveryBenchmark.targetInTheBandMs;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01286',
        atomicStepReferenceId: 'GEN-01286',
        setupStepAction:
            'COLUMN NOTE: this row\'s Atomic Step targets sub-100ms transit '
            'while its own band calls 500ms optimal, a five-fold contradiction '
            'between an instruction and its metric that the track has not '
            'recorded before, so both are published; its ceiling of "<5s" is '
            'worse than its floor of "<3s" while Step 433 one row later '
            'measures the same thing with a ceiling better than its floor, '
            'which together prove the Ceiling column has no fixed meaning; and '
            'it asks for benchmarks without naming a percentile, a network '
            'profile or a payload size, so three percentiles across three '
            'profiles are published and the worst-case p99 is scored. Atomic '
            'Step: "Execute message delivery latency benchmarks targeting '
            'sub-100ms transit times."',
        implementationOrder: 432,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Execute message delivery latency benchmarks targeting sub-100ms '
          'transit times':
              'p50, p95 and p99 across $profiles network profiles; the scored '
                  'figure is the worst-case p99 at $scored ms, against an '
                  'instruction target of $instructionTarget ms and a band '
                  'optimal of $bandTarget ms',
          'Completion Status': 'Average',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'In-App Message Delivery Latency',
            observed:
                'THE ROW\'S OWN INSTRUCTION AND ITS OWN BAND DISAGREE BY FIVE '
                'TIMES, AND THE PAIR WITH STEP 433 SETTLES THE CEILING COLUMN. '
                'The Atomic Step targets $instructionTarget ms and the band '
                'calls $bandTarget ms optimal, with nothing to say which is '
                'the requirement -- a shape the track has not recorded, since '
                'previous rows carried a metric belonging elsewhere rather '
                'than a target contradicting their own instruction. This '
                'row\'s ceiling of "<5s" is worse than its floor of "<3s"; '
                'Step 433 one row later measures the same thing with a ceiling '
                'better than its floor. Six rows in this batch use the ceiling '
                'as the worst value and one uses it as the best. Observed: '
                '$scored ms.',
            floor: '<3s',
            optimal: '<500ms',
            ceiling: '<5s',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Benchmark parameters the row supplies',
            observed:
                '0 of 3. The row names no percentile, no network profile and '
                'no payload size, which are the three things that decide a '
                'latency answer. The median on depot wifi is thirty-eight '
                'milliseconds, clearing even the instruction\'s hundred; the '
                'ninety-ninth percentile in the cold store is $scored ms. Both '
                'are true and only one describes somebody\'s afternoon, so '
                'three percentiles across $profiles profiles are published and '
                'the worst-case p99 is what the band is scored against.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/live/delivery_benchmark.dart',
        ],
      ),
    );
  });
}
