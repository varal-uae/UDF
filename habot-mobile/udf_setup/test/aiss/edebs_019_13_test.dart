/// AISS GATE -- Step 282 of 295
/// Global Reference ID:       EDEBS-019-13
/// Atomic Steps Reference ID: EDEBS-019-13
/// Setup Step (Action): "Match skeleton placeholder layout frame sizes exactly
///                      to corresponding live query text areas." (DIFFERENT
///                      SUBJECT)
/// Atomic Step: "Position Snackbar notification at bottom of screen reading
///               'Action Failed'."
/// Metric: Observability / Alert Coverage -- Floor ">=90%", Optimal 1,
///         Ceiling 1. Good / Average / Poor. The twin of Step 281's metric.
///
/// "ACTION FAILED" PASSES THE EXISTING PRESENTABILITY GATE AND TELLS NOBODY
/// ANYTHING. THE TWO TESTS ARE ORTHOGONAL AND BOTH ARE REQUIRED.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/feedback/action_failed_snackbar.dart';

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

  group('EDEBS-019-13 :: safe and empty', () {
    gate(
      'EDEBS-019-13-G1',
      'Atomic Step: a snackbar "reading \'Action Failed\'".',
      'The row\'s own string passes the existing leakage gate and fails the '
          'complementary test this step adds, which is the finding stated as '
          'a measurement',
      () => HabotActionFailedSnackbar
          .theRowsStringPassesTheOldGateAndFailsTheNewOne,
    );

    gate(
      'EDEBS-019-13-G2',
      'It fails both halves of the new test.',
      'It names no action, so a person with two pending operations cannot '
          'tell which stopped, and offers no next move',
      () =>
          HabotActionFailedSnackbar.itFailsBothHalvesOfTheNewTest &&
          HabotActionFailedSnackbar.whichActionNote.contains('into three'),
    );

    gate(
      'EDEBS-019-13-G3',
      'A corpus where the tests agree tests nothing.',
      'Four messages cover all four combinations of leaky and empty, so '
          'neither test is passing on the strength of the other',
      () =>
          HabotActionFailedSnackbar.theCorpusSeparatesTheTwoTests &&
          HabotActionFailedSnackbar.corpus.length == 4,
    );

    gate(
      'EDEBS-019-13-G4',
      'The existing gate is not at fault.',
      'It was built to stop internals reaching a user and does exactly that; '
          'the orthogonality is recorded rather than the older rule blamed, '
          'and the replacement message survives both',
      () =>
          HabotActionFailedSnackbar.theReplacementSurvivesBoth &&
          HabotActionFailedSnackbar.orthogonalNote.contains('doing its job'),
    );
  });

  group('EDEBS-019-13 :: where it sits, and what belongs on it', () {
    gate(
      'EDEBS-019-13-G5',
      'Atomic Step: "at bottom of screen".',
      'The bottom is already occupied: Step 176 anchored the FAB there and '
          'Step 226 declared the space a floating snackbar reserves',
      () =>
          HabotActionFailedSnackbar.theBottomIsOccupied &&
          HabotActionFailedSnackbar.reservedBottomSpaceDp > 0,
    );

    gate(
      'EDEBS-019-13-G6',
      'A snackbar over a button is dismissed by the press meant for it.',
      'The consequence -- the message gone and the action not taken -- is '
          'recorded rather than left as a layout preference',
      () => HabotActionFailedSnackbar.bottomEdgeNote
          .contains('did not happen'),
    );

    gate(
      'EDEBS-019-13-G7',
      'A snackbar disappears on its own.',
      'Only a failure the person can afford to miss belongs on one; work lost '
          'or money moved routes to the dialog at Step 281, decided by two '
          'booleans rather than a judgement at the call site',
      () =>
          HabotActionFailedSnackbar.aCostlyFailureGoesElsewhere &&
          HabotActionFailedSnackbar.transienceNote.contains('two booleans'),
    );

    gate(
      'EDEBS-019-13-G8',
      'Metric: Observability / Alert Coverage -- the twin of Step 281.',
      'The same metric on a different surface, about neither; five coverage '
          'obligations all hold, giving Good, and all ten declared checks '
          'pass',
      () =>
          HabotActionFailedSnackbar.coverage.length == 5 &&
          HabotActionFailedSnackbar.coverage.values.every((bool b) => b) &&
          HabotActionFailedSnackbar.coverageRate == 1.0 &&
          HabotActionFailedSnackbar.qualitativeOutput == 'Good' &&
          HabotActionFailedSnackbar.twinMetricNote.contains('Step 281') &&
          HabotActionFailedSnackbar.checks.length == 10 &&
          HabotActionFailedSnackbar.checks.values.every((bool b) => b) &&
          HabotActionFailedSnackbar.columnNote.contains('skeleton'),
    );
  });

  tearDownAll(() {
    final String reserved = HabotActionFailedSnackbar.reservedBottomSpaceDp
        .toStringAsFixed(0);
    final String safeEmpty =
        '${HabotActionFailedSnackbar.safeButEmpty.length}';
    final String leaky = '${HabotActionFailedSnackbar.leaky.length}';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'EDEBS-019-13',
        atomicStepReferenceId: 'EDEBS-019-13',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Match '
            'skeleton placeholder layout frame sizes exactly to corresponding '
            'live query text areas", and the Data Requirement column reads '
            '"N/A (Backend database setup)" four times. Atomic Step: '
            '"Position Snackbar notification at bottom of screen reading '
            '\'Action Failed\'."',
        implementationOrder: 282,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotActionFailedSnackbar',
          'Component Properties':
              '${HabotActionFailedSnackbar.corpus.length} messages across all '
              'four combinations -- $safeEmpty safe and empty, $leaky leaky, '
              'one usable; ${reserved}dp reserved above the FAB; costly '
              'failures routed to the Step 281 dialog',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotActionFailedSnackbar.orthogonalNote} '
              'MESSAGE: ${HabotActionFailedSnackbar.whichActionNote} '
              'PLACEMENT: ${HabotActionFailedSnackbar.bottomEdgeNote} '
              'TWIN: ${HabotActionFailedSnackbar.twinMetricNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Observability / Alert Coverage',
            observed:
                'NOT THE SAME KIND OF ALERT, and the identical metric appears '
                'on Step 281. Substituted: coverage over this surface\'s five '
                'obligations, which is 100% for the replacement message and '
                '40% for the string the row asks for.',
            floor: '>=90%',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Messages that pass the leakage gate and say nothing',
            observed:
                '$safeEmpty of ${HabotActionFailedSnackbar.corpus.length}, '
                'and it is the row\'s own string. The existing gate checks '
                'for internals reaching a user and does that correctly; '
                'emptiness is a different failure and needs a different test.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/feedback/action_failed_snackbar.dart',
        ],
      ),
    );
  });
}
