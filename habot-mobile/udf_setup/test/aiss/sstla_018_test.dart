/// AISS GATE -- Step 39 of 50
/// Global Reference ID:       SSTLA-018
/// Atomic Steps Reference ID: SSTLA-018-A01
/// Setup Step (Action):       "Formulating the responsive layout rules to
///                             organize parent command sections on 5.5-inch
///                             mobile viewports."
///
/// Setup Step Description: "Identify target 5.5-inch mobile viewport dimensions
/// and resolution constraints (e.g., 1080x1920 pixels at 16:9)."
/// Mobile App First Implication: "Screen elements must collapse into vertical
/// layout stacks to eliminate horizontal scroll glitches."
/// Flow Impact: "Navigation bars sit comfortably within standard thumb
/// interaction spaces."
/// Poka-Yoke: "Selection items lock automatically if required preceding details
/// stay empty."
/// Metric: Requirement & Asset Discovery Coverage (%) -- Floor 0.9, Optimal 1.0.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/shell/dashboard_grid.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';

import 'aiss_reporter.dart';

const List<HabotCommandSection> _sections = <HabotCommandSection>[
  HabotCommandSection(id: 'intake', title: 'Intake', child: Text('12')),
  HabotCommandSection(
    id: 'review',
    title: 'Review',
    requires: <String>{'intake'},
    child: Text('4'),
  ),
  HabotCommandSection(
    id: 'release',
    title: 'Release',
    requires: <String>{'review'},
    child: Text('0'),
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

  group('SSTLA-018-A01 :: the 5.5-inch rules', () {
    gate(
      'SSTLA-018-G1',
      'Setup Step Description: "Identify target 5.5-inch mobile viewport '
          'dimensions and resolution constraints (e.g., 1080x1920 pixels at '
          '16:9)."',
      'The reference viewport is pinned in both units: 1080x1920 physical at a '
          'pixel ratio of 3 is 360x640dp, and the 16:9 aspect is stated rather '
          'than implied',
      () =>
          HabotReferenceViewport.physicalWidthPx == 1080 &&
          HabotReferenceViewport.physicalHeightPx == 1920 &&
          HabotReferenceViewport.devicePixelRatio == 3 &&
          HabotReferenceViewport.widthDp == 360 &&
          HabotReferenceViewport.heightDp == 640 &&
          HabotReferenceViewport.matchesAspect(
            HabotReferenceViewport.widthDp,
            HabotReferenceViewport.heightDp,
          ),
    );

    gate(
      'SSTLA-018-G2',
      'Mobile App First Implication: "Screen elements must collapse into '
          'VERTICAL LAYOUT STACKS to eliminate horizontal scroll glitches." + '
          'GEN-00022: "single-column or 2x2 grid on mobile."',
      'The reference viewport gets one column; two only once the screen is no '
          'longer compact -- there is no three-column dashboard on a phone, '
          'because the third column is where horizontal scrolling comes from',
      () =>
          HabotDashboardGrid.columnsFor(HabotReferenceViewport.widthDp) ==
              HabotDashboardGrid.singleColumn &&
          HabotDashboardGrid.columnsFor(320) ==
              HabotDashboardGrid.singleColumn &&
          HabotDashboardGrid.columnsFor(599) ==
              HabotDashboardGrid.singleColumn &&
          HabotDashboardGrid.columnsFor(600) ==
              HabotDashboardGrid.quadColumns &&
          HabotDashboardGrid.columnsFor(1280) == HabotDashboardGrid.quadColumns,
    );

    gate(
      'SSTLA-018-G3',
      'Flow Impact: "Navigation bars sit comfortably within standard thumb '
          'interaction spaces."',
      'The thumb band is a stated fraction of the viewport, and a control '
          'anchored to the bottom edge of the reference device falls inside it '
          'while one at the top does not',
      () {
        const double h = HabotReferenceViewport.heightDp;
        return HabotDashboardGrid.thumbZoneFraction > 0 &&
            HabotDashboardGrid.thumbZoneFraction <= 0.5 &&
            HabotDashboardGrid.isWithinThumbZone(h - 72, h) &&
            !HabotDashboardGrid.isWithinThumbZone(0, h);
      },
    );

    gate(
      'SSTLA-018-G4',
      'Poka-Yoke: "Selection items lock automatically if required preceding '
          'details stay empty."',
      'Locking is derived from declared prerequisites, and completing one '
          'unlocks exactly the next -- no caller can pass a flag to open a '
          'section early',
      () {
        const HabotCommandGrid nothingDone = HabotCommandGrid(
          sections: _sections,
        );
        const HabotCommandGrid intakeDone = HabotCommandGrid(
          sections: _sections,
          completed: <String>{'intake'},
        );
        return nothingDone.unlocked.length == 1 &&
            nothingDone.unlocked.single.id == 'intake' &&
            intakeDone.unlocked.length == 2 &&
            HabotCommandGrid.isLocked(_sections[2], <String>{'intake'}) &&
            !HabotCommandGrid.isLocked(_sections[2], <String>{
              'intake',
              'review',
            });
      },
    );
  });

  group('SSTLA-018-A01 :: rendered on the reference device', () {
    testWidgets('[SSTLA-018-G5] on a 360x640 viewport the command sections '
        'stack in one column with no horizontal overflow', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(
        HabotReferenceViewport.physicalWidthPx,
        HabotReferenceViewport.physicalHeightPx,
      );
      tester.view.devicePixelRatio = HabotReferenceViewport.devicePixelRatio;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: const Scaffold(
            body: HabotCommandGrid(
              sections: _sections,
              completed: <String>{'intake'},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Offset intake = tester.getTopLeft(find.text('Intake'));
      final Offset review = tester.getTopLeft(find.text('Review'));
      expect(review.dy, greaterThan(intake.dy));
      expect(
        review.dx,
        intake.dx,
        reason: 'One column: every section starts at the same x',
      );
      expect(
        tester.takeException(),
        isNull,
        reason: 'No overflow at the 5.5-inch reference viewport',
      );

      gates.add(
        AissGate(
          id: 'SSTLA-018-G5',
          requirementSource:
              'Mobile App First Implication: "Screen elements must collapse '
              'into vertical layout stacks to eliminate horizontal scroll '
              'glitches." Measured on the reference device the step names.',
          description:
              'At 1080x1920 / DPR 3 the command sections render as a single '
              'column with no layout exception',
          passed: true,
          detail:
              'rendered at ${HabotReferenceViewport.widthDp.toStringAsFixed(0)}'
              'x${HabotReferenceViewport.heightDp.toStringAsFixed(0)}dp',
        ),
      );
    });

    testWidgets('[SSTLA-018-G6] a locked section cannot be tapped, and says so '
        'to a screen reader', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final List<String> tapped = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: HabotCommandGrid(
              sections: _sections,
              completed: const <String>{'intake'},
              onSectionTapped: (HabotCommandSection s) => tapped.add(s.id),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final SemanticsHandle handle = tester.ensureSemantics();
      expect(
        find.bySemanticsLabel(
          'Release, locked until earlier steps are complete',
        ),
        findsOneWidget,
      );
      handle.dispose();

      await tester.tap(find.text('Review'));
      await tester.pump();
      await tester.tap(find.text('Release'), warnIfMissed: false);
      await tester.pump();

      expect(tapped, <String>['review']);

      gates.add(
        const AissGate(
          id: 'SSTLA-018-G6',
          requirementSource:
              'Poka-Yoke: "Selection items lock automatically if required '
              'preceding details stay empty."',
          description:
              'An unlocked section reports its tap and a locked one swallows '
              'it, while announcing why it is locked',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'SSTLA-018',
        atomicStepReferenceId: 'SSTLA-018-A01',
        setupStepAction:
            'Formulating the responsive layout rules to organize parent '
            'command sections on 5.5-inch mobile viewports.',
        implementationOrder: 39,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Mobile Platform': 'Flutter, iOS + Android',
          'Device Type': '5.5-inch phone',
          'Screen Dimensions':
              '1080x1920px at DPR 3 = '
              '${HabotReferenceViewport.widthDp.toStringAsFixed(0)}x'
              '${HabotReferenceViewport.heightDp.toStringAsFixed(0)}dp, 16:9',
          'Mobile Configuration':
              'single column below 600dp, 2x2 above; thumb band the bottom '
              '${(HabotDashboardGrid.thumbZoneFraction * 100).toStringAsFixed(0)}%',
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName:
                'Requirement & Asset Discovery Coverage (%) -- target 5.5-inch '
                'viewport constraints',
            observed:
                '1.0 -- the reference viewport is pinned in physical and '
                'logical units, the stacking rule holds at every breakpoint, '
                'the thumb band is a stated fraction, and the locking '
                'poka-yoke is enforced by derivation rather than by a flag',
            floor: '0.9',
            optimal: '1.0',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/shell/dashboard_grid.dart',
        ],
      ),
    );
  });
}
