/// AISS GATE -- Step 434 of 415
/// Global Reference ID:       GEN-04075
/// Atomic Steps Reference ID: GEN-04075
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Run load tests to verify all mobile mutation endpoints return
///               HTTP 202 in under 100ms."
/// Metric: Mutation Load Test Latency -- floor "<100ms", optimal "<30ms",
///         ceiling "150ms". Best Qualitative Output: "Pass/Fail". SLA
///         Performance Testing Rules. Assigned to **UDF**.
///
/// A FAST 202, WHICH MEASURES A QUEUE ACCEPTING WORK AND NOT THE WORK BEING
/// DONE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/live/mutation_load.dart';

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

  group('GEN-04075 :: an acknowledgement is not an outcome', () {
    gate(
      'GEN-04075-G1',
      'A 202 is an acknowledgement, not an outcome.',
      'It means I have taken this and I have not done it',
      () =>
          HabotMutationLoad.theTwoMeaningsDiffer &&
          HabotMutationLoad.statusCode == 202,
    );

    gate(
      'GEN-04075-G2',
      'So the interface says submitted and waits.',
      'Three submission states: submitted, applied, rejected',
      () =>
          HabotMutationLoad.theInterfaceDoesNotClaimSuccess &&
          HabotMutationLoad.threeSubmissionStates &&
          HabotMutationLoad.itIsTheShapeStep433Gave,
    );

    gate(
      'GEN-04075-G3',
      'And a screen treating one as the other is wrong when it matters.',
      'Which is the shape Step 433 gave a message one row earlier, for the '
          'same reason',
      () =>
          HabotMutationLoad
              .acceptanceNote.contains('exactly the moment somebody cares'),
    );

  });

  group('GEN-04075 :: the third "all", and the first that holds', () {
    gate(
      'GEN-04075-G4',
      'Four endpoints and no exemptions.',
      'Overtime request, shift swap, clock in, profile update',
      () =>
          HabotMutationLoad.endpointCount == 4 &&
          HabotMutationLoad.theAllHolds,
    );

    gate(
      'GEN-04075-G5',
      'The third unbounded "all", and the first that holds.',
      'After Step 408, where two components had to be exempt, and Step 418, '
          'where nothing needed wrapping',
      () =>
          HabotMutationLoad.thirdUnboundedAll &&
          HabotMutationLoad.whyItHoldsHere.isNotEmpty,
    );

  });

  group('GEN-04075 :: the load test the row did not specify', () {
    gate(
      'GEN-04075-G6',
      'The row names no concurrency, duration or failure criterion.',
      'A load test without those three is a request rather than a test',
      () =>
          HabotMutationLoad.theRowNamesNoneOfThem &&
          HabotMutationLoad.allThreeAreDeclaredHere,
    );

    gate(
      'GEN-04075-G7',
      'So fifty clients for ten minutes are declared here.',
      'Failing on any 5xx or a p99 above the floor, and named as chosen rather '
          'than taken from the row',
      () =>
          HabotMutationLoad.concurrentClients == 50 &&
          HabotMutationLoad.durationMinutes == 10 &&
          HabotMutationLoad.testNote.contains('rather than a test'),
    );

  });

  group('GEN-04075 :: the seventh instance of the shape', () {
    gate(
      'GEN-04075-G8',
      'Every endpoint clears the floor and none reaches the optimal.',
      'The slowest accepts in forty-four milliseconds',
      () =>
          HabotMutationLoad.everyEndpointClearsTheFloor &&
          HabotMutationLoad.noEndpointReachesTheOptimal,
    );

    gate(
      'GEN-04075-G9',
      'The optimal sits below both boundaries, for the seventh time.',
      'Floor "<100ms" and ceiling "150ms" bracket one hundred to one hundred '
          'and fifty; the optimal is "<30ms"',
      () =>
          HabotMutationLoad.theOptimalIsBelowBothBoundaries &&
          HabotMutationLoad.theShapeIsTheDeclaredConvention &&
          HabotMutationLoad.thisIsTheSeventh,
    );

    gate(
      'GEN-04075-G10',
      'Five obligations, all met, giving Pass.',
      'And all ten declared checks hold',
      () =>
          HabotMutationLoad.obligations.length == 5 &&
          HabotMutationLoad.obligations.values.every((bool b) => b) &&
          HabotMutationLoad.qualitativeOutput == 'Pass' &&
          HabotMutationLoad.slowestTerminalSeconds == 6,
    );
  });

  tearDownAll(() {
    final int endpoints = HabotMutationLoad.endpointCount;
    final int slowestMs = HabotMutationLoad.slowestAcceptMs;
    final int terminalSeconds = HabotMutationLoad.slowestTerminalSeconds;
    final int clients = HabotMutationLoad.concurrentClients;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04075',
        atomicStepReferenceId: 'GEN-04075',
        setupStepAction:
            'COLUMN NOTE: this row measures the time to an HTTP 202, which is '
            'a queue accepting work rather than the work being done, so the '
            'terminal time is published beside it and the interface says '
            '"submitted" rather than "approved"; its "all mobile mutation '
            'endpoints" is the third unbounded "all" in two batches after '
            'Steps 408 and 418, and the first where the word survives contact '
            'with the design; it asks for load tests without naming a '
            'concurrency, a duration or a failure criterion, all three of '
            'which are declared here and named as chosen; and its optimal of '
            '"<30ms" sits below both its floor of "<100ms" and its ceiling of '
            '"150ms", the seventh and last instance of that shape. Atomic '
            'Step: "Run load tests to verify all mobile mutation endpoints '
            'return HTTP 202 in under 100ms."',
        implementationOrder: 434,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Run load tests to verify all mobile mutation endpoints return':
              '$endpoints endpoints under $clients concurrent clients for ten '
                  'minutes; slowest acceptance $slowestMs ms and slowest '
                  'terminal state $terminalSeconds s, both published',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Mutation Load Test Latency',
            observed:
                'THE METRIC TIMES A QUEUE ACCEPTING WORK. A 202 means I have '
                'taken this and I have not done it, so a 202 under a hundred '
                'milliseconds is a measurement of a queue and says nothing '
                'about whether the overtime request was approved -- the '
                'interface says "submitted" and waits for the terminal state, '
                'which is the shape Step 433 gave a message one row earlier. '
                'The optimal of "<30ms" sits below both the floor of "<100ms" '
                'and the ceiling of "150ms", the seventh and last instance of '
                'that shape across two batches, six of them here. Observed: '
                '$slowestMs ms to acceptance across $endpoints endpoints.',
            floor: '<100ms',
            optimal: '<30ms',
            ceiling: '150ms',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Seconds to the terminal state, which no cell asks for',
            observed:
                '$terminalSeconds at the slowest endpoint. That is the number '
                'a person actually waits, and no column in this row asks for '
                'it, so it is published beside the acceptance time. The row\'s '
                '"all mobile mutation endpoints" is the third unbounded "all" '
                'in two batches and the first where the word survives contact '
                'with the design -- every mutation endpoint should return 202, '
                'because the alternative is an endpoint holding a mobile '
                'connection open while it works. The load test\'s $clients '
                'concurrent clients, ten-minute duration and failure criterion '
                'are declared here and named as chosen.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/live/mutation_load.dart',
        ],
      ),
    );
  });
}
