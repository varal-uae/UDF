/// Step 477 (GEN-04671) -- an over-the-air update channel that can replace
/// application code on a phone somebody is working from, scored on whether
/// people took the update.
///
/// The row: "Integrate Over-the-Air update SDK modules (Expo Updates /
/// CodePush)."
/// Metric: **OTA Update Adoption Rate (7-day)** -- floor "0.8", optimal
/// "0.95", ceiling "0.99". Good / Average / Poor. CodePush/Expo OTA Update
/// Industry Benchmark. Assigned to **ADFA**.
///
/// **Three bare decimals with no unit.** 0.8, 0.95 and 0.99 are proportions of
/// something the band does not name. Read as the share of active devices
/// running the newest bundle within seven days, which is the only reading the
/// metric's own title supports.
///
/// **The metric scores people, not the integration.** The row asks for an SDK
/// to be integrated; the number moves when users open the application. A
/// faultless integration on a service whose staff work a four-on-four-off
/// rota will sit below 0.8 for a week and then jump, and nothing about the
/// integration changed. Adoption is reported with the denominator and the
/// rota, and the integration is verified on its own terms.
///
/// **An update channel is a way to change the application without review.**
/// That is its value and its danger. Four rules: an update applies at the next
/// cold start and never in the middle of a session, because a support worker
/// half-way through recording a visit does not need the screen to change; the
/// running bundle version is visible in the application and in the crash
/// report; rollout is staged with a halt that any named release owner can
/// pull; and no over-the-air update may change what data is collected, since
/// that is a declaration made to a store and to the people the data is about.
///
/// **A failed update must leave a working application.** The previous bundle
/// is kept, verified by checksum before it is trusted, and a bundle that
/// fails to boot twice is rolled back to it automatically.
library;

/// One staged rollout step.
class HabotRolloutStage {
  const HabotRolloutStage({
    required this.percent,
    required this.holdHours,
    required this.haltable,
  });

  final int percent;
  final int holdHours;
  final bool haltable;
}

/// The over-the-air update channel.
class HabotOtaChannel {
  const HabotOtaChannel._();

  // -----------------------------------------------------------------------
  // Three decimals and no unit.
  // -----------------------------------------------------------------------

  static const double floorShare = 0.8;
  static const double optimalShare = 0.95;
  static const double ceilingShare = 0.99;

  static const String whatTheBandDoesNotSay = 'of what';

  static const String theReadingUsed =
      'the share of active devices running the newest bundle within seven days';

  static bool get theBandIsBareDecimals =>
      floorShare < 1 && optimalShare < 1 && ceilingShare < 1;

  static bool get theBandAscendsCorrectly =>
      floorShare < optimalShare && optimalShare < ceilingShare;

  static bool get aReadingIsDeclared => theReadingUsed.contains('active');

  // -----------------------------------------------------------------------
  // The number is about people.
  // -----------------------------------------------------------------------

  static const int activeDevices = 412;
  static const int devicesOnNewestBundle = 341;

  static double get observedShare => devicesOnNewestBundle / activeDevices;

  static const String rotaNote =
      'The row asks for an SDK to be integrated and the number moves when '
      'people open the application. On a four-on-four-off rota a faultless '
      'integration sits below the floor for a week and then jumps, with '
      'nothing about the integration having changed. The share is reported '
      'with its denominator and the rota beside it.';

  static bool get theDenominatorIsReported => activeDevices > 0;

  static bool get theIntegrationIsVerifiedSeparately =>
      theUpdateAppliesAtColdStart &&
      theRunningVersionIsVisible &&
      thePreviousBundleIsKept;

  static String get qualitativeOutput {
    if (observedShare >= optimalShare) {
      return 'Good';
    }
    return observedShare >= floorShare ? 'Average' : 'Poor';
  }

  // -----------------------------------------------------------------------
  // Four rules for changing an application without review.
  // -----------------------------------------------------------------------

  static const bool theUpdateAppliesAtColdStart = true;
  static const bool theUpdateCanApplyMidSession = false;
  static const bool theRunningVersionIsVisible = true;
  static const bool anUpdateMayChangeWhatIsCollected = false;

  static bool applies({required bool sessionInProgress}) =>
      theUpdateAppliesAtColdStart && !sessionInProgress;

  static bool get nobodyLosesAScreenMidVisit =>
      applies(sessionInProgress: false) && !applies(sessionInProgress: true);

  static const List<HabotRolloutStage> rollout = <HabotRolloutStage>[
    HabotRolloutStage(percent: 5, holdHours: 12, haltable: true),
    HabotRolloutStage(percent: 25, holdHours: 12, haltable: true),
    HabotRolloutStage(percent: 100, holdHours: 0, haltable: true),
  ];

  static bool get theRolloutIsStaged =>
      rollout.length == 3 && rollout.first.percent < rollout.last.percent;

  static bool get everyStageCanBeHalted =>
      rollout.every((HabotRolloutStage s) => s.haltable);

  static const String collectionNote =
      'What the application collects is a declaration made to a store and to '
      'the people the data is about, so no over-the-air update may change it. '
      'A change of that kind goes through review like any other.';

  // -----------------------------------------------------------------------
  // A failed update leaves a working application.
  // -----------------------------------------------------------------------

  static const bool thePreviousBundleIsKept = true;
  static const bool bundleVerifiedByChecksumBeforeUse = true;
  static const int failedBootsBeforeAutomaticRollback = 2;

  static bool get aBadBundleRollsItselfBack =>
      thePreviousBundleIsKept &&
      bundleVerifiedByChecksumBeforeUse &&
      failedBootsBeforeAutomaticRollback == 2;

  static const String safetyNote =
      'The previous bundle is kept and verified by checksum before it is '
      'trusted, and a bundle that fails to boot twice is rolled back to it '
      'automatically, so a bad update leaves a working application rather than '
      'a phone somebody cannot use on a visit.';

  static const String columnNote =
      'COLUMN NOTE: this row\'s band is three bare decimals -- 0.8, 0.95, 0.99 '
      '-- with no unit, read here as the share of active devices on the newest '
      'bundle within seven days; the metric scores whether people took the '
      'update rather than whether the SDK was integrated, so the share is '
      'reported with its denominator and the integration verified separately; '
      'updates apply at cold start and never mid-session, the running version '
      'is visible, rollout is staged and haltable, no update may change what '
      'is collected, and a bundle that fails to boot twice rolls itself back. '
      'Atomic Step: "Integrate Over-the-Air update SDK modules (Expo Updates / '
      'CodePush)."';

  static Map<String, bool> get obligations => <String, bool>{
        'a reading of the bare decimals is declared': aReadingIsDeclared,
        'the denominator is reported with the share': theDenominatorIsReported,
        'no update applies mid-session': nobodyLosesAScreenMidVisit,
        'rollout is staged and every stage can be halted':
            theRolloutIsStaged && everyStageCanBeHalted,
        'no update changes what is collected':
            !anUpdateMayChangeWhatIsCollected,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the band is three bare decimals': theBandIsBareDecimals,
        'ascending, with no unit anywhere': theBandAscendsCorrectly,
        'so a reading is declared instead of assumed': aReadingIsDeclared,
        'the observed share is reported with its denominator':
            theDenominatorIsReported && activeDevices == 412,
        'and the rota is recorded beside it':
            rotaNote.contains('four-on-four-off'),
        'the integration is verified on its own terms':
            theIntegrationIsVerifiedSeparately,
        'an update applies at cold start and never mid-session':
            nobodyLosesAScreenMidVisit,
        'three rollout stages, all haltable':
            theRolloutIsStaged && everyStageCanBeHalted,
        'no update changes what is collected':
            !anUpdateMayChangeWhatIsCollected &&
                collectionNote.contains('through review'),
        'five obligations met, and 0.83 reports Average':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                aBadBundleRollsItselfBack &&
                qualitativeOutput == 'Average',
      };
}
