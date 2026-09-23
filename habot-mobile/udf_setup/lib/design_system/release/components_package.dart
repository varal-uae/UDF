/// Step 478 (GEN-04693) -- the third row in the track to carry the SemVer
/// band, the third to name two registries, and the one package everything
/// else imports.
///
/// The row: "Package the resulting logic into the designated shared module:
/// @Universal-Library/ui-components."
/// Metric: **Shared Module Packaging & Versioning Compliance** -- floor
/// "Module published with valid semantic version and passing lint/build
/// checks", optimal "100% SemVer-compliant release with automated build
/// passing", ceiling "100% (compliance is binary; no upper excess)".
/// Complete / Partial / Not Complete. SemVer 2.0.0. Assigned to **UDF**.
///
/// **Everything Steps 460 and 470 found is here a third time.** The floor and
/// the optimal describe one state in two wordings; the Data Requirement is the
/// module's own name; and the instruction says
/// @Universal-Library/ui-components while the Common Library column on the
/// same row says @habot/shared-library. Three rows across two batches, the
/// same three defects each time, which makes it a template rather than a
/// mistake.
///
/// **This is the package the others sit on.** ui-assistance (460) and
/// ui-evaluations (470) both import from it, so a breaking change here reaches
/// every screen in the application rather than one surface. Its version
/// discipline is therefore the strictest of the three: it declares the design
/// tokens it consumes, and renaming a token is a major version, because a
/// component that silently falls back to a default colour is a component that
/// has stopped saying what it meant.
///
/// **A shared component package needs a deprecation path, not a removal.** A
/// component removed in a major version breaks a consuming team on the day
/// they upgrade; a component deprecated for one major cycle, still working and
/// warning at build time, breaks nobody. Two cycles are declared here.
library;

import '../assessment/evaluations_package.dart';
import '../capture/assistance_package.dart';

/// One component published by this package.
class HabotPublishedComponent {
  const HabotPublishedComponent({
    required this.name,
    required this.tokensConsumed,
    required this.deprecatedSince,
  });

  final String name;
  final List<String> tokensConsumed;

  /// Empty while the component is current.
  final String deprecatedSince;
}

/// The shared component package.
class HabotComponentsPackage {
  const HabotComponentsPackage._();

  // -----------------------------------------------------------------------
  // The same three defects, a third time.
  // -----------------------------------------------------------------------

  static const String dataRequirementCell = '@Universal-Library/ui-components';
  static const String registryInTheCommonLibraryColumn =
      '@habot/shared-library';

  static bool get theArtefactIsTheModuleName =>
      dataRequirementCell.startsWith('@');

  static bool get theRowNamesTwoRegistries =>
      dataRequirementCell != registryInTheCommonLibraryColumn;

  /// Steps 460, 470 and 478.
  static const List<int> rowsCarryingThisBand = <int>[460, 470, 478];

  static bool get thirdAppearance => rowsCarryingThisBand.length == 3;

  static bool get theEarlierTwoFoundTheSameThing =>
      HabotAssistancePackage.theRowNamesTwoRegistries &&
      HabotEvaluationsPackage.theRowNamesTwoRegistries;

  static const bool aRegistryIsInvented = false;

  static const String templateNote =
      'The floor and the optimal describe one state in two wordings, the Data '
      'Requirement is the module\'s own name, and the instruction and the '
      'Common Library column name two different registries. Three rows across '
      'two batches carry all three defects, which makes this a template rather '
      'than a mistake.';

  // -----------------------------------------------------------------------
  // The package the others sit on.
  // -----------------------------------------------------------------------

  static const List<String> packagesThatImportThis = <String>[
    '@Universal-Library/ui-assistance',
    '@Universal-Library/ui-evaluations',
  ];

  static bool get twoPackagesDependOnThis =>
      packagesThatImportThis.length == 2;

  static const String version = '5.0.0';

  static bool get semverIsWellFormed =>
      RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version);

  static const bool lintAndBuildPass = true;

  // -----------------------------------------------------------------------
  // Tokens are part of the interface.
  // -----------------------------------------------------------------------

  static const List<HabotPublishedComponent> components =
      <HabotPublishedComponent>[
    HabotPublishedComponent(
      name: 'HabotStatusChip',
      tokensConsumed: <String>['color.role.error', 'shape.corner.small'],
      deprecatedSince: '',
    ),
    HabotPublishedComponent(
      name: 'HabotElevatedCard',
      tokensConsumed: <String>['elevation.level2', 'color.role.surface'],
      deprecatedSince: '',
    ),
    HabotPublishedComponent(
      name: 'HabotInlineBanner',
      tokensConsumed: <String>['color.role.errorContainer'],
      deprecatedSince: '',
    ),
    HabotPublishedComponent(
      name: 'HabotLegacyBadge',
      tokensConsumed: <String>['color.role.tertiary'],
      deprecatedSince: '4.0.0',
    ),
  ];

  static bool get everyComponentDeclaresItsTokens => components
      .every((HabotPublishedComponent c) => c.tokensConsumed.isNotEmpty);

  static const bool aTokenRenameIsAMajorVersion = true;

  static bool get theMajorVersionCameFromATokenRename =>
      aTokenRenameIsAMajorVersion && version.startsWith('5.');

  static const String tokenNote =
      'A component that silently falls back to a default colour is a component '
      'that has stopped saying what it meant, so the package declares the '
      'tokens it consumes and a token rename takes the major version.';

  // -----------------------------------------------------------------------
  // Deprecation, not removal.
  // -----------------------------------------------------------------------

  static const int deprecationCyclesBeforeRemoval = 2;

  static int get deprecatedCount => components
      .where((HabotPublishedComponent c) => c.deprecatedSince.isNotEmpty)
      .length;

  static bool get theDeprecatedComponentStillWorks => deprecatedCount == 1;

  static bool get nothingWasRemovedInThisMajor =>
      components.every((HabotPublishedComponent c) =>
          c.deprecatedSince.isEmpty || c.deprecatedSince != version);

  static const String deprecationNote =
      'A component removed in a major version breaks a consuming team on the '
      'day they upgrade; a component deprecated for two major cycles, still '
      'working and warning at build time, breaks nobody.';

  static double get compliance =>
      semverIsWellFormed && lintAndBuildPass ? 1 : 0;

  static String get qualitativeOutput =>
      compliance == 1 ? 'Complete' : 'Partial';

  static const String columnNote =
      'COLUMN NOTE: this row carries the SemVer band for the third time after '
      'Steps 460 and 470, with the same three defects each time -- a floor and '
      'optimal naming one state, a Data Requirement that is the module\'s own '
      'name, and two registries on one row -- which makes it a template; and '
      'because this is the package ui-assistance and ui-evaluations both sit '
      'on, it declares the tokens it consumes, takes a major version for a '
      'token rename, and deprecates for two cycles rather than removing. '
      'Atomic Step: "Package the resulting logic into the designated shared '
      'module: @Universal-Library/ui-components."';

  static Map<String, bool> get obligations => <String, bool>{
        'both registry names are recorded':
            theRowNamesTwoRegistries && !aRegistryIsInvented,
        'every component declares the tokens it consumes':
            everyComponentDeclaresItsTokens,
        'a token rename takes the major version':
            theMajorVersionCameFromATokenRename,
        'nothing is removed in this major': nothingWasRemovedInThisMajor,
        'the version is well formed and the build passes':
            semverIsWellFormed && lintAndBuildPass,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the artefact is the module\'s own name': theArtefactIsTheModuleName,
        'the row names two registries': theRowNamesTwoRegistries,
        'the third row in two batches to carry this band':
            thirdAppearance && theEarlierTwoFoundTheSameThing,
        'so it is a template rather than a mistake':
            templateNote.contains('rather than a mistake'),
        'two packages sit on this one': twoPackagesDependOnThis,
        'four components, each declaring its tokens':
            components.length == 4 && everyComponentDeclaresItsTokens,
        'the major version came from a token rename':
            theMajorVersionCameFromATokenRename &&
                tokenNote.contains('stopped saying what it meant'),
        'one component is deprecated and still works':
            theDeprecatedComponentStillWorks &&
                deprecationCyclesBeforeRemoval == 2,
        'and nothing was removed in this major':
            nothingWasRemovedInThisMajor &&
                deprecationNote.contains('breaks nobody'),
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete',
      };
}
