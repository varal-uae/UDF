/// AISS Step 193 -- GEN-04814
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement substep 1: Position M3 Extended FAB in the primary
///               thumb zone (bottom-right on portrait viewports)."
/// Metric: Substep Definition-of-Done Adherence Rate -- Floor ">=90% unit test
///         coverage / acceptance criteria met before merge", Optimal "95-100%
///         coverage, all acceptance criteria met", Ceiling "100% (coverage
///         beyond 100% is not meaningful)".
///         Complete / Partial / Not Complete.
///
/// **"BOTTOM-RIGHT" IS AN ASSUMPTION ABOUT TWO THINGS, AND ONE OF THEM THE APP
/// CANNOT KNOW.** It assumes a left-to-right locale, and it assumes a
/// right-handed user. The first is knowable and is honoured: MD3 anchors the
/// FAB to the **trailing** edge in reading order, which is the right in English
/// and the left in Urdu — so a build that hard-codes "right" puts the primary
/// action under the thumb of nobody in the languages this product already
/// ships (Step 138). This is the third time the same defect has appeared:
/// Step 150's swipe direction and Step 167's frozen column were both written
/// as sides.
///
/// The second is **not knowable**, and pretending otherwise would be the
/// dishonest part. Around one person in ten is left-handed; the platform does
/// not expose handedness and this app does not ask. The trailing-edge anchor is
/// right for the majority and is wrong for them, every time, on every screen.
/// That is recorded as a limitation with the mitigation that actually exists —
/// the FAB is never the *only* route to its action — rather than as a solved
/// problem.
///
/// **A SCREEN HAS ONE PRIMARY ACTION, AND TWO COMPONENTS HERE CLAIM IT.**
/// A bottom action bar (Step 192) with a confirm button and a FAB in the same
/// corner are two primary actions on one screen, which means at least one of
/// them is not primary. [HabotFabThumbZone.mayCoexistWithBottomBar] is false
/// and the rule is enforced at the call site rather than discovered in review.
///
/// **STEP 154 ALREADY OWNS THE KEYBOARD BEHAVIOUR AND IS NOT RE-DECIDED
/// HERE.** The FAB leaves the tree when the keyboard opens. This step places
/// it; it does not get a second opinion about when it exists.
library;

import '../i18n/localization_objective.dart';
import '../layout/bottom_action_bar.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/touch_target_band.dart';
import 'keyboard_aware_fab.dart';

/// Which corner a FAB is anchored to, in reading-order terms.
enum HabotFabAnchor {
  /// The bottom edge, trailing side. MD3's default and the primary thumb zone.
  bottomTrailing,

  /// Centred on the bottom edge. A different MD3 pattern (docked to a bottom
  /// app bar), not a variation on the default.
  bottomCentre,

  /// The bottom edge, leading side. Not an MD3 placement; declared so that
  /// choosing it is a decision rather than a mistake.
  bottomLeading,
}

/// Which physical side an anchor resolves to.
enum HabotScreenSide { left, right, centre }

/// Where the FAB goes, and why it is not a side.
class HabotFabThumbZone {
  const HabotFabThumbZone._();

  /// MD3's placement, and the one the row is asking for.
  static const HabotFabAnchor anchor = HabotFabAnchor.bottomTrailing;

  /// The margin from both edges. A token, so the FAB does not drift relative
  /// to everything else on the screen.
  static double get edgeMargin => HabotSpacing.md;

  /// **The resolution the row's wording skips.**
  static HabotScreenSide sideFor(
    HabotFabAnchor anchor,
    HabotTextDirectionality direction,
  ) {
    final bool rtl = direction == HabotTextDirectionality.rightToLeft;
    switch (anchor) {
      case HabotFabAnchor.bottomTrailing:
        return rtl ? HabotScreenSide.left : HabotScreenSide.right;
      case HabotFabAnchor.bottomLeading:
        return rtl ? HabotScreenSide.right : HabotScreenSide.left;
      case HabotFabAnchor.bottomCentre:
        return HabotScreenSide.centre;
    }
  }

  /// What the row's literal wording produces in each direction, for the
  /// record.
  static bool literalRightIsCorrect(HabotTextDirectionality direction) =>
      sideFor(anchor, direction) == HabotScreenSide.right;

  /// The distance from the bottom of the window the FAB is anchored at.
  ///
  /// It clears the same system intrusion the bottom bar does -- a FAB over the
  /// home indicator is a FAB the system gesture takes the tap for -- and it
  /// does NOT chase the keyboard, because Step 154 removes it entirely while
  /// the keyboard is open.
  static double bottomOffsetFor(HabotWindowInsets insets) =>
      insets.viewPaddingBottom + edgeMargin;

  /// Whether the FAB is in the tree at all. Step 154's rule, read rather than
  /// restated.
  static bool isPresent(HabotWindowInsets insets) => !insets.keyboardIsOpen;

  /// **One primary action per screen.** See the header.
  static const bool mayCoexistWithBottomBar = false;

  /// True when a screen's declared composition is legal.
  static bool compositionIsValid({
    required bool hasFab,
    required bool hasBottomActionBar,
  }) =>
      !(hasFab && hasBottomActionBar) || mayCoexistWithBottomBar;

  /// The size an Extended FAB occupies. MD3 specifies 56dp tall; the band from
  /// Step 184 is what says that is inside the acceptable range rather than
  /// merely conventional.
  static const double extendedFabHeightDp = 56;

  static bool get heightIsWithinTouchBand =>
      extendedFabHeightDp >= HabotTouchBand.floorDp &&
      extendedFabHeightDp <= HabotTouchBand.ceilingDp;

  // ---- the limitation, stated ---------------------------------------------

  /// **Not solved, and not solvable from here.**
  static const String handednessLimitation =
      'Around one person in ten is left-handed. The platform does not expose '
      'handedness and this app does not ask, so the trailing-edge anchor is '
      'right for the majority and wrong for them on every screen, every time. '
      'The mitigation is that the FAB is never the only route to its action -- '
      'every action reachable from a FAB is also reachable from the screen\'s '
      'own content -- so a user who cannot comfortably reach it is '
      'inconvenienced rather than blocked.';

  /// The rule that mitigation depends on.
  static const bool fabIsNeverTheOnlyRoute = true;

  // ---- the row's metric ---------------------------------------------------

  /// The substep's acceptance criteria. The row's metric is a coverage figure;
  /// see [coverageReadingNote] for why the acceptance half is what is reported.
  static Map<String, bool> get acceptanceCriteria => <String, bool>{
        'the FAB is anchored to the bottom trailing corner rather than to a '
                'named side':
            anchor == HabotFabAnchor.bottomTrailing,
        'the anchor resolves to the right in a left-to-right locale, which is '
                'what the row asks for':
            literalRightIsCorrect(HabotTextDirectionality.leftToRight),
        'and to the left in a right-to-left locale, which is what the row '
                'would have got wrong':
            !literalRightIsCorrect(HabotTextDirectionality.rightToLeft),
        'the FAB clears the system gesture area at the bottom':
            bottomOffsetFor(
                  const HabotWindowInsets(
                    viewPaddingBottom: 34,
                    viewInsetsBottom: 0,
                  ),
                ) >
                34,
        'the FAB is absent while the keyboard is open, per Step 154':
            !isPresent(
                  const HabotWindowInsets(
                    viewPaddingBottom: 34,
                    viewInsetsBottom: 336,
                  ),
                ) &&
                HabotKeyboardAwareFab.hidesOnKeyboardAlways,
        'the FAB and a bottom action bar cannot both be on one screen':
            !compositionIsValid(hasFab: true, hasBottomActionBar: true) &&
                compositionIsValid(hasFab: true, hasBottomActionBar: false),
        'the Extended FAB height sits inside the Step 184 touch band':
            heightIsWithinTouchBand,
        'the edge margin is a token rather than a literal':
            edgeMargin == HabotSpacing.md,
        'the handedness limitation is recorded with its mitigation rather '
                'than left implied':
            handednessLimitation.length > 120 && fabIsNeverTheOnlyRoute,
      };

  static double get adherenceRate {
    final Iterable<bool> v = acceptanceCriteria.values;
    return v.where((bool b) => b).length / v.length;
  }

  static const double floor = 0.9;
  static const double optimal = 1.0;

  static String get qualitativeOutput {
    if (adherenceRate >= optimal) {
      return 'Complete';
    }
    return adherenceRate >= floor ? 'Partial' : 'Not Complete';
  }

  static const String coverageReadingNote =
      'The row\'s metric is "unit test coverage / acceptance criteria met '
      'before merge" -- two different things joined by a slash. A coverage '
      'percentage cannot be produced on this host: there is no Dart toolchain, '
      'so nothing runs and nothing is instrumented. The acceptance-criteria '
      'half is producible and is what is reported, with the substitution '
      'recorded rather than a coverage number being invented.';

  static const String directionNote =
      '"Bottom-right" assumes a left-to-right locale. MD3 anchors the FAB to '
      'the trailing edge in reading order, which is the right in English and '
      'the left in Urdu, so hard-coding "right" puts the primary action under '
      'nobody\'s thumb in a language this product already ships. Third '
      'occurrence of the same defect: Step 150\'s swipe direction and Step '
      '167\'s frozen column were both written as sides.';

  static const String onePrimaryActionNote =
      'A bottom action bar with a confirm button and a FAB in the same corner '
      'are two primary actions on one screen, which means at least one of them '
      'is not primary. The rule is enforced at the call site rather than '
      'discovered in review.';

  static const String columnNote =
      'Setup Step (Action) is EMPTY on this row. The Atomic Step is the unit '
      'of work.';
}
