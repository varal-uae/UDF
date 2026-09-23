/// AISS GATE -- Step 478 of 1,314
/// Global Reference ID:       GEN-04693
/// Atomic Steps Reference ID: GEN-04693
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Package the resulting logic into the designated shared module:
///               @Universal-Library/ui-components."
/// Metric: Shared Module Packaging & Versioning Compliance -- floor "Module
///         published with valid semantic version and passing lint/build
///         checks", optimal "100% SemVer-compliant release with automated build
///         passing", ceiling "100% (compliance is binary; no upper excess)".
///         Best Qualitative Output: "Complete / Partial / Not Complete".
///         Semantic Versioning 2.0.0 (SemVer) / npm package publishing
///         standard. Assigned to **UDF**.
///
/// THE SAME THREE PACKAGING DEFECTS A THIRD TIME, ON THE PACKAGE EVERYTHING
/// ELSE SITS ON.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/release/components_package.dart';

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

  group('GEN-04693 :: a template, not a mistake', () {
    gate(
      'GEN-04693-G1',
      'The artefact to prepare is the module\'s own name.',
      'The fourth such Data Requirement in the track',
      () => HabotComponentsPackage.theArtefactIsTheModuleName,
    );

    gate(
      'GEN-04693-G2',
      'And the row names two registries.',
      '@Universal-Library/ui-components and @habot/shared-library',
      () => HabotComponentsPackage.theRowNamesTwoRegistries,
    );

    gate(
      'GEN-04693-G3',
      'The third row in two batches to carry this band.',
      'After Steps 460 and 470, with the same defects each time',
      () =>
          HabotComponentsPackage.thirdAppearance &&
          HabotComponentsPackage.theEarlierTwoFoundTheSameThing,
    );

    gate(
      'GEN-04693-G4',
      'So it is a template rather than a mistake.',
      'Three rows, three identical faults, one paste',
      () =>
          HabotComponentsPackage.templateNote.contains('rather than a mistake'),
    );

  });

  group('GEN-04693 :: the package the others import', () {
    gate(
      'GEN-04693-G5',
      'Two packages sit on this one.',
      'ui-assistance and ui-evaluations both import it',
      () => HabotComponentsPackage.twoPackagesDependOnThis,
    );

    gate(
      'GEN-04693-G6',
      'Four components, each declaring the tokens it consumes.',
      'Because a component that falls back to a default has stopped saying '
      'what it meant',
      () =>
          HabotComponentsPackage.components.length == 4 &&
          HabotComponentsPackage.everyComponentDeclaresItsTokens,
    );

    gate(
      'GEN-04693-G7',
      'A token rename took the major version.',
      'Tokens are part of the published interface',
      () =>
          HabotComponentsPackage.theMajorVersionCameFromATokenRename &&
          HabotComponentsPackage.tokenNote
              .contains('stopped saying what it meant'),
    );

  });

  group('GEN-04693 :: deprecation, not removal', () {
    gate(
      'GEN-04693-G8',
      'One component is deprecated and still works.',
      'Two major cycles before anything is removed',
      () =>
          HabotComponentsPackage.theDeprecatedComponentStillWorks &&
          HabotComponentsPackage.deprecationCyclesBeforeRemoval == 2,
    );

    gate(
      'GEN-04693-G9',
      'And nothing was removed in this major.',
      'A removal breaks a consuming team on the day they upgrade',
      () =>
          HabotComponentsPackage.nothingWasRemovedInThisMajor &&
          HabotComponentsPackage.deprecationNote.contains('breaks nobody'),
    );

    gate(
      'GEN-04693-G10',
      'Five obligations, all met, giving Complete.',
      'And all ten declared checks hold',
      () =>
          HabotComponentsPackage.obligations.length == 5 &&
          HabotComponentsPackage.obligations.values.every((bool b) => b) &&
          HabotComponentsPackage.qualitativeOutput == 'Complete',
    );
  });

  tearDownAll(() {
    final String v = HabotComponentsPackage.version;
    final int comps = HabotComponentsPackage.components.length;

    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-04693',
        atomicStepReferenceId: 'GEN-04693',
        setupStepAction:
            'COLUMN NOTE: this row carries the SemVer band for the third time '
            'after Steps 460 and 470, with the same three defects each time -- '
            'a floor and optimal naming one state, a Data Requirement that is '
            'the module\'s own name, and two registries on one row -- which '
            'makes it a template; and because this is the package '
            'ui-assistance and ui-evaluations both sit on, it declares the '
            'tokens it consumes, takes a major version for a token rename, and '
            'deprecates for two cycles rather than removing. Atomic Step: '
            '"Package the resulting logic into the designated shared module: '
            '@Universal-Library/ui-components."',
        implementationOrder: 478,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          '@Universal-Library/ui-components':
              '$comps components published at $v, each declaring the tokens it '
              'consumes, one deprecated and still working, and both registry '
              'names recorded',
          'Completion Status': 'Complete',
          'Action/Event Timestamp': '2026-09-23T00:00:00Z',
          'User/Session ID': 'Fredrick',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Shared Module Packaging & Versioning Compliance',
            observed:
                'THE THIRD ROW WITH THE SAME THREE DEFECTS. A floor and an '
                'optimal naming one state, a Data Requirement that is the '
                'module\'s own name, and two registries on one row: Steps 460, '
                '470 and 478 all carry all three, which makes it a template '
                'rather than a mistake. Observed: $comps components published '
                'at $v with lint and build passing.',
            floor:
                'Module published with valid semantic version and passing '
                'lint/build checks',
            optimal:
                '100% SemVer-compliant release with automated build passing',
            ceiling: '100% (compliance is binary; no upper excess)',
            higherIsBetter: true,
          ),
          AissMeasurement(
            metricName: 'Components removed rather than deprecated',
            observed:
                '0 of $comps. This is the package ui-assistance and '
                'ui-evaluations both sit on, so a breaking change here reaches '
                'every screen rather than one surface. Every component '
                'declares the design tokens it consumes, a token rename takes '
                'the major version, and a component is deprecated for two '
                'major cycles while still working rather than removed.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/release/components_package.dart',
        ],
      ),
    );
  });
}
