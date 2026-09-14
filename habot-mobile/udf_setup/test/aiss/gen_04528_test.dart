/// AISS GATE -- Step 178 of 195
/// Global Reference ID:       GEN-04528
/// Atomic Steps Reference ID: GEN-04528
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Validate visual output parity between token definitions and
///               Figma source components."
/// Metric: Design Token Adoption Rate -- Floor 0.9, Optimal 1, Ceiling 1.
///         Complete / Partial / Not Complete.
///
/// PARITY NEEDS TWO SIDES AND FIGMA IS NOT ONE THIS BUILD CAN READ. The same
/// class of defect -- definition does not equal output -- is checkable on the
/// pair this repository owns both ends of, and it can diverge silently: a role
/// missed in the theme's override list resolves to a tonal value the Step 4
/// audit never saw.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/theme/habot_theme.dart';
import 'package:udf_setup/design_system/tokens/color_tokens.dart';
import 'package:udf_setup/design_system/tokens/token_parity.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double parity = 0;

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

  group('GEN-04528 :: declared equals delivered', () {
    gate(
      'GEN-04528-G1',
      'Atomic Step: "Validate visual output parity between token definitions '
          'and ... components."',
      'Every colour role the token package declares arrives at a widget with '
          'the value it was declared with, in both schemes the app ships -- so '
          'the colour the Step 4 audit measured is the colour that renders',
      () {
        parity = HabotTokenParity.overallParityRate;
        return HabotTokenParity.auditAll().isEmpty &&
            parity == 1.0 &&
            parity >= HabotTokenParity.optimal &&
            parity >= HabotTokenParity.floor &&
            HabotTokenParity.qualitativeOutput == 'Complete';
      },
    );

    gate(
      'GEN-04528-G2',
      '"A role added to HabotColorScheme and forgotten in the theme is a token '
          'that does nothing."',
      'Every declared role is read back from a real built ColorScheme, so a '
          'role with nowhere to arrive is reported as unwired rather than '
          'silently skipped',
      () {
        final ColorScheme light = HabotTheme.light().colorScheme;
        return HabotTokenParity.unwiredRoles(HabotColors.light, light)
                .isEmpty &&
            HabotTokenParity.unwiredRoles(
              HabotColors.dark,
              HabotTheme.dark().colorScheme,
            ).isEmpty &&
            HabotTokenParity.deliveredRoles(light).length ==
                HabotColors.light.roles.length &&
            HabotTokenParity.deliveredRoles(light).keys.toSet().containsAll(
                  HabotColors.light.roles.keys,
                );
      },
    );

    gate(
      'GEN-04528-G3',
      '"A role missed in the override list resolves to whatever the MD3 tonal '
          'algorithm produced from the seed. Every existing check misses it: '
          'the Step 4 contrast audit reads HabotColorScheme, not the built '
          'theme."',
      'The check is shown DETECTING that failure, on a scheme where one role '
          'has been changed away from what the theme delivers -- because a '
          'comparison that can only ever agree proves nothing',
      () {
        final ColorScheme built = HabotTheme.light().colorScheme;
        // The same declared scheme with one role moved. This is what a missed
        // override looks like from the audit's side: the declaration says one
        // thing, the widget receives another.
        final HabotColorScheme drifted = HabotColorScheme(
          primary: HabotColors.dark.primary,
          onPrimary: HabotColors.light.onPrimary,
          primaryContainer: HabotColors.light.primaryContainer,
          onPrimaryContainer: HabotColors.light.onPrimaryContainer,
          secondary: HabotColors.light.secondary,
          onSecondary: HabotColors.light.onSecondary,
          secondaryContainer: HabotColors.light.secondaryContainer,
          onSecondaryContainer: HabotColors.light.onSecondaryContainer,
          tertiary: HabotColors.light.tertiary,
          onTertiary: HabotColors.light.onTertiary,
          tertiaryContainer: HabotColors.light.tertiaryContainer,
          onTertiaryContainer: HabotColors.light.onTertiaryContainer,
          error: HabotColors.light.error,
          onError: HabotColors.light.onError,
          errorContainer: HabotColors.light.errorContainer,
          onErrorContainer: HabotColors.light.onErrorContainer,
          surface: HabotColors.light.surface,
          onSurface: HabotColors.light.onSurface,
          onSurfaceVariant: HabotColors.light.onSurfaceVariant,
          surfaceContainerLowest: HabotColors.light.surfaceContainerLowest,
          surfaceContainerLow: HabotColors.light.surfaceContainerLow,
          surfaceContainer: HabotColors.light.surfaceContainer,
          surfaceContainerHigh: HabotColors.light.surfaceContainerHigh,
          surfaceContainerHighest: HabotColors.light.surfaceContainerHighest,
          outline: HabotColors.light.outline,
          outlineVariant: HabotColors.light.outlineVariant,
          inverseSurface: HabotColors.light.inverseSurface,
          onInverseSurface: HabotColors.light.onInverseSurface,
        );
        final List<HabotParityFinding> findings =
            HabotTokenParity.drift(drifted, built);
        return findings.length == 1 &&
            findings.single.role == 'primary' &&
            findings.single.toString().contains('declared') &&
            findings.single.toString().contains('delivered') &&
            HabotTokenParity.parityRate(drifted, built) < 1.0 &&
            HabotTokenParity.parityRate(drifted, built) ==
                27 / 28;
      },
    );

    gate(
      'GEN-04528-G4',
      'A finding that says "parity failed" is not actionable.',
      'A drift finding names the role and prints both values, and says which '
          'of them the contrast audit measured -- which is the sentence that '
          'turns it into a fix',
      () {
        final HabotParityFinding f = HabotParityFinding(
          role: 'primary',
          declared: HabotColors.light.primary,
          delivered: HabotColors.dark.primary,
        );
        final String s = f.toString();
        return s.startsWith('primary:') &&
            s.contains('0xFF00538A') &&
            s.contains('0xFF9BCBFF') &&
            s.contains('the contrast audit read the declared value') &&
            s.contains('the user saw the delivered one');
      },
    );
  });

  group('GEN-04528 :: the boundary, and the other number', () {
    gate(
      'GEN-04528-G5',
      'Figma styles live in a design file this build cannot read.',
      'The boundary is recorded rather than the check being quietly narrowed '
          'and reported as though it covered the design tool',
      () =>
          HabotTokenParity.figmaBoundaryNote.contains('cannot read') &&
          HabotTokenParity.figmaBoundaryNote
              .contains('owns both ends of') &&
          HabotTokenParity.silentDriftNote.contains('does not fail, does not '
              'warn, and does not look wrong') &&
          HabotTokenParity.columnNote.contains('EMPTY'),
    );

    gate(
      'GEN-04528-G6',
      'Metric: Design Token Adoption Rate. Step 60 already owns a figure by '
          'that name.',
      'This step measures the hop BEFORE adoption -- whether the token a '
          'widget adopts is the token that was declared -- and says so, rather '
          'than presenting one number as the other',
      () =>
          HabotTokenParity.adoptionIsAnotherNumberNote.contains('Step 60') &&
          HabotTokenParity.adoptionIsAnotherNumberNote
              .contains('adopting the wrong values') &&
          HabotTokenParity.floor == 0.9 &&
          HabotTokenParity.optimal == 1.0,
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04528',
        atomicStepReferenceId: 'GEN-04528',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Validate visual output parity between token definitions '
            'and Figma source components."',
        implementationOrder: 178,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotTokenParity / HabotParityFinding',
          'Component Properties':
              'Compares all ${HabotColors.light.roles.length} declared colour '
              'roles against the values a built ColorScheme delivers, in both '
              'the light and dark schemes; reports unwired roles and drifted '
              'values separately',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'BOUNDARY RECORDED: parity needs two sides and Figma is not one '
              'this build can read. The checkable pair is the token as '
              'declared against the colour a widget is handed, which is the '
              'same class of defect. IT CAN DIVERGE SILENTLY: HabotTheme '
              'builds its scheme with ColorScheme.fromSeed and overrides each '
              'audited role, so a role missed in that list resolves to a tonal '
              'value -- valid Material, not obviously wrong, and never '
              'audited, because the Step 4 engine reads HabotColorScheme '
              'rather than the built theme. Nothing else in this repository '
              'compares the two.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Token parity (declared vs delivered)',
            observed:
                '${parity.toStringAsFixed(2)} across both schemes: every one '
                'of the ${HabotColors.light.roles.length} declared roles '
                'arrives at a widget unchanged. The same computation reports '
                '${(27 / 28).toStringAsFixed(3)} on a scheme with one role '
                'moved, and names it -- so the figure is a measurement rather '
                'than a constant.',
            floor: '0.9',
            optimal: '1',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Unwired roles',
            observed:
                '0 in both schemes. A role declared in the token package with '
                'nowhere to arrive is a token that does nothing; it is '
                'reported by name rather than skipped.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tokens/token_parity.dart',
        ],
      ),
    );
  });
}
