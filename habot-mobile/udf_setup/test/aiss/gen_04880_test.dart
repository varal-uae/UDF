/// AISS GATE -- Step 65 of 65
/// Global Reference ID:       GEN-04880
/// Atomic Steps Reference ID: GEN-04880-A01
/// Setup Step (Action):       "Implement the self-chasing automation behavior:
///                             Clicking any KPI card automatically applies the
///                             corresponding filter."
/// Metric: Automation Trigger Reliability Rate -- Floor ">=99.0% successful
///         automated triggers", Optimal "99.9% (three-nines)".
///
/// The step that closes the loop, and the last of the batch. The metric is
/// measurable here -- unlike most of the batch -- because the trigger is a tap
/// rather than a background job: drive N taps, count how many produced the
/// intended selection, report the rate. G4 drives 200.
///
/// The load-bearing word in the requirement is "CORRESPONDING". A KPI that
/// maps to no filter must not be tappable at all, and G2 is the gate that
/// holds that line.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/dashboard/dashboard_controller.dart';
import 'package:udf_setup/design_system/dashboard/filter_model.dart';
import 'package:udf_setup/design_system/dashboard/kpi_card.dart';
import 'package:udf_setup/design_system/dashboard/kpi_grid.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';

import 'aiss_reporter.dart';

const HabotKpi _intake = HabotKpi(
  id: 'intake',
  label: 'Records in intake',
  value: 148,
  category: HabotMetricCategory.volume,
  filterKey: 'intake',
);
const HabotKpi _flagged = HabotKpi(
  id: 'flagged',
  label: 'Flagged for exception',
  value: 3,
  previousValue: 1,
  category: HabotMetricCategory.fault,
  filterKey: 'flagged',
);
const HabotKpi _unmapped = HabotKpi(
  id: 'latency',
  label: 'Median review time',
  value: 412,
  previousValue: 360,
  category: HabotMetricCategory.latency,
);

void main() {
  final List<AissGate> gates = <AissGate>[];
  double measuredRate = 0;
  int triggersDriven = 0;

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

  group('GEN-04880-A01 :: the trigger', () {
    gate(
      'GEN-04880-G1',
      'Setup Step (Action): "Clicking any KPI card AUTOMATICALLY APPLIES THE '
          'CORRESPONDING FILTER."',
      'A tap replaces the facet rather than adding to it -- tapping "Flagged" '
          'means show me flagged, not add flagged to whatever was selected -- '
          'and tapping the same card again clears it, so the gesture is its '
          'own undo',
      () {
        final HabotDashboardController controller =
            HabotDashboardController(facetKey: 'category');
        controller.applyFromKpi(_intake);
        final bool first =
            controller.selection.isSelected('category', 'intake');
        controller.applyFromKpi(_flagged);
        final bool replaced =
            controller.selection.isSelected('category', 'flagged') &&
                !controller.selection.isSelected('category', 'intake');
        controller.applyFromKpi(_flagged);
        final bool undone = controller.selection.isEmpty;
        return first && replaced && undone;
      },
    );

    gate(
      'GEN-04880-G2',
      'Setup Step (Action): "...the CORRESPONDING filter." A card that looks '
          'interactive and does nothing is worse than one that looks inert.',
      'A KPI with no filter key produces no selection change and is recorded '
          'as a failed trigger with a reason, rather than silently doing '
          'nothing and being excluded from the rate',
      () {
        final HabotDashboardController controller =
            HabotDashboardController(facetKey: 'category');
        final bool changed = controller.applyFromKpi(_unmapped);
        final HabotTriggerRecord record = controller.triggers.single;
        return !changed &&
            controller.selection.isEmpty &&
            !record.succeeded &&
            record.reason != null &&
            record.kpiId == 'latency' &&
            controller.reliabilityRate == 0;
      },
    );

    gate(
      'GEN-04880-G3',
      'Metric: Automation Trigger Reliability Rate -- a rate computed only '
          'over the successes is 100% by construction and therefore worthless.',
      'Every call is recorded, successful or not, and a human choosing a '
          'filter from the sheet is NOT recorded as an automated trigger -- '
          'counting it would inflate the number the metric is about',
      () {
        final HabotDashboardController controller =
            HabotDashboardController(facetKey: 'category');
        controller.applyFromKpi(_intake);
        controller.applyFromKpi(_unmapped);
        final int afterTaps = controller.triggerCount;
        controller.applyFromSheet(
          const HabotFilterSelection(<String, Set<String>>{
            'category': <String>{'accuracy'},
          }),
        );
        return afterTaps == 2 &&
            controller.triggerCount == 2 &&
            controller.successfulTriggers == 1 &&
            controller.reliabilityRate == 50 &&
            !controller.meetsFloor &&
            HabotDashboardController.floorReliability == 99.0 &&
            HabotDashboardController.optimalReliability == 99.9;
      },
    );

    gate(
      'GEN-04880-G4',
      'Metric: Automation Trigger Reliability Rate -- Floor ">=99.0% '
          'successful automated triggers", Optimal "99.9%".',
      'Two hundred alternating taps against mapped KPIs all produce the '
          'intended selection: the measured rate is reported, not asserted, '
          'and it clears the optimal band',
      () {
        final HabotDashboardController controller =
            HabotDashboardController(facetKey: 'category');
        const List<HabotKpi> mapped = <HabotKpi>[_intake, _flagged];
        for (int i = 0; i < 200; i++) {
          final HabotKpi kpi = mapped[i % 2];
          controller.applyFromKpi(kpi);
        }
        triggersDriven = controller.triggerCount;
        measuredRate = controller.reliabilityRate;
        return triggersDriven == 200 &&
            measuredRate >= HabotDashboardController.optimalReliability &&
            controller.meetsFloor;
      },
    );

    gate(
      'GEN-04880-G5',
      'Setup Step (Action) -- the loop should be visible in both directions, '
          'not only forwards.',
      'The card carrying the active filter reads as active, so a user can see '
          'which number narrowed the dashboard, and clearing releases it',
      () {
        final HabotDashboardController controller =
            HabotDashboardController(facetKey: 'category');
        controller.applyFromKpi(_flagged);
        final bool active =
            controller.isActive(_flagged) && !controller.isActive(_intake);
        final bool unmappedNeverActive = !controller.isActive(_unmapped);
        controller.clear();
        return active && unmappedNeverActive && !controller.isActive(_flagged);
      },
    );
  });

  group('GEN-04880-A01 :: rendered', () {
    testWidgets('[GEN-04880-G6] tapping a card in the real grid narrows the '
        'dashboard, and tapping it again restores it', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final HabotDashboardController controller =
          HabotDashboardController(facetKey: 'category');
      addTearDown(controller.dispose);
      const List<HabotKpi> all = <HabotKpi>[_intake, _flagged, _unmapped];

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: AnimatedBuilder(
              animation: controller,
              builder: (BuildContext context, Widget? _) {
                final List<HabotKpi> visible = controller.selection
                    .apply<HabotKpi>(
                      all,
                      (HabotKpi k, String _) => k.filterKey ?? '',
                    );
                return SingleChildScrollView(
                  child: HabotKpiGrid(
                    kpis: visible,
                    onKpiTapped: controller.applyFromKpi,
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HabotKpiCard), findsNWidgets(3));

      await tester.tap(find.byKey(HabotKpiCard.keyFor('flagged')));
      await tester.pumpAndSettle();

      expect(
        find.byType(HabotKpiCard),
        findsOneWidget,
        reason: 'the dashboard narrowed to the tapped category',
      );
      expect(find.byKey(HabotKpiCard.keyFor('flagged')), findsOneWidget);

      await tester.tap(find.byKey(HabotKpiCard.keyFor('flagged')));
      await tester.pumpAndSettle();
      expect(
        find.byType(HabotKpiCard),
        findsNWidgets(3),
        reason: 'and the same gesture restored it',
      );
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'GEN-04880-G6',
          requirementSource:
              'Setup Step (Action): "Implement the SELF-CHASING automation '
              'behavior: Clicking any KPI card automatically applies the '
              'corresponding filter."',
          description:
              'In the real grid a tap on a KPI card narrows the dashboard to '
              'that category and a second tap restores the full set',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-04880-G7] an unmapped card cannot be tapped at all', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final HabotDashboardController controller =
          HabotDashboardController(facetKey: 'category');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: HabotKpiGrid(
              kpis: const <HabotKpi>[_unmapped],
              onKpiTapped: controller.applyFromKpi,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(HabotKpiCard.keyFor('latency')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(
        controller.triggerCount,
        0,
        reason: 'the card offered no gesture, so nothing was even attempted',
      );
      expect(controller.selection.isEmpty, isTrue);

      gates.add(
        const AissGate(
          id: 'GEN-04880-G7',
          requirementSource:
              'Setup Step (Action): "...the CORRESPONDING filter." Where there '
              'is no correspondence there is no gesture.',
          description:
              'A KPI with no filter key renders without a tap target, so a tap '
              'on it is swallowed and never reaches the controller',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04880',
        atomicStepReferenceId: 'GEN-04880-A01',
        setupStepAction:
            'Implement the self-chasing automation behavior: Clicking any KPI '
            'card automatically applies the corresponding filter.',
        implementationOrder: 65,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotDashboardController',
          'Component Type': 'Self-chasing KPI-to-filter trigger',
          'Component Properties':
              'one named facet; replace-not-append semantics; every trigger '
              'recorded whether it succeeded or not',
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Automation Trigger Reliability Rate',
            observed:
                '${measuredRate.toStringAsFixed(1)}% over $triggersDriven '
                'driven triggers -- every tap on a mapped KPI produced the '
                'intended selection. Failed triggers are recorded with a '
                'reason and counted in the denominator, so the rate cannot be '
                'flattered by excluding them.',
            floor: '>=99.0% successful automated triggers',
            optimal: '99.9% (three-nines) reliability',
            ceiling: '100% (five-nines+ pursuit)',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/dashboard_controller.dart',
        ],
      ),
    );
  });
}
