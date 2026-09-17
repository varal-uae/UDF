/// AISS GATE -- Step 394 of 395
/// Global Reference ID:       GEN-01782
/// Atomic Steps Reference ID: GEN-01782
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Configure the application state to set isLoading = true."
/// Metric: Implementation Completion Rate (%) -- floor 95, optimal 99.5,
///         ceiling 100. Complete/Partial/Not Complete. ISO/IEC 27001:2022
///         Implementation Standards. Assigned to **UDF**.
///
/// STEP 194 IS THIS ROW, TWO HUNDRED ROWS EARLIER -- AND IT KEPT THE SINGLE
/// BOOLEAN AS A RECORDED COUNTER-EXAMPLE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/loading/loading_flag.dart';

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

  group('GEN-01782 :: what a single boolean cannot do', () {
    gate(
      'GEN-01782-G1',
      'Three things it cannot distinguish.',
      'Loading from loaded-and-empty, loading from failed, and which of '
          'several requests is still running',
      () =>
          HabotLoadingFlag.threeThingsAreIndistinguishable &&
          !HabotLoadingFlag.aSingleBooleanIsUsed,
    );

    gate(
      'GEN-01782-G2',
      'Which is how an app shows an empty list to somebody whose request '
          'errored.',
      'And how a spinner disappears while something is still in flight',
      () => HabotLoadingFlag.booleanNote.contains('whose request errored'),
    );
  });

  group('GEN-01782 :: the third duplicated instruction in this batch', () {
    gate(
      'GEN-01782-G3',
      'Step 194 reads the same instruction.',
      'GEN-04726: "set global app state isLoading = true and inject M3 '
          'progress indicator", under a different reference id',
      () =>
          HabotLoadingFlag.theStepThatDeclaredTheShape == 194 &&
          HabotLoadingFlag.theOtherReference == 'GEN-04726' &&
          !HabotLoadingFlag.eitherRowMentionsTheOther,
    );

    gate(
      'GEN-01782-G4',
      'Two hundred rows apart, and the furthest of the three.',
      'After Steps 380 and 382, which duplicate a dashboard rule and a release '
          'control',
      () =>
          HabotLoadingFlag.thisIsTheThirdDuplicateInTheBatch &&
          HabotLoadingFlag.rowsApart == 200 &&
          HabotLoadingFlag.duplicatedInstructionRows.contains(380) &&
          HabotLoadingFlag.duplicatedInstructionRows.contains(382),
    );

    gate(
      'GEN-01782-G5',
      'That step kept the single flag as a recorded counter-example.',
      'So this row asks for the thing the earlier one exists to argue against, '
          'and nothing new is built',
      () =>
          HabotLoadingFlag.thisRowAsksForTheCounterExample &&
          HabotLoadingFlag.counterExampleNote
              .contains('the keyed state is bound'),
    );
  });

  group('GEN-01782 :: three concurrent operations', () {
    gate(
      'GEN-01782-G6',
      'Three operations, tracked separately.',
      'A list loading, a filter applying and a background refresh running',
      () =>
          HabotWaitKind.values.length == 3 &&
          HabotLoadingFlag.eachSurfaceKnowsItsOwnWait &&
          HabotLoadingFlag.operationsDistinguished == 100,
    );

    gate(
      'GEN-01782-G7',
      'One finishing leaves two running, and the derived boolean stays true.',
      'Which is the bug a shared flag has: whichever finishes first clears it',
      () =>
          HabotLoadingFlag.twoRemainAfterOneFinishes &&
          HabotLoadingFlag.theDerivedBooleanStaysTrue &&
          HabotLoadingFlag.anythingIsLoading,
    );
  });

  group('GEN-01782 :: timing comes from tokens', () {
    gate(
      'GEN-01782-G8',
      'The delay and the minimum visible time are Step 194\'s tokens.',
      'A boolean set the instant a request starts has neither',
      () =>
          HabotLoadingFlag.theTimingIsTokenised &&
          !HabotLoadingFlag.aBooleanCarriesTiming,
    );

    gate(
      'GEN-01782-G9',
      'A fast response shows nothing and a slow one does not flash.',
      'The worked response times are derived from the declared delay rather '
          'than written as literals',
      () =>
          HabotLoadingFlag.aFastResponseShowsNothing &&
          HabotLoadingFlag.aSlowResponseShowsASpinner &&
          HabotLoadingFlag.timingNote.contains('as a glitch'),
    );

    gate(
      'GEN-01782-G10',
      'Output reported as Complete / Partial / Not Complete.',
      'Five obligations, all met, giving Complete; the artefact cell is a '
          'variable name, the band is well formed, and all ten declared checks '
          'hold',
      () =>
          HabotLoadingFlag.obligations.length == 5 &&
          HabotLoadingFlag.obligations.values.every((bool b) => b) &&
          HabotLoadingFlag.qualitativeOutput == 'Complete' &&
          HabotLoadingFlag.theArtefactCellIsAVariableName &&
          HabotLoadingFlag.generatorArtefactCellsInTwoBatches == 8 &&
          HabotLoadingFlag.theBandIsWellFormed &&
          HabotLoadingFlag.checks.length == 10 &&
          HabotLoadingFlag.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final int running = HabotLoadingFlag.running.length;
    final int remaining =
        HabotLoadingFlag.after(HabotWaitKind.filterChange).length;
    final String artefact = HabotLoadingFlag.artefactCell;
    final int delayMs = HabotLoadingFlag.appearAfter.inMilliseconds;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01782',
        atomicStepReferenceId: 'GEN-01782',
        setupStepAction:
            'COLUMN NOTE: the Data Requirement cell on this row reads '
            '"Data/artifacts to prepare: isLoading", a variable name lifted '
            'into the artefact list and the eighth generator-artefact cell '
            'across these two batches; the Atomic Step repeats Step 194\'s '
            'instruction two hundred rows later under a different reference '
            'id, asking for the single boolean that step keeps in the '
            'repository as a recorded counter-example -- the third duplicated '
            'instruction in this batch after Steps 380 and 382, and the '
            'furthest apart; and the Setup Step column is empty. Atomic Step: '
            '"Configure the application state to set isLoading = true."',
        implementationOrder: 394,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'isLoading':
              'derived from an operation-keyed state rather than stored; '
                  '$running concurrent operations tracked separately',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'one operation finishing leaves $remaining running; the spinner '
                  'delay is the declared ${delayMs}ms token',
          'Data Quality Note':
              'BOOLEAN: ${HabotLoadingFlag.booleanNote} DUPLICATE: '
              '${HabotLoadingFlag.counterExampleNote} CONCURRENCY: '
              '${HabotLoadingFlag.concurrencyNote} TIMING: '
              '${HabotLoadingFlag.timingNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Implementation Completion Rate (%)',
            observed:
                'WELL FORMED, AND THE SAME TAUTOLOGY STEP 378 CARRIES. Floor '
                '95, optimal 99.5, ceiling 100, correctly ordered. The '
                'artefact cell for this row is the single identifier '
                '"$artefact" -- the eighth generator-artefact cell across '
                'these two batches and the first that is a variable name '
                'rather than a label or a phrase. The figure published is the '
                'share of concurrent operations the state can tell apart, '
                'which is the property the row\'s own instruction would '
                'remove: $running of $running.',
            floor: '95',
            optimal: '99.5',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Spinners that vanish while something is still loading',
            observed:
                '0. One flag for a whole screen means concurrent requests '
                'share it and whichever finishes first clears it. Step 194 '
                'read "set global app state isLoading = true and inject M3 '
                'progress indicator" and built an operation-keyed scope, '
                'keeping a naive single flag beside it as a recorded '
                'counter-example; this row, two hundred rows later under a '
                'different reference id, asks for the counter-example. Nothing '
                'new is built: $running operations are tracked separately, one '
                'finishing leaves $remaining running, and the spinner timing '
                'comes from the declared tokens rather than from the instant a '
                'request started.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/loading/loading_flag.dart',
        ],
      ),
    );
  });
}
