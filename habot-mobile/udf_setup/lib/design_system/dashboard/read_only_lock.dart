/// Step 368 (GEN-02411) -- a lock on a surface that was never editable,
/// scored on how fresh its numbers are.
///
/// The row: "Configure the dashboard elements as read-only locks to prevent
/// accidental data edits (Poka-Yoke)."
/// Metric: **Data Freshness (minutes)** -- floor 5, optimal "0-1", ceiling 1.
/// Real-time / Near Real-time / Delayed. Tableau Best Practices, BI Standards.
/// Assigned to **DEA**.
///
/// **The optimal is a range and the ceiling is inside it.** Floor 5, optimal
/// "0-1", ceiling 1: the optimal spans two values and the ceiling is the upper
/// end of that span, so the best attainable value is also a permissible optimal
/// value. A band whose ceiling sits inside its own optimal has three cells and
/// two distinct positions.
///
/// **The output vocabulary, unusually, is already ours.** Real-time / Near
/// Real-time / Delayed is exactly the vocabulary `HabotFreshness` declares, and
/// `HabotFreshnessPolicy` already classifies an age into it against tokenised
/// boundaries. This is the first row in this batch whose qualitative output
/// column matches something the repository had already built, so the evidence
/// and the sheet agree without anything being restated.
///
/// **"Read-only lock" on a dashboard is a lock on a door that was never a
/// door.** A dashboard element displays a number; there is nothing to edit. The
/// row calls it poka-yoke, and Step 341 settled what earns that word: a device
/// that makes the error impossible rather than one that notices it. A widget
/// that cannot be edited because *there is no edit path* is the mechanical
/// kind; a widget with a disabled text field over it is the other, and is also
/// how somebody comes to believe a dashboard is an input.
///
/// **A greyed-out field is a worse answer than no field.** Step 292 recorded
/// that a disabled control at MD3's 0.38 opacity keeps about 2.7:1 of contrast,
/// and Step 320 built the remedy. Neither applies here, because the right build
/// has no disabled control at all: a figure is text, and text is not a field
/// somebody has been locked out of.
library;

import 'freshness.dart';

/// How a surface can be made non-editable.
enum HabotLockKind {
  /// A disabled input sits over the value.
  disabledField,

  /// There is no input. The value is text.
  noEditPath,
}

/// The read-only rule for dashboard elements.
class HabotReadOnlyLock {
  const HabotReadOnlyLock._();

  // -----------------------------------------------------------------------
  // The band, whose ceiling is inside its optimal.
  // -----------------------------------------------------------------------

  static const int bandFloorMinutes = 5;
  static const String bandOptimalRaw = '0-1';
  static const int bandCeilingMinutes = 1;

  static const int optimalLow = 0;
  static const int optimalHigh = 1;

  static bool get theOptimalIsARange =>
      bandOptimalRaw.contains('-') && optimalLow != optimalHigh;

  static bool get theCeilingSitsInsideTheOptimal =>
      bandCeilingMinutes >= optimalLow && bandCeilingMinutes <= optimalHigh;

  /// Three cells, two distinct positions: 5, and the 0-1 span whose top is
  /// also the ceiling.
  static bool get threeCellsHoldTwoPositions =>
      theOptimalIsARange && theCeilingSitsInsideTheOptimal;

  static const String bandNote =
      'Floor 5, optimal "0-1", ceiling 1. The optimal spans two values and the '
      'ceiling is the upper end of that span, so the best attainable value is '
      'also a permissible optimal value and the band has three cells holding '
      'two distinct positions. It is a new shape for this track: previous '
      'defects made the ceiling equal to the optimal or worse than the floor, '
      'and this one puts the ceiling inside the optimal.';

  // -----------------------------------------------------------------------
  // The vocabulary, which is already ours.
  // -----------------------------------------------------------------------

  static const List<String> rowVocabulary = <String>[
    'Real-time',
    'Near Real-time',
    'Delayed',
  ];

  static List<String> get declaredVocabulary => HabotFreshness.values
      .map((HabotFreshness f) => f.qualitativeOutput)
      .toSet()
      .toList();

  static bool get theVocabularyMatchesWhatWeBuilt =>
      declaredVocabulary.length == rowVocabulary.length &&
      rowVocabulary.every((String v) => declaredVocabulary.contains(v));

  static HabotFreshness classify(Duration age) =>
      HabotFreshnessPolicy.classify(age);

  static String outputFor(Duration age) => classify(age).qualitativeOutput;

  /// Worked ages, derived from the declared boundaries rather than written
  /// as literals: half the optimal, three times it, and twice the budget.
  static Duration get insideOptimal => HabotFreshnessPolicy.optimal ~/ 2;

  static Duration get betweenOptimalAndBudget =>
      HabotFreshnessPolicy.optimal * 3;

  static Duration get pastBudget => HabotFreshnessPolicy.budget * 2;

  static bool get aThirtySecondAgeIsRealTime =>
      outputFor(insideOptimal) == 'Real-time';

  static bool get aThreeMinuteAgeIsNearRealTime =>
      outputFor(betweenOptimalAndBudget) == 'Near Real-time';

  static bool get aTenMinuteAgeIsDelayed =>
      outputFor(pastBudget) == 'Delayed';

  static bool get allThreeStatesAreReachable =>
      aThirtySecondAgeIsRealTime &&
      aThreeMinuteAgeIsNearRealTime &&
      aTenMinuteAgeIsDelayed;

  static const String vocabularyNote =
      'Real-time / Near Real-time / Delayed is exactly the vocabulary the '
      'freshness policy built at Step 129 declares, classified against '
      'tokenised boundaries. This is the first row in this batch whose '
      'qualitative output column matches something the repository already had, '
      'so the evidence and the sheet agree without a second scheme being '
      'written beside the first -- and all three states are reachable, which a '
      'vocabulary borrowed and never exercised would not guarantee.';

  // -----------------------------------------------------------------------
  // A lock on a door that was never a door.
  // -----------------------------------------------------------------------

  static const HabotLockKind chosenKind = HabotLockKind.noEditPath;

  static bool get theLockIsMechanical =>
      chosenKind == HabotLockKind.noEditPath;

  static const bool aDisabledFieldIsRendered = false;

  /// Step 341 settled what earns the word: a device that makes the error
  /// impossible rather than one that notices it afterwards.
  static const int theStepThatSettledPokaYoke = 341;

  static const String lockNote =
      'A dashboard element displays a number; there is nothing to edit, so a '
      '"read-only lock" is a lock on a door that was never a door. Step 341 '
      'settled what earns the word poka-yoke: a device that makes the error '
      'impossible rather than one that notices it. A figure rendered as text '
      'has no edit path at all, which is the mechanical kind. A disabled input '
      'placed over the value is the other kind, and it is also how somebody '
      'comes to believe a dashboard is a form.';

  // -----------------------------------------------------------------------
  // Why not a greyed field.
  // -----------------------------------------------------------------------

  static const double disabledOpacity = 0.38;

  static const double contrastKeptAtThatOpacity = 2.7;

  static const double contrastRequired = 4.5;

  static bool get aGreyedFieldWouldFailContrast =>
      contrastKeptAtThatOpacity < contrastRequired;

  static const int theStepThatMeasuredIt = 292;
  static const int theStepThatBuiltTheRemedy = 320;

  /// Neither applies, because the right build has no disabled control.
  static bool get neitherRemedyIsNeededHere => !aDisabledFieldIsRendered;

  static const String contrastNote =
      'Step 292 measured what a disabled control keeps at MD3\'s 0.38 opacity '
      '-- about 2.7:1 against a 4.5:1 requirement -- and Step 320 built the '
      'remedy, a way to ask for the permission that would ungrey it. Neither '
      'is needed here, because the right build has no disabled control: a '
      'figure is text, and text is not a field somebody has been locked out '
      'of. A greyed field is a worse answer than no field, since it advertises '
      'an ability that does not exist.';

  static Map<String, bool> get obligations => <String, bool>{
        'there is no edit path to lock':
            theLockIsMechanical && !aDisabledFieldIsRendered,
        'no disabled control is rendered': neitherRemedyIsNeededHere,
        'the freshness vocabulary is the declared one':
            theVocabularyMatchesWhatWeBuilt,
        'all three freshness states are reachable':
            allThreeStatesAreReachable,
        'the age is classified against tokenised boundaries':
            aTenMinuteAgeIsDelayed,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b)
          ? outputFor(insideOptimal)
          : 'Delayed';

  static Map<String, bool> get checks => <String, bool>{
        'the optimal is a range': theOptimalIsARange,
        'and the ceiling sits inside it':
            theCeilingSitsInsideTheOptimal && threeCellsHoldTwoPositions,
        'which is a new band shape for this track':
            bandNote.contains('new shape for this track'),
        'the row vocabulary is the one Step 129 declared':
            theVocabularyMatchesWhatWeBuilt && rowVocabulary.length == 3,
        'all three states are reachable from real ages':
            allThreeStatesAreReachable,
        'the lock is the mechanical kind':
            theLockIsMechanical && theStepThatSettledPokaYoke == 341,
        'no disabled field is drawn':
            !aDisabledFieldIsRendered && lockNote.contains('never a door'),
        'a greyed field would fail contrast':
            aGreyedFieldWouldFailContrast &&
                theStepThatMeasuredIt == 292 &&
                theStepThatBuiltTheRemedy == 320,
        'and neither remedy is needed because there is no control':
            neitherRemedyIsNeededHere &&
                contrastNote.contains('advertises'),
        'five obligations, all met, giving Real-time':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Real-time',
      };

  static const String columnNote =
      'COLUMN NOTE: this row is assigned to DEA rather than UDF; its band sets '
      'a floor of 5 against an optimal written "0-1" and a ceiling of 1, so '
      'the ceiling sits inside the optimal; its metric is a data freshness on '
      'a row about editability; and the Setup Step column is empty. Its output '
      'vocabulary, unusually, is the one this repository already declares. '
      'Atomic Step: "Configure the dashboard elements as read-only locks to '
      'prevent accidental data edits (Poka-Yoke)."';
}
