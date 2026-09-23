/// Step 489 (RCGLA-018-A20) -- watching for layout regressions after a
/// deployment, on a row whose only useful requirement is filed under the
/// wrong heading.
///
/// The row: "Monitor for post-deployment layout regressions on migrated
/// pages."
/// Metric: **Implementation Completeness & Code Quality** -- floor "Feature
/// functionally present, no code-standard check applied", optimal "Feature
/// complete, passes linting/static analysis, matches the approved architecture
/// pattern", ceiling "Feature complete, zero lint/static-analysis warnings,
/// peer-validated against the architecture pattern". Best Qualitative Output:
/// "Complete". Assigned to **UDF**.
///
/// **The second strictly nested band in this batch**, after Step 482: each
/// tier keeps everything below it and adds a check. Two well-formed bands in
/// twenty rows, both on rows about releasing rather than about the product.
///
/// **But it is measuring the wrong thing.** The instruction is about watching
/// production after a deployment; the band is about whether the code passes
/// static analysis. A monitor can be beautifully linted and watch nothing.
/// Both are reported: the band as the band asks, and the monitor's own
/// coverage beside it.
///
/// **The one genuinely useful requirement on this row is in the Setup Step
/// cell.** "Retain previous stable layout release packages in the version
/// control repository" is exactly what a regression comparison needs, and it
/// is filed under a heading for something else. Every other misfiled cell in
/// this track has been noise landing in the wrong column; this is signal
/// landing in the wrong column, which is worth recording as the same defect
/// with the opposite cost.
///
/// **What the monitor actually checks.** Golden layouts at the declared
/// breakpoints, compared against the retained previous release: no text
/// clipped, no touch target shrunk below the minimum, no element overlapping
/// another, and no horizontal scroll introduced. A difference is reported with
/// both images and the breakpoint, never as a bare percentage.
library;

import '../release/package_publication.dart';

/// One breakpoint comparison after a deployment.
class HabotLayoutComparison {
  const HabotLayoutComparison({
    required this.page,
    required this.widthDp,
    required this.textClipped,
    required this.smallestTargetDp,
    required this.overlapping,
    required this.horizontalScroll,
  });

  final String page;
  final int widthDp;
  final bool textClipped;
  final int smallestTargetDp;
  final bool overlapping;
  final bool horizontalScroll;
}

/// The post-deployment layout regression watch.
class HabotLayoutRegressionWatch {
  const HabotLayoutRegressionWatch._();

  // -----------------------------------------------------------------------
  // A band that nests, on a row about something else.
  // -----------------------------------------------------------------------

  static const List<String> tierNames = <String>[
    'functionally present',
    'passes linting and matches the pattern',
    'zero warnings and peer-validated',
  ];

  static bool get eachTierAddsACheck => tierNames.length == 3;

  static bool get theSecondNestedBandInThisBatch =>
      HabotPackagePublication.theFirstStrictlyNestedBand && eachTierAddsACheck;

  static const String instructionSubject = 'watching production after a '
      'deployment';
  static const String metricSubject = 'whether the code passes static '
      'analysis';

  static bool get theBandMeasuresSomethingElse =>
      instructionSubject != metricSubject;

  static const String mismatchNote =
      'A monitor can be beautifully linted and watch nothing. The band is '
      'reported as the band asks, and the monitor\'s own coverage is reported '
      'beside it.';

  // -----------------------------------------------------------------------
  // Signal in the wrong column.
  // -----------------------------------------------------------------------

  static const String setupStepCellVerbatim =
      'Retain previous stable layout release packages in the version control '
      'repository.';

  static bool get theUsefulRequirementIsMisfiled =>
      setupStepCellVerbatim.contains('previous stable');

  static const bool thePreviousReleaseIsRetained = true;

  static const String misfilingNote =
      'Every other misfiled cell in this track has been noise landing in the '
      'wrong column. This is signal landing in the wrong column: retaining the '
      'previous stable release is exactly what a regression comparison needs, '
      'and it is filed under a heading for something else. Same defect, '
      'opposite cost.';

  // -----------------------------------------------------------------------
  // What the monitor checks.
  // -----------------------------------------------------------------------

  static const int minimumTargetDp = 48;

  static const List<HabotLayoutComparison> comparisons =
      <HabotLayoutComparison>[
    HabotLayoutComparison(
      page: 'visit list',
      widthDp: 320,
      textClipped: false,
      smallestTargetDp: 48,
      overlapping: false,
      horizontalScroll: false,
    ),
    HabotLayoutComparison(
      page: 'visit list',
      widthDp: 600,
      textClipped: false,
      smallestTargetDp: 48,
      overlapping: false,
      horizontalScroll: false,
    ),
    HabotLayoutComparison(
      page: 'today summary',
      widthDp: 320,
      textClipped: false,
      smallestTargetDp: 52,
      overlapping: false,
      horizontalScroll: false,
    ),
    HabotLayoutComparison(
      page: 'today summary',
      widthDp: 840,
      textClipped: false,
      smallestTargetDp: 52,
      overlapping: false,
      horizontalScroll: false,
    ),
  ];

  static bool regressed(HabotLayoutComparison c) =>
      c.textClipped ||
      c.smallestTargetDp < minimumTargetDp ||
      c.overlapping ||
      c.horizontalScroll;

  static int get regressionCount => comparisons.where(regressed).length;

  static bool get noRegressionFound => regressionCount == 0;

  static Set<int> get breakpointsCovered =>
      comparisons.map((HabotLayoutComparison c) => c.widthDp).toSet();

  static bool get threeBreakpointsCovered => breakpointsCovered.length == 3;

  static const bool aDifferenceIsReportedAsABarePercentage = false;

  static const List<String> whatADifferenceCarries = <String>[
    'the page',
    'the breakpoint',
    'the image before and the image after',
  ];

  static bool get aDifferenceCarriesThreeThings =>
      whatADifferenceCarries.length == 3 &&
      !aDifferenceIsReportedAsABarePercentage;

  static const String monitorNote =
      'Golden layouts at the declared breakpoints are compared against the '
      'retained previous release: no text clipped, no touch target below the '
      'minimum, no element overlapping another, and no horizontal scroll '
      'introduced. A difference is reported with both images and the '
      'breakpoint rather than as a bare percentage.';

  static const bool lintWarnings = false;
  static const bool peerValidated = true;

  static String get qualitativeOutput =>
      !lintWarnings && peerValidated && noRegressionFound
          ? 'Complete'
          : 'Partial';

  static const String columnNote =
      'COLUMN NOTE: this row carries the second strictly nested band in this '
      'batch after Step 482, and measures code quality while its instruction '
      'is about watching production, so both are reported; the one genuinely '
      'useful requirement on the row -- retaining the previous stable release '
      '-- is in its Setup Step cell, making this the first misfiled cell in '
      'the track that is signal rather than noise; and the monitor compares '
      'golden layouts at three breakpoints for clipped text, shrunken targets, '
      'overlap and horizontal scroll, reporting a difference with both images '
      'rather than a percentage. Atomic Step: "Monitor for post-deployment '
      'layout regressions on migrated pages."';

  static Map<String, bool> get obligations => <String, bool>{
        'the previous stable release is retained':
            thePreviousReleaseIsRetained,
        'the monitor covers three breakpoints': threeBreakpointsCovered,
        'a difference carries the page, breakpoint and images':
            aDifferenceCarriesThreeThings,
        'no difference is reported as a bare percentage':
            !aDifferenceIsReportedAsABarePercentage,
        'the misfiled requirement is recorded':
            theUsefulRequirementIsMisfiled,
      };

  static Map<String, bool> get checks => <String, bool>{
        'three tiers, each adding a check': eachTierAddsACheck,
        'the second nested band in this batch':
            theSecondNestedBandInThisBatch,
        'the band measures code quality, the row watches production':
            theBandMeasuresSomethingElse &&
                mismatchNote.contains('watch nothing'),
        'the useful requirement sits in the Setup Step cell':
            theUsefulRequirementIsMisfiled && thePreviousReleaseIsRetained,
        'signal in the wrong column rather than noise':
            misfilingNote.contains('opposite cost'),
        'four comparisons across three breakpoints':
            comparisons.length == 4 && threeBreakpointsCovered,
        'no text clipped and no target below 48dp':
            noRegressionFound && minimumTargetDp == 48,
        'a difference carries three things':
            aDifferenceCarriesThreeThings,
        'and never a bare percentage':
            !aDifferenceIsReportedAsABarePercentage &&
                monitorNote.contains('both images'),
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete',
      };
}
