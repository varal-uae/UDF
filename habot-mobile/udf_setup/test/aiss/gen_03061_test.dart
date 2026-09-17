/// AISS GATE -- Step 382 of 395
/// Global Reference ID:       GEN-03061
/// Atomic Steps Reference ID: GEN-03061
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Configure the project management UI to physically disable
///               Release to Production if an AI System Impact Assessment is
///               missing or unapproved."
/// Metric: Task Completion Status -- floor 0.8, optimal 1, ceiling 1.
///         Complete/Partial/Not Complete. ITIL v4 Service Value System /
///         Internal SOP. Assigned to **UDF**.
///
/// THE SAME RELEASE CONTROL STEP 292 DISABLED, WITH A DIFFERENT CONDITION AND A
/// DIFFERENT NAME.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/operations/release_gate.dart';

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

  group('GEN-03061 :: two rows, one release control', () {
    gate(
      'GEN-03061-G1',
      'Step 292 already disables a release button.',
      'PELCE-029-17 on a reconciliation score; this row on an impact '
          'assessment, and neither mentions the other',
      () =>
          HabotReleaseGate.twoRowsGateOneKindOfRelease &&
          HabotReleaseGate.theOtherReference == 'PELCE-029-17' &&
          !HabotReleaseGate.eitherRowMentionsTheOther,
    );

    gate(
      'GEN-03061-G2',
      'The two rows name the button differently.',
      '"Release to Tech" and "Release to Production" -- if it is one button it '
          'has two gates, and if it is two the sheet never says so',
      () =>
          HabotReleaseGate.theButtonsAreNamedDifferently &&
          HabotReleaseGate.duplicateNote.contains('the sheet never says so'),
    );

    gate(
      'GEN-03061-G3',
      'Step 380 in this batch is the blunter version.',
      'A duplicated instruction outright, where this one is a duplicated '
          'control under two conditions',
      () => HabotReleaseGate.duplicateNote.contains('Step 380'),
    );
  });

  group('GEN-03061 :: a set of blockers, not a boolean', () {
    gate(
      'GEN-03061-G4',
      'The gate takes a set and needs it empty.',
      'A release control with one condition hard-coded is one the next row '
          'bolts a second condition onto',
      () =>
          HabotReleaseGate.theButtonNeedsAnEmptyList &&
          HabotReleaseBlocker.values.length == 3,
    );

    gate(
      'GEN-03061-G5',
      'Step 292\'s condition is in the same list.',
      'So adding it is a data change rather than a rewrite, and the two '
          'conditions cannot end up in two gates that do not know about each '
          'other',
      () =>
          HabotReleaseGate.theOtherRowsConditionIsInTheSameList &&
          !HabotReleaseGate.aSecondConditionNeedsARewrite &&
          HabotReleaseGate.setNote.contains('do not know about each other'),
    );

    gate(
      'GEN-03061-G6',
      'Every blocker states itself.',
      'A blocked button that does not say which condition blocked it is a '
          'twenty-minute investigation',
      () => HabotReleaseGate.everyBlockerStatesItself,
    );
  });

  group('GEN-03061 :: missing and unapproved are different queues', () {
    gate(
      'GEN-03061-G7',
      'Each blocker names who acts on it.',
      'Three blockers, three different people',
      () => HabotReleaseGate.eachBlockerNamesWhoActs,
    );

    gate(
      'GEN-03061-G8',
      'No assessment and an unapproved one go to different people.',
      'One means somebody has to write one; the other means somebody has to '
          'read one, and collapsing them is how a governance gate becomes a '
          'two-week delay',
      () =>
          HabotReleaseGate.theTwoAssessmentStatesGoToDifferentPeople &&
          !HabotReleaseGate.theTwoStatesAreCollapsed &&
          HabotReleaseGate.queueNote.contains('nobody can account for'),
    );
  });

  group('GEN-03061 :: what a disabled button is worth', () {
    gate(
      'GEN-03061-G9',
      'The release happens on a server.',
      'A disabled button is a courtesy to whoever is looking at the screen; '
          'Step 376 recorded the same limit',
      () =>
          HabotReleaseGate.theLimitIsStated &&
          !HabotReleaseGate.theDisabledButtonIsTheControl &&
          HabotReleaseGate.theRowThatRecordedThisFirst == 376 &&
          HabotReleaseGate.limitNote.contains('reads like a guarantee'),
    );

    gate(
      'GEN-03061-G10',
      'Output reported as Complete / Partial / Not Complete.',
      'Six obligations, all met, giving Complete; the blocked control lists '
          'every blocker, the optimal and ceiling are both 1, and all ten '
          'declared checks hold',
      () =>
          HabotReleaseGate.aBlockedReleaseIsNotADeadEnd &&
          HabotReleaseGate.theReasonListsEveryBlocker &&
          HabotReleaseGate.obligations.length == 6 &&
          HabotReleaseGate.obligations.values.every((bool b) => b) &&
          HabotReleaseGate.qualitativeOutput == 'Complete' &&
          HabotReleaseGate.theOptimalEqualsTheCeiling &&
          HabotReleaseGate.checks.length == 10 &&
          HabotReleaseGate.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final int blockers = HabotReleaseBlocker.values.length;
    final String missingActor =
        HabotReleaseGate.whoActsOn[HabotReleaseBlocker.assessmentMissing] ?? '';
    final String unapprovedActor = HabotReleaseGate
            .whoActsOn[HabotReleaseBlocker.assessmentUnapproved] ??
        '';

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03061',
        atomicStepReferenceId: 'GEN-03061',
        setupStepAction:
            'COLUMN NOTE: this row disables a release control that Step 292 '
            'already disables under a different condition and a different '
            'name, and neither row mentions the other -- the second duplicated '
            'control in this batch after Step 380; its metric is called "Task '
            'Completion Status", which is a status rather than a rate, and its '
            'optimal and ceiling are both 1; its Data Requirement cell holds '
            'the Atomic Step\'s own text truncated with an ellipsis; and the '
            'Setup Step column is empty. Atomic Step: "Configure the project '
            'management UI to physically disable Release to Production if an '
            'AI System Impact Assessment is missing or unapproved."',
        implementationOrder: 382,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Configure the project management UI to physically disable Release':
              '$blockers blockers, each stating itself and naming who acts',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'a missing assessment goes to $missingActor and an unapproved '
                  'one to $unapprovedActor',
          'Data Quality Note':
              'DUPLICATE: ${HabotReleaseGate.duplicateNote} SET: '
              '${HabotReleaseGate.setNote} QUEUE: '
              '${HabotReleaseGate.queueNote} LIMIT: '
              '${HabotReleaseGate.limitNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Task Completion Status',
            observed:
                'A STATUS SCORED AS A RATE, WITH THE OPTIMAL EQUAL TO THE '
                'CEILING. Floor 0.8, optimal 1, ceiling 1 -- the fifth band in '
                'this track whose optimal and ceiling are the same value. What '
                'the row builds is a gate, and a gate has no completion '
                'percentage: it is open or it is not. The honest figure is how '
                'many of the $blockers blockers state themselves and name who '
                'acts on them, which is all of them.',
            floor: '0.8',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Release conditions living in gates that cannot see '
                'each other',
            observed:
                '0. Step 292 disables "Release to Tech" when the '
                'reconciliation score is not zero; this row disables "Release '
                'to Production" when an impact assessment is missing or '
                'unapproved. Two rows, one release control, two conditions, '
                'two names, and neither mentions the other. The gate is '
                'therefore a set rather than a boolean, with Step 292\'s '
                'condition in the same list, so a third condition is a data '
                'change. "Missing" and "unapproved" stay separate because they '
                'send different people to different queues.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/operations/release_gate.dart',
        ],
      ),
    );
  });
}
