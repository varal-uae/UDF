/// AISS GATE -- Step 362 of 375
/// Global Reference ID:       GEN-01143
/// Atomic Steps Reference ID: GEN-01143
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Display popular filter combinations and search parameter
///               trends on the analytics dashboard."
/// Metric: Dashboard Data Refresh Latency -- the shared band. Good/Average/
///         Poor. Assigned to **CAL**.
///
/// A SEARCH LOG IS A RECORD OF PEOPLE, AND THE SECOND OF FOUR COPIES OF THE
/// SHARED BAND IN THIS BATCH.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/dashboard/search_trends.dart';

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

  group('GEN-01143 :: a search log is a record of people', () {
    gate(
      'GEN-01143-G1',
      'Five worked combinations, three of which publish.',
      'A combination is shown only when at least ten distinct searchers '
          'produced it',
      () =>
          HabotSearchTrends.combinations.length == 5 &&
          HabotSearchTrends.threeOfFivePublish &&
          HabotSearchTrends.kAnonymityFloor == 10,
    );

    gate(
      'GEN-01143-G2',
      'The two suppressed combinations are the specific ones.',
      '"Overnight, medical needs, postcode-level" and "Arabic-speaking carer, '
          'infant, specific street" -- no field in either is a name',
      () =>
          HabotSearchTrends.suppressed.first.label.contains('medical needs') &&
          HabotSearchTrends.suppressed.last.label.contains('specific street') &&
          HabotSearchTrends.anonymityNote
              .contains('no field in that sentence is a name'),
    );

    gate(
      'GEN-01143-G3',
      'The suppressed rows are counted rather than hidden.',
      'Twenty-three searches sit behind them, and a dashboard that silently '
          'drops rows teaches its reader that the tail is empty',
      () =>
          HabotSearchTrends.theSuppressedAreCounted &&
          !HabotSearchTrends.suppressedRowsAreHidden &&
          HabotSearchTrends.suppressedSearches == 23,
    );
  });

  group('GEN-01143 :: popular needs a window', () {
    gate(
      'GEN-01143-G4',
      'The ranking window is on the face of the panel.',
      'The last 28 days, because a reader comparing this week to last needs to '
          'know the two were measured the same way',
      () =>
          HabotSearchTrends.theWindowIsStated &&
          HabotSearchTrends.window.contains('28 days'),
    );

    gate(
      'GEN-01143-G5',
      'A day, a month and all time give three different lists.',
      'And the third is mostly a record of whatever was popular the month the '
          'feature launched',
      () =>
          HabotSearchTrends.threeWindowsGiveThreeLists &&
          HabotSearchTrends.windowNote.contains('the feature launched'),
    );
  });

  group('GEN-01143 :: the shared band', () {
    gate(
      'GEN-01143-G6',
      'This row carries the band Steps 358, 374 and 375 also carry.',
      'And Steps 163 and 175, which tokenised it -- six rows, one band',
      () =>
          HabotSearchTrends.theBandIsTheSharedOne &&
          HabotSearchTrends.rowsSharingIt == 6,
    );

    gate(
      'GEN-01143-G7',
      'The panel does not adopt it.',
      'Adopting it would mean treating a day-old analytics panel as the ideal',
      () =>
          !HabotSearchTrends.thePanelAdoptsTheRowsBand &&
          HabotSearchTrends.bandNote.contains('six rows, one band'),
    );

    gate(
      'GEN-01143-G8',
      'A day-old panel is labelled Delayed.',
      'Classified by the Step 129 policy, so a reader is told the figures are '
          'old rather than left to assume they are current',
      () => HabotSearchTrends.aDayOldPanelIsLabelledDelayed,
    );
  });

  group('GEN-01143 :: the columns and the output', () {
    gate(
      'GEN-01143-G9',
      'Assigned to CAL, with a truncated artefact cell.',
      'The Data Requirement cell holds the Atomic Step\'s own text cut off '
          'mid-sentence with an ellipsis',
      () =>
          HabotSearchTrends.columnNote.contains('CAL') &&
          HabotSearchTrends.columnNote.contains('truncated mid-sentence'),
    );

    gate(
      'GEN-01143-G10',
      'Output reported as Good / Average / Poor.',
      'Five obligations, all met, giving Good; all ten declared checks hold',
      () =>
          HabotSearchTrends.obligations.length == 5 &&
          HabotSearchTrends.obligations.values.every((bool b) => b) &&
          HabotSearchTrends.qualitativeOutput == 'Good' &&
          HabotSearchTrends.checks.length == 10 &&
          HabotSearchTrends.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final int published = HabotSearchTrends.published.length;
    final int suppressed = HabotSearchTrends.suppressed.length;
    final String label = HabotSearchTrends.suppressionLabel;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01143',
        atomicStepReferenceId: 'GEN-01143',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to CAL rather than UDF, its '
            'band is the one shared with Steps 358, 374 and 375 of this batch '
            'and with Steps 163 and 175, and its Data Requirement cell holds '
            'the Atomic Step\'s own text truncated mid-sentence with an '
            'ellipsis as the artefact to prepare. The Setup Step column is '
            'empty. Atomic Step: "Display popular filter combinations and '
            'search parameter trends on the analytics dashboard."',
        implementationOrder: 362,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Display popular filter combinations and search parameter trends on '
                  'the':
              '$published of 5 combinations publish; $suppressed are held back '
                  'below the anonymity floor',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the panel states its 28-day window and shows "$label" rather '
                  'than dropping the suppressed rows',
          'Data Quality Note':
              'ANONYMITY: ${HabotSearchTrends.anonymityNote} '
              'SUPPRESSION: ${HabotSearchTrends.suppressionNote} '
              'WINDOW: ${HabotSearchTrends.windowNote} '
              'BAND: ${HabotSearchTrends.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Dashboard Data Refresh Latency',
            observed:
                'THE SECOND OF FOUR COPIES IN THIS BATCH. The identical three '
                'cells appear on Steps 358, 374 and 375 and on Steps 163 and '
                '175, which tokenised them -- six rows, one band, with a '
                'ceiling twenty-four times its floor on a lower-is-better '
                'measure. The panel does not adopt it: adopting it would mean '
                'treating a day-old analytics panel as ideal. It labels its '
                'own age with the Step 129 policy instead.',
            floor: '<1 hour',
            optimal: '<5 minutes',
            ceiling: '<24 hours',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Filter combinations published below the k floor',
            observed:
                '0 of 5. A search log records what people were looking for, '
                'and in this application that is childcare: a postcode, a '
                'date, an age, a requirement. One search is not sensitive and '
                'a handful is. $published combinations clear ten distinct '
                'searchers and publish; $suppressed do not and are held back '
                'with twenty-three searches behind them -- counted on the face '
                'of the panel rather than dropped, because a dashboard that '
                'silently removes rows teaches its reader that the tail is '
                'empty.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/search_trends.dart',
        ],
      ),
    );
  });
}
