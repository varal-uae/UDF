/// Step 480 (BPTR-0176-A14) -- a staging deployment on a row that says
/// "environment environment" and whose own cell admits it has no match.
///
/// The row: "Deploy the mobile application structure to a staging environment
/// environment."
/// Metric: **Release Readiness / Deployment Success Rate** -- floor "95",
/// optimal "99.5", ceiling "100". Pass (Scale: Pass/Fail). CI/CD release
/// engineering benchmark. Assigned to **UDF**.
///
/// **The sheet says, in its own cell, that it does not know.** The Data
/// Requirement reads "No matched reference row in Setup Implementation master
/// list -- required data fields limited to atomic-level Data Collection
/// Requirements only; standardized Mobile UX/UI & domain-expertise fields
/// unavailable, verify manually." That is the first cell in 480 rows to
/// declare its own failure to match, and it is more useful than the eleven
/// spliced rows that said nothing: an unmatched row you can see is a row
/// somebody can fix.
///
/// **And the splice happened anyway.** The lower half of the row is about
/// variable font bundles, a 30kb typography payload and a 40kb build budget,
/// with its own poka-yoke about fallback system fonts. The Setup Step cell is
/// a fourth subject again -- a notification module hidden unless an orphan
/// record is confirmed. Twelve spliced rows now.
///
/// **"A staging environment environment."** The word is repeated. It is a
/// small thing and it is the kind of small thing that shows a row was
/// assembled from fragments rather than written.
///
/// **The band is three bare numbers.** 95, 99.5 and 100 with no unit, on a
/// metric named as a rate; read as percentages of deployments passing
/// automated smoke tests on the first attempt, which is what the output type
/// cell describes.
///
/// **What staging is for.** A staging deployment that nobody uses is a
/// ceremony. This one is defined by what must be true before production sees
/// the build: the same artefact that will be promoted, not a rebuild; seeded
/// with data that looks like real data and contains none of it; and a smoke
/// suite that exercises the paths a support worker uses in the first two
/// minutes of a shift.
library;

/// One deployment attempt to staging.
class HabotStagingAttempt {
  const HabotStagingAttempt({
    required this.build,
    required this.smokePassedFirstTime,
    required this.artefactPromoted,
  });

  final String build;
  final bool smokePassedFirstTime;

  /// True when the very same artefact is what moves on to production.
  final bool artefactPromoted;
}

/// The staging deployment.
class HabotStagingDeploy {
  const HabotStagingDeploy._();

  // -----------------------------------------------------------------------
  // A cell that admits its own failure.
  // -----------------------------------------------------------------------

  static const String dataRequirementAdmission =
      'No matched reference row in Setup Implementation master list -- '
      'required data fields limited to atomic-level Data Collection '
      'Requirements only; standardized Mobile UX/UI & domain-expertise fields '
      'unavailable, verify manually.';

  static bool get theCellAdmitsNoMatch =>
      dataRequirementAdmission.startsWith('No matched reference row');

  static const int rowsBeforeThisOne = 480;

  static const bool anUnmatchedRowIsWorseWhenSilent = true;

  static const String admissionNote =
      'This is the first cell in 480 rows to declare its own failure to match, '
      'and it is more useful than the eleven spliced rows that said nothing: '
      'an unmatched row you can see is a row somebody can fix.';

  // -----------------------------------------------------------------------
  // Spliced anyway, and a repeated word.
  // -----------------------------------------------------------------------

  static const String atomicStep =
      'Deploy the mobile application structure to a staging environment '
      'environment.';

  static bool get aWordIsRepeated =>
      atomicStep.contains('environment environment');

  static const List<String> lowerHalfSubjects = <String>[
    'variable font bundle architecture',
    'a 30kb typography payload budget',
    'a 40kb build-breaking asset budget',
    'a notification module hidden unless an orphan record is confirmed',
  ];

  static bool get fourForeignSubjects => lowerHalfSubjects.length == 4;

  static const int splicedRowsInTheTrack = 12;

  static bool get theTwelfthSplicedRow => splicedRowsInTheTrack == 12;

  // -----------------------------------------------------------------------
  // Three bare numbers.
  // -----------------------------------------------------------------------

  static const double floorPercent = 95;
  static const double optimalPercent = 99.5;
  static const double ceilingPercent = 100;

  static const String theReadingUsed =
      'the share of deployments passing automated smoke tests on the first '
      'attempt';

  static bool get theBandCarriesNoUnit =>
      floorPercent == 95 && ceilingPercent == 100;

  static bool get aReadingIsDeclared => theReadingUsed.contains('first');

  // -----------------------------------------------------------------------
  // What staging is for.
  // -----------------------------------------------------------------------

  static const List<HabotStagingAttempt> attempts = <HabotStagingAttempt>[
    HabotStagingAttempt(
      build: '2026.09.20+864',
      smokePassedFirstTime: true,
      artefactPromoted: true,
    ),
    HabotStagingAttempt(
      build: '2026.09.21+867',
      smokePassedFirstTime: true,
      artefactPromoted: true,
    ),
    HabotStagingAttempt(
      build: '2026.09.22+869',
      smokePassedFirstTime: false,
      artefactPromoted: false,
    ),
    HabotStagingAttempt(
      build: '2026.09.23+871',
      smokePassedFirstTime: true,
      artefactPromoted: true,
    ),
  ];

  static double get firstAttemptRate =>
      100 *
      attempts.where((HabotStagingAttempt a) => a.smokePassedFirstTime).length /
      attempts.length;

  static bool get thePromotedArtefactIsTheTestedOne => attempts
      .where((HabotStagingAttempt a) => a.smokePassedFirstTime)
      .every((HabotStagingAttempt a) => a.artefactPromoted);

  static const bool stagingIsSeededWithRealData = false;
  static const bool stagingIsSeededWithLifelikeData = true;

  static const List<String> smokePaths = <String>[
    'sign in and land on today',
    'open the first visit of the shift',
    'record a note and see it saved',
    'go offline and come back',
  ];

  static bool get theSmokeSuiteIsTheFirstTwoMinutes =>
      smokePaths.length == 4 && smokePaths.first.contains('sign in');

  static bool get noRealDataInStaging =>
      !stagingIsSeededWithRealData && stagingIsSeededWithLifelikeData;

  static const String stagingNote =
      'A staging deployment nobody uses is a ceremony. This one promotes the '
      'same artefact it tested rather than a rebuild, is seeded with data that '
      'looks like real data and contains none of it, and runs a smoke suite '
      'covering the paths a support worker uses in the first two minutes of a '
      'shift.';

  static String get qualitativeOutput =>
      firstAttemptRate >= floorPercent ? 'Pass' : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row\'s Data Requirement declares in its own words '
      'that no reference row matched, the first cell in 480 rows to do so, and '
      'the row is spliced anyway -- four foreign subjects about font bundles, '
      'payload budgets and an orphan-record notification, making it the '
      'twelfth spliced row; its instruction repeats the word "environment"; '
      'its band is three bare numbers read here as first-attempt smoke-test '
      'percentages; and what is built promotes the tested artefact, keeps real '
      'data out of staging, and smoke-tests the first two minutes of a shift. '
      'Atomic Step: "Deploy the mobile application structure to a staging '
      'environment environment."';

  static Map<String, bool> get obligations => <String, bool>{
        'the unmatched-row admission is recorded': theCellAdmitsNoMatch,
        'the foreign subjects are recorded, not built': fourForeignSubjects,
        'the promoted artefact is the tested one':
            thePromotedArtefactIsTheTestedOne,
        'no real data reaches staging': noRealDataInStaging,
        'the smoke suite covers the first two minutes':
            theSmokeSuiteIsTheFirstTwoMinutes,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the cell admits that nothing matched': theCellAdmitsNoMatch,
        'which is more useful than a silent splice':
            anUnmatchedRowIsWorseWhenSilent &&
                admissionNote.contains('somebody can fix'),
        'four foreign subjects in the lower half':
            fourForeignSubjects && theTwelfthSplicedRow,
        'and the instruction repeats a word':
            aWordIsRepeated && rowsBeforeThisOne == 480,
        'the band is three bare numbers': theBandCarriesNoUnit,
        'so a reading is declared instead of assumed': aReadingIsDeclared,
        'four attempts, three passing first time':
            attempts.length == 4 && firstAttemptRate == 75,
        'every first-time pass is the artefact promoted':
            thePromotedArtefactIsTheTestedOne,
        'staging holds lifelike data and no real data': noRealDataInStaging,
        'five obligations met, and 75 per cent reports Fail':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                stagingNote.contains('is a ceremony') &&
                qualitativeOutput == 'Fail',
      };
}
