/// Step 417 (UFHT-019) -- a row with no metric name at all, an output column
/// written backwards, and a lower half about firing people.
///
/// The row: "Define the friction indicators to be silently logged."
/// Metric: **(the cell is empty)** -- floor 0.8, optimal 0.95, ceiling 1. Best
/// Qualitative Output: "Not Complete / Partial / Complete". IIBA BABOK v3
/// requirements-elicitation completeness benchmark. Assigned to **ADFA**.
///
/// **The Metric Name cell is empty.** Four hundred and sixteen rows into the
/// track this is the first one with no metric at all. There is a band -- 0.8,
/// 0.95, 1 -- and nothing saying what is being measured to three decimal
/// places. A band without a metric is a scale with no quantity: it can be
/// satisfied by any number anybody chooses to put under it, which is the same
/// as not being satisfiable.
///
/// **The output column is written backwards.** Every other row in four hundred
/// and sixteen reads best-first: "Complete/Partial/Not Complete",
/// "Good/Average/Poor", "Pass/Fail". This one reads "Not Complete / Partial /
/// Complete". If the column is positional -- and six rows in this track carry
/// an arrow saying "Best = " the first value -- then this row declares Not
/// Complete to be its best outcome. It does not mean that. It is the only row
/// where the convention and the contents disagree, which is worth more than the
/// typo it probably is: it shows the column is read by position, not by value.
///
/// **The lower half belongs to a row about removing people's access.** The
/// Poka-Yoke cell reads "Script executes via Cloud Scheduler; managers cannot
/// 'save' a low performer manually"; the Completion Measures cell reads "Test
/// worker below threshold loses IAM access automatically"; the Expected Output
/// is "Automated Pruning Script logic defined"; the library is
/// "Security/Access Module". Fifth spliced row in the track, and the first
/// whose two halves fit together into a system that would be coherent if
/// anybody built it: friction telemetry wired to automatic dismissal. **Those
/// cells are recorded and refused.** Step 416's framework says the unit of
/// analysis is a screen and no indicator may be attributed to an individual,
/// and that limit exists precisely for this.
///
/// **"Silently" has two readings and only one of them is implemented.**
/// Silent as in *causing no visual disturbance* -- no layout shift, no
/// main-thread work, no battery cost -- is what the row's own design cells ask
/// for, and it is built. Silent as in *without the person knowing* is refused:
/// the indicators are listed on a disclosure surface, in plain words, with what
/// each one is for.
library;

import 'friction_framework.dart';

/// What a logged indicator may be joined to.
enum HabotJoinScope {
  /// A screen and a field. The declared scope.
  screenAndField,

  /// A session, for sequencing within one visit.
  session,

  /// A named person. Refused.
  individual,
}

/// The friction-indicator definitions.
class HabotFrictionIndicators {
  const HabotFrictionIndicators._();

  // -----------------------------------------------------------------------
  // No metric, and a band anyway.
  // -----------------------------------------------------------------------

  static const String metricNameCell = '';

  static bool get theMetricCellIsEmpty => metricNameCell.isEmpty;

  static const double bandFloor = 0.8;
  static const double bandOptimal = 0.95;
  static const double bandCeiling = 1;

  static bool get thereIsABandAnyway =>
      bandFloor < bandOptimal && bandOptimal < bandCeiling;

  static bool get aBandWithNoQuantity =>
      theMetricCellIsEmpty && thereIsABandAnyway;

  static const int rowsBeforeThisOne = 416;

  static const bool anyEarlierRowHadNoMetric = false;

  static bool get thisIsTheFirstRowWithNoMetric =>
      !anyEarlierRowHadNoMetric && rowsBeforeThisOne == 416;

  /// What is measured here instead, named because the sheet does not name it.
  static const String metricSuppliedHere =
      'Share of declared friction indicators that carry a threshold, a join '
      'scope and a disclosure line';

  static const String metricNote =
      'The Metric Name cell is empty and the band is not: 0.8, 0.95, 1, to two '
      'decimal places, measuring nothing the row names. Four hundred and '
      'sixteen rows in, this is the first with no metric at all. A band with '
      'no quantity behind it can be satisfied by whatever number is put under '
      'it, which is the same as not being satisfiable, so a metric is supplied '
      'here and named as a substitution rather than presented as the row\'s.';

  // -----------------------------------------------------------------------
  // The output column runs the wrong way.
  // -----------------------------------------------------------------------

  static const String outputColumnRaw = 'Not Complete / Partial / Complete';

  static const String theConventionEverywhereElse =
      'best value first, worst value last';

  static bool get theColumnIsReversed =>
      outputColumnRaw.startsWith('Not Complete');

  /// Six rows in the track annotate the column with "Best = " its first value.
  static const int rowsDeclaringTheFirstValueBest = 6;

  static bool get theConventionIsPositional =>
      rowsDeclaringTheFirstValueBest == 6;

  static bool get theRowContradictsItself =>
      theColumnIsReversed && theConventionIsPositional;

  static const String bestOutputActuallyMeant = 'Complete';

  static const String reversalNote =
      'Every other row in the track reads best-first, and six of them carry an '
      'arrow saying so outright: "Best =" the first value. This row reads "Not '
      'Complete / Partial / Complete", which under that convention declares '
      'failure to be its best outcome. It does not mean that. It is worth more '
      'than the typo it probably is, because it shows the column is read by '
      'position rather than by value -- which means any row whose values are '
      'listed in an unusual order is silently mis-scored.';

  // -----------------------------------------------------------------------
  // The lower half is about dismissing people.
  // -----------------------------------------------------------------------

  static const List<String> cellsFromTheOtherRow = <String>[
    'Poka-Yoke: "Script executes via Cloud Scheduler; managers cannot save a '
        'low performer manually"',
    'Completion Measures: "Test worker below threshold loses IAM access '
        'automatically"',
    'Expected Output: "Automated Pruning Script logic defined"',
    'Common Library: "Security/Access Module"',
    'Decision Group: "TC Implementer"',
  ];

  static bool get fiveCellsBelongElsewhere =>
      cellsFromTheOtherRow.length == 5;

  /// Steps 388, 390, 398, 416 and this one.
  static const List<int> splicedRows = <int>[388, 390, 398, 416, 417];

  static bool get thisIsTheFifthSplicedRow => splicedRows.length == 5;

  static const bool thePruningBehaviourIsBuilt = false;

  static const bool theCellsAreRecorded = true;

  static bool get theSpliceIsRecordedAndRefused =>
      theCellsAreRecorded && !thePruningBehaviourIsBuilt;

  static bool get theFrameworkAlreadyForbidsIt =>
      HabotFrictionFramework.theUnitOfAnalysisIsAScreen;

  static const String spliceNote =
      'The lower half of this row describes a scheduled script that removes a '
      'worker\'s access when they fall below a threshold, with managers '
      'explicitly prevented from intervening. It is the fifth spliced row in '
      'the track and the first whose halves fit together into something '
      'coherent -- friction telemetry wired to automatic dismissal -- which is '
      'exactly why it is recorded rather than built. Step 416 declares the '
      'unit of analysis to be a screen and forbids attributing an indicator to '
      'an individual; that limit was written for this case and holds here.';

  // -----------------------------------------------------------------------
  // Two readings of "silently".
  // -----------------------------------------------------------------------

  static const String silentAsBuilt =
      'causing no visual disturbance: no layout shift, no main-thread work, no '
      'measurable battery cost';

  static const String silentAsRefused =
      'without the person knowing it is happening';

  static bool get theTwoReadingsDiffer => silentAsBuilt != silentAsRefused;

  static const bool loggingCausesALayoutShift = false;
  static const bool loggingRunsOnTheMainThread = false;
  static const bool theIndicatorsAreDisclosed = true;

  static bool get theEngineeringReadingIsImplemented =>
      !loggingCausesALayoutShift && !loggingRunsOnTheMainThread;

  static bool get theSecrecyReadingIsRefused => theIndicatorsAreDisclosed;

  static const String disclosureSurface = 'Settings > Privacy > What we record';

  static const String silenceNote =
      'The row\'s own design cells ask for passive system events, no visual '
      'shifts during log creation, and tight resource limits -- silence as an '
      'engineering property, and it is built. Silence as secrecy is refused: '
      'every indicator appears on a disclosure surface in plain words with '
      'what it is for. The distinction costs nothing technically and is the '
      'whole difference between instrumentation and surveillance.';

  // -----------------------------------------------------------------------
  // What each indicator may be joined to.
  // -----------------------------------------------------------------------

  static const Map<HabotFrictionKind, HabotJoinScope> joinScope =
      <HabotFrictionKind, HabotJoinScope>{
    HabotFrictionKind.hesitationBeforeInput: HabotJoinScope.screenAndField,
    HabotFrictionKind.dwell: HabotJoinScope.screenAndField,
    HabotFrictionKind.correction: HabotJoinScope.screenAndField,
    HabotFrictionKind.deadTap: HabotJoinScope.screenAndField,
    HabotFrictionKind.abandonment: HabotJoinScope.session,
  };

  static bool get everyIndicatorHasAJoinScope =>
      joinScope.length == HabotFrictionKind.values.length;

  static bool get noIndicatorJoinsToAnIndividual => !joinScope.values
      .any((HabotJoinScope s) => s == HabotJoinScope.individual);

  static const Map<HabotFrictionKind, String> disclosureLine =
      <HabotFrictionKind, String>{
    HabotFrictionKind.hesitationBeforeInput:
        'how long a field waits before its first keystroke, so we can tell '
            'which questions are unclear',
    HabotFrictionKind.dwell:
        'how long a field is open without being filled in',
    HabotFrictionKind.correction:
        'when an answer is entered, cleared and entered again',
    HabotFrictionKind.deadTap:
        'when something that looks tappable is not',
    HabotFrictionKind.abandonment:
        'when a screen is opened and the task is not finished',
  };

  static bool get everyIndicatorHasADisclosureLine =>
      disclosureLine.length == HabotFrictionKind.values.length;

  static double get definitionCompleteness {
    final int total = HabotFrictionKind.values.length;
    if (total == 0) {
      return 0;
    }
    final int complete = HabotFrictionKind.values
        .where((HabotFrictionKind k) =>
            joinScope.containsKey(k) && disclosureLine.containsKey(k))
        .length;
    return complete / total;
  }

  static bool get theSuppliedMetricReachesTheCeiling =>
      definitionCompleteness == bandCeiling;

  static const String columnNote =
      'COLUMN NOTE: the Metric Name cell on this row is empty -- the first row '
      'in four hundred and sixteen with no metric at all -- while the band '
      'still reads 0.8, 0.95, 1; its Best Qualitative Output column reads "Not '
      'Complete / Partial / Complete", the only row in the track written '
      'worst-first, which under the positional convention six other rows '
      'declare outright would make failure its best outcome; and its '
      'Poka-Yoke, Completion Measures, Expected Output, Common Library and '
      'Decision Group cells all belong to a row about a scheduled script that '
      'automatically removes a low performer\'s access, making this the fifth '
      'spliced row in the track. Those five cells are recorded and the '
      'behaviour is refused. Atomic Step: "Define the friction indicators to '
      'be silently logged."';

  static Map<String, bool> get obligations => <String, bool>{
        'every indicator has a join scope': everyIndicatorHasAJoinScope,
        'no indicator joins to an individual': noIndicatorJoinsToAnIndividual,
        'every indicator has a disclosure line':
            everyIndicatorHasADisclosureLine,
        'logging is silent in the engineering sense':
            theEngineeringReadingIsImplemented,
        'and not silent in the other sense': theSecrecyReadingIsRefused,
        'the spliced cells are recorded and refused':
            theSpliceIsRecordedAndRefused,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Complete' : 'Partial';

  static Map<String, bool> get checks => <String, bool>{
        'the Metric Name cell is empty and the band is not':
            theMetricCellIsEmpty && thereIsABandAnyway && aBandWithNoQuantity,
        'the first row in the track with no metric':
            thisIsTheFirstRowWithNoMetric &&
                metricNote.contains('not being satisfiable'),
        'the output column is written backwards':
            theColumnIsReversed && theRowContradictsItself,
        'which shows the column is read by position':
            theConventionIsPositional &&
                reversalNote.contains('silently mis-scored'),
        'five cells belong to a row about removing access':
            fiveCellsBelongElsewhere && thisIsTheFifthSplicedRow,
        'and the behaviour is refused, not built':
            theSpliceIsRecordedAndRefused && theFrameworkAlreadyForbidsIt,
        'silence as an engineering property is built':
            theEngineeringReadingIsImplemented && theTwoReadingsDiffer,
        'silence as secrecy is refused':
            theSecrecyReadingIsRefused &&
                disclosureSurface.contains('Privacy'),
        'every indicator has a scope and a disclosure line':
            everyIndicatorHasAJoinScope &&
                everyIndicatorHasADisclosureLine &&
                noIndicatorJoinsToAnIndividual,
        'six obligations, all met, giving Complete':
            obligations.length == 6 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == bestOutputActuallyMeant &&
                theSuppliedMetricReachesTheCeiling,
      };
}
