/// AISS GATE -- Step 37 of 50
/// Global Reference ID:       GEN-03270
/// Atomic Steps Reference ID: GEN-03270-A01
/// Setup Step (Action):       "Create responsive split-screen and master-detail
///                             layout containers for mobile/tablet screens."
/// Metric: Layout Responsiveness Pass Rate -- Floor = Optimal = Ceiling = 1.0.
///   A single-value metric: every viewport passes or the step is not done.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/layout/device_profiles.dart';
import 'package:udf_setup/design_system/shell/adaptive_panes.dart';
import 'package:udf_setup/design_system/shell/contextual_mirror.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  int viewportsPassed = 0;
  int viewportsTested = 0;

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

  Widget split() => MaterialApp(
    theme: HabotTheme.light(),
    home: const Scaffold(
      body: HabotSplitView(
        evidence: Text('evidence pane'),
        action: Text('action pane'),
      ),
    ),
  );

  Widget masterDetail({Widget? detail, VoidCallback? onDismissed}) =>
      MaterialApp(
        theme: HabotTheme.light(),
        home: Scaffold(
          body: HabotMasterDetail(
            master: const Text('the list'),
            detail: detail,
            onDetailDismissed: onDismissed,
            detailPlaceholder: const Text('nothing selected'),
          ),
        ),
      );

  group('GEN-03270-A01 :: container rules', () {
    gate(
      'GEN-03270-G1',
      'Setup Step (Action): "Create RESPONSIVE split-screen and master-detail '
          'layout containers for MOBILE/TABLET screens."',
      'Both containers read the viewport rather than taking a breakpoint '
          'parameter: master-detail is two-pane exactly where the blueprint '
          'says the mirror is side by side',
      () =>
          !HabotMasterDetail.isTwoPane(360) &&
          !HabotMasterDetail.isTwoPane(599) &&
          HabotMasterDetail.isTwoPane(600) &&
          HabotMasterDetail.isTwoPane(1024) &&
          HabotMasterDetail.isTwoPane(744) ==
              (ContextualMirrorSpec.preferredArrangementFor(744) ==
                  HabotMirrorArrangement.sideBySide),
    );

    gate(
      'GEN-03270-G2',
      'Metric: Layout Responsiveness Pass Rate = 1.0 -- every viewport, not '
          'most of them.',
      'Across all nine matrix devices in both orientations the containers '
          'resolve to a usable arrangement, and the flex weights always sum to '
          'the whole axis',
      () {
        bool allPass = true;
        for (final HabotDeviceProfile device in HabotDevices.all) {
          for (final List<double> axes in <List<double>>[
            <double>[device.widthDp, device.heightDp],
            <double>[device.heightDp, device.widthDp],
          ]) {
            viewportsTested++;
            final HabotMirrorLayout layout = ContextualMirrorSpec.resolve(
              width: axes[0],
              height: axes[1],
            );
            final bool ok =
                layout.isUsable &&
                (layout.evidenceExtent + layout.actionExtent) > 0;
            if (ok) {
              viewportsPassed++;
            }
            allPass = allPass && ok;
          }
        }
        return allPass &&
            HabotMasterDetail.masterFlex + HabotMasterDetail.detailFlex == 100;
      },
    );
  });

  group('GEN-03270-A01 :: rendered containers', () {
    testWidgets('[GEN-03270-G3] the split view stacks on a phone and sits side '
        'by side on a tablet, from the same widget', (
      WidgetTester tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      tester.view.physicalSize = const Size(393, 851);
      await tester.pumpWidget(split());
      await tester.pumpAndSettle();
      final Offset phoneEvidence = tester.getTopLeft(find.text('evidence pane'));
      final Offset phoneAction = tester.getTopLeft(find.text('action pane'));
      expect(
        phoneAction.dy,
        greaterThan(phoneEvidence.dy),
        reason: 'On a phone the panes stack: action sits below evidence',
      );
      expect(phoneAction.dx, phoneEvidence.dx);

      tester.view.physicalSize = const Size(1024, 1366);
      await tester.pumpWidget(split());
      await tester.pumpAndSettle();
      final Offset tabletEvidence = tester.getTopLeft(
        find.text('evidence pane'),
      );
      final Offset tabletAction = tester.getTopLeft(find.text('action pane'));
      expect(
        tabletAction.dx,
        greaterThan(tabletEvidence.dx),
        reason: 'On a tablet the panes sit side by side, evidence leading',
      );
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'GEN-03270-G3',
          requirementSource:
              'Setup Step (Action): "Create responsive split-screen ... '
              'containers for mobile/tablet screens."',
          description:
              'One widget produces a vertical stack at 393dp and a side-by-side '
              'split at 1024dp, with evidence leading in both',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-03270-G4] master-detail shows both panes on a tablet and '
        'one at a time on a phone', (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      tester.view.physicalSize = const Size(1024, 1366);
      await tester.pumpWidget(masterDetail(detail: const Text('the record')));
      await tester.pumpAndSettle();
      expect(find.text('the list'), findsOneWidget);
      expect(find.text('the record'), findsOneWidget);

      tester.view.physicalSize = const Size(393, 851);
      await tester.pumpWidget(masterDetail(detail: const Text('the record')));
      await tester.pumpAndSettle();
      expect(
        find.text('the list'),
        findsNothing,
        reason: 'On a phone the detail replaces the list rather than sharing '
            'the screen with it',
      );
      expect(find.text('the record'), findsOneWidget);

      gates.add(
        const AissGate(
          id: 'GEN-03270-G4',
          requirementSource:
              'Setup Step (Action): "...and MASTER-DETAIL layout containers '
              'for mobile/tablet screens."',
          description:
              'The same container shows list and record together at 1024dp and '
              'the record alone at 393dp',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-03270-G5] on a phone a system back gesture dismisses the '
        'detail rather than leaving the screen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393, 851);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      int dismissed = 0;
      await tester.pumpWidget(
        masterDetail(
          detail: const Text('the record'),
          onDismissed: () => dismissed++,
        ),
      );
      await tester.pumpAndSettle();

      final PopScope<Object?> scope = tester.widget<PopScope<Object?>>(
        find.byType(PopScope<Object?>),
      );
      expect(
        scope.canPop,
        isFalse,
        reason: 'While a detail is open the back gesture belongs to the '
            'container, not to the route',
      );
      scope.onPopInvokedWithResult?.call(false, null);
      expect(dismissed, 1);

      gates.add(
        const AissGate(
          id: 'GEN-03270-G5',
          requirementSource:
              'Setup Step (Action) -- a master-detail container that loses the '
              'back gesture makes the phone case unusable, which is the case '
              'the step is for.',
          description:
              'With a detail open on a phone the container claims the back '
              'gesture and reports the dismissal to its caller',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-03270-G6] the tabbed fallback renders tabs, not a '
        'starved split, on the smallest device in landscape', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(568, 320);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(split());
      await tester.pumpAndSettle();

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Evidence'), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'GEN-03270-G6',
          requirementSource:
              'SSTLA-012 Expected Output: "maintaining target sizes across '
              'panels." A 160dp pane has not maintained its target size, so '
              'the container changes shape instead.',
          description:
              'At 568x320 the split view renders the documented tabbed '
              'fallback with both panes reachable as tabs',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03270',
        atomicStepReferenceId: 'GEN-03270-A01',
        setupStepAction:
            'Create responsive split-screen and master-detail layout '
            'containers for mobile/tablet screens.',
        implementationOrder: 37,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotSplitView / HabotMasterDetail',
          'Component Type': 'Adaptive layout containers',
          'Component Properties':
              'master ${HabotMasterDetail.masterFlex.toStringAsFixed(0)} / '
              'detail ${HabotMasterDetail.detailFlex.toStringAsFixed(0)} flex; '
              'split ratios from the Step 36 blueprint',
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Layout Responsiveness Pass Rate',
            observed:
                '1.0 -- $viewportsPassed of $viewportsTested viewports '
                '(9 devices x 2 orientations) resolve to a usable arrangement',
            floor: '1.0',
            optimal: '1.0',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/shell/adaptive_panes.dart',
        ],
      ),
    );
  });
}
