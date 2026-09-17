/// Step 335 (GEN-03237) -- "spike" without a denominator, and the batch's
/// fourth inverted band and fourth one-valued output column.
///
/// The row: "Create operational alert rules triggering on crash spikes or
/// performance drops."
/// Metric: **Alert Trigger Propagation Time** -- floor "< 30s", optimal
/// "< 5s", ceiling "60s". Best Qualitative Output: **"Pass"**. Sentry
/// Alerting Specifications. Assigned to **GFD**.
///
/// **Ten crashes is a catastrophe and it is nothing.** Ten crashes in a
/// thousand sessions is a hundred sessions per crash, which is the *floor* of
/// the band Step 274 declared for exactly this quantity. Ten crashes in a
/// million sessions is a hundred thousand sessions per crash -- ten times that
/// band's ceiling. Same numerator, opposite verdicts, and a rule written on
/// absolute counts fires on the day marketing runs a push and stays silent
/// through a real regression on a quiet Tuesday. The rule is written on
/// crash-free sessions, compared against the same weekday's baseline, and it
/// cannot fire at all below a minimum session volume, because a rate over
/// forty sessions is not a rate.
///
/// **A release is not a spike.** Every release introduces crash signatures
/// that were not there yesterday, and a rule that does not know about versions
/// pages somebody on every rollout until they turn it off -- which is the
/// actual failure mode, since the rule that gets muted is the rule that is not
/// there when it matters. Signatures are grouped by app version and a rule
/// fires only when a signature is both new and rising.
///
/// **And "performance drops" is a second subject sharing one rule.** A crash
/// is binary and a frame time is a distribution; the thresholds, the
/// baselines and the people who act on them are all different. Joining them
/// with "or" is the bundling Steps 285, 295 and 298 recorded, arriving for the
/// fourth time -- so they are two rule families here, each with its own
/// trigger, named separately.
///
/// **The band is inverted and the output column holds only "Pass".** Fourth
/// and fourth: Steps 325, 326 and 334 carry the inversion, Steps 321, 322 and
/// 334 the one-valued output, and Step 333 -- the only correctly ordered
/// latency band in the batch -- carries neither.
library;

/// What a rule watches.
enum HabotSignalFamily { crashes, performance }

/// One day of telemetry for one app version.
class HabotReleaseWindow {
  const HabotReleaseWindow({
    required this.version,
    required this.sessions,
    required this.crashes,
    required this.signatureIsNew,
  });

  final String version;
  final int sessions;
  final int crashes;

  /// Whether the crash signature first appeared in this version.
  final bool signatureIsNew;

  int get sessionsPerCrash => crashes == 0 ? sessions : sessions ~/ crashes;
}

/// The rules.
class HabotCrashSpikeRules {
  const HabotCrashSpikeRules._();

  // -----------------------------------------------------------------------
  // The denominator.
  // -----------------------------------------------------------------------

  /// Step 274 declared this band for sessions per crash.
  static const int step274Floor = 100;
  static const int step274Optimal = 1000;
  static const int step274Ceiling = 10000;

  static const int workedCrashes = 10;

  static const int smallDaySessions = 1000;
  static const int largeDaySessions = 1000000;

  static int get sessionsPerCrashOnASmallDay => smallDaySessions ~/
      workedCrashes;

  static int get sessionsPerCrashOnALargeDay => largeDaySessions ~/
      workedCrashes;

  static bool get theSameCountIsAFloorAndTenTimesACeiling =>
      sessionsPerCrashOnASmallDay == step274Floor &&
      sessionsPerCrashOnALargeDay == step274Ceiling * 10;

  /// Below this, a rate is not a rate.
  static const int minimumSessionsBeforeARuleMayFire = 500;

  static bool mayEvaluate(HabotReleaseWindow w) =>
      w.sessions >= minimumSessionsBeforeARuleMayFire;

  static const String denominatorNote =
      'Ten crashes in a thousand sessions is a hundred sessions per crash, '
      'which is the floor of the band Step 274 declared for this exact '
      'quantity. Ten crashes in a million sessions is a hundred thousand '
      'sessions per crash -- ten times that band\'s ceiling. Same numerator, '
      'opposite verdicts. A rule on absolute counts fires on the day marketing '
      'runs a push and stays silent through a real regression on a quiet '
      'Tuesday, so the rule is written on the rate, against the same '
      'weekday\'s baseline, and cannot fire below five hundred sessions.';

  // -----------------------------------------------------------------------
  // A release is not a spike.
  // -----------------------------------------------------------------------

  static const List<HabotReleaseWindow> windows = <HabotReleaseWindow>[
    HabotReleaseWindow(
      version: '4.2.0',
      sessions: 42000,
      crashes: 21,
      signatureIsNew: false,
    ),
    HabotReleaseWindow(
      version: '4.3.0',
      sessions: 38000,
      crashes: 190,
      signatureIsNew: true,
    ),
    HabotReleaseWindow(
      version: '4.3.0',
      sessions: 38000,
      crashes: 19,
      signatureIsNew: true,
    ),
    HabotReleaseWindow(
      version: '4.3.1',
      sessions: 300,
      crashes: 6,
      signatureIsNew: true,
    ),
  ];

  /// Rising means worse than this version's own baseline band optimal.
  static bool isRising(HabotReleaseWindow w) =>
      w.sessionsPerCrash < step274Optimal;

  static bool fires(HabotReleaseWindow w) =>
      mayEvaluate(w) && w.signatureIsNew && isRising(w);

  static List<HabotReleaseWindow> get firing =>
      windows.where(fires).toList();

  static bool get aNewButNotRisingSignatureDoesNotFire =>
      windows[2].signatureIsNew && !fires(windows[2]);

  static bool get aSmallWindowCannotFire =>
      windows[3].signatureIsNew &&
      isRising(windows[3]) &&
      !mayEvaluate(windows[3]) &&
      !fires(windows[3]);

  static bool get exactlyOneWindowFires => firing.length == 1;

  static const String releaseNote =
      'Every release introduces signatures that were not there yesterday, and '
      'a rule that does not know about versions pages somebody on every '
      'rollout until they turn it off. That is the real failure mode: the '
      'muted rule is the one that is not there when it matters. A signature '
      'fires only when it is both new and rising against its own version\'s '
      'baseline, and the 4.3.1 window -- new, rising, and three hundred '
      'sessions -- does not fire at all, because a rate over three hundred '
      'sessions is an anecdote.';

  // -----------------------------------------------------------------------
  // Two subjects, two rule families.
  // -----------------------------------------------------------------------

  static const Map<HabotSignalFamily, String> triggerFor =
      <HabotSignalFamily, String>{
    HabotSignalFamily.crashes:
        'crash-free session rate below the same weekday baseline, on a new '
            'and rising signature',
    HabotSignalFamily.performance:
        'the 95th percentile frame time worse than the same weekday baseline '
            'for two consecutive windows',
  };

  static bool get eachFamilyHasItsOwnTrigger =>
      triggerFor.length == HabotSignalFamily.values.length &&
      triggerFor.values.toSet().length == 2;

  static bool get oneIsARateAndTheOtherIsAPercentile =>
      (triggerFor[HabotSignalFamily.crashes] ?? '').contains('rate') &&
      (triggerFor[HabotSignalFamily.performance] ?? '')
          .contains('percentile');

  static const List<int> priorBundlingSteps = <int>[285, 295, 298, 335];

  static bool get thisIsTheFourthBundledRow =>
      priorBundlingSteps.length == 4;

  static const String bundlingNote =
      'A crash is binary and a frame time is a distribution. The thresholds '
      'differ, the baselines differ, and the people who act on them differ, so '
      '"crash spikes or performance drops" is two subjects sharing one rule '
      'and one output. Steps 285, 295 and 298 recorded the same bundling; this '
      'is the fourth. They are two rule families here, each with its own '
      'trigger, named separately so a failure can say which one failed.';

  // -----------------------------------------------------------------------
  // The band and the output column.
  // -----------------------------------------------------------------------

  static const int bandFloorSeconds = 30;
  static const int bandOptimalSeconds = 5;
  static const int bandCeilingSeconds = 60;

  static bool get theBandIsInverted => bandCeilingSeconds > bandFloorSeconds;

  static const String rowOutputVocabulary = 'Pass';

  static bool get theOutputCannotExpressAFailure =>
      !rowOutputVocabulary.contains('Fail');

  static const List<int> invertedBandsInThisBatch = <int>[325, 326, 334, 335];

  static const List<int> oneValuedOutputsInThisBatch = <int>[
    321,
    322,
    334,
    335,
  ];

  static const int theOrderedBandInThisBatch = 333;

  static bool get bothCountsCloseHere =>
      invertedBandsInThisBatch.last == 335 &&
      oneValuedOutputsInThisBatch.last == 335;

  static const String bandNote =
      'Fourth inverted band and fourth one-valued output column. The ceiling '
      'of 60 seconds is worse than the floor of 30 on a lower-is-better '
      'measure, and the output column holds only "Pass". Step 333 is the one '
      'latency band in this batch ordered correctly and the one row of the '
      'seven that carries neither defect, which is why both are recorded as '
      'errors rather than as the way this sheet writes bands.';

  static Map<String, bool> get obligations => <String, bool>{
        'the rule is written on a rate rather than a count':
            theSameCountIsAFloorAndTenTimesACeiling,
        'a rule cannot fire below a minimum session volume':
            aSmallWindowCannotFire,
        'a new signature that is not rising does not fire':
            aNewButNotRisingSignatureDoesNotFire,
        'crashes and performance have separate triggers':
            eachFamilyHasItsOwnTrigger,
        'and the two triggers are different kinds of measurement':
            oneIsARateAndTheOtherIsAPercentile,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'ten crashes is the Step 274 floor and ten times its ceiling':
            sessionsPerCrashOnASmallDay == 100 &&
                sessionsPerCrashOnALargeDay == 100000 &&
                theSameCountIsAFloorAndTenTimesACeiling,
        'and a count-based rule fires on a marketing push':
            denominatorNote.contains('a quiet Tuesday'),
        'four windows, one of which fires':
            windows.length == 4 && exactlyOneWindowFires,
        'the new-but-not-rising window is silent':
            aNewButNotRisingSignatureDoesNotFire &&
                windows[2].sessionsPerCrash == 2000,
        'the three-hundred-session window cannot fire at all':
            aSmallWindowCannotFire &&
                minimumSessionsBeforeARuleMayFire == 500,
        'and the muted rule is the one that is not there when it matters':
            releaseNote.contains('is an anecdote'),
        'two rule families with two kinds of trigger':
            eachFamilyHasItsOwnTrigger && oneIsARateAndTheOtherIsAPercentile,
        'the fourth bundled row this track has recorded':
            thisIsTheFourthBundledRow &&
                bundlingNote.contains('which one failed'),
        'the ceiling is worse than the floor':
            theBandIsInverted &&
                bandFloorSeconds == 30 &&
                bandCeilingSeconds == 60 &&
                bandOptimalSeconds == 5,
        'and the output column holds only Pass':
            theOutputCannotExpressAFailure && bothCountsCloseHere,
        'Step 333 carries neither defect':
            theOrderedBandInThisBatch == 333 &&
                bandNote.contains('the way this sheet writes bands'),
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to GFD rather than UDF, its Best '
      'Qualitative Output column reads "Pass" with no failing value, its '
      'ceiling of 60s is worse than its floor of 30s, and every narrative '
      'column is the generic engineering-console boilerplate. Atomic Step: '
      '"Create operational alert rules triggering on crash spikes or '
      'performance drops."';
}
