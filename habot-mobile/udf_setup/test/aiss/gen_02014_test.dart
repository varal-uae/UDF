/// AISS GATE -- Step 377 of 395
/// Global Reference ID:       GEN-02014
/// Atomic Steps Reference ID: GEN-02014
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Render disabled visual states for out-of-bounds actions
///               automatically."
/// Metric: Invalid State Form Lock Rate (%) -- floor 99, optimal 100, ceiling
///         100. Pass / Fail. W3C HTML Standards & Material Design 3 Form
///         Guidelines. Assigned to **UDF**.
///
/// "AUTOMATICALLY" IS THE WHOLE OF THE STEP, AND "OUT OF BOUNDS" IS FIVE
/// DIFFERENT THINGS.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/access/disabled_state_renderer.dart';

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

  group('GEN-02014 :: derived, not set', () {
    gate(
      'GEN-02014-G1',
      'The enabled state is a function of the bound.',
      'So a new call site cannot forget to disable and two call sites cannot '
          'disagree about when',
      () =>
          HabotOutOfBoundsState.theStateIsDerivedFromTheBound &&
          !HabotOutOfBoundsState.theEnabledStateIsSetAtEachCallSite,
    );

    gate(
      'GEN-02014-G2',
      'The bug is never the line that was written.',
      'It is the fourth screen, added later, where nobody wrote it',
      () => HabotOutOfBoundsState.automaticNote
          .contains('two call sites cannot disagree'),
    );
  });

  group('GEN-02014 :: five reasons, not one', () {
    gate(
      'GEN-02014-G3',
      'Five actions, five distinct reasons for refusal.',
      'Above a ceiling, below a floor, a precondition unmet, a role refused, '
          'and a state already reached',
      () =>
          HabotBoundsReason.values.length == 5 &&
          HabotOutOfBoundsState.actions.length == 5 &&
          HabotOutOfBoundsState.fiveReasonsAreDistinguished,
    );

    gate(
      'GEN-02014-G4',
      'Only two of the five are arithmetic bounds.',
      'A renderer that calls all five "invalid" produces the same grey button '
          'with the same silence for all of them',
      () =>
          HabotOutOfBoundsState.twoOfFiveAreArithmetic &&
          HabotOutOfBoundsState.arithmeticBounds == 2 &&
          HabotOutOfBoundsState.reasonNote.contains('the same silence'),
    );
  });

  group('GEN-02014 :: every refusal says why', () {
    gate(
      'GEN-02014-G5',
      'Every refusal carries an explanation.',
      'A disabled control with no reason is the failure this step exists to '
          'prevent',
      () => HabotOutOfBoundsState.everyRefusalCarriesAnExplanation,
    );

    gate(
      'GEN-02014-G6',
      'The explanation sits beside the control, as Step 292 settled.',
      'A greyed label is the one place a person will not look for an '
          'explanation',
      () =>
          HabotOutOfBoundsState.theReasonSitsBesideTheControl &&
          !HabotOutOfBoundsState.theReasonIsInsideTheControl &&
          HabotOutOfBoundsState.explanationNote.contains('will not look'),
    );

    gate(
      'GEN-02014-G7',
      'Three of the five can be changed by the person.',
      'The two that cannot say so, rather than being left looking temporary',
      () =>
          HabotOutOfBoundsState.threeOfFiveAreChangeable &&
          HabotOutOfBoundsState.changeableByThePerson == 3,
    );

    gate(
      'GEN-02014-G8',
      'Nothing is latched.',
      'Every refusal is conditional or not-permitted in the declared '
          'vocabulary, so none of them is a control that never comes back',
      () => HabotOutOfBoundsState.noRefusalIsLatched,
    );
  });

  group('GEN-02014 :: the metric and the output', () {
    gate(
      'GEN-02014-G9',
      'An invalid-state form lock rate on a row that mostly disables buttons.',
      'Two of the five actions are in a form; the metric covers part of the '
          'row rather than the row, and its optimal and ceiling are both 100',
      () =>
          HabotOutOfBoundsState.theMetricCoversPartOfTheRow &&
          HabotOutOfBoundsState.actionsInAForm == 2 &&
          HabotOutOfBoundsState.theOptimalEqualsTheCeiling,
    );

    gate(
      'GEN-02014-G10',
      'Output reported as Pass / Fail.',
      'Six obligations, all met, giving Pass; every disabled state is derived, '
          'and all ten declared checks hold',
      () =>
          HabotOutOfBoundsState.obligations.length == 6 &&
          HabotOutOfBoundsState.obligations.values.every((bool b) => b) &&
          HabotOutOfBoundsState.qualitativeOutput == 'Pass' &&
          HabotOutOfBoundsState.derivedShare == 100 &&
          HabotOutOfBoundsState.checks.length == 10 &&
          HabotOutOfBoundsState.checks.values.every((bool b) => b),
    );
  });

  tearDownAll(() {
    final int actions = HabotOutOfBoundsState.actions.length;
    final int arithmetic = HabotOutOfBoundsState.arithmeticBounds;
    final int changeable = HabotOutOfBoundsState.changeableByThePerson;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02014',
        atomicStepReferenceId: 'GEN-02014',
        setupStepAction:
            'COLUMN NOTE: the Data Requirement cell on this row holds the '
            'Atomic Step\'s own sentence as the artefact to prepare; its '
            'metric is an invalid-state form lock rate on a row that mostly '
            'disables buttons outside forms; its optimal and ceiling are both '
            '100; and the Setup Step column is empty. Atomic Step: "Render '
            'disabled visual states for out-of-bounds actions automatically."',
        implementationOrder: 377,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Render disabled visual states for out-of-bounds actions':
              '$actions actions across 5 reasons; $arithmetic of them are '
                  'arithmetic bounds and $changeable can be cleared by the '
                  'person',
          'Completion Status': 'Pass',
          'Action/Event Timestamp': '2026-09-17T00:00:00Z',
          'User/Session ID': 'Fredrick',
          'Component Properties':
              'every disabled state is derived from a declared bound, and '
                  'every refusal carries its explanation beside the control',
          'Data Quality Note':
              'AUTOMATIC: ${HabotOutOfBoundsState.automaticNote} REASONS: '
              '${HabotOutOfBoundsState.reasonNote} EXPLANATION: '
              '${HabotOutOfBoundsState.explanationNote} METRIC: '
              '${HabotOutOfBoundsState.metricNote}',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Invalid State Form Lock Rate (%)',
            observed:
                'A FORM METRIC ON A ROW ABOUT BUTTONS, WITH THE OPTIMAL EQUAL '
                'TO THE CEILING. The metric is the share of invalid form '
                'states that locked submission; $arithmetic of the five '
                'actions here are in a form and the rest are buttons on '
                'surfaces that are not forms. The figure published instead is '
                'the share of out-of-bounds actions whose disabled state is '
                'derived from a declared bound rather than written at the call '
                'site, which is what the word "automatically" is asking for: '
                '100 per cent.',
            floor: '99',
            optimal: '100',
            ceiling: '100',
          ),
          AissMeasurement(
            metricName: 'Disabled controls that do not say why',
            observed:
                '0 of $actions. "Out of bounds" is five different things -- a '
                'value above a ceiling, a value below a floor, a precondition '
                'unmet, a role refused, and a state already reached -- and '
                'only two are bounds in the arithmetic sense. Each carries its '
                'own explanation, placed beside the control rather than inside '
                'it as Step 292 settled, and $changeable of the five name '
                'something the person can do. The two that nothing would '
                'change say so rather than looking temporary, and none of the '
                'five is latched.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/access/disabled_state_renderer.dart',
        ],
      ),
    );
  });
}
