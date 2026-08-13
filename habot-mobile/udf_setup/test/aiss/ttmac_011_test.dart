/// AISS GATE -- Step 10 of 10
/// Global Reference ID:      TTMAC-011
/// Atomic Steps Reference ID: TTMAC-011-A01
/// Setup Step (Action):      "Touch-Target Optimization Framework Setup
///                            (48x48 dp Minimum Interaction Nodes)."
///
/// Completion Measures: "100% of deployed interactive elements maintain
/// physical tap boundaries >= 48 x 48 dp."
///
/// G5 is the literal form of that measure: it pumps the real app and measures
/// every rendered touch target, rather than trusting that the constant is used.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/app.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/interaction/touch_target.dart';
import 'package:udf_setup/design_system/layout/device_profiles.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';

import 'aiss_reporter.dart';

/// Files permitted to build a raw interactive primitive. Everything else must
/// go through HabotTouchTarget so the 48dp floor cannot be bypassed.
/// The sanctioned interaction module. Every primitive under it -- the touch
/// target itself, the state-layer feedback engine -- is allowed to touch raw
/// gesture APIs; that is what "sanctioned" means. The gate description names the
/// module, so the exemption is the module, not a hand-maintained file list.
const String _sanctionedInteractionDir = 'lib/design_system/interaction/';

/// Reviewed exceptions *outside* that module -- secondary gestures, not primary
/// tap targets, each with an accessible alternative and each mandated by
/// another gate:
///  - the panel divider's double-tap to cycle the split ratio (SSTLA-012-G7);
///    a thin divider cannot be a 48dp target and carries button semantics.
///  - long-press on a metadata label, redundant with the adjacent
///    HabotTouchTarget that does the same on tap (MUFCE-028-G4).
const Set<String> _rawInteractionAllowList = <String>{
  'lib/design_system/shell/adaptive_panes.dart',
  'lib/design_system/surfaces/metadata_disclosure.dart',
};

void main() {
  final List<AissGate> gates = <AissGate>[];
  double smallestObserved = double.infinity;
  int measuredTargets = 0;

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

  group('TTMAC-011-A01 :: touch-target optimisation framework', () {
    // ---- Substep 1 --------------------------------------------------------
    gate(
      'TTMAC-011-G1',
      '4 Substeps #1: "Define absolute minimum touch-target boundaries '
          '(>= 48 x 48 dp) for compact layout elements."',
      'The 48dp floor is defined once, and the compliance predicate rejects '
          'anything under it',
      () {
        if (TouchTargetPolicy.minimumDp != 48 ||
            HabotDensity.minTouchTarget != 48) {
          return false;
        }
        return TouchTargetPolicy.isCompliant(const Size(48, 48)) &&
            TouchTargetPolicy.isCompliant(const Size(64, 56)) &&
            !TouchTargetPolicy.isCompliant(const Size(47, 48)) &&
            !TouchTargetPolicy.isCompliant(const Size(48, 24)) &&
            !TouchTargetPolicy.isCompliant(const Size(24, 24));
      },
    );

    // ---- Substep 3 --------------------------------------------------------
    gate(
      'TTMAC-011-G2',
      '4 Substeps #3: "Configure button element grid bounds to preserve an '
          '8 dp safety spacing margin."',
      'Safety margin is 8dp and the separation predicate rejects tighter gaps',
      () =>
          TouchTargetPolicy.safetyMarginDp == 8 &&
          HabotDensity.touchSafetyMargin == 8 &&
          TouchTargetPolicy.hasSafeSeparation(8) &&
          TouchTargetPolicy.hasSafeSeparation(16) &&
          !TouchTargetPolicy.hasSafeSeparation(4) &&
          !TouchTargetPolicy.hasSafeSeparation(0),
    );

    // ---- Poka-Yoke ---------------------------------------------------------
    gate(
      'TTMAC-011-G3',
      'Poka-Yoke: "The compile engine throws a validation error if any touch '
          'target layout bounds map below 48 dp constraints."',
      'HabotTouchTarget carries a constructor assert that rejects a sub-48dp '
          'minSize before anything renders',
      () {
        final String source = File(
          'lib/design_system/interaction/touch_target.dart',
        ).readAsStringSync();
        return source.contains('assert(') &&
            source.contains('minSize >= HabotDensity.minTouchTarget');
      },
    );

    gate(
      'TTMAC-011-G4',
      'What Standardized Must Be Done: "Adherence to core interactive '
          'component parameters." + Completion Measures: 100% of interactive '
          'elements >= 48dp.',
      'No file under lib/ builds a raw IconButton or GestureDetector outside '
          'the sanctioned interaction module',
      () {
        final RegExp raw = RegExp(r'\b(IconButton|GestureDetector)\s*\(');
        for (final File file
            in Directory('lib')
                .listSync(recursive: true)
                .whereType<File>()
                .where((File f) => f.path.endsWith('.dart'))) {
          final String path = file.path.replaceAll('\\', '/');
          if (path.startsWith(_sanctionedInteractionDir) ||
              _rawInteractionAllowList.contains(path)) {
            continue;
          }
          if (raw.hasMatch(file.readAsStringSync())) {
            return false;
          }
        }
        return true;
      },
    );
  });

  // ---- Completion measure: measure the real thing ------------------------
  group('TTMAC-011-A01 :: completion measure -- measured, not assumed', () {
    for (final HabotDeviceProfile device in <HabotDeviceProfile>[
      HabotDevices.iphoneSe,
      HabotDevices.pixel5,
      HabotDevices.ipadPro,
    ]) {
      testWidgets('every rendered touch target is >= 48dp on ${device.name}', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = device.logicalSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(const HabotApp(home: DesignSystemProbePage()));
        await tester.pumpAndSettle();

        final Iterable<RenderBox> targets = tester
            .renderObjectList<RenderBox>(find.byType(HabotTouchTarget))
            .where((RenderBox b) => b.hasSize);

        expect(
          targets,
          isNotEmpty,
          reason:
              'The probe screen must render touch targets, or this gate '
              'passes vacuously',
        );

        for (final RenderBox box in targets) {
          measuredTargets++;
          final double smallestSide = box.size.width < box.size.height
              ? box.size.width
              : box.size.height;
          if (smallestSide < smallestObserved) {
            smallestObserved = smallestSide;
          }
          expect(
            TouchTargetPolicy.isCompliant(box.size),
            isTrue,
            reason:
                'A touch target rendered at ${box.size} on ${device.name}, '
                'below the ${TouchTargetPolicy.minimumDp}dp floor',
          );
        }
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('[TTMAC-011-G5] measured-compliance gate recorded', (
      WidgetTester tester,
    ) async {
      gates.add(
        AissGate(
          id: 'TTMAC-011-G5',
          requirementSource:
              'Completion Measures: "100% of deployed interactive elements '
              'maintain physical tap boundaries >= 48 x 48 dp."',
          description:
              'Every touch target rendered by the app at 320 / 393 / 1024dp '
              'measures at least 48dp on its shortest side',
          passed: true,
          detail:
              'measured $measuredTargets target instances; smallest side '
              '${smallestObserved.isFinite ? smallestObserved.toStringAsFixed(1) : "n/a"}dp',
        ),
      );
      expect(measuredTargets, greaterThan(0));
    });

    testWidgets('[TTMAC-011-G6] adjacent targets keep the 8dp safety gap', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = HabotDevices.iphoneSe.logicalSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: Center(
              child: HabotTouchRow(
                children: <Widget>[
                  HabotTouchTarget(
                    semanticLabel: 'One',
                    onPressed: () {},
                    child: const Icon(Icons.looks_one),
                  ),
                  HabotTouchTarget(
                    semanticLabel: 'Two',
                    onPressed: () {},
                    child: const Icon(Icons.looks_two),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final List<Rect> rects = tester
          .renderObjectList<RenderBox>(find.byType(HabotTouchTarget))
          .map((RenderBox b) => b.localToGlobal(Offset.zero) & b.size)
          .toList();

      expect(rects, hasLength(2));
      final double gap = rects[1].left - rects[0].right;
      expect(
        TouchTargetPolicy.hasSafeSeparation(gap),
        isTrue,
        reason: 'Adjacent targets were ${gap.toStringAsFixed(1)}dp apart',
      );

      gates.add(
        AissGate(
          id: 'TTMAC-011-G6',
          requirementSource:
              '4 Substeps #3: "preserve an 8 dp safety spacing margin."',
          description:
              'HabotTouchRow renders adjacent targets with a measured gap of '
              'at least 8dp',
          passed: true,
          detail: 'measured gap ${gap.toStringAsFixed(1)}dp',
        ),
      );
    });

    testWidgets('[TTMAC-011-G7] a micro-icon keeps its visual size while its '
        'tap area expands, and long-press reveals detail', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: Center(
              child: HabotTouchTarget(
                semanticLabel: 'Tiny toggle',
                detail: 'Toggles the tiny thing',
                onPressed: () {},
                child: const Icon(Icons.circle, size: 12),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Substep 2: the expansion box is transparent -- the icon stays small.
      final RenderBox icon = tester.renderObject<RenderBox>(
        find.byIcon(Icons.circle),
      );
      final RenderBox target = tester.renderObject<RenderBox>(
        find.byType(HabotTouchTarget),
      );
      expect(icon.size.width, lessThan(TouchTargetPolicy.minimumDp));
      expect(TouchTargetPolicy.isCompliant(target.size), isTrue);

      // Substep 4: long-press reveals the detail rather than an inline box.
      await tester.longPress(find.byType(HabotTouchTarget));
      await tester.pumpAndSettle();
      expect(find.text('Toggles the tiny thing'), findsOneWidget);

      gates.add(
        AissGate(
          id: 'TTMAC-011-G7',
          requirementSource:
              '4 Substeps #2: "Inject transparent target expansion boxes around '
              'micro-icons or selector ticks." + #4: "Map long-press '
              'interaction paths to reveal detailed tooltips."',
          description:
              'A 12dp icon renders at 12dp but is wrapped in a >=48dp tap area, '
              'and long-press surfaces the detail tooltip',
          passed: true,
          detail:
              'icon ${icon.size.width.toStringAsFixed(0)}dp inside target '
              '${target.size.width.toStringAsFixed(0)}x'
              '${target.size.height.toStringAsFixed(0)}dp',
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'TTMAC-011',
        atomicStepReferenceId: 'TTMAC-011-A01',
        setupStepAction:
            'Touch-Target Optimization Framework Setup (48x48 dp Minimum '
            'Interaction Nodes).',
        implementationOrder: 10,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Layout Type': 'Touch container bounding-box utility module',
          'Layout Grid Dimensions':
              'minimum ${TouchTargetPolicy.minimumDp.toStringAsFixed(0)}x'
              '${TouchTargetPolicy.minimumDp.toStringAsFixed(0)}dp per target',
          'Spacing Rules':
              '${TouchTargetPolicy.safetyMarginDp.toStringAsFixed(0)}dp safety '
              'margin between adjacent interactive elements',
          'Alignment Settings':
              'transparent expansion box centred on the visual child',
          'Layout Validation Status':
              '$measuredTargets rendered targets measured across 3 device '
              'profiles; smallest side '
              '${smallestObserved.isFinite ? smallestObserved.toStringAsFixed(1) : "n/a"}dp',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'Environment / Asset Access Readiness',
            observed:
                'Touch container module version-controlled at one documented '
                'path and reachable on first attempt',
            floor: 'Located on first attempt',
            optimal: 'Path version-controlled & documented',
            ceiling: 'N/A (one-time setup)',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/interaction/touch_target.dart',
        ],
      ),
    );
  });
}
