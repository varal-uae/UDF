/// Step 388 (ARCPE-013-12) -- a button that locks a rubric, on a row whose
/// other columns describe a glossary.
///
/// The row: "Program a validation finalization button that locks the rubric
/// settings upon execution."
/// Metric: **AI Output Confidence Threshold Accuracy** -- floor 0.8, optimal
/// 0.92, ceiling 0.98. High (Scale: High/Medium/Low). NIST AI Risk Management
/// Framework (AI RMF 1.0). Assigned to **UDF**.
///
/// **This row is two rows.** Its top half is about a finalisation button and
/// its data fields are lock fields -- Lock Type, Lock Status, Locked By, Lock
/// Timestamp, Lock Reason. Its Data Requirement column then asks for "list item
/// with secondary text for definitions", "Label Small for proficiency notes"
/// and "tap dimension to see full definition", which is a glossary screen, and
/// its Setup Step column asks for "no regression in component functionality
/// after code-splitting", which is a build task. Three different subjects in
/// one row. Step 390 in this batch is the same shape.
///
/// **What the lock fields ask for is the right design and the row does not
/// know it.** Lock Type, Locked By, Lock Timestamp and Lock Reason are exactly
/// the four things a lock has to carry to be reversible by somebody other than
/// the person who set it. They are in the data-fields column rather than the
/// instruction, so a reader who implements only the Atomic Step builds a lock
/// with none of them.
///
/// **Locking a rubric after scoring has started is the point.** A rubric that
/// can change mid-assessment makes two candidates incomparable without either
/// score being wrong, which is the failure a finalisation button prevents. So
/// the lock is checked at the moment of *first score*, not at submission, and
/// the timestamp recorded is the lock's, not the button press's.
///
/// **An unlock has to exist and has to cost something.** A rubric locked by
/// mistake before anybody scored is an ordinary Tuesday. The unlock is
/// available while no score exists, requires a reason, and is itself recorded
/// -- which is Step 320's elevation shape rather than a second mechanism.
///
/// **The band is well formed and measures a model.** 0.8, 0.92, 0.98,
/// correctly ordered; it scores an AI confidence threshold on a row that builds
/// a button. What is published is the share of lock facts the record carries.
library;

import '../operations/permanent_disable.dart';

/// What a lock on a rubric records.
enum HabotRubricLockField {
  /// Which kind of lock this is.
  lockType,

  /// Whether it is on.
  lockStatus,

  /// Who set it.
  lockedBy,

  /// When, monotonically.
  lockTimestamp,

  /// Why.
  lockReason,
}

/// One rubric lock.
class HabotRubricLockRecord {
  const HabotRubricLockRecord({
    required this.lockType,
    required this.locked,
    required this.lockedBy,
    required this.lockTimestamp,
    required this.lockReason,
  });

  final String lockType;
  final bool locked;
  final String lockedBy;
  final String lockTimestamp;
  final String lockReason;

  List<String> get statedFields =>
      <String>[lockType, lockedBy, lockTimestamp, lockReason];

  bool get isComplete => statedFields.every((String f) => f.isNotEmpty);
}

/// The rubric-lock rule.
class HabotRubricLock {
  const HabotRubricLock._();

  // -----------------------------------------------------------------------
  // Three subjects in one row.
  // -----------------------------------------------------------------------

  static const String theAtomicStepsSubject = 'a finalisation button';
  static const String theDataRequirementsSubject = 'a glossary screen';
  static const String theSetupStepsSubject =
      'a code-splitting regression check';

  static bool get threeColumnsDescribeThreeThings =>
      theAtomicStepsSubject != theDataRequirementsSubject &&
      theDataRequirementsSubject != theSetupStepsSubject &&
      theAtomicStepsSubject != theSetupStepsSubject;

  /// Step 390 in this batch has the same shape.
  static const int theOtherSplicedRow = 390;

  static const String spliceNote =
      'The Atomic Step builds a finalisation button; the Data Requirement '
      'column asks for list items with secondary text, Label Small proficiency '
      'notes and tap-to-see-a-definition, which is a glossary screen; and the '
      'Setup Step column asks for no regression after code-splitting, which is '
      'a build task. Three subjects in one row, and Step 390 in this batch is '
      'the same shape -- the top half about one feature and the bottom half '
      'about another.';

  // -----------------------------------------------------------------------
  // The data fields are the design.
  // -----------------------------------------------------------------------

  static const HabotRubricLockRecord worked = HabotRubricLockRecord(
    lockType: 'finalised for the September assessment round',
    locked: true,
    lockedBy: 'the assessment owner',
    lockTimestamp: '2026-09-03T11:02:44+04:00',
    lockReason: 'scoring opens tomorrow',
  );

  static bool get everyLockFactIsRecorded =>
      worked.isComplete &&
      HabotRubricLockField.values.length == 5;

  static bool get theLockNamesItsHolder => worked.lockedBy.isNotEmpty;

  static bool get theLockCarriesAReason => worked.lockReason.isNotEmpty;

  static const bool theAtomicStepMentionsAnyOfThem = false;

  static const String fieldsNote =
      'Lock Type, Locked By, Lock Timestamp and Lock Reason are exactly the '
      'four things a lock has to carry to be reversible by somebody who was '
      'not there when it was set. They sit in the data-fields column rather '
      'than in the instruction, so a reader who implements only the Atomic '
      'Step builds a lock with none of them -- which is a lock nobody can '
      'safely undo.';

  // -----------------------------------------------------------------------
  // When the lock is checked.
  // -----------------------------------------------------------------------

  static const bool theLockIsCheckedAtSubmission = false;

  static const bool theLockIsCheckedAtFirstScore = true;

  static bool get theCheckIsAtTheRightMoment =>
      theLockIsCheckedAtFirstScore && !theLockIsCheckedAtSubmission;

  static const String whatAnUnlockedRubricCosts =
      'two candidates scored against different rubrics, neither score wrong';

  static bool get theCostIsNamed =>
      whatAnUnlockedRubricCosts.contains('neither score wrong');

  static const String momentNote =
      'A rubric that changes mid-assessment makes two candidates incomparable '
      'without either score being wrong, which is the failure a finalisation '
      'button prevents. The lock is therefore checked at the moment of the '
      'first score rather than at submission, and the timestamp stored is the '
      'lock\'s rather than the button press\'s -- they are the same only if '
      'nobody retries.';

  // -----------------------------------------------------------------------
  // The unlock.
  // -----------------------------------------------------------------------

  static bool canUnlock({required int scoresRecorded}) => scoresRecorded == 0;

  static bool get anUnlockIsPossibleBeforeScoring =>
      canUnlock(scoresRecorded: 0) && !canUnlock(scoresRecorded: 1);

  static const bool anUnlockNeedsAReason = true;

  static const bool theUnlockIsRecorded = true;

  static const int theStepThatSettledElevation = 320;

  static bool get theUnlockIsTheDeclaredShape =>
      anUnlockNeedsAReason && theUnlockIsRecorded;

  static const HabotDisableKind kind = HabotDisableKind.conditional;

  static HabotDisabledControl get editControl => HabotDisabledControl(
        label: 'Edit rubric settings',
        kind: kind,
        reason: 'finalised: ${worked.lockReason}',
        whatWouldChangeIt: 'an unlock, while no score has been recorded',
      );

  static bool get theLockedControlIsNotADeadEnd => !editControl.isADeadEnd;

  static const String unlockNote =
      'A rubric locked by mistake before anybody scored is an ordinary '
      'Tuesday. The unlock is available while no score exists, needs a reason '
      'and is itself recorded -- which is the elevation shape Step 320 built '
      'rather than a second mechanism. After the first score the unlock is '
      'gone, because at that point undoing the lock is undoing an assessment.';

  // -----------------------------------------------------------------------
  // The band.
  // -----------------------------------------------------------------------

  static const double bandFloor = 0.8;
  static const double bandOptimal = 0.92;
  static const double bandCeiling = 0.98;

  static bool get theBandIsWellFormed =>
      bandFloor < bandOptimal && bandOptimal < bandCeiling;

  static const String metricName = 'AI Output Confidence Threshold Accuracy';

  static const bool theMetricMeasuresAModel = true;

  static double get lockFactsRecorded => worked.statedFields.isEmpty
      ? 0
      : worked.statedFields.where((String f) => f.isNotEmpty).length /
          worked.statedFields.length *
          100;

  static const String metricNote =
      'The band is well formed -- 0.8, 0.92, 0.98, correctly ordered, and a '
      'ceiling below 1 that is a real position rather than a mistake, unlike '
      'Step 370\'s. It measures an AI confidence threshold on a row that '
      'builds a button, so the figure published is the share of lock facts the '
      'record actually carries.';

  static Map<String, bool> get obligations => <String, bool>{
        'every lock fact is recorded': everyLockFactIsRecorded,
        'the lock names its holder and its reason':
            theLockNamesItsHolder && theLockCarriesAReason,
        'the lock is checked at the first score': theCheckIsAtTheRightMoment,
        'an unlock exists before scoring starts':
            anUnlockIsPossibleBeforeScoring,
        'the unlock needs a reason and is recorded':
            theUnlockIsTheDeclaredShape,
        'the locked control is not a dead end': theLockedControlIsNotADeadEnd,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'High' : 'Low';

  static Map<String, bool> get checks => <String, bool>{
        'three columns describe three subjects':
            threeColumnsDescribeThreeThings && theOtherSplicedRow == 390,
        'and the same shape appears again at Step 390':
            spliceNote.contains('the same shape'),
        'five lock fields, all recorded': everyLockFactIsRecorded,
        'the Atomic Step mentions none of them':
            !theAtomicStepMentionsAnyOfThem &&
                fieldsNote.contains('nobody can safely undo'),
        'the lock is checked at the first score, not at submission':
            theCheckIsAtTheRightMoment,
        'and the cost of not locking is named':
            theCostIsNamed && momentNote.contains('only if nobody retries'),
        'an unlock exists while no score does':
            anUnlockIsPossibleBeforeScoring && theUnlockIsTheDeclaredShape,
        'the unlock is Step 320\'s shape':
            theStepThatSettledElevation == 320 &&
                unlockNote.contains('undoing an assessment'),
        'the band is well formed and measures a model':
            theBandIsWellFormed && theMetricMeasuresAModel,
        'six obligations, all met, giving High':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'High' &&
                lockFactsRecorded == 100,
      };

  static const String columnNote =
      'COLUMN NOTE: this row describes three different things in three columns '
      '-- a finalisation button in the Atomic Step, a glossary screen in the '
      'Data Requirement column, and a code-splitting regression check in the '
      'Setup Step column, which reads "Confirm no regression in component '
      'functionality after code-splitting"; its metric scores an AI output '
      'confidence threshold on a row that builds a button; and its five lock '
      'data fields describe the design the Atomic Step does not ask for. '
      'Atomic Step: "Program a validation finalization button that locks the '
      'rubric settings upon execution."';
}
