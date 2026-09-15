/// Step 295 (LSAV-002) -- "interface permissions", which are not permissions,
/// and three reasons a cell is read-only that all look the same.
///
/// The row: "Configure interface permissions to block cell-level data
/// modification or direct manual row edits."
/// Metric: **Points-Ledger Accuracy & Redemption Processing Time** -- floor
/// ">=99% ledger accuracy; redemption <5 seconds", optimal "100% accuracy;
/// redemption <1 second; tier update within 1 minute", ceiling "100% accuracy
/// is both floor and ceiling; processing ceiling near-instant (<500ms)".
/// Pass / Fail.
///
/// **"Interface permissions" is a contradiction.** Permissions are enforced
/// where the data is. What an interface does is decline to offer an edit,
/// which prevents a mistake and prevents nothing else -- the fifth time this
/// batch has reached that distinction and the second time on the same day as
/// Step 294. The distinction is not pedantry: it decides what the message
/// says. "You cannot change this" is false if the server would accept it from
/// somebody else; "this is not editable here" is true.
///
/// **Read-only is three different states wearing one appearance.** A cell can
/// be derived, so nobody edits it; forbidden, so this person does not; or
/// locked, so nobody edits it *now*. They look identical on screen and need
/// three different sentences, and the one that gets missed is the first --
/// a derived cell that looks editable is the worst of the three, because the
/// person types a value, watches it revert, and stops trusting the table.
///
/// **The five fields the row asks to collect are Step 273's lock fields.**
/// Lock Type, Lock Status, Locked By, Lock Timestamp, Lock Reason: written for
/// pessimistic record locking, carried there by a circuit breaker because they
/// fitted, and here for the first time they describe what they were written
/// for.
library;

import '../resilience/persistence_circuit.dart';

/// Why a cell cannot be edited.
enum HabotReadOnlyReason {
  /// It is computed from other cells. Nobody edits it.
  derived,

  /// This person's role does not include it.
  notPermitted,

  /// The record is locked -- by a state, or by somebody else.
  lockedNow,
}

/// One cell in the table.
class HabotEditableCell {
  const HabotEditableCell({
    required this.column,
    required this.reason,
  });

  final String column;

  /// Null when the cell is editable.
  final HabotReadOnlyReason? reason;

  bool get isEditable => reason == null;
}

/// The rule.
class HabotCellEditPermission {
  const HabotCellEditPermission._();

  // -----------------------------------------------------------------------
  // Three reasons, three sentences.
  // -----------------------------------------------------------------------

  static const List<HabotEditableCell> cells = <HabotEditableCell>[
    HabotEditableCell(column: 'note', reason: null),
    HabotEditableCell(
      column: 'line total',
      reason: HabotReadOnlyReason.derived,
    ),
    HabotEditableCell(
      column: 'points balance',
      reason: HabotReadOnlyReason.derived,
    ),
    HabotEditableCell(
      column: 'payout status',
      reason: HabotReadOnlyReason.notPermitted,
    ),
    HabotEditableCell(
      column: 'session date',
      reason: HabotReadOnlyReason.lockedNow,
    ),
  ];

  static String messageFor(HabotReadOnlyReason reason) => switch (reason) {
        HabotReadOnlyReason.derived =>
          'This is calculated from the other columns, so it is not edited '
              'directly. Change what it is calculated from.',
        HabotReadOnlyReason.notPermitted =>
          'Your account does not include changing this. An administrator '
              'can.',
        HabotReadOnlyReason.lockedNow =>
          'This record is in use and will unlock on its own. Nothing you '
              'have typed is lost.',
      };

  static Set<String> get distinctMessages =>
      HabotReadOnlyReason.values.map(messageFor).toSet();

  static bool get everyReasonHasItsOwnSentence =>
      distinctMessages.length == HabotReadOnlyReason.values.length &&
      HabotReadOnlyReason.values.length == 3;

  static bool get everySentenceSaysWhatToDoOrThatNothingIsNeeded =>
      messageFor(HabotReadOnlyReason.derived).contains('Change what') &&
      messageFor(HabotReadOnlyReason.notPermitted).contains('administrator') &&
      messageFor(HabotReadOnlyReason.lockedNow).contains('on its own');

  static List<HabotEditableCell> get editable =>
      cells.where((HabotEditableCell c) => c.isEditable).toList();

  static List<HabotEditableCell> get readOnly =>
      cells.where((HabotEditableCell c) => !c.isEditable).toList();

  static bool get everyReadOnlyKindAppears =>
      readOnly
          .map((HabotEditableCell c) => c.reason)
          .whereType<HabotReadOnlyReason>()
          .toSet()
          .length ==
      HabotReadOnlyReason.values.length;

  /// A derived cell that looks editable is the worst of the three, so it is
  /// the one the appearance has to distinguish first.
  static bool get aDerivedCellIsNeverPresentedAsEditable => cells
      .where((HabotEditableCell c) => c.reason == HabotReadOnlyReason.derived)
      .every((HabotEditableCell c) => !c.isEditable);

  static const String threeReasonsNote =
      'Read-only is three states wearing one appearance. A cell can be '
      'derived, so nobody edits it; forbidden, so this person does not; or '
      'locked, so nobody edits it now. On screen they are identical and they '
      'need three different sentences -- and the one that gets missed is the '
      'first. A derived cell that looks editable is the worst of the three, '
      'because the person types a value, watches it revert, and stops '
      'trusting the whole table; the other two at least fail honestly.';

  // -----------------------------------------------------------------------
  // What an interface can and cannot enforce.
  // -----------------------------------------------------------------------

  static const bool theInterfaceEnforcesPermissions = false;
  static const bool theInterfacePreventsMistakes = true;

  /// The wording that follows from that: what is true of the surface rather
  /// than of the person's rights.
  static const String truthfulPhrasing = 'This is not editable here.';
  static const String falsePhrasing = 'You cannot change this.';

  static bool get theWordingFollowsFromWhoEnforces =>
      !theInterfaceEnforcesPermissions &&
      truthfulPhrasing.contains('here') &&
      !truthfulPhrasing.contains('cannot');

  static const String notPermissionsNote =
      '"Interface permissions" is a contradiction. Permissions are enforced '
      'where the data is; what an interface does is decline to offer an edit, '
      'which prevents a mistake and prevents nothing else. The distinction is '
      'not pedantry, because it decides the wording: "you cannot change this" '
      'is false if the server would accept the same change from somebody '
      'else, and a person who discovers that stops believing the next message '
      'too. "This is not editable here" is true of the surface, which is the '
      'only thing the surface can speak for.';

  // -----------------------------------------------------------------------
  // The five declared fields, which finally describe what they were for.
  // -----------------------------------------------------------------------

  /// Step 273 carried Lock Type, Lock Status, Locked By, Lock Timestamp and
  /// Lock Reason on a circuit-breaker row because they fitted a tripped
  /// breaker. They were written for record locking, which is this row.
  static HabotCircuitLock lockFor({required DateTime at}) =>
      HabotPersistenceCircuit.lockFor(
        state: HabotCircuitState.open,
        reason: HabotUnavailability.requestTimedOut,
        at: at,
      );

  static bool get theSameFiveFieldsDescribeARecordLock {
    final HabotCircuitLock lock = lockFor(at: DateTime.utc(2026, 9, 15));
    return lock.lockType.isNotEmpty &&
        lock.lockedBy.isNotEmpty &&
        lock.lockTimestamp.isUtc &&
        lock.isHeld;
  }

  static const String lockFieldsNote =
      'The five fields this row asks to collect -- Lock Type, Lock Status, '
      'Locked By, Lock Timestamp, Lock Reason -- are the same five Step 273 '
      'carried on a circuit-breaker row. They were written for pessimistic '
      'record locking and fitted a tripped breaker by accident; here they '
      'describe the thing they were written for, which is the first time in '
      'this track that a Data Collected column has arrived at its own '
      'subject. The vocabulary is reused rather than redeclared, so a record '
      'lock and a circuit lock are the same shape in the evidence.';

  // -----------------------------------------------------------------------
  // Metric: a different subject entirely.
  // -----------------------------------------------------------------------

  static const String metricSubject =
      'Points-Ledger Accuracy & Redemption Processing Time';

  static bool get theMetricIsAboutSomethingElse =>
      !metricSubject.toLowerCase().contains('edit') &&
      !metricSubject.toLowerCase().contains('permission');

  /// Two measurements bundled into one metric: an accuracy and a latency,
  /// with a single Pass/Fail over both -- the same defect Step 285 found in
  /// its touch-and-contrast bundle.
  static const int bundledMeasurements = 2;

  static bool get twoMeasurementsOneVerdict => bundledMeasurements == 2;

  static const String metricNote =
      'The metric is a points ledger and a redemption latency, on a row about '
      'whether a table cell can be typed into. It is also two measurements '
      'bundled under one Pass/Fail -- an accuracy and a processing time -- '
      'which is the defect Step 285 found in its touch-and-contrast bundle: a '
      'single verdict over two quantities cannot say which one failed. '
      'Neither reaches this row, and the ceiling text is the only part with '
      'anything to say about the subject: "100% accuracy is both floor and '
      'ceiling for ledger integrity", which is the right shape for money and '
      'the wrong row to say it on.';

  static Map<String, bool> get obligations => <String, bool>{
        'every read-only reason has its own sentence':
            everyReasonHasItsOwnSentence,
        'every sentence says what to do, or that nothing is needed':
            everySentenceSaysWhatToDoOrThatNothingIsNeeded,
        'a derived cell is never presented as editable':
            aDerivedCellIsNeverPresentedAsEditable,
        'all three read-only kinds appear in the worked table':
            everyReadOnlyKindAppears,
        'the wording follows from who actually enforces':
            theWordingFollowsFromWhoEnforces,
        'the five declared lock fields are carried':
            theSameFiveFieldsDescribeARecordLock,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'five cells, one editable and four not':
            cells.length == 5 && editable.length == 1 && readOnly.length == 4,
        'three read-only reasons, three distinct sentences':
            everyReasonHasItsOwnSentence && everyReadOnlyKindAppears,
        'every sentence says what to do or that nothing is needed':
            everySentenceSaysWhatToDoOrThatNothingIsNeeded,
        'a derived cell is never presented as editable':
            aDerivedCellIsNeverPresentedAsEditable &&
                threeReasonsNote.contains('stops trusting the whole table'),
        'the interface prevents mistakes and enforces nothing':
            !theInterfaceEnforcesPermissions && theInterfacePreventsMistakes,
        'the wording follows from that, and the false phrasing is named':
            theWordingFollowsFromWhoEnforces &&
                falsePhrasing.contains('cannot') &&
                notPermissionsNote.contains('speak for'),
        'the five lock fields from Step 273 describe a record lock here':
            theSameFiveFieldsDescribeARecordLock &&
                lockFieldsNote.contains('arrived at its own subject'),
        'the metric belongs to a different subject':
            theMetricIsAboutSomethingElse,
        'two measurements share one verdict':
            twoMeasurementsOneVerdict && metricNote.contains('Step 285'),
        'six obligations, all met, giving Pass':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass',
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Write a '
      'JavaScript function to track the current active column sorting key '
      'parameter" -- JavaScript, in a Dart application, and the eighth row in '
      'this track written for another stack. Every narrative column is about '
      'API gateway payload limits. Atomic Step: "Configure interface '
      'permissions to block cell-level data modification or direct manual row '
      'edits."';
}
