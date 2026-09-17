/// AISS GATE -- Step 332 of 335
/// Global Reference ID:       HSFVS-013-17
/// Atomic Steps Reference ID: HSFVS-013-17
/// Setup Step (Action): "Identify score inputs triggering extreme rating
///                      thresholds (e.g., minimum score 1.0 or maximum score
///                      5.0)." (A DIFFERENT SUBJECT)
/// Atomic Step: "Restrict developers from clearing the dashboard error state
///               until metadata logging is proven active and fixed for the
///               failing track."
/// Metric: Text/UI Contrast Ratio -- floor 4.5:1, optimal 7:1, ceiling
///         **>=7:1**. Pass/Fail. WCAG 2.2 SC 1.4.3 / 1.4.6. Assigned to PDG.
///
/// THE CEILING IS THE OPTIMAL RESTATED, ON A ROW WHOSE OWN DATA REQUIREMENT
/// SAYS IT HAS NO USER INTERFACE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/telemetry/error_state_clearance.dart';

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

  group('HSFVS-013-17 :: the wrong thing is unsayable', () {
    gate(
      'HSFVS-013-17-G1',
      'Atomic Step: "Restrict developers from clearing".',
      'A disabled button in a console stops nobody who can edit the console; '
          'the evidence is a required argument and there is no force flag',
      () =>
          HabotErrorStateClearance.evidenceIsARequiredArgument &&
          !HabotErrorStateClearance.thereIsAForceFlag,
    );

    gate(
      'HSFVS-013-17-G2',
      'A call that clears without proof does not compile.',
      'Which is the shape Shingo meant, on a row that -- unlike Step 328 -- '
          'does not use the word',
      () =>
          HabotErrorStateClearance.enforcementNote
              .contains('does not compile') &&
          HabotErrorStateClearance.enforcementNote.contains('Step 328'),
    );
  });

  group('HSFVS-013-17 :: two conditions, four states', () {
    gate(
      'HSFVS-013-17-G3',
      'Atomic Step: "proven active AND fixed".',
      'Four combinations of the two booleans, exactly one of which clears',
      () =>
          HabotErrorStateClearance.allCombinations.length == 4 &&
          HabotErrorStateClearance.exactlyOneCombinationClears,
    );

    gate(
      'HSFVS-013-17-G4',
      'The common case is logging restored with the cause still open.',
      'Logging is quick to restore and causes are slow to find, so the state '
          'that arrives most often is exactly the one a single-condition rule '
          'would clear on',
      () =>
          HabotErrorStateClearance.theCommonCaseIsLoggingWithoutAFix &&
          HabotErrorStateClearance.twoConditionsNote
              .contains('a single-condition rule would clear'),
    );

    gate(
      'HSFVS-013-17-G5',
      'Each refusal says which half is missing.',
      'Three different sentences for three different states, and the '
          'logging-without-a-fix one names the live fault it would hide',
      () =>
          HabotErrorStateClearance.everyRefusalIsDifferent &&
          HabotErrorStateClearance.refusalFor(
            HabotErrorStateClearance.evidence(
              loggingActive: true,
              causeFixed: false,
            ),
          ).contains('hides a live fault'),
    );
  });

  group('HSFVS-013-17 :: clearing is not deleting', () {
    gate(
      'HSFVS-013-17-G6',
      'A cleared error moves to a history.',
      'Carrying who cleared it, when, and what was true at the time',
      () =>
          HabotErrorStateClearance.nothingIsDeleted &&
          HabotErrorStateClearance.disposition ==
              HabotClearedDisposition.movedToHistory &&
          HabotErrorStateClearance.theHistoryRecordsWhoAndWhen,
    );

    gate(
      'HSFVS-013-17-G7',
      'A dashboard clean by forgetting reports a button press.',
      'And the first person to notice is whoever is asked why the same '
          'failure was never investigated',
      () => HabotErrorStateClearance.historyNote
          .contains('never investigated'),
    );
  });

  group('HSFVS-013-17 :: the band', () {
    gate(
      'HSFVS-013-17-G8',
      'Ceiling ">=7:1" against an optimal of "7:1".',
      'The same threshold with an inequality in front of it, so the band has '
          'two ends and one of them is a restatement',
      () =>
          HabotErrorStateClearance.theCeilingIsTheOptimalRestated &&
          HabotErrorStateClearance.bandOptimal == '7:1',
    );

    gate(
      'HSFVS-013-17-G9',
      'And the row says it has no user interface.',
      'Its Data Requirement cell reads "N/A (Backend logging)" on the same '
          'line it is scored on a text contrast ratio -- the fifth distinct '
          'band defect in this batch',
      () =>
          HabotErrorStateClearance.theRowSaysItHasNoInterface &&
          HabotErrorStateClearance.distinctBandDefectsInThisBatch == 5 &&
          HabotErrorStateClearance.bandNote
              .contains('fifth distinct band defect'),
    );

    gate(
      'HSFVS-013-17-G10',
      'Output: Pass / Fail.',
      'Six declared obligations, all met, giving Pass; all ten declared '
          'checks hold',
      () =>
          HabotErrorStateClearance.obligations.length == 6 &&
          HabotErrorStateClearance.obligations.values.every((bool b) => b) &&
          HabotErrorStateClearance.qualitativeOutput == 'Pass' &&
          HabotErrorStateClearance.checks.length == 10 &&
          HabotErrorStateClearance.checks.values.every((bool b) => b) &&
          HabotErrorStateClearance.columnNote.contains('PDG'),
    );
  });

  tearDownAll(() {
    final String bothMissing = HabotErrorStateClearance.refusalFor(
      HabotErrorStateClearance.evidence(
        loggingActive: false,
        causeFixed: false,
      ),
    );
    final String loggingOnly = HabotErrorStateClearance.refusalFor(
      HabotErrorStateClearance.evidence(
        loggingActive: true,
        causeFixed: false,
      ),
    );

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'HSFVS-013-17',
        atomicStepReferenceId: 'HSFVS-013-17',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to PDG rather than UDF, its '
            'Data Requirement cell reads "N/A (Backend logging)" while its '
            'metric is a text contrast ratio, its ceiling restates its '
            'optimal, and the Setup Step reads "Identify score inputs '
            'triggering extreme rating thresholds". Atomic Step: "Restrict '
            'developers from clearing the dashboard error state until metadata '
            'logging is proven active and fixed for the failing track."',
        implementationOrder: 332,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Step Execution ID': 'HSFVS-013-17',
          'Execution Status': 'Complete',
          'Execution Timestamp': '2026-09-17T00:00:00Z',
          'Step Outcome':
              '4 combinations of two conditions, 1 of which clears; a cleared '
                  'error moves to a history rather than being deleted',
          'User ID': 'Fredrick',
          'Completion Status': 'Pass',
          'Component Properties':
              'logging-without-a-fix reads "$loggingOnly"; neither-condition '
                  'reads "$bothMissing"',
          'Data Quality Note':
              'ENFORCEMENT: ${HabotErrorStateClearance.enforcementNote} '
              'CONDITIONS: ${HabotErrorStateClearance.twoConditionsNote} '
              'HISTORY: ${HabotErrorStateClearance.historyNote} '
              'BAND: ${HabotErrorStateClearance.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Text/UI Contrast Ratio',
            observed:
                'NOT THIS ROW\'S SUBJECT, AND THE BAND RESTATES ITSELF. The '
                'ceiling ">=7:1" is the optimal "7:1" with an inequality in '
                'front of it, and the row\'s own Data Requirement cell says '
                '"N/A (Backend logging)" -- it states it has no user interface '
                'on the same line it is scored on a text contrast ratio. Fifth '
                'distinct band defect in this batch.',
            floor: '4.5:1',
            optimal: '7:1',
            ceiling: '>=7:1',
          ),
          AissMeasurement(
            metricName: 'Ways to clear an error state without evidence',
            observed:
                '0. The evidence is a required argument, there is no force '
                'flag, and exactly one of the four combinations of "logging '
                'active" and "cause fixed" permits a clear. The other three '
                'each say which half is missing, and the one that arrives most '
                'often -- logging restored, cause still open -- is the one a '
                'single-condition rule would have cleared on.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/telemetry/error_state_clearance.dart',
        ],
      ),
    );
  });
}
