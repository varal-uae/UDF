/// AISS GATE -- Step 103 of 115
/// Global Reference ID:       GEN-04462
/// Atomic Steps Reference ID: GEN-04462-A01
/// Setup Step (Action):       "Verify typography sizing, line heights, and
///                             weights against Figma specs."
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// SUBSTITUTION RECORDED: there is no Figma file in this project, and a
/// "Visual Regression Pixel Variance" metric needs a reference image to vary
/// from. The declared type scale is the specification, and it is what this
/// verifies against. No pixel-variance figure is invented.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/a11y/type_scale_audit.dart';
import 'package:udf_setup/design_system/tokens/typography_tokens.dart';

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

  group('GEN-04462-A01 :: the three properties the row names', () {
    gate(
      'GEN-04462-G1',
      'Setup Step (Action): "verify typography SIZING ... against specs".',
      'Sizes descend within each Material role group, which is the '
          'relationship a scale has -- checked per group, because bodyLarge '
          'is deliberately larger than titleSmall and a whole-list check '
          'would report that correct design as a defect',
      () {
        final List<HabotTypeFinding> f = HabotTypeScaleAudit.audit();
        return f
                .where(
                  (HabotTypeFinding x) =>
                      x.defect == HabotTypeDefect.sizeNotDescending,
                )
                .isEmpty &&
            HabotTypeScaleAudit.groupOf(HabotTypography.bodyLarge) == 'body' &&
            HabotTypeScaleAudit.groupOf(HabotTypography.titleSmall) == 'title';
      },
    );

    gate(
      'GEN-04462-G2',
      'Setup Step (Action): "... LINE HEIGHTS ...".',
      'No token has leading tighter than its glyphs, and every leading ratio '
          'sits inside the band where text is neither cramped nor drifting '
          'apart',
      () {
        final List<HabotTypeFinding> f = HabotTypeScaleAudit.audit();
        return f
                .where(
                  (HabotTypeFinding x) =>
                      x.defect == HabotTypeDefect.leadingTighterThanGlyphs ||
                      x.defect == HabotTypeDefect.leadingRatioOutOfBand,
                )
                .isEmpty &&
            HabotTypography.all.every(
              (HabotTypeToken t) =>
                  t.heightMultiple >= HabotTypeScaleAudit.minLeadingRatio &&
                  t.heightMultiple <= HabotTypeScaleAudit.maxLeadingRatio,
            );
      },
    );

    gate(
      'GEN-04462-G3',
      'Setup Step (Action): "... and WEIGHTS".',
      'Every declared weight is a real Material weight, so no token resolves '
          'to a face the platform has to synthesise',
      () =>
          HabotTypography.all.every(
            (HabotTypeToken t) =>
                HabotTypeScaleAudit.materialWeights.contains(t.weight),
          ) &&
          HabotTypography.all.every(
            (HabotTypeToken t) => t.fontWeight.value == t.weight,
          ),
    );
  });

  group('GEN-04462-A01 :: the substitution, and its limits', () {
    gate(
      'GEN-04462-G4',
      'The row names Figma; there is no Figma file in this project.',
      'The specification this audit runs against is named in the code, so a '
          'reader is told what was substituted rather than assuming a design '
          'file was consulted',
      () =>
          HabotTypeScaleAudit.specificationSource.contains(
            'typography_tokens.dart',
          ) &&
          HabotTypeScaleAudit.specificationSource.contains('Figma'),
    );

    gate(
      'GEN-04462-G5',
      'Two names for one visual style is a scale nobody can apply '
          'consistently.',
      'Duplicate tokens are detected, and the one duplicate Material 3 itself '
          'declares is recorded as a sanctioned exemption with its reason '
          'rather than skipped silently -- so a NEW collision still fails',
      () {
        final List<HabotTypeFinding> f = HabotTypeScaleAudit.audit();
        final bool noneReported = f
            .where(
              (HabotTypeFinding x) =>
                  x.defect == HabotTypeDefect.duplicateToken,
            )
            .isEmpty;
        // The pair really is identical -- the exemption is not hiding a
        // difference that would make the rule pointless.
        final bool actuallyIdentical =
            HabotTypography.titleSmall.sizeSp ==
                HabotTypography.labelLarge.sizeSp &&
            HabotTypography.titleSmall.lineHeightSp ==
                HabotTypography.labelLarge.lineHeightSp &&
            HabotTypography.titleSmall.weight ==
                HabotTypography.labelLarge.weight &&
            HabotTypography.titleSmall.tracking ==
                HabotTypography.labelLarge.tracking;
        return noneReported &&
            actuallyIdentical &&
            HabotTypeScaleAudit.sanctionedDuplicates.length == 2 &&
            HabotTypeScaleAudit.sanctionedDuplicateRationale.contains(
              'Material 3',
            );
      },
    );

    gate(
      'GEN-04462-G6',
      'A verification that always passes verifies nothing.',
      'The scale is clean overall, and the audit reports that as a sentence '
          'naming the specification rather than as a bare boolean',
      () =>
          HabotTypeScaleAudit.isClean &&
          HabotTypeScaleAudit.report().contains('TYPE SCALE CLEAN') &&
          HabotTypeScaleAudit.report().contains('typography_tokens.dart'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04462',
        atomicStepReferenceId: 'GEN-04462-A01',
        setupStepAction:
            'Verify typography sizing, line heights, and weights against '
            'Figma specs.',
        implementationOrder: 103,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotTypeScaleAudit',
          'Component Properties':
              '${HabotTypography.all.length} tokens checked against six '
              'relationships; leading band '
              '${HabotTypeScaleAudit.minLeadingRatio}..'
              '${HabotTypeScaleAudit.maxLeadingRatio}; '
              '${HabotTypeScaleAudit.sanctionedDuplicates.length} sanctioned '
              'duplicate roles recorded with a rationale',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'The row names Figma and a pixel-variance metric. Neither '
              'exists in this project; the substitution is recorded in the '
              'audit itself and printed in its report.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Type scale findings',
            observed:
                '${HabotTypeScaleAudit.audit().length} findings across '
                '${HabotTypography.all.length} tokens, verified against '
                '${HabotTypeScaleAudit.specificationSource}',
            floor: 'no finding',
            optimal: 'no finding',
            ceiling: 'no finding',
            higherIsBetter: false,
          ),
          const AissMeasurement(
            metricName: 'Visual Regression Pixel Variance (the sheet metric)',
            observed:
                'NOT PRODUCED. A pixel-variance figure needs a reference '
                'image, and the Figma file the row names does not exist in '
                'this project. The declared type scale was substituted as the '
                'specification and that substitution is recorded rather than '
                'a number being invented.',
            floor: 'no reference image exists',
            optimal: 'no reference image exists',
            ceiling: 'no reference image exists',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/a11y/type_scale_audit.dart',
        ],
      ),
    );
  });
}
