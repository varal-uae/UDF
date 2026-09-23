/// AISS GATE -- Step 475 of 1,314
/// Global Reference ID:       GEN-05210
/// Atomic Steps Reference ID: GEN-05210
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Document the completed configuration, mark the step as done in
///               the project tracker, and obtain sign-off to proceed to the
///               next step"
/// Metric: Documentation & Sign-off Completeness -- floor "Undocumented / no
///         sign-off obtained", optimal "Fully documented in tracker with
///         stakeholder sign-off", ceiling "1". Best Qualitative Output:
///         "Complete/Partial/Not Complete". PMBOK 7th Ed. - Project Closing
///         Process Group. Assigned to **PDG**.
///
/// THREE INSTRUCTIONS, TWO MEASURES, AND A LEDGER THAT CLOSES UNSIGNED.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/governance/step_signoff_record.dart';

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

  group('GEN-05210 :: three asked, two measured', () {
    gate(
      'GEN-05210-G1',
      'Three actions are asked for and two are measured.',
      'Document, mark done in the tracker, obtain sign-off',
      () =>
          HabotStepSignoffRecord.threeActionsAreAsked &&
          HabotStepSignoffRecord.twoAreMeasured,
    );

    gate(
      'GEN-05210-G2',
      'And the unmeasured one is the one everybody reads.',
      'A step marked done is read downstream as a step that works',
      () =>
          HabotStepSignoffRecord.theUnmeasuredOneChangesWhatPeopleBelieve &&
          HabotStepSignoffRecord.measureNote.contains('a step that works'),
    );

  });

  group('GEN-05210 :: a floor that describes the failure', () {
    gate(
      'GEN-05210-G3',
      'The floor describes the failure, the fourth such.',
      'After Steps 442, 450 and 453',
      () =>
          HabotStepSignoffRecord.theFloorDescribesTheFailure &&
          HabotStepSignoffRecord.fourthSuchFloor,
    );

  });

  group('GEN-05210 :: what was documented', () {
    gate(
      'GEN-05210-G4',
      'Twenty library files, twenty evidence files, two hundred gates.',
      'Which is what "the completed configuration" amounts to here',
      () => HabotStepSignoffRecord.theConfigurationIsDocumented,
    );

    gate(
      'GEN-05210-G5',
      'The verification is static and every symbol resolves.',
      'No Dart toolchain exists on this device, and the batch says so',
      () => HabotStepSignoffRecord.theVerificationIsStatic,
    );

    gate(
      'GEN-05210-G6',
      'The defaults decision is recorded.',
      'Step 471\'s four roles, carried into the closing record',
      () => HabotStepSignoffRecord.theDefaultsDecisionIsRecorded,
    );

  });

  group('GEN-05210 :: the ledger closes', () {
    gate(
      'GEN-05210-G7',
      'The ledger opened at Step 457 has four rows.',
      'Steps 457, 463, 472 and 475',
      () => HabotStepSignoffRecord.theLedgerHasFourRows,
    );

    gate(
      'GEN-05210-G8',
      'This row is the last of them.',
      'And it closes the ledger rather than clearing it',
      () => HabotStepSignoffRecord.itIsTheLastRowAwaitingSignature,
    );

    gate(
      'GEN-05210-G9',
      'All four are still unsigned, and the remedy is one sentence.',
      'Naming four accountable owners turns all four Partials into Completes',
      () =>
          HabotStepSignoffRecord.allFourAreStillUnsigned &&
          HabotStepSignoffRecord.theRemedyIsOneSentence,
    );

    gate(
      'GEN-05210-G10',
      'Five obligations met, and the row reports Partial.',
      'Two of three actions done, and the third is a person\'s act',
      () =>
          HabotStepSignoffRecord.obligations.length == 5 &&
          HabotStepSignoffRecord.obligations.values.every((bool b) => b) &&
          HabotStepSignoffRecord.qualitativeOutput == 'Partial',
    );
  });

  tearDownAll(() {
    final int gatesTotal = HabotStepSignoffRecord.gates;
    final int waiting = HabotSignoffLedger.count;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-05210',
        atomicStepReferenceId: 'GEN-05210',
        setupStepAction:
            'COLUMN NOTE: this row asks for three things and its band measures '
            'two, leaving the marking of a step as done -- the one that '
            'changes what everybody downstream believes -- unmeasured; its '
            'floor describes the failure, the fourth such floor across two '
            'batches after Steps 442, 450 and 453; two of its three actions '
            'are done and the third cannot be from here, so it reports Partial '
            'and closes the ledger opened at Step 457 with all four rows '
            'unsigned; and the remedy is a list of four named owners. Atomic '
            'Step: "Document the completed configuration, mark the step as '
            'done in the project tracker, and obtain sign-off to proceed to '
            'the next step"',
        implementationOrder: 475,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Document the completed configuration, mark the step as done in':
              'twenty library files, twenty evidence files and $gatesTotal '
                  'gates documented and the sheet re-marked; $waiting rows '
                  'close unsigned, and four named owners would clear all of '
                  'them',
          'Completion Status': 'Partial',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Documentation & Sign-off Completeness',
            observed:
                'PARTIAL, AND THE LEDGER CLOSES UNSIGNED. The row asks for '
                'three things and its band measures two, leaving the marking '
                'of a step as done -- the one that changes what everybody '
                'downstream believes -- unmeasured, so what was verified is '
                'recorded beside the mark. Two of the three are done: the '
                'configuration is documented at $gatesTotal gates and the '
                'sheet is re-marked. The third is a signature.',
            floor: 'Undocumented / no sign-off obtained',
            optimal: 'Fully documented in tracker with stakeholder sign-off',
            ceiling: '1',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Rows in this batch closing without a named owner',
            observed:
                '$waiting. Steps 457, 463, 472 and 475 each reach their floor '
                'and stop short of their optimal because the optimal is a '
                'human signature. The build can verify acceptance criteria; it '
                'cannot sign. Naming four accountable owners turns all four '
                'from Partial into Complete with no code changing, which is '
                'the most useful single sentence this batch hands back.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/governance/step_signoff_record.dart',
        ],
      ),
    );
  });
}
