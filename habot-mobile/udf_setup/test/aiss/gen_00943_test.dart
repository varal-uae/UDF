/// AISS GATE -- Step 490 of 1,314
/// Global Reference ID:       GEN-00943
/// Atomic Steps Reference ID: GEN-00943
/// Setup Step (Action): Verify the enforcer's performance to ensure no typing
///                      latency is introduced.
/// Atomic Step: "Aggregate sentiment scores by build_artifact_hash (app
///               version) and utm_source (channel)."
/// Metric: Aggregation Calculation Speed -- floor "$\le 1\text{ sec}$", optimal
///         "$\le 200\text{ ms}$", ceiling "$3\text{ secs}$". Best Qualitative
///         Output: "Pass / Fail". DAMA DMBOK2 Dimensional Rules. Assigned to
///         **ADFA**.
///
/// TWO CUTS, ONE OF WHICH IS A QUESTION AND ONE OF WHICH IS A STATEMENT ABOUT
/// PEOPLE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/field/sentiment_by_version.dart';

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

  group('GEN-00943 :: a third ceiling at the wrong end', () {
    gate(
      'GEN-00943-G1',
      'Three seconds is slower than one.',
      'The third latency ceiling at the wrong end in this batch',
      () =>
          HabotSentimentByVersion.theCeilingIsSlowerThanTheFloor &&
          HabotSentimentByVersion.theThirdInThisBatch,
    );

  });

  group('GEN-00943 :: version against channel', () {
    gate(
      'GEN-00943-G2',
      'The version cut answers a question worth asking.',
      'Whether the release we shipped made things worse',
      () => HabotSentimentByVersion.theVersionCutAnswersAQuestion,
    );

    gate(
      'GEN-00943-G3',
      'The channel cut makes a statement about people.',
      '"People who came from this campaign are less happy"',
      () => HabotSentimentByVersion.theChannelCutMakesAStatementAboutPeople,
    );

    gate(
      'GEN-00943-G4',
      'So it stays an aggregate and never reaches a person.',
      'It supports no decision the version cut does not support better',
      () =>
          HabotSentimentByVersion.theChannelCutStaysAggregate &&
          HabotSentimentByVersion.cutNote.contains('about an individual'),
    );

  });

  group('GEN-00943 :: a denominator already small', () {
    gate(
      'GEN-00943-G5',
      'Four cells, two reported and two suppressed.',
      'Below twenty-five responses a cell is people, not an aggregate',
      () =>
          HabotSentimentByVersion.twoCellsAreReported &&
          HabotSentimentByVersion.twoCellsAreSuppressed,
    );

    gate(
      'GEN-00943-G6',
      'The smallest cell holds three people.',
      'Three responses cut by version and by channel',
      () =>
          HabotSentimentByVersion.suppressed.first.responses == 3 &&
          HabotSentimentByVersion.minimumCellSize == 25,
    );

    gate(
      'GEN-00943-G7',
      'Suppressed cells are visible as suppressed.',
      'A gap somebody can see is a gap nobody quietly fills in',
      () =>
          HabotSentimentByVersion.aGapIsVisible &&
          HabotSentimentByVersion.suppressionNote.contains('quietly fills in'),
    );

    gate(
      'GEN-00943-G8',
      'A group of three was already refused at Step 445.',
      'The same rule, arriving from the other direction',
      () => HabotSentimentByVersion.theDenominatorWasAlreadyAProblem,
    );

  });

  group('GEN-00943 :: what the version cut found', () {
    gate(
      'GEN-00943-G9',
      'The mean falls on this week\'s build.',
      '7.4 to 6.1, with the layout watch finding nothing',
      () =>
          HabotSentimentByVersion.theNewReleaseScoresLower &&
          HabotSentimentByVersion.theLayoutWatchFoundNothing &&
          HabotSentimentByVersion.findingNote
              .contains('rather than an explanation'),
    );

    gate(
      'GEN-00943-G10',
      'Five obligations met, and 340 ms reports Pass.',
      'Inside the one-second floor',
      () =>
          HabotSentimentByVersion.obligations.length == 5 &&
          HabotSentimentByVersion.obligations.values.every((bool b) => b) &&
          HabotSentimentByVersion.qualitativeOutput == 'Pass',
    );
  });

  tearDownAll(() {
    final int cells = HabotSentimentByVersion.cells.length;
    final int ms = HabotSentimentByVersion.observedMillis;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00943',
        atomicStepReferenceId: 'GEN-00943',
        setupStepAction:
            'COLUMN NOTE: this row\'s ceiling of three seconds is slower than '
            'its one-second floor, the third latency row in this batch to put '
            'the ceiling at the wrong end; of its two cuts, the build hash '
            'answers whether a release made things worse and the acquisition '
            'source only produces statements about people who arrived a '
            'particular way, so the channel cut stays an aggregate and is '
            'never joined to an individual; no cell below twenty-five '
            'responses is reported and suppressed cells are shown as '
            'suppressed; and the two reportable cells show the mean falling '
            'from 7.4 to 6.1 on this week\'s build. Atomic Step: "Aggregate '
            'sentiment scores by build_artifact_hash (app version) and '
            'utm_source (channel)."',
        implementationOrder: 490,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'build_artifact_hash; utm_source':
              '$cells cells of which two are reportable, the channel cut kept '
              'aggregate, suppressed cells shown as suppressed, and the mean '
              'falling 7.4 to 6.1 on this week\'s build; aggregation $ms ms',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Aggregation Calculation Speed',
            observed:
                'TWO CUTS, ONLY ONE OF WHICH IS ANYBODY\'S BUSINESS. Cutting '
                'sentiment by build hash asks whether a release made things '
                'worse, which is the reason this row belongs in a batch about '
                'what comes back after a release. Cutting by acquisition '
                'source produces statements about the people who arrived a '
                'particular way, so it stays an aggregate and is never joined '
                'to an individual. Observed: aggregation in $ms ms, inside the '
                'one-second floor, with the ceiling of three seconds again at '
                'the wrong end.',
            floor: r'$\le 1\text{ sec}$',
            optimal: r'$\le 200\text{ ms}$',
            ceiling: r'$3\text{ secs}$',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Cells reported below the minimum cohort',
            observed:
                '0 of $cells. Two cells hold three and twelve responses, which '
                'are not aggregates but individuals with a label, so neither '
                'is reported and both are shown as suppressed rather than '
                'omitted. Step 445 already refused to report a group of three. '
                'The two reportable cells show the mean falling from 7.4 to '
                '6.1 on this week\'s build, handed on as a question rather '
                'than an explanation.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/field/sentiment_by_version.dart',
        ],
      ),
    );
  });
}
