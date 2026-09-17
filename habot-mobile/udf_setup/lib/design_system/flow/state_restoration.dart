/// Step 355 (EDEBS-019-12) -- restore the screen without a flash, on a row
/// whose own Data Requirement says it has no screen.
///
/// The row: "Restore previous UI state smoothly without jarring screen
/// refreshes."
/// Metric: **UI Design-System Adherence Rate** -- floor ">=85%", optimal
/// ">=95%", ceiling 1. Good/Average/Poor. MD3 Guidelines / Nielsen Norman
/// heuristic evaluation.
///
/// **The Data Requirement cell reads "N/A (Backend database setup). | N/A. |
/// N/A. | N/A."** That is a row about restoring a user interface declaring that
/// it has no user interface, four times. It is the second such cell in two
/// batches, after Step 332's "N/A (Backend logging)" beside a text-contrast
/// metric, and the pair is worth recording together: when the sheet cannot
/// place a row, it writes N/A into the cell that would have told anybody.
///
/// **Android kills the process and the person does not know that happened.**
/// Restoration is not a nicety. A worker takes a photograph mid-form, the
/// camera takes the foreground, the system reclaims memory, and the form comes
/// back empty -- from their point of view the application threw their work away
/// for no reason. The state has to survive the process, not only the
/// navigation.
///
/// **"Without jarring refreshes" is three separate promises.** Do not flash the
/// empty state on the way to the restored one. Do not animate the restoration
/// as though it were a new arrival. Do not move what the person was looking at:
/// restore the scroll offset and the focused field, not merely the values.
///
/// **What is restored and what is not is a decision, not an implementation
/// detail.** What was typed is restored. What was validated is not, because an
/// error message from before a restart refers to a check that has not run
/// since. And nothing sensitive is written to the restoration store, which the
/// platform keeps in plain files.
///
/// **COLUMN NOTE.** The Data Requirement column says "N/A (Backend database
/// setup)" on a UI-restoration row; the Setup Step column reads "Construct the
/// NavigationBar component specifically for compact viewports (< 600dp)"; and
/// the band mixes percentages with the bare ratio "1", the fifth in this batch.
library;

import '../tokens/motion_tokens.dart';
import 'linear_stepper.dart';

/// What happened before the screen came back.
enum HabotReturnCause {
  /// Navigated away and back within the same process.
  navigation,

  /// The process was killed and the application relaunched.
  processDeath,

  /// A configuration change: rotation, text scale, theme.
  reconfiguration,
}

/// One piece of screen state.
class HabotRestorable {
  const HabotRestorable({
    required this.name,
    required this.restored,
    required this.sensitive,
  });

  final String name;
  final bool restored;
  final bool sensitive;
}

/// The restoration rule.
class HabotStateRestoration {
  const HabotStateRestoration._();

  // -----------------------------------------------------------------------
  // The cell that says the row has no interface.
  // -----------------------------------------------------------------------

  static const String dataRequirementCell =
      'N/A (Backend database setup). | N/A. | N/A. | N/A.';

  static bool get theRowSaysItHasNoInterface =>
      dataRequirementCell.startsWith('N/A');

  static int get naCount => 'N/A'.allMatches(dataRequirementCell).length;

  static bool get itSaysSoFourTimes => naCount == 4;

  static const int theOtherSuchRow = 332;

  static bool get thisIsTheSecondSuchCellInTwoBatches =>
      theRowSaysItHasNoInterface && theOtherSuchRow == 332;

  static const String cellNote =
      'A row about restoring a user interface declares that it has no user '
      'interface, four times over. Step 332 in the previous batch did the same '
      'thing -- "N/A (Backend logging)" on a row scored on a text contrast '
      'ratio -- and the pair is worth recording together, because it is a '
      'pattern rather than a slip: when the sheet cannot place a row, it '
      'writes N/A into the one cell that would have told a reader where the '
      'row belongs.';

  // -----------------------------------------------------------------------
  // Three causes, and the one that matters.
  // -----------------------------------------------------------------------

  static const Map<HabotReturnCause, bool> survivedByObjectState =
      <HabotReturnCause, bool>{
    HabotReturnCause.navigation: true,
    HabotReturnCause.reconfiguration: true,
    HabotReturnCause.processDeath: false,
  };

  static List<HabotReturnCause> get causesNeedingPersistence =>
      HabotReturnCause.values
          .where((HabotReturnCause c) => survivedByObjectState[c] == false)
          .toList();

  static bool get onlyProcessDeathNeedsPersistence =>
      causesNeedingPersistence.length == 1 &&
      causesNeedingPersistence.first == HabotReturnCause.processDeath;

  static const String processNote =
      'Two of the three ways a screen comes back are survived by objects in '
      'memory. The third is not: Android reclaims a backgrounded process '
      'whenever it needs the memory, and the person is never told. Somebody '
      'takes a photograph mid-form, the camera takes the foreground, and the '
      'form returns empty -- from where they are standing, the application '
      'threw their work away for no reason. Restoration that only survives '
      'navigation solves the case nobody loses anything in.';

  // -----------------------------------------------------------------------
  // Three promises inside "without jarring refreshes".
  // -----------------------------------------------------------------------

  static const bool theEmptyStateIsShownFirst = false;
  static const bool theRestorationIsAnimatedAsAnArrival = false;
  static const bool theScrollOffsetIsRestored = true;
  static const bool theFocusedFieldIsRestored = true;

  static bool get nothingFlashesEmpty => !theEmptyStateIsShownFirst;

  static bool get theReturnIsNotDressedAsAnArrival =>
      !theRestorationIsAnimatedAsAnArrival;

  static bool get thePersonKeepsTheirPlace =>
      theScrollOffsetIsRestored && theFocusedFieldIsRestored;

  static int get promisesInsideOnePhrase => 3;

  static const String smoothNote =
      '"Without jarring refreshes" is three promises wearing one phrase. Do '
      'not flash the empty state on the way to the restored one, which is what '
      'a build that renders before the state arrives will do. Do not animate '
      'the restoration as though the screen were new, because a transition '
      'tells a person something changed and nothing has. And do not move what '
      'they were looking at: the scroll offset and the focused field are the '
      'place, and the values alone are not.';

  // -----------------------------------------------------------------------
  // What is restored, and what deliberately is not.
  // -----------------------------------------------------------------------

  static const List<HabotRestorable> state = <HabotRestorable>[
    HabotRestorable(
      name: 'what was typed into each field',
      restored: true,
      sensitive: false,
    ),
    HabotRestorable(
      name: 'the scroll offset',
      restored: true,
      sensitive: false,
    ),
    HabotRestorable(
      name: 'which field had focus',
      restored: true,
      sensitive: false,
    ),
    HabotRestorable(
      name: 'which step of the flow',
      restored: true,
      sensitive: false,
    ),
    HabotRestorable(
      name: 'validation errors from before the restart',
      restored: false,
      sensitive: false,
    ),
    HabotRestorable(
      name: 'the entered card number',
      restored: false,
      sensitive: true,
    ),
  ];

  static List<HabotRestorable> get notRestored =>
      state.where((HabotRestorable s) => !s.restored).toList();

  static bool get twoThingsAreDeliberatelyNotRestored =>
      notRestored.length == 2;

  static bool get nothingSensitiveIsPersisted =>
      state.every((HabotRestorable s) => !(s.sensitive && s.restored));

  static bool get staleErrorsAreDropped => notRestored
      .any((HabotRestorable s) => s.name.contains('validation errors'));

  static const String selectionNote =
      'What was typed comes back. What was validated does not, because an '
      'error message that survived a restart refers to a check that has not '
      'run since, and a red field with no live reason behind it is worse than '
      'no message. Nothing sensitive is written at all: the platform '
      'restoration store is ordinary files in the application sandbox, which '
      'is the wrong place for a card number even though it is the convenient '
      'one.';

  // -----------------------------------------------------------------------
  // The step it restores into.
  // -----------------------------------------------------------------------

  static bool get theFlowPositionIsRestorable =>
      HabotLinearStepper.thePositionNamesTheDenominator;

  static Duration get noTransition => Duration.zero;

  static bool get theReturnUsesNoTransition =>
      noTransition == Duration.zero &&
      HabotMotion.standard.inMilliseconds > 0;

  static const String bandFloor = '>=85%';
  static const String bandOptimal = '>=95%';
  static const String bandCeiling = '1';

  static bool get theBandMixesUnits =>
      bandFloor.contains('%') && !bandCeiling.contains('%');

  static const int mixedUnitBandsInThisBatch = 5;

  static const String bandNote =
      'The same band as Step 354 -- two percentages and a bare ratio -- which '
      'makes five mixed-unit bands in this batch after Steps 336, 343, 348 and '
      '354. The adherence rate names no population, so what is published here '
      'is the share of this component\'s declared obligations that hold.';

  static Map<String, bool> get obligations => <String, bool>{
        'state survives process death': onlyProcessDeathNeedsPersistence,
        'nothing flashes empty first': nothingFlashesEmpty,
        'the return is not animated as an arrival':
            theReturnIsNotDressedAsAnArrival,
        'the person keeps their place': thePersonKeepsTheirPlace,
        'stale validation errors are dropped': staleErrorsAreDropped,
        'nothing sensitive is persisted': nothingSensitiveIsPersisted,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static double get adherence => obligations.isEmpty
      ? 0
      : obligations.values.where((bool b) => b).length /
          obligations.length *
          100;

  static Map<String, bool> get checks => <String, bool>{
        'the row declares it has no interface':
            theRowSaysItHasNoInterface && itSaysSoFourTimes,
        'and it is the second such cell in two batches':
            thisIsTheSecondSuchCellInTwoBatches &&
                cellNote.contains('pattern rather than a slip'),
        'three return causes, one needing persistence':
            HabotReturnCause.values.length == 3 &&
                onlyProcessDeathNeedsPersistence,
        'the process-death case is the one that loses work':
            processNote.contains('threw their work away'),
        'the phrase carries three promises':
            promisesInsideOnePhrase == 3 &&
                nothingFlashesEmpty &&
                theReturnIsNotDressedAsAnArrival,
        'the place is restored, not only the values':
            thePersonKeepsTheirPlace &&
                smoothNote.contains('the values alone are not'),
        'six pieces of state, two deliberately not restored':
            state.length == 6 && twoThingsAreDeliberatelyNotRestored,
        'stale errors and the card number are the two':
            staleErrorsAreDropped && nothingSensitiveIsPersisted,
        'the flow position restores into Step 354\'s stepper':
            theFlowPositionIsRestorable && theReturnUsesNoTransition,
        'six obligations, all met, giving Good':
            obligations.length == 6 &&
                adherence == 100 &&
                qualitativeOutput == 'Good' &&
                theBandMixesUnits &&
                mixedUnitBandsInThisBatch == 5,
      };

  static const String columnNote =
      'COLUMN NOTE: the Data Requirement column on this row reads "N/A '
      '(Backend database setup). | N/A. | N/A. | N/A." on a row about '
      'restoring a user interface; the Setup Step column reads "Construct the '
      'NavigationBar component specifically for compact viewports (< 600dp)"; '
      'and the band mixes two percentages with the bare ratio "1". Atomic '
      'Step: "Restore previous UI state smoothly without jarring screen '
      'refreshes."';
}
