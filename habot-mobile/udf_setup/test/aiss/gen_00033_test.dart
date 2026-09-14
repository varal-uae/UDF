/// AISS GATE -- Step 177 of 195
/// Global Reference ID:       GEN-00033
/// Atomic Steps Reference ID: GEN-00033
/// Setup Step (Action): "Identify all entity types in the application that
///                       require scope filtering -- users, projects, regions,
///                       roles."
/// Atomic Step: "Verify that all Figma styles are properly named and
///               structured according to Material Design 3 token specs."
/// Metric: Requirements Definition Completeness -- Floor "All required inputs
///         identified (no gaps)", Optimal "100% coverage of requirement
///         scope", Ceiling 1. Complete / Partial / Not Complete.
///
/// THE FIGMA SIDE CANNOT BE READ FROM A REPOSITORY. What the client owns is
/// the other end of the same mapping -- the canonical MD3 name for every token
/// it declares -- without which "the Figma style is named correctly" has
/// nothing to be correct against.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/tokens/color_tokens.dart';
import 'package:udf_setup/design_system/tokens/m3_naming.dart';
import 'package:udf_setup/design_system/tokens/typography_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double completeness = 0;

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

  group('GEN-00033 :: the naming spec, applied in one place', () {
    gate(
      'GEN-00033-G1',
      'MD3 token names are lower-kebab-case under md.sys.*; Dart identifiers '
          'are camelCase. "Converting by hand at each call site gets '
          'onPrimaryContainer wrong as on-primarycontainer about one time in '
          'ten."',
      'The conversion is done once and is correct on the multi-word roles it '
          'is easy to get wrong, including the ones with a digit that MD3 '
          'keeps attached rather than separating',
      () =>
          HabotM3Naming.kebab('primary') == 'primary' &&
          HabotM3Naming.kebab('onPrimary') == 'on-primary' &&
          HabotM3Naming.kebab('onPrimaryContainer') == 'on-primary-container' &&
          HabotM3Naming.kebab('surfaceContainerHighest') ==
              'surface-container-highest' &&
          HabotM3Naming.kebab('level3') == 'level3' &&
          HabotM3Naming.kebab('displayLarge') == 'display-large',
    );

    gate(
      'GEN-00033-G2',
      'A conformance test that accepts everything proves nothing.',
      'The conformance check accepts a well-formed MD3 name and rejects the '
          'things a hand-written one actually looks like: a Dart identifier, '
          'a missing namespace, an upper-case fragment and a trailing '
          'separator',
      () =>
          HabotM3Naming.isConformant('md.sys.color.on-primary-container') &&
          HabotM3Naming.isConformant('md.sys.elevation.level3') &&
          HabotM3Naming.isConformant('md.ref.palette.neutral10') &&
          !HabotM3Naming.isConformant('md.sys.color.onPrimaryContainer') &&
          !HabotM3Naming.isConformant('color.primary') &&
          !HabotM3Naming.isConformant('md.sys.color.') &&
          !HabotM3Naming.isConformant('md.other.color.primary'),
    );

    gate(
      'GEN-00033-G3',
      'Atomic Step: "verify that ALL styles are properly named". The mapping '
          'has to cover the token set rather than a sample of it.',
      'Every colour role, type role, elevation level and shape radius the '
          'product declares carries a conformant MD3 name, and the colour and '
          'type lists are read from the declarations themselves rather than '
          'from a second list that would drift from them',
      () {
        final int colours = HabotM3Naming.colorTokens.length;
        final int types = HabotM3Naming.typescaleTokens.length;
        return HabotM3Naming.nonConformant().isEmpty &&
            colours == HabotColors.light.roles.length &&
            colours == 28 &&
            types == HabotTypography.all.length &&
            types == 15 &&
            HabotM3Naming.elevationTokens.length == 6 &&
            HabotM3Naming.shapeTokens.length ==
                HabotM3Naming.shapeNames.length &&
            HabotM3Naming.all.length == colours + types + 6 +
                HabotM3Naming.shapeNames.length;
      },
    );

    gate(
      'GEN-00033-G4',
      'MD3 names shape radii by size word; this repository uses abbreviated '
          'identifiers.',
      'The shape mapping is explicit rather than derived from the '
          'abbreviations, so "xl" resolves to the MD3 word rather than to a '
          'token name no specification contains',
      () =>
          HabotM3Naming.shapeNames['xl'] == 'extra-large' &&
          HabotM3Naming.shapeNames['xs'] == 'extra-small' &&
          HabotM3Naming.shapeNames['md'] == 'medium' &&
          HabotM3Naming.shapeTokens.every(
            (HabotM3Token t) =>
                t.m3Name.startsWith('md.sys.shape.corner.') &&
                HabotM3Naming.isConformant(t.m3Name),
          ),
    );
  });

  group('GEN-00033 :: extensions, declared rather than discovered', () {
    gate(
      'GEN-00033-G5',
      '"A role with no MD3 name is not a failure -- it is a brand extension. '
          'The failure mode is an extension nobody wrote down, which is '
          'indistinguishable from an MD3 role that was misnamed."',
      'Every value this product declares that MD3 does not specify is listed '
          'as an extension with a reason, and the reasons say what the value '
          'is rather than that it is ours',
      () =>
          HabotM3Naming.brandExtensions.length == 6 &&
          HabotM3Naming.isBrandExtension('seedPrimary') &&
          HabotM3Naming.isBrandExtension('pageFrameLightStart') &&
          HabotM3Naming.isBrandExtension('scrim') &&
          !HabotM3Naming.isBrandExtension('primary') &&
          !HabotM3Naming.isBrandExtension('surfaceContainer') &&
          HabotM3Naming.brandExtensions.values
              .every((String r) => r.length > 30) &&
          HabotM3Naming.brandExtensions['scrim']!.contains('opacity') &&
          HabotM3Naming.extensionNote.contains('misnamed'),
    );

    gate(
      'GEN-00033-G6',
      'Metric: Requirements Definition Completeness -- "all required inputs '
          'identified (no gaps)", optimal "100% coverage of requirement '
          'scope".',
      'The completeness figure is computed over the declared checks, reaches '
          '1.0, and the half this repository cannot check is NAMED rather than '
          'left looking like an omission',
      () {
        completeness = HabotM3Naming.completeness;
        return HabotM3Naming.completenessChecks.length == 6 &&
            HabotM3Naming.completenessChecks.values.every((bool b) => b) &&
            completeness == 1.0 &&
            completeness >= HabotM3Naming.optimal &&
            HabotM3Naming.qualitativeOutput == 'Complete' &&
            HabotM3Naming.outOfScope.length == 1 &&
            HabotM3Naming.outOfScope.single.contains('Figma') &&
            HabotM3Naming.figmaBoundaryNote
                .contains('two people reading two lists');
      },
    );

    gate(
      'GEN-00033-G7',
      'COLUMN NOTE: the Setup Step names entity scope filtering -- users, '
          'projects, regions, roles. The Atomic Step names Figma style '
          'naming.',
      'The mismatch is recorded in the code rather than resolved by picking '
          'whichever was easier to build',
      () =>
          HabotM3Naming.columnNote.contains('scope filtering') &&
          HabotM3Naming.columnNote.contains('share no vocabulary') &&
          HabotM3Naming.columnNote.contains('unit of work'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00033',
        atomicStepReferenceId: 'GEN-00033',
        setupStepAction:
            'COLUMN NOTE: the Setup Step names entity scope filtering; the '
            'Atomic Step names Figma style naming against the MD3 token spec. '
            'Atomic Step: "Verify that all Figma styles are properly named and '
            'structured according to Material Design 3 token specs."',
        implementationOrder: 177,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotM3Naming / HabotM3Token',
          'Component Properties':
              '${HabotM3Naming.all.length} tokens mapped to canonical MD3 '
              'names (${HabotM3Naming.colorTokens.length} colour, '
              '${HabotM3Naming.typescaleTokens.length} typescale, '
              '${HabotM3Naming.elevationTokens.length} elevation, '
              '${HabotM3Naming.shapeTokens.length} shape); '
              '${HabotM3Naming.brandExtensions.length} declared brand '
              'extensions with reasons',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'BOUNDARY RECORDED: Figma styles live in a design file this '
              'build cannot read, so the Figma half is out of scope and named '
              'as such. What the client owns is the other end of the mapping: '
              'without a canonical name for every token it declares, "the '
              'Figma style is named correctly" has nothing to be correct '
              'against. COLUMN NOTE: the Setup Step and the Atomic Step on '
              'this row describe different work and share no vocabulary.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Requirements Definition Completeness',
            observed:
                '${completeness.toStringAsFixed(2)} over '
                '${HabotM3Naming.completenessChecks.length} declared checks. '
                'Every colour, type, elevation and shape token converts to a '
                'conformant md.sys.* name; every departure from the MD3 role '
                'set is declared as a brand extension with a reason; and the '
                'camelCase-to-kebab conversion happens in one place rather '
                'than at each call site.',
            floor: 'All required inputs identified (no gaps)',
            optimal: '100% coverage of requirement scope',
            ceiling: '1',
          ),
          AissMeasurement(
            metricName: 'Tokens mapped to a canonical MD3 name',
            observed:
                '${HabotM3Naming.all.length} of ${HabotM3Naming.all.length}, '
                'with 0 non-conformant. The colour and type lists are read '
                'from the declarations themselves rather than from a second '
                'list, so a role added to the scheme appears here without '
                'anyone remembering to add it.',
            floor: 'all declared tokens',
            optimal: 'all declared tokens',
            ceiling: 'all declared tokens',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tokens/m3_naming.dart',
        ],
      ),
    );
  });
}
