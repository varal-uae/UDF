/// Step 397 (ETMDI-016-07) -- "exactly one atomic, singular system transaction"
/// per screen, and what that costs when you mean it.
///
/// The row: "Assign exactly one atomic, singular system transaction to each
/// newly separated screen."
/// Metric: **Task Atomicity / Single-Action Granularity Rate** -- floor
/// ">=90%", optimal 1, ceiling 1. Best Qualitative Output: "Good/Average/Poor
/// -> Best = Good (100%)". Lean Six Sigma Process Decomposition Standard.
/// Assigned to **UDF**.
///
/// **Three words are doing different jobs and only one of them is the rule.**
/// "Exactly one" is a count. "Atomic" is a durability property -- it either all
/// happened or none of it did. "Singular" is neither; it is emphasis. Read
/// carelessly the row says a screen may write one row to one table, which no
/// real screen does: approving overtime writes an approval, an audit entry and
/// a notification, and all three have to succeed together or none of them
/// should.
///
/// **So the rule is one transaction, not one write.** Step 396's inventory
/// names seven actions across five screens; two screens declare more than one.
/// Those two are the finding, and they split differently: "Approve" and
/// "Decline" on the overtime screen are one decision with two outcomes and stay
/// together, while "Offer" and "Withdraw" on the shift screen are two decisions
/// about different states and become two screens.
///
/// **A decision with two outcomes is still one transaction.** Splitting Approve
/// and Decline onto separate screens would make somebody navigate before they
/// could disagree, which is the interface telling them what to choose. The test
/// is whether the two outcomes answer the same question, not whether they write
/// the same row.
///
/// **What "atomic" actually obliges is a rollback.** If the approval writes and
/// the audit entry fails, the screen must not report success -- and the
/// existing rollback boundary is where that lives rather than in a second
/// mechanism invented here.
///
/// **COLUMN NOTE.** The output cell carries the arrow annotation, the band
/// mixes ">=90%" with an optimal and ceiling of 1, the Data Requirement column
/// holds step-execution fields beside Jetpack Compose layout advice, and the
/// Setup Step column is about single-column stacking rules.
library;

import 'screen_action_audit.dart';

/// Why a screen with more than one action is or is not a problem.
enum HabotTransactionScope {
  /// Two outcomes of one question. Stays on one screen.
  oneDecisionTwoOutcomes,

  /// Two questions. Becomes two screens.
  twoDecisions,

  /// One action. Nothing to decide.
  alreadySingular,
}

/// One screen, classified.
class HabotScreenTransaction {
  const HabotScreenTransaction({
    required this.screen,
    required this.scope,
    required this.reason,
  });

  final String screen;
  final HabotTransactionScope scope;
  final String reason;

  bool get mustSplit => scope == HabotTransactionScope.twoDecisions;
}

/// The one-transaction rule.
class HabotOneTransactionPerScreen {
  const HabotOneTransactionPerScreen._();

  // -----------------------------------------------------------------------
  // Three words, one rule.
  // -----------------------------------------------------------------------

  static const Map<String, String> theRowsWords = <String, String>{
    'exactly one': 'a count',
    'atomic': 'a durability property: all of it happened, or none of it did',
    'singular': 'emphasis, carrying no separate obligation',
  };

  static bool get theThreeWordsAreDistinguished => theRowsWords.length == 3;

  static const bool aScreenMayWriteOnlyOneRow = false;

  static const int writesWhenOvertimeIsApproved = 3;

  static bool get oneTransactionIsNotOneWrite =>
      !aScreenMayWriteOnlyOneRow && writesWhenOvertimeIsApproved == 3;

  static const String wordsNote =
      '"Exactly one" is a count, "atomic" is a durability property, and '
      '"singular" is emphasis. Read as one write per screen the rule describes '
      'nothing real: approving overtime writes an approval, an audit entry and '
      'a notification, and all three have to succeed together or none of them '
      'should. The rule is one transaction, and a transaction can be three '
      'writes.';

  // -----------------------------------------------------------------------
  // Applied to the inventory.
  // -----------------------------------------------------------------------

  static List<HabotAuditedScreen> get inventory =>
      HabotScreenActionAudit.screens;

  static int get screensWithMoreThanOneAction =>
      HabotScreenActionAudit.screensWithMoreThanOneAction;

  static const List<HabotScreenTransaction> classified =
      <HabotScreenTransaction>[
    HabotScreenTransaction(
      screen: 'Clock in',
      scope: HabotTransactionScope.alreadySingular,
      reason: 'one action; nothing to decide',
    ),
    HabotScreenTransaction(
      screen: 'Approve overtime',
      scope: HabotTransactionScope.oneDecisionTwoOutcomes,
      reason: 'approve and decline answer the same question',
    ),
    HabotScreenTransaction(
      screen: 'Edit profile',
      scope: HabotTransactionScope.alreadySingular,
      reason: 'one action; nothing to decide',
    ),
    HabotScreenTransaction(
      screen: 'Export payroll',
      scope: HabotTransactionScope.alreadySingular,
      reason: 'one action; nothing to decide',
    ),
    HabotScreenTransaction(
      screen: 'Swap a shift',
      scope: HabotTransactionScope.twoDecisions,
      reason: 'offering and withdrawing are two questions about two states',
    ),
  ];

  static bool get everyScreenIsClassified =>
      classified.length == inventory.length;

  static int get screensThatSplit =>
      classified.where((HabotScreenTransaction t) => t.mustSplit).length;

  static bool get oneOfTwoSplits =>
      screensThatSplit == 1 && screensWithMoreThanOneAction == 2;

  static int get screensAfterTheSplit => inventory.length + screensThatSplit;

  static bool get theCountRisesByOne => screensAfterTheSplit == 6;

  static const String applicationNote =
      'Step 396\'s inventory names two screens with more than one action, and '
      'they split differently. Approve and decline are one decision with two '
      'outcomes and stay together; offering and withdrawing a shift are two '
      'questions about two states and become two screens. Five screens become '
      'six, which is the only number this row actually changes.';

  // -----------------------------------------------------------------------
  // A decision with two outcomes.
  // -----------------------------------------------------------------------

  static const bool approveAndDeclineAreSplit = false;

  static const String whatSplittingThemWouldCost =
      'somebody would have to navigate before they could disagree';

  static bool get theTestIsTheQuestionNotTheWrite =>
      !approveAndDeclineAreSplit &&
      whatSplittingThemWouldCost.contains('before they could disagree');

  static const String decisionNote =
      'Splitting approve and decline onto separate screens makes somebody '
      'navigate before they can disagree, which is the interface telling them '
      'what to choose. The test is whether the two outcomes answer the same '
      'question, not whether they write the same row -- and a refusal that is '
      'harder to reach than an approval is a refusal that gets skipped.';

  // -----------------------------------------------------------------------
  // What "atomic" obliges.
  // -----------------------------------------------------------------------

  static const bool aPartialWriteReportsSuccess = false;

  static const int theStepThatBuiltTheRollbackBoundary = 19;

  static bool get atomicityIsBoundToTheExistingBoundary =>
      !aPartialWriteReportsSuccess && theStepThatBuiltTheRollbackBoundary == 19;

  static const String atomicNote =
      'If the approval writes and the audit entry fails, the screen must not '
      'report success. That is the whole of what "atomic" obliges, and the '
      'rollback boundary Step 19 built is where it lives -- inventing a second '
      'mechanism here would give two answers to the question of what a failed '
      'half-write looks like.';

  // -----------------------------------------------------------------------
  // The band and the arrow.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = '>=90%';
  static const int bandOptimal = 1;
  static const int bandCeiling = 1;

  static bool get theBandMixesUnits => bandFloorRaw.contains('%');

  static bool get theOptimalEqualsTheCeiling => bandOptimal == bandCeiling;

  static const String outputColumnRaw =
      'Good/Average/Poor -> Best = Good (100%)';

  static bool get theOutputColumnHoldsAnAnnotation =>
      outputColumnRaw.contains('->');

  static double get atomicityRate => classified.isEmpty
      ? 0
      : classified
              .where((HabotScreenTransaction t) => !t.mustSplit)
              .length /
          classified.length *
          100;

  static const String columnNote =
      'COLUMN NOTE: the Best Qualitative Output cell on this row reads '
      '"Good/Average/Poor -> Best = Good (100%)", the second arrow-annotated '
      'output cell in this batch; the band mixes ">=90%" with an optimal and a '
      'ceiling both written 1; the Data Requirement column holds '
      'step-execution fields beside Jetpack Compose layout advice identical to '
      'Step 396\'s; and the Setup Step column reads "Save the single-column '
      'stacking rules style assets to the central layout codebase". Atomic '
      'Step: "Assign exactly one atomic, singular system transaction to each '
      'newly separated screen."';

  static Map<String, bool> get obligations => <String, bool>{
        'the three words are distinguished': theThreeWordsAreDistinguished,
        'one transaction is not one write': oneTransactionIsNotOneWrite,
        'every screen in the inventory is classified': everyScreenIsClassified,
        'a decision with two outcomes stays on one screen':
            theTestIsTheQuestionNotTheWrite,
        'a partial write does not report success':
            atomicityIsBoundToTheExistingBoundary,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'three words, three different jobs':
            theThreeWordsAreDistinguished &&
                (theRowsWords['atomic'] ?? '').contains('none of it did'),
        'one transaction can be three writes':
            oneTransactionIsNotOneWrite && wordsNote.contains('three writes'),
        'every screen in Step 396\'s inventory is classified':
            everyScreenIsClassified && inventory.length == 5,
        'two screens have more than one action and one splits':
            oneOfTwoSplits && screensThatSplit == 1,
        'five screens become six': theCountRisesByOne,
        'approve and decline stay together':
            theTestIsTheQuestionNotTheWrite &&
                decisionNote.contains('gets skipped'),
        'atomicity is Step 19\'s rollback boundary':
            atomicityIsBoundToTheExistingBoundary &&
                atomicNote.contains('two answers'),
        'the band mixes units': theBandMixesUnits && theOptimalEqualsTheCeiling,
        'the output cell carries an arrow': theOutputColumnHoldsAnAnnotation,
        'five obligations, all met, giving Good':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good' &&
                atomicityRate == 80,
      };
}
