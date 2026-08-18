/// AISS GATE -- Step 62 of 65
/// Global Reference ID:       GEN-02709
/// Atomic Steps Reference ID: GEN-02709-A01
/// Setup Step (Action):       "Build an aggregate infrastructure KPI summary
///                             section at the top of the dashboard visible on
///                             initial load."
/// Metric: Dashboard Load Time -- Floor "Dashboard loads within 5 seconds",
///         Optimal "Dashboard loads within 2 seconds", Ceiling "Load time
///         exceeding 10 seconds".
///
/// "VISIBLE ON INITIAL LOAD" is the requirement doing the work, and G3 is the
/// gate that takes it literally: the strip is outside the scroll view by
/// construction, so it cannot be scrolled away, and it renders its skeleton at
/// full size on the first frame rather than appearing when data arrives.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/dashboard/kpi_card.dart';
import 'package:udf_setup/design_system/dashboard/summary_strip.dart';
import 'package:udf_setup/design_system/feedback/status_badge.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/dashboard_tokens.dart';

import 'aiss_reporter.dart';

const List<HabotKpi> _healthy = <HabotKpi>[
  HabotKpi(
    id: 'intake',
    label: 'Records in intake',
    value: 148,
    category: HabotMetricCategory.volume,
  ),
  HabotKpi(
    id: 'accuracy',
    label: 'First-pass accuracy',
    value: 96.4,
    previousValue: 94.1,
    category: HabotMetricCategory.rate,
  ),
];

const List<HabotKpi> _mixed = <HabotKpi>[
  ..._healthy,
  HabotKpi(
    id: 'latency',
    label: 'Median review time',
    value: 412,
    previousValue: 360,
    category: HabotMetricCategory.latency,
  ),
  HabotKpi(
    id: 'flagged',
    label: 'Flagged for exception',
    value: 3,
    previousValue: 1,
    category: HabotMetricCategory.fault,
  ),
];

void main() {
  final List<AissGate> gates = <AissGate>[];
  Duration firstFrame = Duration.zero;

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

  group('GEN-02709-A01 :: the aggregate', () {
    gate(
      'GEN-02709-G1',
      'Setup Step (Action): "Build an AGGREGATE infrastructure KPI summary '
          'section..."',
      'A summary is a shorter, different set derived from the KPIs -- how many '
          'are healthy, how many need attention, and the single worst one by '
          'name -- rather than the same KPIs in a smaller font',
      () {
        final HabotKpiAggregate healthy = HabotKpiAggregate.from(_healthy);
        final HabotKpiAggregate mixed = HabotKpiAggregate.from(_mixed);
        return healthy.allHealthy &&
            healthy.needsAttention == 0 &&
            healthy.worst == null &&
            healthy.role == HabotStatusRole.success &&
            mixed.total == 4 &&
            mixed.needsAttention == 2 &&
            mixed.worst != null &&
            mixed.role == HabotStatusRole.warning &&
            mixed.headline == '2 of 4 need attention';
      },
    );

    gate(
      'GEN-02709-G2',
      'Setup Step (Action) -- a summary that promotes the least-good healthy '
          'metric when everything is fine is telling the reader to worry about '
          'nothing.',
      'The worst KPI is the one with the largest movement among those needing '
          'attention, and it is null when nothing does -- in which case the '
          'strip says so in words rather than naming a metric',
      () {
        final HabotKpiAggregate healthy = HabotKpiAggregate.from(_healthy);
        final HabotKpiAggregate mixed = HabotKpiAggregate.from(_mixed);
        final HabotKpiAggregate empty =
            HabotKpiAggregate.from(const <HabotKpi>[]);
        return healthy.detail == 'Nothing is trending the wrong way.' &&
            mixed.worst!.id == 'flagged' &&
            mixed.detail.contains('Flagged for exception') &&
            empty.total == 0 &&
            empty.headline == 'No metrics yet' &&
            empty.role == HabotStatusRole.neutral;
      },
    );
  });

  group('GEN-02709-A01 :: visible on initial load', () {
    testWidgets('[GEN-02709-G3] the strip occupies its full height on the '
        'FIRST frame, loading or loaded, and never changes size', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final Stopwatch clock = Stopwatch()..start();
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: const Scaffold(
            body: HabotSummaryStrip(kpis: <HabotKpi>[], isLoading: true),
          ),
        ),
      );
      clock.stop();
      firstFrame = clock.elapsed;

      expect(find.byKey(HabotSummaryStrip.skeletonKey), findsOneWidget);
      final Size loading =
          tester.getSize(find.byKey(HabotSummaryStrip.skeletonKey));

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: const Scaffold(body: HabotSummaryStrip(kpis: _mixed)),
        ),
      );
      await tester.pumpAndSettle();
      final Size loaded =
          tester.getSize(find.byKey(HabotSummaryStrip.stripKey));

      expect(loaded.height, loading.height);
      expect(loaded.height, HabotSummaryStrip.height);
      expect(loaded.height, HabotDashboardTokens.summaryStripHeight);
      expect(find.text('2 of 4 need attention'), findsOneWidget);
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'GEN-02709-G3',
          requirementSource:
              'Setup Step (Action): "...VISIBLE ON INITIAL LOAD." A strip that '
              'renders after its data arrives is not visible on initial load.',
          description:
              'The strip is present and full height on the first frame while '
              'loading, and the loaded strip is exactly the same height -- so '
              'the data arriving moves nothing',
          passed: true,
          detail:
              'first frame ${firstFrame.inMicroseconds / 1000}ms on the test '
              'host; height ${loaded.height.toStringAsFixed(0)}dp loading and '
              'loaded',
        ),
      );
    });

    testWidgets('[GEN-02709-G4] the strip sits outside the scroll view and '
        'cannot be scrolled away', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: HabotDashboardSection(
              kpis: _mixed,
              scrollingContent: Column(
                children: <Widget>[
                  for (int i = 0; i < 40; i++)
                    SizedBox(height: 48, child: Text('row $i')),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Offset before =
          tester.getTopLeft(find.byKey(HabotSummaryStrip.stripKey));
      await tester.drag(find.text('row 3'), const Offset(0, -500));
      await tester.pumpAndSettle();
      final Offset after =
          tester.getTopLeft(find.byKey(HabotSummaryStrip.stripKey));

      expect(
        after,
        before,
        reason: 'The strip is not passed to the scrolling content, so it '
            'cannot be inside it -- the same structural argument Step 38 made '
            'for the pinned metric strip',
      );
      expect(find.text('2 of 4 need attention'), findsOneWidget);
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'GEN-02709-G4',
          requirementSource:
              'Setup Step (Action): "at the TOP OF THE DASHBOARD visible on '
              'initial load."',
          description:
              'After scrolling 500dp of dashboard content the summary strip '
              'has not moved and still shows its aggregate',
          passed: true,
          detail: 'strip origin ${before.dy.toStringAsFixed(1)}dp, unchanged',
        ),
      );
    });

    testWidgets('[GEN-02709-G5] the strip announces its aggregate as one '
        'sentence rather than four fragments', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: const Scaffold(body: HabotSummaryStrip(kpis: _mixed)),
        ),
      );
      await tester.pumpAndSettle();

      final HabotKpiAggregate aggregate = HabotKpiAggregate.from(_mixed);
      expect(find.bySemanticsLabel(aggregate.semanticsLabel), findsOneWidget);
      handle.dispose();

      gates.add(
        AissGate(
          id: 'GEN-02709-G5',
          requirementSource:
              'TTMCS-005 (Step 4) accessibility floor applied to the first '
              'thing on the dashboard.',
          description:
              'The strip exposes one semantics node carrying the headline and '
              'the worst metric together',
          passed: true,
          detail: 'spoken as: "${aggregate.semanticsLabel}"',
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02709',
        atomicStepReferenceId: 'GEN-02709-A01',
        setupStepAction:
            'Build an aggregate infrastructure KPI summary section at the top '
            'of the dashboard visible on initial load.',
        implementationOrder: 62,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotSummaryStrip / HabotDashboardSection',
          'Component Type': 'Aggregate KPI summary, pinned above the fold',
          'Component Properties':
              'height '
              '${HabotDashboardTokens.summaryStripHeight.toStringAsFixed(0)}dp '
              'loading and loaded; outside the scroll view by construction',
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Dashboard Load Time',
            observed:
                'The strip is on screen at full height on the FIRST frame '
                '(${firstFrame.inMicroseconds / 1000}ms to first pump on the '
                'test host), before any data arrives, and does not change size '
                'when it does. Time-to-visible is therefore bounded by the '
                'frame rather than by the network. NOT a cold app start and '
                'not a handset reading -- a device number needs a '
                'profile-mode run.',
            floor: 'Dashboard loads within 5 seconds',
            optimal: 'Dashboard loads within 2 seconds',
            ceiling: 'Load time exceeding 10 seconds',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/dashboard/summary_strip.dart',
        ],
      ),
    );
  });
}
