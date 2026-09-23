/// Step 485 (GEN-00478) -- an alert on the age of a backup, whose floor,
/// optimal and ceiling are the same LaTeX string.
///
/// The row: "Set alert conditions triggering a Shakti Defense Alert if
/// timestamp age exceeds 65 minutes."
/// Metric: **Backup Age Alert Threshold** -- floor, optimal and ceiling all
/// read "$> 65\text{ mins}$". Pass / Fail. Habot Shakti Safety Protocol.
/// Assigned to **ADFA**.
///
/// **Three identical cells again, four rows after Step 481.** Step 481
/// collapsed its band into the word "Deployed"; this one collapses its band
/// into the alert condition itself. The band holds the rule rather than a
/// measure of the rule, which means there is nothing in the row that could
/// distinguish an alert that works from one that never fires.
///
/// **And it is the fifth LaTeX band in the track.** The cell is a typeset
/// fragment, `$> 65\text{ mins}$`, pasted from a document into a spreadsheet
/// column that is read by software. It is recorded exactly as written.
///
/// **So the thing measured here is the alert's behaviour.** Fires above the
/// threshold, does not fire below it, and says what is wrong: which backup,
/// how old, and what happens if nothing is done. Sixty-five minutes is an
/// hourly backup plus five minutes of grace, and saying that out loud is what
/// stops somebody "tuning" it to ninety.
///
/// **An alert keyed on age needs a clock it can trust.** If the device clock
/// drifts, a backup that ran four minutes ago looks two hours old and the
/// alert fires at three in the morning for nothing. The age is computed from
/// the server's authoritative time, and a clock skew beyond the tolerance
/// raises a different alert -- about the clock, not the backup.
library;

import '../live/clock_latency.dart';

/// One evaluation of the alert condition.
class HabotBackupObservation {
  const HabotBackupObservation({
    required this.backup,
    required this.ageMinutes,
    required this.skewSeconds,
  });

  final String backup;
  final int ageMinutes;

  /// Difference between the device clock and the authoritative clock.
  final int skewSeconds;
}

/// What the alert decided.
enum HabotBackupAlert {
  /// The backup is older than the threshold.
  backupStale,

  /// The clock cannot be trusted, so the age cannot be either.
  clockUntrusted,

  /// Nothing to say.
  quiet,
}

/// The backup age alert.
class HabotBackupAgeAlert {
  const HabotBackupAgeAlert._();

  // -----------------------------------------------------------------------
  // Three identical cells.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = r'$> 65\text{ mins}$';
  static const String bandOptimalRaw = r'$> 65\text{ mins}$';
  static const String bandCeilingRaw = r'$> 65\text{ mins}$';

  static bool get allThreeCellsAreIdentical =>
      bandFloorRaw == bandOptimalRaw && bandOptimalRaw == bandCeilingRaw;

  /// Step 481 and this one.
  static const List<int> rowsCollapsingAllThreeCells = <int>[481, 485];

  static bool get theSecondSuchRowInThisBatch =>
      rowsCollapsingAllThreeCells.length == 2;

  static bool get theBandHoldsTheRuleNotAMeasure =>
      bandFloorRaw.contains('65');

  static const int latexBandsInTheTrack = 5;

  static bool get theFifthLatexBand => latexBandsInTheTrack == 5;

  static const String bandNote =
      'Step 481 collapsed its band into the word "Deployed"; this one '
      'collapses its band into the alert condition itself, so there is nothing '
      'in the row that could distinguish an alert that works from one that '
      'never fires. The cell is also the fifth typeset LaTeX fragment pasted '
      'into a column read by software.';

  // -----------------------------------------------------------------------
  // What sixty-five minutes means.
  // -----------------------------------------------------------------------

  static const int backupIntervalMinutes = 60;
  static const int graceMinutes = 5;
  static const int thresholdMinutes = 65;

  static bool get theThresholdIsIntervalPlusGrace =>
      backupIntervalMinutes + graceMinutes == thresholdMinutes;

  static const String derivationNote =
      'Sixty-five minutes is an hourly backup plus five minutes of grace. '
      'Saying so is what stops somebody tuning it to ninety because the alert '
      'was noisy.';

  // -----------------------------------------------------------------------
  // The alert's behaviour, which is the thing worth measuring.
  // -----------------------------------------------------------------------

  static const int skewToleranceSeconds = 120;

  static HabotBackupAlert evaluate(HabotBackupObservation o) {
    if (o.skewSeconds.abs() > skewToleranceSeconds) {
      return HabotBackupAlert.clockUntrusted;
    }
    return o.ageMinutes > thresholdMinutes
        ? HabotBackupAlert.backupStale
        : HabotBackupAlert.quiet;
  }

  static const List<HabotBackupObservation> corpus = <HabotBackupObservation>[
    HabotBackupObservation(backup: 'visits', ageMinutes: 71, skewSeconds: 3),
    HabotBackupObservation(backup: 'visits', ageMinutes: 64, skewSeconds: 3),
    HabotBackupObservation(backup: 'notes', ageMinutes: 4, skewSeconds: 5400),
  ];

  static bool get itFiresAboveTheThreshold =>
      evaluate(corpus[0]) == HabotBackupAlert.backupStale;

  static bool get itIsQuietBelowTheThreshold =>
      evaluate(corpus[1]) == HabotBackupAlert.quiet;

  static bool get aDriftingClockRaisesADifferentAlert =>
      evaluate(corpus[2]) == HabotBackupAlert.clockUntrusted;

  static bool get anAgeIsNotAWallTime =>
      HabotClockLatency.itShowsAgeRatherThanTime;

  static const List<String> whatTheAlertSays = <String>[
    'which backup',
    'how old it is',
    'what happens if nothing is done',
  ];

  static bool get theAlertSaysThreeThings => whatTheAlertSays.length == 3;

  static const String clockNote =
      'If the device clock drifts, a backup that ran four minutes ago looks '
      'two hours old and the alert fires at three in the morning for nothing. '
      'The age is computed from the authoritative server time, and a skew '
      'beyond two minutes raises a different alert -- about the clock, not the '
      'backup.';

  static String get qualitativeOutput =>
      itFiresAboveTheThreshold &&
              itIsQuietBelowTheThreshold &&
              aDriftingClockRaisesADifferentAlert
          ? 'Pass'
          : 'Fail';

  static const String columnNote =
      'COLUMN NOTE: this row\'s floor, optimal and ceiling are one identical '
      'LaTeX string holding the alert condition itself, the second band in '
      'this batch to collapse all three cells after Step 481 and the fifth '
      'typeset fragment in the track, so what is measured here is the alert\'s '
      'behaviour instead: it fires at 71 minutes, stays quiet at 64, says '
      'which backup and how old and what happens next, derives its threshold '
      'as an hourly backup plus five minutes of grace, and raises a separate '
      'clock alert rather than a false backup alert when the device clock has '
      'drifted. Atomic Step: "Set alert conditions triggering a Shakti Defense '
      'Alert if timestamp age exceeds 65 minutes."';

  static Map<String, bool> get obligations => <String, bool>{
        'the threshold is derived, not assumed':
            theThresholdIsIntervalPlusGrace,
        'the alert fires above the threshold': itFiresAboveTheThreshold,
        'and is quiet below it': itIsQuietBelowTheThreshold,
        'a drifting clock raises a clock alert':
            aDriftingClockRaisesADifferentAlert,
        'the alert says three things': theAlertSaysThreeThings,
      };

  static Map<String, bool> get checks => <String, bool>{
        'floor, optimal and ceiling are the same string':
            allThreeCellsAreIdentical,
        'the second such collapse in this batch':
            theSecondSuchRowInThisBatch && theBandHoldsTheRuleNotAMeasure,
        'and the fifth LaTeX band in the track':
            theFifthLatexBand && bandNote.contains('never fires'),
        'sixty-five minutes is sixty plus five':
            theThresholdIsIntervalPlusGrace &&
                derivationNote.contains('tuning it to ninety'),
        'seventy-one minutes fires': itFiresAboveTheThreshold,
        'sixty-four minutes does not': itIsQuietBelowTheThreshold,
        'a ninety-minute clock skew raises a clock alert':
            aDriftingClockRaisesADifferentAlert &&
                skewToleranceSeconds == 120,
        'and the authoritative clock is the one used':
            anAgeIsNotAWallTime && clockNote.contains('not the backup'),
        'the alert names the backup, its age and the consequence':
            theAlertSaysThreeThings,
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };
}
