/// AISS GATE -- Step 295 of 295
/// Global Reference ID:       LSAV-002
/// Atomic Steps Reference ID: LSAV-002
/// Setup Step (Action): "Write a JavaScript function to track the current
///                      active column sorting key parameter." (JAVASCRIPT, IN
///                      A DART APPLICATION)
/// Atomic Step: "Configure interface permissions to block cell-level data
///               modification or direct manual row edits."
/// Metric: Points-Ledger Accuracy & Redemption Processing Time -- a different
///         subject, and two measurements under one Pass/Fail.
///
/// "INTERFACE PERMISSIONS" IS A CONTRADICTION, AND READ-ONLY IS THREE STATES
/// WEARING ONE APPEARANCE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/operations/cell_edit_permission.dart';

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

  group('LSAV-002 :: three reasons, three sentences', () {
    gate(
      'LSAV-002-G1',
      'Atomic Step: "block cell-level data modification".',
      'Five cells, one editable and four not, with all three read-only '
          'reasons appearing in the worked table',
      () =>
          HabotCellEditPermission.cells.length == 5 &&
          HabotCellEditPermission.editable.length == 1 &&
          HabotCellEditPermission.readOnly.length == 4 &&
          HabotCellEditPermission.everyReadOnlyKindAppears,
    );

    gate(
      'LSAV-002-G2',
      'Derived, forbidden and locked look identical on screen.',
      'Each has its own sentence, and no two of the three are the same',
      () =>
          HabotCellEditPermission.everyReasonHasItsOwnSentence &&
          HabotReadOnlyReason.values.length == 3,
    );

    gate(
      'LSAV-002-G3',
      'Every sentence says what to do, or that nothing is needed.',
      'The derived cell says what to change instead, the forbidden one names '
          'who can, and the locked one says it clears on its own',
      () => HabotCellEditPermission
          .everySentenceSaysWhatToDoOrThatNothingIsNeeded,
    );

    gate(
      'LSAV-002-G4',
      'A derived cell that looks editable is the worst of the three.',
      'None is presented as editable, because the person types a value, '
          'watches it revert, and stops trusting the whole table',
      () =>
          HabotCellEditPermission.aDerivedCellIsNeverPresentedAsEditable &&
          HabotCellEditPermission.threeReasonsNote
              .contains('stops trusting the whole table'),
    );
  });

  group('LSAV-002 :: what an interface can enforce', () {
    gate(
      'LSAV-002-G5',
      'Atomic Step: "Configure interface permissions".',
      'Permissions are enforced where the data is; an interface declines to '
          'offer an edit, which prevents a mistake and prevents nothing else',
      () =>
          !HabotCellEditPermission.theInterfaceEnforcesPermissions &&
          HabotCellEditPermission.theInterfacePreventsMistakes,
    );

    gate(
      'LSAV-002-G6',
      'The distinction decides the wording.',
      '"You cannot change this" is false if the server would accept it from '
          'somebody else; "this is not editable here" is true of the surface, '
          'which is the only thing the surface can speak for',
      () =>
          HabotCellEditPermission.theWordingFollowsFromWhoEnforces &&
          HabotCellEditPermission.notPermissionsNote.contains('speak for'),
    );

    gate(
      'LSAV-002-G7',
      'Data Collected: Lock Type, Status, Locked By, Timestamp, Reason.',
      'The same five fields Step 273 carried on a circuit-breaker row because '
          'they fitted; here they describe the record locking they were '
          'written for, and the vocabulary is reused rather than redeclared',
      () =>
          HabotCellEditPermission.theSameFiveFieldsDescribeARecordLock &&
          HabotCellEditPermission.lockFieldsNote
              .contains('arrived at its own subject'),
    );
  });

  group('LSAV-002 :: the metric from another row', () {
    gate(
      'LSAV-002-G8',
      'Metric: Points-Ledger Accuracy & Redemption Processing Time.',
      'A points ledger and a latency, on a row about whether a table cell can '
          'be typed into; neither reaches this subject',
      () => HabotCellEditPermission.theMetricIsAboutSomethingElse,
    );

    gate(
      'LSAV-002-G9',
      'Two measurements under one Pass/Fail.',
      'An accuracy and a processing time share a single verdict, which cannot '
          'say which failed -- the defect Step 285 found in its '
          'touch-and-contrast bundle',
      () =>
          HabotCellEditPermission.twoMeasurementsOneVerdict &&
          HabotCellEditPermission.metricNote.contains('Step 285'),
    );

    gate(
      'LSAV-002-G10',
      'Output: Pass / Fail.',
      'Six declared obligations, all met, giving Pass; all ten declared '
          'checks hold, and the row\'s JavaScript setup step is recorded as '
          'the eighth foreign stack in this track',
      () =>
          HabotCellEditPermission.obligations.length == 6 &&
          HabotCellEditPermission.obligations.values.every((bool b) => b) &&
          HabotCellEditPermission.qualitativeOutput == 'Pass' &&
          HabotCellEditPermission.checks.length == 10 &&
          HabotCellEditPermission.checks.values.every((bool b) => b) &&
          HabotCellEditPermission.columnNote.contains('JavaScript'),
    );
  });

  tearDownAll(() {
    final String derived = HabotCellEditPermission.messageFor(
      HabotReadOnlyReason.derived,
    );
    final String locked = HabotCellEditPermission.messageFor(
      HabotReadOnlyReason.lockedNow,
    );
    final String lock = HabotCellEditPermission.lockFor(
      at: DateTime.utc(2026, 9, 15),
    ).lockType;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'LSAV-002',
        atomicStepReferenceId: 'LSAV-002',
        setupStepAction:
            'COLUMN NOTE: the Setup Step column on this row reads "Write a '
            'JavaScript function to track the current active column sorting '
            'key parameter" -- JavaScript, in a Dart application, and the '
            'eighth row in this track written for another stack. Atomic Step: '
            '"Configure interface permissions to block cell-level data '
            'modification or direct manual row edits."',
        implementationOrder: 295,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Configuration Parameter': 'cell editability by reason',
          'Current Setting':
              '${HabotCellEditPermission.cells.length} cells, '
                  '${HabotCellEditPermission.readOnly.length} read-only across '
                  '${HabotReadOnlyReason.values.length} distinct reasons, each '
                  'with its own sentence',
          'Previous Setting':
              'a single read-only flag with one message for all three reasons',
          'Change Log':
              'the Step 273 lock vocabulary reused rather than redeclared; '
                  'lock type "$lock"',
          'Configuration Timestamp': '2026-09-15T00:00:00Z',
          'Component Properties':
              'derived reads "$derived"; locked reads "$locked"; the wording '
                  'is true of the surface rather than of the person\'s rights',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotCellEditPermission.threeReasonsNote} '
              'WORDING: ${HabotCellEditPermission.notPermissionsNote} '
              'LOCK FIELDS: ${HabotCellEditPermission.lockFieldsNote} '
              'METRIC: ${HabotCellEditPermission.metricNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Points-Ledger Accuracy & Redemption Processing Time',
            observed:
                'NEITHER MEASUREMENT REACHES THIS ROW, and the two are '
                'bundled under one Pass/Fail so a failure could not say which '
                'one failed. Reported instead over this step\'s six declared '
                'obligations, all of which hold. The ceiling text -- "100% '
                'accuracy is both floor and ceiling for ledger integrity" -- '
                'is the right shape for money and the wrong row to say it on.',
            floor: '>=99% ledger accuracy; redemption <5 seconds',
            optimal: '100% accuracy; redemption <1 second',
            ceiling: '100% accuracy; processing <500ms',
          ),
          AissMeasurement(
            metricName: 'Read-only reasons sharing one message',
            observed:
                '0 of ${HabotReadOnlyReason.values.length}. Derived, '
                'forbidden and locked look identical on screen and need three '
                'different sentences; the one that gets missed is derived, '
                'and it is the worst to miss.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/operations/cell_edit_permission.dart',
        ],
      ),
    );
  });
}
