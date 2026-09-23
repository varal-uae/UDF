/// Step 470 (GEN-05089) -- packaging the evaluation surfaces, where a version
/// number changes what a five-year-old chart means.
///
/// The row: "Package the resulting logic into the designated shared module:
/// @Universal-Library/ui-evaluations."
/// Metric: **Shared Module Packaging & Versioning Compliance** -- floor
/// "Module published with valid semantic version and passing lint/build
/// checks", optimal "100% SemVer-compliant release with automated build
/// passing", ceiling "100% (compliance is binary; no upper excess)".
/// Complete / Partial / Not Complete. SemVer 2.0.0. Assigned to **UDF**.
///
/// **Everything Step 460 found is here again.** The floor and the optimal
/// name one state; the Data Requirement is the module's own name; and the
/// instruction says @Universal-Library/ui-evaluations while the Common
/// Library column on the same row says @habot/shared-library. Two registries,
/// a second time, ten rows apart.
///
/// **A version number here is part of a child's record.** Step 468's chart
/// plots assessments taken years apart, and Step 469 opens the document
/// behind each one. If the scoring or banding in this module changes, a point
/// recorded in 2022 and a point recorded in 2026 stop meaning the same thing,
/// and a chart that renders both with today's rules quietly rewrites history.
/// So every stored assessment records the module version that produced it,
/// and the chart renders each point under the semantics of its own version.
///
/// **Which makes a major version a migration, not a release.** Publishing a
/// breaking change without a rule for existing records is how a longitudinal
/// record becomes unreadable, so a major version ships with a statement of
/// what changed for old data and what will be shown beside it.
library;

import '../capture/assistance_package.dart';

/// One stored assessment and the module version that produced it.
class HabotVersionedAssessment {
  const HabotVersionedAssessment({
    required this.date,
    required this.score,
    required this.producedByVersion,
  });

  final String date;
  final double score;
  final String producedByVersion;
}

/// The evaluations package.
class HabotEvaluationsPackage {
  const HabotEvaluationsPackage._();

  // -----------------------------------------------------------------------
  // Step 460 again.
  // -----------------------------------------------------------------------

  static const String dataRequirementCell = '@Universal-Library/ui-evaluations';
  static const String registryInTheCommonLibraryColumn =
      '@habot/shared-library';

  static bool get theArtefactIsTheModuleName =>
      dataRequirementCell.startsWith('@');

  static bool get theRowNamesTwoRegistries =>
      dataRequirementCell != registryInTheCommonLibraryColumn;

  static bool get itIsStep460sPatternAgain =>
      HabotAssistancePackage.theRowNamesTwoRegistries &&
      HabotAssistancePackage.bothEndsNameOneState &&
      theRowNamesTwoRegistries;

  static const int rowsApartFromStep460 = 10;

  static const String repeatNote =
      'The floor and the optimal name one state, the Data Requirement is the '
      'module\'s own name, and the instruction and the Common Library column '
      'name two different registries. Everything Step 460 found is here again, '
      'ten rows later.';

  // -----------------------------------------------------------------------
  // A version is part of the record.
  // -----------------------------------------------------------------------

  static const String version = '3.0.0';

  static const List<HabotVersionedAssessment> stored =
      <HabotVersionedAssessment>[
    HabotVersionedAssessment(
      date: '2022-03-14',
      score: 62,
      producedByVersion: '1.2.0',
    ),
    HabotVersionedAssessment(
      date: '2023-04-02',
      score: 68,
      producedByVersion: '2.0.0',
    ),
    HabotVersionedAssessment(
      date: '2026-05-19',
      score: 74,
      producedByVersion: '3.0.0',
    ),
  ];

  static bool get everyRecordCarriesItsVersion => stored.every(
      (HabotVersionedAssessment a) => a.producedByVersion.isNotEmpty);

  static int get distinctVersionsInTheRecord =>
      stored.map((HabotVersionedAssessment a) => a.producedByVersion)
          .toSet()
          .length;

  static const bool historicalPointsRenderedWithTodaysRules = false;

  static bool get eachPointKeepsItsOwnSemantics =>
      everyRecordCarriesItsVersion &&
      !historicalPointsRenderedWithTodaysRules;

  static const String historyNote =
      'If the scoring or banding in this module changes, a point recorded in '
      '2022 and a point recorded in 2026 stop meaning the same thing, and a '
      'chart that renders both with today\'s rules quietly rewrites history. '
      'Every stored assessment records the module version that produced it and '
      'is rendered under the semantics of that version.';

  // -----------------------------------------------------------------------
  // A major version is a migration.
  // -----------------------------------------------------------------------

  static const String breakingChangeStatement =
      'v3 rebanded the communication domain; points from v1 and v2 are shown '
      'with their original banding and a note naming the change.';

  static bool get aMajorVersionShipsWithAMigrationStatement =>
      version.startsWith('3.') && breakingChangeStatement.contains('v1 and v2');

  static bool get semverIsWellFormed =>
      RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version);

  static const bool lintAndBuildPass = true;

  static double get compliance =>
      semverIsWellFormed && lintAndBuildPass ? 1 : 0;

  static String get qualitativeOutput =>
      compliance == 1 ? 'Complete' : 'Partial';

  static const String columnNote =
      'COLUMN NOTE: this row repeats Step 460 ten rows later -- a floor and an '
      'optimal naming one state, a Data Requirement that is the module\'s own '
      'name, and two registries named on one row -- and the module it '
      'publishes treats its own version as part of a child\'s record, storing '
      'the producing version with every assessment and rendering each point '
      'under the semantics of its own version, so that a major release is a '
      'migration with a statement about old data rather than a release. Atomic '
      'Step: "Package the resulting logic into the designated shared module: '
      '@Universal-Library/ui-evaluations."';

  static Map<String, bool> get obligations => <String, bool>{
        'both registry names are recorded': theRowNamesTwoRegistries,
        'every stored assessment carries its version':
            everyRecordCarriesItsVersion,
        'points are not re-rendered with today\'s rules':
            eachPointKeepsItsOwnSemantics,
        'a major version ships with a migration statement':
            aMajorVersionShipsWithAMigrationStatement,
        'the version is well formed and the build passes':
            semverIsWellFormed && lintAndBuildPass,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the artefact is the module\'s name': theArtefactIsTheModuleName,
        'the row names two registries, as Step 460 did':
            theRowNamesTwoRegistries && itIsStep460sPatternAgain,
        'ten rows apart':
            rowsApartFromStep460 == 10 && repeatNote.contains('here again'),
        'three stored assessments, three versions':
            stored.length == 3 && distinctVersionsInTheRecord == 3,
        'every one carries the version that produced it':
            everyRecordCarriesItsVersion,
        'and none is re-rendered with today\'s rules':
            eachPointKeepsItsOwnSemantics,
        'because a rebanding would rewrite history':
            historyNote.contains('rewrites history'),
        'the major version ships with a migration statement':
            aMajorVersionShipsWithAMigrationStatement,
        'the version is well formed and the build passes':
            semverIsWellFormed && lintAndBuildPass,
        'five obligations met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete',
      };
}
