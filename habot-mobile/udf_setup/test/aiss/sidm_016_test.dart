/// AISS GATE -- Step 370 of 375
/// Global Reference ID:       SIDM-016
/// Atomic Steps Reference ID: SIDM-016
/// Setup Step (Action): "Write unit tests for the save, restore, discard, and
///                      quota check functions."
/// Atomic Step: "Select Material Design status summary formats and modern
///               layout specifications."
/// Metric: Select Material Design Quality Index -- floor 0.9, optimal 1,
///         ceiling 0.98. Best Qualitative Output: "High".
///
/// THE SECOND BAND IN THIS TRACK THAT IS FALSE ON ITS OWN TERMS, WITH A GAP
/// TWENTY TIMES THE FIRST.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/dashboard/status_summary_format.dart';

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

  group('SIDM-016 :: a band false on its own terms', () {
    gate(
      'SIDM-016-G1',
      'The ceiling is below the optimal.',
      'The value the row calls best sits outside the range the row calls '
          'attainable',
      () =>
          HabotStatusSummaryFormat.theCeilingIsBelowTheOptimal &&
          HabotStatusSummaryFormat.bandCeiling == 0.98 &&
          HabotStatusSummaryFormat.bandOptimal == 1,
    );

    gate(
      'SIDM-016-G2',
      'By two hundredths.',
      'Not a rounding artefact but a stated position two per cent short of the '
          'stated ideal',
      () => HabotStatusSummaryFormat.theShortfallIsTwoHundredths,
    );

    gate(
      'SIDM-016-G3',
      'Second such band, fifty-eight rows after Step 312.',
      'Which makes it a class of defect rather than a one-off, and this gap is '
          'twenty times the first',
      () =>
          HabotStatusSummaryFormat.thisIsTheSecondSuchBand &&
          HabotStatusSummaryFormat.rowsApart == 58 &&
          HabotStatusSummaryFormat.thisGapIsTwentyTimesTheFirst &&
          HabotStatusSummaryFormat.bandNote.contains('a class of defect'),
    );
  });

  group('SIDM-016 :: the columns', () {
    gate(
      'SIDM-016-G4',
      'The output column holds one value.',
      '"High" with no failing value beside it -- the seventh one-valued output '
          'column in the track, with Step 371 in this batch',
      () =>
          HabotStatusSummaryFormat.theOutputCannotExpressAFailure &&
          HabotStatusSummaryFormat.theCountReachesSeven &&
          HabotStatusSummaryFormat.oneValuedColumnsIncludingThis == 7,
    );

    gate(
      'SIDM-016-G5',
      'The standard cell holds benchmarking advice.',
      'A sentence about establishing service levels where the name of '
          'something to measure against belongs',
      () =>
          HabotStatusSummaryFormat.theStandardCellHoldsAdvice &&
          HabotStatusSummaryFormat.outputNote
              .contains('rather than the name'),
    );

    gate(
      'SIDM-016-G6',
      'The metric name begins with the row\'s own verb.',
      '"Select" welded onto a metric name -- the behaviour Steps 352, 356 and '
          '357 show in the artefact cell, arriving in the metric column',
      () =>
          HabotStatusSummaryFormat.theMetricNameStartsWithTheRowsVerb &&
          HabotStatusSummaryFormat.theSameBehaviourAppearsInAnotherColumn &&
          HabotStatusSummaryFormat.artefactCellRows.contains(357) &&
          HabotStatusSummaryFormat.metricNameNote
              .contains('meant for something else'),
    );
  });

  group('SIDM-016 :: a format is a decision about what to drop', () {
    gate(
      'SIDM-016-G7',
      'Four fields fit in 296dp with 32dp to spare.',
      'On a 328dp compact screen, which is the constraint the choosing happens '
          'inside',
      () =>
          HabotStatusSummaryFormat.fourFit &&
          HabotStatusSummaryFormat.includedCount == 4 &&
          HabotStatusSummaryFormat.widthLeft == 32,
    );

    gate(
      'SIDM-016-G8',
      'The fifth genuinely does not fit.',
      '120dp against 32dp remaining, so the omission is a measurement rather '
          'than a preference',
      () =>
          HabotStatusSummaryFormat.theFifthWouldNotFit &&
          HabotStatusSummaryFormat.dropped.length == 1 &&
          HabotStatusSummaryFormat.dropped.first.widthDp == 120,
    );

    gate(
      'SIDM-016-G9',
      'The dropped field is named, with where it is still reachable.',
      'The rule Step 311 settled for the trace map and Step 363 for a '
          'truncated list',
      () =>
          HabotStatusSummaryFormat.everyDroppedFieldIsReachable &&
          HabotStatusSummaryFormat.dropped.first.reachableAt
              .contains('one tap') &&
          HabotStatusSummaryFormat.formatNote.contains('on the reader'),
    );

    gate(
      'SIDM-016-G10',
      'Output reported as High.',
      'Five obligations, all met; all ten declared checks hold',
      () =>
          HabotStatusSummaryFormat.obligations.length == 5 &&
          HabotStatusSummaryFormat.obligations.values.every((bool b) => b) &&
          HabotStatusSummaryFormat.qualitativeOutput == 'High' &&
          HabotStatusSummaryFormat.checks.length == 10 &&
          HabotStatusSummaryFormat.checks.values.every((bool b) => b) &&
          HabotStatusSummaryFormat.columnNote.contains('quota check'),
    );
  });

  tearDownAll(() {
    final String shortfall =
        HabotStatusSummaryFormat.shortfall.toStringAsFixed(2);
    final String width =
        HabotStatusSummaryFormat.includedWidth.toStringAsFixed(0);
    final String spare = HabotStatusSummaryFormat.widthLeft.toStringAsFixed(0);
    final String droppedField = HabotStatusSummaryFormat.dropped.first.name;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'SIDM-016',
        atomicStepReferenceId: 'SIDM-016',
        setupStepAction:
            'COLUMN NOTE: the band on this row sets a ceiling of 0.98 below '
            'its own optimal of 1 -- the second such band in this track after '
            'Step 312, fifty-eight rows earlier, with a gap twenty times as '
            'large -- its Best Qualitative Output column reads "High" with no '
            'failing value beside it, its Best Qualitative Output Type cell '
            'holds benchmarking advice where the name of a standard belongs, '
            'its metric name begins with the Atomic Step\'s own first word, '
            'and its Setup Step column reads "Write unit tests for the save, '
            'restore, discard, and quota check functions". Atomic Step: '
            '"Select Material Design status summary formats and modern layout '
            'specifications."',
        implementationOrder: 370,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Layout Type': 'a four-field status summary row',
          'Layout Grid Dimensions':
              '${width}dp of fields inside a 328dp compact width',
          'Spacing Rules': 'the declared spacing scale',
          'Alignment Settings': 'status leading, count trailing',
          'Layout Validation Status': 'High',
          'Completion Status': 'High',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              '4 fields included in ${width}dp with ${spare}dp spare; '
                  '"$droppedField" is dropped and named as reachable in the '
                  'detail sheet',
          'Data Quality Note':
              'BAND: ${HabotStatusSummaryFormat.bandNote} '
              'OUTPUT: ${HabotStatusSummaryFormat.outputNote} '
              'METRIC NAME: ${HabotStatusSummaryFormat.metricNameNote} '
              'FORMAT: ${HabotStatusSummaryFormat.formatNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Select Material Design Quality Index',
            observed:
                'FALSE ON ITS OWN TERMS, FOR THE SECOND TIME IN THIS TRACK. '
                'Floor 0.9, optimal 1, ceiling 0.98: the value the row calls '
                'best sits $shortfall below the value it calls ideal, so the '
                'band contradicts itself without any reading being taken. Step '
                '312 carried the identical shape with a gap of one thousandth '
                'and was recorded as the first; this is the second, '
                'fifty-eight rows later, with nothing linking the two rows and '
                'a gap twenty times as large. The metric name is also the '
                'Atomic Step\'s first word welded onto an index, and the '
                'output column can only say "High".',
            floor: '0.9',
            optimal: '1',
            ceiling: '0.98',
          ),
          AissMeasurement(
            metricName: 'Fields dropped from the summary without being named',
            observed:
                '0 of 1. A status summary on a 328dp screen cannot show '
                'everything, so the format is the choosing: four fields fit in '
                '${width}dp with ${spare}dp to spare, and the fifth is 120dp '
                'and does not. "$droppedField" is dropped, named as dropped, '
                'and given where it can still be found -- one tap away on the '
                'detail sheet -- which is the rule Step 311 settled for the '
                'trace map and Step 363 for a truncated list. A format that '
                'drops a field silently has decided something on the reader\'s '
                'behalf without telling them.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/status_summary_format.dart',
        ],
      ),
    );
  });
}
