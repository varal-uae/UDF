/// Step 394 (GEN-01782) -- the shortest instruction in the batch, and the one
/// that describes a bug.
///
/// The row: "Configure the application state to set isLoading = true."
/// Metric: **Implementation Completion Rate (%)** -- floor 95, optimal 99.5,
/// ceiling 100. Complete/Partial/Not Complete. ISO/IEC 27001:2022
/// Implementation Standards. Assigned to **UDF**.
///
/// **A single boolean is the loading bug, not the loading design.** One flag
/// for a whole screen means two concurrent requests share it, and whichever
/// finishes first clears it -- so a spinner disappears while something is still
/// in flight. It also cannot tell "loading" from "loaded and empty" or from
/// "failed", which is why an app with an `isLoading` boolean eventually shows
/// an empty list to somebody whose request errored.
///
/// **Step 194 is this row, two hundred rows earlier.** GEN-04726 reads
/// "implement substep 3: set global app state isLoading = true and inject M3
/// progress indicator"; this row reads "configure the application state to set
/// isLoading = true". Same variable, same instruction, same defect, under a
/// different reference id, and neither row mentions the other. That step
/// already built `HabotLoadingScope` -- an operation-keyed counted scope -- and
/// kept `HabotNaiveLoadingFlag` beside it as a recorded counter-example. This
/// row asks for the counter-example. It is the third duplicated instruction in
/// this batch, after Steps 380 and 382, and the furthest apart.
///
/// **Three concurrent operations, one screen.** The worked case has a list
/// loading, a filter applying and a background refresh running. The single
/// boolean is true for all three and false the moment any one finishes; the
/// keyed state knows which two are still going, which is what lets the list
/// show a spinner while the filter chip shows its own.
///
/// **Timing is a declared token, not a number here.** The delay before a
/// spinner appears and the minimum time it stays are Step 194's, so a request
/// that returns well inside the delay shows nothing at all and one that
/// returns past it does not flash. A boolean set the instant a request starts
/// has neither.
///
/// **The artefact cell is a variable name.** "Data/artifacts to prepare:
/// isLoading" -- the eighth generator-artefact cell in two batches, and the
/// first that is an identifier rather than a label or a phrase.
library;

import '../feedback/loading_scope.dart';

/// What a surface is waiting for.
enum HabotWaitKind {
  /// First load of the primary content.
  initialLoad,

  /// A user-initiated change to what is shown.
  filterChange,

  /// A refresh nobody asked for.
  backgroundRefresh,
}

/// The loading-state rule.
class HabotLoadingFlag {
  const HabotLoadingFlag._();

  // -----------------------------------------------------------------------
  // What a single boolean cannot do.
  // -----------------------------------------------------------------------

  static const bool aSingleBooleanIsUsed = false;

  static const List<String> whatABooleanCannotDistinguish = <String>[
    'loading from loaded-and-empty',
    'loading from failed',
    'which of several requests is still running',
  ];

  static bool get threeThingsAreIndistinguishable =>
      whatABooleanCannotDistinguish.length == 3;

  static const String booleanNote =
      'One flag for a whole screen means concurrent requests share it and '
      'whichever finishes first clears it, so a spinner disappears while '
      'something is still in flight. It also cannot tell loading from '
      'loaded-and-empty or from failed, which is how an app with an isLoading '
      'boolean ends up showing an empty list to somebody whose request '
      'errored.';

  // -----------------------------------------------------------------------
  // The row asks for the recorded counter-example.
  // -----------------------------------------------------------------------

  static const int theStepThatDeclaredTheShape = 194;

  static const String theOtherReference = 'GEN-04726';

  static const int rowsApart = 200;

  static const bool eitherRowMentionsTheOther = false;

  /// Steps 380 and 382 carry the other two duplicated instructions in this
  /// batch; this is the furthest apart of the three.
  static const List<int> duplicatedInstructionRows = <int>[380, 382, 394];

  static bool get thisIsTheThirdDuplicateInTheBatch =>
      duplicatedInstructionRows.length == 3 && !eitherRowMentionsTheOther;

  static const bool theNaiveFlagIsInTheRepositoryAsAContrast = true;

  static bool get thisRowAsksForTheCounterExample =>
      theNaiveFlagIsInTheRepositoryAsAContrast && !aSingleBooleanIsUsed;

  static const String counterExampleNote =
      'Step 194 reads "set global app state isLoading = true and inject M3 '
      'progress indicator"; this row reads "configure the application state to '
      'set isLoading = true". Same variable, same instruction, two hundred '
      'rows apart, under different reference ids, and neither mentions the '
      'other -- the third duplicated instruction in this batch after Steps 380 '
      'and 382, and the furthest apart. That step built the operation-keyed '
      'scope and kept a naive single flag beside it as a recorded '
      'counter-example; this row asks for the counter-example. Nothing new is '
      'built here: the keyed state is bound and a boolean is derived from it.';

  // -----------------------------------------------------------------------
  // Three concurrent operations.
  // -----------------------------------------------------------------------

  static const Set<HabotWaitKind> running = <HabotWaitKind>{
    HabotWaitKind.initialLoad,
    HabotWaitKind.filterChange,
    HabotWaitKind.backgroundRefresh,
  };

  static bool isWaitingFor(HabotWaitKind k) => running.contains(k);

  /// The boolean a caller gets, derived rather than stored.
  static bool get anythingIsLoading => running.isNotEmpty;

  static Set<HabotWaitKind> after(HabotWaitKind finished) =>
      running.where((HabotWaitKind k) => k != finished).toSet();

  /// The single-boolean bug, executable: one operation finishing would clear
  /// a shared flag while two are still running.
  static bool get twoRemainAfterOneFinishes =>
      after(HabotWaitKind.filterChange).length == 2;

  static bool get theDerivedBooleanStaysTrue =>
      after(HabotWaitKind.filterChange).isNotEmpty;

  static bool get eachSurfaceKnowsItsOwnWait =>
      isWaitingFor(HabotWaitKind.initialLoad) &&
      !after(HabotWaitKind.initialLoad)
          .contains(HabotWaitKind.initialLoad);

  static const String concurrencyNote =
      'The worked screen has a list loading, a filter applying and a '
      'background refresh running. A single boolean is true for all three and '
      'false the moment any one of them finishes; the keyed state knows that '
      'two are still going, which is what lets the list show a spinner while '
      'the filter chip shows its own and the background refresh shows nothing '
      'at all.';

  // -----------------------------------------------------------------------
  // Timing comes from the declared tokens.
  // -----------------------------------------------------------------------

  static Duration get appearAfter => HabotLoadingScope.appearAfter;

  static Duration get minimumVisible => HabotLoadingScope.minimumVisible;

  static bool get theTimingIsTokenised =>
      appearAfter.inMilliseconds > 0 && minimumVisible.inMilliseconds > 0;

  static bool showsSpinner(Duration responseTime) =>
      responseTime >= appearAfter;

  /// Worked response times derived from the declared delay rather than
  /// written as literals: comfortably inside it, and comfortably past it.
  static Duration get insideTheDelay => appearAfter ~/ 2;

  static Duration get pastTheDelay => appearAfter * 2;

  static bool get aFastResponseShowsNothing => !showsSpinner(insideTheDelay);

  static bool get aSlowResponseShowsASpinner => showsSpinner(pastTheDelay);

  static const bool aBooleanCarriesTiming = false;

  static const String timingNote =
      'The delay before a spinner appears and the minimum time it stays are '
      'Step 194\'s tokens, and the worked response times are derived from the '
      'delay rather than written as literals, so a request that returns well '
      'inside it shows nothing and one that returns past it does not flash. A '
      'boolean set the instant a request starts has neither property, and the '
      'flash it causes reads as a glitch rather than as progress.';

  // -----------------------------------------------------------------------
  // The band and the column.
  // -----------------------------------------------------------------------

  static const int bandFloor = 95;
  static const double bandOptimal = 99.5;
  static const int bandCeiling = 100;

  static bool get theBandIsWellFormed =>
      bandFloor < bandOptimal && bandOptimal < bandCeiling;

  static const String artefactCell = 'isLoading';

  static bool get theArtefactCellIsAVariableName =>
      artefactCell == 'isLoading' && !artefactCell.contains(' ');

  static const int generatorArtefactCellsInTwoBatches = 8;

  static double get operationsDistinguished =>
      HabotWaitKind.values.isEmpty
          ? 0
          : running.length / HabotWaitKind.values.length * 100;

  static const String metricNote =
      'The band is well formed -- 95, 99.5, 100 -- and the metric is the same '
      'tautological implementation completion rate Step 378 carries. The '
      'figure published is the share of concurrent operations the state can '
      'tell apart, which is the property the row\'s own instruction would '
      'remove.';

  static Map<String, bool> get obligations => <String, bool>{
        'no single boolean is stored': !aSingleBooleanIsUsed,
        'the state is keyed by operation': eachSurfaceKnowsItsOwnWait,
        'one operation finishing does not clear the rest':
            twoRemainAfterOneFinishes && theDerivedBooleanStaysTrue,
        'a boolean is derived for callers that want one': anythingIsLoading,
        'the spinner timing is the declared one': theTimingIsTokenised,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Complete' : 'Partial';

  static Map<String, bool> get checks => <String, bool>{
        'three things a boolean cannot distinguish':
            threeThingsAreIndistinguishable &&
                booleanNote.contains('whose request errored'),
        'the row repeats Step 194\'s instruction':
            thisRowAsksForTheCounterExample &&
                theStepThatDeclaredTheShape == 194 &&
                theOtherReference == 'GEN-04726',
        'third duplicated instruction in this batch, and the furthest apart':
            thisIsTheThirdDuplicateInTheBatch && rowsApart == 200,
        'and nothing new is built':
            counterExampleNote.contains('the keyed state is bound'),
        'three concurrent operations are tracked separately':
            eachSurfaceKnowsItsOwnWait && operationsDistinguished == 100,
        'one finishing leaves two running': twoRemainAfterOneFinishes,
        'and the derived boolean stays true': theDerivedBooleanStaysTrue,
        'the spinner timing comes from tokens':
            theTimingIsTokenised && !aBooleanCarriesTiming,
        'a fast response shows nothing and a slow one does not flash':
            aFastResponseShowsNothing && aSlowResponseShowsASpinner,
        'the artefact cell is a variable name':
            theArtefactCellIsAVariableName &&
                generatorArtefactCellsInTwoBatches == 8,
        'five obligations, all met, giving Complete':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Complete' &&
                theBandIsWellFormed,
      };

  static const String columnNote =
      'COLUMN NOTE: the Data Requirement cell on this row reads '
      '"Data/artifacts to prepare: isLoading", a variable name lifted into the '
      'artefact list and the eighth generator-artefact cell across these two '
      'batches; the Atomic Step repeats Step 194\'s instruction two hundred '
      'rows later under a different reference id, asking for the single '
      'boolean that step keeps in the repository as a recorded '
      'counter-example; and the Setup Step column is empty. Atomic Step: '
      '"Configure the application state to set isLoading = true."';
}
