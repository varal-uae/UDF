/// AISS GATE -- Step 237 of 255
/// Global Reference ID:       USMBL-013
/// Atomic Steps Reference ID: USMBL-013-A01
/// Setup Step (Action): present on this row.
/// Atomic Step: "Review the form layout's required component modes (idle,
///               editing, submitting, locked, error)."
/// Metric: Scope Coverage / Audit Completeness -- Floor "80% of relevant items
///         identified", Optimal "100% identified and logged in an inventory
///         register", Ceiling "100% identified, logged, and cross-checked
///         against the design/architecture spec". Complete.
///
/// THE ATOMIC STEP SAYS REVIEW AND THE EXPECTED OUTPUT ASKS FOR A MACHINE.
/// Both are produced. Three of the five modes already existed under other
/// names, and "the instant submission triggers" is a synchronous requirement.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/form_mode_machine.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double coverage = 0;

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

  group('USMBL-013-A01 :: the register', () {
    gate(
      'USMBL-013-A01-G1',
      'Atomic Step lists five modes; Expected Output asks for an FSM.',
      'Both artefacts exist: a register saying where each of the five modes '
          'lives today, and a transition table -- the metric grades the audit '
          'and the Expected Output grades the machine, and they are different '
          'things',
      () =>
          HabotFormMode.values.length == 5 &&
          HabotFormModeMachine.declaredAt.length == 5 &&
          HabotFormModeMachine.transitions.isNotEmpty &&
          HabotFormModeMachine.auditVersusMachineNote
              .contains('different artefacts'),
    );

    gate(
      'USMBL-013-A01-G2',
      'Three of the five already exist under other names.',
      'idle and locked are HabotSubmitState and editing is HabotFormGate\'s '
          'touched state; what exists nowhere is submitting as a mode distinct '
          'from locked, and error as a mode of the form rather than of a field',
      () =>
          HabotFormModeMachine.modesAlreadyDeclared.length == 3 &&
          HabotFormModeMachine.modesThisStepAdds.length == 2 &&
          HabotFormModeMachine.modesThisStepAdds
              .contains(HabotFormMode.submitting) &&
          HabotFormModeMachine.modesThisStepAdds
              .contains(HabotFormMode.error) &&
          HabotFormModeMachine.threeOfFiveNote.contains('no place to put it'),
    );

    gate(
      'USMBL-013-A01-G3',
      'Metric ceiling: "cross-checked against the design/architecture spec."',
      'The spec here is the row\'s own list of five mode names, and every '
          'declared mode matches one of them by name -- so the cross-check is '
          'against the row rather than against a list this file wrote itself',
      () =>
          HabotFormModeMachine.everyRowModeIsRegistered &&
          HabotFormModeMachine.crossCheckedAgainstTheSpec &&
          HabotFormModeMachine.rowsDeclaredModes.length == 5,
    );
  });

  group('USMBL-013-A01 :: the machine', () {
    gate(
      'USMBL-013-A01-G4',
      '"A strict finite state machine manager."',
      'Seven transitions, each with a reason, and an illegal move returns null '
          'rather than silently staying put -- which is what makes it strict '
          'rather than a set of setters',
      () =>
          HabotFormModeMachine.transitions.length == 7 &&
          HabotFormModeMachine.transitions.every(
            (HabotModeTransition t) => t.rationale.length > 60,
          ) &&
          HabotFormModeMachine.next(
                HabotFormMode.locked,
                HabotFormEvent.editResumed,
              ) ==
              null &&
          HabotFormModeMachine.next(
                HabotFormMode.idle,
                HabotFormEvent.responseSucceeded,
              ) ==
              null &&
          HabotFormEvent.values.length == 6,
    );

    gate(
      'USMBL-013-A01-G5',
      'Completion measure: "all interactable components lock completely the '
          'instant form submission triggers."',
      'Nothing leaves the submitting mode except a response, nothing is '
          'interactive while in it, and the synchronous requirement -- the '
          'lock is set before the first await, not after -- is stated as a '
          'property of the machine rather than of one call site',
      () =>
          HabotFormModeMachine.submittingIsSealed &&
          !HabotFormModeMachine.isInteractive(HabotFormMode.submitting) &&
          HabotFormModeMachine.synchronousLockNote
              .contains('before the first await'),
    );

    gate(
      'USMBL-013-A01-G6',
      'Locked is a mode, not a phase of submitting.',
      'Nothing leaves locked, and it is reachable without a submit at all -- a '
          'window closing mid-edit locks the form, which is the transition '
          'that makes the two modes genuinely different',
      () =>
          HabotFormModeMachine.lockedIsTerminal &&
          HabotFormModeMachine.next(
                HabotFormMode.editing,
                HabotFormEvent.policyClosed,
              ) ==
              HabotFormMode.locked &&
          HabotFormModeMachine.next(
                HabotFormMode.idle,
                HabotFormEvent.policyClosed,
              ) ==
              HabotFormMode.locked &&
          !HabotFormModeMachine.isInteractive(HabotFormMode.locked),
    );

    gate(
      'USMBL-013-A01-G7',
      'Metric: Scope Coverage / Audit Completeness -- Complete.',
      'All nine checks hold at 100% coverage, cross-checked against the spec, '
          'so the step reports Complete on both halves of a row that asks for '
          'two different things',
      () {
        coverage = HabotFormModeMachine.scopeCoverage;
        return HabotFormModeMachine.checks.length == 9 &&
            HabotFormModeMachine.checks.values.every((bool b) => b) &&
            coverage == 1.0 &&
            HabotFormModeMachine.qualitativeOutput == 'Complete' &&
            HabotFormModeMachine.columnNote.contains('Setup Step');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'USMBL-013',
        atomicStepReferenceId: 'USMBL-013-A01',
        setupStepAction:
            'Atomic Step: "Review the form layout\'s required component modes '
            '(idle, editing, submitting, locked, error)." Expected Output: "A '
            'strict finite state machine manager governing data submission '
            'lifecycles."',
        implementationOrder: 237,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotFormModeMachine / HabotFormMode',
          'Component Properties':
              '${HabotFormMode.values.length} modes over '
              '${HabotFormEvent.values.length} events with '
              '${HabotFormModeMachine.transitions.length} legal transitions, '
              'each carrying a reason; '
              '${HabotFormModeMachine.modesAlreadyDeclared.length} modes '
              'already declared elsewhere and '
              '${HabotFormModeMachine.modesThisStepAdds.length} added here; '
              'submitting sealed, locked terminal',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'COLUMN: ${HabotFormModeMachine.auditVersusMachineNote} '
              'FINDING: ${HabotFormModeMachine.threeOfFiveNote} SECOND: '
              '${HabotFormModeMachine.synchronousLockNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Scope Coverage / Audit Completeness',
            observed:
                '${(coverage * 100).toStringAsFixed(0)}% -- all '
                '${HabotFormMode.values.length} modes the row names are in '
                'the register with where each lives today, and the register '
                'is cross-checked against the row\'s own list rather than '
                'against a list written here.',
            floor: '80% of relevant items identified',
            optimal: '100% identified and logged in an inventory register',
            ceiling: '100% identified, logged, and cross-checked against the '
                'design/architecture spec',
          ),
          AissMeasurement(
            metricName: 'Modes this step had to add',
            observed:
                '${HabotFormModeMachine.modesThisStepAdds.length} of '
                '${HabotFormMode.values.length}. submitting and error. The '
                'other three were already declared -- two at the submit guard '
                'and one at the form gate -- under different names.',
            floor: '0',
            optimal: '0',
            ceiling: '5',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/form_mode_machine.dart',
        ],
      ),
    );
  });
}
