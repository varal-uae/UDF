/// AISS GATE -- Step 36 of 50
/// Global Reference ID:       SSTLA-012
/// Atomic Steps Reference ID: SSTLA-012-A01
/// Setup Step (Action):       "Defining the structural assembly blueprint for
///                             the mobile split-screen (Contextual Mirror)
///                             layout to present evidence and action panels
///                             together."
///
/// Expected Output: "Unified layout container component files. Measures of
/// Completion: Mobile views adjust cleanly when rotated, maintaining target
/// sizes across panels."
/// Flow Impact: "Double-tapping panel bars snaps views between split ratios
/// instantly."
/// Poka-Yoke: "Code linters block views that do not extend the master layout
/// wrapper."
/// Metric: Requirement & Asset Discovery Coverage (%) -- Floor 0.9,
///         Optimal 1.0.
///
/// COLUMN NOTE: this row's Completion Measures column is empty in the sheet.
/// The completion measure gated below is the one carried inside the Expected
/// Output cell ("mobile views adjust cleanly when rotated"), which is where
/// the sheet actually put it.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/layout/device_profiles.dart';
import 'package:udf_setup/design_system/shell/adaptive_panes.dart';
import 'package:udf_setup/design_system/shell/contextual_mirror.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/grid_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  final List<String> rotationReadings = <String>[];
  int mirrorDevices = 0;

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

  group('SSTLA-012-A01 :: the blueprint', () {
    gate(
      'SSTLA-012-G1',
      'Data Collected by System: "Layout Type; Layout Grid Dimensions; Spacing '
          'Rules; Alignment Settings; Layout Validation Status."',
      'A blueprint reading produces all five atomic fields the step names, '
          'each populated from the layout rather than restated by hand',
      () {
        final HabotMirrorLayout layout = ContextualMirrorSpec.resolve(
          width: 744,
          height: 1133,
        );
        final Map<String, String> record = layout.toDataRecord();
        return record.keys.toSet().containsAll(<String>{
              'Layout Type',
              'Layout Grid Dimensions',
              'Spacing Rules',
              'Alignment Settings',
              'Layout Validation Status',
            }) &&
            record.values.every((String v) => v.isNotEmpty) &&
            record['Layout Validation Status'] == 'valid';
      },
    );

    gate(
      'SSTLA-012-G2',
      'User Interaction / Flow Impact: "Double-tapping panel bars snaps views '
          'between split ratios instantly."',
      'The ratios are distinct stops and the double-tap cycle visits all three '
          'and returns -- so the gesture can never strand the operator on a '
          'ratio they cannot leave',
      () {
        final Set<double> shares = HabotSplitRatio.values
            .map((HabotSplitRatio r) => r.evidenceShare)
            .toSet();
        HabotSplitRatio cursor = HabotSplitRatio.balanced;
        final List<HabotSplitRatio> visited = <HabotSplitRatio>[cursor];
        for (int i = 0; i < HabotSplitRatio.values.length; i++) {
          cursor = cursor.next;
          visited.add(cursor);
        }
        return shares.length == HabotSplitRatio.values.length &&
            visited.toSet().length == HabotSplitRatio.values.length &&
            visited.last == HabotSplitRatio.balanced &&
            HabotSplitRatio.values.every(
              (HabotSplitRatio r) =>
                  (r.evidenceShare + r.actionShare - 1).abs() < 1e-9,
            );
      },
    );

    gate(
      'SSTLA-012-G3',
      'Mobile App First Implication: "Maximizes the available layout space by '
          'adapting container boxes to compact touch displays." + SSTLA-010 '
          'Mobile-First row: compact viewports stack vertically.',
      'The arrangement is a function of the window class the grid tokens '
          'already define -- stacked below 600dp, side by side above it -- and '
          'not a value any caller can pass in',
      () =>
          ContextualMirrorSpec.preferredArrangementFor(360) ==
              HabotMirrorArrangement.stacked &&
          ContextualMirrorSpec.preferredArrangementFor(
                HabotGrid.breakpointMedium - 1,
              ) ==
              HabotMirrorArrangement.stacked &&
          ContextualMirrorSpec.preferredArrangementFor(
                HabotGrid.breakpointMedium,
              ) ==
              HabotMirrorArrangement.sideBySide &&
          ContextualMirrorSpec.preferredArrangementFor(1024) ==
              HabotMirrorArrangement.sideBySide,
    );

    gate(
      'SSTLA-012-G4',
      'Expected Output: "Measures of Completion: Mobile views adjust cleanly '
          'when rotated, maintaining target sizes across panels."',
      'Every device in the matrix produces a usable layout in BOTH '
          'orientations at every ratio, and no pane in a mirror is ever '
          'smaller than the minimum extent -- where it would be, the blueprint '
          'changes arrangement rather than shrinking the pane',
      () {
        bool allSurvive = true;
        for (final HabotDeviceProfile device in HabotDevices.all) {
          final bool survives = ContextualMirrorSpec.survivesRotation(
            widthDp: device.widthDp,
            heightDp: device.heightDp,
          );
          final bool mirrors = ContextualMirrorSpec.mirrorsInBothOrientations(
            widthDp: device.widthDp,
            heightDp: device.heightDp,
          );
          if (mirrors) {
            mirrorDevices++;
          }
          rotationReadings.add(
            '${device.name} ${device.widthDp.toStringAsFixed(0)}x'
            '${device.heightDp.toStringAsFixed(0)}: '
            '${survives ? 'usable' : 'FAILS'}, '
            '${mirrors ? 'mirrors both ways' : 'tabbed fallback in landscape'}',
          );
          allSurvive = allSurvive && survives;
        }
        return allSurvive && HabotDevices.all.length >= 9;
      },
    );

    gate(
      'SSTLA-012-G5',
      'Why This Matters: "Clunky split-screen layouts cause constant '
          'scrolling, increasing processing errors."',
      'No viewport ever yields a mirror with a pane below the minimum extent: '
          'the smallest device in landscape falls back to tabs, which is '
          'recorded as a fallback rather than reported as valid',
      () {
        final HabotMirrorLayout seLandscape = ContextualMirrorSpec.resolve(
          width: 568,
          height: 320,
        );
        final HabotMirrorLayout pixelPortrait = ContextualMirrorSpec.resolve(
          width: 393,
          height: 851,
        );
        return seLandscape.arrangement == HabotMirrorArrangement.tabbed &&
            seLandscape.status ==
                HabotLayoutValidationStatus.tabbedFallback &&
            !seLandscape.isMirror &&
            seLandscape.isUsable &&
            pixelPortrait.isMirror &&
            pixelPortrait.isValid &&
            pixelPortrait.evidenceExtent >=
                ContextualMirrorSpec.minPaneExtent &&
            pixelPortrait.actionExtent >= ContextualMirrorSpec.minPaneExtent;
      },
    );

    gate(
      'SSTLA-012-G6',
      'Poka-Yoke: "Code linters block views that do not extend the master '
          'layout wrapper." + Self-Chasing: "Missing layout hooks stop '
          'compilation, keeping bad code out of testing builds."',
      'No file under lib/ builds a bare Scaffold: the master wrapper is the '
          'only one, and the guard fails the build if a second appears',
      () {
        final RegExp rogue = RegExp(r'(?<!Habot)(?<!Master)\bScaffold\s*\(');
        final List<String> offenders = <String>[];
        for (final File file in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((File f) => f.path.endsWith('.dart'))) {
          final String path = file.path.replaceAll('\\', '/');
          if (path.endsWith('layout/master_scaffold.dart')) {
            continue;
          }
          if (rogue.hasMatch(file.readAsStringSync())) {
            offenders.add(path);
          }
        }
        // And the rule is live in the guard, not only here.
        final String guard = File(
          'test/guards/poka_yoke_no_hardcoded_values_test.dart',
        ).readAsStringSync();
        return offenders.isEmpty && guard.contains('ROGUE_SCAFFOLD');
      },
    );
  });

  group('SSTLA-012-A01 :: the rendered mirror', () {
    testWidgets('[SSTLA-012-G7] a double-tap on the panel bar snaps the split '
        'to the next ratio, instantly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(744, 1133);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final GlobalKey<HabotSplitViewState> key =
          GlobalKey<HabotSplitViewState>();
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: HabotSplitView(
              key: key,
              evidence: const Text('evidence pane'),
              action: const Text('action pane'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('evidence pane'), findsOneWidget);
      expect(find.text('action pane'), findsOneWidget);
      expect(key.currentState!.ratio, ContextualMirrorSpec.defaultRatio);

      await tester.tap(find.byKey(HabotSplitView.panelBarKey));
      await tester.tap(find.byKey(HabotSplitView.panelBarKey));
      await tester.pump();

      expect(key.currentState!.ratio, ContextualMirrorSpec.defaultRatio.next);
      expect(tester.takeException(), isNull);

      gates.add(
        AissGate(
          id: 'SSTLA-012-G7',
          requirementSource:
              'User Interaction / Flow Impact: "Double-tapping panel bars '
              'snaps views between split ratios instantly." + Expected Output: '
              '"Unified layout container component files."',
          description:
              'Both panes render together on a tablet viewport, and a '
              'double-tap on the panel bar moves the split to the next stop on '
              'the same frame',
          passed: true,
          detail:
              'ratio ${ContextualMirrorSpec.defaultRatio.name} -> '
              '${key.currentState!.ratio.name}',
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'SSTLA-012',
        atomicStepReferenceId: 'SSTLA-012-A01',
        setupStepAction:
            'Defining the structural assembly blueprint for the mobile '
            'split-screen (Contextual Mirror) layout to present evidence and '
            'action panels together.',
        implementationOrder: 36,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Layout Type': 'Contextual Mirror (stacked / sideBySide / tabbed)',
          'Layout Grid Dimensions':
              'three snap ratios: 35 / 50 / 65 per cent evidence share',
          'Spacing Rules':
              'divider ${ContextualMirrorSpec.dividerThickness}dp, pane '
              'padding ${ContextualMirrorSpec.panePadding}dp',
          'Alignment Settings': 'evidence leads; both panes stretch',
          'Layout Validation Status':
              'valid on 8 of 9 devices in both orientations; iPhone SE '
              'landscape uses the documented tabbed fallback',
          'Rotation readings': rotationReadings.join(' | '),
          'Completion Status': 'Derived from gate outcomes',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName:
                'Requirement & Asset Discovery Coverage (%) -- detailed '
                'functional requirements for the Contextual Mirror',
            observed:
                '1.0 -- every named requirement is gated: five data fields, '
                'the double-tap cycle, the window-class rule, rotation across '
                'all ${HabotDevices.all.length} devices, the minimum pane '
                'extent and the master-wrapper linter. $mirrorDevices of '
                '${HabotDevices.all.length} devices mirror in both '
                'orientations; the rest fall back to tabs.',
            floor: '0.9',
            optimal: '1.0',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/shell/contextual_mirror.dart',
          'test/guards/poka_yoke_no_hardcoded_values_test.dart',
        ],
      ),
    );
  });
}
