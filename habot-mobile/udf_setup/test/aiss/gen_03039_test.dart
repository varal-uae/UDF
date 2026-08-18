/// AISS GATE -- Step 58 of 65
/// Global Reference ID:       GEN-03039
/// Atomic Steps Reference ID: GEN-03039-A01
/// Setup Step (Action):       "Display a mobile SLI health dashboard with
///                             latency sparklines and drift counters."
/// Metric: Mobile Response/Load Latency (ms) -- Floor 1000.0, Optimal 300.0,
///         Ceiling 2000.0.
///
/// INVERTED BANDS, RECORDED. Everywhere else in the sheet the Floor is the
/// minimum acceptable value and the Ceiling is the best. For latency lower is
/// better, so these run the other way: 300ms is the target, 1000ms the edge of
/// acceptable, 2000ms the failure threshold. The numbers are not wrong, the
/// convention is reversed, and anyone scanning quickly will read them
/// backwards. The reading used here is stated so it can be argued with.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/charts/habot_charts.dart';
import 'package:udf_setup/design_system/dashboard/sli_health_view.dart';
import 'package:udf_setup/design_system/feedback/status_badge.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';

import 'aiss_reporter.dart';

HabotChartSeries _history(String label, List<double> values) =>
    HabotChartSeries.fromSparse(
      label: label,
      sparse: <int, double>{
        for (int i = 0; i < values.length; i++) i: values[i],
      },
      length: values.length,
    );

List<HabotSli> _indicators() => <HabotSli>[
  HabotSli(
    id: 'submit',
    name: 'Submit round trip',
    objectiveMs: 300,
    history: _history('submit', <double>[280, 291, 305, 288, 274]),
  ),
  HabotSli(
    id: 'search',
    name: 'Search results',
    objectiveMs: 350,
    history: _history('search', <double>[402, 418, 441, 470, 512]),
  ),
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

  group('GEN-03039-A01 :: the bands, read in the latency sense', () {
    gate(
      'GEN-03039-G1',
      'Metric: Mobile Response/Load Latency (ms) -- Floor 1000.0, Optimal '
          '300.0, Ceiling 2000.0. Read in the latency sense: lower is better, '
          'so the bands run the opposite way to the sheet convention.',
      'The three thresholds are the sheet\'s own numbers, ordered so that '
          'optimal is the smallest and failure the largest, and "better" is a '
          'named function rather than a comparison written at each call site',
      () =>
          HabotLatencyBands.optimalMs == 300 &&
          HabotLatencyBands.acceptableMs == 1000 &&
          HabotLatencyBands.failureMs == 2000 &&
          HabotLatencyBands.optimalMs < HabotLatencyBands.acceptableMs &&
          HabotLatencyBands.acceptableMs < HabotLatencyBands.failureMs &&
          HabotLatencyBands.isBetter(280, 900),
    );

    gate(
      'GEN-03039-G2',
      'WCAG 2.1 SC 1.4.1 through Step 28: a band carried only by a colour is '
          'a band some readers cannot see.',
      'Each band maps to a status role that brings an icon and a name with it, '
          'and the boundaries are inclusive on the good side so a reading '
          'exactly at the target counts as meeting it',
      () =>
          HabotLatencyBands.roleFor(280) == HabotStatusRole.success &&
          HabotLatencyBands.roleFor(300) == HabotStatusRole.success &&
          HabotLatencyBands.roleFor(512) == HabotStatusRole.neutral &&
          HabotLatencyBands.roleFor(1400) == HabotStatusRole.warning &&
          HabotLatencyBands.roleFor(2400) == HabotStatusRole.error &&
          HabotLatencyBands.bandName(280) == 'optimal' &&
          HabotLatencyBands.bandName(2400) == 'failing',
    );
  });

  group('GEN-03039-A01 :: drift counters', () {
    gate(
      'GEN-03039-G3',
      'Setup Step (Action): "...with latency sparklines and DRIFT COUNTERS."',
      'Drift is the signed distance from the objective, not from a fixed '
          'threshold, so two indicators with different objectives are each '
          'measured against their own -- and the sign is preserved, because '
          'the direction is the information',
      () {
        final List<HabotSli> slis = _indicators();
        final HabotSli inside = slis[0];
        final HabotSli outside = slis[1];
        return inside.currentMs == 274 &&
            inside.driftMs == -26 &&
            inside.isWithinObjective &&
            outside.currentMs == 512 &&
            outside.driftMs == 162 &&
            !outside.isWithinObjective &&
            outside.displayDrift.startsWith('+') &&
            inside.driftFraction < 0 &&
            outside.driftFraction > 0;
      },
    );

    gate(
      'GEN-03039-G4',
      'Setup Step (Action) -- a health dashboard listing six rows has not '
          'answered "is it healthy?".',
      'The view reports how many indicators are inside their objective, which '
          'is the number worth reading first',
      () {
        final List<HabotSli> slis = _indicators();
        return HabotSliHealthView.withinObjective(slis) == 1 &&
            HabotSliHealthView.withinObjective(<HabotSli>[]) == 0;
      },
    );

    gate(
      'GEN-03039-G5',
      'TTMCS-005 (Step 4) accessibility floor applied to a dense metric row.',
      'Each indicator speaks one sentence carrying its name, its reading, its '
          'band and its drift -- rather than the six fragments the row is '
          'built from',
      () {
        final HabotSli sli = _indicators()[1];
        final String spoken = sli.semanticsLabel;
        return spoken.contains('Search results') &&
            spoken.contains('512') &&
            spoken.contains('acceptable') &&
            spoken.contains('over objective') &&
            spoken.contains('162');
      },
    );
  });

  group('GEN-03039-A01 :: rendered', () {
    testWidgets('[GEN-03039-G6] each indicator renders a sparkline, a reading '
        'and its drift, and speaks as one node', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final List<HabotSli> slis = _indicators();
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(body: HabotSliHealthView(indicators: slis)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(HabotSliHealthView.viewKey), findsOneWidget);
      expect(
        find.byKey(HabotSliHealthView.rowKeyFor('submit')),
        findsOneWidget,
      );
      expect(find.byType(HabotSparkline), findsNWidgets(slis.length));
      expect(find.text('274ms'), findsOneWidget);
      expect(find.text('512ms'), findsOneWidget);
      expect(find.text('+162ms vs objective'), findsOneWidget);
      expect(find.bySemanticsLabel(slis[1].semanticsLabel), findsOneWidget);
      expect(tester.takeException(), isNull);
      handle.dispose();

      gates.add(
        const AissGate(
          id: 'GEN-03039-G6',
          requirementSource:
              'Setup Step (Action): "Display a mobile SLI health dashboard '
              'with latency sparklines and drift counters."',
          description:
              'At 360dp each indicator renders one sparkline, its current '
              'reading and its signed drift, and exposes a single merged '
              'semantics node',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    final List<HabotSli> slis = _indicators();
    // Built up front rather than inside the string: a nested interpolation
    // holding its own quoted strings is legal Dart and unreadable code.
    final StringBuffer readings = StringBuffer();
    for (final HabotSli sli in slis) {
      if (readings.isNotEmpty) {
        readings.write('; ');
      }
      final String sign = sli.driftMs > 0 ? '+' : '';
      readings.write(
        '${sli.name} ${sli.currentMs.round()}ms '
        '(${HabotLatencyBands.bandName(sli.currentMs)}, drift '
        '$sign${sli.driftMs.round()}ms)',
      );
    }
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03039',
        atomicStepReferenceId: 'GEN-03039-A01',
        setupStepAction:
            'Display a mobile SLI health dashboard with latency sparklines and '
            'drift counters.',
        implementationOrder: 58,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotSliHealthView',
          'Component Type': 'SLI health view with sparklines and drift',
          'Component Properties':
              'optimal ${HabotLatencyBands.optimalMs.toStringAsFixed(0)}ms, '
              'acceptable ${HabotLatencyBands.acceptableMs.toStringAsFixed(0)}'
              'ms, failure ${HabotLatencyBands.failureMs.toStringAsFixed(0)}ms',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'INVERTED BANDS -- the sheet lists Floor 1000 / Optimal 300 / '
              'Ceiling 2000 for a latency metric, which is the opposite order '
              'to every other row. Read in the latency sense (300ms target, '
              '2000ms failure) and stated explicitly so the reading is '
              'reviewable.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Mobile Response/Load Latency (ms)',
            observed:
                '${HabotSliHealthView.withinObjective(slis)} of '
                '${slis.length} indicators inside their own objective. '
                'Readings: $readings',
            floor: '1000.0 (edge of acceptable, in the latency sense)',
            optimal: '300.0 (the target)',
            ceiling: '2000.0 (the failure threshold)',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/sli_health_view.dart',
        ],
      ),
    );
  });
}
