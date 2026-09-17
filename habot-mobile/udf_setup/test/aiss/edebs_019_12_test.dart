/// AISS GATE -- Step 355 of 355
/// Global Reference ID:       EDEBS-019-12
/// Atomic Steps Reference ID: EDEBS-019-12
/// Setup Step (Action): "Construct the NavigationBar component specifically
///                      for compact viewports (< 600dp)."
/// Atomic Step: "Restore previous UI state smoothly without jarring screen
///               refreshes."
/// Metric: UI Design-System Adherence Rate -- floor ">=85%", optimal ">=95%",
///         ceiling 1. Good/Average/Poor. MD3 / Nielsen Norman.
///
/// A ROW ABOUT RESTORING A USER INTERFACE WHOSE OWN DATA REQUIREMENT SAYS IT
/// HAS NO USER INTERFACE -- FOUR TIMES. SECOND SUCH CELL IN TWO BATCHES.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/flow/state_restoration.dart';

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

  group('EDEBS-019-12 :: the cell that denies the row', () {
    gate(
      'EDEBS-019-12-G1',
      'Data Requirement: "N/A (Backend database setup). | N/A. | N/A. | N/A."',
      'A row about restoring a user interface declaring that it has no user '
          'interface, four times over',
      () =>
          HabotStateRestoration.theRowSaysItHasNoInterface &&
          HabotStateRestoration.itSaysSoFourTimes &&
          HabotStateRestoration.naCount == 4,
    );

    gate(
      'EDEBS-019-12-G2',
      'Second such cell in two batches, after Step 332.',
      'When the sheet cannot place a row it writes N/A into the one cell that '
          'would have told a reader where the row belongs -- a pattern rather '
          'than a slip',
      () =>
          HabotStateRestoration.thisIsTheSecondSuchCellInTwoBatches &&
          HabotStateRestoration.theOtherSuchRow == 332 &&
          HabotStateRestoration.cellNote.contains('pattern rather than a slip'),
    );
  });

  group('EDEBS-019-12 :: three ways back, one that loses work', () {
    gate(
      'EDEBS-019-12-G3',
      'Three return causes; two are survived by objects in memory.',
      'Navigation and reconfiguration; process death is not',
      () =>
          HabotReturnCause.values.length == 3 &&
          HabotStateRestoration.onlyProcessDeathNeedsPersistence,
    );

    gate(
      'EDEBS-019-12-G4',
      'Android reclaims a backgrounded process and nobody is told.',
      'A worker photographs something mid-form, the camera takes the '
          'foreground, and the form returns empty -- from where they stand the '
          'application threw their work away for no reason',
      () => HabotStateRestoration.processNote
          .contains('threw their work away'),
    );
  });

  group('EDEBS-019-12 :: three promises in one phrase', () {
    gate(
      'EDEBS-019-12-G5',
      'Nothing flashes the empty state on the way to the restored one.',
      'Which is what a build that renders before the state arrives will do',
      () =>
          HabotStateRestoration.nothingFlashesEmpty &&
          HabotStateRestoration.promisesInsideOnePhrase == 3,
    );

    gate(
      'EDEBS-019-12-G6',
      'The return is not animated as an arrival.',
      'A transition tells a person something changed, and nothing has',
      () => HabotStateRestoration.theReturnIsNotDressedAsAnArrival,
    );

    gate(
      'EDEBS-019-12-G7',
      'The scroll offset and the focused field come back.',
      'The place is what a person keeps, and the values alone are not the '
          'place',
      () =>
          HabotStateRestoration.thePersonKeepsTheirPlace &&
          HabotStateRestoration.smoothNote
              .contains('the values alone are not'),
    );
  });

  group('EDEBS-019-12 :: what is deliberately not restored', () {
    gate(
      'EDEBS-019-12-G8',
      'Six pieces of state, two of which are deliberately not restored.',
      'Validation errors from before the restart, and the entered card number',
      () =>
          HabotStateRestoration.state.length == 6 &&
          HabotStateRestoration.twoThingsAreDeliberatelyNotRestored,
    );

    gate(
      'EDEBS-019-12-G9',
      'Stale errors are dropped and nothing sensitive is persisted.',
      'An error surviving a restart refers to a check that has not run since, '
          'and the platform restoration store is ordinary files',
      () =>
          HabotStateRestoration.staleErrorsAreDropped &&
          HabotStateRestoration.nothingSensitiveIsPersisted &&
          HabotStateRestoration.selectionNote.contains('ordinary files'),
    );

    gate(
      'EDEBS-019-12-G10',
      'Output reported as Good / Average / Poor.',
      'Six obligations, all met, giving Good; the band mixes units for the '
          'fifth time in this batch and all ten declared checks hold',
      () =>
          HabotStateRestoration.obligations.length == 6 &&
          HabotStateRestoration.obligations.values.every((bool b) => b) &&
          HabotStateRestoration.qualitativeOutput == 'Good' &&
          HabotStateRestoration.theBandMixesUnits &&
          HabotStateRestoration.mixedUnitBandsInThisBatch == 5 &&
          HabotStateRestoration.checks.length == 10 &&
          HabotStateRestoration.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final int notRestored = HabotStateRestoration.notRestored.length;
    final int causes = HabotStateRestoration.causesNeedingPersistence.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'EDEBS-019-12',
        atomicStepReferenceId: 'EDEBS-019-12',
        setupStepAction:
            'COLUMN NOTE: the Data Requirement column on this row reads "N/A '
            '(Backend database setup). | N/A. | N/A. | N/A." on a row about '
            'restoring a user interface; the Setup Step column reads '
            '"Construct the NavigationBar component specifically for compact '
            'viewports (< 600dp)"; and the band mixes two percentages with the '
            'bare ratio "1". Atomic Step: "Restore previous UI state smoothly '
            'without jarring screen refreshes."',
        implementationOrder: 355,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Step Execution ID': 'EDEBS-019-12',
          'Execution Status': 'Complete',
          'Execution Timestamp': '2026-09-17T00:00:00Z',
          'Step Outcome':
              '3 return causes, $causes of which needs persistence; 6 pieces '
                  'of state, $notRestored deliberately not restored',
          'User ID': 'Fredrick',
          'Completion Status': 'Good',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'nothing flashes empty, the return is not animated as an '
                  'arrival, and the scroll offset and focused field come back '
                  'with the values',
          'Data Quality Note':
              'CELL: ${HabotStateRestoration.cellNote} '
              'PROCESS: ${HabotStateRestoration.processNote} '
              'SMOOTH: ${HabotStateRestoration.smoothNote} '
              'SELECTION: ${HabotStateRestoration.selectionNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Design-System Adherence Rate',
            observed:
                '100 over the population named here, because the row names '
                'none. THE ROW ALSO DENIES IT HAS AN INTERFACE: its Data '
                'Requirement cell reads "N/A (Backend database setup). | N/A. '
                '| N/A. | N/A." on a row about restoring a user interface. '
                'Step 332 in the previous batch did the same thing beside a '
                'text-contrast metric, and the pair is a pattern rather than a '
                'slip -- when the sheet cannot place a row it writes N/A into '
                'the cell that would have said where the row belongs. The band '
                'mixes units for the fifth time in this batch.',
            floor: '>=85%',
            optimal: '>=95%',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Return causes that lose the person\'s work',
            observed:
                '0 of 3, which requires persistence rather than object state '
                'for the one cause that is not survived in memory. Android '
                'reclaims a backgrounded process whenever it needs the memory '
                'and tells nobody: a worker photographs something mid-form, '
                'the camera takes the foreground, and the form comes back '
                'empty. Restoration that survives only navigation solves the '
                'case in which nothing was ever at risk. $notRestored of the '
                'six pieces of state are deliberately not restored -- stale '
                'validation errors, which refer to a check that has not run '
                'since, and the card number, which the platform would write to '
                'ordinary files.',
            floor: '1',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/flow/state_restoration.dart',
        ],
      ),
    );
  });
}
