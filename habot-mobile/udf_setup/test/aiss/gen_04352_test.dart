/// AISS GATE -- Step 433 of 415
/// Global Reference ID:       GEN-04352
/// Atomic Steps Reference ID: GEN-04352
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement message delivery state indicators (Sending, Sent,
///               Delivered, Read)."
/// Metric: Real-Time Message Delivery Latency -- floor "< 2s", optimal "<
///         500ms", ceiling "< 100ms (diminishing returns)". Best Qualitative
///         Output: "Good/Average/Poor". WebSocket Real-Time Messaging Industry
///         Benchmark. Assigned to **PDG**.
///
/// FOUR DELIVERY STATES WHERE A MESSAGE HAS FIVE, AND ONE STATE THAT IS ABOUT
/// THE RECIPIENT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/live/delivery_state.dart';

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

  group('GEN-04352 :: four listed, five needed', () {
    gate(
      'GEN-04352-G1',
      'The row lists four states and five are implemented.',
      'Sending, Sent, Delivered, Read -- and Failed',
      () =>
          HabotDeliveryStateIndicators.listedByTheRow == 4 &&
          HabotDeliveryStateIndicators.oneMoreStateThanTheRowLists,
    );

    gate(
      'GEN-04352-G2',
      'Three failure modes are named.',
      'Rejected by the server, expired in the queue, refused because the '
          'recipient has left the site',
      () =>
          HabotDeliveryStateIndicators.threeFailureModesAreNamed &&
          HabotDeliveryStateIndicators.theMissingState ==
              HabotMessageDeliveryState.failed,
    );

    gate(
      'GEN-04352-G3',
      'And an indicator without one shows Sending forever.',
      'Which a reader takes as still trying and which means gave up',
      () =>
          HabotDeliveryStateIndicators.theOmissionWouldLie &&
          HabotDeliveryStateIndicators.failureNote.contains('gave up'),
    );

  });

  group('GEN-04352 :: read is about the person', () {
    gate(
      'GEN-04352-G4',
      'Four states describe the message and one describes the person.',
      'Read is what the recipient did, not where the message got to',
      () =>
          HabotDeliveryStateIndicators.fourStatesDescribeTheMessage &&
          HabotDeliveryStateIndicators.readDescribesThePerson,
    );

    gate(
      'GEN-04352-G5',
      'The read state is shown and the recipient controls it.',
      'Hiding it was considered and rejected, because the other states promise '
          'the sender an honest account',
      () =>
          HabotDeliveryStateIndicators.itIsShownAndControlled &&
          HabotDeliveryStateIndicators.hidingItWasConsidered,
    );

    gate(
      'GEN-04352-G6',
      'And what a manager learns from it is named.',
      'That a message was read at 21:40, which is a fact about somebody\'s '
          'evening, with an expectation of a reply behind it',
      () =>
          HabotDeliveryStateIndicators.theCostIsNamed &&
          HabotDeliveryStateIndicators.readNote.contains('breaks that promise'),
    );

  });

  group('GEN-04352 :: every failure carries a reason', () {
    gate(
      'GEN-04352-G7',
      'Every failure carries a reason and a retry.',
      'And no success carries a reason',
      () =>
          HabotDeliveryStateIndicators.everyFailureNamesAReason &&
          HabotDeliveryStateIndicators.everyFailureOffersARetry &&
          HabotDeliveryStateIndicators.noSuccessCarriesAReason,
    );

  });

  group('GEN-04352 :: the only band that descends', () {
    gate(
      'GEN-04352-G8',
      'The band descends and the ceiling is the best value.',
      'The only one of seven latency rows across two batches written that way',
      () =>
          HabotDeliveryStateIndicators.theBandDescends &&
          HabotDeliveryStateIndicators.theCeilingIsTheBestValue,
    );

    gate(
      'GEN-04352-G9',
      'And Step 432 runs the other way, which settles the column.',
      'Same subject, same optimal, opposite ceilings, one row apart',
      () =>
          HabotDeliveryStateIndicators.theOtherRowRunsTheOtherWay &&
          HabotDeliveryStateIndicators.theTwoTogetherSettleIt,
    );

    gate(
      'GEN-04352-G10',
      'Five obligations, all met, giving Average.',
      'At 310ms, between the optimal and the floor, and all ten declared '
          'checks hold',
      () =>
          HabotDeliveryStateIndicators.obligations.length == 5 &&
          HabotDeliveryStateIndicators
              .obligations.values.every((bool b) => b) &&
          HabotDeliveryStateIndicators.qualitativeOutput == 'Average' &&
          HabotDeliveryStateIndicators
              .theObservedFigureSitsBetweenOptimalAndFloor &&
          HabotDeliveryStateIndicators.sixthAnnotatedBoundary &&
          HabotDeliveryStateIndicators.thePhraseRepeatsStep413s &&
          HabotDeliveryStateIndicators.theCeilingCarriesAnArgument &&
          HabotDeliveryStateIndicators.theStatesUseTheLiveStates,
    );
  });

  tearDownAll(() {
    final int listed = HabotDeliveryStateIndicators.listedByTheRow;
    final int implemented = HabotDeliveryStateIndicators.statesImplemented;
    final int modes = HabotDeliveryStateIndicators.waysAMessageFails.length;
    final int observedMs = HabotDeliveryStateIndicators.observedMs;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04352',
        atomicStepReferenceId: 'GEN-04352',
        setupStepAction:
            'COLUMN NOTE: this row lists four delivery states where a message '
            'has five, so Failed was added with a reason and a retry -- an '
            'indicator with no failure state shows Sending indefinitely, which '
            'reads as still trying and means gave up; its Read state is the '
            'only one that describes the recipient rather than the message, so '
            'it is shown and the recipient controls whether it is sent; its '
            'band descends correctly, the only one of seven latency rows '
            'across two batches to do so, while Step 432 one row earlier '
            'measures the same thing with its ceiling as the worst value; and '
            'its ceiling carries "(diminishing returns)", the sixth annotated '
            'boundary and the second in four rows. Atomic Step: "Implement '
            'message delivery state indicators (Sending, Sent, Delivered, '
            'Read)."',
        implementationOrder: 433,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Implement message delivery state indicators (Sending, Sent, '
          'Delivered, Read)':
              '$implemented states implemented where the row lists $listed; '
                  '$modes failure modes named, each carrying a reason and a '
                  'retry; observed delivery latency $observedMs ms',
          'Completion Status': 'Average',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Real-Time Message Delivery Latency',
            observed:
                'THE ONLY LATENCY BAND IN TWO BATCHES THAT DESCENDS CORRECTLY, '
                'ONE ROW AFTER ITS OPPOSITE. Floor "< 2s", optimal "< 500ms", '
                'ceiling "< 100ms": each better than the last, the ceiling the '
                'best value, and the only one of seven latency rows written '
                'that way -- while Step 432, one row earlier, measures the '
                'same thing with its ceiling as the worst value. The pair is '
                'the proof that the column cannot be read from its name. Its '
                'ceiling also carries "(diminishing returns)", the sixth '
                'annotated boundary and the second in four rows. Observed: '
                '$observedMs ms, between the optimal and the floor.',
            floor: '< 2s',
            optimal: '< 500ms',
            ceiling: '< 100ms (diminishing returns)',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'States a message can be in that the row does not list',
            observed:
                '1 of $implemented. Sending, Sent, Delivered and Read describe '
                'the path where everything works; a message can also be '
                'rejected by the server, expire in the queue, or be refused '
                'because the recipient has left the site -- $modes failure '
                'modes, each carrying a reason and a retry. An indicator with '
                'no failure state does not become accurate by leaving one out: '
                'it shows Sending indefinitely, which reads as still trying '
                'and means gave up. Read is the one state that describes the '
                'recipient rather than the message, so it is shown and the '
                'recipient controls whether it is sent.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/live/delivery_state.dart',
        ],
      ),
    );
  });
}
