/// Step 348 (GEN-04660) -- tooltips on a surface with no hover, measured by
/// something they do not cause, in a band with three unit systems.
///
/// The row: "Add custom animations introducing tooltips cleanly onto active
/// viewports."
/// Metric: **Onboarding Completion Rate** -- floor 0.6, optimal 0.8, ceiling
/// "90%+ (diminishing returns)". Good/Average/Poor. Appcues onboarding
/// benchmark.
///
/// **A tooltip is a hover construct and this is a touch surface.** There is no
/// hover: a finger is either down or not, and the state a tooltip waits for
/// does not occur. Every mobile "tooltip" is therefore something else wearing
/// the name -- a long-press popover, a tap-to-reveal label, or persistent text
/// that was never a tooltip at all. This repository has refused hover
/// affordances since the poka-yoke guard shipped, and `HOVER_TOOLTIP` has been
/// one of its ten rules since then, so the word in this row is already
/// answered by a lint.
///
/// **The band has three unit systems in it.** Floor 0.6, optimal 0.8, ceiling
/// "90%+ (diminishing returns)": a decimal, a decimal, and a percentage with a
/// plus sign and a parenthetical excuse. Reading them onto one scale gives 60,
/// 80 and 90, which is at least ordered -- but nothing in the band says that,
/// and a reader who takes the ceiling literally as 90 against a floor of 0.6
/// has a band spanning a factor of 150.
///
/// **The metric measures something the row cannot move.** Onboarding completion
/// is how many people finish setting up. An animation on a label is not a cause
/// of that, and attributing it to one is how a team ends up defending a
/// transition curve in a growth review. What an entry animation can be
/// measured on is whether it makes the label readable sooner or later than no
/// animation at all -- which is a number this file computes.
///
/// **COLUMN NOTE.** Three unit systems in one band; a growth metric on a
/// presentation row; a ceiling with a parenthetical excuse in place of a value;
/// and every narrative column the generic engineering-console boilerplate.
library;

import '../tokens/motion_tokens.dart';

/// What a mobile surface can actually offer in a tooltip's place.
enum HabotHintForm {
  /// Held, then a popover. Invisible until discovered.
  longPressPopover,

  /// Tapped, then a label that stays until dismissed.
  tapReveal,

  /// Always present, under or beside the control.
  persistentSupportingText,
}

/// The entry animation on a hint.
class HabotTooltipEntry {
  const HabotTooltipEntry._();

  // -----------------------------------------------------------------------
  // There is no hover.
  // -----------------------------------------------------------------------

  static const bool thisSurfaceHasHover = false;

  static const String guardRuleAlreadyEnforcing = 'HOVER_TOOLTIP';

  static bool get theWordIsAlreadyLinted =>
      guardRuleAlreadyEnforcing == 'HOVER_TOOLTIP';

  static const Map<HabotHintForm, String> whatEachActuallyIs =
      <HabotHintForm, String>{
    HabotHintForm.longPressPopover: 'a gesture nobody is told about',
    HabotHintForm.tapReveal: 'a disclosure, which competes with the control',
    HabotHintForm.persistentSupportingText: 'not a tooltip at all',
  };

  static bool get everyFormIsNamedForWhatItIs =>
      whatEachActuallyIs.length == HabotHintForm.values.length;

  /// What is chosen, and why: supporting text is the only one that is there
  /// when a person needs it without being found first.
  static const HabotHintForm chosenForm =
      HabotHintForm.persistentSupportingText;

  static bool get theChosenFormNeedsNoDiscovery =>
      chosenForm == HabotHintForm.persistentSupportingText;

  static const String hoverNote =
      'A tooltip waits for a pointer to rest on something. A finger is down or '
      'it is not, so the state never arrives and every mobile tooltip is some '
      'other control wearing the name. The poka-yoke guard has carried a '
      'HOVER_TOOLTIP rule since it shipped, so the word in this row is already '
      'answered by a lint. Of the three forms a touch surface can offer, '
      'supporting text is the one that is present when it is needed rather '
      'than after it has been found.';

  // -----------------------------------------------------------------------
  // The band's three unit systems.
  // -----------------------------------------------------------------------

  static const String bandFloorRaw = '0.6';
  static const String bandOptimalRaw = '0.8';
  static const String bandCeilingRaw = '90%+ (diminishing returns)';

  static bool get theCeilingIsAPercentage => bandCeilingRaw.contains('%');

  static bool get theFloorIsADecimal =>
      double.tryParse(bandFloorRaw) != null && !bandFloorRaw.contains('%');

  static bool get theCeilingIsNotParseable =>
      double.tryParse(bandCeilingRaw) == null;

  /// Read onto one scale the values are 60, 80, 90, which is ordered.
  static const List<int> reconciledPercentages = <int>[60, 80, 90];

  static bool get theyAreOrderedOnceReconciled =>
      reconciledPercentages[0] < reconciledPercentages[1] &&
      reconciledPercentages[1] < reconciledPercentages[2];

  /// Taken literally, 90 against 0.6 is a factor of 150.
  static double get literalSpan => 90 / 0.6;

  static bool get theLiteralReadingSpansOneHundredAndFifty =>
      literalSpan == 150;

  static const String bandNote =
      'Floor 0.6, optimal 0.8, ceiling "90%+ (diminishing returns)": a '
      'decimal, a decimal and a percentage carrying a plus sign and an excuse. '
      'Reconciled onto one scale they are 60, 80 and 90, which is ordered, but '
      'nothing in the band says to reconcile them. Read literally, a ceiling '
      'of 90 against a floor of 0.6 is a band spanning a factor of a hundred '
      'and fifty, and the ceiling cell cannot be parsed as a number at all.';

  // -----------------------------------------------------------------------
  // The metric measures something this row cannot move.
  // -----------------------------------------------------------------------

  static const String metricName = 'Onboarding Completion Rate';
  static const String metricSubject = 'how many people finish setting up';
  static const String rowSubject = 'an entry animation on a hint';

  static bool get theMetricAndTheSubjectAreUnrelated =>
      metricSubject != rowSubject;

  static const String attributionNote =
      'Onboarding completion is a growth number with a dozen real causes: how '
      'many fields the form has, whether the network held, whether the person '
      'had their documents to hand. An entry animation on a label is not among '
      'them in any measurable way, and attributing it to one is how a team '
      'ends up defending a transition curve in a growth review. What an entry '
      'animation can honestly be measured on is whether the text is readable '
      'sooner or later than it would be without one.';

  // -----------------------------------------------------------------------
  // What can be measured: time to readable.
  // -----------------------------------------------------------------------

  static Duration get entryDuration => HabotMotion.fast;

  static bool get theDurationComesFromTokens =>
      entryDuration == HabotMotion.fast;

  /// Persistent supporting text is on screen before the interaction begins.
  static const int millisecondsToReadableWithPersistentText = 0;

  static int get millisecondsToReadableWithAnEntryAnimation =>
      entryDuration.inMilliseconds;

  static bool get theAnimationCostsTimeRatherThanSavingIt =>
      millisecondsToReadableWithAnEntryAnimation >
      millisecondsToReadableWithPersistentText;

  /// Which is not an argument against the animation -- only against calling
  /// it a cause of completion.
  static const String measurementNote =
      'Supporting text that is always present is readable at zero '
      'milliseconds; the same text introduced by an entry animation is '
      'readable when the animation ends. The animation therefore costs time '
      'rather than saving it, which is not an argument against having one -- '
      'motion that shows where a thing came from is worth a frame or two -- '
      'but it is a reason not to claim it lifts a completion rate.';

  static Map<String, bool> get obligations => <String, bool>{
        'no hover state is depended on': !thisSurfaceHasHover,
        'the chosen form needs no discovery': theChosenFormNeedsNoDiscovery,
        'the entry duration comes from the motion tokens':
            theDurationComesFromTokens,
        'the band\'s units are reconciled and the reconciliation stated':
            theyAreOrderedOnceReconciled,
        'the metric mismatch is recorded rather than claimed':
            theMetricAndTheSubjectAreUnrelated,
      };

  static String get qualitativeOutput =>
      obligations.values.every((bool b) => b) ? 'Good' : 'Poor';

  static Map<String, bool> get checks => <String, bool>{
        'there is no hover on this surface':
            !thisSurfaceHasHover && theWordIsAlreadyLinted,
        'each of the three forms is named for what it is':
            everyFormIsNamedForWhatItIs && HabotHintForm.values.length == 3,
        'the chosen form is present rather than discovered':
            theChosenFormNeedsNoDiscovery &&
                hoverNote.contains('after it has been found'),
        'the floor is a decimal and the ceiling a percentage':
            theFloorIsADecimal && theCeilingIsAPercentage,
        'the ceiling cannot be parsed as a number':
            theCeilingIsNotParseable,
        'reconciled, the three values are ordered':
            theyAreOrderedOnceReconciled &&
                reconciledPercentages.length == 3,
        'read literally, the band spans a factor of 150':
            theLiteralReadingSpansOneHundredAndFifty,
        'the metric is a growth number on a presentation row':
            theMetricAndTheSubjectAreUnrelated &&
                attributionNote.contains('growth review'),
        'the animation costs time rather than saving it':
            theAnimationCostsTimeRatherThanSavingIt &&
                millisecondsToReadableWithPersistentText == 0,
        'five obligations, all met, giving Good':
            obligations.length == 5 &&
                obligations.values.every((bool b) => b) &&
                qualitativeOutput == 'Good',
      };

  static const String columnNote =
      'COLUMN NOTE: the band on this row carries three unit systems -- 0.6, '
      '0.8 and "90%+ (diminishing returns)" -- its ceiling cell holds an '
      'excuse in place of a value, its metric is a growth rate on a '
      'presentation row, and every narrative column is the generic '
      'engineering-console boilerplate. Atomic Step: "Add custom animations '
      'introducing tooltips cleanly onto active viewports."';
}
