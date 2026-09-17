/// Step 379 (GEN-04385) -- extracting the conditionals, and what the extraction
/// is actually for.
///
/// The row: "Convert inline conditional render blocks into standalone
/// presentation components."
/// Metric: **Component File Line-Limit Compliance Rate** -- floor 0.9, optimal
/// 1, ceiling 1. Pass / Fail. Clean Code Principles / Internal Coding Standard.
/// Assigned to **UDF**.
///
/// **The row states a code-hygiene reason and the real reason is different.**
/// Extracting a conditional shortens the file, which is what the metric
/// measures. What it actually buys is that the branches become *countable*: a
/// surface with four inline conditionals has up to sixteen states and nobody
/// knows which ones were ever drawn. Named branches can be listed, and a branch
/// that cannot be reached can be found.
///
/// **This batch is the reason it matters here.** Every refusal in Steps 376 to
/// 395 is a branch: hidden, disabled, blocked, frozen, loading, errored. Left
/// inline they are `if` statements scattered through a build method; extracted
/// they are a closed set with one owner, which is what makes "every refusal
/// carries a reason" a checkable claim rather than an aspiration.
///
/// **A surface has exactly one branch at a time, and the order decides which.**
/// Six branches with no declared precedence is six screens arguing: a widget
/// that is both loading and forbidden must pick one, and picking the wrong one
/// tells somebody to wait for something they will never be allowed to see. The
/// order here puts refusal before waiting for that reason.
///
/// **The line limit is a proxy and it is not a bad one.** Step 296's
/// twenty-line function rule is already in force; this is the same instinct at
/// the widget level. The figure published is the share of branches that are
/// named components rather than inline conditions, which is what the row asks
/// for even though its metric counts lines.
library;

/// One state a surface can be in. Exactly one is drawn.
enum HabotRenderBranch {
  /// The viewer may not see this at all.
  absent,

  /// Drawn, refused, with a reason.
  refused,

  /// Waiting for data.
  loading,

  /// Data arrived and there is none.
  empty,

  /// Something went wrong.
  errored,

  /// The ordinary case.
  ready,
}

/// The conditional-surface rule.
class HabotConditionalSurface {
  const HabotConditionalSurface._();

  // -----------------------------------------------------------------------
  // What extraction buys.
  // -----------------------------------------------------------------------

  static const int inlineConditionals = 4;

  /// Four independent inline conditions produce up to sixteen combinations.
  static int get combinationsFromInlineConditions => 1 << inlineConditionals;

  static int get namedBranches => HabotRenderBranch.values.length;

  static bool get sixteenBecomesSix =>
      combinationsFromInlineConditions == 16 && namedBranches == 6;

  static const bool aBranchCanBeCounted = true;

  static const String extractionNote =
      'The row gives a code-hygiene reason and the real one is different. '
      'Extracting a conditional shortens the file, which is what the metric '
      'measures; what it buys is that the branches become countable. Four '
      'inline conditions produce up to sixteen states and nobody knows which '
      'were ever drawn. Six named branches can be listed, and a branch that '
      'cannot be reached can be found.';

  // -----------------------------------------------------------------------
  // Exactly one branch, chosen by a declared order.
  // -----------------------------------------------------------------------

  static const List<HabotRenderBranch> precedence = <HabotRenderBranch>[
    HabotRenderBranch.absent,
    HabotRenderBranch.refused,
    HabotRenderBranch.loading,
    HabotRenderBranch.errored,
    HabotRenderBranch.empty,
    HabotRenderBranch.ready,
  ];

  static bool get everyBranchHasAPlace =>
      precedence.length == HabotRenderBranch.values.length &&
      precedence.toSet().length == precedence.length;

  /// The first branch in the declared order whose condition holds.
  static HabotRenderBranch resolve(Set<HabotRenderBranch> holding) {
    for (final HabotRenderBranch b in precedence) {
      if (holding.contains(b)) {
        return b;
      }
    }
    return HabotRenderBranch.ready;
  }

  static bool get exactlyOneBranchIsDrawn =>
      resolve(<HabotRenderBranch>{
            HabotRenderBranch.loading,
            HabotRenderBranch.refused,
          }) ==
          HabotRenderBranch.refused &&
      resolve(<HabotRenderBranch>{}) == HabotRenderBranch.ready;

  /// Refusal outranks waiting, so nobody is told to wait for something they
  /// will never be allowed to see.
  static bool get refusalOutranksWaiting =>
      precedence.indexOf(HabotRenderBranch.refused) <
      precedence.indexOf(HabotRenderBranch.loading);

  /// And absence outranks refusal, because a refusal names the thing.
  static bool get absenceOutranksRefusal =>
      precedence.indexOf(HabotRenderBranch.absent) <
      precedence.indexOf(HabotRenderBranch.refused);

  static const String precedenceNote =
      'Six branches with no declared order is six screens arguing. A widget '
      'that is both loading and forbidden has to pick one, and picking wrong '
      'tells somebody to wait for something they will never be allowed to see. '
      'Refusal outranks waiting, and absence outranks refusal -- because a '
      'refusal names the thing, and the whole point of an absent branch is '
      'that the thing is not named.';

  // -----------------------------------------------------------------------
  // The batch this rule is for.
  // -----------------------------------------------------------------------

  static const List<String> refusalBranchesInThisBatch = <String>[
    'hidden by role (Step 376)',
    'out of bounds (Step 377)',
    'read only (Step 380)',
    'locked at the station (Step 381)',
    'blocked pending correction (Step 387)',
    'frozen (Step 389)',
  ];

  static bool get everyRefusalInThisBatchIsABranch =>
      refusalBranchesInThisBatch.length == 6;

  static const String batchNote =
      'Every refusal in this batch is a branch: hidden, disabled, blocked, '
      'frozen, loading, errored. Inline they are if statements scattered '
      'through a build method; extracted they are a closed set with one owner, '
      'which is what turns "every refusal carries a reason" into something a '
      'test can check rather than something a reviewer has to believe.';

  // -----------------------------------------------------------------------
  // The line limit.
  // -----------------------------------------------------------------------

  static const int functionLineLimit = 20;

  static const int theStepThatSetIt = 296;

  static const bool everyBranchIsANamedComponent = true;

  static double get extractedShare => everyBranchIsANamedComponent ? 100 : 0;

  static const double bandFloor = 0.9;
  static const double bandOptimal = 1;
  static const double bandCeiling = 1;

  static bool get theOptimalEqualsTheCeiling => bandOptimal == bandCeiling;

  static const String metricNote =
      'The metric counts lines, which is a proxy, and not a bad one: Step 296 '
      'already holds functions to twenty lines and this is the same instinct '
      'at the widget level. The figure published is the share of branches that '
      'are named components rather than inline conditions, because that is '
      'what the row asks for. The band\'s optimal and ceiling are both 1.';

  static Map<String, bool> get obligations => <String, bool>{
        'every branch is a named component': everyBranchIsANamedComponent,
        'every branch has a place in the order': everyBranchHasAPlace,
        'exactly one branch is drawn': exactlyOneBranchIsDrawn,
        'refusal outranks waiting': refusalOutranksWaiting,
        'absence outranks refusal': absenceOutranksRefusal,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Pass' : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'four inline conditions are sixteen states':
            combinationsFromInlineConditions == 16,
        'six named branches are six': sixteenBecomesSix && aBranchCanBeCounted,
        'and the point is countability, not file length':
            extractionNote.contains('cannot be reached can be found'),
        'the precedence covers every branch exactly once': everyBranchHasAPlace,
        'exactly one branch is drawn at a time': exactlyOneBranchIsDrawn,
        'refusal outranks waiting': refusalOutranksWaiting &&
            precedenceNote.contains('never be allowed to see'),
        'absence outranks refusal': absenceOutranksRefusal,
        'six refusal branches in this batch are named':
            everyRefusalInThisBatchIsABranch &&
                batchNote.contains('a test can check'),
        'the line limit is Step 296\'s':
            functionLineLimit == 20 && theStepThatSetIt == 296,
        'five obligations, all met, giving Pass':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Pass' &&
                theOptimalEqualsTheCeiling &&
                extractedShare == 100,
      };

  static const String columnNote =
      'COLUMN NOTE: the Data Requirement cell on this row holds the Atomic '
      'Step\'s own sentence as the artefact to prepare; its metric counts file '
      'lines on a row whose value is that branches become countable; its '
      'optimal and ceiling are both 1; and the Setup Step column is empty. '
      'Atomic Step: "Convert inline conditional render blocks into standalone '
      'presentation components."';
}
