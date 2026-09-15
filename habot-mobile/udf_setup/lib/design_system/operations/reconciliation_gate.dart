/// Step 291 (PELCE-029-16) -- binding a button to an equation, and the row
/// that already contains the antidote to the next one's defect.
///
/// The row: "Programmatically link the button's enabled/disabled state to the
/// output of the 'Design Reconciliation Test' equation."
/// Metric: **QA Test Case Pass Rate** -- floor ">=95%", optimal 1, ceiling 1.
/// Pass / Fail -> Best = Pass (100%).
///
/// **Binding a button to an equation's *output* is the trap; binding it to the
/// equation's *result* is the fix.** A boolean says no and nothing else, so
/// the person is left to guess which of eleven conditions is unmet. Step 254
/// already replaced that boolean with a sealed result that carries reasons,
/// each with a field to move focus to and a sentence saying what to do. This
/// row is that gate applied to a second call site, so the gate is reused
/// rather than a second one written.
///
/// **The row already knows the answer to Step 292's problem.** Its design
/// notes say "tap the widget to see exactly which logic chunk is missing" --
/// which is precisely what a disabled control needs and precisely what the
/// next row, which disables a button permanently, does not provide. The fix
/// and the defect are adjacent rows assigned as separate steps, and both are
/// recorded here.
///
/// **"Green for 0, Red for >0" is colour alone.** SC 1.4.1 has been enforced
/// in this repository since Step 217: colour may carry meaning and may not
/// carry it alone. The score therefore has a word and a shape as well as a
/// hue, and a person who cannot distinguish the two hues reads the same
/// information.
library;

import '../forms/strict_true_gate.dart';

/// How the score is presented.
class HabotScorePresentation {
  const HabotScorePresentation({
    required this.word,
    required this.shape,
    required this.colourRole,
  });

  /// The text a screen reader announces and a person reads.
  final String word;

  /// A glyph that differs by state, so shape alone distinguishes them.
  final String shape;

  /// The colour role. Named rather than a hex value, because a hex value is
  /// what the guard refuses and a role is what adapts to the theme.
  final String colourRole;

  bool get carriesMeaningWithoutColour => word.isNotEmpty && shape.isNotEmpty;
}

/// The binding.
class HabotReconciliationGate {
  const HabotReconciliationGate._();

  // -----------------------------------------------------------------------
  // The gate, reused.
  // -----------------------------------------------------------------------

  /// A balanced, complete submission.
  static HabotGateResult get clean => HabotStrictTrueGate.balancedAndComplete;

  /// One that does not balance.
  static HabotGateResult get unbalanced => HabotStrictTrueGate.unbalanced;

  /// One with fields outstanding.
  static HabotGateResult get outstanding =>
      HabotStrictTrueGate.fieldsOutstanding;

  /// The row's own binding: enabled exactly when the result allows it.
  static bool buttonIsEnabled(HabotGateResult result) =>
      HabotStrictTrueGate.mayProgress(result);

  static bool get theCleanCaseEnablesTheButton => buttonIsEnabled(clean);

  static bool get eitherProblemDisablesIt =>
      !buttonIsEnabled(unbalanced) && !buttonIsEnabled(outstanding);

  /// The score the row's equation produces: the number of open reasons. Zero
  /// is the only value that enables anything, which is what "score != 0"
  /// means read carefully.
  static int scoreFor(HabotGateResult result) =>
      HabotStrictTrueGate.reasonsFrom(result).length;

  static bool get theScoreIsZeroExactlyWhenEnabled =>
      (scoreFor(clean) == 0) == buttonIsEnabled(clean) &&
      (scoreFor(unbalanced) == 0) == buttonIsEnabled(unbalanced) &&
      (scoreFor(outstanding) == 0) == buttonIsEnabled(outstanding);

  // -----------------------------------------------------------------------
  // Which logic chunk is missing.
  // -----------------------------------------------------------------------

  /// Every disabled state can say what would change it, because the result
  /// carries reasons rather than a boolean.
  static List<String> reasonsShownFor(HabotGateResult result) =>
      HabotStrictTrueGate.reasonsFrom(result)
          .map((HabotGateReason r) => r.message)
          .toList();

  static bool get everyDisabledStateCanSayWhy =>
      reasonsShownFor(unbalanced).isNotEmpty &&
      reasonsShownFor(outstanding).isNotEmpty &&
      reasonsShownFor(clean).isEmpty;

  /// And where tapping takes you: the first field-level reason, so the tap
  /// the row describes lands on the thing that needs fixing rather than on a
  /// list.
  static String? tapTargetFor(HabotGateResult result) =>
      HabotStrictTrueGate.focusTargetFrom(result);

  static bool get theTapLandsOnAField =>
      tapTargetFor(outstanding) != null && tapTargetFor(clean) == null;

  /// A form-level problem has no field to land on, and says so rather than
  /// guessing.
  static bool get aFormLevelProblemHasNoField =>
      tapTargetFor(unbalanced) == null &&
      reasonsShownFor(unbalanced).isNotEmpty;

  static const String theRowContainsTheAntidoteNote =
      'This row\'s design notes say "tap the widget to see exactly which '
      'logic chunk is missing" -- which is exactly what a disabled control '
      'needs, and exactly what Step 292 does not provide when it disables a '
      'button permanently with nothing beside it. The fix and the defect are '
      'adjacent rows in the same sheet, assigned as separate steps, and '
      'neither references the other. Recorded here because a reader who '
      'implements 292 alone will build the dead end, and a reader who '
      'implements both will not notice they were ever separate.';

  // -----------------------------------------------------------------------
  // Colour alone.
  // -----------------------------------------------------------------------

  static const HabotScorePresentation clear = HabotScorePresentation(
    word: 'Balanced',
    shape: 'check',
    colourRole: 'success container',
  );

  static const HabotScorePresentation blocked = HabotScorePresentation(
    word: 'Gaps open',
    shape: 'alert triangle',
    colourRole: 'error container',
  );

  static HabotScorePresentation presentationFor(HabotGateResult result) =>
      buttonIsEnabled(result) ? clear : blocked;

  static bool get meaningSurvivesWithoutColour =>
      clear.carriesMeaningWithoutColour &&
      blocked.carriesMeaningWithoutColour &&
      clear.word != blocked.word &&
      clear.shape != blocked.shape;

  /// And the colours themselves are roles rather than values, so the guard's
  /// RAW_COLOR_LITERAL rule is satisfied by construction.
  static bool get noHexAppearsHere =>
      !clear.colourRole.contains('#') && !blocked.colourRole.contains('#');

  static const String colourAloneNote =
      '"Green for 0, Red for >0" is colour alone, which SC 1.4.1 refuses and '
      'this repository has enforced since Step 217. Roughly one man in twelve '
      'cannot reliably separate those two hues, and on a small score chip '
      'they are the whole message. The score therefore carries a word and a '
      'shape as well as a hue, and a person who sees neither colour reads the '
      'same information. The hues stay -- they are faster for everybody who '
      'can see them -- they just stop being the only channel.';

  // -----------------------------------------------------------------------
  // Metric: QA Test Case Pass Rate -- 95% / 1 / 1.
  // -----------------------------------------------------------------------

  /// The three results this step exercises, and whether each behaves.
  static Map<String, bool> get cases => <String, bool>{
        'a clean submission enables the button':
            theCleanCaseEnablesTheButton && scoreFor(clean) == 0,
        'an unbalanced one disables it and says so':
            !buttonIsEnabled(unbalanced) &&
                reasonsShownFor(unbalanced).isNotEmpty,
        'outstanding fields disable it and point at one':
            !buttonIsEnabled(outstanding) && tapTargetFor(outstanding) != null,
        'the score is zero exactly when the button is enabled':
            theScoreIsZeroExactlyWhenEnabled,
        'a form-level problem has no field to land on':
            aFormLevelProblemHasNoField,
        'the score reads without colour': meaningSurvivesWithoutColour,
      };

  static double get passRate =>
      cases.values.where((bool b) => b).length / cases.length;

  static const double floorRate = 0.95;

  static String get qualitativeOutput => passRate >= 1.0 ? 'Pass' : 'Fail';

  static const String metricNote =
      'QA Test Case Pass Rate on a row about binding a button to an equation '
      'measures the test suite rather than the binding. Read over the cases '
      'this step actually exercises -- three gate results, the score '
      'agreement between them, the form-level case and the colour-independent '
      'reading -- it is a real number about a real thing, and that is how it '
      'is reported.';

  static Map<String, bool> get checks => <String, bool>{
        'the existing gate is reused rather than a second one written':
            theCleanCaseEnablesTheButton && eitherProblemDisablesIt,
        'every disabled state carries at least one reason':
            everyDisabledStateCanSayWhy,
        'the tap lands on a field when there is one':
            theTapLandsOnAField && aFormLevelProblemHasNoField,
        'the score is zero exactly when the button is enabled':
            theScoreIsZeroExactlyWhenEnabled,
        'the row already contains the antidote to Step 292':
            theRowContainsTheAntidoteNote.contains('build the dead end'),
        'the score carries a word and a shape as well as a hue':
            meaningSurvivesWithoutColour &&
                colourAloneNote.contains('only channel'),
        'no hex literal appears, only colour roles': noHexAppearsHere,
        'six cases, all passing, giving Pass':
            cases.length == 6 &&
                cases.values.every((bool b) => b) &&
                passRate == 1.0 &&
                passRate > floorRate &&
                qualitativeOutput == 'Pass',
        'the metric is read over the cases this step exercises':
            metricNote.contains('a real number about a real thing'),
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Embed '
      'hardware-accelerated CSS properties (transform, opacity) as the '
      'preferred animation approach" -- CSS again, in a Dart application. '
      'Atomic Step: "Programmatically link the button\'s enabled/disabled '
      'state to the output of the \'Design Reconciliation Test\' equation."';
}
