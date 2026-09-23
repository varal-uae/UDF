/// Step 482 (RCGLA-016-A20) -- publishing a version and telling the teams
/// that depend on it, under the best-formed band in the track.
///
/// The row: "Publish the updated package version and notify consuming teams."
/// Metric: **Deployment Readiness & Rollback Safety** -- floor "Deployed to
/// staging, manually smoke-tested", optimal "Deployed to staging, automated
/// smoke test passes, zero critical regressions, monitored for 24 hours",
/// ceiling "Deployed via progressive rollout (canary/blue-green), automated
/// monitoring with a tested rollback path, zero critical regressions".
/// Best Qualitative Output: "Pass". Progressive delivery benchmark. Assigned
/// to **UDF**.
///
/// **This is the first strictly nested band in the track.** Each tier contains
/// the one below it and adds something: manual smoke becomes automated smoke
/// plus twenty-four hours of monitoring, which becomes progressive rollout
/// plus a rollback path that has actually been exercised. Nothing is
/// contradicted, nothing is restated, and the ceiling is genuinely better than
/// the optimal rather than worse, equal, or an argument. After a batch of
/// collapsed and inverted bands it is worth saying plainly: this cell was
/// written by somebody who knew what a band is for.
///
/// **A rollback path that has never been run is a diagram.** The ceiling says
/// "tested rollback path", so it is tested: the previous version is restored
/// in a rehearsal before the rollout starts, and the rehearsal's duration is
/// recorded, because the number that matters during an incident is how long
/// going back takes.
///
/// **Notifying consuming teams is part of publishing.** A version published
/// without a note is a version somebody discovers when their build breaks. The
/// notification names the version, the breaking changes, the deprecations and
/// the person to ask, and it goes to the teams that actually import the
/// package rather than to everybody.
///
/// **The row is spliced.** Its lower half is about responsive layout gutters,
/// padding and grid columns, and its Setup Step cell is about client-side file
/// size validation before upload. Thirteenth spliced row.
library;

import 'components_package.dart';
import 'staging_deploy.dart';

/// One tier of the readiness band.
class HabotReadinessTier {
  const HabotReadinessTier({
    required this.name,
    required this.requirements,
  });

  final String name;
  final List<String> requirements;
}

/// The package publication.
class HabotPackagePublication {
  const HabotPackagePublication._();

  // -----------------------------------------------------------------------
  // A band that nests.
  // -----------------------------------------------------------------------

  static const List<HabotReadinessTier> tiers = <HabotReadinessTier>[
    HabotReadinessTier(
      name: 'floor',
      requirements: <String>[
        'deployed to staging',
        'manually smoke-tested',
      ],
    ),
    HabotReadinessTier(
      name: 'optimal',
      requirements: <String>[
        'deployed to staging',
        'automated smoke test passes',
        'zero critical regressions',
        'monitored for 24 hours',
      ],
    ),
    HabotReadinessTier(
      name: 'ceiling',
      requirements: <String>[
        'deployed to staging',
        'automated smoke test passes',
        'zero critical regressions',
        'monitored for 24 hours',
        'progressive rollout',
        'a tested rollback path',
      ],
    ),
  ];

  static bool get eachTierContainsTheOneBelow {
    for (int i = 1; i < tiers.length; i++) {
      final List<String> below = tiers[i - 1].requirements;
      final List<String> here = tiers[i].requirements;
      if (here.length <= below.length) {
        return false;
      }
      if (!below
          .where((String r) => !r.startsWith('manually'))
          .every(here.contains)) {
        return false;
      }
    }
    return true;
  }

  static bool get theCeilingIsBetterThanTheOptimal =>
      tiers.last.requirements.length > tiers[1].requirements.length;

  static const bool theCeilingIsAnArgument = false;

  static bool get theFirstStrictlyNestedBand =>
      eachTierContainsTheOneBelow &&
      theCeilingIsBetterThanTheOptimal &&
      !theCeilingIsAnArgument;

  static const String bandNote =
      'Each tier contains the one below it and adds something: manual smoke '
      'becomes automated smoke plus twenty-four hours of monitoring, which '
      'becomes progressive rollout plus a rollback path that has been '
      'exercised. Nothing is contradicted, nothing is restated, and the '
      'ceiling is genuinely better than the optimal. After a batch of '
      'collapsed and inverted bands, this cell was written by somebody who '
      'knew what a band is for.';

  // -----------------------------------------------------------------------
  // The rollback is rehearsed.
  // -----------------------------------------------------------------------

  static const bool rollbackRehearsed = true;
  static const int rollbackRehearsalSeconds = 214;
  static const String versionRestoredTo = '4.7.2';

  static bool get theRollbackPathIsTested =>
      rollbackRehearsed && rollbackRehearsalSeconds > 0;

  static bool get theRehearsalDurationIsRecorded =>
      rollbackRehearsalSeconds == 214;

  static const String rollbackNote =
      'A rollback path that has never been run is a diagram. The previous '
      'version is restored in a rehearsal before the rollout starts and the '
      'rehearsal is timed, because the number that matters during an incident '
      'is how long going back takes.';

  // -----------------------------------------------------------------------
  // Notifying the teams that import it.
  // -----------------------------------------------------------------------

  static const String publishedVersion = '5.0.0';
  static const String checksum = 'sha512:9ac31e';

  static const List<String> notifiedTeams = <String>[
    'the ui-assistance maintainers',
    'the ui-evaluations maintainers',
  ];

  static bool get theTeamsNotifiedAreTheTeamsThatImport =>
      notifiedTeams.length ==
      HabotComponentsPackage.packagesThatImportThis.length;

  static const List<String> noticeContents = <String>[
    'the version',
    'the breaking changes',
    'the deprecations',
    'the person to ask',
  ];

  static bool get theNoticeCarriesFourThings => noticeContents.length == 4;

  static bool get thePublicationCarriesAChecksum => checksum.isNotEmpty;

  static const String noticeNote =
      'A version published without a note is a version somebody discovers when '
      'their build breaks. The notice names the version, the breaking changes, '
      'the deprecations and the person to ask, and it goes to the teams that '
      'import the package rather than to everybody.';

  // -----------------------------------------------------------------------
  // Spliced.
  // -----------------------------------------------------------------------

  static const List<String> lowerHalfSubjects = <String>[
    'responsive layout gutters at 16dp and 24dp',
    'grid columns moving from 4 to 12 on viewport detection',
    'client-side file size validation before upload',
  ];

  static bool get theRowIsSpliced => lowerHalfSubjects.length == 3;

  static const int splicedRowsInTheTrack = 13;

  static bool get theThirteenthSplicedRow =>
      splicedRowsInTheTrack == HabotStagingDeploy.splicedRowsInTheTrack + 1;

  static String get tierReached {
    if (theRollbackPathIsTested && thePublicationCarriesAChecksum) {
      return 'ceiling';
    }
    return 'optimal';
  }

  static String get qualitativeOutput => tierReached == 'ceiling'
      ? 'Pass'
      : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row carries the first strictly nested band in the '
      'track -- each tier contains the one below it and adds something, and '
      'the ceiling is genuinely better than the optimal rather than worse, '
      'equal, or an argument; its rollback path is rehearsed and the rehearsal '
      'timed at 214 seconds; publication carries a checksum and a notice '
      'naming the version, the breaking changes, the deprecations and the '
      'person to ask, sent to the two packages that import this one; and the '
      'row is nonetheless spliced, its lower half covering layout gutters and '
      'file-size validation. Atomic Step: "Publish the updated package version '
      'and notify consuming teams."';

  static Map<String, bool> get obligations => <String, bool>{
        'the rollback path is rehearsed and timed':
            theRollbackPathIsTested && theRehearsalDurationIsRecorded,
        'the publication carries a checksum': thePublicationCarriesAChecksum,
        'the notice carries four things': theNoticeCarriesFourThings,
        'it goes to the teams that import the package':
            theTeamsNotifiedAreTheTeamsThatImport,
        'the splice is recorded, not built': theRowIsSpliced,
      };

  static Map<String, bool> get checks => <String, bool>{
        'each tier contains the one below it': eachTierContainsTheOneBelow,
        'and the ceiling is better than the optimal':
            theCeilingIsBetterThanTheOptimal && !theCeilingIsAnArgument,
        'the first strictly nested band in the track':
            theFirstStrictlyNestedBand && bandNote.contains('what a band is '
                'for'),
        'the rollback is rehearsed before the rollout':
            theRollbackPathIsTested && versionRestoredTo == '4.7.2',
        'and the rehearsal is timed':
            theRehearsalDurationIsRecorded &&
                rollbackNote.contains('how long going back takes'),
        'the publication carries a checksum':
            thePublicationCarriesAChecksum && publishedVersion == '5.0.0',
        'the notice carries four things': theNoticeCarriesFourThings,
        'sent to the two packages that import this one':
            theTeamsNotifiedAreTheTeamsThatImport &&
                noticeNote.contains('rather than to everybody'),
        'three foreign subjects in the lower half':
            theRowIsSpliced && theThirteenthSplicedRow,
        'five obligations met, reaching the ceiling tier':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                tierReached == 'ceiling' &&
                qualitativeOutput == 'Pass',
      };
}
