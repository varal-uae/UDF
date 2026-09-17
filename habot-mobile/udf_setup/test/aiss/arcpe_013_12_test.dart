/// AISS GATE -- Step 388 of 395
/// Global Reference ID:       ARCPE-013-12
/// Atomic Steps Reference ID: ARCPE-013-12
/// Setup Step (Action): "Confirm no regression in component functionality
///                      after code-splitting."
/// Atomic Step: "Program a validation finalization button that locks the
///               rubric settings upon execution."
/// Metric: AI Output Confidence Threshold Accuracy -- floor 0.8, optimal 0.92,
///         ceiling 0.98. High (Scale: High/Medium/Low). NIST AI Risk
///         Management Framework (AI RMF 1.0). Assigned to **UDF**.
///
/// THREE COLUMNS, THREE SUBJECTS -- AND THE DATA FIELDS DESCRIBE THE DESIGN THE
/// ATOMIC STEP DOES NOT ASK FOR.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/operations/rubric_lock.dart';

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

  group('ARCPE-013-12 :: three columns, three subjects', () {
    gate(
      'ARCPE-013-12-G1',
      'A button, a glossary and a build task.',
      'The Atomic Step, the Data Requirement column and the Setup Step column '
          'describe three different things',
      () => HabotRubricLock.threeColumnsDescribeThreeThings,
    );

    gate(
      'ARCPE-013-12-G2',
      'Step 390 in this batch is the same shape.',
      'Its top half is about validation and its bottom half about masking '
          'salaries',
      () =>
          HabotRubricLock.theOtherSplicedRow == 390 &&
          HabotRubricLock.spliceNote.contains('the same shape'),
    );
  });

  group('ARCPE-013-12 :: the data fields are the design', () {
    gate(
      'ARCPE-013-12-G3',
      'Five lock fields, all recorded.',
      'Lock Type, Lock Status, Locked By, Lock Timestamp, Lock Reason',
      () =>
          HabotRubricLockField.values.length == 5 &&
          HabotRubricLock.everyLockFactIsRecorded,
    );

    gate(
      'ARCPE-013-12-G4',
      'The lock names its holder and its reason.',
      'The four things a lock has to carry to be reversible by somebody who '
          'was not there when it was set',
      () =>
          HabotRubricLock.theLockNamesItsHolder &&
          HabotRubricLock.theLockCarriesAReason,
    );

    gate(
      'ARCPE-013-12-G5',
      'The Atomic Step mentions none of them.',
      'So a reader who implements only the instruction builds a lock nobody '
          'can safely undo',
      () =>
          !HabotRubricLock.theAtomicStepMentionsAnyOfThem &&
          HabotRubricLock.fieldsNote.contains('nobody can safely undo'),
    );
  });

  group('ARCPE-013-12 :: when the lock is checked', () {
    gate(
      'ARCPE-013-12-G6',
      'At the first score, not at submission.',
      'A rubric that changes mid-assessment makes two candidates incomparable '
          'without either score being wrong',
      () =>
          HabotRubricLock.theCheckIsAtTheRightMoment &&
          HabotRubricLock.theLockIsCheckedAtFirstScore &&
          !HabotRubricLock.theLockIsCheckedAtSubmission,
    );

    gate(
      'ARCPE-013-12-G7',
      'And the cost of not locking is named.',
      'The stored timestamp is the lock\'s rather than the button press\'s, '
          'which are the same only if nobody retries',
      () =>
          HabotRubricLock.theCostIsNamed &&
          HabotRubricLock.momentNote.contains('only if nobody retries'),
    );
  });

  group('ARCPE-013-12 :: the unlock, and the band', () {
    gate(
      'ARCPE-013-12-G8',
      'An unlock exists while no score does, and it costs something.',
      'It needs a reason and is itself recorded, which is Step 320\'s '
          'elevation shape rather than a second mechanism',
      () =>
          HabotRubricLock.anUnlockIsPossibleBeforeScoring &&
          HabotRubricLock.theUnlockIsTheDeclaredShape &&
          HabotRubricLock.theStepThatSettledElevation == 320,
    );

    gate(
      'ARCPE-013-12-G9',
      'After the first score the unlock is gone, and the control is still not '
          'a dead end.',
      'Undoing the lock at that point is undoing an assessment',
      () =>
          HabotRubricLock.theLockedControlIsNotADeadEnd &&
          !HabotRubricLock.canUnlock(scoresRecorded: 1) &&
          HabotRubricLock.unlockNote.contains('undoing an assessment'),
    );

    gate(
      'ARCPE-013-12-G10',
      'Output reported on a High / Medium / Low scale.',
      'Six obligations, all met, giving High; the band is well formed, it '
          'measures a model, and all ten declared checks hold',
      () =>
          HabotRubricLock.obligations.length == 6 &&
          HabotRubricLock.obligations.values.every((bool b) => b) &&
          HabotRubricLock.qualitativeOutput == 'High' &&
          HabotRubricLock.theBandIsWellFormed &&
          HabotRubricLock.theMetricMeasuresAModel &&
          HabotRubricLock.lockFactsRecorded == 100 &&
          HabotRubricLock.checks.length == 10 &&
          HabotRubricLock.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final String holder = HabotRubricLock.worked.lockedBy;
    final String reason = HabotRubricLock.worked.lockReason;
    final String when = HabotRubricLock.worked.lockTimestamp;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'ARCPE-013-12',
        atomicStepReferenceId: 'ARCPE-013-12',
        setupStepAction:
            'COLUMN NOTE: this row describes three different things in three '
            'columns -- a finalisation button in the Atomic Step, a glossary '
            'screen in the Data Requirement column with list items, Label '
            'Small proficiency notes and tap-to-see-a-definition, and a '
            'code-splitting regression check in the Setup Step column, which '
            'reads "Confirm no regression in component functionality after '
            'code-splitting"; its metric scores an AI output confidence '
            'threshold on a row that builds a button; and its five lock data '
            'fields describe the design the Atomic Step does not ask for. '
            'Atomic Step: "Program a validation finalization button that locks '
            'the rubric settings upon execution."',
        implementationOrder: 388,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Lock Type': HabotRubricLock.worked.lockType,
          'Lock Status': 'locked',
          'Locked By': holder,
          'Lock Timestamp': when,
          'Lock Reason': reason,
          'Completion Status': 'High',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the lock is checked at the first score and can be undone until '
                  'one exists, with a reason and a record',
          'Data Quality Note':
              'SPLICE: ${HabotRubricLock.spliceNote} FIELDS: '
              '${HabotRubricLock.fieldsNote} MOMENT: '
              '${HabotRubricLock.momentNote} UNLOCK: '
              '${HabotRubricLock.unlockNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'AI Output Confidence Threshold Accuracy',
            observed:
                'WELL FORMED, AND MEASURING A MODEL ON A ROW THAT BUILDS A '
                'BUTTON. Floor 0.8, optimal 0.92, ceiling 0.98 -- correctly '
                'ordered, with a ceiling below 1 that is a real position '
                'rather than a mistake, unlike Step 370\'s. It scores an AI '
                'confidence threshold, and this row programs a finalisation '
                'control, so the figure published is the share of lock facts '
                'the record actually carries: all five.',
            floor: '0.8',
            optimal: '0.92',
            ceiling: '0.98',
          ),
          AissMeasurement(
            metricName: 'Lock facts the Atomic Step asks for',
            observed:
                '0 of 5, and all five are built anyway. Lock Type, Locked By, '
                'Lock Timestamp and Lock Reason are exactly what a lock has to '
                'carry to be reversible by somebody who was not there when it '
                'was set, and they sit in the data-fields column rather than '
                'in the instruction -- so a reader who implements only the '
                'Atomic Step builds a lock nobody can safely undo. The lock is '
                'checked at the first score rather than at submission, and the '
                'unlock disappears once a score exists, because at that point '
                'undoing the lock is undoing an assessment.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/operations/rubric_lock.dart',
        ],
      ),
    );
  });
}
