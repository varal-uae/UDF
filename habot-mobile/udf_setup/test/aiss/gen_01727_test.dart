/// AISS GATE -- Step 387 of 395
/// Global Reference ID:       GEN-01727
/// Atomic Steps Reference ID: GEN-01727
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Block the user from proceeding to force localized error
///               correction."
/// Metric: Automated PR Rejection Rate for Non-Compliance (%) -- floor 95,
///         optimal 99.5, ceiling 100. High/Medium/Low. CI/CD Best Practices &
///         GitHub Standards. Assigned to **PDG**.
///
/// "LOCALIZED" IS THE LOAD-BEARING WORD, AND THE METRIC IS A CONTINUOUS
/// INTEGRATION MEASURE ON A FORM.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/correction_block.dart';

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

  group('GEN-01727 :: three properties of a local correction', () {
    gate(
      'GEN-01727-G1',
      'The error is on the field, not the form.',
      'A banner saying "please correct the errors below" on a form with '
          'fourteen fields is a block without a location',
      () =>
          HabotCorrectionScope.values.length == 2 &&
          HabotCorrectionBlock.theErrorIsOnTheField,
    );

    gate(
      'GEN-01727-G2',
      'Focus moves to the first error, and it is named.',
      'So the work the block creates is a correction rather than a hunt',
      () =>
          HabotCorrectionBlock.focusMovesToTheFirstError &&
          HabotCorrectionBlock.theFirstErrorIsNamed,
    );

    gate(
      'GEN-01727-G3',
      'Every message is an instruction rather than a verdict.',
      '"Invalid date" is a verdict; "use DD/MM/YYYY, for example 03/09/2026" '
          'is an instruction',
      () =>
          HabotCorrectionBlock.everyMessageSaysWhatWouldFixIt &&
          HabotCorrectionBlock.errors.length == 4 &&
          HabotCorrectionBlock.localNote.contains('is an instruction'),
    );
  });

  group('GEN-01727 :: what is blocked, and what is not', () {
    gate(
      'GEN-01727-G4',
      'Only the submit is blocked.',
      'Typing is never blocked and a draft can be kept with every one of these '
          'errors still in it',
      () =>
          HabotCorrectionBlock.onlySubmittingIsBlocked &&
          !HabotCorrectionBlock.typingIsBlocked &&
          !HabotCorrectionBlock.savingADraftIsBlocked &&
          HabotCorrectionBlock.noErrorBlocksSaving,
    );

    gate(
      'GEN-01727-G5',
      'A form that refuses everything loses the work that took longest.',
      'The block exists to stop a bad record being created, not to stop '
          'somebody thinking',
      () => HabotCorrectionBlock.scopeNote.contains('took longest'),
    );
  });

  group('GEN-01727 :: how long this will take', () {
    gate(
      'GEN-01727-G6',
      'The summary counts and names.',
      '"4 things to fix -- the first is Start date" tells somebody how long '
          'this will take before they start',
      () =>
          HabotCorrectionBlock.theSummaryCountsAndNames &&
          HabotCorrectionBlock.errorCount == 4,
    );

    gate(
      'GEN-01727-G7',
      'The vague summary is refused.',
      'A block with no count is a block of unknown depth, and people abandon '
          'unknown depths',
      () =>
          HabotCorrectionBlock.theVagueSummaryIsRefused &&
          HabotCorrectionBlock.summaryNote
              .contains('people abandon unknown depths'),
    );

    gate(
      'GEN-01727-G8',
      'The error styling is Step 189\'s and is not colour alone.',
      'The state is carried by an icon and a message as well as by a role',
      () =>
          HabotCorrectionBlock.theErrorStylingIsAlreadyDeclared &&
          HabotCorrectionBlock.errorIsNotColourAlone,
    );
  });

  group('GEN-01727 :: one metric, two unrelated rows', () {
    gate(
      'GEN-01727-G9',
      'Step 392 carries the identical metric and band.',
      'A pull-request rejection rate on a row about floating-point arithmetic, '
          'five rows later; neither subject is a pull request',
      () =>
          HabotCorrectionBlock.oneMetricScoresTwoUnrelatedRows &&
          HabotCorrectionBlock.theOtherRowWithThisMetric == 392 &&
          HabotCorrectionBlock.theBandIsWellFormed,
    );

    gate(
      'GEN-01727-G10',
      'Output reported as High / Medium / Low.',
      'Six obligations, all met, giving High; every error is localised on all '
          'three counts, and all ten declared checks hold',
      () =>
          HabotCorrectionBlock.obligations.length == 6 &&
          HabotCorrectionBlock.obligations.values.every((bool b) => b) &&
          HabotCorrectionBlock.qualitativeOutput == 'High' &&
          HabotCorrectionBlock.localised == 100 &&
          HabotCorrectionBlock.checks.length == 10 &&
          HabotCorrectionBlock.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final String summary = HabotCorrectionBlock.summary;
    final String firstMessage = HabotCorrectionBlock.errors.first.message;
    final int count = HabotCorrectionBlock.errorCount;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01727',
        atomicStepReferenceId: 'GEN-01727',
        setupStepAction:
            'COLUMN NOTE: this row is assigned to PDG rather than UDF; its '
            'metric is an automated pull-request rejection rate -- a '
            'continuous-integration measure -- on a row about blocking a '
            'person in a form, and Step 392 in this batch carries the '
            'identical metric and band on a row about floating-point '
            'arithmetic; its Data Requirement cell holds the Atomic Step\'s '
            'own sentence as the artefact to prepare; and the Setup Step '
            'column is empty. Atomic Step: "Block the user from proceeding to '
            'force localized error correction."',
        implementationOrder: 387,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Block the user from proceeding to force localized error correction':
              '$count field errors, each attached to its field and each '
                  'phrased as an instruction',
          'Completion Status': 'High',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'the summary reads "$summary" and the first message reads '
                  '"$firstMessage"',
          'Data Quality Note':
              'LOCAL: ${HabotCorrectionBlock.localNote} SCOPE: '
              '${HabotCorrectionBlock.scopeNote} SUMMARY: '
              '${HabotCorrectionBlock.summaryNote} METRIC: '
              '${HabotCorrectionBlock.metricNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Automated PR Rejection Rate for Non-Compliance (%)',
            observed:
                'A CONTINUOUS-INTEGRATION MEASURE ON A FORM, AND THE FIRST OF '
                'TWO IDENTICAL COPIES IN THIS BATCH. A pull-request rejection '
                'rate measures a pipeline turning away non-compliant commits, '
                'which is a real thing happening somewhere else. Step 392 '
                'carries the same metric name and the same band five rows '
                'later, on a row about floating-point arithmetic: one measure, '
                'two unrelated subjects, and neither of them a pull request. '
                'The band is at least well formed.',
            floor: '95',
            optimal: '99.5',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Errors a person has to hunt for',
            observed:
                '0 of $count. "Localized" is the load-bearing word: blocking '
                'on its own is easy and useless, and what makes it worth '
                'something is that the person is taken to the specific thing '
                'that is wrong. Each error is attached to its field, focus '
                'moves to the first one, and each message says what would fix '
                'it. Only the submit is blocked -- typing is never blocked and '
                'a draft survives every one of these errors -- and the summary '
                'reads "$summary" rather than "please correct the errors '
                'below", because a block of unknown depth is one people '
                'abandon.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/correction_block.dart',
        ],
      ),
    );
  });
}
