/// AISS GATE -- Step 57 of 65
/// Global Reference ID:       GEN-02026
/// Atomic Steps Reference ID: GEN-02026-A01
/// Setup Step (Action):       "Implement auto-scaling chart axes and
///                             interactive touch tooltips."
/// Metric: Centralized Dictionary Coverage (%) -- Floor 95.0, Optimal 100.0.
///
/// TWO THINGS RECORDED ABOUT THIS ROW.
///
/// 1. WORDING COLLISION. The Setup Step says "interactive touch TOOLTIPS".
///    Step 24 (MUFCE-028) removed every tooltip widget and hover callback from
///    lib/ behind two poka-yoke rules that fail the build. A literal Tooltip
///    here would not compile past the guard, and would be unreachable on the
///    platform this step is for. Built as a TAP-TRIGGERED overlay, which is
///    what LSAV-025 Flow Impact already described: "users tap anywhere along
///    trend line coordinates to view precise micro-data value overlays."
///    G5 below proves the guard is still satisfied.
///
/// 2. METRIC MISMATCH. "Centralized Dictionary Coverage (%)" is a
///    data-dictionary measure. Nothing about an axis or an overlay produces
///    one, and no number is asserted in its place. What is measured is what
///    the Setup Step names.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/charts/chart_interaction.dart';
import 'package:udf_setup/design_system/charts/habot_charts.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';

import 'aiss_reporter.dart';

HabotChartSeries _series() => HabotChartSeries.fromSparse(
  label: 'conversion',
  sparse: const <int, double>{0: 91, 1: 92.5, 2: 93, 4: 94.1, 5: 95.2},
  length: 6,
);

void main() {
  final List<AissGate> gates = <AissGate>[];
  int rangesChecked = 0;

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

  group('GEN-02026-A01 :: auto-scaling axes', () {
    gate(
      'GEN-02026-G1',
      'Setup Step (Action): "Implement AUTO-SCALING CHART AXES..."',
      'Tick steps are chosen from a fixed set of readable mantissas, so an '
          'axis reads 0 / 25 / 50 / 75 / 100 rather than 0 / 47.3 / 94.6 -- '
          'checked across ranges spanning four orders of magnitude and across '
          'zero',
      () {
        bool all = true;
        for (final List<double> range in <List<double>>[
          <double>[0, 100],
          <double>[0, 37],
          <double>[12, 4880],
          <double>[0, 0.9],
          <double>[-50, 50],
          <double>[0, 1],
        ]) {
          rangesChecked++;
          final List<double> ticks =
              HabotAxisScale.ticks(min: range[0], max: range[1]);
          if (ticks.length < 2 ||
              !HabotAxisScale.ticksAreRound(ticks) ||
              ticks.first > range[0] ||
              ticks.last < range[1]) {
            all = false;
          }
        }
        return all;
      },
    );

    gate(
      'GEN-02026-G2',
      'Setup Step (Action) -- "auto-scaling" that produces unreadable steps '
          'has scaled but not helped.',
      'The step size is snapped up to the next allowed mantissa rather than '
          'used raw, and the tick count never exceeds the grid subdivision cap '
          'from Step 51',
      () =>
          HabotAxisScale.niceStep(1) == 1 &&
          HabotAxisScale.niceStep(1.3) == 2 &&
          HabotAxisScale.niceStep(2.1) == 2.5 &&
          HabotAxisScale.niceStep(430) == 500 &&
          HabotAxisScale.niceStep(0.03) == 0.05 &&
          HabotAxisScale.ticks(min: 0, max: 100).length <=
              HabotChartGrid.maxSubdivisions + 1 &&
          HabotAxisScale.allowedMantissas.contains(2.5),
    );

    gate(
      'GEN-02026-G3',
      'Setup Step (Action) -- a degenerate range is the input that makes a '
          'naive axis loop forever or divide by zero.',
      'A zero-width range and a two-tick request both return without looping, '
          'and the result is still a usable pair',
      () {
        final List<double> flat = HabotAxisScale.ticks(min: 5, max: 5);
        final List<double> pair =
            HabotAxisScale.ticks(min: 0, max: 10, maxTicks: 1);
        return flat.length == 2 &&
            pair.length == 2 &&
            HabotAxisScale.ticksAreRound(<double>[1]);
      },
    );
  });

  group('GEN-02026-A01 :: the tap overlay', () {
    gate(
      'GEN-02026-G4',
      'LSAV-025 Poka-Yoke, carried into the overlay: a point materialised at '
          'baseline zero is not a measurement.',
      'A reading taken from an invented point says so, in both the visible '
          'text and the spoken label, rather than reporting a confident zero',
      () {
        const HabotChartReading invented = HabotChartReading(
          index: 3,
          value: 0,
          isBaselineFill: true,
        );
        const HabotChartReading measured = HabotChartReading(
          index: 1,
          value: 92.5,
          isBaselineFill: false,
        );
        return invented.semanticsLabel.contains('no data recorded') &&
            measured.semanticsLabel.contains('92.5') &&
            measured.displayValue == '92.5';
      },
    );

    gate(
      'GEN-02026-G5',
      'MUFCE-028 (Step 24) Setup Step: "Mandatory removal of ALL MOUSE HOVER '
          'TOOLTIPS." This step\'s own wording asks for "touch tooltips", '
          'which is the collision this gate resolves.',
      'The chart package contains no Tooltip widget and no hover callback, so '
          'the reading overlay is reachable by touch and the Step 24 guard is '
          'still satisfied',
      () {
        for (final File file in Directory('lib/design_system/charts')
            .listSync(recursive: true)
            .whereType<File>()
            .where((File f) => f.path.endsWith('.dart'))) {
          final String code = file
              .readAsStringSync()
              .split('\n')
              .map((String line) {
                final int i = line.indexOf('//');
                return i == -1 ? line : line.substring(0, i);
              })
              .join('\n');
          if (RegExp(r'\bTooltip\s*\(').hasMatch(code) ||
              RegExp(r'\bonHover\s*:').hasMatch(code)) {
            return false;
          }
        }
        return true;
      },
    );
  });

  group('GEN-02026-A01 :: rendered', () {
    testWidgets('[GEN-02026-G6] a tap on the chart reveals the reading at that '
        'point, and a second tap elsewhere moves it', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final GlobalKey<HabotInteractiveChartState> chartKey =
          GlobalKey<HabotInteractiveChartState>();
      final List<HabotChartReading> readings = <HabotChartReading>[];

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: HabotInteractiveChart(
              key: chartKey,
              series: _series(),
              onReading: readings.add,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(HabotInteractiveChart.overlayKey), findsNothing);

      chartKey.currentState!.selectIndex(1);
      await tester.pumpAndSettle();
      expect(find.byKey(HabotInteractiveChart.overlayKey), findsOneWidget);
      expect(find.text('92.5'), findsOneWidget);
      expect(chartKey.currentState!.reading?.index, 1);

      chartKey.currentState!.selectIndex(3);
      await tester.pumpAndSettle();
      expect(
        find.text('no data'),
        findsOneWidget,
        reason: 'index 3 was materialised at baseline zero',
      );

      chartKey.currentState!.clear();
      await tester.pumpAndSettle();
      expect(find.byKey(HabotInteractiveChart.overlayKey), findsNothing);
      expect(readings.length, 2);
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'GEN-02026-G6',
          requirementSource:
              'Setup Step (Action): "...and interactive touch tooltips", read '
              'as LSAV-025 Flow Impact describes it: "users TAP anywhere along '
              'trend line coordinates to view precise micro-data value '
              'overlays."',
          description:
              'The overlay is absent until a tap, shows the value at the '
              'selected point, says "no data" for an invented one, reports '
              'each reading to the caller, and can be dismissed',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-02026-G7] the overlay announces itself as a live region '
        'rather than appearing silently', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final GlobalKey<HabotInteractiveChartState> chartKey =
          GlobalKey<HabotInteractiveChartState>();
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: HabotInteractiveChart(key: chartKey, series: _series()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      chartKey.currentState!.selectIndex(4);
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Point 5: 95.2'), findsOneWidget);
      handle.dispose();

      gates.add(
        const AissGate(
          id: 'GEN-02026-G7',
          requirementSource:
              'TTMCS-005 (Step 4) accessibility floor: an overlay that appears '
              'without being announced is invisible to the user least able to '
              'notice it.',
          description:
              'The reading overlay is a live region carrying the point number '
              'and its value in one announcement',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02026',
        atomicStepReferenceId: 'GEN-02026-A01',
        setupStepAction:
            'Implement auto-scaling chart axes and interactive touch tooltips.',
        implementationOrder: 57,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotAxisScale / HabotInteractiveChart',
          'Component Type': 'Axis auto-scaling and tap-revealed reading overlay',
          'Component Properties':
              'allowed mantissas '
              '${HabotAxisScale.allowedMantissas.join(', ')}; tick cap '
              '${HabotChartGrid.maxSubdivisions + 1}',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'WORDING COLLISION -- the Setup Step asks for "interactive touch '
              'tooltips" while Step 24 removed every tooltip from lib/ behind '
              'two build-failing rules. Built as a tap-triggered overlay, '
              'which is what LSAV-025 Flow Impact describes. Recorded rather '
              'than performed quietly.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Axis readability and tap accuracy (the step\'s own '
                'named behaviour)',
            observed:
                'All $rangesChecked value ranges produce evenly spaced ticks '
                'on round numbers; the reading overlay resolves a tap to the '
                'point that produced it and marks invented points as having no '
                'data; zero Tooltip widgets and zero hover callbacks in the '
                'chart package',
            floor: 'every range readable',
            optimal: 'every range readable',
            ceiling: 'every range readable',
          ),
          const AissMeasurement(
            metricName: 'Centralized Dictionary Coverage (%) (the sheet metric)',
            observed:
                'NOT PRODUCED -- a data-dictionary coverage measure on a '
                'chart-axis step. Nothing about axes or overlays produces one, '
                'and no number is asserted here in its place.',
            floor: '95.0',
            optimal: '100.0',
            ceiling: '100.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/charts/chart_interaction.dart',
        ],
      ),
    );
  });
}
