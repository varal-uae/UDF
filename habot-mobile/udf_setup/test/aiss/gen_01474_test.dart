/// AISS GATE -- Step 44 of 50
/// Global Reference ID:       GEN-01474
/// Atomic Steps Reference ID: GEN-01474-A01
/// Setup Step (Action):       "Benchmark tab switching latency to ensure view
///                             rendering completes under 200ms."
///
/// METRIC MISMATCH, RECORDED: this row's Metric Name is "Information
/// Architecture Task Success Rate" (Floor 0.8, Optimal 0.95, Ceiling 1.0,
/// scale Good/Average/Poor), which is a usability-study measure -- you obtain
/// it by watching people try to find things, not by timing a render. The
/// number this step actually names is in its own Setup Step: 200ms. That is
/// what these gates measure. The mismatch is recorded rather than quietly
/// reinterpreted, and the sheet's metric is reported as not-produced.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/navigation/adaptive_navigation.dart';
import 'package:udf_setup/design_system/navigation/tab_switch_budget.dart';
import 'package:udf_setup/design_system/shell/app_shell.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double measuredPassRate = 0;
  Duration measuredWorst = Duration.zero;
  int measuredSwitches = 0;

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

  List<HabotShellDestination> destinations() => <HabotShellDestination>[
    HabotShellDestination(
      destination: const HabotDestination(
        route: '/overview',
        label: 'Overview',
        icon: Icons.dashboard_outlined,
      ),
      builder: (BuildContext context) => const Text('overview body'),
    ),
    HabotShellDestination(
      destination: const HabotDestination(
        route: '/tasks',
        label: 'Tasks',
        icon: Icons.checklist_outlined,
      ),
      builder: (BuildContext context) => const Text('tasks body'),
    ),
    HabotShellDestination(
      destination: const HabotDestination(
        route: '/settings',
        label: 'Settings',
        icon: Icons.settings_outlined,
      ),
      builder: (BuildContext context) => const Text('settings body'),
    ),
  ];

  group('GEN-01474-A01 :: the budget itself', () {
    gate(
      'GEN-01474-G1',
      'Setup Step (Action): "...to ensure view rendering completes UNDER '
          '200MS."',
      'The 200ms ceiling is the interactive ceiling Step 11 already fixed, not '
          'a second copy of the same number that could drift away from it',
      () =>
          HabotTabSwitchBudget.ceiling == const Duration(milliseconds: 200) &&
          HabotTabSwitchBudget.ceiling == HabotMotion.interactiveCeiling,
    );

    gate(
      'GEN-01474-G2',
      'Setup Step (Action): "BENCHMARK tab switching latency." A benchmark '
          'that cannot report a failure is not a benchmark.',
      'A switch at the ceiling passes, one a millisecond over it fails, and '
          'the pass rate is the share of samples inside the budget rather than '
          'a verdict on the worst one',
      () {
        final HabotTabSwitchBudget budget = HabotTabSwitchBudget();
        budget.record(
          from: '/a',
          to: '/b',
          duration: HabotTabSwitchBudget.ceiling,
        );
        if (!budget.allWithinBudget || budget.passRate != 100) {
          return false;
        }
        budget.record(
          from: '/b',
          to: '/c',
          duration:
              HabotTabSwitchBudget.ceiling + const Duration(milliseconds: 1),
        );
        return !budget.allWithinBudget &&
            budget.passRate == 50 &&
            budget.worst > HabotTabSwitchBudget.ceiling &&
            budget.samples.length == 2;
      },
    );

    gate(
      'GEN-01474-G3',
      'Data Collected column: "Action/Event Timestamp; User/Session ID" -- a '
          'latency record that does not say what was switched between cannot '
          'be acted on.',
      'Every sample carries its origin and destination routes, so a slow '
          'switch names the pair that was slow',
      () {
        final HabotTabSwitchBudget budget = HabotTabSwitchBudget();
        final HabotTabSwitchSample sample = budget.record(
          from: '/overview',
          to: '/tasks',
          duration: const Duration(milliseconds: 12),
        );
        return sample.from == '/overview' &&
            sample.to == '/tasks' &&
            sample.withinBudget &&
            budget.worst == const Duration(milliseconds: 12);
      },
    );
  });

  group('GEN-01474-A01 :: measured in the shell', () {
    testWidgets('[GEN-01474-G4] every destination switch in the real shell '
        'completes inside the budget', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final GlobalKey<HabotAppShellState> shellKey =
          GlobalKey<HabotAppShellState>();
      final HabotTabSwitchBudget budget = HabotTabSwitchBudget();

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: HabotAppShell(
              key: shellKey,
              destinations: destinations(),
              router: HabotShellRoutes.router(),
              budget: budget,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // One warm-up switch, then the measured run. The first frame after a
      // cold pumpWidget includes work that belongs to app start rather than to
      // tab switching, and attributing it here would flatter or damn the
      // number for the wrong reason.
      shellKey.currentState!.select(1);
      await tester.pumpAndSettle();
      budget.reset();

      for (final int index in <int>[2, 0, 1, 2, 0]) {
        shellKey.currentState!.select(index);
        await tester.pumpAndSettle();
      }

      measuredSwitches = budget.samples.length;
      measuredWorst = budget.worst;
      measuredPassRate = budget.passRate;

      expect(measuredSwitches, 5, reason: 'Five switches were driven');
      expect(find.text('overview body'), findsOneWidget);
      expect(
        budget.allWithinBudget,
        isTrue,
        reason:
            'Worst switch ${measuredWorst.inMilliseconds}ms against a '
            '${HabotTabSwitchBudget.ceiling.inMilliseconds}ms ceiling',
      );

      gates.add(
        AissGate(
          id: 'GEN-01474-G4',
          requirementSource:
              'Setup Step (Action): "Benchmark tab switching latency to ensure '
              'view rendering completes under 200ms."',
          description:
              'Five real destination switches through HabotAppShell were timed '
              'end to post-frame; all completed inside the 200ms ceiling',
          passed: true,
          detail:
              'worst ${measuredWorst.inMicroseconds / 1000}ms, pass rate '
              '${measuredPassRate.toStringAsFixed(1)}% over $measuredSwitches '
              'switches; measured on the test host, not on device',
        ),
      );
    });

    testWidgets('[GEN-01474-G5] selecting the destination already showing is '
        'not recorded as a switch', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final GlobalKey<HabotAppShellState> shellKey =
          GlobalKey<HabotAppShellState>();
      final HabotTabSwitchBudget budget = HabotTabSwitchBudget();

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: HabotAppShell(
              key: shellKey,
              destinations: destinations(),
              router: HabotShellRoutes.router(),
              budget: budget,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      shellKey.currentState!.select(0);
      await tester.pumpAndSettle();

      expect(
        budget.samples,
        isEmpty,
        reason:
            'A no-op selection would otherwise pad the benchmark with '
            'zero-length samples and lift the pass rate for free',
      );

      gates.add(
        const AissGate(
          id: 'GEN-01474-G5',
          requirementSource:
              'Setup Step (Action): "Benchmark..." -- a benchmark that counts '
              'work it did not do is a broken benchmark.',
          description:
              'Re-selecting the current destination records no sample, so the '
              'pass rate cannot be inflated by no-op taps',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01474',
        atomicStepReferenceId: 'GEN-01474-A01',
        setupStepAction:
            'Benchmark tab switching latency to ensure view rendering '
            'completes under 200ms.',
        implementationOrder: 44,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotTabSwitchBudget',
          'Component Type': 'Latency benchmark',
          'Component Properties':
              'ceiling ${HabotTabSwitchBudget.ceiling.inMilliseconds}ms, '
              'samples carry from/to route and duration',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'METRIC MISMATCH -- the sheet names "Information Architecture '
              'Task Success Rate", a usability-study measure, for a '
              'render-latency step. The 200ms figure in the Setup Step is what '
              'is gated; the sheet metric is recorded as not produced.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Tab switch latency (the 200ms the Setup Step names)',
            observed:
                'worst ${measuredWorst.inMicroseconds / 1000}ms over '
                '$measuredSwitches shell switches; pass rate '
                '${measuredPassRate.toStringAsFixed(1)}%',
            floor: '<= 200ms',
            optimal: '<= 200ms',
            ceiling: '200ms',
          ),
          const AissMeasurement(
            metricName:
                'Information Architecture Task Success Rate (the sheet metric)',
            observed:
                'NOT PRODUCED -- this is a usability-study measure obtained by '
                'observing people complete findability tasks. No test suite '
                'can generate it, and no number is asserted here in its place.',
            floor: '0.8',
            optimal: '0.95',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/navigation/tab_switch_budget.dart',
        ],
      ),
    );
  });
}
