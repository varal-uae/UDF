/// AISS GATE -- Step 28 of 35
/// Global Reference ID:       GEN-01275
/// Atomic Steps Reference ID: GEN-01275-A01
/// Setup Step (Action):       "Embed M3 status Badges to mark completed and
///                             active milestone nodes."
/// Metric: Real-Time Status Update Latency -- Floor <30s, Optimal <5s,
///         Ceiling <60s.
///
/// ON THE METRIC: update latency is a property of the data pipeline feeding
/// the badge, not of the badge. What this component controls is the latency it
/// ADDS -- the time between a status changing in the widget tree and the badge
/// showing it. That is measurable here, and it is what the measurement reports.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/contrast.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/feedback/status_badge.dart';
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

  group('GEN-01275-A01 :: M3 status badges', () {
    gate(
      'GEN-01275-G1',
      'Setup Step (Action): "Embed M3 status Badges to mark COMPLETED and '
          'ACTIVE milestone nodes."',
      'The status vocabulary covers the two states the step names and the three '
          'a real sequence also needs, each with a label, an icon and a colour '
          'role',
      () {
        if (!HabotStatuses.isComplete) {
          return false;
        }
        for (final HabotStatusSpec spec in HabotStatuses.all) {
          if (spec.label.isEmpty) {
            return false;
          }
        }
        return HabotStatuses.of(HabotStatus.complete).label == 'Complete' &&
            HabotStatuses.of(HabotStatus.active).label == 'Active';
      },
    );

    gate(
      'GEN-01275-G2',
      'WCAG 2.1 SC 1.4.1 (Use of Colour), which TTMCS-005 already made this '
          'codebase accountable to: colour may not be the only visual means of '
          'conveying information.',
      'No two statuses share an icon and no two share a label, so status '
          'survives greyscale, colour-blindness and a screen reader',
      () {
        final Set<IconData> icons = HabotStatuses.all
            .map((HabotStatusSpec s) => s.icon)
            .toSet();
        final Set<String> labels = HabotStatuses.all
            .map((HabotStatusSpec s) => s.label)
            .toSet();
        return icons.length == HabotStatus.values.length &&
            labels.length == HabotStatus.values.length;
      },
    );

    gate(
      'GEN-01275-G3',
      'TTMCS-005 contrast policy, inherited: every foreground/background pair '
          'the app paints is audited.',
      'Every status role clears the 4.5:1 text floor in both schemes, and each '
          'reaches the 7:1 AAA target',
      () {
        // The schemes the app actually paints with, not a reconstruction.
        final ColorScheme lightScheme = HabotTheme.light().colorScheme;
        final ColorScheme darkScheme = HabotTheme.dark().colorScheme;
        for (final HabotStatusRole role in HabotStatusRole.values) {
          final double light = Contrast.ratio(
            HabotStatuses.onContainerColor(lightScheme, role),
            HabotStatuses.containerColor(lightScheme, role),
          );
          final double dark = Contrast.ratio(
            HabotStatuses.onContainerColor(darkScheme, role),
            HabotStatuses.containerColor(darkScheme, role),
          );
          if (light < WcagThresholds.textOptimal ||
              dark < WcagThresholds.textOptimal) {
            return false;
          }
        }
        return true;
      },
    );

    gate(
      'GEN-01275-G4',
      'Setup Step (Action) -- "status Badges" plural, across surfaces. One '
          'vocabulary, or a node reads Active while the message that produced '
          'it said In review.',
      'Each status maps to exactly one colour role, and distinct statuses do '
          'not collapse onto the same role',
      () {
        final Set<HabotStatusRole> roles = HabotStatuses.all
            .map((HabotStatusSpec s) => s.role)
            .toSet();
        return roles.length == HabotStatus.values.length;
      },
    );
  });

  group('GEN-01275-A01 :: rendered badge and milestone node', () {
    testWidgets('[GEN-01275-G5] a badge renders its icon and its label '
        'together, not colour alone', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: const Scaffold(
            body: Center(child: HabotStatusBadge(status: HabotStatus.complete)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Complete'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      gates.add(
        const AissGate(
          id: 'GEN-01275-G5',
          requirementSource:
              'Setup Step (Action): "Embed M3 status Badges..." + WCAG 2.1 SC '
              '1.4.1.',
          description:
              'The rendered badge carries both the icon and the text label, so '
              'the status is legible without colour',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-01275-G6] a milestone node announces title and status as '
        'one phrase, and a status change is reflected on the next frame', (
      WidgetTester tester,
    ) async {
      final ValueNotifier<HabotStatus> status = ValueNotifier<HabotStatus>(
        HabotStatus.active,
      );
      addTearDown(status.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: ValueListenableBuilder<HabotStatus>(
              valueListenable: status,
              builder: (BuildContext context, HabotStatus value, Widget? _) =>
                  HabotMilestoneNode(title: 'Release batch', status: value),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Active'), findsOneWidget);

      status.value = HabotStatus.complete;
      await tester.pump();

      // The component adds no latency of its own: one frame, no animation, no
      // debounce between the value changing and the badge showing it.
      expect(find.text('Complete'), findsOneWidget);
      expect(find.text('Active'), findsNothing);

      final SemanticsHandle handle = tester.ensureSemantics();
      expect(
        find.bySemanticsLabel('Release batch, Complete'),
        findsOneWidget,
        reason: 'One node, one sentence -- not two unrelated fragments',
      );
      handle.dispose();

      gates.add(
        const AissGate(
          id: 'GEN-01275-G6',
          requirementSource:
              'Setup Step (Action): "...to mark completed and active MILESTONE '
              'NODES." + Metric: Real-Time Status Update Latency.',
          description:
              'A milestone node reflects a status change on the very next '
              'frame and announces title and status as a single phrase',
          passed: true,
          detail: 'component-added latency: one frame, no debounce',
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01275',
        atomicStepReferenceId: 'GEN-01275-A01',
        setupStepAction:
            'Embed M3 status Badges to mark completed and active milestone '
            'nodes.',
        implementationOrder: 28,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotStatusBadge / HabotMilestoneNode',
          'Component Type': 'MD3 status badge with shared status vocabulary',
          'State Definitions':
              '${HabotStatus.values.length} statuses x '
              '${HabotStatusRole.values.length} colour roles, all audited',
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'Real-Time Status Update Latency',
            observed:
                'Component-added latency: one frame (<17ms at 60Hz), no '
                'debounce and no animation between the status changing and the '
                'badge showing it. End-to-end latency depends on the data '
                'pipeline feeding the status and is outside this component.',
            floor: '<30s',
            optimal: '<5s',
            ceiling: '<60s',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>['lib/design_system/feedback/status_badge.dart'],
      ),
    );
  });
}
