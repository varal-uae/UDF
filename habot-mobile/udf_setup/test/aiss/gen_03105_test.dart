/// AISS GATE -- Step 125 of 135
/// Global Reference ID:       GEN-03105
/// Atomic Steps Reference ID: GEN-03105
/// Atomic Step: "Set offline status chip height to 28 dp on mobile."
/// Metric: UI Design System Consistency Score (%) -- Floor 85, Optimal 95,
///         Ceiling 100.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) is EMPTY on this row.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/feedback/offline_chip.dart';
import 'package:udf_setup/design_system/interaction/touch_standards.dart';
import 'package:udf_setup/design_system/resilience/connectivity_state.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];

  void record(String id, String source, String description, bool passed) {
    gates.add(
      AissGate(
        id: id,
        requirementSource: source,
        description: description,
        passed: passed,
      ),
    );
  }

  void gate(String id, String source, String description, bool Function() run) {
    test('[$id] $description', () {
      bool passed = false;
      try {
        passed = run();
        expect(passed, isTrue, reason: '$id failed: $description');
      } finally {
        record(id, source, description, passed);
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
        record(id, source, description, passed);
      }
    });
  }

  Widget host(HabotOfflineChipState state, {VoidCallback? onPressed}) =>
      MaterialApp(
        theme: HabotTheme.light(),
        home: Scaffold(
          body: Center(
            child: HabotOfflineChip(state: state, onPressed: onPressed),
          ),
        ),
      );

  const HabotOfflineChipState offlineDurable = HabotOfflineChipState(
    connectivity: HabotConnectivity.offline,
    pendingCount: 3,
    queueIsDurable: true,
  );

  const HabotOfflineChipState offlineVolatile = HabotOfflineChipState(
    connectivity: HabotConnectivity.offline,
    pendingCount: 3,
    queueIsDurable: false,
  );

  group('GEN-03105 :: the number the row asks for', () {
    widgetGate(
      'GEN-03105-G1',
      'Atomic Step: "set offline status chip height to 28 DP on mobile".',
      'The painted chip is exactly 28dp tall -- measured on the rendered '
          'widget, not read off the constant',
      (WidgetTester tester) async {
        await tester.pumpWidget(host(offlineDurable));
        final Size size = tester.getSize(
          find.byKey(HabotOfflineChip.chipKey),
        );
        return size.height == HabotOfflineChipMetrics.heightDp &&
            size.height == 28;
      },
    );

    widgetGate(
      'GEN-03105-G2',
      'Step 10 sets a 48dp touch minimum and explicitly permits a hit box '
          'larger than the visible outline. 48dp of PAINT would be a chip that '
          'looks like a button; 28dp of HIT AREA would be a control nobody can '
          'press.',
      'When the chip is given an action the hit area grows to the Step 10 '
          'minimum while the paint stays at 28dp -- both halves checked, '
          'because getting either wrong is a real defect',
      (WidgetTester tester) async {
        await tester.pumpWidget(host(offlineDurable, onPressed: () {}));
        final Size paint = tester.getSize(
          find.byKey(HabotOfflineChip.chipKey),
        );
        final Size hit = tester.getSize(
          find.byKey(HabotOfflineChip.hitAreaKey),
        );
        return paint.height == HabotOfflineChipMetrics.heightDp &&
            hit.height == HabotDensity.minTouchTarget &&
            hit.height > paint.height &&
            TouchStandards.hitBoxMayExceedVisibleOutline;
      },
    );

    widgetGate(
      'GEN-03105-G3',
      'A status chip is not interactive by default, and a non-interactive '
          'control must not claim a touch target it does not use.',
      'Without an action there is no hit area at all, and the chip announces '
          'as a live region rather than as a button',
      (WidgetTester tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        try {
          await tester.pumpWidget(host(offlineDurable));
          final SemanticsNode node = tester.getSemantics(
            find.byKey(HabotOfflineChip.chipKey),
          );
          return find.byKey(HabotOfflineChip.hitAreaKey).evaluate().isEmpty &&
              node.hasFlag(SemanticsFlag.isLiveRegion) &&
              !node.hasFlag(SemanticsFlag.isButton);
        } finally {
          handle.dispose();
        }
      },
    );
  });

  group('GEN-03105 :: the chip has to tell the truth', () {
    gate(
      'GEN-03105-G4',
      'From the build order: "a chip that says offline is a lie until there is '
          'a queue behind it holding the work."',
      'Over a VOLATILE queue the chip says so rather than showing a '
          'reassuring count -- and the honesty property is checkable rather '
          'than a matter of reading the copy',
      () =>
          offlineDurable.label.contains('3') &&
          !offlineDurable.label.contains('not saved') &&
          offlineVolatile.label.contains('not saved yet') &&
          !offlineDurable.reassuresFalsely &&
          !offlineVolatile.reassuresFalsely &&
          offlineDurable.isHonestAboutQueue &&
          offlineVolatile.isHonestAboutQueue,
    );

    gate(
      'GEN-03105-G5',
      'What a worker needs to know is not "offline" -- they can see the signal '
          'bar. It is whether their work is safe.',
      'The hint says what the state MEANS for their work, and says something '
          'different when the queue cannot be trusted',
      () =>
          offlineDurable.semanticHint.contains(
            'Closing the app will not lose them',
          ) &&
          offlineVolatile.semanticHint.contains('held in memory only') &&
          offlineVolatile.semanticHint.contains('not something you can fix') &&
          const HabotOfflineChipState(
            connectivity: HabotConnectivity.online,
            pendingCount: 0,
            queueIsDurable: true,
          ).semanticHint ==
              'Nothing is waiting to be sent.',
    );

    widgetGate(
      'GEN-03105-G6',
      'Online with an empty queue, there is nothing to say and saying it is '
          'noise.',
      'The chip renders nothing when online and idle, and appears again as '
          'soon as there is queued work even while online',
      (WidgetTester tester) async {
        const HabotOfflineChipState idle = HabotOfflineChipState(
          connectivity: HabotConnectivity.online,
          pendingCount: 0,
          queueIsDurable: true,
        );
        const HabotOfflineChipState catchingUp = HabotOfflineChipState(
          connectivity: HabotConnectivity.online,
          pendingCount: 2,
          queueIsDurable: true,
        );
        await tester.pumpWidget(host(idle));
        final bool hidden =
            find.byKey(HabotOfflineChip.chipKey).evaluate().isEmpty;
        await tester.pumpWidget(host(catchingUp));
        return hidden &&
            !idle.isVisible &&
            catchingUp.isVisible &&
            find.byKey(HabotOfflineChip.chipKey).evaluate().isNotEmpty;
      },
    );

    gate(
      'GEN-03105-G7',
      'Metric: UI Design System Consistency Score, floor 85, optimal 95. Two '
          'components that both say "you are offline" in different words is '
          'the drift this metric is about.',
      'The score is computed over five ways this component could drift from '
          'the system -- height, spacing token, Step 48 palette, Step 48 '
          'vocabulary, Step 10 hit area -- and it clears the optimal band',
      () =>
          HabotOfflineChipConsistency.score >=
              HabotOfflineChipConsistency.optimal &&
          HabotOfflineChipConsistency.meetsFloor &&
          HabotOfflineChipConsistency.failures.isEmpty &&
          HabotOfflineChipConsistency.checks.length == 5 &&
          HabotOfflineChipMetrics.horizontalPaddingDp == HabotSpacing.xs,
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03105',
        atomicStepReferenceId: 'GEN-03105',
        setupStepAction: 'Set offline status chip height to 28 dp on mobile.',
        implementationOrder: 125,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotOfflineChip / HabotOfflineChipConsistency',
          'Component Properties':
              'painted height ${HabotOfflineChipMetrics.heightDp}dp; '
              'interactive hit area '
              '${HabotOfflineChipMetrics.interactiveTargetDp}dp; colours, copy '
              'and state consumed from the Step 48 offline banner rather than '
              'redeclared',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) is EMPTY on this row.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Chip height, measured on the rendered widget',
            observed:
                '${HabotOfflineChipMetrics.heightDp}dp painted, '
                '${HabotOfflineChipMetrics.interactiveTargetDp}dp hit area '
                'when interactive. Below the Step 10 touch minimum by design '
                'and not in conflict with it: a status chip is not '
                'interactive, and where it is, Step 10 explicitly permits a '
                'hit box larger than the visible outline.',
            floor: '28dp',
            optimal: '28dp',
            ceiling: '28dp',
          ),
          AissMeasurement(
            metricName: 'UI Design System Consistency Score',
            observed:
                '${HabotOfflineChipConsistency.score.toStringAsFixed(0)}% over '
                '${HabotOfflineChipConsistency.checks.length} drift checks. '
                'The chip takes its colours, its copy and its state from the '
                'Step 48 offline banner, so the two cannot say the same thing '
                'in different words.',
            floor: '85',
            optimal: '95',
            ceiling: '100',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/feedback/offline_chip.dart',
        ],
      ),
    );
  });
}
