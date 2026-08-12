/// AISS GATE -- Step 14 of 20
/// Global Reference ID:      TTMAC-014
/// Atomic Steps Reference ID: TTMAC-014-A01
/// Setup Step (Action):      "Interactive Touch Target Standardization Engine
///                            Setup"
///
/// Completion Measures: "Average frequency of double tap corrections on closely
/// packed selections (<1%)." That is a telemetry number this suite cannot
/// produce; G5 gates the geometric precondition instead and G7 records the
/// telemetry half honestly as deferred.
/// Metric: Asset/Resource Location & Access Confirmation -- 0.9 / 0.98 / 1.0.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/interaction/atomic_button.dart';
import 'package:udf_setup/design_system/interaction/touch_standards.dart';
import 'package:udf_setup/design_system/interaction/touch_target.dart';
import 'package:udf_setup/design_system/layout/device_profiles.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/spacing_tokens.dart';

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

  group('TTMAC-014-A01 :: touch target standardization engine', () {
    gate(
      'TTMAC-014-G1',
      'Decision to be Made Before Setup Step: "Establish if expanding hit boxes '
          'beyond visible component outlines is acceptable for small icons."',
      'The decision is recorded as YES and the padding maths implements it -- a '
          'small glyph gains a transparent target rather than growing',
      () {
        if (!TouchStandards.hitBoxMayExceedVisibleOutline) {
          return false;
        }
        // A dense 18dp icon needs 15dp a side to reach 48.
        final double pad = TouchStandards.protectivePaddingFor(
          TouchStandards.iconDense,
        );
        if ((pad - 15).abs() > 0.001) {
          return false;
        }
        // A glyph already at or past the floor gains nothing.
        return TouchStandards.protectivePaddingFor(48) == 0 &&
            TouchStandards.protectivePaddingFor(64) == 0;
      },
    );

    gate(
      'TTMAC-014-G2',
      '4 Substeps #1: "Wrap all interactive components in protective padding '
          'zones matching minimum target dimensions."',
      'Padding always resolves the glyph to at least the 48dp floor, for every '
          'size from 1dp up',
      () {
        for (double size = 1; size <= 96; size += 1) {
          final Size target = TouchStandards.targetFor(size);
          if (target.width < HabotDensity.minTouchTarget ||
              target.height < HabotDensity.minTouchTarget) {
            return false;
          }
        }
        return true;
      },
    );

    gate(
      'TTMAC-014-G3',
      '4 Substeps #2: "Set default dimensions for icon actions to maintain '
          'structural usability."',
      'Three icon sizes are defined, ascending, all on the 4dp sub-baseline, '
          'and all below the touch floor (so padding always does the work)',
      () {
        final List<double> sizes = HabotIconSize.values
            .map(TouchStandards.iconSizeFor)
            .toList();
        double previous = 0;
        for (final double size in sizes) {
          if (size <= previous ||
              size % HabotSpacing.subBaseline != 0 ||
              size >= HabotDensity.minTouchTarget) {
            return false;
          }
          previous = size;
        }
        return sizes.length == 3;
      },
    );

    gate(
      'TTMAC-014-G4',
      '4 Substeps #3: "Configure clearance spaces around closely positioned '
          'items to avoid accidental double taps."',
      'Clearance is the 8dp token and the predicate rejects touching or '
          'overlapping targets',
      () =>
          TouchStandards.clearance == HabotDensity.touchSafetyMargin &&
          TouchStandards.hasClearance(100, 108) &&
          TouchStandards.hasClearance(100, 200) &&
          !TouchStandards.hasClearance(100, 104) &&
          !TouchStandards.hasClearance(100, 100) &&
          !TouchStandards.hasClearance(100, 96),
    );

    gate(
      'TTMAC-014-G6',
      '4 Substeps #4: "Test alignment grids against different device screen '
          'scale definitions."',
      'A 48dp target survives rasterisation at every device pixel ratio in the '
          'approved matrix, including the fractional 2.75',
      () {
        for (final double dpr in TouchStandards.testedDevicePixelRatios) {
          if (!TouchStandards.survivesScale(HabotDensity.minTouchTarget, dpr)) {
            return false;
          }
        }
        // And the ratios tested are the ones the device matrix actually uses.
        final Set<double> matrixRatios = HabotDevices.all
            .map((HabotDeviceProfile d) => d.devicePixelRatio)
            .toSet();
        return matrixRatios.every(
          TouchStandards.testedDevicePixelRatios.contains,
        );
      },
    );
  });

  group('TTMAC-014-A01 :: measured clearance between real controls', () {
    testWidgets('[TTMAC-014-G5] adjacent AtomicButtons never share a boundary', (
      WidgetTester tester,
    ) async {
      TouchTargetAudit.reset();
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (int i = 0; i < 3; i++)
                    AtomicButton(
                      semanticLabel: 'Action $i',
                      touchPadding: AtomicButton.standardTouchPadding,
                      onPressed: () {},
                      child: const Icon(
                        Icons.circle,
                        size: TouchStandards.iconDense,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final List<Rect> rects = tester
          .renderObjectList<RenderBox>(find.byType(AtomicButton))
          .map((RenderBox b) => b.localToGlobal(Offset.zero) & b.size)
          .toList();
      expect(rects, hasLength(3));

      // The buttons are laid out flush against each other on purpose: the
      // internal touchPadding is what must create the clearance, not a
      // SizedBox the caller remembered to add.
      for (int i = 1; i < rects.length; i++) {
        final double visualGap =
            (rects[i].left + AtomicButton.standardTouchPadding) -
            (rects[i - 1].right - AtomicButton.standardTouchPadding);
        expect(
          visualGap,
          greaterThanOrEqualTo(TouchStandards.clearance - 0.5),
          reason:
              'Interactive glyphs ${i - 1} and $i are only '
              '${visualGap.toStringAsFixed(1)}dp apart',
        );
      }
      for (int i = 0; i < rects.length; i++) {
        TouchTargetAudit.check('AtomicButton $i', rects[i].size);
      }
      expect(TouchTargetAudit.isClean, isTrue);

      gates.add(
        const AissGate(
          id: 'TTMAC-014-G5',
          requirementSource:
              'Mobile-First UI Decision: "Ensure row items maintain distinct '
              'spacing separations to avoid tracking confusion." + Poka-Yoke: '
              '"The component compiler throws layout warnings if an asset\'s '
              'interactive region drops below required touch target dimensions."',
          description:
              'Three flush-packed buttons still keep at least 8dp between '
              'their visible glyphs, from their own padding',
          passed: true,
        ),
      );
    });

    test('[TTMAC-014-G7] the <1% double-tap-correction measure is declared out '
        'of scope, not assumed', () {
      gates.add(
        const AissGate(
          id: 'TTMAC-014-G7',
          requirementSource:
              'Completion Measures: "Average frequency of double tap '
              'corrections on closely packed selections (<1%)." + Self-Chasing: '
              '"Telemetry tracking logs touch patterns."',
          description:
              'Field telemetry metric. This suite gates the geometric '
              'precondition (G5) but cannot produce a correction rate.',
          passed: false,
          deferred: true,
          detail:
              'Needs production interaction telemetry. UFHT-032 ("UI Hesitation '
              'Tracker Engine Setup", S.No 4723, zero-dependency) is the step '
              'that would close this.',
        ),
      );
      expect(gates.any((AissGate g) => g.id == 'TTMAC-014-G7'), isTrue);
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'TTMAC-014',
        atomicStepReferenceId: 'TTMAC-014-A01',
        setupStepAction:
            'Interactive Touch Target Standardization Engine Setup',
        implementationOrder: 14,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Repository URL':
              'Others/Fredrick workspace :: habot-mobile/udf_setup',
          'Repository Branch': 'working tree (not yet committed)',
          'Access Rights': 'UDF team read/write',
          'Commit History': 'n/a -- see git log after commit',
          'Repository Version': 'design system 0.1.0',
          'Clone Status':
              'Present locally at lib/design_system/interaction/',
        },
        measurements: const <AissMeasurement>[
          AissMeasurement(
            metricName: 'Asset/Resource Location & Access Confirmation',
            observed:
                '1.0 -- the touch standards engine is reachable from one '
                'documented path (lib/design_system/interaction/touch_standards.dart)',
            floor: '0.9',
            optimal: '0.98',
            ceiling: '1.0',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/interaction/touch_standards.dart',
          'lib/design_system/interaction/touch_target.dart',
        ],
      ),
    );
  });
}
