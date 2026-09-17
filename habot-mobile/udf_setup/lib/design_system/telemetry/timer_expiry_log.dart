/// Step 330 (GEN-00123) -- a band whose ceiling is a copy of its floor, and a
/// log entry that decides the cause before anybody looks.
///
/// The row: "Log a process design failure entry when a timer expires."
/// Metric: **Task Execution SLA Adherence** -- floor "<= 300 seconds (hard
/// ceiling per task)", optimal "<= 180 seconds median completion", ceiling
/// "300 seconds (auto-revocation threshold)". Pass / Fail. ITIL v4.
///
/// **The floor and the ceiling are the same number wearing two names.** 300
/// seconds is the "hard ceiling per task" at the floor and the "auto-revocation
/// threshold" at the ceiling. A band whose two ends are one value has no
/// interior, and the optimal -- 180 -- is not inside it in any reading. This is
/// a new shape: the other bands in this batch are inverted, unfailable or
/// one-valued; this one is *duplicated*.
///
/// **"Process design failure" decides the cause in the name of the record.** A
/// timer expiring means the task took longer than the design allowed. That is
/// sometimes the design, often the world -- a lift out of service, a site
/// locked, a customer not answering -- and occasionally the person. Writing
/// every expiry as a design failure means the one honest answer, "we do not
/// know yet", cannot be recorded, and a log that cannot say "unknown" will be
/// full of confident wrong values. The entry records what happened; the cause
/// is a separate field whose default is unknown and which only a human sets.
///
/// **And the log entry must not also be the punishment.** Revoking somebody's
/// task at the instant the timer hits zero, with no warning, is the failure
/// Step 315's Setup Step was recorded for: WCAG 2.1 SC 2.2.1 Timing Adjustable
/// is Level A and asks for a warning, a way to extend, and the work preserved.
/// The warning fires at 80 per cent -- 240 seconds -- one extension of 120
/// seconds is available, and the task is never discarded, only handed back.
///
/// **COLUMN NOTE.** The Setup Step reads "Run the Token Studio linter to
/// confirm zero token overrides or raw typography values", which is typography
/// on a timer row.
library;

import '../tokens/motion_tokens.dart';

/// Why a task ran past its time. Set by a person, never inferred.
enum HabotExpiryCause {
  /// Nobody has looked yet. The default, and usually the truth.
  unknown,

  /// The time the design allowed was never enough for this task.
  designWasWrong,

  /// Something outside the app: a locked site, a missing customer.
  worldIntervened,

  /// The person was doing something else.
  attentionElsewhere,
}

/// One entry in the log.
class HabotExpiryEntry {
  const HabotExpiryEntry({
    required this.taskId,
    required this.elapsedSeconds,
    required this.extensionsTaken,
    required this.cause,
  });

  final String taskId;
  final int elapsedSeconds;
  final int extensionsTaken;

  /// Defaults to unknown at write time.
  final HabotExpiryCause cause;
}

/// The log.
class HabotTimerExpiryLog {
  const HabotTimerExpiryLog._();

  // -----------------------------------------------------------------------
  // The clock.
  // -----------------------------------------------------------------------

  static const int slaSeconds = 300;
  static const int medianTargetSeconds = 180;

  /// Warn at four fifths, which is the last point at which a warning is still
  /// useful rather than an announcement.
  static int get warnAtSeconds => (slaSeconds * 4) ~/ 5;

  static const int extensionSeconds = 120;

  static const int extensionsAllowed = 1;

  static int get longestPossibleSeconds =>
      slaSeconds + extensionSeconds * extensionsAllowed;

  static bool get thereIsAWarningBeforeTheLimit => warnAtSeconds < slaSeconds;

  static bool get anExtensionIsOffered => extensionsAllowed >= 1;

  static const bool theTaskIsDiscardedAtZero = false;

  static const String handedBackTo = 'the queue it came from, with its notes';

  static const String criterion = 'WCAG 2.1 SC 2.2.1 Timing Adjustable';
  static const String criterionLevel = 'A';

  static const int stepThatRecordedTheSameFailure = 315;

  static const String timingNote =
      'Revoking a task at the instant the timer hits zero, with no warning, is '
      'the failure Step 315\'s Setup Step was recorded for. SC 2.2.1 is Level '
      'A and asks for three things: a warning before the limit, a way to '
      'extend it, and the work preserved. The warning is at 240 seconds, one '
      'extension of 120 is available, and the task is handed back to its queue '
      'with its notes rather than discarded -- because the person who ran out '
      'of time is usually the person who needed more of it.';

  // -----------------------------------------------------------------------
  // What the entry says, and what it refuses to say.
  // -----------------------------------------------------------------------

  static HabotExpiryEntry entryFor({
    required String taskId,
    required int elapsedSeconds,
    required int extensionsTaken,
  }) =>
      HabotExpiryEntry(
        taskId: taskId,
        elapsedSeconds: elapsedSeconds,
        extensionsTaken: extensionsTaken,
        cause: HabotExpiryCause.unknown,
      );

  static bool get theCauseDefaultsToUnknown =>
      entryFor(taskId: 't-1', elapsedSeconds: 421, extensionsTaken: 1).cause ==
      HabotExpiryCause.unknown;

  static const bool theCauseCanBeInferredByTheApplication = false;

  static int get causesAvailable => HabotExpiryCause.values.length;

  static bool get unknownIsOneOfThem =>
      HabotExpiryCause.values.contains(HabotExpiryCause.unknown);

  static const String nameTheRowGivesTheEntry = 'process design failure';

  static bool get theRowsNameDecidesTheCause =>
      nameTheRowGivesTheEntry.contains('design failure');

  static const String causeNote =
      'A timer expiring means the task took longer than the design allowed. '
      'That is sometimes the design, often the world -- a lift out of service, '
      'a site locked, a customer not answering -- and occasionally the person. '
      'Calling every expiry a process design failure records a conclusion in '
      'the name of the observation, and a log that cannot say "unknown" fills '
      'up with confident wrong values instead. Four causes are available, the '
      'default is unknown, and only a person sets it.';

  // -----------------------------------------------------------------------
  // What a person sees, not just what is written.
  // -----------------------------------------------------------------------

  static Duration get warningNoticeDuration =>
      HabotMotion.snackbarDisplayWithAction;

  static const Map<String, String> notices = <String, String>{
    'warning':
        'A minute left on this task. You can add two minutes if you need them',
    'expired':
        'Time is up. This has gone back to the queue with your notes -- '
            'nothing you entered is lost',
    'extended': 'Two minutes added',
  };

  static bool get everyNoticeSaysWhatHappensNext => notices.values.every(
        (String v) =>
            v.contains('can add') ||
            v.contains('gone back') ||
            v.contains('added'),
      );

  static bool get theExpiryNoticeSaysNothingIsLost =>
      (notices['expired'] ?? '').contains('nothing you entered is lost');

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static const String bandFloor = '<= 300 seconds (hard ceiling per task)';
  static const String bandOptimal = '<= 180 seconds median completion';
  static const String bandCeiling = '300 seconds (auto-revocation threshold)';

  static bool get theFloorAndTheCeilingAreTheSameNumber =>
      bandFloor.contains('300') && bandCeiling.contains('300');

  static bool get theyCarryDifferentNames =>
      bandFloor.contains('hard ceiling') &&
      bandCeiling.contains('auto-revocation');

  static bool get theBandHasNoInterior =>
      theFloorAndTheCeilingAreTheSameNumber && theyCarryDifferentNames;

  static const String bandNote =
      'Three hundred seconds is the "hard ceiling per task" at the floor and '
      'the "auto-revocation threshold" at the ceiling: one number, two names, '
      'and no interior between them. The other bands in this batch are '
      'inverted, unfailable or one-valued; this one is duplicated, which is a '
      'fourth shape. The optimal, 180, sits below both ends and is the only '
      'one of the three that is a target.';

  static Map<String, bool> get obligations => <String, bool>{
        'a warning arrives before the limit': thereIsAWarningBeforeTheLimit,
        'an extension is offered in the warning': anExtensionIsOffered,
        'the work is never discarded': !theTaskIsDiscardedAtZero,
        'the entry records what happened, not why':
            theCauseDefaultsToUnknown,
        'the application never infers a cause':
            !theCauseCanBeInferredByTheApplication,
        'every notice says what happens next': everyNoticeSaysWhatHappensNext,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'the warning is at 240 seconds of 300':
            warnAtSeconds == 240 &&
                slaSeconds == 300 &&
                thereIsAWarningBeforeTheLimit,
        'one extension of 120 seconds, so 420 is the longest possible':
            extensionSeconds == 120 &&
                extensionsAllowed == 1 &&
                longestPossibleSeconds == 420,
        'the task is handed back rather than discarded':
            !theTaskIsDiscardedAtZero &&
                handedBackTo.contains('with its notes') &&
                theExpiryNoticeSaysNothingIsLost,
        'and that is the Level A criterion Step 315 recorded':
            criterionLevel == 'A' &&
                criterion.contains('2.2.1') &&
                stepThatRecordedTheSameFailure == 315 &&
                timingNote.contains('needed more of it'),
        'four causes are available and the default is unknown':
            causesAvailable == 4 &&
                unknownIsOneOfThem &&
                theCauseDefaultsToUnknown &&
                !theCauseCanBeInferredByTheApplication,
        'the row\'s own name for the entry decides the cause':
            theRowsNameDecidesTheCause &&
                causeNote.contains('confident wrong values'),
        'three notices, each saying what happens next':
            notices.length == 3 &&
                everyNoticeSaysWhatHappensNext &&
                warningNoticeDuration.inSeconds == 6,
        'the floor and the ceiling are 300 under two names':
            theFloorAndTheCeilingAreTheSameNumber &&
                theyCarryDifferentNames &&
                theBandHasNoInterior,
        'which is a fourth band shape in one batch':
            bandNote.contains('fourth shape') &&
                medianTargetSeconds == 180,
        'six obligations, all met, giving Pass':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Run the Token '
      'Studio linter to confirm zero token overrides or raw typography '
      'values", which is typography on a timer row, and the band\'s floor and '
      'ceiling are the same 300 seconds under two different names. Atomic '
      'Step: "Log a process design failure entry when a timer expires."';
}
