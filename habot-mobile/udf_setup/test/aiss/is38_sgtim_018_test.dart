/// AISS GATE -- Step 31 of 35
/// Global Reference ID:       IS38-SGTIM-018-AS01
/// Atomic Steps Reference ID: IS38-SGTIM-018-AS01-A01
/// Setup Step (Action):       "Apply M3 Overscroll Stretch on MTOI Lists"
///
/// 4 Substeps, verbatim:
///   1. "Update to Compose Foundation 1.1.0+."
///   2. "Apply to LazyColumn task lists."
///   3. "Test scrolling bounds."
///   4. "Verify physical elasticity feel on devices."
///
/// Decision to be Made Before Setup Step: "How does the list feel when the user
/// reaches the end of their task queue?"
/// Poka-Yoke: "Built-in Material 3 physics prevent unnatural scrolling breaks
/// or rigid UI halts."
/// Completion Measure: "Physical device testing confirms the stretch effect
/// upon reaching the end of the MTOI task list."
/// Metric: Asset & Component Discovery Completeness -- Floor 90%, Optimal 100%.
///
/// PLATFORM TRANSLATION: substeps 1 and 2 are written against Jetpack Compose.
/// This codebase is Flutter, so "Compose Foundation 1.1.0+" and "LazyColumn"
/// have no literal equivalent -- the stretch indicator is already in the
/// framework. What the step actually requires is that it be applied
/// everywhere rather than left to per-platform defaults, and that is what is
/// gated. The translation is recorded rather than quietly performed.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/layout/habot_scroll_behavior.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';

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

  Widget listUnder(TargetPlatform platform) => MaterialApp(
    theme: HabotTheme.light().copyWith(platform: platform),
    scrollBehavior: const HabotScrollBehavior(),
    home: Scaffold(
      body: ListView.builder(
        itemCount: 40,
        itemBuilder: (BuildContext context, int index) =>
            SizedBox(height: 48, child: Text('task $index')),
      ),
    ),
  );

  group('IS38-SGTIM-018-AS01-A01 :: M3 overscroll stretch', () {
    gate(
      'IS38-SGTIM-018-G1',
      '4 Substeps #1 and #2, translated: "Update to Compose Foundation 1.1.0+" '
          '/ "Apply to LazyColumn task lists." In Flutter the stretch already '
          'exists; the requirement is that it be applied, not installed.',
      'The behaviour declares the stretch for the Android family and only for '
          'the Android family, so no list has to opt in',
      () =>
          HabotScrollBehavior.stretchesOn(TargetPlatform.android) &&
          HabotScrollBehavior.stretchesOn(TargetPlatform.fuchsia) &&
          !HabotScrollBehavior.stretchesOn(TargetPlatform.iOS) &&
          !HabotScrollBehavior.stretchesOn(TargetPlatform.macOS) &&
          !HabotScrollBehavior.stretchesOn(TargetPlatform.windows),
    );

    gate(
      'IS38-SGTIM-018-G2',
      '4 Substeps #2: "Apply to LazyColumn TASK LISTS" -- all of them.',
      'The behaviour is installed once at the application root, so every '
          'scrollable in the app inherits it rather than remembering to ask',
      () {
        final String app = File('lib/app.dart').readAsStringSync();
        return app.contains('scrollBehavior: const HabotScrollBehavior()');
      },
    );

    gate(
      'IS38-SGTIM-018-G3',
      '4 Substeps #3: "Test scrolling bounds." + Poka-Yoke: "Built-in Material '
          '3 physics prevent unnatural scrolling breaks or rigid UI halts."',
      'Physics are clamped on the stretch platforms -- the stretch is a visual '
          'effect over a scroll that has genuinely stopped -- and bouncing '
          'where the platform itself bounces',
      () =>
          HabotScrollBehavior.bouncePlatforms.contains(TargetPlatform.iOS) &&
          !HabotScrollBehavior.bouncePlatforms.contains(
            TargetPlatform.android,
          ) &&
          HabotScrollBehavior.stretchPlatforms.isNotEmpty,
    );

    gate(
      'IS38-SGTIM-018-G4',
      'Decision to be Made Before Setup Step: "How does the list feel when the '
          'user reaches the end of their task queue?"',
      'The decision is recorded in the source next to the code it governs -- '
          'elastic, never a rigid halt, never a glow',
      () {
        final String source = File(
          'lib/design_system/layout/habot_scroll_behavior.dart',
        ).readAsStringSync();
        return source.contains('Decision to be Made Before Setup Step') &&
            source.contains('elastic') &&
            source.contains('never a rigid halt');
      },
    );
  });

  group('IS38-SGTIM-018-AS01-A01 :: rendered scrollables', () {
    testWidgets('[IS38-SGTIM-018-G5] an Android list is wrapped in the '
        'stretching indicator and never in the glow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(listUnder(TargetPlatform.android));
      await tester.pumpAndSettle();

      expect(find.byType(StretchingOverscrollIndicator), findsOneWidget);
      expect(find.byType(GlowingOverscrollIndicator), findsNothing);

      gates.add(
        const AissGate(
          id: 'IS38-SGTIM-018-G5',
          requirementSource:
              'Setup Step (Action): "Apply M3 Overscroll Stretch on MTOI '
              'Lists." + Poka-Yoke: "Built-in Material 3 physics prevent '
              'unnatural scrolling breaks."',
          description:
              'A list rendered on Android carries the stretching overscroll '
              'indicator, and the pre-MD3 glow appears nowhere',
          passed: true,
        ),
      );
    });

    testWidgets('[IS38-SGTIM-018-G6] iOS keeps its own bounce rather than '
        'inheriting a stretch that would feel foreign there', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(listUnder(TargetPlatform.iOS));
      await tester.pumpAndSettle();

      expect(find.byType(StretchingOverscrollIndicator), findsNothing);
      expect(find.byType(GlowingOverscrollIndicator), findsNothing);

      final ScrollableState state = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      expect(_chainHas<BouncingScrollPhysics>(state.position.physics), isTrue);

      gates.add(
        const AissGate(
          id: 'IS38-SGTIM-018-G6',
          requirementSource:
              '4 Substeps #4: "Verify physical elasticity FEEL." Elasticity on '
              'iOS is the platform bounce; imposing the Android stretch there '
              'would be the unnatural break the poka-yoke warns about.',
          description:
              'On iOS no overscroll indicator is drawn and the scroll physics '
              'are the platform bouncing physics',
          passed: true,
        ),
      );
    });

    testWidgets('[IS38-SGTIM-018-G7] the list scrolls to its end and stops '
        'there -- the stretch is a visual effect, not extra scroll extent', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(listUnder(TargetPlatform.android));
      await tester.pumpAndSettle();

      final ScrollableState state = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      state.position.jumpTo(state.position.maxScrollExtent);
      await tester.pumpAndSettle();

      // Drag further at the boundary: the position must not exceed the extent.
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(state.position.pixels, state.position.maxScrollExtent);
      expect(_chainHas<ClampingScrollPhysics>(state.position.physics), isTrue);

      gates.add(
        AissGate(
          id: 'IS38-SGTIM-018-G7',
          requirementSource: '4 Substeps #3: "Test scrolling bounds."',
          description:
              'At the end of the list a further drag leaves the scroll offset '
              'pinned to the maximum extent under clamping physics',
          passed: true,
          detail:
              'pixels ${state.position.pixels.toStringAsFixed(1)} == '
              'maxScrollExtent '
              '${state.position.maxScrollExtent.toStringAsFixed(1)}',
        ),
      );
    });
  });

  tearDownAll(() {
    // Substep 4 / Completion Measure: "Physical device testing confirms the
    // stretch effect upon reaching the end of the MTOI task list."
    //
    // A widget test proves the indicator is in the tree and the bounds hold.
    // It cannot confirm how the stretch FEELS in a hand on a real device, and
    // claiming otherwise would be the kind of quiet overreach this project
    // exists to avoid. Recorded as deferred: the step stays Partial until
    // someone runs it on hardware, and the gate runner stays green so a real
    // regression is still visible.
    gates.add(
      const AissGate(
        id: 'IS38-SGTIM-018-G8',
        requirementSource:
            'Completion Measures: "Physical device testing confirms the '
            'stretch effect upon reaching the end of the MTOI task list." + 4 '
            'Substeps #4: "Verify physical elasticity feel on devices."',
        description:
            'Physical-device confirmation of the stretch feel at the end of a '
            'task list',
        passed: false,
        deferred: true,
        detail:
            'Needs a hand and a handset. The widget-level facts -- indicator '
            'present, glow absent, bounds clamped -- are gated by G5 and G7. '
            'Run the app on one Android device and one iOS device, scroll a '
            'task list past its end, and record the result here.',
      ),
    );

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'IS38-SGTIM-018-AS01',
        atomicStepReferenceId: 'IS38-SGTIM-018-AS01-A01',
        setupStepAction: 'Apply M3 Overscroll Stretch on MTOI Lists',
        implementationOrder: 31,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotScrollBehavior',
          'Component Type': 'Application-wide ScrollBehavior',
          'Component Properties':
              'stretch on android + fuchsia, bounce on iOS + macOS, clamping '
              'elsewhere',
          'State Definitions': 'stretch / bounce / clamp, by platform',
          'Component Hierarchy':
              'MaterialApp.scrollBehavior -> every Scrollable in the app',
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName:
                'Asset & Component Discovery Completeness - Material design 3 '
                'm3 ui components',
            observed:
                '100% of target assets present -- StretchingOverscrollIndicator '
                'applied app-wide, glow eliminated, bounds clamped. Physical '
                'device confirmation outstanding (see deferred gate).',
            floor: '90% of target assets confirmed present',
            optimal: '100% of target assets confirmed present',
            ceiling:
                '100% (full inventory - no further discovery value beyond '
                'complete coverage)',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/layout/habot_scroll_behavior.dart',
          'lib/app.dart',
        ],
      ),
    );
  });
}

/// Walks the physics chain looking for [T].
///
/// A ScrollView composes physics rather than replacing them -- a vertical
/// ListView with no controller wraps whatever the behaviour supplies in
/// AlwaysScrollableScrollPhysics -- so asserting on the outermost type would
/// test the framework's composition, not this behaviour's decision.
bool _chainHas<T extends ScrollPhysics>(ScrollPhysics? physics) {
  ScrollPhysics? node = physics;
  while (node != null) {
    if (node is T) {
      return true;
    }
    node = node.parent;
  }
  return false;
}
