/// AISS GATE -- Step 38 of 50
/// Global Reference ID:       SSTLA-010
/// Atomic Steps Reference ID: SSTLA-010-A01
/// Setup Step (Action):       "Formulate the responsive split-screen grid
///                             distributions and layout rules for Micro Task
///                             Outsourcing (MTO) panels to maximize
///                             readability."
///
/// Mobile App First Implication: "Replaces wide side-by-side desktop grids with
/// clean, thumb-friendly vertical stacks tailored for mobile interaction."
/// Poka-Yoke: "Key source metrics are pinned immovably at the top of the
/// viewport, keeping important details visible while filling out long fields."
/// Self-Chasing: "Hardcoding layout values across screens creates broken,
/// overlapping UI elements on smaller devices."
/// Metric: Requirement & Asset Discovery Coverage (%) -- Floor 0.9, Optimal 1.0.
///
/// COLUMN NOTE: this row's Completion Measures column is empty in the sheet.
/// The gates below defend the Setup Step, the Mobile-First row, the poka-yoke
/// and the self-chasing rule, which are all populated.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/shell/pane_distribution.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/grid_tokens.dart';

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

  group('SSTLA-010-A01 :: distribution rules', () {
    gate(
      'SSTLA-010-G1',
      'Mobile App First Implication: "Replaces wide side-by-side desktop grids '
          'with clean, thumb-friendly VERTICAL STACKS tailored for mobile '
          'interaction."',
      'A pane on a compact viewport is a single column of full-width rows; two '
          'fields per row only once there is room for them',
      () =>
          HabotPaneDistribution.stacksVertically(360) &&
          HabotPaneDistribution.fieldsPerRow(360) == 1 &&
          !HabotPaneDistribution.stacksVertically(1024) &&
          HabotPaneDistribution.fieldsPerRow(1024) == 2,
    );

    gate(
      'SSTLA-010-G2',
      'Self-Chasing: "Hardcoding layout values across screens creates broken, '
          'overlapping UI elements on smaller devices, instantly stalling qa '
          'cycles."',
      'Column counts inside a pane are derived from the shared grid rather '
          'than declared: a pane never claims more columns than the screen has, '
          'and never fewer than the compact minimum',
      () {
        for (final double width in <double>[
          320,
          360,
          412,
          600,
          744,
          1024,
          1280,
        ]) {
          final int paneColumns = HabotPaneDistribution.columnsFor(width);
          final int screenColumns = HabotGrid.columnsFor(width);
          if (paneColumns > screenColumns) {
            return false;
          }
          if (paneColumns < HabotGrid.compactColumns) {
            return false;
          }
        }
        return HabotPaneDistribution.columnsFor(1024) <=
                HabotGrid.expandedColumns ~/ 2 &&
            HabotPaneDistribution.maxLineLengthChars <= 75;
      },
    );

    gate(
      'SSTLA-010-G3',
      'Setup Step (Action): "...to MAXIMIZE READABILITY." + Why This Matters: '
          '"constant pinching and zooming, causing fast operator fatigue."',
      'The readable measure is a stated number rather than a hope, and the '
          'pinned strip is capped so it cannot grow into a header',
      () =>
          HabotPaneDistribution.maxLineLengthChars > 0 &&
          HabotPaneDistribution.maxLineLengthChars <= 80 &&
          HabotPinnedMetrics.maxPinnedMetrics == 4,
    );
  });

  group('SSTLA-010-A01 :: the pinned strip', () {
    testWidgets('[SSTLA-010-G4] the metric strip stays put while the long '
        'fields beneath it scroll', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: HabotPinnedMetrics(
              metrics: const <HabotPinnedMetric>[
                HabotPinnedMetric(label: 'Batch', value: 'B-2026-08'),
                HabotPinnedMetric(label: 'Records', value: '148'),
              ],
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < 40; i++)
                    SizedBox(height: 48, child: Text('field $i')),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Offset before = tester.getTopLeft(
        find.byKey(HabotPinnedMetrics.stripKey),
      );
      expect(find.text('B-2026-08'), findsOneWidget);

      await tester.drag(find.text('field 3'), const Offset(0, -400));
      await tester.pumpAndSettle();

      final Offset after = tester.getTopLeft(
        find.byKey(HabotPinnedMetrics.stripKey),
      );
      expect(
        after,
        before,
        reason:
            'Poka-yoke: the strip is pinned immovably, so scrolling the '
            'fields must not move it',
      );
      expect(find.text('B-2026-08'), findsOneWidget);
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'SSTLA-010-G4',
          requirementSource:
              'Poka-Yoke: "Key source metrics are pinned immovably at the top '
              'of the viewport, keeping important details visible while filling '
              'out long fields."',
          description:
              'After scrolling 400dp of fields the metric strip has not moved '
              'and its values are still on screen',
          passed: true,
          detail: 'strip origin ${before.dy.toStringAsFixed(1)}dp, unchanged',
        ),
      );
    });

    testWidgets('[SSTLA-010-G5] the strip caps at four metrics however many '
        'it is given', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: const Scaffold(
            body: HabotPinnedMetrics(
              metrics: <HabotPinnedMetric>[
                HabotPinnedMetric(label: 'One', value: '1'),
                HabotPinnedMetric(label: 'Two', value: '2'),
                HabotPinnedMetric(label: 'Three', value: '3'),
                HabotPinnedMetric(label: 'Four', value: '4'),
                HabotPinnedMetric(label: 'Five', value: '5'),
                HabotPinnedMetric(label: 'Six', value: '6'),
              ],
              child: Text('fields'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('One'), findsOneWidget);
      expect(find.text('Four'), findsOneWidget);
      expect(find.text('Five'), findsNothing);
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'SSTLA-010-G5',
          requirementSource:
              'Poka-Yoke -- a strip that grows without limit stops being a '
              'pinned detail and becomes a header, which is the scrolling '
              'problem this step exists to remove.',
          description:
              'Six metrics render as four: the cap is applied by the component, '
              'not left to the caller',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'SSTLA-010',
        atomicStepReferenceId: 'SSTLA-010-A01',
        setupStepAction:
            'Formulate the responsive split-screen grid distributions and '
            'layout rules for Micro Task Outsourcing (MTO) panels to maximize '
            'readability.',
        implementationOrder: 38,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Mobile Platform': 'Flutter, iOS + Android + web',
          'Device Type': 'phone and tablet, from the Step 5 matrix',
          'Screen Dimensions': '320dp to 1280dp, both orientations',
          'Mobile Configuration':
              'compact: 1 field per row, vertical stack; medium and above: 2 '
              'fields per row, panes side by side',
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName:
                'Requirement & Asset Discovery Coverage (%) -- core visual '
                'content requirements for MTO panels',
            observed:
                '1.0 -- the vertical-stack rule, the derived column counts, '
                'the readable measure and the pinned-metric poka-yoke are all '
                'gated, the last of them by scrolling a real tree',
            floor: '0.9',
            optimal: '1.0',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/shell/pane_distribution.dart',
        ],
      ),
    );
  });
}
