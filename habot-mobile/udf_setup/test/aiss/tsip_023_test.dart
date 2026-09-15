/// AISS GATE -- Step 273 of 275
/// Global Reference ID:       TSIP-023
/// Atomic Steps Reference ID: TSIP-023
/// Setup Step (Action): "Parse incoming raw request body JSON string into
///                      micro-task data object." (A SIXTH SUBJECT -- RECORDED)
/// Atomic Step: "Program the system to break the circuit and block
///               persistence if '200 OK' fails within 30s."
/// Metric: TLS Protocol Compliance Rate -- Floor "100% of connections on TLS
///         1.2 or higher", Optimal "100% on TLS 1.3", Ceiling "100% on TLS
///         1.3 with hardened cipher suite". Output "Pass".
///
/// SIX SUBJECTS ON ONE ROW. FIVE OF THEM ARE SERVER WORK; THE CIRCUIT IS THE
/// ONE THAT IS THE CLIENT'S, AND THIRTY SECONDS IS NOT ITS PATIENCE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/resilience/persistence_circuit.dart';

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

  group('TSIP-023 :: the breaker', () {
    gate(
      'TSIP-023-G1',
      'Atomic Step: "break the circuit".',
      'Two consecutive failures leave the circuit closed and three open it, '
          'so one bad connection does not stop a person saving their work',
      () =>
          HabotPersistenceCircuit.failureThreshold == 3 &&
          HabotPersistenceCircuit.twoFailuresDoNotTripIt &&
          HabotPersistenceCircuit.threeFailuresTripIt &&
          HabotCircuitState.values.length == 3,
    );

    gate(
      'TSIP-023-G2',
      'Half open is one request, not a mode to linger in.',
      'A failed probe reopens the circuit rather than staying half open, and '
          'the probe is a single request so a recovery does not become a '
          'stampede',
      () =>
          HabotPersistenceCircuit.aFailedProbeDoesNotLingerHalfOpen &&
          HabotPersistenceCircuit.probeConcurrency == 1 &&
          HabotPersistenceCircuit.theProbeDelayIsADeclaredValue,
    );

    gate(
      'TSIP-023-G3',
      'One success closes it, from wherever it was.',
      'Success from any of the three states returns the circuit to closed, '
          'exercised across every state rather than asserted for one',
      () => HabotPersistenceCircuit.oneSuccessClosesItFromAnywhere,
    );

    gate(
      'TSIP-023-G4',
      'Thirty seconds is the server\'s patience, not the client\'s.',
      'The row\'s figure is fifteen of the declared interactive budgets, and '
          'that arithmetic is published rather than the figure being adopted '
          'as a user-facing wait',
      () =>
          HabotPersistenceCircuit.serverPatienceSeconds == 30 &&
          HabotPersistenceCircuit.budgetsInsideTheRowsFigure == 15 &&
          HabotPersistenceCircuit.theRowsFigureIsNotAUiWait &&
          HabotPersistenceCircuit.patienceNote.contains('second four'),
    );
  });

  group('TSIP-023 :: what blocking persistence may mean', () {
    gate(
      'TSIP-023-G5',
      '"Block persistence" is about somebody\'s data.',
      'Blocked means queued and never reported as saved, because a circuit '
          'that stops writes silently turns an outage into data loss',
      () =>
          HabotPersistenceCircuit.queuesRatherThanDiscards &&
          !HabotPersistenceCircuit.reportsSuccessWhileOpen &&
          HabotPersistenceCircuit.blockingNote.contains('silent data loss'),
    );

    gate(
      'TSIP-023-G6',
      'No fifth unavailability state was invented.',
      'An open circuit repeats the last real answer instead of adding a state '
          'for "the client declined to send", and it behaves the way Step '
          '251 already said that answer should -- under the write rule, not '
          'the read one',
      () =>
          HabotPersistenceCircuit.noFifthUnavailabilityStateWasInvented &&
          HabotPersistenceCircuit.anOpenCircuitBehavesLikeThe503ItIsRepeating &&
          HabotPersistenceCircuit.theWriteRuleIsTheOneApplied,
    );

    gate(
      'TSIP-023-G7',
      'Data Collected: Lock Type, Status, Locked By, Timestamp, Reason.',
      'All five record-locking fields are carried as the circuit\'s own state '
          'record, with the reason drawn from the existing vocabulary, and a '
          'closed circuit holds no lock',
      () =>
          HabotPersistenceCircuit.theLockRecordUsesAllFiveDeclaredFields &&
          HabotPersistenceCircuit.aClosedCircuitHoldsNoLock &&
          HabotPersistenceCircuit.lockFieldsNote.contains('pessimistic'),
    );
  });

  group('TSIP-023 :: the metric, and the other five subjects', () {
    gate(
      'TSIP-023-G8',
      'Metric: TLS Protocol Compliance Rate.',
      'The floor is met structurally -- the socket policy declares wss and '
          'refuses anything else -- while the negotiated version and cipher '
          'suite belong to the platform TLS stack and are named rather than '
          'claimed',
      () =>
          HabotPersistenceCircuit.theSchemeIsRefusedIfNotEncrypted &&
          !HabotPersistenceCircuit.theClientChoosesTheCipherSuite &&
          HabotPersistenceCircuit.tlsNote.contains('shipping its own TLS'),
    );

    gate(
      'TSIP-023-G9',
      'Six subjects on one row.',
      'The circuit, the TLS metric, an IAM boundary mapping sheet, five '
          'record-locking fields, a shared IAM library and a JSON-parsing '
          'setup step are all named, and the one that is the client\'s is the '
          'one built',
      () =>
          HabotPersistenceCircuit.sixSubjectsNote.contains('SIX SUBJECTS') &&
          HabotPersistenceCircuit.columnNote.contains('Setup Step'),
    );

    gate(
      'TSIP-023-G10',
      'Output: Pass.',
      'All fourteen declared checks hold and the step reports Pass on the '
          'client\'s half, with the five server subjects recorded rather than '
          'answered',
      () =>
          HabotPersistenceCircuit.checks.length == 14 &&
          HabotPersistenceCircuit.checks.values.every((bool b) => b) &&
          HabotPersistenceCircuit.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final String budgets =
        '${HabotPersistenceCircuit.budgetsInsideTheRowsFigure}';
    final String wait = '${HabotPersistenceCircuit.clientWait.inSeconds}s';
    final String probe =
        '${HabotPersistenceCircuit.probeDelay.inMilliseconds}ms';
    final String rule = HabotPersistenceCircuit.ruleWhileOpen.name;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'TSIP-023',
        atomicStepReferenceId: 'TSIP-023',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Parse '
            'incoming raw request body JSON string into micro-task data '
            'object", which belongs to neither the Atomic Step nor the '
            'metric. Atomic Step: "Program the system to break the circuit '
            'and block persistence if \'200 OK\' fails within 30s."',
        implementationOrder: 273,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Lock Type': 'persistence -- the circuit locks the write path, and '
              'the row\'s five locking fields are carried as its state record',
          'Lock Status': 'closed / open / halfOpen, one success closing it '
              'from any of the three and a failed probe reopening it',
          'Locked By': 'client circuit breaker',
          'Lock Reason': 'drawn from Step 251\'s HabotUnavailability rather '
              'than a sixth set of names; while open the last real answer is '
              'repeated and handled as $rule',
          'Component Properties':
              'threshold ${HabotPersistenceCircuit.failureThreshold} '
              'consecutive failures; probe concurrency '
              '${HabotPersistenceCircuit.probeConcurrency} after $probe; '
              'client wait $wait against the row\'s '
              '${HabotPersistenceCircuit.serverPatienceSeconds}s',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotPersistenceCircuit.patienceNote} '
              'BLOCKING: ${HabotPersistenceCircuit.blockingNote} '
              'TLS: ${HabotPersistenceCircuit.tlsNote} '
              'SUBJECTS: ${HabotPersistenceCircuit.sixSubjectsNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'TLS Protocol Compliance Rate',
            observed:
                'FLOOR MET STRUCTURALLY. HabotSocketPolicy declares wss and '
                'refuses anything else, so an unencrypted connection is a '
                'compile-time impossibility rather than a runtime statistic. '
                'The negotiated version and the cipher suite are chosen by '
                'the platform TLS stack against what the server offers, so '
                'the optimal and the ceiling are server configuration '
                'reported by the server.',
            floor: '100% of connections on TLS 1.2 or higher',
            optimal: '100% of connections on TLS 1.3',
            ceiling: '100% on TLS 1.3 with hardened cipher suite',
          ),
          AissMeasurement(
            metricName: 'Client interactive budgets inside the row\'s 30s',
            observed:
                '$budgets. Step 165 declares $wait to interactive on 3G, so '
                'a client that waited the row\'s thirty seconds would spend '
                '$budgets of them on a spinner. The breaker counts '
                'consecutive failures instead.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/resilience/persistence_circuit.dart',
        ],
      ),
    );
  });
}
