/// AISS GATE -- Step 137 of 155
/// Global Reference ID:       REF-377
/// Atomic Steps Reference ID: REF-377-A02
/// Setup Step (Action): "Set Progressive Stepper Transitions."
/// Atomic Step: "Set the global transition variable for stepper animations
///               (e.g., 0.3s ease-in-out)."
/// Metric: Variable Definition -- Floor "Done", Optimal "Done", Ceiling
///         "Done". Pass/Fail.
/// Completion Measure: "Transitions feel instantaneous and fluid."
///
/// THE SECOND DEPENDENCY-SATISFIED ROW: serial 466 depends on serial 400
/// (REF-377-A01, Step 12).
///
/// A DEVIATION FROM THE ROW'S OWN EXAMPLE, GATED. 0.3s would breach
/// FIEVR-033's gated completion measure. The gate proves both halves: that the
/// value chosen honours the measure, and that the row's example would not.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/motion/stepper_transition.dart';
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

  void widgetGate(
    String id,
    String source,
    String description,
    Future<bool> Function(WidgetTester tester) run,
  ) {
    testWidgets('[$id] $description', (WidgetTester tester) async {
      bool passed = false;
      try {
        passed = await run(tester);
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

  group('REF-377-A02 :: the variable the row asks for', () {
    gate(
      'REF-377-A02-G1',
      'Atomic Step: "Set the GLOBAL TRANSITION VARIABLE for stepper '
          'animations." Metric: Variable Definition -- Done.',
      'A single global name exists for both halves of the transition, duration '
          'and curve, and both resolve to values that already exist rather '
          'than to new numbers',
      () =>
          HabotStepperTransition.duration == HabotMotion.stepperTransition &&
          HabotStepperTransition.duration == HabotMotion.stepperSlideIn &&
          HabotStepperTransition.curve == HabotEasing.stepperTransition &&
          HabotStepperTransition.curve == HabotEasing.stepperEnter &&
          HabotStepperTransition.exitDuration == HabotMotion.stepperSlideOut,
    );

    gate(
      'REF-377-A02-G2',
      'FIEVR-033 Completion Measure, verbatim: "Forms glide across steps '
          'cleanly in under 200ms", encoded as HabotMotion.interactiveCeiling '
          'and asserted by that step own gate.',
      'The global variable honours that commitment -- and the row own 0.3s '
          'example demonstrably would not, which is what makes the deviation a '
          'decision rather than an oversight',
      () =>
          HabotStepperTransition.withinInteractiveCeiling &&
          HabotStepperTransition.interactiveCeiling ==
              const Duration(milliseconds: 200) &&
          HabotStepperTransition.rowExample ==
              const Duration(milliseconds: 300) &&
          HabotStepperTransition.rowExampleWouldBreachCeiling &&
          HabotStepperTransition.exampleNotTakenNote.contains(
            'is an example, not a requirement',
          ),
    );

    gate(
      'REF-377-A02-G3',
      'If the entry is faster than the exit, the arriving step overtakes the '
          'leaving one and both are on screen moving in opposite directions.',
      'Entry is not faster than exit, and the two are the pair REF-377-A01 set '
          'rather than a third and fourth number',
      () =>
          HabotStepperTransition.entryIsNotFasterThanExit &&
          HabotStepperTransition.exitDuration <
              HabotStepperTransition.duration &&
          HabotStepperTransition.exitCurve == HabotEasing.stepperExit,
    );
  });

  group('REF-377-A02 :: the half a global variable usually forgets', () {
    gate(
      'REF-377-A02-G4',
      'REF-377-A01 substep 4: "respect reduced motion preferences." A global '
          'variable every stepper reads that ignores the OS setting pushes the '
          'obligation onto every call site, which is where it gets forgotten.',
      'Resolving under reduced motion collapses the animation to nothing and '
          'says so, rather than leaving the caller to check',
      () {
        final HabotResolvedTransition reduced =
            HabotStepperTransition.resolveWith(reducedMotion: true);
        final HabotResolvedTransition normal =
            HabotStepperTransition.resolveWith(reducedMotion: false);
        return reduced.isInstant &&
            reduced.duration == Duration.zero &&
            reduced.reducedMotion &&
            reduced.curve == HabotEasing.reducedMotion &&
            !normal.isInstant &&
            !normal.reducedMotion &&
            normal.duration == HabotStepperTransition.duration &&
            normal.curve == HabotStepperTransition.curve;
      },
    );

    widgetGate(
      'REF-377-A02-G5',
      'A resolver that only works away from a widget tree would be checked in '
          'tests and bypassed in screens.',
      'The context-based resolver agrees with the explicit one under both OS '
          'settings, so a screen reading the preference through MediaQuery '
          'gets the same answer a unit test does',
      (WidgetTester tester) async {
        bool matches = true;
        for (final bool disable in <bool>[false, true]) {
          late HabotResolvedTransition viaContext;
          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(disableAnimations: disable),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Builder(
                  builder: (BuildContext context) {
                    viaContext = HabotStepperTransition.resolve(context);
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          );
          final HabotResolvedTransition expected =
              HabotStepperTransition.resolveWith(reducedMotion: disable);
          matches = matches &&
              viaContext.duration == expected.duration &&
              viaContext.reducedMotion == expected.reducedMotion &&
              viaContext.reducedMotion == disable;
        }
        return matches;
      },
    );

    gate(
      'REF-377-A02-G6',
      'Completion Measure: "Transitions feel instantaneous and fluid."',
      'The measure is given a number rather than a feeling, and the honest '
          'reading is recorded: what it asks for is that the user never WAITS, '
          'which is the interactive ceiling -- not that the transition is '
          'below the ~100ms immediacy threshold, which a step change is not',
      () =>
          HabotStepperTransition.perceptualImmediacy == HabotMotion.fast &&
          HabotStepperTransition.duration >
              HabotStepperTransition.perceptualImmediacy &&
          HabotStepperTransition.withinInteractiveCeiling &&
          HabotStepperTransition.reducedMotionNote.contains(
            'where it gets forgotten',
          ),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'REF-377',
        atomicStepReferenceId: 'REF-377-A02',
        setupStepAction: 'Set Progressive Stepper Transitions.',
        implementationOrder: 137,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotStepperTransition',
          'Component Properties':
              'global duration ${HabotMotion.stepperTransition.inMilliseconds}'
              'ms in / ${HabotMotion.stepperSlideOut.inMilliseconds}ms out, '
              'MD3 emphasised ease-in-out, reduced motion resolved by the '
              'variable rather than by the caller',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Dependency Count 1, dependency serial 400 (REF-377-A01, Step '
              '12). The row example of 0.3s is NOT taken; the reason is '
              'recorded in HabotStepperTransition.exampleNotTakenNote and '
              'gated by REF-377-A02-G2.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Variable Definition',
            observed:
                'Done. One global name for the stepper transition, bound to '
                'the ${HabotMotion.stepperSlideIn.inMilliseconds}ms / '
                '${HabotMotion.stepperSlideOut.inMilliseconds}ms pair '
                'REF-377-A01 already set, with the easing the row asks for.',
            floor: 'Done',
            optimal: 'Done',
            ceiling: 'Done',
          ),
          AissMeasurement(
            metricName: 'Transition duration against the gated ceiling',
            observed:
                '${HabotMotion.stepperTransition.inMilliseconds}ms against a '
                '${HabotMotion.interactiveCeiling.inMilliseconds}ms ceiling. '
                'The row example of '
                '${HabotMotion.emphasized.inMilliseconds}ms would have '
                'breached FIEVR-033 stated completion measure ("forms glide '
                'across steps cleanly in under 200ms"), so it was not taken.',
            floor: '<= 200ms',
            optimal: '<= 200ms',
            ceiling: '200ms',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/motion/stepper_transition.dart',
        ],
      ),
    );
  });
}
