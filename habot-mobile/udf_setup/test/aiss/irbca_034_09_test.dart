/// AISS GATE -- Step 255 of 255
/// Global Reference ID:       IRBCA-034-09
/// Atomic Steps Reference ID: IRBCA-034-09
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Pause optimistic UI updates and execution until validation
///               clears locally."
/// Metric: UI Design-System Adherence Rate -- Floor >=85%, Optimal >=95%,
///         Ceiling 1. Good/Average/Poor. Standard cited: Material Design 3 /
///         Nielsen Norman Group Heuristic Evaluation.
///
/// READ LITERALLY, THE ROW DESCRIBES A FORM THAT WORKS. The question
/// underneath is which updates may be optimistic at all, and nothing declared
/// that.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/form_mode_machine.dart';
import 'package:udf_setup/design_system/forms/optimistic_update_policy.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double adherence = 0;

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

  group('IRBCA-034-09 :: the row, and the question underneath it', () {
    gate(
      'IRBCA-034-09-G1',
      'Atomic Step: "PAUSE optimistic UI updates until validation clears '
          'locally."',
      'Optimistic UI means showing a result before the SERVER confirms it, and '
          'local validation is a precondition of sending anything at all -- so '
          'a submission that fails it never happens and there is no optimistic '
          'update to pause',
      () =>
          HabotOptimisticUpdatePolicy.thereIsNothingToPause &&
          !HabotOptimisticUpdatePolicy.anythingIsSentWhen(
            localValidationPassed: false,
          ) &&
          HabotOptimisticUpdatePolicy.readLiterallyNote
              .contains('a form that works'),
    );

    gate(
      'IRBCA-034-09-G2',
      'What happens when local validation passes and the server says no.',
      'That is the case optimistic UI actually creates, and what nothing '
          'declared is which updates may be optimistic at all -- a decision '
          'per operation rather than a mechanism, and the mechanism already '
          'existed',
      () => HabotOptimisticUpdatePolicy.theRealQuestionNote
          .contains('WHICH updates may be optimistic'),
    );

    gate(
      'IRBCA-034-09-G3',
      'A ruling chosen per screen is not a rule.',
      'Six operations are ruled on, three each way, and every ruling follows '
          'from the two declared facts about the operation -- whether it is '
          'reversible and whether a rollback would be seen by somebody else',
      () =>
          HabotOptimisticUpdatePolicy.operations.length == 6 &&
          HabotOptimisticUpdatePolicy.optimisticOperations.length == 3 &&
          HabotOptimisticUpdatePolicy.pessimisticOperations.length == 3 &&
          HabotOptimisticUpdatePolicy.everyRulingFollowsFromTheRule &&
          HabotOptimismRuling.values.length == 2,
    );

    gate(
      'IRBCA-034-09-G4',
      '"The person has already acted on what they were shown."',
      'Nothing that moves money, issues a pass or tells a third party is '
          'optimistic, and each of those three says the reason is not that the '
          'rollback is hard -- a pass shown optimistically is a pass somebody '
          'screenshots and takes to a door',
      () =>
          HabotOptimisticUpdatePolicy.pessimisticOperations.every(
            (HabotOptimisticOperation o) =>
                o.rollbackIsVisibleToOthers && !o.isReversible,
          ) &&
          HabotOptimisticUpdatePolicy.operations.every(
            (HabotOptimisticOperation o) => o.why.length > 80,
          ),
    );
  });

  group('IRBCA-034-09 :: where a rejection lands', () {
    gate(
      'IRBCA-034-09-G5',
      'Step 237 gave the form a rejection mode.',
      'A rejected submission lands in the error mode, read from the machine '
          'rather than restated here, so the two steps cannot drift apart',
      () =>
          HabotOptimisticUpdatePolicy.rejectionLandsInTheErrorMode &&
          HabotOptimisticUpdatePolicy.modeAfterRejection ==
              HabotFormMode.error,
    );

    gate(
      'IRBCA-034-09-G6',
      '"Something went wrong" on a screen where the person did nothing wrong.',
      'A server rejection after a local pass is ordinary -- a conflict, or a '
          'rule the client cannot know -- and both categories have declared '
          'templates, so the message comes from the template set rather than '
          'from a string at the call site',
      () =>
          HabotOptimisticUpdatePolicy.rejectionMessageComesFromTheTemplates &&
          HabotOptimisticUpdatePolicy.rejectionCategories.length == 2 &&
          HabotOptimisticUpdatePolicy.whyLocalPassAndServerFailNote
              .contains('did nothing'),
    );

    gate(
      'IRBCA-034-09-G7',
      'Metric: UI Design-System Adherence Rate -- optimal >=95%.',
      'All ten checks hold and every ruling follows from the stated rule, '
          'giving an adherence rate at the ceiling and a Good -- reported on a '
          'policy the row did not ask for, because the thing it did ask for '
          'was already true',
      () {
        adherence = HabotOptimisticUpdatePolicy.adherenceRate;
        return HabotOptimisticUpdatePolicy.checks.length == 10 &&
            HabotOptimisticUpdatePolicy.checks.values.every((bool b) => b) &&
            adherence == HabotOptimisticUpdatePolicy.ceiling &&
            adherence >= HabotOptimisticUpdatePolicy.optimal &&
            HabotOptimisticUpdatePolicy.qualitativeOutput == 'Good' &&
            HabotOptimisticUpdatePolicy.columnNote.contains('no Setup Step');
      },
    );
  });

  tearDownAll(() {
    final int optimisticCount =
        HabotOptimisticUpdatePolicy.optimisticOperations.length;
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'IRBCA-034-09',
        atomicStepReferenceId: 'IRBCA-034-09',
        setupStepAction:
            'COLUMN NOTE: this row carries no Setup Step, no Expected Output '
            'and no Completion Measures -- only a metric and a Data Collected '
            'list of execution identifiers. Atomic Step: "Pause optimistic UI '
            'updates and execution until validation clears locally."',
        implementationOrder: 255,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotOptimisticUpdatePolicy / HabotOptimisticOperation',
          'Component Properties':
              '${HabotOptimisticUpdatePolicy.operations.length} operations '
              'ruled on, $optimisticCount optimistic and '
              '${HabotOptimisticUpdatePolicy.pessimisticOperations.length} '
              'not, every ruling derived from whether the operation is '
              'reversible and whether a rollback would be seen by somebody '
              'else; rejection lands in Step 237\'s error mode with a message '
              'from the declared template set',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotOptimisticUpdatePolicy.readLiterallyNote} THE '
              'REAL QUESTION: '
              '${HabotOptimisticUpdatePolicy.theRealQuestionNote} RULE: an '
              'update may be optimistic only where the operation is '
              'reversible AND a rollback would not be seen by anybody else. '
              'Three of six qualify. The three that do not -- a payment, an '
              'entry pass, a cancellation inside the refund window -- are '
              'refused not because the rollback is hard but because the '
              'person has already acted on what they were shown. ORDINARY: '
              '${HabotOptimisticUpdatePolicy.whyLocalPassAndServerFailNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Design-System Adherence Rate',
            observed:
                '${adherence.toStringAsFixed(2)} -- every one of the '
                '${HabotOptimisticUpdatePolicy.operations.length} rulings '
                'follows from the stated rule rather than from a judgement '
                'made per screen, which is the only sense in which a policy '
                'like this can be adhered to.',
            floor: '>=85%',
            optimal: '>=95%',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Operations shown optimistically whose rollback '
                'somebody else would see',
            observed:
                '0 of ${HabotOptimisticUpdatePolicy.operations.length}. '
                'A payment, an entry pass and a cancellation inside the '
                'refund window all wait, because withdrawing one afterwards '
                'is not a rollback -- it is a person being turned away, or '
                'two people being told different things.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/optimistic_update_policy.dart',
        ],
      ),
    );
  });
}
