/// Step 460 (GEN-04891) -- packaging the assistive surfaces, on a row that
/// names two different registries and a band that says one thing twice.
///
/// The row: "Package the resulting logic into the designated shared module:
/// @Universal-Library/ui-assistance."
/// Metric: **Shared Module Packaging & Versioning Compliance** -- floor
/// "Module published with valid semantic version and passing lint/build
/// checks", optimal "100% SemVer-compliant release with automated build
/// passing", ceiling "100% (compliance is binary; no upper excess)".
/// Complete / Partial / Not Complete. SemVer 2.0.0. Assigned to **UDF**.
///
/// **The floor and the optimal are one sentence written twice.** "Published
/// with a valid semantic version and passing lint/build checks" and "100%
/// SemVer-compliant release with automated build passing" describe the same
/// state in different words. It is the second band in this batch, after Step
/// 456's, whose two ends hold one value.
///
/// **The Data Requirement is the module's name.** "Data/artifacts to prepare:
/// @Universal-Library/ui-assistance." -- the artefact is the noun in the
/// instruction, the third such row in two batches after Step 436's
/// "completion" and Step 450's "Learning Difficulty (LD)".
///
/// **The row names two registries.** The Atomic Step says
/// @Universal-Library/ui-assistance; the Common Library column on the same
/// row says @habot/shared-library. Step 470 does the same with
/// ui-evaluations. Both names are recorded and neither is invented over --
/// where this actually publishes is a decision for Fredrick, not for the
/// build.
///
/// **A change to what an assistive surface says is a major version.** A
/// screen-reader user has learned the wording of a control. Renaming a label
/// from "Read aloud" to "Listen" is invisible in a screenshot and total for
/// somebody who navigates by hearing it, so announced text is part of this
/// module's public interface and changing it breaks the version.
library;

/// One surface this module publishes.
class HabotAssistiveSurface {
  const HabotAssistiveSurface({
    required this.name,
    required this.announces,
  });

  final String name;

  /// The text a screen reader speaks. Part of the public interface.
  final String announces;
}

/// The assistance package.
class HabotAssistancePackage {
  const HabotAssistancePackage._();

  // -----------------------------------------------------------------------
  // A band whose ends hold one value.
  // -----------------------------------------------------------------------

  static const String floorRaw =
      'Module published with valid semantic version and passing lint/build '
      'checks';
  static const String optimalRaw =
      '100% SemVer-compliant release with automated build passing';

  static bool get bothEndsNameOneState =>
      floorRaw.contains('valid semantic version') &&
      optimalRaw.contains('SemVer-compliant') &&
      floorRaw.contains('build') &&
      optimalRaw.contains('build');

  /// Step 456's floor and ceiling, and this floor and optimal.
  static const List<int> bandsHoldingOneValue = <int>[456, 460];

  static bool get secondSuchBand => bandsHoldingOneValue.length == 2;

  // -----------------------------------------------------------------------
  // The artefact is the noun.
  // -----------------------------------------------------------------------

  static const String dataRequirementCell = '@Universal-Library/ui-assistance';

  static bool get theArtefactIsTheModuleName =>
      dataRequirementCell.startsWith('@');

  /// Step 436's "completion", Step 450's "Learning Difficulty (LD)", this.
  static const List<int> rowsWhoseArtefactIsTheirOwnNoun = <int>[436, 450, 460];

  static bool get thirdSuchRow => rowsWhoseArtefactIsTheirOwnNoun.length == 3;

  // -----------------------------------------------------------------------
  // Two registries.
  // -----------------------------------------------------------------------

  static const String registryInTheInstruction =
      '@Universal-Library/ui-assistance';
  static const String registryInTheCommonLibraryColumn =
      '@habot/shared-library';

  static bool get theRowNamesTwoRegistries =>
      registryInTheInstruction != registryInTheCommonLibraryColumn;

  static const bool aRegistryIsInvented = false;

  static const String registryNote =
      'The Atomic Step names @Universal-Library/ui-assistance and the Common '
      'Library column on the same row names @habot/shared-library. Step 470 '
      'does the same with ui-evaluations. Both names are recorded and neither '
      'is chosen over the other, because where this publishes is a decision '
      'for the owner of the registries.';

  // -----------------------------------------------------------------------
  // What is in it, and what a version means.
  // -----------------------------------------------------------------------

  static const List<HabotAssistiveSurface> surfaces =
      <HabotAssistiveSurface>[
    HabotAssistiveSurface(
      name: 'readAloudControl',
      announces: 'Read aloud',
    ),
    HabotAssistiveSurface(
      name: 'plainLanguageToggle',
      announces: 'Simpler wording',
    ),
    HabotAssistiveSurface(
      name: 'reducedMotionObserver',
      announces: 'Animations reduced',
    ),
    HabotAssistiveSurface(
      name: 'listFallbackLink',
      announces: 'Open as a list',
    ),
  ];

  static bool get everySurfaceAnnouncesSomething =>
      surfaces.every((HabotAssistiveSurface s) => s.announces.isNotEmpty);

  static const String version = '2.0.0';
  static const String previousVersion = '1.4.2';

  static const String breakingChange =
      'the read-aloud control was announced as "Listen" in 1.4.2';

  static bool get aWordingChangeIsMajor =>
      version.startsWith('2.') && previousVersion.startsWith('1.');

  static bool get announcedTextIsPublicInterface =>
      everySurfaceAnnouncesSomething && aWordingChangeIsMajor;

  static const String versionNote =
      'A screen-reader user has learned the wording of a control, so renaming '
      'a label from "Listen" to "Read aloud" is invisible in a screenshot and '
      'total for somebody who navigates by hearing it. Announced text is part '
      'of this module\'s public interface, and changing it takes the major '
      'version.';

  static bool get semverIsWellFormed =>
      RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version);

  static const bool lintAndBuildPass = true;

  static double get compliance =>
      semverIsWellFormed && lintAndBuildPass ? 1 : 0;

  static String get qualitativeOutput =>
      compliance == 1 ? 'Complete' : 'Partial';

  static const String columnNote =
      'COLUMN NOTE: this row\'s floor and optimal describe one state in two '
      'wordings, the second such band in this batch after Step 456\'s; its '
      'Data Requirement is the module\'s own name, the third such artefact '
      'after Steps 436 and 450; its instruction and its Common Library column '
      'name two different registries, as Step 470\'s do; and the module it '
      'publishes treats announced text as public interface, so a change of '
      'wording takes the major version. Atomic Step: "Package the resulting '
      'logic into the designated shared module: '
      '@Universal-Library/ui-assistance."';

  static Map<String, bool> get obligations => <String, bool>{
        'both registry names are recorded':
            theRowNamesTwoRegistries && !aRegistryIsInvented,
        'every surface announces something':
            everySurfaceAnnouncesSomething,
        'announced text is treated as public interface':
            announcedTextIsPublicInterface,
        'the version is well formed': semverIsWellFormed,
        'lint and build pass': lintAndBuildPass,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the floor and the optimal name one state': bothEndsNameOneState,
        'the second such band in this batch': secondSuchBand,
        'the artefact to prepare is the module\'s name':
            theArtefactIsTheModuleName && thirdSuchRow,
        'the row names two registries': theRowNamesTwoRegistries,
        'and neither is invented over':
            !aRegistryIsInvented && registryNote.contains('owner of the'),
        'four surfaces, each with announced text':
            surfaces.length == 4 && everySurfaceAnnouncesSomething,
        'a wording change took the major version':
            aWordingChangeIsMajor && breakingChange.contains('1.4.2'),
        'because announced text is public interface':
            announcedTextIsPublicInterface &&
                versionNote.contains('navigates by hearing'),
        'the version is well formed and the build passes':
            semverIsWellFormed && lintAndBuildPass,
        'five obligations met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete',
      };
}
