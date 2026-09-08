/// AISS GATE -- Step 107 of 115
/// Global Reference ID:       GEN-01352
/// Atomic Steps Reference ID: GEN-01352-A01
/// Setup Step (Action):       "Map system OS dynamic color variables to
///                             client-side theme tokens."
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// METRIC MISMATCH, RECORDED: "OS Theming Compatibility Rate" is a platform
/// property. Whether an OS offers a dynamic palette, and what is in it, is not
/// something a client can move, and no client-side suite can observe the rate.
/// It is reported as NOT PRODUCED. What the client DOES own is gated here.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/contrast.dart';
import 'package:udf_setup/design_system/theme/dynamic_color_mapping.dart';
import 'package:udf_setup/design_system/tokens/color_tokens.dart';

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

  /// A palette that is legible. Derived from this project's own tokens, so it
  /// stands in for a well-behaved OS palette without inventing colours.
  ColorScheme goodPalette() {
    final HabotColorScheme t = HabotColors.light;
    return ColorScheme(
      brightness: Brightness.light,
      primary: t.primary,
      onPrimary: t.onPrimary,
      primaryContainer: t.primaryContainer,
      onPrimaryContainer: t.onPrimaryContainer,
      secondary: t.secondary,
      onSecondary: t.onSecondary,
      secondaryContainer: t.secondaryContainer,
      onSecondaryContainer: t.onSecondaryContainer,
      tertiary: t.tertiary,
      onTertiary: t.onTertiary,
      tertiaryContainer: t.tertiaryContainer,
      onTertiaryContainer: t.onTertiaryContainer,
      error: t.error,
      onError: t.onError,
      errorContainer: t.errorContainer,
      onErrorContainer: t.onErrorContainer,
      surface: t.surface,
      onSurface: t.onSurface,
      onSurfaceVariant: t.onSurfaceVariant,
      surfaceContainerLowest: t.surfaceContainerLowest,
      surfaceContainerLow: t.surfaceContainerLow,
      surfaceContainer: t.surfaceContainer,
      surfaceContainerHigh: t.surfaceContainerHigh,
      surfaceContainerHighest: t.surfaceContainerHighest,
      outline: t.outline,
      outlineVariant: t.outlineVariant,
      inverseSurface: t.inverseSurface,
      onInverseSurface: t.onInverseSurface,
    );
  }

  /// The realistic failure: a wallpaper-derived palette whose "on" colour is
  /// close in luminance to its container. Nothing exotic -- this is what
  /// Material You produces from a mid-grey photograph.
  ColorScheme lowContrastPalette() => goodPalette().copyWith(
    onSurface: const Color(0xFF8A8A8A),
    onSurfaceVariant: const Color(0xFF9A9A9A),
  );

  group('GEN-01352-A01 :: what the client owns', () {
    gate(
      'GEN-01352-G1',
      'Setup Step (Action): "MAP system OS dynamic colour variables to '
          'client-side theme tokens".',
      'Every declared role is filled from the OS palette, so no widget in an '
          'adopted theme falls back to a Material default nobody audited',
      () {
        final HabotDynamicColorResult r = HabotDynamicColorMapping.resolve(
          osScheme: goodPalette(),
          fallback: HabotColors.light,
        );
        return r.adopted &&
            r.mappedRoles == HabotColors.light.roles.length &&
            !r.rejections.contains(HabotDynamicColorRejection.roleMissing);
      },
    );

    gate(
      'GEN-01352-G2',
      'A palette chosen from a wallpaper can break every ratio Step 105 just '
          'measured. Material You is a preference; legible text is not.',
      'A low-contrast OS palette is REFUSED and this app keeps its own '
          'tokens, with each failing pair named so "why did my phone colours '
          'not apply?" has an answer',
      () {
        final HabotDynamicColorResult r = HabotDynamicColorMapping.resolve(
          osScheme: lowContrastPalette(),
          fallback: HabotColors.light,
        );
        return !r.adopted &&
            r.scheme == HabotColors.light &&
            r.rejections.contains(
              HabotDynamicColorRejection.contrastFailure,
            ) &&
            r.rejectedPairs.any((String p) => p.contains('onSurface')) &&
            r.explanation.contains('Kept the design system tokens');
      },
    );

    gate(
      'GEN-01352-G3',
      'A scheme where some roles come from the OS and some do not is a scheme '
          'whose contrast nobody has measured.',
      'Adoption is all or nothing: the returned scheme is either entirely the '
          'OS palette or entirely this project s tokens, never a mixture',
      () {
        final HabotDynamicColorResult bad = HabotDynamicColorMapping.resolve(
          osScheme: lowContrastPalette(),
          fallback: HabotColors.dark,
        );
        final HabotDynamicColorResult good = HabotDynamicColorMapping.resolve(
          osScheme: goodPalette(),
          fallback: HabotColors.dark,
        );
        return bad.scheme == HabotColors.dark &&
            good.scheme != HabotColors.dark &&
            good.scheme.primary == HabotColors.light.primary;
      },
    );
  });

  group('GEN-01352-A01 :: the platform half', () {
    gate(
      'GEN-01352-G4',
      'Most devices offer no dynamic palette at all -- every iOS device, and '
          'Android below 12.',
      'A null palette is an ordinary outcome with its own recorded reason, '
          'not an error and not a silent fallback',
      () {
        final HabotDynamicColorResult r = HabotDynamicColorMapping.resolve(
          osScheme: null,
          fallback: HabotColors.light,
        );
        return !r.adopted &&
            r.mappedRoles == 0 &&
            r.rejections.single == HabotDynamicColorRejection.notOffered &&
            r.explanation.contains('no dynamic palette');
      },
    );

    gate(
      'GEN-01352-G5',
      'Contrast is undefined against an unknown backdrop.',
      'A translucent colour from the OS is refused rather than measured, and '
          'the refusal names the role',
      () {
        final HabotDynamicColorResult r = HabotDynamicColorMapping.resolve(
          osScheme: goodPalette().copyWith(
            primary: const Color(0x80005599),
          ),
          fallback: HabotColors.light,
        );
        return !r.adopted &&
            r.rejections.contains(
              HabotDynamicColorRejection.translucentToken,
            ) &&
            r.rejectedPairs.any((String p) => p.contains('translucent')) &&
            !Contrast.isOpaque(const Color(0x80005599));
      },
    );

    gate(
      'GEN-01352-G6',
      'The decision has to be inspectable after the fact.',
      'The result serialises what was adopted, what was rejected and why, so '
          'the choice can be read out of the evidence rather than reasoned '
          'about from the code',
      () {
        final Map<String, Object?> j = HabotDynamicColorMapping.resolve(
          osScheme: lowContrastPalette(),
          fallback: HabotColors.light,
        ).toJson();
        return j['adopted'] == false &&
            (j['rejected_pairs']! as List<String>).isNotEmpty &&
            (j['rejections']! as List<String>).contains('contrastFailure');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01352',
        atomicStepReferenceId: 'GEN-01352-A01',
        setupStepAction:
            'Map system OS dynamic color variables to client-side theme '
            'tokens.',
        implementationOrder: 107,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotDynamicColorMapping',
          'Component Properties':
              '${HabotColors.light.roles.length} roles mapped from the '
              'platform ColorScheme; completeness, opacity and a full '
              'contrast re-audit applied before adoption; '
              '${HabotDynamicColorRejection.values.length} recorded refusal '
              'reasons',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) and Setup Step Description are the '
              'identical string on this row. No package was added: the '
              'platform supplies a ColorScheme and mapping it is the whole '
              'job, which also makes it testable without a device.',
        },
        measurements: <AissMeasurement>[
          const AissMeasurement(
            metricName: 'Unmapped OS colours reaching a widget',
            observed:
                '0. Adoption is all-or-nothing, so a partially mapped palette '
                'never renders. A palette that fails the re-audit is refused '
                'and every failing pair is named in the result.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
          const AissMeasurement(
            metricName: 'OS Theming Compatibility Rate (the sheet metric)',
            observed:
                'NOT PRODUCED. Whether a platform offers a dynamic palette, '
                'and what is in it, is a property of the operating system and '
                'the user wallpaper. A client cannot move that rate and this '
                'suite cannot observe it. No number is asserted.',
            floor: 'platform property',
            optimal: 'platform property',
            ceiling: 'platform property',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/theme/dynamic_color_mapping.dart',
        ],
      ),
    );
  });
}
