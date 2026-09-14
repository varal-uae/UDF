/// AISS GATE -- Step 251 of 255
/// Global Reference ID:       PELCE-039
/// Atomic Steps Reference ID: PELCE-039-11
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Program mobile application error controllers to catch backend
///               service unavailability responses gracefully."
/// Metric: Process Execution Quality Score -- Floor >=90%, Optimal >=98%,
///         Ceiling 1. Good/Average/Poor. Standard cited: ISO 9001:2015.
///
/// UNAVAILABILITY IS FOUR SITUATIONS, AND ON ONE OF THEM THE CLIENT DOES NOT
/// KNOW WHETHER THE WRITE HAPPENED. Retrying there charges twice.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/resilience/backend_unavailability.dart';
import 'package:udf_setup/design_system/resilience/error_templates.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double score = 0;

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

  group('PELCE-039-11 :: four situations', () {
    gate(
      'PELCE-039-11-G1',
      'Atomic Step: "catch backend service UNAVAILABILITY responses '
          'gracefully."',
      'Four states are distinguished -- a 503, a timeout, no connection, and a '
          '200 whose body reports a failure -- and each maps onto a category '
          'that already has a message, so no fifth vocabulary is introduced '
          'for the same situations',
      () =>
          HabotUnavailability.values.length == 4 &&
          HabotBackendUnavailability.handlings.length == 4 &&
          HabotBackendUnavailability.everyStateHasAnExistingTemplate &&
          HabotBackendUnavailability.reusesExistingVocabularyNote
              .contains('idempotency dimension'),
    );

    gate(
      'PELCE-039-11-G2',
      '"On a timeout the client does not know whether the write happened."',
      'Exactly one of the four leaves the outcome unknown and it is the '
          'timeout -- the request may have been received, processed and '
          'committed with only the response lost',
      () =>
          HabotBackendUnavailability.outcomeUnknownStates.length == 1 &&
          HabotBackendUnavailability.outcomeUnknownStates.single.state ==
              HabotUnavailability.requestTimedOut &&
          HabotBackendUnavailability.timeoutNote.contains('charged twice'),
    );

    gate(
      'PELCE-039-11-G3',
      'The retry rule is a function of two things, and nothing carried the '
          'second.',
      'A timeout on a read retries automatically and the same timeout on a '
          'payment reconciles with the server first, so the rules differ by '
          'idempotency on three of the four states',
      () =>
          HabotBackendUnavailability.ruleFor(
                state: HabotUnavailability.requestTimedOut,
                isIdempotent: true,
              ) ==
              HabotRetryRule.automaticWithBackoff &&
          HabotBackendUnavailability.ruleFor(
                state: HabotUnavailability.requestTimedOut,
                isIdempotent: false,
              ) ==
              HabotRetryRule.reconcileFirst &&
          HabotBackendUnavailability.handlings
                  .where(
                    (HabotUnavailabilityHandling h) => h.theRulesDiffer,
                  )
                  .length ==
              3,
    );

    gate(
      'PELCE-039-11-G4',
      'Reconciling everything is as wrong as reconciling nothing.',
      'Reconciliation is required exactly where the outcome is unknown and the '
          'call is unsafe to repeat, nowhere else, and no non-idempotent call '
          'is ever retried silently',
      () =>
          HabotBackendUnavailability
              .reconciliationIsRequiredExactlyWhereNeeded &&
          HabotBackendUnavailability.noNonIdempotentCallIsRetriedSilently &&
          HabotBackendUnavailability.automaticRetryUsesTheDeclaredBackoff,
    );
  });

  group('PELCE-039-11 :: the state nobody writes a handler for', () {
    gate(
      'PELCE-039-11-G5',
      'A client checking status codes alone treats a 200 as success.',
      'A 200 whose body reports a failure is a declared state with its own '
          'rule -- retrying reproduces the failure, so there is no retry, and '
          'the interesting part is that this one produces no error at all in a '
          'client that does not look',
      () =>
          HabotBackendUnavailability.handlingFor(
                HabotUnavailability.errorInASuccessBody,
              ).ruleWhenIdempotent ==
              HabotRetryRule.noRetry &&
          HabotBackendUnavailability.handlingFor(
                HabotUnavailability.errorInASuccessBody,
              ).ruleWhenNotIdempotent ==
              HabotRetryRule.noRetry &&
          HabotBackendUnavailability.successBodyNote
              .contains('no error at all'),
    );

    gate(
      'PELCE-039-11-G6',
      'The existing template set says every one of these categories is '
          'retryable.',
      'One state\'s template offers a retry button its rule refuses, and the '
          'mismatch is structural -- templates are keyed by category and '
          'retryability depends on the situation -- so it is named rather than '
          'patched into another step\'s gated file',
      () =>
          HabotBackendUnavailability.templateRetryDisagreements.length == 1 &&
          HabotBackendUnavailability.templateRetryDisagreements.single.state ==
              HabotUnavailability.errorInASuccessBody &&
          HabotErrorTemplates.of(HabotErrorCategory.unknown).retryable &&
          HabotBackendUnavailability.templateDisagreementNote
              .contains('keyed by'),
    );

    gate(
      'PELCE-039-11-G7',
      'Metric: Process Execution Quality Score -- optimal >=98%.',
      'All eleven checks hold and the score is at the ceiling across four '
          'criteria per state: a declared message, a stated reason, a rule for '
          'an unsafe call that is never a silent retry, and an explicit '
          'statement of whether the outcome is known. Reports Good',
      () {
        score = HabotBackendUnavailability.qualityScore;
        return HabotBackendUnavailability.checks.length == 11 &&
            HabotBackendUnavailability.checks.values.every((bool b) => b) &&
            score == HabotBackendUnavailability.ceiling &&
            score >= HabotBackendUnavailability.optimal &&
            HabotBackendUnavailability.qualitativeOutput == 'Good' &&
            HabotBackendUnavailability.columnNote.contains('no Setup Step');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'PELCE-039',
        atomicStepReferenceId: 'PELCE-039-11',
        setupStepAction:
            'COLUMN NOTE: this row carries no Setup Step, no Expected Output '
            'and no Completion Measures, and its Data Collected list is about '
            'device configuration rather than about errors. Atomic Step: '
            '"Program mobile application error controllers to catch backend '
            'service unavailability responses gracefully."',
        implementationOrder: 251,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotBackendUnavailability / HabotUnavailabilityHandling / '
              'HabotRetryRule',
          'Component Properties':
              '${HabotUnavailability.values.length} unavailability states, '
              'each mapped to a declared error category, with a retry rule '
              'for a safe call and a different one for an unsafe call, and an '
              'explicit statement of whether the outcome is known; '
              '${HabotRetryRule.values.length} retry rules',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: ${HabotBackendUnavailability.fourStatesNote} THE ONE '
              'THAT MATTERS: ${HabotBackendUnavailability.timeoutNote} '
              'THIRD: ${HabotBackendUnavailability.successBodyNote} SECOND '
              'FINDING: '
              '${HabotBackendUnavailability.templateDisagreementNote} REUSE: '
              '${HabotBackendUnavailability.reusesExistingVocabularyNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Process Execution Quality Score',
            observed:
                '${score.toStringAsFixed(2)} over four criteria applied to '
                'each of the ${HabotUnavailability.values.length} states: a '
                'declared category with a message, a stated reason, a rule '
                'for an unsafe call that is never a silent retry, and an '
                'explicit statement of whether the outcome is known.',
            floor: '>=90%',
            optimal: '>=98%',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Non-idempotent calls retried without being asked',
            observed:
                '0 of ${HabotUnavailability.values.length}. On a timeout the '
                'client reconciles with the server before offering anything, '
                'because it does not know whether the payment went through '
                'and the alternative is charging a parent twice.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/resilience/backend_unavailability.dart',
        ],
      ),
    );
  });
}
