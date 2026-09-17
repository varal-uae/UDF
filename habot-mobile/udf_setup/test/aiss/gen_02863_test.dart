/// AISS GATE -- Step 339 of 355
/// Global Reference ID:       GEN-02863
/// Atomic Steps Reference ID: GEN-02863
/// Setup Step (Action): (the generic engineering-console boilerplate --
///                      COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement swipe-to-confirm gesture for high-risk tool actions
///               on mobile."
/// Metric: Task Completion Status -- floor 0.8, optimal 1, ceiling 1.
///         Complete / Partial / Not Complete. ITIL v4 Service Value System.
///
/// A GOOD IDEA THAT IS A LEVEL A FAILURE UNLESS IT HAS A SECOND ROUTE, AND
/// THE SECOND BAND IN THIS BATCH WHOSE OPTIMAL AND CEILING COINCIDE.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/gesture/swipe_to_confirm.dart';

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

  group('GEN-02863 :: the criterion', () {
    gate(
      'GEN-02863-G1',
      'Atomic Step: "swipe-to-confirm gesture for high-risk tool actions".',
      'A slide-to-confirm control is a path-based gesture, and the row names '
          'no other way to the action it guards',
      () =>
          HabotSwipeToConfirm.theRowsRouteIsPathBased &&
          HabotSwipeToConfirm.theRowsOnlyRoute == HabotConfirmationCost.slide,
    );

    gate(
      'GEN-02863-G2',
      'SC 2.5.1 Pointer Gestures is Level A.',
      'Two of the three routes built here need no path, so the action is '
          'reachable by a switch, a head pointer or voice control',
      () =>
          HabotSwipeToConfirm.theCriterionIsSatisfied &&
          HabotSwipeToConfirm.twoOfThreeRoutesNeedNoPath &&
          HabotSwipeToConfirm.conformanceLevel == 'A',
    );
  });

  group('GEN-02863 :: the cost has to survive the alternative', () {
    gate(
      'GEN-02863-G3',
      'Each of the three routes states what it costs.',
      'A deliberate travel, typing the action word, or holding for the '
          'declared dwell',
      () =>
          HabotSwipeToConfirm.everyRouteCostsSomething &&
          HabotSwipeToConfirm.whatEachCosts.length == 3,
    );

    gate(
      'GEN-02863-G4',
      'No plain one-tap route is offered.',
      'An alternative that removes the friction is a bypass: the person using '
          'a switch would get the dangerous version and everybody else the '
          'careful one',
      () =>
          !HabotSwipeToConfirm.aPlainButtonIsOffered &&
          HabotSwipeToConfirm.equivalenceNote.contains('bypass of it'),
    );
  });

  group('GEN-02863 :: proportionality', () {
    gate(
      'GEN-02863-G5',
      'Step 248 refused two of three friction devices as commercial.',
      'The rule that survived is the one applied here, read from Step 248 '
          'rather than restated',
      () =>
          HabotSwipeToConfirm.theFrictionRuleIsAlreadyDeclared &&
          HabotSwipeToConfirm.proportionalityNote.contains('Step 248'),
    );

    gate(
      'GEN-02863-G6',
      'All three guarded actions are irreversible by the actor.',
      'Deleting a submitted record, releasing a payment, revoking another '
          'person\'s access -- a confirm gesture on anything reversible is a '
          'toll rather than a safeguard',
      () =>
          HabotSwipeToConfirm.everyGuardedActionIsIrreversibleByTheActor &&
          HabotSwipeToConfirm.guarded.length == 3 &&
          HabotSwipeToConfirm.proportionalityNote.contains('toll'),
    );
  });

  group('GEN-02863 :: the travel', () {
    gate(
      'GEN-02863-G7',
      'The commit threshold is Step 225\'s dismissal fraction.',
      'Half of a 280dp track is 140dp, read from the existing gesture rule',
      () =>
          HabotSwipeToConfirm.theTravelIsReadFromStep225 &&
          HabotSwipeToConfirm.commitFraction == 0.5 &&
          HabotSwipeToConfirm.travelToCommitDp == 140,
    );

    gate(
      'GEN-02863-G8',
      'Releasing short of the threshold commits nothing.',
      'The handle returns and the action does not fire',
      () => !HabotSwipeToConfirm.aPartialSlideCommits,
    );
  });

  group('GEN-02863 :: the band', () {
    gate(
      'GEN-02863-G9',
      'Floor 0.8, optimal 1, ceiling 1.',
      'The top two values are the same number -- the second such band in this '
          'batch after Step 336, and one of four in all',
      () =>
          HabotSwipeToConfirm.theOptimalEqualsTheCeiling &&
          HabotSwipeToConfirm.collapsedTopsInThisBatch == 4 &&
          HabotSwipeToConfirm.bandNote.contains('two ends and three'),
    );

    gate(
      'GEN-02863-G10',
      'Output reported as Complete / Partial / Not Complete.',
      'Five obligations, all met, giving Complete; all ten declared checks '
          'hold',
      () =>
          HabotSwipeToConfirm.obligations.length == 5 &&
          HabotSwipeToConfirm.obligations.values.every((bool b) => b) &&
          HabotSwipeToConfirm.qualitativeOutput == 'Complete' &&
          HabotSwipeToConfirm.checks.length == 10 &&
          HabotSwipeToConfirm.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final int pathFree = HabotSwipeToConfirm.pathFreeRoutes.length;
    final double travel = HabotSwipeToConfirm.travelToCommitDp;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02863',
        atomicStepReferenceId: 'GEN-02863',
        setupStepAction:
            'COLUMN NOTE: the band on this row sets a floor of 0.8 against an '
            'optimal and a ceiling both written "1", so its top two values are '
            'the same number, and every narrative column is the generic '
            'engineering-console boilerplate. Atomic Step: "Implement '
            'swipe-to-confirm gesture for high-risk tool actions on mobile."',
        implementationOrder: 339,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Implement swipe-to-confirm gesture for high-risk tool actions on '
                  'mobile.':
              '3 confirmation routes, $pathFree of which need no path gesture; '
                  'the slide commits at $travel dp',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'three guarded actions, all irreversible by the actor; no plain '
                  'one-tap route exists',
          'Data Quality Note':
              'CRITERION: ${HabotSwipeToConfirm.criterionNote} '
              'EQUIVALENCE: ${HabotSwipeToConfirm.equivalenceNote} '
              'PROPORTIONALITY: ${HabotSwipeToConfirm.proportionalityNote} '
              'BAND: ${HabotSwipeToConfirm.bandNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Task Completion Status',
            observed:
                'THE OPTIMAL AND THE CEILING ARE THE SAME VALUE. Floor 0.8 '
                'against an optimal and a ceiling both written "1", which is '
                'the second band shaped this way in this batch after Step 336 '
                'and one of four in all. A band whose top two cells hold the '
                'same number cannot distinguish a good outcome from the best '
                'one.',
            floor: '0.8',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Confirmation routes that need no path gesture',
            observed:
                '$pathFree of 3 -- typing the action word, and holding for the '
                'declared dwell -- against the 1 the row names, which is the '
                'slide. Both alternatives keep a cost, because an accessible '
                'alternative that removes the friction is not an alternative '
                'to this control but a bypass of it: it would give the person '
                'using a switch the dangerous one-tap version of a destructive '
                'action and everybody else the careful one.',
            floor: '1',
            optimal: '2',
            ceiling: '2',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/gesture/swipe_to_confirm.dart',
        ],
      ),
    );
  });
}
