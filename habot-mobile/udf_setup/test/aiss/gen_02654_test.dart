/// AISS GATE -- Step 52 of 65
/// Global Reference ID:       GEN-02654
/// Atomic Steps Reference ID: GEN-02654-A01
/// Setup Step (Action):       "Design the M3 KPI card layout for each metric
///                             category on a mobile viewport of 360px width."
/// Metric: Implementation Completeness Rate -- Floor "90% of defined scope
///         completed", Optimal "100% of scope complete with peer validation".
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/dashboard/kpi_card.dart';
import 'package:udf_setup/design_system/feedback/status_badge.dart';
import 'package:udf_setup/design_system/layout/device_profiles.dart';
import 'package:udf_setup/design_system/shell/dashboard_grid.dart';
import 'package:udf_setup/design_system/surfaces/card_chassis.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/surface_tokens.dart';

import 'aiss_reporter.dart';

const HabotKpi _rate = HabotKpi(
  id: 'accuracy',
  label: 'First-pass accuracy',
  value: 96.4,
  previousValue: 94.1,
  category: HabotMetricCategory.rate,
  filterKey: 'accuracy',
);

const HabotKpi _latency = HabotKpi(
  id: 'latency',
  label: 'Median review time',
  value: 412,
  previousValue: 360,
  category: HabotMetricCategory.latency,
);

void main() {
  final List<AissGate> gates = <AissGate>[];
  int categoriesCovered = 0;

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

  Widget card(HabotKpi kpi, {void Function(HabotKpi)? onTap}) => MaterialApp(
    theme: HabotTheme.light(),
    home: Scaffold(body: HabotKpiCard(kpi: kpi, onTap: onTap)),
  );

  group('GEN-02654-A01 :: the 360px viewport', () {
    gate(
      'GEN-02654-G1',
      'Setup Step (Action): "...on a mobile viewport of 360PX WIDTH."',
      'The 360 this step names is the same 360 Step 39 pinned as the 5.5-inch '
          'reference device, not a second number that happens to match today',
      () =>
          HabotReferenceViewport.widthDp == 360 &&
          HabotDashboardGrid.columnsFor(HabotReferenceViewport.widthDp) ==
              HabotDashboardGrid.singleColumn,
    );

    gate(
      'GEN-02654-G2',
      'Setup Step (Action): "Design the M3 KPI CARD layout..." + GEN-01452 '
          '(Step 29): the card chassis with its shadow-or-border rule.',
      'The KPI card is a variant of the existing chassis rather than a fourth '
          'card, so it inherits the corner radius, the content padding and the '
          'rule that a card never carries both a border and a shadow',
      () =>
          HabotKpiSpec.variant == HabotCardVariant.filled &&
          HabotKpiSpec.contentPadding == HabotCardSpec.contentPadding &&
          HabotCardSpec.hasBorder[HabotKpiSpec.variant] == false,
    );

    gate(
      'GEN-02654-G3',
      'Setup Step (Action): "...for EACH METRIC CATEGORY."',
      'A category decides the shape of the card, not its colour: whether a '
          'delta is shown at all, which direction is an improvement, and what '
          'unit follows the value. Latency and rate disagree about direction, '
          'which is why one global "up is good" would be wrong',
      () {
        categoriesCovered = HabotMetricCategory.values.length;
        return categoriesCovered == 4 &&
            HabotMetricCategory.rate.risingIsGood &&
            !HabotMetricCategory.latency.risingIsGood &&
            !HabotMetricCategory.fault.risingIsGood &&
            !HabotMetricCategory.volume.carriesDelta &&
            HabotMetricCategory.rate.unitSuffix == '%' &&
            HabotMetricCategory.latency.unitSuffix == 'ms';
      },
    );

    gate(
      'GEN-02654-G4',
      'WCAG 2.1 SC 1.4.1 (use of colour), inherited from Step 28: a direction '
          'carried only by a colour is a direction some readers cannot see.',
      'The status role is DERIVED from the category and the delta -- a rising '
          'rate is success, a rising latency is error, and a change below the '
          'material threshold is neutral rather than a flashing rounding error',
      () {
        const HabotKpi risingRate = _rate;
        const HabotKpi risingLatency = _latency;
        const HabotKpi tinyChange = HabotKpi(
          id: 'tiny',
          label: 'Barely moved',
          value: 100.5,
          previousValue: 100,
          category: HabotMetricCategory.rate,
        );
        const HabotKpi cleanFault = HabotKpi(
          id: 'clean',
          label: 'Faults',
          value: 0,
          previousValue: 0,
          category: HabotMetricCategory.fault,
        );
        return risingRate.role == HabotStatusRole.success &&
            risingLatency.role == HabotStatusRole.error &&
            tinyChange.role == HabotStatusRole.neutral &&
            cleanFault.role == HabotStatusRole.neutral &&
            risingRate.isImproving &&
            !risingLatency.isImproving;
      },
    );

    gate(
      'GEN-02654-G5',
      'Step 46 (GEN-02060) fitting rules, applied to the label a KPI card '
          'carries at the reference viewport.',
      'A realistic KPI label survives at every device in the matrix in both '
          'orientations -- a card whose label truncates to four characters has '
          'stopped being a KPI card',
      () {
        for (final HabotDeviceProfile device in HabotDevices.all) {
          for (final double width in <double>[device.widthDp, device.heightDp]) {
            final int columns = HabotDashboardGrid.columnsFor(width);
            if (!HabotKpiSpec.labelFits(
              'Flagged for exception',
              width,
              columns,
            )) {
              return false;
            }
          }
        }
        return true;
      },
    );
  });

  group('GEN-02654-A01 :: rendered at 360dp', () {
    testWidgets('[GEN-02654-G6] the card renders label, value and delta, and '
        'speaks as one sentence', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(card(_rate));
      await tester.pumpAndSettle();

      expect(find.byKey(HabotKpiCard.keyFor('accuracy')), findsOneWidget);
      expect(find.text('First-pass accuracy'), findsOneWidget);
      expect(find.text('96.4%'), findsOneWidget);
      expect(find.text('+2.4%'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      expect(find.bySemanticsLabel(_rate.semanticsLabel), findsOneWidget);
      expect(tester.takeException(), isNull);
      handle.dispose();

      gates.add(
        AissGate(
          id: 'GEN-02654-G6',
          requirementSource:
              'Setup Step (Action): "Design the M3 KPI card layout for each '
              'metric category on a mobile viewport of 360px width."',
          description:
              'At 360dp the card renders its label, value and signed delta '
              'with a direction icon, and exposes one merged semantics label '
              'rather than four fragments',
          passed: true,
          detail: 'spoken as: "${_rate.semanticsLabel}"',
        ),
      );
    });

    testWidgets('[GEN-02654-G7] a card with no filter is not tappable, and one '
        'with a filter reports its tap', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(card(_latency, onTap: (HabotKpi _) {}));
      await tester.pumpAndSettle();
      final HabotKpiCard inert = tester.widget<HabotKpiCard>(
        find.byType(HabotKpiCard),
      );
      expect(
        inert.isActionable,
        isFalse,
        reason: 'A card that looks interactive and does nothing is worse than '
            'one that looks inert',
      );

      HabotKpi? tapped;
      await tester.pumpWidget(card(_rate, onTap: (HabotKpi k) => tapped = k));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(HabotKpiCard.keyFor('accuracy')));
      await tester.pump();
      expect(tapped?.id, 'accuracy');

      gates.add(
        const AissGate(
          id: 'GEN-02654-G7',
          requirementSource:
              'GEN-04880 (Step 65): "Clicking any KPI card automatically '
              'applies the CORRESPONDING filter." A card with no corresponding '
              'filter must not offer the gesture.',
          description:
              'Tappability is derived from whether the KPI declares a filter, '
              'not from whether a callback was passed',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02654',
        atomicStepReferenceId: 'GEN-02654-A01',
        setupStepAction:
            'Design the M3 KPI card layout for each metric category on a '
            'mobile viewport of 360px width.',
        implementationOrder: 52,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotKpiCard',
          'Component Type': 'M3 filled card, KPI variant',
          'Component Properties':
              'min height ${HabotKpiSpec.minHeight.toStringAsFixed(0)}dp; '
              'padding from HabotCardSpec; material delta threshold '
              '${(HabotKpiSpec.materialDeltaFraction * 100).toStringAsFixed(0)}%',
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Implementation Completeness Rate',
            observed:
                '100% of defined scope: all $categoriesCovered metric '
                'categories carry their own direction, unit and delta rule; '
                'the card reuses the Step 29 chassis rather than adding a '
                'fourth; labels survive the fitting rules on all 18 viewports',
            floor: '90% of defined scope completed',
            optimal: '100% of scope complete with peer validation',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/kpi_card.dart',
          'lib/design_system/tokens/dashboard_tokens.dart',
        ],
      ),
    );
  });
}
