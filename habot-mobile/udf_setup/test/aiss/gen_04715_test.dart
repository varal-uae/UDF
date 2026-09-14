/// AISS GATE -- Step 189 of 195
/// Global Reference ID:       GEN-04715
/// Atomic Steps Reference ID: GEN-04715
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement the mobile UI styling requirement: M3 Error color
///               state tokens applied instantly on validation breach."
/// Metric: UI Styling / Transition Compliance -- Floor "<=100ms transition
///         duration; visual QA pass on target devices", Optimal "<=100ms
///         transition, 100% visual QA pass", Ceiling ">100ms transitions read
///         as sluggish; >0 visual QA defects". Pass / Fail.
///
/// "INSTANTLY" AND "<=100ms" ARE NOT THE SAME INSTRUCTION AND THE ROW GIVES
/// BOTH. A 90ms fade satisfies the number and fails the word: by then the user
/// has started the next character, so the error arrives attached to the wrong
/// keystroke. And colour alone cannot carry an error -- WCAG 2.1 SC 1.4.1.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/validation_state_color.dart';
import 'package:udf_setup/design_system/tokens/m3_naming.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

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

  group('GEN-04715 :: instantly, and the asymmetry', () {
    gate(
      'GEN-04715-G1',
      'Atomic Step: "...applied INSTANTLY on validation breach." Metric '
          'floor: "<=100ms transition duration".',
      'Entering the error state takes no time at all rather than merely '
          'clearing the budget -- a 90ms fade satisfies the number and fails '
          'the word',
      () =>
          HabotValidationStateColor.enterTransition == Duration.zero &&
          HabotValidationStateColor.enterTransition == HabotMotion.instant &&
          HabotValidationStateColor.withinBudget(
            HabotValidationStateColor.enterTransition,
          ) &&
          HabotValidationStateColor.budget == HabotMotion.fast &&
          HabotValidationStateColor.budget ==
              const Duration(milliseconds: 100) &&
          HabotValidationStateColor.instantlyVersusBudgetNote
              .contains('wrong keystroke'),
    );

    gate(
      'GEN-04715-G2',
      '"Removing an error is reassurance rather than an alert, and a one-frame '
          'snap reads as flicker."',
      'Leaving the error state is deliberately NOT instant, and the direction '
          'of the change is what selects the timing -- so the asymmetry is in '
          'the code rather than in a comment',
      () =>
          HabotValidationStateColor.exitTransition > Duration.zero &&
          HabotValidationStateColor.withinBudget(
            HabotValidationStateColor.exitTransition,
          ) &&
          HabotValidationStateColor.transitionFor(
                from: HabotFieldVisualState.focused,
                to: HabotFieldVisualState.error,
              ) ==
              Duration.zero &&
          HabotValidationStateColor.transitionFor(
                from: HabotFieldVisualState.error,
                to: HabotFieldVisualState.neutral,
              ) ==
              HabotValidationStateColor.exitTransition &&
          HabotValidationStateColor.asymmetryNote.contains('rendering bug'),
    );

    gate(
      'GEN-04715-G3',
      'The ceiling reads ">100ms transitions read as sluggish".',
      'Every declared transition is inside the budget, and the budget check '
          'rejects a duration past it -- so the bound is enforced rather than '
          'merely stated',
      () =>
          HabotValidationStateColor.withinBudget(
            const Duration(milliseconds: 100),
          ) &&
          !HabotValidationStateColor.withinBudget(
            const Duration(milliseconds: 101),
          ) &&
          !HabotValidationStateColor.withinBudget(HabotMotion.standard),
    );
  });

  group('GEN-04715 :: what colour cannot do on its own', () {
    gate(
      'GEN-04715-G4',
      'WCAG 2.1 SC 1.4.1: "colour must not be the only visual means of '
          'conveying information." A red border is nothing to a screen reader.',
      'The error state declares four carriers, including text -- the only one '
          'a screen reader can use -- and no meaning-bearing state anywhere in '
          'the set is conveyed by colour alone',
      () {
        final Set<HabotStateCarrier> error =
            HabotValidationStateColor.carriersFor(HabotFieldVisualState.error);
        return error.length == 4 &&
            error.contains(HabotStateCarrier.colour) &&
            error.contains(HabotStateCarrier.icon) &&
            error.contains(HabotStateCarrier.text) &&
            error.contains(HabotStateCarrier.semantics) &&
            HabotValidationStateColor.colourOnlyStates().isEmpty &&
            HabotValidationStateColor.colourAloneNote
                .contains('flattens hue');
      },
    );

    gate(
      'GEN-04715-G5',
      '"Focus is a position rather than information, and SC 1.4.1 is about '
          'information."',
      'The meaning-bearing states are declared as a set and focus is '
          'deliberately outside it, so the colour-only check is applied to the '
          'states it is actually about rather than to every visual state',
      () =>
          HabotValidationStateColor.meaningBearing.length == 3 &&
          HabotValidationStateColor.meaningBearing
              .contains(HabotFieldVisualState.error) &&
          HabotValidationStateColor.meaningBearing
              .contains(HabotFieldVisualState.success) &&
          !HabotValidationStateColor.meaningBearing
              .contains(HabotFieldVisualState.focused) &&
          HabotValidationStateColor.carriersFor(
                HabotFieldVisualState.neutral,
              ).isEmpty &&
          HabotFieldVisualState.values.length == 5,
    );

    gate(
      'GEN-04715-G6',
      '"error-on-surface is a 3:1 non-text pair, which is correct for a border '
          'and below the 4.5:1 floor for body text."',
      'Helper text on the error container takes the on-container role rather '
          'than the error role, and every declared surface role converts to a '
          'conformant MD3 token name',
      () =>
          HabotValidationStateColor.errorRoles['containerText'] ==
              'onErrorContainer' &&
          HabotValidationStateColor.errorRoles['border'] == 'error' &&
          HabotValidationStateColor.errorRoles.length == 6 &&
          HabotValidationStateColor.errorTokens['border'] ==
              'md.sys.color.error' &&
          HabotValidationStateColor.errorTokens['containerText'] ==
              'md.sys.color.on-error-container' &&
          HabotValidationStateColor.errorTokens.values
              .every(HabotM3Naming.isConformant),
    );

    gate(
      'GEN-04715-G7',
      'Metric: UI Styling / Transition Compliance -- Pass / Fail.',
      'Every compliance condition holds, and the record says why the colour '
          'and the message have to arrive on the same frame: they come from '
          'the same Step 20 verdict, and splitting them gives the user a red '
          'box with no reason in it',
      () =>
          HabotValidationStateColor.isCompliant &&
          HabotValidationStateColor.complianceChecks.length == 7 &&
          HabotValidationStateColor.complianceChecks.values
              .every((bool b) => b) &&
          HabotValidationStateColor.qualitativeOutput == 'Pass' &&
          HabotValidationStateColor.sameFrameNote
              .contains('no reason in it') &&
          HabotValidationStateColor.columnNote.contains('EMPTY'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04715',
        atomicStepReferenceId: 'GEN-04715',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Implement the mobile UI styling requirement: M3 Error '
            'color state tokens applied instantly on validation breach."',
        implementationOrder: 189,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotValidationStateColor',
          'Component Properties':
              '${HabotFieldVisualState.values.length} field visual states, '
              '${HabotStateCarrier.values.length} declared carriers; '
              '${HabotValidationStateColor.errorRoles.length} error surface '
              'roles; enter transition '
              '${HabotValidationStateColor.enterTransition.inMilliseconds}ms, '
              'exit '
              '${HabotValidationStateColor.exitTransition.inMilliseconds}ms, '
              'budget '
              '${HabotValidationStateColor.budget.inMilliseconds}ms',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'READING RECORDED: the row gives both "instantly" and "<=100ms". '
              'They are not the same instruction -- a 90ms fade satisfies the '
              'number and fails the word, because by then the user has started '
              'the next character and the error arrives attached to the wrong '
              'keystroke. Entering the error state is immediate; LEAVING it '
              'deliberately is not, because removing an error is reassurance '
              'rather than an alert and a one-frame snap is reported as '
              'flicker. ADDED BEYOND THE ROW: WCAG 2.1 SC 1.4.1 -- colour '
              'cannot be the only carrier, so the error state declares an '
              'icon, text and a semantics announcement alongside it.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'UI Styling / Transition Compliance',
            observed:
                'Enter '
                '${HabotValidationStateColor.enterTransition.inMilliseconds}ms '
                '(immediate), exit '
                '${HabotValidationStateColor.exitTransition.inMilliseconds}ms, '
                'both inside the 100ms budget, and the budget check rejects '
                '101ms. All '
                '${HabotValidationStateColor.complianceChecks.length} '
                'conditions hold.',
            floor: '<=100ms transition duration; visual QA pass on target '
                'devices',
            optimal: '<=100ms transition, 100% visual QA pass',
            ceiling: '>100ms transitions read as sluggish; >0 visual QA '
                'defects',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Carriers beyond colour on a meaning-bearing state',
            observed:
                '4 on the error state (colour, icon, text, semantics) and 0 '
                'meaning-bearing states conveyed by colour alone. Focus is '
                'deliberately outside the meaning-bearing set: it is a '
                'position rather than information, and SC 1.4.1 is about '
                'information.',
            floor: '>1 carrier on every meaning-bearing state',
            optimal: '>1 carrier on every meaning-bearing state',
            ceiling: '>1 carrier on every meaning-bearing state',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/forms/validation_state_color.dart',
        ],
      ),
    );
  });
}
