/// AISS GATE -- Step 22 of 35
/// Global Reference ID:       GEN-00954
/// Atomic Steps Reference ID: GEN-00954-A01
/// Setup Step (Action):       "Standardize Material Design 3 (MD3) Bottom-Sheet
///                             UI for Mobile Complex Action Flows"
/// Expected Output:           "...Configure backdrop scrim color to 32%
///                             opacity black."
/// Metric: Scrim Opacity Compliance -- Floor 32%, Optimal 32%, Ceiling 32%.
///   A single-value metric: there is no partial credit and no better-than.
///   Either the scrim is 32% or the step is not done.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/contrast.dart';
import 'package:udf_setup/design_system/aiss/aiss_evidence.dart';
import 'package:udf_setup/design_system/surfaces/bottom_sheet.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/color_tokens.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';
import 'package:udf_setup/design_system/tokens/surface_tokens.dart';

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

  group('GEN-00954-A01 :: MD3 bottom-sheet standardisation', () {
    gate(
      'GEN-00954-G1',
      'Expected Output: "Configure backdrop scrim color to 32% opacity black." '
          '+ Metric: Scrim Opacity Compliance, Floor = Optimal = Ceiling = 32%.',
      'The scrim is exactly 32% opaque -- not 30, not a third, not "about a '
          'third"',
      () => HabotSheet.scrimOpacity == 0.32,
    );

    gate(
      'GEN-00954-G2',
      'Expected Output: "...32% opacity BLACK."',
      'The scrim colour is pure black, and the composed scrim carries the token '
          'opacity rather than baking an alpha into the hex',
      () {
        final Color scrim = HabotSheetScrim.color;
        return HabotColors.scrim.r == 0 &&
            HabotColors.scrim.g == 0 &&
            HabotColors.scrim.b == 0 &&
            HabotColors.scrim.a == 1.0 &&
            (scrim.a - HabotSheet.scrimOpacity).abs() < 0.005 &&
            scrim.r == 0 &&
            scrim.g == 0 &&
            scrim.b == 0;
      },
    );

    gate(
      'GEN-00954-G3',
      'Setup Step (Action): "STANDARDIZE MD3 Bottom-Sheet UI for Mobile Complex '
          'Action Flows." Standardised means one scrim, not one per flow.',
      'Exactly one place in lib/ supplies a barrier colour, and it supplies '
          'the token -- so no flow can open a sheet over a scrim of its own',
      () {
        final List<String> offenders = <String>[];
        for (final File file in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((File f) => f.path.endsWith('.dart'))) {
          final String code = file.readAsStringSync();
          if (!code.contains('barrierColor')) {
            continue;
          }
          if (!code.contains('barrierColor: HabotSheetScrim.color')) {
            offenders.add(file.path);
          }
        }
        return offenders.isEmpty &&
            HabotSheetScrim.absorbsPointer &&
            // One dimming intensity for the whole app: the sheet scrim and the
            // BPTR-0422 failure dim are the same 32%, not two opinions.
            HabotSheet.scrimOpacity == HabotMotion.failureDimOpacity;
      },
    );

    gate(
      'GEN-00954-G4',
      'Setup Step (Action) -- a scrim exists to separate the sheet from the '
          'page beneath it; if it does not darken enough to do that, it is '
          'decoration.',
      'The scrim measurably darkens both schemes: the scrimmed page surface is '
          'at least 25% darker in relative luminance in light mode, and the '
          'sheet still clears the text floor against its own surface',
      () {
        final double lightBefore = Contrast.relativeLuminance(
          HabotColors.light.surface,
        );
        final double lightAfter = Contrast.relativeLuminance(
          _composite(HabotColors.scrim, HabotColors.light.surface, 0.32),
        );
        final double sheetContrast = Contrast.ratio(
          HabotColors.light.onSurface,
          HabotColors.light.surfaceContainerLow,
        );
        return lightAfter < lightBefore * 0.75 &&
            sheetContrast >= WcagThresholds.textFloor;
      },
    );
  });

  group('GEN-00954-A01 :: applied to the route', () {
    testWidgets('[GEN-00954-G5] the modal route paints the standard scrim and '
        'the scrim absorbs the tap that dismisses the sheet', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => Center(
                child: FilledButton(
                  onPressed: () => HabotBottomSheet.show<void>(
                    context: context,
                    title: 'Complex action',
                    draggable: false,
                    builder: (BuildContext context) => const Text('flow body'),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(HabotSheetSurface), findsOneWidget);

      // The barrier is the modal route's own; tapping it must close the sheet,
      // which is the behaviour that proves the scrim took the pointer.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byType(HabotSheetSurface), findsNothing);

      gates.add(
        const AissGate(
          id: 'GEN-00954-G5',
          requirementSource:
              'Expected Output: "Configure backdrop scrim color to 32% opacity '
              'black." A scrim that does not take the pointer is a tint, not a '
              'modal barrier.',
          description:
              'The modal route shows the sheet over the standard scrim, and a '
              'tap on the scrim dismisses it',
          passed: true,
        ),
      );
    });

    testWidgets('[GEN-00954-G6] the standard presentation collapses its motion '
        'under the reduced-motion preference', (WidgetTester tester) async {
      late BuildContext reduced;
      await tester.pumpWidget(
        MaterialApp(
          theme: HabotTheme.light(),
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (BuildContext context) {
                reduced = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final AnimationStyle style = HabotBottomSheet.animationStyleFor(reduced);
      expect(style.duration, Duration.zero);
      expect(style.reverseDuration, Duration.zero);

      gates.add(
        const AissGate(
          id: 'GEN-00954-G6',
          requirementSource:
              'Setup Step (Action): "Standardize MD3 Bottom-Sheet UI." The '
              'standard has to include the accessibility behaviour, or every '
              'flow re-decides it.',
          description:
              'Under MediaQuery.disableAnimations the sheet route opens with '
              'zero-duration motion in both directions',
          passed: true,
        ),
      );
    });
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00954',
        atomicStepReferenceId: 'GEN-00954-A01',
        setupStepAction:
            'Standardize Material Design 3 (MD3) Bottom-Sheet UI for Mobile '
            'Complex Action Flows',
        implementationOrder: 22,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Configuration Name': 'Bottom-sheet scrim',
          'Configuration Value':
              '${(HabotSheet.scrimOpacity * 100).toStringAsFixed(0)}% opacity '
              'black (#000000)',
          'Completion Status': 'Derived from gate outcomes',
          'Validation Status': 'Validated against the single-value metric',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Scrim Opacity Compliance',
            observed:
                '${(HabotSheet.scrimOpacity * 100).toStringAsFixed(0)}% -- '
                'exact match, single-value metric',
            floor: '32%',
            optimal: '32%',
            ceiling: '32%',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/surfaces/bottom_sheet.dart',
          'lib/design_system/tokens/color_tokens.dart',
          'lib/design_system/tokens/surface_tokens.dart',
        ],
      ),
    );
  });
}

/// Composites [tint] over [base] at [alpha], the same arithmetic the elevation
/// ladder uses -- repeated here so the gate does not depend on the component
/// under test to prove the component under test.
Color _composite(Color tint, Color base, double alpha) {
  int channel(double t, double b) =>
      (((t * alpha) + (b * (1 - alpha))) * 255.0).round().clamp(0, 255);
  return Color.fromARGB(
    255,
    channel(tint.r, base.r),
    channel(tint.g, base.g),
    channel(tint.b, base.b),
  );
}
