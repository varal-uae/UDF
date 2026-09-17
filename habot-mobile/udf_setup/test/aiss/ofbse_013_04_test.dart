/// AISS GATE -- Step 367 of 375
/// Global Reference ID:       OFBSE-013-04
/// Atomic Steps Reference ID: OFBSE-013-04
/// Setup Step (Action): "Document the finalized progressive loading
///                      configuration."
/// Atomic Step: "Isolate views serving historical metric charts or
///               non-realtime dashboard summaries."
/// Metric: Monitoring Coverage & Alert Latency -- floor "95% cov. / <15 min",
///         optimal "99% cov. / <5 min", ceiling "100% cov. / <1 min". High
///         (High/Medium/Low). Google SRE Book. Assigned to **DEA**.
///
/// TWO MEASURES IN EVERY BOUNDARY CELL, AND A READING THAT SATISFIES HALF OF
/// EACH.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/charts/historical_view_isolation.dart';

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

  group('OFBSE-013-04 :: a compound band', () {
    gate(
      'OFBSE-013-04-G1',
      'Each boundary cell holds two measures joined by a slash.',
      'A coverage percentage and a latency, with different units and different '
          'failure modes -- a shape this track has not met before',
      () => HabotHistoricalViewIsolation.eachCellHoldsTwoMeasures,
    );

    gate(
      'OFBSE-013-04-G2',
      'Split apart, both halves are well formed.',
      '95/99/100 rising and 15/5/1 falling, which is an argument for splitting '
          'rather than for discarding',
      () =>
          HabotHistoricalViewIsolation.bothHalvesAreWellFormed &&
          HabotHistoricalViewIsolation.coverageBand.length == 3 &&
          HabotHistoricalViewIsolation.latencyBandMinutes.length == 3,
    );

    gate(
      'OFBSE-013-04-G3',
      '99 per cent coverage at twelve minutes satisfies half of each.',
      'Above the coverage optimal and below the latency floor, and the cell '
          'has no way to say which verdict wins',
      () =>
          HabotHistoricalViewIsolation.oneReadingSatisfiesHalfOfEachBoundary &&
          HabotHistoricalViewIsolation.bandNote
              .contains('which verdict wins'),
    );
  });

  group('OFBSE-013-04 :: different promises, not different renderers', () {
    gate(
      'OFBSE-013-04-G4',
      'Three view kinds, each promising something different.',
      'Live says how old it is, historical says what period it covers, and the '
          'third says the period has not finished',
      () =>
          HabotViewKind.values.length == 3 &&
          HabotHistoricalViewIsolation.everyKindMakesADifferentPromise,
    );

    gate(
      'OFBSE-013-04-G5',
      'The row names two of the three.',
      'Today\'s figures are historical in form and live in fact, so a reader '
          'is told the last bar will grow',
      () =>
          HabotHistoricalViewIsolation.theRowNamesTwoOfThree &&
          HabotHistoricalViewIsolation.openPeriodNote.contains('will grow'),
    );

    gate(
      'OFBSE-013-04-G6',
      'The right instruction for the wrong reason.',
      'The separation exists because a chart redrawing under somebody reading '
          'a closed period is the failure, not because a renderer needs relief',
      () => HabotHistoricalViewIsolation.promiseNote.contains('wrong reason'),
    );
  });

  group('OFBSE-013-04 :: isolation enforced rather than intended', () {
    gate(
      'OFBSE-013-04-G7',
      'Two historical views, neither subscribing to the live stream.',
      'A historical view that quietly subscribes is invisible until somebody '
          'watches a number change on a closed month',
      () =>
          HabotHistoricalViewIsolation.historicalViews == 2 &&
          HabotHistoricalViewIsolation.noHistoricalViewSubscribes,
    );

    gate(
      'OFBSE-013-04-G8',
      'The subscription is a property of the kind, not of the screen.',
      'So a new historical view cannot get it wrong',
      () =>
          HabotHistoricalViewIsolation.everySubscriptionFollowsTheKind &&
          !HabotHistoricalViewIsolation.eachScreenDecidesItsOwnSubscription &&
          HabotHistoricalViewIsolation.enforcementNote
              .contains('cannot get it wrong'),
    );
  });

  group('OFBSE-013-04 :: the age label and the output', () {
    gate(
      'OFBSE-013-04-G9',
      'A live view carries its age from the Step 129 policy.',
      'A historical view carries its period instead, because "37 minutes old" '
          'is meaningless on last quarter\'s incidents',
      () =>
          HabotHistoricalViewIsolation.theLiveViewLabelsItsAge &&
          HabotHistoricalViewIsolation.ageNote.contains('Step 129') &&
          !HabotHistoricalViewIsolation.labelsItsAge(
            HabotHistoricalViewIsolation.views[1],
          ),
    );

    gate(
      'OFBSE-013-04-G10',
      'Output reported on a High / Medium / Low scale.',
      'Five obligations, all met, giving High; all ten declared checks hold',
      () =>
          HabotHistoricalViewIsolation.obligations.length == 5 &&
          HabotHistoricalViewIsolation.obligations.values
              .every((bool b) => b) &&
          HabotHistoricalViewIsolation.qualitativeOutput == 'High' &&
          HabotHistoricalViewIsolation.checks.length == 10 &&
          HabotHistoricalViewIsolation.checks.values.every((bool b) => b) &&
          HabotHistoricalViewIsolation.columnNote.contains('DEA'),
    );
  });

  tearDownAll(() {
    final int views = HabotHistoricalViewIsolation.views.length;
    final int historical = HabotHistoricalViewIsolation.historicalViews;
    final int coverage = HabotHistoricalViewIsolation.splitReadingCoverage;
    final int latency =
        HabotHistoricalViewIsolation.splitReadingLatencyMinutes;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'OFBSE-013-04',
        atomicStepReferenceId: 'OFBSE-013-04',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to DEA rather than UDF, and '
            'each of its three boundary cells holds two measures joined by a '
            'slash -- a coverage percentage and a latency -- so a reading can '
            'satisfy half a boundary; its Data Requirement column is about '
            'non-blocking snackbars and carries CSS and ARIA attributes; and '
            'its Setup Step column reads "Document the finalized progressive '
            'loading configuration". Atomic Step: "Isolate views serving '
            'historical metric charts or non-realtime dashboard summaries."',
        implementationOrder: 367,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Layout Type': 'three isolated view kinds over one chart surface',
          'Layout Grid Dimensions': 'single column at compact width',
          'Spacing Rules': 'the declared spacing scale',
          'Alignment Settings': 'period or age label leading the view',
          'Layout Validation Status': 'High',
          'Completion Status': 'High',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              '$views worked views, $historical of them historical and none '
                  'of those subscribing to the live stream',
          'Data Quality Note':
              'BAND: ${HabotHistoricalViewIsolation.bandNote} '
              'PROMISE: ${HabotHistoricalViewIsolation.promiseNote} '
              'OPEN PERIOD: ${HabotHistoricalViewIsolation.openPeriodNote} '
              'ENFORCEMENT: ${HabotHistoricalViewIsolation.enforcementNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Monitoring Coverage & Alert Latency',
            observed:
                'TWO MEASURES IN EVERY CELL, WHICH IS A NEW SHAPE. Each '
                'boundary joins a coverage percentage to an alert latency with '
                'a slash. They have different units and different failure '
                'modes, so a reading can satisfy half a boundary: $coverage '
                'per cent coverage at $latency minutes clears the coverage '
                'optimal and misses the latency floor, and the cell cannot say '
                'which verdict wins. Split apart they are two well-formed '
                'bands, one higher-is-better and one lower-is-better, which is '
                'an argument for splitting rather than for discarding.',
            floor: '95% cov. / <15 min',
            optimal: '99% cov. / <5 min',
            ceiling: '100% cov. / <1 min',
          ),
          AissMeasurement(
            metricName: 'Historical views that can move under a reader',
            observed:
                '0 of $historical. Live and historical views are separated not '
                'to protect a renderer but because they promise different '
                'things: one says how old it is and refreshes, the other says '
                'what period it covers and does not move. A third kind is '
                'needed for a period that has not finished, which the row does '
                'not name -- today\'s figures are historical in form and live '
                'in fact. The live subscription is a property of the view kind '
                'rather than a decision each screen makes, so isolation here '
                'is enforced rather than intended.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/charts/historical_view_isolation.dart',
        ],
      ),
    );
  });
}
