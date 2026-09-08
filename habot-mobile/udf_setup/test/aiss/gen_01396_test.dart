/// AISS GATE -- Step 150 of 155
/// Global Reference ID:       GEN-01396
/// Atomic Steps Reference ID: GEN-01396
/// Setup Step (Action) / Atomic Step: "Implement swipe gesture controllers to
///   allow transitions between wizard Byt views."
/// Metric: Entity Decomposition Structural Integrity -- Floor 0.95,
///         Optimal 1.0, Ceiling 1.0. Pass / Fail.
///
/// THE STEP STEPS 138 AND 146 WERE WRITTEN FOR: a swipe is a physical
/// direction, "next" is a semantic one, and the mapping reverses in Urdu.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/forms/field_validation.dart';
import 'package:udf_setup/design_system/forms/form_gate.dart';
import 'package:udf_setup/design_system/i18n/localization_objective.dart';
import 'package:udf_setup/design_system/wizard/step_machine.dart';
import 'package:udf_setup/design_system/wizard/swipe_controller.dart';
import 'package:udf_setup/design_system/wizard/wizard_navigation.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double integrity = 0;

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

  const List<WizardStep> steps = <WizardStep>[
    WizardStep(id: 's1', title: 'One', fieldNames: <String>['a']),
    WizardStep(id: 's2', title: 'Two', fieldNames: <String>['b']),
    WizardStep(id: 's3', title: 'Three', fieldNames: <String>['c']),
  ];

  ({HabotSwipeController swipe, HabotFormGate gate, WizardStepMachine machine})
      build({
    HabotTextDirectionality direction = HabotTextDirectionality.leftToRight,
  }) {
    final HabotFormGate g = HabotFormGate();
    for (final String f in <String>['a', 'b', 'c']) {
      g
        ..register(f)
        ..update(f, const FieldValidationResult.valid());
    }
    final WizardStepMachine m = WizardStepMachine(steps: steps, gate: g);
    return (
      swipe: HabotSwipeController(
        navigation: HabotWizardNavigation(machine: m, direction: direction),
        direction: direction,
      ),
      gate: g,
      machine: m,
    );
  }

  const HabotSwipeGesture leftwards = HabotSwipeGesture(
    horizontalDelta: -120,
    velocityPixelsPerSecond: -600,
  );
  const HabotSwipeGesture rightwards = HabotSwipeGesture(
    horizontalDelta: 120,
    velocityPixelsPerSecond: 600,
  );

  group('GEN-01396 :: the mapping that reverses', () {
    gate(
      'GEN-01396-G1',
      'Step 146 finding F-1: a wizard hardcoded to "swipe left for next" '
          'advances BACKWARDS in Urdu, and the defect is invisible to every '
          'reviewer who reads left to right.',
      'All four combinations of direction and gesture are checked, they are '
          'mirror images of each other, and the mapping lives in one place '
          'testable without building a wizard',
      () {
        integrity = HabotSwipeController.directionalIntegrity;
        return integrity == 1.0 &&
            integrity >= HabotSwipeController.floor &&
            HabotSwipeController.directionalFailures.isEmpty &&
            HabotSwipeController.directionIntegrity().length == 5;
      },
    );

    gate(
      'GEN-01396-G2',
      'The mapping has to hold through the real controller, not only through a '
          'static helper.',
      'The same physical gesture advances the wizard in a left-to-right '
          'language and retreats it in a right-to-left one, observed on the '
          'step index rather than on an enum',
      () {
        final ({
          HabotSwipeController swipe,
          HabotFormGate gate,
          WizardStepMachine machine
        }) ltr = build();
        ltr.swipe.apply(leftwards);
        final int afterLtr = ltr.machine.index;

        final ({
          HabotSwipeController swipe,
          HabotFormGate gate,
          WizardStepMachine machine
        }) rtl = build(direction: HabotTextDirectionality.rightToLeft);
        rtl.swipe.apply(leftwards);
        final int rtlFromStart = rtl.machine.index;
        rtl.swipe.apply(rightwards);
        final int rtlAfterRight = rtl.machine.index;

        return afterLtr == 1 &&
            rtlFromStart == 0 &&
            rtlAfterRight == 1 &&
            HabotSwipeController.directionMappingNote.contains(
              'exactly one method',
            );
      },
    );
  });

  group('GEN-01396 :: refusals, and gestures that are not refusals', () {
    gate(
      'GEN-01396-G3',
      'Step 146 finding F-2: a tap that does nothing looks like a refusal; a '
          'swipe that does nothing looks like the app has frozen, and users '
          'force-quit frozen apps mid-form.',
      'A forward swipe past an unsatisfied step is refused through the SAME '
          'navigation the button uses and carries the same message key, so the '
          'gesture cannot become a way around validation',
      () {
        final ({
          HabotSwipeController swipe,
          HabotFormGate gate,
          WizardStepMachine machine
        }) w = build();
        w.gate.update('a', const FieldValidationResult.invalid('No.'));
        final HabotNavigationOutcome out = w.swipe.apply(leftwards);
        return !out.moved &&
            out.wasRefused &&
            out.blockedBy == StepBlockReason.validationFailed &&
            out.refusalMessageKey == 'wizard.blocked.validation' &&
            w.machine.index == 0 &&
            HabotSwipeController.silentRefusalNote.contains(
              'looks like the app has frozen',
            );
      },
    );

    gate(
      'GEN-01396-G4',
      '"You did not swipe far enough" is not "you may not go forward". '
          'Conflating them puts a validation message on screen for a stray '
          'finger.',
      'An indecisive gesture returns no refusal at all, while a short fast '
          'flick and a long slow drag both count -- because both are '
          'deliberate and requiring both distance and speed would reject half '
          'of each',
      () {
        final ({
          HabotSwipeController swipe,
          HabotFormGate gate,
          WizardStepMachine machine
        }) w = build();
        const HabotSwipeGesture stray = HabotSwipeGesture(
          horizontalDelta: -8,
          velocityPixelsPerSecond: -20,
        );
        const HabotSwipeGesture fastFlick = HabotSwipeGesture(
          horizontalDelta: -20,
          velocityPixelsPerSecond: -900,
        );
        const HabotSwipeGesture slowDrag = HabotSwipeGesture(
          horizontalDelta: -200,
          velocityPixelsPerSecond: -30,
        );
        final HabotNavigationOutcome ignored = w.swipe.apply(stray);
        return !ignored.moved &&
            !ignored.wasRefused &&
            ignored.blockedBy == StepBlockReason.none &&
            ignored.refusalMessageKey == null &&
            w.machine.index == 0 &&
            !HabotSwipeController.isDecisive(stray) &&
            HabotSwipeController.isDecisive(fastFlick) &&
            HabotSwipeController.isDecisive(slowDrag);
      },
    );

    gate(
      'GEN-01396-G5',
      'Step 146 decision D-1: back is never refused. A gesture must not become '
          'the one way a user gets trapped.',
      'Swiping backwards from an unsatisfiable step succeeds, so the exit the '
          'button offers is also the exit the gesture offers',
      () {
        final ({
          HabotSwipeController swipe,
          HabotFormGate gate,
          WizardStepMachine machine
        }) w = build();
        w.swipe.apply(leftwards);
        w.gate.update('b', const FieldValidationResult.invalid('No.'));
        final HabotNavigationOutcome back = w.swipe.apply(rightwards);
        return back.moved &&
            back.index == 0 &&
            back.refusalMessageKey == null &&
            w.machine.index == 0;
      },
    );

    gate(
      'GEN-01396-G6',
      'Step 146 finding F-5: this app already has a horizontally scrolling '
          'surface. Two horizontal gestures on one screen means one loses, and '
          'which one is decided by widget order rather than by intent.',
      'A step declares whether it scrolls horizontally, the conflicting steps '
          'are listed by name, and the resolution is stated rather than left '
          'to the widget tree',
      () {
        final List<String> conflicts = HabotSwipeController.conflictingSteps(
          <String, bool>{'s1': false, 's2': true, 's3': false},
        );
        return conflicts.single == 's2' &&
            HabotSwipeController.gestureConflicts(
              stepScrollsHorizontally: true,
            ) &&
            !HabotSwipeController.gestureConflicts(
              stepScrollsHorizontally: false,
            ) &&
            HabotSwipeController.gestureConflictNote.contains(
              'sticky-column table',
            );
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01396',
        atomicStepReferenceId: 'GEN-01396',
        setupStepAction:
            'Implement swipe gesture controllers to allow transitions between '
            'wizard Byt views.',
        implementationOrder: 150,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotSwipeController',
          'Component Properties':
              'direction mapping in one method; '
              '${HabotSwipeController.distanceThresholdDp.toStringAsFixed(0)}dp '
              'or ${HabotSwipeController.velocityThreshold.toStringAsFixed(0)} '
              'px/s to count; refusals routed through HabotWizardNavigation',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Zero-dependency row. Built to Step 146 findings F-1, F-2 and '
              'F-5, which came from Step 138 putting a right-to-left language '
              'in scope.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Entity Decomposition Structural Integrity',
            observed:
                '${integrity.toStringAsFixed(2)} over all four combinations of '
                'writing direction and gesture direction, plus the property '
                'that the two are mirror images -- checked statically and then '
                'again through the real controller on the step index.',
            floor: '0.95',
            optimal: '1.0',
            ceiling: '1.0',
          ),
          const AissMeasurement(
            metricName: 'Wizards that advance backwards in Urdu',
            observed:
                '0. Hardcoding "swipe left for next" would have produced one, '
                'and the defect would have been invisible to every reviewer '
                'who reads left to right. Found at Step 146 before this was '
                'written, it is a mapping in one method; found afterwards it '
                'would have been a rebuild.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/wizard/swipe_controller.dart',
        ],
      ),
    );
  });
}
