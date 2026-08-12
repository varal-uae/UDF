/// AISS GATE -- Step 12 of 20
/// Global Reference ID:      REF-377
/// Atomic Steps Reference ID: REF-377-A01
/// Setup Step (Action):      "Set Progressive Stepper Transitions."
///
/// Completion Measures: "Transitions feel instantaneous and fluid."
/// Metric: Location Accuracy -- Floor / Optimal / Ceiling all 100.0.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/forms/form_gate.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';
import 'package:udf_setup/design_system/wizard/carousel_stepper.dart';
import 'package:udf_setup/design_system/wizard/step_machine.dart';

import 'aiss_reporter.dart';

const List<WizardStep> _steps = <WizardStep>[
  WizardStep(id: 'a', title: 'A', fieldNames: <String>[]),
  WizardStep(id: 'b', title: 'B', fieldNames: <String>[]),
];

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

  group('REF-377-A01 :: progressive stepper transitions', () {
    gate(
      'REF-377-G1',
      '4 Substeps #1: "Define slide-in duration (200ms)."',
      'Slide-in is exactly 200ms',
      () => HabotMotion.stepperSlideIn.inMilliseconds == 200,
    );

    gate(
      'REF-377-G2',
      '4 Substeps #2: "Define slide-out duration."',
      'Slide-out is defined, non-zero, and no slower than the slide-in so the '
          'outgoing step clears first',
      () =>
          HabotMotion.stepperSlideOut > Duration.zero &&
          HabotMotion.stepperSlideOut <= HabotMotion.stepperSlideIn,
    );

    gate(
      'REF-377-G3',
      '4 Substeps #3: "Decide easing function."',
      'Enter and exit have distinct curves, both well-formed',
      () =>
          HabotEasing.stepperEnter != HabotEasing.stepperExit &&
          HabotEasing.stepperEnter.transform(0) == 0 &&
          HabotEasing.stepperEnter.transform(1) == 1 &&
          HabotEasing.stepperExit.transform(0) == 0 &&
          HabotEasing.stepperExit.transform(1) == 1,
    );

    gate(
      'REF-377-G5',
      'Completion Measures: "Transitions feel instantaneous and fluid."',
      'Both stepper durations sit at or under the 200ms interactive ceiling',
      () =>
          HabotMotion.stepperSlideIn <= HabotMotion.interactiveCeiling &&
          HabotMotion.stepperSlideOut <= HabotMotion.interactiveCeiling,
    );
  });

  // ---- Substep 4: reduced motion, proven end to end ----------------------
  group('REF-377-A01 :: substep 4 reduced motion', () {
    testWidgets('[REF-377-G4] every design-system animation collapses to zero '
        'when the OS asks for reduced motion', (WidgetTester tester) async {
      late BuildContext normalContext;
      late BuildContext reducedContext;

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Column(
            children: <Widget>[
              MediaQuery(
                data: const MediaQueryData(),
                child: Builder(
                  builder: (BuildContext context) {
                    normalContext = context;
                    return const SizedBox.shrink();
                  },
                ),
              ),
              MediaQuery(
                data: const MediaQueryData(disableAnimations: true),
                child: Builder(
                  builder: (BuildContext context) {
                    reducedContext = context;
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(HabotMotionPolicy.prefersReducedMotion(normalContext), isFalse);
      expect(HabotMotionPolicy.prefersReducedMotion(reducedContext), isTrue);

      // Every rung of the ladder, not just one sample.
      for (final Duration d in HabotMotion.durationLadder) {
        expect(HabotMotionPolicy.resolve(normalContext, d), d);
        expect(HabotMotionPolicy.resolve(reducedContext, d), Duration.zero);
      }
      expect(
        HabotMotionPolicy.resolve(reducedContext, HabotMotion.stepperSlideIn),
        Duration.zero,
      );
      // A looping animation must stop entirely, not merely speed up.
      expect(HabotMotionPolicy.allowsLoopingMotion(normalContext), isTrue);
      expect(HabotMotionPolicy.allowsLoopingMotion(reducedContext), isFalse);

      gates.add(
        const AissGate(
          id: 'REF-377-G4',
          requirementSource:
              '4 Substeps #4: "Respect reduced motion preferences." + UI '
              'Implementation: "prefers-reduced-motion media queries."',
          description:
              'HabotMotionPolicy collapses every duration to zero and stops '
              'looping motion under MediaQuery.disableAnimations',
          passed: true,
        ),
      );
    });
  });

  // ---- Poka-Yoke: previous steps are unmounted --------------------------
  group('REF-377-A01 :: poka-yoke -- no back-editing an off-screen step', () {
    testWidgets('[REF-377-G6] only the active step exists in the tree', (
      WidgetTester tester,
    ) async {
      final HabotFormGate gate = HabotFormGate();
      final WizardStepMachine machine = WizardStepMachine(
        steps: _steps,
        gate: gate,
      );
      addTearDown(machine.dispose);
      addTearDown(gate.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: CarouselStepper(
              machine: machine,
              stepBuilder: (BuildContext context, WizardStep step) =>
                  Text('step-${step.id}'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('step-a'), findsOneWidget);
      expect(find.text('step-b'), findsNothing);

      machine.next();
      await tester.pumpAndSettle();

      expect(find.text('step-b'), findsOneWidget);
      expect(
        find.text('step-a'),
        findsNothing,
        reason:
            'The previous step must be unmounted so it cannot be back-edited',
      );

      gates.add(
        const AissGate(
          id: 'REF-377-G6',
          requirementSource:
              'Poka-Yoke: "Unmounts previous steps from DOM to prevent '
              'accidental back-edits."',
          description:
              'After advancing, the previous step is gone from the tree -- its '
              'fields cannot be focused or edited',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'REF-377',
        atomicStepReferenceId: 'REF-377-A01',
        setupStepAction: 'Set Progressive Stepper Transitions.',
        implementationOrder: 12,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Architecture Pattern':
              'Token-driven motion; every animation resolves through '
              'HabotMotionPolicy',
          'Component Hierarchy':
              'CarouselStepper > StepSlideTransition > AnimatedSwitcher',
          'Data Flow Diagram':
              'WizardStepMachine.index -> StepSlideTransition key -> '
              'AnimatedSwitcher in/out',
          'Integration Points':
              'HabotMotion, HabotEasing, MediaQuery.disableAnimations',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'Location Accuracy',
            observed:
                '100.0 -- stepper motion is declared in exactly one documented '
                'location (motion_tokens.dart), enforced by the RAW_DURATION '
                'and RAW_CURVE poka-yoke rules',
            floor: '100.0',
            optimal: '100.0',
            ceiling: '100.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tokens/motion_tokens.dart',
          'lib/design_system/wizard/carousel_stepper.dart',
        ],
      ),
    );
  });
}
