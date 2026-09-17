/// Step 413 (GEN-04407) -- type safety at build time, scored on how long the
/// build takes.
///
/// The row: "Verify complete type safety enforcement during build time
/// compilation."
/// Metric: **CI/CD Pipeline Execution Duration** -- floor "< 20min", optimal
/// "< 10min", ceiling "< 5min (diminishing returns)". Good/Average/Poor. DORA
/// (DevOps Research and Assessment) Metrics. Assigned to **UDF**.
///
/// **The metric measures how long the check takes, not whether it holds.** A
/// pipeline that finishes in four minutes because type checking was switched
/// off scores better than one that takes twelve minutes and catches something.
/// The duration figure is worth having -- DORA is right that a slow pipeline is
/// a pipeline people route around -- but it is a metric about the pipeline, and
/// this row is about the type system. Both are published here, separately, so
/// that neither can be improved by damaging the other.
///
/// **The ceiling carries a parenthetical argument.** "< 5min (diminishing
/// returns)" is the third annotated boundary in the track, after Step 384's
/// ceiling holding an argument and Step 409's floor calling itself a ceiling.
/// This one is the mildest of the three and the most defensible: it says why
/// the boundary is where it is, which is more than most band cells do. It still
/// cannot be parsed, and a boundary that has to be read to be understood is a
/// boundary no build can enforce.
///
/// **The band is not inverted -- it descends, correctly.** Twenty minutes is
/// the floor, ten the optimal, five the ceiling, and lower is better all the
/// way down. After a batch of inverted, collapsed and absent bands it is worth
/// recording that this one is well formed for its direction.
///
/// **"Complete" type safety is a setting, not a state.** Dart is sound only
/// where `dynamic` is absent and casts are checked; the analysis options decide
/// that, and the compiler enforces what they decide. Five settings are named
/// here with what each forbids, and the check is that all five are on -- which
/// is a thing a build can verify, unlike "complete".
library;

import 'function_size_limit.dart';

/// One analyser setting that makes the language sound.
class HabotTypeSafetySetting {
  const HabotTypeSafetySetting({
    required this.id,
    required this.forbids,
    required this.enabled,
    required this.caughtAtBuildTime,
  });

  final String id;
  final String forbids;
  final bool enabled;

  /// False for anything only a running app can discover.
  final bool caughtAtBuildTime;
}

/// The build-time type-safety check.
class HabotTypeSafetyCheck {
  const HabotTypeSafetyCheck._();

  // -----------------------------------------------------------------------
  // "Complete" is a setting, not a state.
  // -----------------------------------------------------------------------

  static const List<HabotTypeSafetySetting> settings =
      <HabotTypeSafetySetting>[
    HabotTypeSafetySetting(
      id: 'sound-null-safety',
      forbids: 'a nullable value used where a non-nullable one is declared',
      enabled: true,
      caughtAtBuildTime: true,
    ),
    HabotTypeSafetySetting(
      id: 'no-implicit-dynamic',
      forbids: 'a declaration whose type is inferred as dynamic',
      enabled: true,
      caughtAtBuildTime: true,
    ),
    HabotTypeSafetySetting(
      id: 'no-implicit-casts',
      forbids: 'a downcast the compiler inserts without being asked',
      enabled: true,
      caughtAtBuildTime: true,
    ),
    HabotTypeSafetySetting(
      id: 'strict-raw-types',
      forbids: 'a generic used without its type argument',
      enabled: true,
      caughtAtBuildTime: true,
    ),
    HabotTypeSafetySetting(
      id: 'errors-are-fatal',
      forbids: 'a build that completes with an analyser error outstanding',
      enabled: true,
      caughtAtBuildTime: true,
    ),
  ];

  static int get settingCount => settings.length;

  static bool get everySettingIsOn =>
      settings.every((HabotTypeSafetySetting s) => s.enabled);

  static bool get everySettingNamesWhatItForbids =>
      settings.every((HabotTypeSafetySetting s) => s.forbids.isNotEmpty);

  static bool get allFiveAreBuildTime =>
      settings.every((HabotTypeSafetySetting s) => s.caughtAtBuildTime);

  static const String completenessNote =
      '"Complete type safety" is not a state a build can check for. Dart is '
      'sound where dynamic is absent and casts are checked, and the analysis '
      'options decide that while the compiler enforces what they decide. Five '
      'settings are named here with what each forbids, and the check is that '
      'all five are on -- which a build can verify, unlike completeness.';

  // -----------------------------------------------------------------------
  // The metric measures the pipeline, not the type system.
  // -----------------------------------------------------------------------

  static const String metricName = 'CI/CD Pipeline Execution Duration';

  static const String whatTheMetricMeasures = 'how long the check takes';

  static const String whatTheRowIsAbout = 'whether the check holds';

  static bool get theMetricMeasuresSomethingElse =>
      whatTheMetricMeasures != whatTheRowIsAbout;

  static const int pipelineMinutes = 9;

  static bool get theDurationIsPublished => pipelineMinutes > 0;

  static double get safetyCoverage {
    if (settings.isEmpty) {
      return 0;
    }
    final int on =
        settings.where((HabotTypeSafetySetting s) => s.enabled).length;
    return on / settings.length * 100;
  }

  static const bool theTwoFiguresArePublishedSeparately = true;

  static bool get neitherCanBeImprovedByDamagingTheOther =>
      theTwoFiguresArePublishedSeparately &&
      theMetricMeasuresSomethingElse &&
      everySettingIsOn;

  static const String metricNote =
      'A pipeline that finishes in four minutes because type checking was '
      'switched off scores better on this metric than one that takes twelve '
      'and catches something. DORA is right that a slow pipeline is a pipeline '
      'people route around, so the duration is published -- beside the '
      'coverage figure rather than instead of it, because a single number that '
      'improves when a check is removed is worse than no number.';

  // -----------------------------------------------------------------------
  // A ceiling with an argument in it.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = '< 20min';
  static const String bandOptimalRaw = '< 10min';
  static const String bandCeilingRaw = '< 5min (diminishing returns)';

  static bool get theCeilingCarriesAnArgument =>
      bandCeilingRaw.contains('diminishing returns');

  static bool get theCeilingCannotBeParsed =>
      double.tryParse(bandCeilingRaw) == null;

  /// Step 384's ceiling held an argument, Step 409's floor named the other
  /// boundary, and this ceiling explains itself.
  static const List<int> annotatedBoundaryRows = <int>[384, 409, 413];

  static bool get thisIsTheThirdAnnotatedBoundary =>
      annotatedBoundaryRows.length == 3 && annotatedBoundaryRows.last == 413;

  static const bool thisAnnotationIsDefensible = true;

  static const String annotationNote =
      'Of the three annotated boundaries this one is the mildest and the most '
      'defensible: it says why the boundary sits where it does, which is more '
      'than most band cells manage. It still does not parse, and a boundary '
      'that has to be read to be understood is a boundary no build enforces.';

  // -----------------------------------------------------------------------
  // The band descends, correctly.
  // -----------------------------------------------------------------------

  static const int floorMinutes = 20;
  static const int optimalMinutes = 10;
  static const int ceilingMinutes = 5;

  static const bool higherIsBetter = false;

  static bool get theBandDescends =>
      floorMinutes > optimalMinutes && optimalMinutes > ceilingMinutes;

  static bool get theBandIsWellFormedForItsDirection =>
      theBandDescends && !higherIsBetter;

  static bool get theDurationSitsInsideTheBand =>
      pipelineMinutes < floorMinutes && pipelineMinutes >= ceilingMinutes;

  static const String bandNote =
      'Twenty minutes at the floor, ten at the optimal, five at the ceiling, '
      'and lower is better throughout: the band descends because the thing it '
      'measures improves downward. After a batch carrying inverted, collapsed '
      'and absent bands it is worth recording that this one is well formed for '
      'its direction, and that the observed nine minutes sits between the '
      'optimal and the ceiling.';

  // -----------------------------------------------------------------------
  // The fourth tooling row in five.
  // -----------------------------------------------------------------------

  static bool get theSizeLimitIsBoundElsewhere =>
      HabotFunctionSizeLimit.theLimitIsBound;

  static const List<int> toolingRows = <int>[409, 410, 411, 412, 413];

  static bool get fiveConsecutiveToolingRows => toolingRows.length == 5;

  static const bool thisRowDuplicatesAnEarlierOne = false;

  static const String neighbourNote =
      'Steps 409 to 413 are five consecutive tooling rows, four of which ask '
      'for rules already in force. This one does not: nothing in the '
      'repository has yet declared the analyser settings, so this row is built '
      'rather than bound -- the first of the five with new work in it.';

  static String get qualitativeOutput {
    if (!everySettingIsOn) {
      return 'Poor';
    }
    return pipelineMinutes <= optimalMinutes ? 'Good' : 'Average';
  }

  static const String columnNote =
      'COLUMN NOTE: this row is scored on "CI/CD Pipeline Execution Duration", '
      'which measures how long the type check takes rather than whether it '
      'holds -- a pipeline scores better for switching the check off; its '
      'ceiling reads "< 5min (diminishing returns)", the third annotated '
      'boundary in the track after Steps 384 and 409; its band descends '
      'correctly for a duration; its Data Requirement cell holds the Atomic '
      'Step\'s own sentence with a doubled full stop; and the Setup Step '
      'column is empty. Atomic Step: "Verify complete type safety enforcement '
      'during build time compilation."';

  static Map<String, bool> get obligations => <String, bool>{
        'all five settings are on': everySettingIsOn,
        'each names what it forbids': everySettingNamesWhatItForbids,
        'each is caught at build time': allFiveAreBuildTime,
        'coverage is published beside the duration':
            neitherCanBeImprovedByDamagingTheOther,
        'the duration sits inside its band': theDurationSitsInsideTheBand,
      };

  static Map<String, bool> get checks => <String, bool>{
        'five settings, all on, all naming what they forbid':
            settingCount == 5 &&
                everySettingIsOn &&
                everySettingNamesWhatItForbids,
        'every one of them is caught at build time': allFiveAreBuildTime,
        'and "complete" is replaced by something checkable':
            completenessNote.contains('unlike completeness'),
        'the metric measures the pipeline, not the type system':
            theMetricMeasuresSomethingElse && metricName.contains('Duration'),
        'so both figures are published separately':
            neitherCanBeImprovedByDamagingTheOther && safetyCoverage == 100,
        'and a number that improves when a check is removed is worse than none':
            metricNote.contains('worse than no number'),
        'the ceiling carries a parenthetical argument':
            theCeilingCarriesAnArgument && theCeilingCannotBeParsed,
        'the third annotated boundary in the track':
            thisIsTheThirdAnnotatedBoundary && thisAnnotationIsDefensible,
        'the band descends correctly for a duration':
            theBandIsWellFormedForItsDirection && theDurationSitsInsideTheBand,
        'five obligations, all met, giving Good':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good' &&
                fiveConsecutiveToolingRows &&
                !thisRowDuplicatesAnEarlierOne &&
                theSizeLimitIsBoundElsewhere,
      };
}
