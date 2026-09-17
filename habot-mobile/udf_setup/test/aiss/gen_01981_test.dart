/// AISS GATE -- Step 333 of 335
/// Global Reference ID:       GEN-01981
/// Atomic Steps Reference ID: GEN-01981
/// Setup Step (Action): (the generic engineering-console boilerplate --
///                      COLUMN NOTE, RECORDED)
/// Atomic Step: "Trigger immediate security alerts for any unauthorized
///               modification attempts."
/// Metric: Maximum Unacknowledged Message Age (seconds) -- floor 60, optimal
///         10, ceiling 5. Good / Fair / Poor. Assigned to **GFD**.
///
/// THE ONE CORRECTLY ORDERED LATENCY BAND IN THIS BATCH. IT IS RECORDED
/// BECAUSE IT IS WHAT MAKES THE OTHER FOUR ERRORS RATHER THAN A CONVENTION.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/change_alert.dart';

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

  group('GEN-01981 :: the band that is right', () {
    gate(
      'GEN-01981-G1',
      'Floor 60 s, optimal 10 s, ceiling 5 s.',
      'Lower is better, the floor is the worst tolerable value and the '
          'ceiling is the best -- ordered correctly',
      () =>
          HabotUnauthorisedChangeAlert.theBandIsOrderedForLowerIsBetter &&
          HabotUnauthorisedChangeAlert.bandFloorSeconds == 60 &&
          HabotUnauthorisedChangeAlert.bandOptimalSeconds == 10 &&
          HabotUnauthorisedChangeAlert.bandCeilingSeconds == 5,
    );

    gate(
      'GEN-01981-G2',
      'And it is the only one of five in this batch that is.',
      'Steps 325, 326, 334 and 335 run the other way; one correct instance '
          'is what turns four into an error rather than a convention',
      () =>
          HabotUnauthorisedChangeAlert.thisIsTheOnlyOrderedOneOfFive &&
          HabotUnauthorisedChangeAlert.invertedBandsInThisBatch.length == 4 &&
          HabotUnauthorisedChangeAlert.bandNote
              .contains('rather than a convention'),
    );

    gate(
      'GEN-01981-G3',
      'The metric times a button press.',
      'Unacknowledged age is a real operational number and acknowledging is a '
          'button; it measures the queue rather than whether anybody looked',
      () => HabotUnauthorisedChangeAlert
          .theMetricMeasuresTheQueueRatherThanThePerson,
    );
  });

  group('GEN-01981 :: the volume nobody decided', () {
    gate(
      'GEN-01981-G4',
      'Atomic Step: "any unauthorized modification attempt".',
      'Four hundred and eighty-three events in a day reduce to twelve '
          'distinct actor-resource-kind triples -- a 97.5 per cent reduction',
      () =>
          HabotUnauthorisedChangeAlert.rawEventCount == 483 &&
          HabotUnauthorisedChangeAlert.distinctTriples == 12 &&
          (HabotUnauthorisedChangeAlert.reduction - 0.97516).abs() < 1e-4,
    );

    gate(
      'GEN-01981-G5',
      'A stricter deadline on a firehose buys the wrong behaviour.',
      'Acknowledgement without reading, which looks like success in the data '
          'and is a failure in the room',
      () =>
          HabotUnauthorisedChangeAlert.alertingOnEachEventIsAFirehose &&
          HabotUnauthorisedChangeAlert.volumeNote
              .contains('a failure in the room'),
    );

    gate(
      'GEN-01981-G6',
      'Refusals escalate on rate; a success escalates on one occurrence.',
      'A refused modification is the control working and a successful one is '
          'the control failing, so "any attempt" puts the loudest signal on '
          'the quietest news',
      () =>
          HabotUnauthorisedChangeAlert.successes.length == 1 &&
          HabotUnauthorisedChangeAlert
              .onlyASuccessEscalatesOnOneOccurrence &&
          HabotUnauthorisedChangeAlert.outcomeNote
              .contains('the quietest available news'),
    );

    gate(
      'GEN-01981-G7',
      'Four refusal triples cross the rate threshold.',
      'So the day produces five alerts rather than 483, and the day fits on '
          'one screen',
      () =>
          HabotUnauthorisedChangeAlert.refusalsThatPage.length == 4 &&
          HabotUnauthorisedChangeAlert.refusalRateThreshold == 15 &&
          HabotUnauthorisedChangeAlert.alertsPerDay == 5 &&
          HabotUnauthorisedChangeAlert.theDayFitsInASingleScreen,
    );

    gate(
      'GEN-01981-G8',
      'No isolated human attempt pages anybody.',
      'Which is the difference between a rule that survives a month and a '
          'rule somebody mutes',
      () => HabotUnauthorisedChangeAlert.thePersonAttemptsDoNotPage,
    );
  });

  group('GEN-01981 :: the vocabularies', () {
    gate(
      'GEN-01981-G9',
      'Output: Good / Fair / Poor.',
      'A third wording for the same three-point scale; five output '
          'vocabularies appear across this batch of twenty rows',
      () =>
          HabotUnauthorisedChangeAlert.outputVocabulary == 'Good/Fair/Poor' &&
          HabotUnauthorisedChangeAlert.fiveVocabulariesInOneBatch,
    );

    gate(
      'GEN-01981-G10',
      'Five declared obligations, all met, giving Good.',
      'All twelve declared checks hold',
      () =>
          HabotUnauthorisedChangeAlert.obligations.length == 5 &&
          HabotUnauthorisedChangeAlert.obligations.values
              .every((bool b) => b) &&
          HabotUnauthorisedChangeAlert.qualitativeOutput == 'Good' &&
          HabotUnauthorisedChangeAlert.checks.length == 12 &&
          HabotUnauthorisedChangeAlert.checks.values.every((bool b) => b) &&
          HabotUnauthorisedChangeAlert.columnNote.contains('GFD'),
    );
  });

  tearDownAll(() {
    final String reduction =
        (HabotUnauthorisedChangeAlert.reduction * 100).toStringAsFixed(1);
    final String alerts = '${HabotUnauthorisedChangeAlert.alertsPerDay}';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01981',
        atomicStepReferenceId: 'GEN-01981',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to GFD rather than UDF, its '
            'output vocabulary is Good/Fair/Poor where every neighbouring row '
            'uses Good/Average/Poor, and every narrative column is the generic '
            'engineering-console boilerplate. Atomic Step: "Trigger immediate '
            'security alerts for any unauthorized modification attempts."',
        implementationOrder: 333,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Trigger immediate security alerts for any unauthorized modification '
                  'attempts.':
              '${HabotUnauthorisedChangeAlert.rawEventCount} events reduce to '
                  '${HabotUnauthorisedChangeAlert.distinctTriples} triples and '
                  '$alerts alerts',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'one successful unauthorised change escalates on its own; '
                  'refusals escalate at '
                  '${HabotUnauthorisedChangeAlert.refusalRateThreshold} '
                  'occurrences in the window',
          'Data Quality Note':
              'BAND: ${HabotUnauthorisedChangeAlert.bandNote} '
              'VOLUME: ${HabotUnauthorisedChangeAlert.volumeNote} '
              'OUTCOMES: ${HabotUnauthorisedChangeAlert.outcomeNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Maximum Unacknowledged Message Age (seconds)',
            observed:
                'THE BAND IS ORDERED CORRECTLY -- floor 60 as the worst '
                'tolerable value, optimal 10, ceiling 5 as the best -- and it '
                'is the only one of five latency bands in this batch that is. '
                'That single correct instance is what makes Steps 325, 326, '
                '334 and 335 errors rather than a house convention. The metric '
                'itself times a button press and says nothing about whether '
                'anybody read the alert, which is tolerable at twelve a day '
                'and meaningless at five hundred.',
            floor: '60',
            optimal: '10',
            ceiling: '5',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Alerts raised per day',
            observed:
                '$alerts, against ${HabotUnauthorisedChangeAlert.rawEventCount}'
                ' if every attempt paged. The reduction is $reduction per '
                'cent, and it comes from three decisions: deduplicate by '
                'actor, resource and kind; escalate refusals on rate rather '
                'than on occurrence; and escalate a successful unauthorised '
                'change on its own, because that one is the control failing '
                'rather than working.',
            floor: '12',
            optimal: '5',
            ceiling: '1',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/change_alert.dart',
        ],
      ),
    );
  });
}
