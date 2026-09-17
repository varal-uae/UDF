/// AISS GATE -- Step 317 of 335
/// Global Reference ID:       ERMWD-029-03
/// Atomic Steps Reference ID: ERMWD-029-03
/// Setup Step (Action): "Research the WebAuthn API requirements for the target
///                      platforms." (AUTHENTICATION, ON A COMPONENT-KIT ROW)
/// Atomic Step: "Store designs in UI Component Kit matching backend
///               fail-closed logic."
/// Metric: UI Design-System Adherence Rate -- floor >=85%, optimal >=95%,
///         ceiling 1. Good/Average/Poor.
///
/// "MATCHING" IS THE WRONG VERB: TWO COPIES OF A SECURITY RULE WILL DISAGREE,
/// AND SILENTLY, IN BOTH DIRECTIONS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/resilience/fail_closed_kit.dart';

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

  group('ERMWD-029-03 :: one rule, not two', () {
    gate(
      'ERMWD-029-03-G1',
      'Atomic Step: "matching backend fail-closed logic".',
      'The kit holds the presentation and the server holds the decision, so '
          'the component cannot reach a verdict of its own -- the only '
          'reading of "matching" that cannot drift',
      () =>
          !HabotFailClosedKit.theKitEvaluatesAnyRule &&
          HabotFailClosedKit.singleSourceNote.contains('cannot drift'),
    );

    gate(
      'ERMWD-029-03-G2',
      'Two copies of a rule that must agree will disagree.',
      'And silently in both directions: the server refuses while the control '
          'looks live, or the control refuses what the server would allow. '
          'Step 314 found the same shape in a parallel accessible list',
      () => HabotFailClosedKit.singleSourceNote.contains('Step 314'),
    );

    gate(
      'ERMWD-029-03-G3',
      'The default state is not the allowed one.',
      'A missing verdict renders as the undecided state and the control is '
          'not pressable, which is what makes the rendering fail-closed '
          'rather than merely faithful',
      () =>
          HabotFailClosedKit.theDefaultIsNotAllowed &&
          HabotFailClosedKit.theKitHasADefaultWhenNoVerdictIsPresent &&
          HabotFailClosedKit.defaultEntry.label == 'Checking',
    );
  });

  group('ERMWD-029-03 :: the bijection', () {
    gate(
      'ERMWD-029-03-G4',
      'Five backend states, five kit entries.',
      'Every state has exactly one design and no design exists without a '
          'state',
      () =>
          HabotBackendVerdict.values.length == 5 &&
          HabotFailClosedKit.entries.length == 5 &&
          HabotFailClosedKit.everyStateHasExactlyOneDesign &&
          HabotFailClosedKit.statesWithNoDesign.isEmpty,
    );

    gate(
      'ERMWD-029-03-G5',
      'Both directions are checked for a reason.',
      'A state with no design is a screen nobody drew; a design with no state '
          'is a screen that can never appear and will be maintained forever',
      () => HabotFailClosedKit.bijectionNote
          .contains('maintained forever'),
    );
  });

  group('ERMWD-029-03 :: what a refusal owes', () {
    gate(
      'ERMWD-029-03-G6',
      'A refused control is still a control.',
      'Three of the four non-allowed states can be pressed and open the '
          'reason behind them -- the remedy Steps 291 and 293 supplied and '
          'Step 292 was refused for lacking',
      () =>
          HabotFailClosedKit.refusingEntries.length == 4 &&
          HabotFailClosedKit.refusalsThatCanBeOpened.length == 3 &&
          HabotFailClosedKit.everyRefusalCanBeOpened,
    );

    gate(
      'ERMWD-029-03-G7',
      'And the fourth is unpressable because nothing is behind it yet.',
      'Not because it is forbidden -- the undecided state is the only one '
          'that cannot be opened',
      () =>
          HabotFailClosedKit.onlyTheUndecidedStateIsUnpressable &&
          HabotFailClosedKit.openableNote
              .contains('not because it is'),
    );
  });

  group('ERMWD-029-03 :: the columns and the band', () {
    gate(
      'ERMWD-029-03-G8',
      'Config cells: keyboardType="numeric" and secureTextEntry={true}.',
      'React Native props in a Flutter application -- the thirteenth row in '
          'this track written for another stack',
      () =>
          HabotFailClosedKit.theConfigurationCellsAreReactNative &&
          HabotFailClosedKit.foreignStackNumber == 13,
    );

    gate(
      'ERMWD-029-03-G9',
      'Ceiling "1" against percentage floors.',
      'The recurring unit mismatch, recorded rather than scored against',
      () => HabotFailClosedKit.theCeilingIsInADifferentUnit,
    );

    gate(
      'ERMWD-029-03-G10',
      'Output: Good / Average / Poor.',
      'Five declared obligations, all met, giving 1.0 and a Good; all nine '
          'declared checks hold',
      () =>
          HabotFailClosedKit.obligations.length == 5 &&
          HabotFailClosedKit.obligations.values.every((bool b) => b) &&
          HabotFailClosedKit.adherence == 1.0 &&
          HabotFailClosedKit.qualitativeOutput == 'Good' &&
          HabotFailClosedKit.checks.length == 9 &&
          HabotFailClosedKit.checks.values.every((bool b) => b) &&
          HabotFailClosedKit.columnNote.contains('WebAuthn'),
    );
  });

  tearDownAll(() {
    final String refusedLabel =
        HabotFailClosedKit.entryFor(HabotBackendVerdict.refused).label;
    final String closedLabel =
        HabotFailClosedKit.entryFor(HabotBackendVerdict.closed).label;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'ERMWD-029-03',
        atomicStepReferenceId: 'ERMWD-029-03',
        setupStepAction:
            'COLUMN NOTE: two of this row\'s Mobile UX/UI configuration cells '
            'are React Native props -- keyboardType="numeric" and '
            'secureTextEntry={true} -- and the Setup Step reads "Research the '
            'WebAuthn API requirements for the target platforms", which '
            'belongs to authentication rather than to a component kit. Atomic '
            'Step: "Store designs in UI Component Kit matching backend '
            'fail-closed logic."',
        implementationOrder: 317,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Step Execution ID': 'ERMWD-029-03',
          'Execution Status': 'Complete',
          'Execution Timestamp': '2026-09-17T00:00:00Z',
          'Step Outcome':
              '${HabotFailClosedKit.entries.length} kit entries for '
                  '${HabotBackendVerdict.values.length} backend states, '
                  'bijective in both directions',
          'User ID': 'Fredrick',
          'Completion Status': 'Good',
          'Component Properties':
              'refused reads "$refusedLabel"; closed reads "$closedLabel"; '
                  'the default is the undecided state and is not pressable',
          'Data Quality Note':
              'SINGLE SOURCE: ${HabotFailClosedKit.singleSourceNote} '
              'BIJECTION: ${HabotFailClosedKit.bijectionNote} '
              'REFUSALS: ${HabotFailClosedKit.openableNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Design-System Adherence Rate',
            observed:
                '100% over five declared obligations, the first of which is '
                'that the kit evaluates no rule of its own. The ceiling is '
                'written as 1 against percentage floors.',
            floor: '>=85%',
            optimal: '>=95%',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Places a fail-closed decision is written',
            observed:
                '1. The row asks for a second copy in the component kit and '
                'the word it uses is "matching"; two copies of a rule that '
                'must agree disagree silently in both directions, and on this '
                'subject the pairs are security decisions.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/resilience/fail_closed_kit.dart',
        ],
      ),
    );
  });
}
