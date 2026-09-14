/// AISS GATE -- Step 254 of 255
/// Global Reference ID:       GEN-01992
/// Atomic Steps Reference ID: GEN-01992
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Mathematically gate execution by requiring a strict 'True' to
///               progress."
/// Metric: Mathematical Balance Validation Accuracy (%) -- Floor 99.5, Optimal
///         99.99, Ceiling 100. Complete/Partial/Not Complete. Standard cited:
///         ISO/IEC 27035 & OWASP.
///
/// "STRICT TRUE" IS A RULE ABOUT THE CHECK, NOT ABOUT THE ANSWER. The trap is
/// a nullable boolean tested with != false, and Dart can make that
/// unrepresentable.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/strict_true_gate.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double accuracy = 0;

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

  group('GEN-01992 :: no third value', () {
    gate(
      'GEN-01992-G1',
      'Atomic Step: "requiring a STRICT \'True\' to progress."',
      'The loose check a nullable boolean invites lets an unevaluated gate '
          'through while the strict one does not, and both agree on a real '
          'true and a real false -- so the difference is exactly the '
          'unevaluated case, which is a submitted form',
      () => HabotStrictTrueGate.theLooseCheckPassesAnUnevaluatedGate,
    );

    gate(
      'GEN-01992-G2',
      'Dart can make the tri-state unrepresentable.',
      'The result is a sealed type with two cases, matched by an exhaustive '
          'switch rather than by a default branch -- so a third case added '
          'later does not compile, where a default would have let it through',
      () =>
          HabotStrictTrueGate.theSealedResultHasNoThirdCase &&
          HabotStrictTrueGate.mayProgress(const HabotGateAllowed()) &&
          !HabotStrictTrueGate.mayProgress(
            const HabotGateBlocked(<HabotGateReason>[]),
          ) &&
          HabotStrictTrueGate.triStateNote.contains('not used anywhere'),
    );

    gate(
      'GEN-01992-G3',
      'Step 250: an error has to say what to do about it.',
      'A gate answering only true or false can stop a submission and cannot '
          'explain it, so every blocked result carries at least one reason and '
          'every allowed result carries none',
      () =>
          HabotStrictTrueGate.everyBlockedResultCarriesAReason &&
          HabotStrictTrueGate.everyAllowedResultCarriesNone &&
          HabotStrictTrueGate.everyReasonSaysWhatToDo &&
          HabotStrictTrueGate.booleanIsNotAnInterfaceNote
              .contains('PROGRESS CONDITION'),
    );

    gate(
      'GEN-01992-G4',
      'Two problems at once produce two reasons, not the first one.',
      'A submission that is both unbalanced and missing a field reports both, '
          'because a person who fixes the one they were told about and is then '
          'told about another has been made to submit twice to learn two facts',
      () =>
          HabotStrictTrueGate.reasonsFrom(HabotStrictTrueGate.bothProblems)
                  .length ==
              2 &&
          HabotStrictTrueGate.reasonsFrom(HabotStrictTrueGate.unbalanced)
                  .single
                  .code ==
              'DOES_NOT_BALANCE' &&
          HabotStrictTrueGate.reasonsFrom(
                HabotStrictTrueGate.fieldsOutstanding,
              ).length ==
              2,
    );
  });

  group('GEN-01992 :: what the blocked case is for', () {
    gate(
      'GEN-01992-G5',
      'A blocked submit should put the person at the problem.',
      'Focus goes to the first field-level reason, and a form-level reason '
          'alone moves focus nowhere -- because there is no field to move it '
          'to and pretending otherwise lands somebody on an unrelated input',
      () =>
          HabotStrictTrueGate.focusTargetFrom(
                HabotStrictTrueGate.fieldsOutstanding,
              ) ==
              'allergies' &&
          HabotStrictTrueGate.focusTargetFrom(
                HabotStrictTrueGate.unbalanced,
              ) ==
              null &&
          HabotStrictTrueGate.focusTargetFrom(
                HabotStrictTrueGate.balancedAndComplete,
              ) ==
              null,
    );

    gate(
      'GEN-01992-G6',
      'The arithmetic is Step 253\'s.',
      'The balance reason comes from the reconciliation rather than being '
          'recomputed here, so there is one predicate and this step adds only '
          'the decision built on top of it',
      () =>
          HabotStrictTrueGate.reasonsFrom(HabotStrictTrueGate.unbalanced)
              .single
              .isFormLevel &&
          HabotStrictTrueGate.notMathematicsNote
              .contains('no default branch'),
    );

    gate(
      'GEN-01992-G7',
      'Metric: Mathematical Balance Validation Accuracy (%) -- optimal 99.99.',
      'All eleven checks hold and the four scenarios are decided correctly '
          '-- one progresses and three do not -- giving 100 and a Complete',
      () {
        accuracy = HabotStrictTrueGate.decisionAccuracy;
        return HabotStrictTrueGate.checks.length == 11 &&
            HabotStrictTrueGate.checks.values.every((bool b) => b) &&
            HabotStrictTrueGate.corpus.length == 4 &&
            HabotStrictTrueGate.corpus
                    .where(HabotStrictTrueGate.mayProgress)
                    .length ==
                1 &&
            accuracy == HabotStrictTrueGate.ceiling &&
            HabotStrictTrueGate.qualitativeOutput == 'Complete' &&
            HabotStrictTrueGate.columnNote.contains('only "True"');
      },
    );
  });

  tearDownAll(() {
    final int progressing = HabotStrictTrueGate.corpus
        .where(HabotStrictTrueGate.mayProgress)
        .length;
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01992',
        atomicStepReferenceId: 'GEN-01992',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row and the '
            'Data Collected column reads only "True". Atomic Step: '
            '"Mathematically gate execution by requiring a strict \'True\' to '
            'progress."',
        implementationOrder: 254,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotStrictTrueGate / HabotGateResult / HabotGateReason',
          'Component Properties':
              'A sealed result with two cases and no null; '
              '${HabotStrictTrueGate.corpus.length} scenarios of which '
              '$progressing progresses; every blocked result carrying at '
              'least one reason with a field to focus or an explicit '
              'form-level marker',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotStrictTrueGate.triStateNote} SECOND: '
              '${HabotStrictTrueGate.booleanIsNotAnInterfaceNote} SCOPE: '
              '${HabotStrictTrueGate.notMathematicsNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Mathematical Balance Validation Accuracy (%)',
            observed:
                '${accuracy.toStringAsFixed(2)} over '
                '${HabotStrictTrueGate.corpus.length} scenarios: balanced and '
                'complete progresses; unbalanced, fields outstanding, and '
                'both at once do not, each carrying the reasons it was '
                'blocked for.',
            floor: '99.5',
            optimal: '99.99',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Values a caller could test loosely',
            observed:
                '0. The result is sealed with two cases and no null, matched '
                'by an exhaustive switch, so there is nothing to compare with '
                '!= false and a third case added later would not compile.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/strict_true_gate.dart',
        ],
      ),
    );
  });
}
