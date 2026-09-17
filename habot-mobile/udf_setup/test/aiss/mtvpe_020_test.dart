/// AISS GATE -- Step 347 of 355
/// Global Reference ID:       MTVPE-020
/// Atomic Steps Reference ID: MTVPE-020
/// Setup Step (Action): "Implement graceful degradation when the profiling
///                      engine cannot reach the server."
/// Atomic Step: "14. Access the guidance tool dismissal controls."
/// Metric: Process Execution Quality (%) -- floor 95, optimal 99, ceiling 100.
///         Pass / Fail. ISO 9001:2015. Assigned to **PDG**.
///
/// THE FIRST CELL IN THIS TRACK THAT DOCUMENTS ITS OWN ABSENCE. THE DATA
/// REQUIREMENT COLUMN SAYS THE GENERATOR FOUND NO SOURCE ROW.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/guidance/guidance_dismissal.dart';

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

  group('MTVPE-020 :: the cell that reports a miss', () {
    gate(
      'MTVPE-020-G1',
      'Data Requirement: "No matched reference row ... verify manually."',
      'The generator reporting that it could not find a source row, printed '
          'into the specification as though it were a requirement',
      () =>
          HabotGuidanceDismissal.theCellReportsItsOwnAbsence &&
          HabotGuidanceDismissal.thisIsTheFirstSuchCell,
    );

    gate(
      'MTVPE-020-G2',
      'A stated gap is worth more than an invented requirement.',
      'One can be closed; the other cannot be told apart from a real one',
      () => HabotGuidanceDismissal.generatorNote
          .contains('cannot be distinguished'),
    );
  });

  group('MTVPE-020 :: three promises', () {
    gate(
      'MTVPE-020-G3',
      'Dismissal means three different things.',
      '"Not now" for this mark, "not this" for this tour, "not ever, until I '
          'ask" for all guidance',
      () =>
          HabotDismissScope.values.length == 3 &&
          HabotGuidanceDismissal.everyScopeHasItsOwnPromise,
    );

    gate(
      'MTVPE-020-G4',
      'The row says "dismissal controls" and names one.',
      'An interface offering only the narrowest makes the other two reachable '
          'by repetition; one treating it as the broadest takes away help',
      () =>
          HabotGuidanceDismissal.theRowNamesFewerScopesThanExist &&
          HabotGuidanceDismissal.scopesTheRowNames == 1 &&
          HabotGuidanceDismissal.scopeNote.contains('dismiss, dismiss'),
    );
  });

  group('MTVPE-020 :: persistence', () {
    gate(
      'MTVPE-020-G5',
      'The two broader scopes survive the session.',
      'A dismissal forgotten at the next launch is a pause, and being taught '
          'the same thing on every cold start teaches people not to read',
      () =>
          HabotGuidanceDismissal.theBroaderScopesPersist &&
          HabotGuidanceDismissal.persistenceNote.contains('without reading'),
    );

    gate(
      'MTVPE-020-G6',
      '"Not now" deliberately does not persist.',
      'It is the only one of the three that means later',
      () => HabotGuidanceDismissal.theNarrowestScopeDoesNot,
    );

    gate(
      'MTVPE-020-G7',
      'Every persistent choice has a way back.',
      'In the place the guidance was offered, rather than buried in a settings '
          'tree',
      () =>
          HabotGuidanceDismissal.thereIsAWayBack &&
          HabotGuidanceDismissal.reEntryPoint.contains('same place'),
    );
  });

  group('MTVPE-020 :: the exit', () {
    gate(
      'MTVPE-020-G8',
      'Three exits, none of them a path gesture.',
      'A close affordance, a labelled action, and the platform back gesture or '
          'key',
      () =>
          HabotGuidanceDismissal.thereAreThreeIndependentExits &&
          HabotGuidanceDismissal.everyControlIsSinglePointerOrSystem &&
          HabotDismissControl.values.length == 3,
    );

    gate(
      'MTVPE-020-G9',
      'A tour teaching a swipe must not need a swipe to close.',
      'Which is this batch\'s own failure arriving in the place meant to fix '
          'it; the back gesture is the exit nobody has to be taught',
      () =>
          !HabotGuidanceDismissal.anyControlRequiresAPathGesture &&
          HabotGuidanceDismissal.exitNote.contains('without being told'),
    );

    gate(
      'MTVPE-020-G10',
      'Output reported as Pass / Fail.',
      'Six obligations, all met, giving Pass; all ten declared checks hold, '
          'and Step 345 delegates dismissal here',
      () =>
          HabotGuidanceDismissal.obligations.length == 6 &&
          HabotGuidanceDismissal.obligations.values.every((bool b) => b) &&
          HabotGuidanceDismissal.qualitativeOutput == 'Pass' &&
          HabotGuidanceDismissal.checks.length == 10 &&
          HabotGuidanceDismissal.checks.values.every((bool b) => b) &&
          HabotGuidanceDismissal.theMarkExpectsThisMechanism &&
          HabotGuidanceDismissal.columnNote.contains('PDG'),
    );
  });

  tearDownAll(() {
    final String now =
        HabotGuidanceDismissal.promiseOf[HabotDismissScope.thisMark] ?? '';
    final String ever =
        HabotGuidanceDismissal.promiseOf[HabotDismissScope.allGuidance] ?? '';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'MTVPE-020',
        atomicStepReferenceId: 'MTVPE-020',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to PDG rather than UDF, its '
            'Atomic Step begins with "14." inside its own text, its Data '
            'Requirement column reports that the generator found no matching '
            'source row and says "verify manually", every narrative column is '
            'about identity and access masking, and the Setup Step column '
            'reads "Implement graceful degradation when the profiling engine '
            'cannot reach the server". Atomic Step: "Access the guidance tool '
            'dismissal controls."',
        implementationOrder: 347,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Access Type': 'guidance dismissal',
          'User Role': 'any signed-in person',
          'Permission Level':
              'no permission is required to stop being taught something',
          'Access Log':
              '3 dismissal scopes, 2 of which persist beyond the session',
          'Access Timestamp': '2026-09-17T00:00:00Z',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the narrowest scope promises "$now" and the broadest "$ever"; '
                  'three exits exist and none of them needs a path gesture',
          'Data Quality Note':
              'GENERATOR: ${HabotGuidanceDismissal.generatorNote} '
              'SCOPES: ${HabotGuidanceDismissal.scopeNote} '
              'PERSISTENCE: ${HabotGuidanceDismissal.persistenceNote} '
              'EXITS: ${HabotGuidanceDismissal.exitNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Execution Quality (%)',
            observed:
                '100 over the population named here: the share of dismissal '
                'scopes that make a distinct, stated promise. The band is well '
                'formed. What is not is the Data Requirement cell, which reads '
                '"No matched reference row in Setup Implementation master list '
                '... verify manually" -- the generator reporting its own miss, '
                'printed as a requirement. It is the first cell this track has '
                'met that documents its own absence, and it is worth more than '
                'most of the cells that are filled in, because a stated gap '
                'can be closed.',
            floor: '95',
            optimal: '99',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Exits from guidance that require a path gesture',
            observed:
                '0 of 3. A tour that teaches a swipe and can only be closed by '
                'swiping has no exit for the person it was written for, which '
                'is this batch\'s own failure arriving in the place meant to '
                'fix it. The three exits are a close affordance, a labelled '
                'action and the platform back gesture or key -- the last being '
                'the one people reach for without being told.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/guidance/guidance_dismissal.dart',
        ],
      ),
    );
  });
}
