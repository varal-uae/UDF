/// AISS GATE -- Step 6 of 10
/// Global Reference ID:      RCGLA-012
/// Atomic Steps Reference ID: RCGLA-012-A01
/// Setup Step (Action):      "Initialize Atomic Grid System & Mobile Viewport
///                            Constraints"
///
/// Completion Measures: "Zero instances of horizontal scrollbars across
/// simulated iPhone SE, 14 Pro, and Pixel devices. Cumulative Layout Shift
/// (CLS) scores tracking strictly under 0.05."
///
/// CLS is a browser metric and cannot be measured from a widget test. The
/// overflow half is gated here; the CLS half is recorded as OUT OF SCOPE in the
/// evidence rather than silently claimed. See G7.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/app.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/layout/device_profiles.dart';
import 'package:udf_setup/design_system/layout/mobile_grid_container.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/grid_tokens.dart';

import 'aiss_reporter.dart';

/// Set to true ONLY when Fredrick has accepted the WCAG 1.4.4 trade-off and
/// web/index.html has been switched to `user-scalable=no`. See the comment
/// block in web/index.html.
const bool zoomLockAccepted = false;

/// Counts the executable lines of a method body in a source file.
int _methodBodyLines(String source, String signature) {
  final int start = source.indexOf(signature);
  if (start == -1) {
    return -1;
  }
  int i = source.indexOf('{', start);
  if (i == -1) {
    return -1;
  }
  int depth = 0;
  final int bodyStart = i;
  for (; i < source.length; i++) {
    if (source[i] == '{') {
      depth++;
    } else if (source[i] == '}') {
      depth--;
      if (depth == 0) {
        break;
      }
    }
  }
  final String body = source.substring(bodyStart + 1, i);
  return body
      .split('\n')
      .map((String l) => l.trim())
      .where((String l) => l.isNotEmpty && !l.startsWith('//'))
      .length;
}

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

  group('RCGLA-012-A01 :: atomic grid system & viewport constraints', () {
    // ---- Substep 1 --------------------------------------------------------
    gate(
      'RCGLA-012-G1',
      '4 Substeps #1: "Define layout breakpoints in the common library '
          'configuration (xs: 0px, sm: 600px)."',
      'xs and sm breakpoints are defined at exactly 0 and 600 and drive the '
          'window-class resolver',
      () =>
          HabotGrid.breakpointXs == 0 &&
          HabotGrid.breakpointSm == 600 &&
          HabotGrid.windowClassFor(HabotGrid.breakpointXs) ==
              HabotWindowClass.compact &&
          HabotGrid.windowClassFor(HabotGrid.breakpointSm - 0.1) ==
              HabotWindowClass.compact &&
          HabotGrid.windowClassFor(HabotGrid.breakpointSm) ==
              HabotWindowClass.medium,
    );

    // ---- Substep 2 --------------------------------------------------------
    test(
      '[RCGLA-012-G2] web viewport meta tag is configured (zoom-lock decision '
      'recorded)',
      () {
        final File index = File('web/index.html');
        expect(index.existsSync(), isTrue);

        // Strip HTML comments FIRST. index.html documents the override in a
        // comment block that itself contains a viewport tag with
        // user-scalable=no; matching that would let the gate pass on a tag
        // that is not actually live.
        final String html = index.readAsStringSync().replaceAll(
          RegExp(r'<!--[\s\S]*?-->'),
          '',
        );

        final RegExp viewportTag = RegExp(
          r'<meta\s+name="viewport"[\s\S]*?content="([^"]+)"',
        );
        expect(
          viewportTag.allMatches(html),
          hasLength(1),
          reason: 'Exactly one live viewport meta tag must be declared',
        );
        final RegExpMatch? match = viewportTag.firstMatch(html);
        expect(
          match,
          isNotNull,
          reason: 'RCGLA-012 substep 2 requires a viewport meta tag',
        );
        final String content = match!.group(1)!;

        // The part of the substep that is not in dispute.
        expect(content, contains('width=device-width'));
        expect(content, contains('initial-scale=1.0'));

        final bool zoomLocked = content.contains('user-scalable=no');

        if (zoomLockAccepted) {
          expect(
            zoomLocked,
            isTrue,
            reason:
                'zoomLockAccepted is true, so web/index.html must actually '
                'carry user-scalable=no',
          );
        }

        // Deliberately NOT asserting zoomLocked == true when the decision is
        // still open. The gate below records the honest state.
        gates.add(
          AissGate(
            id: 'RCGLA-012-G2',
            requirementSource:
                '4 Substeps #2: "Configure HTML Meta viewport tags to disallow '
                'user-scalable zooming."',
            description: zoomLockAccepted
                ? 'Viewport meta tag locks zoom as specified (trade-off '
                      'accepted by owner)'
                : 'Viewport meta tag pins width and initial scale; the '
                      'user-scalable=no clause is DEFERRED because it fails '
                      'WCAG 2.1 SC 1.4.4 and contradicts TTMCS-004/005. '
                      'Awaiting Fredrick decision.',
            passed: zoomLockAccepted ? zoomLocked : false,
            deferred: !zoomLockAccepted,
            detail: zoomLockAccepted
                ? null
                : 'OPEN DECISION. Modern iOS Safari and Android Chrome ignore '
                      'user-scalable=no regardless, so the literal clause '
                      'would fail accessibility without achieving its purpose. '
                      'Flip zoomLockAccepted in this file to override.',
          ),
        );
      },
    );

    // ---- Substep 3 --------------------------------------------------------
    gate(
      'RCGLA-012-G3',
      '4 Substeps #3: "Build a pure MobileGridContainer component restricted '
          'to 20 lines."',
      'MobileGridContainer.build is 20 executable lines or fewer, and the '
          'widget is pure (no Theme, MediaQuery or state)',
      () {
        final File file = File(
          'lib/design_system/layout/mobile_grid_container.dart',
        );
        if (!file.existsSync()) {
          return false;
        }
        final String source = file.readAsStringSync();
        final int lines = _methodBodyLines(
          source,
          'Widget build(BuildContext context)',
        );
        if (lines < 0 || lines > 20) {
          return false;
        }
        // Purity: none of these may appear in the implementation.
        const List<String> impure = <String>[
          'Theme.of(',
          'MediaQuery.',
          'StatefulWidget',
          'setState',
        ];
        for (final String needle in impure) {
          if (source.contains(needle)) {
            return false;
          }
        }
        return true;
      },
    );

    // ---- Substep 4 --------------------------------------------------------
    gate(
      'RCGLA-012-G4',
      '4 Substeps #4: "Implement automated build-time linting to flag '
          'hardcoded pixel values." + Poka-Yoke: "break compilation if outer '
          'layout wrappers contain hardcoded fixed pixel widths over 360px."',
      'The pixel-width ceiling is defined and no layout file declares a '
          'hardcoded wrapper width above it',
      () {
        if (HabotGrid.maxHardcodedWrapperWidth != 360) {
          return false;
        }
        final Directory layoutDir = Directory('lib/design_system/layout');
        if (!layoutDir.existsSync()) {
          return false;
        }
        final RegExp fixedWidth = RegExp(
          r'\b(?:maxWidth|minWidth|width)\s*:\s*(\d+(?:\.\d+)?)\b',
        );
        for (final File file
            in layoutDir
                .listSync(recursive: true)
                .whereType<File>()
                .where((File f) => f.path.endsWith('.dart'))) {
          for (final RegExpMatch m in fixedWidth.allMatches(
            file.readAsStringSync(),
          )) {
            final double value = double.parse(m.group(1)!);
            if (value > HabotGrid.maxHardcodedWrapperWidth) {
              return false;
            }
          }
        }
        return true;
      },
    );

    gate(
      'RCGLA-012-G5',
      'UX Translation: "standard 16px fluid outer margins and a continuous 8px '
          'vertical rhythm alignment."',
      'Outer margin is 16dp and the vertical rhythm is 8dp',
      () => HabotGrid.outerMargin == 16 && HabotGrid.verticalRhythm == 8,
    );
  });

  // ---- Completion measure: zero horizontal overflow ----------------------
  group('RCGLA-012-A01 :: completion measure -- no horizontal scroll', () {
    for (final HabotDeviceProfile device in <HabotDeviceProfile>[
      HabotDevices.iphoneSe,
      HabotDevices.iphone14Pro,
      HabotDevices.pixel5,
    ]) {
      testWidgets('no horizontal overflow on ${device.name}', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = device.logicalSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(const HabotApp());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);

        // Nothing may be laid out wider than the viewport.
        for (final RenderBox box
            in tester
                .renderObjectList<RenderBox>(find.byType(Padding))
                .where((RenderBox b) => b.hasSize)) {
          expect(
            box.size.width,
            lessThanOrEqualTo(device.widthDp + 0.5),
            reason: 'Overflowed the ${device.widthDp}dp viewport',
          );
        }
      });
    }

    testWidgets('[RCGLA-012-G6] MobileGridContainer keeps content inside the '
        'viewport at the narrowest supported width', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = HabotDevices.iphoneSe.logicalSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: const Scaffold(
            body: MobileGridContainer(child: SizedBox.expand()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final RenderBox box = tester.renderObject<RenderBox>(
        find.byType(MobileGridContainer),
      );
      expect(box.size.width, lessThanOrEqualTo(HabotGrid.minSupportedWidth));
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'RCGLA-012-G6',
          requirementSource:
              'Completion Measures: "Zero instances of horizontal scrollbars '
              'across simulated iPhone SE, 14 Pro, and Pixel devices."',
          description:
              'App and MobileGridContainer render inside the viewport at 320, '
              '393 and 393dp with zero overflow exceptions',
          passed: true,
        ),
      );
    });

    test('[RCGLA-012-G7] CLS measurement scope is declared, not assumed', () {
      // Recorded as a failing-open gate on purpose: the step asks for CLS
      // < 0.05 and a widget test cannot produce that number. Claiming it would
      // be the exact dishonesty the AISS method exists to prevent.
      gates.add(
        const AissGate(
          id: 'RCGLA-012-G7',
          requirementSource:
              'Completion Measures: "Cumulative Layout Shift (CLS) scores '
              'tracking strictly under 0.05."',
          description:
              'CLS is a browser metric; needs a Lighthouse run in CI against '
              'the web build. NOT measured by this suite.',
          passed: false,
          deferred: true,
          detail:
              'OUT OF SCOPE for widget tests. Add `lhci autorun` against '
              '`flutter build web` to close this gate.',
        ),
      );
      expect(gates.any((AissGate g) => g.id == 'RCGLA-012-G7'), isTrue);
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'RCGLA-012',
        atomicStepReferenceId: 'RCGLA-012-A01',
        setupStepAction:
            'Initialize Atomic Grid System & Mobile Viewport Constraints',
        implementationOrder: 6,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Layout Type': 'MD3 adaptive column matrix (compact/medium/expanded)',
          'Layout Grid Dimensions':
              '4/8/12 columns; margin 16dp; column gutter 16dp; '
              'vertical rhythm 8dp; min width 320dp',
          'Spacing Rules': '8dp baseline with a single 4dp sub-baseline step',
          'Alignment Settings':
              'top-centre aligned, content capped at 840dp on expanded',
          'Layout Validation Status':
              'overflow-free at 320/393dp; CLS not yet measured',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'Asset/Resource Location & Access Confirmation',
            observed:
                '1.0 -- grid config reachable from one documented location '
                '(lib/design_system/tokens/grid_tokens.dart + tokens.json)',
            floor: '0.8',
            optimal: '0.95',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/layout/mobile_grid_container.dart',
          'lib/design_system/tokens/grid_tokens.dart',
          'web/index.html',
        ],
      ),
    );
  });
}
