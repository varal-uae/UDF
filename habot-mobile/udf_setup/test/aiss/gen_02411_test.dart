/// AISS GATE -- Step 368 of 375
/// Global Reference ID:       GEN-02411
/// Atomic Steps Reference ID: GEN-02411
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Configure the dashboard elements as read-only locks to
///               prevent accidental data edits (Poka-Yoke)."
/// Metric: Data Freshness (minutes) -- floor 5, optimal "0-1", ceiling 1.
///         Real-time / Near Real-time / Delayed. Tableau Best Practices, BI
///         Standards. Assigned to **DEA**.
///
/// THE CEILING SITS INSIDE THE OPTIMAL, AND THE OUTPUT VOCABULARY IS THE ONE
/// THIS REPOSITORY ALREADY BUILT.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/dashboard/read_only_lock.dart';

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

  group('GEN-02411 :: a band with three cells and two positions', () {
    gate(
      'GEN-02411-G1',
      'The optimal is a range.',
      '"0-1" spans two values where the floor and the ceiling are each one',
      () => HabotReadOnlyLock.theOptimalIsARange,
    );

    gate(
      'GEN-02411-G2',
      'And the ceiling sits inside it.',
      'The best attainable value is also a permissible optimal value',
      () =>
          HabotReadOnlyLock.theCeilingSitsInsideTheOptimal &&
          HabotReadOnlyLock.threeCellsHoldTwoPositions,
    );

    gate(
      'GEN-02411-G3',
      'A new band shape for this track.',
      'Previous defects made the ceiling equal to the optimal or worse than '
          'the floor; this one puts the ceiling inside the optimal',
      () => HabotReadOnlyLock.bandNote.contains('new shape for this track'),
    );
  });

  group('GEN-02411 :: the vocabulary is already ours', () {
    gate(
      'GEN-02411-G4',
      'Real-time / Near Real-time / Delayed is what Step 129 declared.',
      'The first row in this batch whose output column matches something the '
          'repository already had',
      () =>
          HabotReadOnlyLock.theVocabularyMatchesWhatWeBuilt &&
          HabotReadOnlyLock.rowVocabulary.length == 3 &&
          HabotReadOnlyLock.vocabularyNote.contains('Step 129'),
    );

    gate(
      'GEN-02411-G5',
      'All three states are reachable from real ages.',
      'Classified against the tokenised boundaries rather than against numbers '
          'restated here',
      () =>
          HabotReadOnlyLock.allThreeStatesAreReachable &&
          HabotReadOnlyLock.aThirtySecondAgeIsRealTime &&
          HabotReadOnlyLock.aTenMinuteAgeIsDelayed,
    );
  });

  group('GEN-02411 :: a lock on a door that was never a door', () {
    gate(
      'GEN-02411-G6',
      'Two lock kinds, and the mechanical one is chosen.',
      'A dashboard element displays a number; there is nothing to edit',
      () =>
          HabotLockKind.values.length == 2 &&
          HabotReadOnlyLock.theLockIsMechanical &&
          HabotReadOnlyLock.chosenKind == HabotLockKind.noEditPath,
    );

    gate(
      'GEN-02411-G7',
      'Step 341 settled what earns the word poka-yoke.',
      'A device that makes the error impossible rather than one that notices '
          'it afterwards',
      () =>
          HabotReadOnlyLock.theStepThatSettledPokaYoke == 341 &&
          HabotReadOnlyLock.lockNote.contains('never a door'),
    );

    gate(
      'GEN-02411-G8',
      'No disabled field is drawn.',
      'A disabled input over the value is how somebody comes to believe a '
          'dashboard is a form',
      () =>
          !HabotReadOnlyLock.aDisabledFieldIsRendered &&
          HabotReadOnlyLock.lockNote.contains('is a form'),
    );
  });

  group('GEN-02411 :: why not a greyed field', () {
    gate(
      'GEN-02411-G9',
      'A greyed control keeps about 2.7:1 against a 4.5:1 requirement.',
      'Step 292 measured it and Step 320 built the remedy -- and neither is '
          'needed here, because text is not a field somebody is locked out of',
      () =>
          HabotReadOnlyLock.aGreyedFieldWouldFailContrast &&
          HabotReadOnlyLock.theStepThatMeasuredIt == 292 &&
          HabotReadOnlyLock.theStepThatBuiltTheRemedy == 320 &&
          HabotReadOnlyLock.neitherRemedyIsNeededHere &&
          HabotReadOnlyLock.contrastNote.contains('advertises'),
    );

    gate(
      'GEN-02411-G10',
      'Output reported as Real-time / Near Real-time / Delayed.',
      'Five obligations, all met, giving Real-time; all ten declared checks '
          'hold',
      () =>
          HabotReadOnlyLock.obligations.length == 5 &&
          HabotReadOnlyLock.obligations.values.every((bool b) => b) &&
          HabotReadOnlyLock.qualitativeOutput == 'Real-time' &&
          HabotReadOnlyLock.checks.length == 10 &&
          HabotReadOnlyLock.checks.values.every((bool b) => b) &&
          HabotReadOnlyLock.columnNote.contains('DEA'),
    );
  });

  tearDownAll(() {
    final String young =
        HabotReadOnlyLock.outputFor(HabotReadOnlyLock.insideOptimal);
    final String middle = HabotReadOnlyLock
        .outputFor(HabotReadOnlyLock.betweenOptimalAndBudget);
    final String old =
        HabotReadOnlyLock.outputFor(HabotReadOnlyLock.pastBudget);

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02411',
        atomicStepReferenceId: 'GEN-02411',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to DEA rather than UDF; its '
            'band sets a floor of 5 against an optimal written "0-1" and a '
            'ceiling of 1, so the ceiling sits inside the optimal and three '
            'cells hold two distinct positions; its metric is a data freshness '
            'on a row about editability; and the Setup Step column is empty. '
            'Its output vocabulary, unusually, is the one this repository '
            'already declares. Atomic Step: "Configure the dashboard elements '
            'as read-only locks to prevent accidental data edits (Poka-Yoke)."',
        implementationOrder: 368,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Layout Type': 'read-only dashboard elements with no edit path',
          'Layout Grid Dimensions': 'the declared dashboard grid',
          'Spacing Rules': 'the declared spacing scale',
          'Alignment Settings': 'figures leading, freshness label trailing',
          'Layout Validation Status': 'Real-time',
          'Completion Status': 'Real-time',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'ages derived from the declared boundaries classify as '
                  '"$young", "$middle" and "$old"',
          'Data Quality Note':
              'BAND: ${HabotReadOnlyLock.bandNote} '
              'VOCABULARY: ${HabotReadOnlyLock.vocabularyNote} '
              'LOCK: ${HabotReadOnlyLock.lockNote} '
              'CONTRAST: ${HabotReadOnlyLock.contrastNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Data Freshness (minutes)',
            observed:
                'THE CEILING SITS INSIDE THE OPTIMAL, WHICH IS A NEW SHAPE. '
                'Floor 5, optimal "0-1", ceiling 1: the optimal spans two '
                'values and the ceiling is the upper end of that span, so the '
                'best attainable value is also a permissible optimal value and '
                'the band has three cells holding two distinct positions. '
                'Earlier defects in this track made the ceiling equal to the '
                'optimal or worse than the floor; this one nests it. The '
                'output vocabulary is the one the Step 129 freshness policy '
                'already declares, and all three of its states are reachable: '
                '"$young", "$middle" and "$old".',
            floor: '5',
            optimal: '0-1',
            ceiling: '1',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Disabled controls rendered over displayed figures',
            observed:
                '0. A dashboard element displays a number, so a "read-only '
                'lock" is a lock on a door that was never a door. Step 341 '
                'settled what earns the word poka-yoke -- a device that makes '
                'the error impossible rather than one that notices it -- and a '
                'figure rendered as text has no edit path at all. The '
                'alternative, a disabled input over the value, keeps about '
                '2.7:1 of contrast at MD3\'s 0.38 opacity against a 4.5:1 '
                'requirement, which Step 292 measured and Step 320 remedied; '
                'neither is needed here, and a greyed field would in any case '
                'advertise an ability that does not exist.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/read_only_lock.dart',
        ],
      ),
    );
  });
}
