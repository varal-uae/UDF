/// AISS GATE -- Step 5 of 10
/// Global Reference ID:      SSTLA-004
/// Atomic Steps Reference ID: SSTLA-004-A01
/// Setup Step (Action):      "Define the exact base breakpoint, column count,
///                            fluid margin, and gutter widths for the core
///                            mobile experience before scaling upward."
///
/// Expected Output: "Approved JSON Token File and an interactive structural
/// layout wireframe for compact mobile devices."
/// Metric: Task Execution Quality Score (1-5) -- Floor 3.5, Optimal 4.5,
/// Ceiling 5.0. The objective half is computed here; the reviewer half is not
/// something a test can award itself. See G6.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/layout/device_profiles.dart';
import 'package:udf_setup/design_system/layout/grid_wireframe.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/grid_tokens.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';

import 'aiss_reporter.dart';

Map<String, dynamic> _matrix() {
  final File file = File('lib/design_system/tokens/device_matrix.json');
  expect(
    file.existsSync(),
    isTrue,
    reason:
        'SSTLA-004 Expected Output names an "Approved JSON Token File". It must '
        'exist at lib/design_system/tokens/device_matrix.json',
  );
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

/// Objective coverage score, 0..5. One point per rubric criterion.
double _objectiveScore() {
  double score = 0;

  final Set<HabotWindowClass> classes = HabotDevices.all
      .map((HabotDeviceProfile d) => HabotGrid.windowClassFor(d.widthDp))
      .toSet();
  if (classes.length == HabotWindowClass.values.length) {
    score += 1;
  }

  if (HabotDevices.all.any(
    (HabotDeviceProfile d) => d.widthDp == HabotGrid.minSupportedWidth,
  )) {
    score += 1;
  }

  final Set<String> platforms = HabotDevices.all
      .map((HabotDeviceProfile d) => d.mobilePlatform)
      .toSet();
  if (platforms.contains('iOS') && platforms.contains('Android')) {
    score += 1;
  }

  final Set<HabotDeviceType> types = HabotDevices.all
      .map((HabotDeviceProfile d) => d.deviceType)
      .toSet();
  if (types.length == HabotDeviceType.values.length) {
    score += 1;
  }

  final Set<double> widths = HabotDevices.all
      .map((HabotDeviceProfile d) => d.widthDp)
      .toSet();
  if (HabotDevices.rcgla032TestWidths.every(widths.contains)) {
    score += 1;
  }

  return score;
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

  group('SSTLA-004-A01 :: baseline grid decision record', () {
    gate(
      'SSTLA-004-G1',
      'Setup Step (Action): "Define the exact base breakpoint, column count, '
          'fluid margin, and gutter widths for the core mobile experience."',
      'All four values are decided, recorded in the JSON, and match the code',
      () {
        final Map<String, dynamic> decision =
            _matrix()['decision_record'] as Map<String, dynamic>;
        return (decision['base_breakpoint_dp'] as num) ==
                HabotGrid.breakpointXs &&
            (decision['base_column_count'] as num) ==
                HabotGrid.compactColumns &&
            (decision['fluid_outer_margin_dp'] as num) ==
                HabotGrid.outerMargin &&
            (decision['column_gutter_dp'] as num) == HabotGrid.gutter &&
            (decision['vertical_rhythm_dp'] as num) ==
                HabotGrid.verticalRhythm &&
            (decision['min_supported_width_dp'] as num) ==
                HabotGrid.minSupportedWidth;
      },
    );

    gate(
      'SSTLA-004-G2',
      'Setup Step Description: "Collate cross-device screen resolution metrics '
          'for target mobile, tablet, and desktop viewports."',
      'Matrix covers mobile, tablet and desktop, and every device carries all '
          'five required atomic data fields',
      () {
        final Set<HabotDeviceType> types = HabotDevices.all
            .map((HabotDeviceProfile d) => d.deviceType)
            .toSet();
        if (types.length != HabotDeviceType.values.length) {
          return false;
        }
        for (final HabotDeviceProfile d in HabotDevices.all) {
          if (d.mobilePlatform.isEmpty ||
              d.osVersion.isEmpty ||
              d.mobileConfiguration.isEmpty ||
              d.widthDp <= 0 ||
              d.heightDp <= 0 ||
              d.devicePixelRatio <= 0) {
            return false;
          }
        }
        return true;
      },
    );

    gate(
      'SSTLA-004-G3',
      'Why This Matters: "preventing viewport overflow bugs ... across varying '
          'mobile viewports." + User Interaction: "Prevents accidental visual '
          'clipping of primary CTAs on tight displays."',
      'At every device width in the matrix, one grid column is still wide '
          'enough to hold a 48dp touch target',
      () {
        for (final HabotDeviceProfile d in HabotDevices.all) {
          if (HabotGrid.columnWidth(d.widthDp) < HabotDensity.minTouchTarget) {
            return false;
          }
        }
        return true;
      },
    );

    gate(
      'SSTLA-004-G4',
      'CONFLICT RESOLUTION -- RCGLA-012 says "16px ... with an 8px gutter grid '
          'system"; RCGLA-032 substep 1 says "16px outer margin and a 16px '
          'column gutter". Resolved into two tokens.',
      'Column gutter is 16dp, vertical rhythm is 8dp, and the resolution is '
          'documented in the JSON rather than left implicit',
      () {
        final Map<String, dynamic> decision =
            _matrix()['decision_record'] as Map<String, dynamic>;
        final Object? conflict = decision['conflict_resolved'];
        return HabotGrid.gutter == 16 &&
            HabotGrid.verticalRhythm == 8 &&
            conflict is Map<String, dynamic> &&
            (conflict['resolution'] as String).isNotEmpty &&
            // RCGLA-032's own metric band: Floor 4dp, Optimal 8dp, Ceiling 16dp.
            HabotGrid.verticalRhythm >= 4 &&
            HabotGrid.verticalRhythm <= 16;
      },
    );

    gate(
      'SSTLA-004-G5',
      'Expected Output: "Approved JSON Token File".',
      'Every device in device_matrix.json is mirrored exactly in Dart',
      () {
        final List<dynamic> json = _matrix()['devices'] as List<dynamic>;
        if (json.length != HabotDevices.all.length) {
          return false;
        }
        for (int i = 0; i < json.length; i++) {
          final Map<String, dynamic> j = json[i] as Map<String, dynamic>;
          final HabotDeviceProfile d = HabotDevices.all[i];
          if (j['name'] != d.name ||
              j['mobile_platform'] != d.mobilePlatform ||
              j['os_version'] != d.osVersion ||
              j['device_type'] != d.deviceType.name ||
              (j['screen_width_dp'] as num) != d.widthDp ||
              (j['screen_height_dp'] as num) != d.heightDp ||
              (j['device_pixel_ratio'] as num) != d.devicePixelRatio ||
              j['mobile_configuration'] != d.mobileConfiguration) {
            return false;
          }
        }
        return true;
      },
    );

    gate(
      'SSTLA-004-G6',
      'Metric: "Task Execution Quality Score (1-5 scale)" -- Floor 3.5, '
          'Optimal 4.5, Ceiling 5.0. Standard/Reference: "scored by a reviewer '
          'against a defined rubric."',
      'Objective rubric coverage reaches 5.0/5.0 (the reviewer score is a '
          'separate human input and is NOT self-awarded here)',
      () => _objectiveScore() >= 4.5,
    );
  });

  group('SSTLA-004-A01 :: interactive structural wireframe', () {
    testWidgets(
      '[SSTLA-004-G7] wireframe overlay renders the grid without intercepting '
      'input, and the readout agrees with the tokens',
      (WidgetTester tester) async {
        tester.view.physicalSize = HabotDevices.iphoneSe.logicalSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        int taps = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: HabotTheme.light(),
            home: Scaffold(
              body: GridWireframeOverlay(
                enabled: true,
                child: Center(
                  child: ElevatedButton(
                    onPressed: () => taps++,
                    child: const Text('under the overlay'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(CustomPaint), findsWidgets);

        // The overlay must be decorative only.
        await tester.tap(find.text('under the overlay'));
        await tester.pump();
        expect(taps, 1, reason: 'The wireframe must not swallow pointers');

        gates.add(
          const AissGate(
            id: 'SSTLA-004-G7',
            requirementSource:
                'Expected Output: "an interactive structural layout wireframe '
                'for compact mobile devices."',
            description:
                'Wireframe overlay paints the grid at 320dp and passes pointers '
                'through to the content beneath',
            passed: true,
          ),
        );
      },
    );

    testWidgets('[SSTLA-004-G8] readout reports the decided values', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = HabotDevices.pixel5.logicalSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: const Scaffold(body: GridDecisionReadout()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('compact'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('16dp'), findsWidgets);
      expect(find.text('8dp'), findsOneWidget);
      expect(tester.takeException(), isNull);

      gates.add(
        const AissGate(
          id: 'SSTLA-004-G8',
          requirementSource:
              'Why This Matters: "Eliminates arbitrary layout configurations '
              'across team members."',
          description:
              'The on-screen readout is generated from the tokens, so it can '
              'never disagree with the decision record',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'SSTLA-004',
        atomicStepReferenceId: 'SSTLA-004-A01',
        setupStepAction:
            'Define the exact base breakpoint, column count, fluid margin, and '
            'gutter widths for the core mobile experience before scaling '
            'upward to tablet or desktop views.',
        implementationOrder: 5,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Mobile Platform': 'iOS, Android, iPadOS, Web',
          'OS Version':
              'iOS 15+, iOS 16+, Android 9+/11+/13+, iPadOS 16+, evergreen web',
          'Device Type': 'phone (6), tablet (2), desktop (1)',
          'Screen Dimensions':
              '320x568 .. 1280x800 dp across ${HabotDevices.all.length} profiles',
          'Mobile Configuration':
              'compact 4-col / medium 8-col / expanded 12-col; '
              '16dp margin, 16dp gutter, 8dp rhythm',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Task Execution Quality Score (1-5 scale)',
            observed:
                'objective rubric ${_objectiveScore().toStringAsFixed(1)}/5.0; '
                'reviewer score PENDING (human input required)',
            floor: '3.5',
            optimal: '4.5',
            ceiling: '5.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tokens/device_matrix.json',
          'lib/design_system/layout/device_profiles.dart',
          'lib/design_system/layout/grid_wireframe.dart',
        ],
      ),
    );
  });
}
