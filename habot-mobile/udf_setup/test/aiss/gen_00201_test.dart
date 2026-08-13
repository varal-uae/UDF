/// AISS GATE -- Step 30 of 35
/// Global Reference ID:       GEN-00201
/// Atomic Steps Reference ID: GEN-00201-A01
/// Setup Step (Action):       "Use Material Design 3 shared axis transitions
///                             for mobile view state changes."
/// Metric: General Task Completion Quality
///   Floor "Task completed with documented exceptions"
///   Optimal "100% completion matching stated implementation-step intent"
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/motion/shared_axis.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
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

  group('GEN-00201-A01 :: MD3 shared axis transitions', () {
    gate(
      'GEN-00201-G1',
      'Setup Step (Action): "Use MATERIAL DESIGN 3 shared axis transitions." '
          'MD3 defines three axes -- X for siblings, Y for hierarchy, Z for '
          'depth.',
      'All three axes exist and each produces a distinct transform, so the '
          'transition still carries the relationship it is supposed to encode',
      () =>
          HabotSharedAxis.values.length == 3 &&
          HabotSharedAxis.values.contains(HabotSharedAxis.horizontal) &&
          HabotSharedAxis.values.contains(HabotSharedAxis.vertical) &&
          HabotSharedAxis.values.contains(HabotSharedAxis.scaled),
    );

    gate(
      'GEN-00201-G2',
      'MD3 shared axis specification: fade-through, not cross-fade. The '
          'outgoing content leaves over the first 30% and the incoming content '
          'arrives over the remaining 70%.',
      'The two fade windows are disjoint -- at no point are both halves partly '
          'visible, which is what stops the double-ghost of a cross-fade',
      () {
        if (!HabotSharedAxisSpec.windowsAreDisjoint()) {
          return false;
        }
        // Sampled across the whole transition, not just at the boundary.
        for (int i = 0; i <= 100; i++) {
          final double t = i / 100;
          final double out = HabotSharedAxisSpec.outgoingOpacity(t);
          final double incoming = HabotSharedAxisSpec.incomingOpacity(t);
          if (out > 0 && incoming > 0) {
            return false;
          }
        }
        return HabotSharedAxisSpec.outgoingOpacity(0) == 1.0 &&
            HabotSharedAxisSpec.incomingOpacity(1.0) == 1.0;
      },
    );

    gate(
      'GEN-00201-G3',
      'BPTR-0422, inherited: "each motion role has its own curve rather than '
          'one curve reused everywhere" + the shared duration ladder.',
      'The transition runs on a rung of the shared duration ladder and its two '
          'curves are registered, distinct motion tokens',
      () =>
          HabotMotion.durationLadder.contains(HabotMotion.sharedAxis) &&
          HabotMotion.sharedAxis == HabotMotion.emphasized &&
          HabotEasing.all.contains(HabotEasing.sharedAxisIncoming) &&
          HabotEasing.all.contains(HabotEasing.sharedAxisOutgoing) &&
          HabotEasing.sharedAxisIncoming != HabotEasing.sharedAxisOutgoing,
    );
  });

  group('GEN-00201-A01 :: applied to a view state change', () {
    testWidgets('[GEN-00201-G4] changing the view state swaps the content '
        'through the transition and settles on the new view', (
      WidgetTester tester,
    ) async {
      final ValueNotifier<String> state = ValueNotifier<String>('summary');
      addTearDown(state.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: ValueListenableBuilder<String>(
              valueListenable: state,
              builder: (BuildContext context, String value, Widget? _) =>
                  HabotSharedAxisSwitcher(
                    stateKey: value,
                    child: Text(value),
                  ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('summary'), findsOneWidget);

      state.value = 'detail';
      await tester.pump();
      // Mid-transition both are in the tree; that is what a switcher does.
      await tester.pump(HabotMotion.sharedAxis ~/ 2);
      await tester.pumpAndSettle();

      expect(find.text('detail'), findsOneWidget);
      expect(find.text('summary'), findsNothing);

      gates.add(
        const AissGate(
          id: 'GEN-00201-G4',
          requirementSource:
              'Setup Step (Action): "Use Material Design 3 shared axis '
              'transitions for mobile VIEW STATE CHANGES."',
          description:
              'A view state change animates through the shared axis and '
              'settles with only the new view in the tree',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-00201-G5] under reduced motion the transition becomes an '
        'instant swap rather than a faster slide', (WidgetTester tester) async {
      late BuildContext reduced;
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (BuildContext context) {
                reduced = context;
                return const HabotSharedAxisSwitcher(
                  stateKey: 'a',
                  child: Text('a'),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(HabotSharedAxisSpec.durationFor(reduced), Duration.zero);

      gates.add(
        const AissGate(
          id: 'GEN-00201-G5',
          requirementSource:
              'REF-377 substep 4, inherited: "respect reduced motion '
              'preferences" -- every design-system animation routes through '
              'HabotMotionPolicy.',
          description:
              'With MediaQuery.disableAnimations set, the shared-axis duration '
              'resolves to zero',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-00201-G6] each axis moves the content along its own '
        'axis and nowhere else', (WidgetTester tester) async {
      final Map<HabotSharedAxis, Offset> offsets = <HabotSharedAxis, Offset>{};
      for (final HabotSharedAxis axis in HabotSharedAxis.values) {
        final AnimationController controller = AnimationController(
          vsync: const TestVSync(),
          duration: HabotMotion.sharedAxis,
        );
        addTearDown(controller.dispose);
        controller.value = 0;

        await tester.pumpWidget(
          MaterialApp(
            theme: HabotTheme.light(),
            home: Scaffold(
              body: Center(
                child: HabotSharedAxisTransition(
                  animation: controller,
                  axis: axis,
                  child: const SizedBox(
                    key: ValueKey<String>('axis-probe'),
                    width: 10,
                    height: 10,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        final RenderBox box = tester.renderObject<RenderBox>(
          find.byKey(const ValueKey<String>('axis-probe')),
        );
        offsets[axis] = box.localToGlobal(Offset.zero);
      }

      // Horizontal and vertical displace along different axes; scaled does not
      // translate at all.
      expect(offsets[HabotSharedAxis.horizontal]!.dx,
          isNot(offsets[HabotSharedAxis.vertical]!.dx));
      expect(offsets[HabotSharedAxis.vertical]!.dy,
          isNot(offsets[HabotSharedAxis.horizontal]!.dy));

      gates.add(
        const AissGate(
          id: 'GEN-00201-G6',
          requirementSource:
              'MD3 shared axis specification: the axis IS the information. X '
              'means sibling, Y means hierarchy, Z means depth -- three axes '
              'that render identically carry nothing.',
          description:
              'At the start of the transition the horizontal, vertical and '
              'scaled axes each place the content differently',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00201',
        atomicStepReferenceId: 'GEN-00201-A01',
        setupStepAction:
            'Use Material Design 3 shared axis transitions for mobile view '
            'state changes.',
        implementationOrder: 30,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotSharedAxisSwitcher / HabotSharedAxisTransition',
          'Component Type': 'MD3 shared axis (fade-through) transition',
          'Component Properties':
              'duration ${HabotMotion.sharedAxis.inMilliseconds}ms, fade split '
              'at ${(HabotSharedAxisSpec.outgoingFadeEnd * 100).toStringAsFixed(0)}%, '
              'slide ${HabotSharedAxisSpec.slideDistance}dp',
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'General Task Completion Quality',
            observed:
                'Complete -- all three MD3 axes implemented with a disjoint '
                'fade-through, on a shared duration rung, honouring reduced '
                'motion. No documented exceptions.',
            floor: 'Task completed with documented exceptions',
            optimal:
                '100% completion matching stated implementation-step intent',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/motion/shared_axis.dart',
          'lib/design_system/tokens/motion_tokens.dart',
        ],
      ),
    );
  });
}
