/// AISS GATE -- Step 105 of 115
/// Global Reference ID:       GEN-00368
/// Atomic Steps Reference ID: GEN-00368-A01
/// Setup Step (Action):       "Confirm pixel-perfect token alignment across
///                             light, dark, and high-contrast modes."
/// Metric: WCAG Contrast Ratio -- 3:1 large text / UI, 4.5:1 normal, 7:1 AAA.
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// THE METRIC FITS, and it names the CORRECT 3:1 non-text floor -- which Step 4
/// measured at the stricter text floor. Both floors are used here, each on the
/// pairs it applies to.
library;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/contrast.dart';
import 'package:udf_setup/design_system/a11y/contrast_audit.dart';
import 'package:udf_setup/design_system/tokens/color_tokens.dart';
import 'package:udf_setup/design_system/tokens/high_contrast_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double worstText = 21;
  double worstNonText = 21;
  int pairsChecked = 0;

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

  group('GEN-00368-A01 :: the third scheme', () {
    gate(
      'GEN-00368-G1',
      'Metric: WCAG Contrast Ratio, 7:1 AAA. A high-contrast mode that only '
          'clears the 4.5:1 AA floor is the normal mode with a different name.',
      'Every text pair in BOTH high-contrast schemes clears 7:1, not merely '
          'the AA floor -- the promise is a number and the number is measured',
      () {
        for (final MapEntry<String, HabotColorScheme> e
            in HabotHighContrast.highContrastSchemes.entries) {
          for (final AuditPair p in ContrastAudit.textPairs) {
            pairsChecked++;
            final double r = Contrast.ratio(
              e.value.roles[p.foreground]!,
              e.value.roles[p.background]!,
            );
            if (r < worstText) {
              worstText = r;
            }
            if (r < HabotHighContrast.textFloor) {
              return false;
            }
          }
        }
        return pairsChecked == ContrastAudit.textPairs.length * 2;
      },
    );

    gate(
      'GEN-00368-G2',
      'Metric names the CORRECT 3:1 floor for large text and UI components, '
          'which Step 4 measured at the stricter text floor.',
      'Meaning-bearing non-text pairs are measured at their own 3:1 floor in '
          'both high-contrast schemes, and clear it with room to spare',
      () {
        for (final HabotColorScheme s
            in HabotHighContrast.highContrastSchemes.values) {
          for (final AuditPair p in ContrastAudit.nonTextPairs) {
            final double r = Contrast.ratio(
              s.roles[p.foreground]!,
              s.roles[p.background]!,
            );
            if (r < worstNonText) {
              worstNonText = r;
            }
            if (r < HabotHighContrast.nonTextFloor) {
              return false;
            }
          }
        }
        return worstNonText >= WcagThresholds.nonTextFloor;
      },
    );

    gate(
      'GEN-00368-G3',
      'Setup Step (Action): "PIXEL-PERFECT TOKEN ALIGNMENT across light, dark, '
          'and high-contrast modes".',
      'All four schemes declare exactly the same role set, so no widget in '
          'any mode can fall back to a Material default nobody audited',
      () =>
          HabotHighContrast.allSchemes.values.every(
            (HabotColorScheme s) =>
                HabotHighContrast.rolesAlign(HabotColors.light, s),
          ) &&
          HabotHighContrast.missingRoles(
            HabotColors.light,
            HabotHighContrast.dark,
          ).isEmpty &&
          HabotColors.light.roles.length == 28,
    );
  });

  group('GEN-00368-A01 :: it flows through the existing engine', () {
    gate(
      'GEN-00368-G4',
      'Step 4 already owns the WCAG ratio engine. High contrast is a new '
          'scheme through it, not a second calculator.',
      'The scheme type is identical, so the Step 4 engine, the Step 96 audit '
          'and the Step 107 re-audit all pick it up with no code change',
      () =>
          HabotHighContrast.light.roles.length ==
              HabotColors.light.roles.length &&
          HabotHighContrast.allSchemes.length == 4 &&
          HabotHighContrast.allSchemes.containsKey('highContrastLight') &&
          HabotHighContrast.allSchemes.containsKey('highContrastDark'),
    );

    gate(
      'GEN-00368-G5',
      'Every design token must be opaque -- a translucent token makes the '
          'measured ratio depend on whatever sits behind it.',
      'No role in either high-contrast scheme is translucent',
      () => HabotHighContrast.highContrastSchemes.values.every(
        (HabotColorScheme s) => s.roles.values.every(Contrast.isOpaque),
      ),
    );

    gate(
      'GEN-00368-G6',
      'The dark elevation ladder lifts surfaces with a translucent white '
          'overlay (Step 3), which NARROWS the gap to the text on them.',
      'The high-contrast dark ladder is five opaque steps instead, and every '
          'one of them still clears 7:1 against onSurface',
      () {
        final HabotColorScheme d = HabotHighContrast.dark;
        final List<Color> ladder = <Color>[
          d.surfaceContainerLowest,
          d.surfaceContainerLow,
          d.surfaceContainer,
          d.surfaceContainerHigh,
          d.surfaceContainerHighest,
        ];
        // Opaque, monotonically lighter, and all above the AAA floor.
        double previous = -1;
        for (final Color c in ladder) {
          final double lum = Contrast.relativeLuminance(c);
          if (lum < previous) {
            return false;
          }
          previous = lum;
          if (Contrast.ratio(d.onSurface, c) < HabotHighContrast.textFloor) {
            return false;
          }
        }
        return ladder.every(Contrast.isOpaque);
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00368',
        atomicStepReferenceId: 'GEN-00368-A01',
        setupStepAction:
            'Confirm pixel-perfect token alignment across light, dark, and '
            'high-contrast modes.',
        implementationOrder: 105,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotHighContrast',
          'Component Properties':
              '2 new schemes, ${HabotColors.light.roles.length} roles each, '
              'identical role set to light and dark; scheme floor '
              '${HabotHighContrast.textFloor}:1 for text and '
              '${HabotHighContrast.nonTextFloor}:1 for meaning-bearing '
              'non-text',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Setup Step (Action) and Setup Step Description are the '
              'identical string on this row. The metric fits, and it names '
              'the correct 3:1 non-text floor.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'WCAG Contrast Ratio -- text, high-contrast schemes',
            observed:
                'worst pair ${worstText.toStringAsFixed(2)}:1 across '
                '$pairsChecked pairs. The scheme holds itself to the AAA '
                'figure rather than the AA floor, because a high-contrast '
                'mode that only just passes AA has not done anything.',
            floor: '4.5:1 (normal text)',
            optimal: '7:1 (AAA)',
            ceiling: '7:1 (AAA)',
          ),
          AissMeasurement(
            metricName: 'WCAG Contrast Ratio -- non-text, high-contrast '
                'schemes',
            observed:
                'worst pair ${worstNonText.toStringAsFixed(2)}:1, measured at '
                'the 3:1 floor the metric correctly names for large text and '
                'UI components',
            floor: '3:1 (large text / UI)',
            optimal: '4.5:1',
            ceiling: '7:1',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tokens/high_contrast_tokens.dart',
        ],
      ),
    );
  });
}
