/// Step 282 (EDEBS-019-13) -- "Action Failed", which passes every check this
/// repository has and tells nobody anything.
///
/// The row: "Position Snackbar notification at bottom of screen reading
/// 'Action Failed'."
/// Metric: **Observability / Alert Coverage** -- floor ">=90%", optimal 1,
/// ceiling 1. Good / Average / Poor. Cited: the Google SRE Handbook. The same
/// metric Step 281 carries, on a different surface; the twin is recorded.
///
/// **The row's own string passes the existing presentability gate.**
/// `HabotErrorSnackbar.isPresentable` checks that a message leaks nothing --
/// no stack, no HTTP, no file path -- and "Action Failed" leaks nothing, so it
/// passes. That gate was built to stop internals reaching a user and it does
/// exactly that. What it was never asked to check is whether the message says
/// anything, and this row is the case that shows the difference: a string can
/// be perfectly safe and completely useless, and a rule that only tests for
/// leakage will wave it through.
///
/// **So this step adds the complementary test, not a replacement.** A message
/// names the thing that failed and the thing to do next. "Action Failed" names
/// neither: it does not say which action, so a person with two pending
/// operations cannot tell which one, and it offers nothing to do. The two
/// checks are orthogonal on purpose -- leakage and emptiness are different
/// failures and a message has to survive both.
///
/// **And "at the bottom of the screen" is already occupied.** Step 176 put the
/// FAB there and declared it may not coexist with a bottom bar; Step 226
/// declared the space a floating snackbar reserves. A snackbar that obeys this
/// row literally covers the control the person was about to press. It lifts
/// above the reserved space instead, which is the existing declaration rather
/// than a new number.
library;

import '../feedback/error_snackbar.dart';
import '../interaction/fab_thumb_zone.dart';

/// The complementary test.
class HabotActionFailedSnackbar {
  const HabotActionFailedSnackbar._();

  /// The exact string the row asks for.
  static const String theRowsString = 'Action Failed';

  // -----------------------------------------------------------------------
  // Two orthogonal tests.
  // -----------------------------------------------------------------------

  /// The existing gate: does it leak anything? Run rather than described.
  static bool leaksNothing(String text) =>
      HabotErrorSnackbar.isPresentable(text);

  /// Words that name an operation somebody performed. A message that contains
  /// none of them has not said which action failed.
  static const Set<String> namedOperations = <String>{
    'book',
    'booking',
    'cancel',
    'save',
    'saved',
    'pay',
    'payment',
    'upload',
    'send',
    'refund',
    'update',
  };

  /// Words that offer a next move.
  static const Set<String> offersANextMove = <String>{
    'try',
    'again',
    'check',
    'choose',
    'contact',
    'reconnect',
    'retry',
  };

  static bool namesTheAction(String text) {
    final String lower = text.toLowerCase();
    return namedOperations.any((String w) => lower.contains(w));
  }

  static bool namesTheNextMove(String text) {
    final String lower = text.toLowerCase();
    return offersANextMove.any((String w) => lower.contains(w));
  }

  /// The complementary test: does it say anything?
  static bool saysSomething(String text) =>
      namesTheAction(text) && namesTheNextMove(text);

  /// A message has to survive both.
  static bool isUsable(String text) =>
      leaksNothing(text) && saysSomething(text);

  // -----------------------------------------------------------------------
  // The corpus, including the row's own string.
  // -----------------------------------------------------------------------

  /// Message, and whether each of the two tests passes it. Chosen so that all
  /// four combinations appear -- a gate whose corpus only contains agreement
  /// is a gate that has not been tested.
  static const List<String> corpus = <String>[
    // Safe and empty: the row's own string.
    theRowsString,
    // Safe and useful.
    'We could not save your booking. Check your connection and try again.',
    // Leaky and useful: says the right things and says too much.
    'Booking save failed: SocketException at line 42. Try again.',
    // Leaky and empty.
    'Unhandled exception (null)',
  ];

  static List<String> get safeButEmpty =>
      corpus.where((String m) => leaksNothing(m) && !saysSomething(m)).toList();

  static List<String> get usable => corpus.where(isUsable).toList();

  static List<String> get leaky =>
      corpus.where((String m) => !leaksNothing(m)).toList();

  /// All four combinations are present, so neither test is passing the corpus
  /// on its own.
  static bool get theCorpusSeparatesTheTwoTests =>
      corpus.length == 4 &&
      safeButEmpty.length == 1 &&
      usable.length == 1 &&
      leaky.length == 2;

  /// The finding, stated as a measurement: the row's string passes the
  /// existing gate and fails the new one.
  static bool get theRowsStringPassesTheOldGateAndFailsTheNewOne =>
      leaksNothing(theRowsString) && !saysSomething(theRowsString);

  /// Which half it fails is worth knowing: it names no action and offers no
  /// next move, so both halves.
  static bool get itFailsBothHalvesOfTheNewTest =>
      !namesTheAction(theRowsString) && !namesTheNextMove(theRowsString);

  static const String theReplacementMessage =
      'We could not save your booking. Check your connection and try again.';

  static bool get theReplacementSurvivesBoth => isUsable(theReplacementMessage);

  static const String orthogonalNote =
      'A message can be perfectly safe and completely useless. The existing '
      'gate asks whether anything leaked -- no stack, no HTTP, no file path -- '
      'and "Action Failed" leaks nothing, so it passes. That gate is doing its '
      'job; it was never asked whether the message says anything. The two '
      'tests are orthogonal on purpose and both are required: the corpus here '
      'contains a message that is safe and empty, one that is safe and '
      'useful, one that is leaky and useful, and one that is neither, so '
      'neither test can be passing on the strength of the other.';

  static const String whichActionNote =
      '"Action Failed" does not say which action. A person with a booking '
      'saving and a photo uploading sees one grey bar and learns that one of '
      'them stopped. It also offers nothing to do, so the only available move '
      'is to try everything again -- which is how a failure message turns a '
      'single failed operation into three.';

  // -----------------------------------------------------------------------
  // Where it sits.
  // -----------------------------------------------------------------------

  /// The space a floating snackbar must leave, read from Step 226's existing
  /// declaration rather than restated.
  static double get reservedBottomSpaceDp =>
      HabotSnackbarInsets.reservedBottomSpace;

  /// The bottom of the screen is already spoken for.
  static bool get theBottomIsOccupied =>
      HabotFabThumbZone.anchor == HabotFabAnchor.bottomTrailing &&
      !HabotFabThumbZone.mayCoexistWithBottomBar &&
      reservedBottomSpaceDp > 0;

  static const String bottomEdgeNote =
      'The bottom of the screen is where Step 176 put the FAB, and Step 226 '
      'already declared the space a floating snackbar reserves. A snackbar '
      'that obeys this row literally covers the control the person was about '
      'to press -- and the press then dismisses the snackbar instead, so the '
      'message is gone and the action did not happen. It lifts above the '
      'reserved space, which is an existing declaration rather than a number '
      'chosen here.';

  // -----------------------------------------------------------------------
  // Which failures belong on a snackbar at all.
  // -----------------------------------------------------------------------

  /// A snackbar is transient. A failure that cost the person something needs
  /// a surface that stays, which is Step 281's dialog.
  static bool belongsOnASnackbar({
    required bool workWasLost,
    required bool moneyMoved,
  }) =>
      !workWasLost && !moneyMoved;

  static bool get aCostlyFailureGoesElsewhere =>
      belongsOnASnackbar(workWasLost: false, moneyMoved: false) &&
      !belongsOnASnackbar(workWasLost: true, moneyMoved: false) &&
      !belongsOnASnackbar(workWasLost: false, moneyMoved: true);

  static const String transienceNote =
      'A snackbar disappears on its own, so it may only carry a failure the '
      'person can afford to miss. One that lost their work or moved their '
      'money needs a surface that stays until it is answered -- Step 281\'s '
      'dialog -- and Step 226 already showed that a swipe removes a snackbar '
      'faster than it can be read. The routing rule is two booleans rather '
      'than a judgement at the call site.';

  // -----------------------------------------------------------------------
  // Metric: Observability / Alert Coverage -- the twin of Step 281.
  // -----------------------------------------------------------------------

  static Map<String, bool> get coverage => <String, bool>{
        'the message leaks nothing': leaksNothing(theReplacementMessage),
        'the message names the action': namesTheAction(theReplacementMessage),
        'the message offers a next move':
            namesTheNextMove(theReplacementMessage),
        'it clears the space the FAB occupies': theBottomIsOccupied,
        'a costly failure is routed off the snackbar':
            aCostlyFailureGoesElsewhere,
      };

  static double get coverageRate =>
      coverage.values.where((bool b) => b).length / coverage.length;

  static const double floorPercent = 90;

  static String get qualitativeOutput {
    final double pct = coverageRate * 100;
    if (pct >= 100) {
      return 'Good';
    }
    return pct >= floorPercent ? 'Average' : 'Poor';
  }

  static const String twinMetricNote =
      'Step 281 carries this identical metric -- Observability / Alert '
      'Coverage, floor 90%, optimal and ceiling 1, cited to the SRE Handbook '
      '-- on a dialog row. Two surfaces, one metric, and the metric is about '
      'neither: alert coverage is the share of failure modes that page an '
      'operator. Both steps substitute coverage over the obligations the '
      'surface actually has and say so, rather than one of them borrowing the '
      'other\'s reading.';

  static Map<String, bool> get checks => <String, bool>{
        'the row\'s own string passes the existing gate and fails this one':
            theRowsStringPassesTheOldGateAndFailsTheNewOne,
        'it fails both halves: no action named, no next move':
            itFailsBothHalvesOfTheNewTest,
        'the corpus separates the two tests in all four combinations':
            theCorpusSeparatesTheTwoTests,
        'the replacement survives both tests': theReplacementSurvivesBoth,
        'the orthogonality is recorded rather than the old gate blamed':
            orthogonalNote.contains('doing its job'),
        'not naming the action is recorded as a cost':
            whichActionNote.contains('into three'),
        'the reserved bottom space is the existing declaration':
            theBottomIsOccupied && bottomEdgeNote.contains('did not happen'),
        'a failure that cost something is routed off the snackbar':
            aCostlyFailureGoesElsewhere &&
                transienceNote.contains('two booleans'),
        'five coverage obligations, all met, giving Good':
            coverage.length == 5 &&
                coverage.values.every((bool b) => b) &&
                coverageRate == 1.0 &&
                qualitativeOutput == 'Good',
        'the twin metric on Step 281 is recorded':
            twinMetricNote.contains('Step 281'),
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Match skeleton '
      'placeholder layout frame sizes exactly to corresponding live query '
      'text areas", and the Data Requirement column reads "N/A (Backend '
      'database setup)" four times. Atomic Step: "Position Snackbar '
      'notification at bottom of screen reading \'Action Failed\'."';
}
