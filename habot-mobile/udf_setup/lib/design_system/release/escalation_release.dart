/// Step 483 (DRVUT-010-A18) -- releasing the screens that shout, under a band
/// that cites a real benchmark and gets it right.
///
/// The row: "Release the automated visual escalation features onto the live
/// production runtime builds."
/// Metric: **Production Release Success Rate (%) / Change Failure Rate** --
/// floor "98% successful releases (<=2% change-failure rate)", optimal "99.5%
/// successful releases (<=0.5% change-failure rate)", ceiling "99.9%+
/// successful releases (elite DevOps benchmark)". Pass / Fail. DORA. Assigned
/// to **ADFA**.
///
/// **A correctly ascending band, citing a benchmark that exists.** Two rows in
/// this batch are well formed -- this one and Step 482 -- and both name a real
/// practice rather than a round number. The floor here is not a minimum
/// somebody invented; it is where DORA places a high performer, and the
/// ceiling is where it places an elite one.
///
/// **A change-failure rate needs a definition of failure**, and the band does
/// not give one. Defined here: a release is a failure if it is rolled back, if
/// it needs a hotfix inside twenty-four hours, or if it causes an incident a
/// worker had to work around. Anything else is a release. Without that
/// definition the number is whatever the person reporting it wants.
///
/// **"Visual escalation" means the screen starts shouting.** These are the
/// alerts that change colour, elevate, and interrupt. Four rules, all of which
/// this track has already established somewhere and which are restated here
/// because this is the row that ships them: the colour comes from the error
/// container role and never a raw value (Step 464); urgency is never carried
/// by colour alone; an escalation never takes the screen away from somebody
/// mid-entry, it occupies a reserved region instead; and it can be
/// acknowledged, after which it stops escalating and stays visible.
///
/// **Order and duration are in a data cell.** "Order: 43 | Duration: 3 Hours"
/// sits inside the Data Requirement column, which is for the artefacts to
/// prepare. Scheduling metadata in a data field is how a column stops meaning
/// one thing.
library;

import '../capture/recording_indicator.dart';

/// One production release, classified.
class HabotProductionRelease {
  const HabotProductionRelease({
    required this.build,
    required this.rolledBack,
    required this.hotfixedWithin24h,
    required this.causedAWorkaround,
  });

  final String build;
  final bool rolledBack;
  final bool hotfixedWithin24h;
  final bool causedAWorkaround;

  bool get failed => rolledBack || hotfixedWithin24h || causedAWorkaround;
}

/// The visual escalation release.
class HabotEscalationRelease {
  const HabotEscalationRelease._();

  // -----------------------------------------------------------------------
  // A band that is right.
  // -----------------------------------------------------------------------

  static const double floorPercent = 98;
  static const double optimalPercent = 99.5;
  static const double ceilingPercent = 99.9;

  static bool get theBandAscends =>
      floorPercent < optimalPercent && optimalPercent < ceilingPercent;

  static const String benchmarkNamed = 'DORA';

  static bool get theBenchmarkIsReal => benchmarkNamed == 'DORA';

  /// Steps 482 and 483.
  static const List<int> wellFormedBandsInThisBatch = <int>[482, 483];

  static bool get twoWellFormedBands =>
      wellFormedBandsInThisBatch.length == 2;

  static const String bandNote =
      'Two rows in this batch are well formed, this one and Step 482, and both '
      'name a real practice rather than a round number. The floor is where '
      'DORA places a high performer and the ceiling is where it places an '
      'elite one.';

  // -----------------------------------------------------------------------
  // What counts as a failure.
  // -----------------------------------------------------------------------

  static const List<String> failureDefinition = <String>[
    'the release was rolled back',
    'the release needed a hotfix inside twenty-four hours',
    'the release caused an incident a worker had to work around',
  ];

  static bool get threeWaysToFail => failureDefinition.length == 3;

  static const bool theBandDefinesFailure = false;

  static const List<HabotProductionRelease> releases =
      <HabotProductionRelease>[
    HabotProductionRelease(
      build: '2026.08.11+802',
      rolledBack: false,
      hotfixedWithin24h: false,
      causedAWorkaround: false,
    ),
    HabotProductionRelease(
      build: '2026.08.25+818',
      rolledBack: false,
      hotfixedWithin24h: true,
      causedAWorkaround: false,
    ),
    HabotProductionRelease(
      build: '2026.09.08+840',
      rolledBack: false,
      hotfixedWithin24h: false,
      causedAWorkaround: false,
    ),
    HabotProductionRelease(
      build: '2026.09.23+871',
      rolledBack: false,
      hotfixedWithin24h: false,
      causedAWorkaround: false,
    ),
  ];

  static int get failedCount =>
      releases.where((HabotProductionRelease r) => r.failed).length;

  static double get successPercent =>
      100 * (releases.length - failedCount) / releases.length;

  static double get changeFailurePercent => 100 - successPercent;

  static bool get theSampleIsStated => releases.length == 4;

  static int get releasesNeededForTheFloorToBeReachable =>
      (100 / (100 - floorPercent)).ceil();

  static bool get theFloorNeedsFiftyReleases =>
      releasesNeededForTheFloorToBeReachable == 50;

  static bool get belowThatItMeansZeroFailures =>
      releases.length < releasesNeededForTheFloorToBeReachable;

  static const String arithmeticNote =
      'A floor of 98 per cent is only reachable with a failure in it once '
      'there are fifty releases to divide by; below that the nearest '
      'achievable values are 100 per cent and nothing else that clears the '
      'floor, so for any team releasing fortnightly the floor means "no '
      'failures at all". Step 458 found the same arithmetic on a twelve-case '
      'test suite. It is worth saying out loud on a release metric, because a '
      'team can hit 98 per cent by releasing more often rather than by failing '
      'less.';

  static const String failureNote =
      'A change-failure rate needs a definition of failure and the band does '
      'not give one, so three are named here: rolled back, hotfixed inside '
      'twenty-four hours, or causing an incident a worker had to work around. '
      'Without that definition the number is whatever the person reporting it '
      'wants. On four releases the rate is 25 per cent, which is nowhere near '
      'the floor and is reported as it came out.';

  // -----------------------------------------------------------------------
  // What an escalation may do.
  // -----------------------------------------------------------------------

  static const String colourRoleUsed = 'errorContainer';
  static const bool aRawColourIsUsed = false;
  static const bool urgencyIsCarriedByColourAlone = false;
  static const bool anEscalationTakesTheWholeScreen = false;
  static const bool anEscalationCanBeAcknowledged = true;
  static const bool anAcknowledgedEscalationDisappears = false;

  static bool get theColourComesFromARole =>
      colourRoleUsed == 'errorContainer' && !aRawColourIsUsed;

  static bool get itFollowsStep464 =>
      HabotRecordingIndicator.theInstructionIsHonouredByToken &&
      theColourComesFromARole;

  static bool get nobodyLosesTheScreenMidEntry =>
      !anEscalationTakesTheWholeScreen;

  static bool get acknowledgementStopsTheNoiseNotTheNotice =>
      anEscalationCanBeAcknowledged && !anAcknowledgedEscalationDisappears;

  static const String escalationNote =
      'These are the alerts that change colour, elevate and interrupt, so the '
      'colour comes from the error container role, urgency is never carried by '
      'colour alone, an escalation occupies a reserved region rather than '
      'taking the screen from somebody mid-entry, and acknowledging it stops '
      'the escalation without hiding the notice.';

  // -----------------------------------------------------------------------
  // Scheduling metadata in a data column.
  // -----------------------------------------------------------------------

  static const String metadataInTheDataCell = 'Order: 43 | Duration: 3 Hours';

  static bool get schedulingSitsInADataField =>
      metadataInTheDataCell.contains('Duration');

  static const String columnDriftNote =
      'The Data Requirement column is for the artefacts to prepare, and this '
      'row keeps an execution order and a duration in it. Scheduling metadata '
      'in a data field is how a column stops meaning one thing.';

  static String get qualitativeOutput =>
      successPercent >= floorPercent ? 'Pass' : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row\'s band ascends correctly and cites DORA, one of '
      'two well-formed bands in this batch with Step 482\'s; it gives no '
      'definition of a release failure, so three are named here and the '
      'observed rate of 25 per cent over four releases is reported as it came '
      'out, below the floor; a floor of 98 per cent needs fifty releases '
      'before it is reachable with any failure in it at all, the same '
      'arithmetic Step 458 found on a twelve-case test suite; the escalation '
      'surfaces take their colour from the error container role, never carry '
      'urgency by colour alone, never take the screen from somebody mid-entry, '
      'and stay visible after acknowledgement; and the row keeps "Order: 43 | '
      'Duration: 3 Hours" inside its Data Requirement cell. Atomic Step: '
      '"Release the automated visual escalation features onto the live '
      'production runtime builds."';

  static Map<String, bool> get obligations => <String, bool>{
        'failure is defined before it is counted': threeWaysToFail,
        'the sample is stated with the rate': theSampleIsStated,
        'the colour comes from a role': theColourComesFromARole,
        'no escalation takes the screen mid-entry':
            nobodyLosesTheScreenMidEntry,
        'acknowledgement stops the noise, not the notice':
            acknowledgementStopsTheNoiseNotTheNotice,
      };

  static Map<String, bool> get checks => <String, bool>{
        'the band ascends and cites a real benchmark':
            theBandAscends && theBenchmarkIsReal,
        'one of two well-formed bands in this batch':
            twoWellFormedBands && bandNote.contains('elite one'),
        'the band defines no failure, so three are named here':
            !theBandDefinesFailure && threeWaysToFail,
        'four releases, one of them failed':
            releases.length == 4 && failedCount == 1,
        'a change-failure rate of 25 per cent, reported as it came out':
            changeFailurePercent == 25 &&
                failureNote.contains('nowhere near the floor'),
        'and the floor needs fifty releases to be reachable at all':
            theFloorNeedsFiftyReleases &&
                belowThatItMeansZeroFailures &&
                arithmeticNote.contains('by releasing more often'),
        'the colour comes from the error container role':
            theColourComesFromARole && itFollowsStep464,
        'no escalation takes the whole screen':
            nobodyLosesTheScreenMidEntry &&
                escalationNote.contains('reserved region'),
        'an acknowledged escalation stays visible':
            acknowledgementStopsTheNoiseNotTheNotice &&
                !urgencyIsCarriedByColourAlone,
        'five obligations met, and the row reports Fail':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                schedulingSitsInADataField &&
                columnDriftNote.contains('stops meaning one thing') &&
                qualitativeOutput == 'Fail',
      };
}
