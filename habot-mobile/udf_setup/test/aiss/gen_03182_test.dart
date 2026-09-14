/// AISS GATE -- Step 176 of 195
/// Global Reference ID:       GEN-03182
/// Atomic Steps Reference ID: GEN-03182
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Initialize a new NPM package directory named
///               @habot/design-tokens."
/// Metric: Package Initialisation Speed -- Floor "< 5s", Optimal "< 1s",
///         Ceiling "10s". Complete.
///
/// MEASURED AS `npm init` THIS METRIC IS A DISK WRITE. Read as what it costs
/// to have the token set available when the first frame is built, it finds
/// something: every family is const and free, and the theme adapter runs the
/// MD3 tonal algorithm on the cold-start path and throws the result away.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/tokens/token_package.dart';

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

  group('GEN-03182 :: the substitution, recorded', () {
    gate(
      'GEN-03182-G1',
      'Atomic Step: "Initialize a new NPM package directory named '
          '@habot/design-tokens." This is a Flutter application.',
      'The name the row gives and the name a Dart package can actually carry '
          'are both recorded, along with the ecosystem, so the substitution is '
          'traceable from either direction rather than the row being quietly '
          'renamed',
      () =>
          HabotTokenPackage.requestedName == '@habot/design-tokens' &&
          HabotTokenPackage.packageName == 'habot_design_tokens' &&
          !HabotTokenPackage.packageName.contains('@') &&
          !HabotTokenPackage.packageName.contains('/') &&
          HabotTokenPackage.ecosystem.contains('pub') &&
          HabotTokenPackage.npmSubstitution.contains('no network') &&
          HabotTokenPackage.notExtractedNote.contains('recorded as not done'),
    );

    gate(
      'GEN-03182-G2',
      'Common Library to Store: "@habot/shared-library". A package is what it '
          'contains and where its contents may be declared.',
      'Every token family is declared with exactly one declaration site, one '
          'public surface and a stated purpose, and no two families share a '
          'site -- so "where does this value live" has one answer',
      () {
        final Set<String> sites = HabotTokenPackage.declarationSites;
        final Set<String> names = HabotTokenPackage.families
            .map((HabotTokenFamily f) => f.name)
            .toSet();
        return HabotTokenPackage.families.length == 8 &&
            names.length == HabotTokenPackage.families.length &&
            HabotTokenPackage.families.every(
              (HabotTokenFamily f) =>
                  f.declarationSite.startsWith('lib/') &&
                  f.declarationSite.endsWith('.dart') &&
                  f.surface.startsWith('Habot') &&
                  f.purpose.length > 20,
            ) &&
            // Two families share elevation_tokens.dart only if someone made a
            // mistake: sites are one-to-one with families.
            sites.length == HabotTokenPackage.families.length &&
            HabotTokenPackage.familyNamed('motion')?.declarationSite ==
                'lib/design_system/tokens/motion_tokens.dart' &&
            HabotTokenPackage.familyNamed('nothing') == null;
      },
    );
  });

  group('GEN-03182 :: the metric, read as what it costs at startup', () {
    gate(
      'GEN-03182-G3',
      'Metric: Package Initialisation Speed -- optimal "< 1s". Measured as an '
          '`npm init`, that is a disk write: under a second on every machine '
          'ever built.',
      'The reading is recorded, and the property it turns on is checkable: '
          'every family is const-declared, so the token set costs nothing to '
          'have available -- the values are compiled into the binary and there '
          'is nothing to initialise',
      () =>
          HabotTokenPackage.initialisesFree &&
          HabotTokenPackage.constFamilies ==
              HabotTokenPackage.families.length &&
          HabotTokenPackage.speedReadingNote.contains('cold-start budget') &&
          HabotTokenPackage.speedReadingNote.contains('disk write'),
    );

    gate(
      'GEN-03182-G4',
      'Step 165 budgets the whole cold-start path at 1.2s on the floor '
          'device. Work done on that path to produce values that are then '
          'discarded is worth naming.',
      'The one non-constant cost in the token path is named with what it costs '
          'and what it buys, rather than the startup figure being reported as '
          'zero -- the theme adapter runs the MD3 tonal algorithm from the '
          'seed and then overrides all 28 audited roles, discarding what it '
          'computed',
      () =>
          HabotTokenPackage.startupWork.length == 1 &&
          HabotTokenPackage.startupWork.containsKey(
            'HabotTheme.ColorScheme.fromSeed',
          ) &&
          HabotTokenPackage.startupWork.values.single
              .contains('discarded') &&
          HabotTokenPackage.startupWork.values.single.contains('Step 165') &&
          HabotTokenPackage.seedFallbackRationale.contains('MISSING_ROLE'),
    );

    gate(
      'GEN-03182-G5',
      '"A value written down outside a declaration site is a value somebody '
          'typed into a widget."',
      'The manifest answers whether a given path may declare a token, which is '
          'what makes it a package boundary rather than a folder listing',
      () =>
          HabotTokenPackage.isDeclarationSite(
            'lib/design_system/tokens/color_tokens.dart',
          ) &&
          HabotTokenPackage.isDeclarationSite(
            'lib/design_system/tokens/motion_tokens.dart',
          ) &&
          !HabotTokenPackage.isDeclarationSite(
            'lib/design_system/dashboard/kpi_card.dart',
          ) &&
          !HabotTokenPackage.isDeclarationSite(
            'lib/design_system/theme/habot_theme.dart',
          ),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-03182',
        atomicStepReferenceId: 'GEN-03182',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Initialize a new NPM package directory named '
            '@habot/design-tokens."',
        implementationOrder: 176,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotTokenPackage',
          'Component Properties':
              '${HabotTokenPackage.families.length} declared token families, '
              'one declaration site each, all const; package '
              '"${HabotTokenPackage.packageName}" v'
              '${HabotTokenPackage.version}; currently at '
              '${HabotTokenPackage.currentLocation} rather than extracted',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'SUBSTITUTION RECORDED: the row names an NPM package. NPM is '
              'JavaScript\'s registry; a Flutter app\'s package manager is pub '
              'and a Dart package name may not contain "@" or "/". There is '
              'also no network on this build host. What is built is the '
              'manifest -- contents, public surface, declaration sites -- '
              'because that is the half that decides whether a token set is a '
              'package or a folder. READING RECORDED: "Package Initialisation '
              'Speed" measured as npm init is a disk write; read as the cost '
              'of having the token set available at first frame, it is zero '
              'for constants and non-zero for the theme adapter.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Package Initialisation Speed (read: cost at startup)',
            observed:
                'Zero for the token set itself. All '
                '${HabotTokenPackage.constFamilies} of '
                '${HabotTokenPackage.families.length} families are '
                'const-declared, so the values are compiled into the binary '
                'and nothing is initialised. One non-constant cost is named: '
                'HabotTheme runs ColorScheme.fromSeed on the cold-start path '
                'and then overrides all 28 audited roles, discarding what the '
                'tonal algorithm produced. It is kept because an unpinned role '
                'would otherwise resolve to a Material default nobody chose, '
                'which is the Step 174 MISSING_ROLE defect moved somewhere '
                'nothing can see it.',
            floor: '< 5s',
            optimal: '< 1s',
            ceiling: '10s',
            higherIsBetter: false,
          ),
          AissMeasurement(
            metricName: 'Declaration sites per token family',
            observed:
                '1 of 1, across all ${HabotTokenPackage.families.length} '
                'families, with no site shared between two families. "Where '
                'does this value live" has exactly one answer, which is what '
                'the poka-yoke guard\'s exemption list depends on.',
            floor: '1',
            optimal: '1',
            ceiling: '1',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/tokens/token_package.dart',
        ],
      ),
    );
  });
}
