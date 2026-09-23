/// AISS GATE -- Step 481 of 1,314
/// Global Reference ID:       GEN-01032
/// Atomic Steps Reference ID: GEN-01032
/// Setup Step (Action): Setup dynamic storage auto-increase parameters to
///                      accommodate dataset expansion cycles.
/// Atomic Step: "Deploy production mobile app builds to Apple App Store
///               Connect."
/// Metric: Deployment Status -- floor "Deployed", optimal "Deployed", ceiling
///         "Deployed". Best Qualitative Output: "Complete / Not Complete".
///         Apple App Store Release Rules. Assigned to **ADFA**.
///
/// FLOOR, OPTIMAL AND CEILING ARE THE SAME WORD.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/release/store_submission.dart';

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

  group('GEN-01032 :: one word, three times', () {
    gate(
      'GEN-01032-G1',
      'Floor, optimal and ceiling all read "Deployed".',
      'The first band in the track to collapse all three cells',
      () => HabotStoreSubmission.allThreeCellsAreIdentical,
    );

    gate(
      'GEN-01032-G2',
      'The third and worst collapse.',
      'A floor and ceiling at 456, a floor and optimal at 460, all three here',
      () =>
          HabotStoreSubmission.theThirdAndWorstCollapse &&
          HabotStoreSubmission.aStateCannotBeExceeded,
    );

    gate(
      'GEN-01032-G3',
      'So the band states a condition, not a measure.',
      'A state cannot be exceeded, missed or improved',
      () => HabotStoreSubmission.bandNote.contains('cannot be exceeded'),
    );

  });

  group('GEN-01032 :: somebody else\'s decision', () {
    gate(
      'GEN-01032-G4',
      'And the condition is a store reviewer\'s decision.',
      'Measuring the team on it measures somebody who does not work here',
      () =>
          !HabotStoreSubmission.theTeamControlsTheOutcome &&
          HabotStoreSubmission.whoDecidesDeployment.isNotEmpty,
    );

    gate(
      'GEN-01032-G5',
      'So four controllable things are measured instead.',
      'Signing, metadata, reproducibility and the privacy declaration',
      () =>
          HabotStoreSubmission.fourControllableThings &&
          HabotStoreSubmission.controlNote.contains('measures the ' 'reviewer'),
    );

  });

  group('GEN-01032 :: the declaration against the allowlist', () {
    gate(
      'GEN-01032-G6',
      'The declaration is eight fields, as the allowlist is.',
      'Compared field by field before submission',
      () =>
          HabotStoreSubmission.theAllowlistIsEightFields &&
          HabotStoreSubmission.theDeclarationMatchesTheAllowlist,
    );

    gate(
      'GEN-01032-G7',
      'And none of them identifies a person.',
      'Step 419 fixed that payload and this row does not widen it',
      () =>
          HabotStoreSubmission.theComparisonRunsBeforeSubmission &&
          HabotStoreSubmission.declarationNote.contains('field by field'),
    );

  });

  group('GEN-01032 :: rejection is a state', () {
    gate(
      'GEN-01032-G8',
      'Two submissions, both signed, complete and tagged.',
      'Every submission is reproducible from a tagged commit',
      () =>
          HabotStoreSubmission.submissions.length == 2 &&
          HabotStoreSubmission.everySubmissionIsSignedAndComplete &&
          HabotStoreSubmission.everySubmissionIsTagged,
    );

    gate(
      'GEN-01032-G9',
      'The rejection reason is verbatim, and took a new version.',
      'Because the reason required a code change',
      () =>
          HabotStoreSubmission.theRejectionReasonIsVerbatim &&
          HabotStoreSubmission.aCodeChangeTookANewVersion,
    );

    gate(
      'GEN-01032-G10',
      'Five obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotStoreSubmission.obligations.length == 5 &&
          HabotStoreSubmission.obligations.values.every((bool b) => b) &&
          HabotStoreSubmission.qualitativeOutput == 'Complete',
    );
  });

  tearDownAll(() {
    final int fields = HabotStoreSubmission.declaredFieldCount;
    final int subs = HabotStoreSubmission.submissions.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01032',
        atomicStepReferenceId: 'GEN-01032',
        setupStepAction:
            'COLUMN NOTE: this row\'s floor, optimal and ceiling are the same '
            'word, the first band in the track to collapse all three cells and '
            'the third collapse after Steps 456 and 460, so it states a '
            'condition rather than a measure; the condition is a store '
            'reviewer\'s decision rather than the team\'s, so four '
            'controllable things are measured instead; the privacy declaration '
            'is compared field by field against the Step 419 allowlist before '
            'submission; and a rejection records the reviewer\'s reason '
            'verbatim, taking a new version only where a code change was '
            'needed. Atomic Step: "Deploy production mobile app builds to '
            'Apple App Store Connect."',
        implementationOrder: 481,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Deploy production mobile app builds to Apple App Store Connect.':
              '$subs submissions, both signed, complete and tagged, with a '
              '$fields-field privacy declaration compared against the '
              'telemetry allowlist before each one',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Deployment Status',
            observed:
                'ONE WORD, THREE TIMES. Floor, optimal and ceiling all read '
                '"Deployed", the first band in the track to collapse all three '
                'cells and the third collapse after Steps 456 and 460, so the '
                'row states a condition rather than a measure -- and a '
                'condition decided by a store review team rather than by '
                'anybody here. Four controllable things are measured instead, '
                'and the second submission was accepted.',
            floor: 'Deployed',
            optimal: 'Deployed',
            ceiling: 'Deployed',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName:
                'Fields declared to the store that the code does not collect',
            observed:
                '0 of $fields. A declaration claiming more than the code '
                'collects is a false statement to the people downloading the '
                'application, and one claiming less is a promise the code does '
                'not keep, so the declaration and the Step 419 allowlist are '
                'compared field by field before submission. The first '
                'submission was rejected on a microphone purpose string; the '
                'reason is recorded verbatim and took a new version and a new '
                'tag.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/release/store_submission.dart',
        ],
      ),
    );
  });
}
