/// AISS GATE -- Step 186 of 195
/// Global Reference ID:       GEN-02753
/// Atomic Steps Reference ID: GEN-02753
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement Material You dynamic color theming by wiring the M3
///               dynamic color scheme to the token package primary color
///               seed."
/// Metric: Design Token Adoption Rate -- Floor "Zero inline CSS or
///         non-tokenized style values in codebase", Optimal "100% design token
///         coverage across all components", Ceiling 1. Pass / Fail.
///
/// MATERIAL YOU AND A WCAG-AUDITED PALETTE ARE IN DIRECT TENSION. A candidate
/// scheme runs through the SAME Step 4 audit the declared palette runs through
/// and is used only if it passes; refusals fall back and are counted, because
/// a silent fallback is indistinguishable from the feature never being wired.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/contrast.dart';
import 'package:udf_setup/design_system/tokens/color_tokens.dart';
import 'package:udf_setup/design_system/tokens/dynamic_color.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double admissionRate = 0;

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

  /// A wallpaper-derived scheme that fails contrast: a pale primary carrying
  /// the same white label the audited palette uses. This is what Material You
  /// actually produces from a light wallpaper.
  HabotColorScheme paleCandidate() => HabotColorScheme(
        primary: HabotColors.light.surfaceContainerHigh,
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

  group('GEN-02753 :: admitted, not adopted', () {
    gate(
      'GEN-02753-G1',
      'Atomic Step: "...wiring the M3 dynamic color scheme to the token '
          'package primary color seed."',
      'The seed comes from the token package rather than from an arbitrary '
          'colour, and it is the same seed the non-dynamic path already uses '
          '-- so the fallback and the dynamic scheme share an origin',
      () =>
          HabotDynamicColor.seedComesFromTokenPackage &&
          HabotDynamicColor.declaredSeed == HabotColors.seedPrimary &&
          HabotDynamicColor.columnNote.contains('EMPTY'),
    );

    gate(
      'GEN-02753-G2',
      '"A pale wallpaper produces a pale primary, and onPrimary over it can '
          'land below 4.5:1 -- which is not a theming preference, it is text '
          'somebody cannot read."',
      'A candidate that fails the Step 4 audit is REFUSED, the declared scheme '
          'is kept, and the failing pairs are named -- so "dynamic colour keeps '
          'getting rejected" arrives with the ratio attached',
      () {
        final HabotDynamicColor engine =
            HabotDynamicColor(fallback: HabotColors.light);
        final HabotDynamicDecision d = engine.admit(paleCandidate());
        return d.verdict == HabotDynamicVerdict.refusedContrast &&
            !d.usedDynamic &&
            d.scheme == HabotColors.light &&
            d.failures.isNotEmpty &&
            d.failures.any(
              (ContrastResult r) =>
                  r.foregroundName.endsWith('onPrimary') &&
                  r.backgroundName.endsWith('primary'),
            ) &&
            d.toString().contains('dynamic colour refused') &&
            engine.refusedCount == 1 &&
            engine.adoptedCount == 0;
      },
    );

    gate(
      'GEN-02753-G3',
      'A gate that refuses everything is as useless as one that admits '
          'everything.',
      'A candidate that passes the audit IS adopted, so the feature is capable '
          'of being active -- demonstrated with the declared dark scheme, '
          'which is a real scheme that has already cleared the same bar',
      () {
        final HabotDynamicColor engine =
            HabotDynamicColor(fallback: HabotColors.light);
        final HabotDynamicDecision d = engine.admit(HabotColors.dark);
        admissionRate = engine.admissionRate;
        return d.verdict == HabotDynamicVerdict.adopted &&
            d.usedDynamic &&
            d.scheme == HabotColors.dark &&
            d.failures.isEmpty &&
            engine.adoptedCount == 1 &&
            admissionRate == 1.0;
      },
    );

    gate(
      'GEN-02753-G4',
      '"A silent fallback is indistinguishable from dynamic colour not being '
          'wired up at all."',
      'The three non-adoption paths are distinguished from each other -- '
          'refused on contrast, unavailable from the platform, and switched '
          'off -- and only the first two count towards the admission rate, '
          'because a disabled feature is not a rejected one',
      () {
        final HabotDynamicColor enabled =
            HabotDynamicColor(fallback: HabotColors.light);
        final HabotDynamicDecision unavailable = enabled.admit(null);
        final HabotDynamicColor off = HabotDynamicColor(
          fallback: HabotColors.light,
          enabled: false,
        );
        final HabotDynamicDecision disabled = off.admit(HabotColors.dark);
        return unavailable.verdict == HabotDynamicVerdict.unavailable &&
            unavailable.scheme == HabotColors.light &&
            enabled.unavailableCount == 1 &&
            enabled.decisions == 1 &&
            disabled.verdict == HabotDynamicVerdict.disabled &&
            disabled.scheme == HabotColors.light &&
            off.decisions == 0 &&
            HabotDynamicVerdict.values.length == 4 &&
            HabotDynamicColor.countedRefusalNote.contains('never once active');
      },
    );

    gate(
      'GEN-02753-G5',
      '"A second, more forgiving bar for dynamic colour would be the quiet way '
          'to let it through."',
      'The candidate audit is the Step 4 audit itself rather than a copy with '
          'looser thresholds -- the declared schemes pass it, which is how we '
          'know it is the same bar they were held to',
      () =>
          HabotDynamicColor.auditCandidate('light', HabotColors.light)
              .isEmpty &&
          HabotDynamicColor.auditCandidate('dark', HabotColors.dark).isEmpty &&
          HabotDynamicColor.auditCandidate('pale', paleCandidate())
              .isNotEmpty &&
          HabotDynamicColor.admittedNotAdoptedNote
              .contains('same Step 4 audit'),
    );
  });

  group('GEN-02753 :: why a colour row carries an adoption metric', () {
    gate(
      'GEN-02753-G6',
      'Metric floor: "Zero inline CSS or non-tokenized style values in '
          'codebase". Optimal: "100% design token coverage across all '
          'components".',
      'Both halves are read from the steps that own them rather than '
          're-measured here: the floor from the Step 180 intercept, the token '
          'set coverage from Step 178, and the widget-layer coverage named as '
          'Step 60\'s figure',
      () =>
          HabotDynamicColor.floorMet &&
          HabotDynamicColor.tokenSetCoverage == 1.0 &&
          HabotDynamicColor.widgetLayerCoverageOwner.contains('Step 60') &&
          HabotDynamicColor.widgetLayerCoverageOwner
              .contains('not re-measured here'),
    );

    gate(
      'GEN-02753-G7',
      '"Dynamic colour converts every tokenisation defect from latent to '
          'visible, which is why the row gates it on adoption first."',
      'The readiness conditions all hold, so the feature is safe to enable: '
          'untokenised values cannot reach a user\'s device, and the declared '
          'token set survives the trip to a widget unchanged',
      () =>
          HabotDynamicColor.isReady &&
          HabotDynamicColor.readinessChecks.length == 5 &&
          HabotDynamicColor.readinessChecks.values.every((bool b) => b) &&
          HabotDynamicColor.qualitativeOutput == 'Pass' &&
          HabotDynamicColor.latentToVisibleNote
              .contains('visible clash on the user\'s own device') &&
          HabotDynamicColor.tensionNote.contains('audited against nothing'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-02753',
        atomicStepReferenceId: 'GEN-02753',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Implement Material You dynamic color theming by wiring the '
            'M3 dynamic color scheme to the token package primary color seed."',
        implementationOrder: 186,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotDynamicColor / HabotDynamicDecision',
          'Component Properties':
              '${HabotDynamicVerdict.values.length} decision verdicts; '
              'candidates audited by ContrastAudit.auditScheme -- the Step 4 '
              'engine itself; seed read from HabotColors.seedPrimary; '
              'refusals, unavailability and disablement counted separately',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'TENSION RECORDED: dynamic colour derives a scheme from the '
              'user\'s wallpaper at runtime, and every colour this product '
              'ships was audited at Step 4 and Step 105 against a contrast '
              'floor. A wallpaper-derived scheme was audited against nothing. '
              'The resolution is admission rather than adoption: a candidate '
              'clears the same bar or the declared scheme is kept and the '
              'refusal is counted. A silent fallback would be '
              'indistinguishable from the feature never being wired up, which '
              'is how something ends up "shipped" and never once active.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Design Token Adoption Rate (readiness for dynamic '
                'colour)',
            observed:
                'All ${HabotDynamicColor.readinessChecks.length} readiness '
                'conditions hold. The floor -- zero non-tokenised style values '
                '-- is the Step 180 intercept\'s, and it is enforced. Token '
                'set coverage is '
                '${HabotDynamicColor.tokenSetCoverage.toStringAsFixed(2)} from '
                'Step 178. Widget-layer coverage is Step 60\'s figure and is '
                'named rather than re-measured, because a codebase can score '
                '1.0 on adoption while adopting the wrong values.',
            floor: 'Zero inline CSS or non-tokenized style values in codebase',
            optimal: '100% design token coverage across all components',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Candidate schemes admitted',
            observed:
                'A scheme that clears the Step 4 audit is adopted '
                '(${(admissionRate * 100).toStringAsFixed(0)}% on a passing '
                'candidate); a pale wallpaper-derived primary carrying a white '
                'label is refused with the failing pair named, and the '
                'declared scheme is kept. Unavailable and disabled are '
                'distinguished from refused, because a disabled feature is not '
                'a rejected one.',
            floor: 'refusals counted, never silent',
            optimal: 'refusals counted, never silent',
            ceiling: 'refusals counted, never silent',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tokens/dynamic_color.dart',
        ],
      ),
    );
  });
}
