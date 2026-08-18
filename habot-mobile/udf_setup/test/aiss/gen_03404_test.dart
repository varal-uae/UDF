/// AISS GATE -- Step 50 of 50
/// Global Reference ID:       GEN-03404
/// Atomic Steps Reference ID: GEN-03404-A01
/// Setup Step (Action):       "Build the mobile notification preference screen
///                             using M3 Switch components."
/// Metric: Preference Screen Render Time -- Floor <100ms, Optimal <30ms,
///         Ceiling 200ms.
///
/// The metric is measurable here, unlike most of the GEN-* metrics in this
/// batch, so it is measured rather than argued about. What is timed is the
/// widget build, layout and paint of the screen -- not a cold app start, and
/// not on a handset. The gate says so in its own evidence, because a 30ms
/// budget that quietly excluded half the work would be worth nothing.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/preferences/notification_preferences.dart';
import 'package:udf_setup/design_system/preferences/preference_manager.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  Duration measuredRender = Duration.zero;

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

  PreferenceStore store({HabotPreferenceWriter? writer}) => PreferenceStore(
    writer:
        writer ??
        (HabotPreferenceColumn c, bool v) async =>
            HabotPreferenceWriteResult.written,
  );

  Widget screen(PreferenceStore s) => MaterialApp(
    theme: HabotTheme.light(),
    home: Scaffold(
      body: SingleChildScrollView(
        child: NotificationPreferenceView(store: s),
      ),
    ),
  );

  group('GEN-03404-A01 :: the budget', () {
    gate(
      'GEN-03404-G1',
      'Metric: Preference Screen Render Time -- Floor <100ms, Optimal <30ms, '
          'Ceiling 200ms.',
      'All three thresholds are the sheet\'s own numbers, held in the motion '
          'tokens, and the ceiling is the same interactive ceiling every other '
          'user-visible wait in this design system is held to',
      () =>
          HabotPreferenceRenderBudget.floor ==
              const Duration(milliseconds: 100) &&
          HabotPreferenceRenderBudget.optimal ==
              const Duration(milliseconds: 30) &&
          HabotPreferenceRenderBudget.ceiling ==
              const Duration(milliseconds: 200) &&
          HabotPreferenceRenderBudget.ceiling ==
              HabotMotion.interactiveCeiling &&
          HabotPreferenceRenderBudget.floor == HabotMotion.preferenceRenderFloor &&
          HabotPreferenceRenderBudget.optimal ==
              HabotMotion.preferenceRenderOptimal,
    );

    gate(
      'GEN-03404-G2',
      'Metric -- a budget that cannot report a miss is decoration.',
      'The budget classifies a measurement below optimal, one between optimal '
          'and floor, and one past the floor differently',
      () =>
          HabotPreferenceRenderBudget.withinOptimal(
            const Duration(milliseconds: 12),
          ) &&
          HabotPreferenceRenderBudget.withinFloor(
            const Duration(milliseconds: 12),
          ) &&
          !HabotPreferenceRenderBudget.withinOptimal(
            const Duration(milliseconds: 55),
          ) &&
          HabotPreferenceRenderBudget.withinFloor(
            const Duration(milliseconds: 55),
          ) &&
          !HabotPreferenceRenderBudget.withinFloor(
            const Duration(milliseconds: 140),
          ),
    );
  });

  group('GEN-03404-A01 :: the rendered screen', () {
    testWidgets('[GEN-03404-G3] the screen renders one M3 switch per '
        'preference column, inside the render budget', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final PreferenceStore s = store();

      // Warm the theme and font resolution first, so what is timed below is
      // the screen rather than the first MaterialApp in the process.
      await tester.pumpWidget(screen(store()));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      final Stopwatch clock = Stopwatch()..start();
      await tester.pumpWidget(screen(s));
      clock.stop();
      measuredRender = clock.elapsed;

      expect(find.byKey(NotificationPreferenceView.viewKey), findsOneWidget);
      expect(
        find.byType(Switch),
        findsNWidgets(HabotPreferenceColumn.values.length),
        reason: 'Setup Step: "using M3 SWITCH components" -- one per column',
      );
      expect(find.text(NotificationPreferenceView.intro), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(
        HabotPreferenceRenderBudget.withinFloor(measuredRender),
        isTrue,
        reason:
            'Measured ${measuredRender.inMicroseconds / 1000}ms against a '
            '${HabotPreferenceRenderBudget.floor.inMilliseconds}ms floor',
      );

      gates.add(
        AissGate(
          id: 'GEN-03404-G3',
          requirementSource:
              'Setup Step (Action): "Build the mobile notification preference '
              'screen using M3 SWITCH COMPONENTS." + Metric: Preference Screen '
              'Render Time.',
          description:
              'The screen builds with one M3 Switch per declared column and a '
              'measured build-to-first-frame time inside the floor',
          passed: true,
          detail:
              '${measuredRender.inMicroseconds / 1000}ms measured on the test '
              'host (build + layout + paint of the screen, not a cold app '
              'start, not on a handset); floor '
              '${HabotPreferenceRenderBudget.floor.inMilliseconds}ms, optimal '
              '${HabotPreferenceRenderBudget.optimal.inMilliseconds}ms',
        ),
      );
    });

    testWidgets('[GEN-03404-G4] the screen tells the user whether their change '
        'was saved', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final PreferenceStore ok = store();
      await tester.pumpWidget(screen(ok));
      await tester.pumpAndSettle();
      expect(find.text('All changes saved'), findsOneWidget);

      await tester.tap(find.text(HabotPreferenceColumn.allowPromo.label));
      await tester.pumpAndSettle();

      expect(find.text('All changes saved'), findsOneWidget);
      expect(ok.toRecord()['allow_promo'], isTrue);

      final PreferenceStore bad = store(
        writer: (HabotPreferenceColumn c, bool v) async =>
            HabotPreferenceWriteResult.failed,
      );
      await tester.pumpWidget(screen(bad));
      await tester.pumpAndSettle();
      await tester.tap(find.text(HabotPreferenceColumn.allowPromo.label));
      await tester.pumpAndSettle();

      expect(find.text('Some changes could not be saved'), findsOneWidget);
      expect(
        bad.toRecord()['allow_promo'],
        isFalse,
        reason: 'and the switch is back where the database left it',
      );

      gates.add(
        const AissGate(
          id: 'GEN-03404-G4',
          requirementSource:
              'IS22-RCGLA-022 Completion Measure: "Preference changes write to '
              'the database accurately." A screen that saves silently is '
              'indistinguishable from one that does not save at all.',
          description:
              'The screen reports saved after an accepted write and reports '
              'the failure after a rejected one, with the control rolled back',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-03404-G5] the same screen can be presented as the '
        'reusable sheet the sheet names', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final PreferenceStore s = store();
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => TextButton(
                onPressed: () => NotificationPreferenceSheet.show(context, s),
                child: const Text('open preferences'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(NotificationPreferenceView.viewKey), findsNothing);

      await tester.tap(find.text('open preferences'));
      await tester.pumpAndSettle();

      expect(find.byKey(NotificationPreferenceView.viewKey), findsOneWidget);
      expect(find.text(NotificationPreferenceView.title), findsWidgets);
      expect(
        find.byType(Switch),
        findsNWidgets(HabotPreferenceColumn.values.length),
      );
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'GEN-03404-G5',
          requirementSource:
              'IS22-RCGLA-022 Atomic Reusability: "NotificationPreferenceSheet '
              'UI wrapper block." The name is the sheet\'s, not this '
              'implementation\'s.',
          description:
              'NotificationPreferenceSheet.show presents the identical view '
              'inside the Step 21 bottom sheet, reachable from anywhere in the '
              'app without a route',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03404',
        atomicStepReferenceId: 'GEN-03404-A01',
        setupStepAction:
            'Build the mobile notification preference screen using M3 Switch '
            'components.',
        implementationOrder: 50,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'NotificationPreferenceView / NotificationPreferenceSheet',
          'Component Type': 'Notification preference screen, M3 Switch based',
          'Component Properties':
              '${HabotPreferenceColumn.values.length} switches, write status '
              'line, bottom-sheet wrapper',
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Preference Screen Render Time',
            observed:
                '${measuredRender.inMicroseconds / 1000}ms -- build, layout '
                'and paint of the screen on the test host after a warm-up '
                'pump. This is not a cold app start and not a handset '
                'measurement; a device reading needs a profile-mode run.',
            floor: '<100ms',
            optimal: '<30ms',
            ceiling: '200ms',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/preferences/notification_preferences.dart',
        ],
      ),
    );
  });
}
