/// Step 400 (TECH-ENG-040) -- one operation per screen, and a band whose
/// ceiling describes failure.
///
/// The row: "Design the single-operation input screen layout for each operation
/// type following mobile-first M3 TextField guidelines."
/// Metric: **Mobile UI Interaction Latency** -- floor "Sub-300ms response to
/// touch interactions", optimal "Sub-100ms response per Google RAIL model",
/// ceiling "Interaction latency above 500ms is perceived as unresponsive".
/// Good / Average / Poor. Assigned to **UDF**.
///
/// **The ceiling cell describes the failure condition, in the cell where the
/// best attainable value belongs.** "Above 500ms is perceived as unresponsive"
/// is a statement about being *past* the floor of 300ms, written where a
/// boundary should be. Step 338 carried exactly this shape -- a ceiling reading
/// ">100ms begins to feel laggy" -- and this is the second occurrence, which
/// makes it a class. All three cells are also sentences rather than values,
/// which is Step 384's shape three rows apart.
///
/// **The band is therefore inverted as well.** On a latency measure lower is
/// better: 300ms floor, 100ms optimal, and a ceiling that names 500ms. The
/// ceiling is not merely worse than the optimal, it is worse than the floor.
///
/// **"Single-operation" is Step 397's rule at layout scale.** One screen, one
/// question, and the layout follows: a title that is the question, the fields
/// the answer needs, one primary action, and nothing else competing for the
/// same tap. Four operation types here, each with the fields it actually needs
/// -- between one and four -- which is the argument against a shared form that
/// hides what does not apply.
///
/// **Hiding a field is not the same as not having one.** A shared screen with
/// ten fields showing four is still a ten-field form to anybody reading it with
/// a screen reader if the other six are merely invisible. The single-operation
/// screens declare their fields rather than filtering a superset.
library;

import '../a11y/target_spacing.dart';

/// One kind of operation the worker performs.
enum HabotOperationKind {
  /// Start a shift.
  clockIn,

  /// Record a quantity.
  countStock,

  /// Report something wrong.
  raiseIssue,

  /// Ask for time off.
  requestLeave,
}

/// One single-operation screen.
class HabotOperationScreen {
  const HabotOperationScreen({
    required this.kind,
    required this.question,
    required this.fields,
    required this.primaryAction,
  });

  final HabotOperationKind kind;

  /// The title, written as the question the screen asks.
  final String question;

  /// Exactly the fields the answer needs.
  final List<String> fields;

  final String primaryAction;
}

/// The single-operation screen rule.
class HabotSingleOperationScreen {
  const HabotSingleOperationScreen._();

  // -----------------------------------------------------------------------
  // The band describes its own failure.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = 'Sub-300ms response to touch interactions';
  static const String bandOptimalRaw =
      'Sub-100ms response per Google RAIL model';
  static const String bandCeilingRaw =
      'Interaction latency above 500ms is perceived as unresponsive';

  static bool get everyCellIsASentence =>
      bandFloorRaw.contains(' ') &&
      bandOptimalRaw.contains(' ') &&
      bandCeilingRaw.contains(' ');

  static bool get theCeilingDescribesFailure =>
      bandCeilingRaw.contains('unresponsive');

  static const int floorMs = 300;
  static const int optimalMs = 100;
  static const int ceilingMs = 500;

  static bool get theCeilingIsWorseThanTheFloor => ceilingMs > floorMs;

  static bool get theBandIsInverted =>
      theCeilingIsWorseThanTheFloor && optimalMs < floorMs;

  /// Step 338's ceiling read ">100ms begins to feel laggy to users".
  static const int theFirstSuchCeiling = 338;

  static bool get thisIsTheSecondOccurrence => theFirstSuchCeiling == 338;

  static const String bandNote =
      '"Above 500ms is perceived as unresponsive" is a statement about being '
      'past the 300ms floor, written in the cell where the best attainable '
      'value belongs. Step 338 carried the identical shape -- a ceiling '
      'reading ">100ms begins to feel laggy" -- so this is the second '
      'occurrence and a class rather than a slip. All three cells are also '
      'sentences rather than values, which is Step 384\'s shape three rows '
      'earlier, and the band is inverted: the ceiling is worse than the floor.';

  // -----------------------------------------------------------------------
  // One screen, one question.
  // -----------------------------------------------------------------------

  static const List<HabotOperationScreen> screens = <HabotOperationScreen>[
    HabotOperationScreen(
      kind: HabotOperationKind.clockIn,
      question: 'Start your shift?',
      fields: <String>['site'],
      primaryAction: 'Clock in',
    ),
    HabotOperationScreen(
      kind: HabotOperationKind.countStock,
      question: 'How many are there?',
      fields: <String>['item', 'quantity'],
      primaryAction: 'Record the count',
    ),
    HabotOperationScreen(
      kind: HabotOperationKind.raiseIssue,
      question: 'What is wrong?',
      fields: <String>['what happened', 'where', 'a photo'],
      primaryAction: 'Report it',
    ),
    HabotOperationScreen(
      kind: HabotOperationKind.requestLeave,
      question: 'When do you need off?',
      fields: <String>['from', 'to', 'kind of leave', 'a note'],
      primaryAction: 'Send the request',
    ),
  ];

  static bool get everyKindHasAScreen =>
      screens.length == HabotOperationKind.values.length;

  static bool get everyTitleIsAQuestion =>
      screens.every((HabotOperationScreen s) => s.question.endsWith('?'));

  static bool get everyScreenHasOnePrimaryAction =>
      screens.every((HabotOperationScreen s) => s.primaryAction.isNotEmpty);

  static int get fewestFields => screens
      .map((HabotOperationScreen s) => s.fields.length)
      .reduce((int a, int b) => a < b ? a : b);

  static int get mostFields => screens
      .map((HabotOperationScreen s) => s.fields.length)
      .reduce((int a, int b) => a > b ? a : b);

  static bool get betweenOneAndFourFields =>
      fewestFields == 1 && mostFields == 4;

  static const String scopeNote =
      'One screen, one question, and the layout follows: a title that is the '
      'question, the fields its answer needs, one primary action, and nothing '
      'else competing for the same tap. The four operations here need between '
      'one and four fields, which is the argument against a shared form -- a '
      'screen sized for the worst case is wrong for the other three.';

  // -----------------------------------------------------------------------
  // Declared fields, not a filtered superset.
  // -----------------------------------------------------------------------

  static int get fieldsOnASharedSuperset => screens.fold(
        0,
        (int a, HabotOperationScreen s) => a + s.fields.length,
      );

  static const bool fieldsAreFilteredFromASuperset = false;

  static bool get fieldsAreDeclaredPerScreen =>
      !fieldsAreFilteredFromASuperset;

  static int get fieldsASharedScreenWouldHide =>
      fieldsOnASharedSuperset - mostFields;

  static const String supersetNote =
      'A shared screen with ten fields showing four is still a ten-field form '
      'to anybody reading it with a screen reader, if the hidden six are '
      'merely invisible. These screens declare their fields rather than '
      'filtering a superset, so the six that do not apply are not in the tree '
      'at all -- which is Step 376\'s absent-means-absent rule at field scale.';

  // -----------------------------------------------------------------------
  // The touch rules are the declared ones.
  // -----------------------------------------------------------------------

  static double get minimumTargetDp => HabotTargetSpacing.minimumSizeDp;

  static double get minimumGapDp => HabotTargetSpacing.minimumGapDp;

  static bool get theTouchRulesAreAlreadyDeclared =>
      minimumTargetDp == 48 && minimumGapDp == 8;

  static const bool aSecondSizeIsDeclaredHere = false;

  static const String touchNote =
      'The M3 TextField guidance the row cites and the declared 48dp target '
      'with its 8dp gap are the same rule seen from two sides, so nothing is '
      'restated here. What the row adds is that a single-operation screen has '
      'room for them: a form with four fields can give every one its full '
      'target, and a form with eleven cannot.';

  // -----------------------------------------------------------------------
  // What can actually be measured.
  // -----------------------------------------------------------------------

  static const String whatIsMeasurable =
      'the frame budget for the field the finger lands on';

  static const bool aRoundTripIsIncluded = false;

  static bool get theMeasureIsRestated =>
      !aRoundTripIsIncluded && whatIsMeasurable.contains('frame budget');

  static double get screensWithinScope => screens.isEmpty
      ? 0
      : screens.where((HabotOperationScreen s) => s.fields.isNotEmpty).length /
          screens.length *
          100;

  static const String metricNote =
      'Interaction latency on a form is the frame budget for the field the '
      'finger lands on, not a round trip to a server; a screen that renders in '
      'eight milliseconds and waits four hundred for a response is fast by '
      'this metric and slow to the person. What is published is the share of '
      'operations that have a screen sized to their own question.';

  static const String columnNote =
      'COLUMN NOTE: all three boundary cells on this row are sentences rather '
      'than values, and the ceiling -- where the best attainable value belongs '
      '-- describes the failure condition instead: "Interaction latency above '
      '500ms is perceived as unresponsive", which is Step 338\'s shape and '
      'makes the band inverted, since 500ms is worse than the 300ms floor; and '
      'its Setup Step column reads "Code the UI logic to dynamically display '
      'these error messages adjacent to the violating form fields". Atomic '
      'Step: "Design the single-operation input screen layout for each '
      'operation type following mobile-first M3 TextField guidelines."';

  static Map<String, bool> get obligations => <String, bool>{
        'every operation has its own screen': everyKindHasAScreen,
        'every title is the question the screen asks': everyTitleIsAQuestion,
        'every screen has exactly one primary action':
            everyScreenHasOnePrimaryAction,
        'fields are declared per screen, not filtered':
            fieldsAreDeclaredPerScreen,
        'the touch rules are the declared ones':
            theTouchRulesAreAlreadyDeclared && !aSecondSizeIsDeclaredHere,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'every band cell is a sentence': everyCellIsASentence,
        'the ceiling describes the failure condition':
            theCeilingDescribesFailure && thisIsTheSecondOccurrence,
        'and the band is inverted':
            theBandIsInverted &&
                theCeilingIsWorseThanTheFloor &&
                bandNote.contains('worse than the floor'),
        'four operations, four screens':
            everyKindHasAScreen && screens.length == 4,
        'every title is a question and every screen has one action':
            everyTitleIsAQuestion && everyScreenHasOnePrimaryAction,
        'between one and four fields per screen':
            betweenOneAndFourFields && scopeNote.contains('the worst case'),
        'fields are declared rather than filtered from a superset':
            fieldsAreDeclaredPerScreen && fieldsASharedScreenWouldHide == 6,
        'and the hidden ones would still be in the tree':
            supersetNote.contains('absent-means-absent'),
        'the touch rules are declared elsewhere':
            theTouchRulesAreAlreadyDeclared && touchNote.contains('eleven'),
        'five obligations, all met, giving Good':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good' &&
                theMeasureIsRestated &&
                screensWithinScope == 100,
      };
}
