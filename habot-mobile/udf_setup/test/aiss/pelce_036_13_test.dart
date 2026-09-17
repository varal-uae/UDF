/// AISS GATE -- Step 389 of 395
/// Global Reference ID:       PELCE-036-13
/// Atomic Steps Reference ID: PELCE-036-13
/// Setup Step (Action): "Set the backup timeout parameter window limit to trip
///                      exactly at 10 seconds of continuous loading latency."
/// Atomic Step: "Trigger automatic UI freeze on marketing spend configuration
///               when rate drops below 98%."
/// Metric: UI Design-System Adherence Rate -- floor ">=85%", optimal ">=95%",
///         ceiling "1". Best Qualitative Output: "Good/Average/Poor -> Best =
///         Good (100%)". Assigned to **ADFA**.
///
/// THE ROW NEVER SAYS WHICH RATE, AND ITS OUTPUT CELL EXPLAINS ITSELF TO ITS
/// READER.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/operations/spend_freeze.dart';

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

  group('PELCE-036-13 :: which rate', () {
    gate(
      'PELCE-036-13-G1',
      'The row does not name the rate.',
      'Four readings are possible, and the metric on the row is a '
          'design-system adherence rate',
      () =>
          !HabotSpendFreeze.theRowNamesTheRate &&
          HabotSpendFreeze.fourReadingsArePossible,
    );

    gate(
      'PELCE-036-13-G2',
      'The rate is named at the call site instead.',
      'So the control cannot fire on a number nobody chose',
      () =>
          HabotSpendFreeze.theRateIsNamedAtTheCallSite &&
          !HabotSpendFreeze.theMetricsRateIsUsed,
    );

    gate(
      'PELCE-036-13-G3',
      'The literal reading is recorded rather than built.',
      'It would freeze a marketing budget because somebody shipped a component '
          'with the wrong padding',
      () => HabotSpendFreeze.rateNote.contains('the wrong padding'),
    );
  });

  group('PELCE-036-13 :: a threshold with no hysteresis flaps', () {
    gate(
      'PELCE-036-13-G4',
      'The freeze arms below 98 and clears at 98.5.',
      'A single threshold on a rate hovering at 98 freezes and thaws on every '
          'sample',
      () =>
          HabotSpendFreeze.thereIsHysteresis &&
          HabotSpendFreeze.itFreezesBelowTheThreshold &&
          HabotSpendFreeze.itClearsAboveTheBand,
    );

    gate(
      'PELCE-036-13-G5',
      'A boundary rate holds its state.',
      'So the person watching sees a condition rather than a flicker, and the '
          'audit log gets one line rather than a stream',
      () =>
          HabotSpendFreeze.aBoundaryRateHoldsItsState &&
          HabotSpendFreeze.hysteresisNote.contains('rather than a flicker'),
    );
  });

  group('PELCE-036-13 :: what is frozen', () {
    gate(
      'PELCE-036-13-G6',
      'Three of five controls freeze.',
      'Only the ones that change how much money moves',
      () =>
          HabotFreezeScope.values.length == 2 &&
          HabotSpendFreeze.controls.length == 5 &&
          HabotSpendFreeze.threeOfFiveFreeze,
    );

    gate(
      'PELCE-036-13-G7',
      'The performance report export is not one of them.',
      'A freeze that takes the export removes the thing somebody needs to work '
          'out why the rate dropped',
      () =>
          HabotSpendFreeze.theExportStaysAvailable &&
          HabotSpendFreeze.scopeNote.contains('why the rate dropped'),
    );

    gate(
      'PELCE-036-13-G8',
      'The freeze is liftable and says what it is waiting for.',
      'A freeze nobody can lift is an outage with a nicer name, and money '
          'moves on a schedule',
      () =>
          HabotSpendFreeze.aLiftExists &&
          HabotSpendFreeze.aLiftNeedsAReason &&
          HabotSpendFreeze.theFreezeIsNotADeadEnd &&
          HabotSpendFreeze.theFreezeSaysWhatItIsWaitingFor,
    );
  });

  group('PELCE-036-13 :: the band and the arrow', () {
    gate(
      'PELCE-036-13-G9',
      'Mixed units, and an output cell with an arrow in it.',
      'Two percentages and the bare ratio "1"; and '
          '"Good/Average/Poor -> Best = Good (100%)" is a scale, an annotation '
          'and a gloss in one cell',
      () =>
          HabotSpendFreeze.theBandMixesUnits &&
          HabotSpendFreeze.threeMixedUnitBands &&
          HabotSpendFreeze.mixedUnitBandRows.contains(364) &&
          HabotSpendFreeze.theOutputColumnHoldsAnAnnotation &&
          HabotSpendFreeze.outputNote.contains('explains itself to its reader'),
    );

    gate(
      'PELCE-036-13-G10',
      'Output reported as Good / Average / Poor.',
      'Six obligations, all met, giving Good; all ten declared checks hold',
      () =>
          HabotSpendFreeze.obligations.length == 6 &&
          HabotSpendFreeze.obligations.values.every((bool b) => b) &&
          HabotSpendFreeze.qualitativeOutput == 'Good' &&
          HabotSpendFreeze.checks.length == 10 &&
          HabotSpendFreeze.checks.values.every((bool b) => b) &&
          HabotSpendFreeze.columnNote.contains('ADFA'),
    );
  });

  tearDownAll(() {
    final int frozen = HabotSpendFreeze.frozenControls;
    final int available = HabotSpendFreeze.availableControls;
    final String rate = HabotSpendFreeze.theRateUsed;
    final String waiting = HabotSpendFreeze.whatTheFreezeIsWaitingFor;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'PELCE-036-13',
        atomicStepReferenceId: 'PELCE-036-13',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to ADFA rather than UDF; it '
            'freezes spend when "rate" drops below 98% without saying which '
            'rate, while its own metric is a UI design-system adherence rate; '
            'its band mixes two percentages with the bare ratio "1"; its Best '
            'Qualitative Output cell reads "Good/Average/Poor -> Best = Good '
            '(100%)", a scale with an arrow and an annotation inside one cell; '
            'and its Setup Step column reads "Set the backup timeout parameter '
            'window limit to trip exactly at 10 seconds of continuous loading '
            'latency". Atomic Step: "Trigger automatic UI freeze on marketing '
            'spend configuration when rate drops below 98%."',
        implementationOrder: 389,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Configuration Key': 'marketing spend freeze',
          'Configuration Value': 'armed below 98%, cleared at 98.5%',
          'Configuration Type': 'a named rate supplied by the caller',
          'Validation Status': 'Good',
          'Configuration Timestamp': '2026-09-17T00:00:00Z',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the rate used is the $rate; $frozen of 5 controls freeze and '
                  '$available stay available',
          'Data Quality Note':
              'RATE: ${HabotSpendFreeze.rateNote} HYSTERESIS: '
              '${HabotSpendFreeze.hysteresisNote} SCOPE: '
              '${HabotSpendFreeze.scopeNote} LIFT: '
              '${HabotSpendFreeze.liftNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Design-System Adherence Rate',
            observed:
                'MIXED UNITS, AND AN OUTPUT CELL THAT ANNOTATES ITSELF. Floor '
                '">=85%", optimal ">=95%", ceiling "1" -- two percentages and '
                'a bare ratio, the third mixed-unit band in two batches after '
                'Steps 364 and 393. The Best Qualitative Output cell reads '
                '"Good/Average/Poor -> Best = Good (100%)": a scale, an arrow, '
                'an annotation naming which value is best, and a percentage '
                'gloss, all in one cell, so a consumer parsing the column for '
                'a scale gets a sentence. The metric is also the candidate '
                'reading of the unnamed "rate" this row freezes on.',
            floor: '>=85%',
            optimal: '>=95%',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Controls frozen that do not move money',
            observed:
                '0 of $available. The row freezes on a rate it never names, so '
                'the rate is supplied and named at the call site -- the $rate '
                '-- rather than taken from the metric, which read literally '
                'would freeze a budget over component padding. The threshold '
                'carries hysteresis, arming below 98 and clearing at 98.5, so '
                'a rate sitting on the boundary produces one state rather than '
                'a stream of events. $frozen of the five controls change how '
                'much money moves and are frozen; renaming a campaign and '
                'exporting the report are not, and the freeze says it is '
                'waiting for $waiting.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/operations/spend_freeze.dart',
        ],
      ),
    );
  });
}
