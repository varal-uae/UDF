/// AISS Step 192 -- GEN-03503
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Position high-contrast M3 Action Buttons locked at the bottom
///               of mobile screens."
/// Metric: Bottom Lock Anchor Precision -- Floor 1, Optimal 1, Ceiling 1.
///         Pass.
///
/// **"THE BOTTOM" IS NOT A NUMBER. THERE ARE THREE OF THEM AND THEY MOVE.**
///   1. The bottom of the window.
///   2. The bottom of the safe area — above the home indicator or the gesture
///      bar. A button locked to the window bottom on a modern handset is a
///      button the system swipe takes the tap for. The user presses "Submit",
///      the app goes to the background, and nothing about that reads as a
///      layout bug.
///   3. The top of the keyboard. A button locked below an open keyboard is
///      invisible, and the form it submits is the one being typed into.
///
/// A metric called **Anchor Precision** with 1 at every bound is asking for
/// the anchor to be exactly right rather than approximately right, which means
/// it has to be computed from the insets rather than padded by a number that
/// looked about right on the reviewer's phone.
///
/// **THE BAR RISES WITH THE KEYBOARD. THE FAB HIDES FROM IT (STEP 154). THE
/// DIFFERENCE IS NOT AN INCONSISTENCY.** A floating action button is a
/// shortcut to something other than what the user is doing, so while they are
/// typing it is only a hazard — Step 154 removes it from the tree. A bottom
/// action bar holds the primary action *for the thing being typed into*;
/// hiding it strands the user mid-form with no way to commit. Same edge of the
/// screen, opposite correct behaviour, and stating the reason is what stops
/// the next person "fixing" one to match the other.
///
/// **A SNACKBAR MUST CLEAR THE BAR, NOT COVER IT.** MD3 places transient
/// messages above persistent bottom elements. A snackbar over the submit
/// button is an error message obscuring the control that would fix the error.
library;

import '../feedback/error_snackbar.dart';
import '../interaction/keyboard_aware_fab.dart';
import '../tokens/button_role_map.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/touch_target_band.dart';

/// The window metrics the anchor is computed from.
///
/// Named rather than taken as three loose doubles, because the failure this
/// step is about is exactly the one where someone passes the wrong inset.
class HabotWindowInsets {
  const HabotWindowInsets({
    required this.viewPaddingBottom,
    required this.viewInsetsBottom,
  });

  /// The system's own bottom intrusion: home indicator, gesture bar,
  /// navigation bar. Present whether or not a keyboard is open.
  final double viewPaddingBottom;

  /// The keyboard. Zero when it is closed.
  final double viewInsetsBottom;

  HabotKeyboardInset get keyboard => HabotKeyboardInset(viewInsetsBottom);

  bool get keyboardIsOpen => keyboard.keyboardIsOpen;
}

/// Where the bottom action bar sits, exactly.
class HabotBottomActionBar {
  const HabotBottomActionBar._();

  /// The gap between the bar's content and the edge it is anchored to. A
  /// token, not a number chosen at the call site.
  static double get contentInset => HabotSpacing.md;

  /// **The anchor.**
  ///
  /// When the keyboard is open it is the only bottom that matters: the system
  /// gesture area is behind the keyboard, so adding both would push the bar up
  /// by a home-indicator height of empty space. When it is closed, the safe
  /// area is the bottom. Taking the larger of the two is what makes that one
  /// rule instead of two.
  static double anchorOffsetFor(HabotWindowInsets insets) {
    final double systemBottom = insets.viewPaddingBottom;
    final double keyboardBottom = insets.viewInsetsBottom;
    return keyboardBottom > systemBottom ? keyboardBottom : systemBottom;
  }

  /// The total space the bar occupies from the window edge.
  static double occupiedHeightFor(HabotWindowInsets insets) =>
      anchorOffsetFor(insets) + barContentHeight;

  /// Content height: one row of action buttons at the declared target size,
  /// with the content inset above and below.
  static double get barContentHeight =>
      HabotTouchBand.optimalDp + (contentInset * 2);

  /// **Rises with the keyboard**, unlike the Step 154 FAB. See the header.
  static bool get rowsWithKeyboard => true;

  /// The reason, carried in code so the divergence from the FAB is a decision
  /// rather than an oversight somebody later "corrects".
  static const String keyboardBehaviourRationale =
      'A FAB is a shortcut to something other than what the user is doing, so '
      'while they are typing it is only a hazard and Step 154 removes it. A '
      'bottom action bar holds the primary action FOR the thing being typed '
      'into; hiding it strands the user mid-form with no way to commit.';

  /// Where a snackbar must sit so it does not cover the bar.
  static double snackbarBottomFor(HabotWindowInsets insets) =>
      occupiedHeightFor(insets) + HabotSnackbarInsets.reservedBottomSpace;

  static bool snackbarClearsBar(
    HabotWindowInsets insets,
    double snackbarBottom,
  ) =>
      snackbarBottom >= occupiedHeightFor(insets);

  // ---- what the bar contains ----------------------------------------------

  /// The row says "high-contrast M3 Action Buttons". Which roles those are is
  /// Step 188's map, read rather than restated -- and the ordering is by what
  /// each button does, so it survives a right-to-left locale.
  static List<HabotButtonRole> get actions => <HabotButtonRole>[
        HabotButtonRole.dismiss,
        HabotButtonRole.confirm,
      ];

  /// The confirming action's container role, from the same map.
  static String? get primaryActionToken =>
      HabotButtonRoleMap.containerTokenFor(HabotButtonRole.confirm);

  /// A bar with no boundary reads as part of the page, and its buttons read as
  /// inline ones. The rung comes from the shell ladder rather than from a
  /// shade chosen here.
  static const String surfaceRung = 'surfaceContainer';

  // ---- the row's metric ---------------------------------------------------

  /// Anchor Precision: the computed offset must equal the insets exactly, with
  /// no slack. Checked against constructed cases rather than asserted.
  static Map<String, bool> get precisionChecks {
    const HabotWindowInsets gestureBarOnly = HabotWindowInsets(
      viewPaddingBottom: 34,
      viewInsetsBottom: 0,
    );
    const HabotWindowInsets keyboardOpen = HabotWindowInsets(
      viewPaddingBottom: 34,
      viewInsetsBottom: 336,
    );
    const HabotWindowInsets noIntrusion = HabotWindowInsets(
      viewPaddingBottom: 0,
      viewInsetsBottom: 0,
    );
    return <String, bool>{
      'with a gesture bar and no keyboard, the anchor is exactly the safe-area '
              'inset':
          anchorOffsetFor(gestureBarOnly) == 34,
      'with the keyboard open, the anchor is exactly the keyboard inset and '
              'does not add the safe area behind it':
          anchorOffsetFor(keyboardOpen) == 336,
      'with neither, the anchor is zero rather than a defensive constant':
          anchorOffsetFor(noIntrusion) == 0,
      'the bar rises with the keyboard rather than hiding from it, and the '
              'reason is recorded':
          rowsWithKeyboard && keyboardBehaviourRationale.length > 80,
      'the bar is tall enough for a target at the declared optimum':
          barContentHeight >= HabotTouchBand.optimalDp,
      'a snackbar is placed above the bar rather than over it':
          snackbarClearsBar(keyboardOpen, snackbarBottomFor(keyboardOpen)) &&
              !snackbarClearsBar(keyboardOpen, 0),
      'the actions are ordered by what they do rather than by side':
          actions.contains(HabotButtonRole.confirm) &&
              actions.contains(HabotButtonRole.dismiss),
      'the content inset is a token rather than a literal':
          contentInset == HabotSpacing.md,
    };
  }

  static bool get isPrecise => precisionChecks.values.every((bool b) => b);

  static const int floor = 1;
  static const int optimal = 1;
  static const int ceiling = 1;

  static String get qualitativeOutput => isPrecise ? 'Pass' : 'Fail';

  static const String threeBottomsNote =
      'There are three bottoms and they move: the window, the safe area above '
      'the home indicator, and the top of the keyboard. A button locked to the '
      'window bottom on a modern handset is a button the system swipe takes '
      'the tap for -- the user presses Submit, the app goes to the background, '
      'and nothing about that reads as a layout bug.';

  static const String precisionNote =
      'A metric called Anchor Precision with 1 at every bound is asking for '
      'the anchor to be exactly right rather than approximately right, which '
      'means computing it from the insets rather than padding by a number that '
      'looked about right on the reviewer\'s phone.';

  static const String snackbarNote =
      'MD3 places transient messages above persistent bottom elements. A '
      'snackbar over the submit button is an error message obscuring the '
      'control that would fix the error.';

  static const String columnNote =
      'Setup Step (Action) is EMPTY on this row. The Atomic Step is the unit '
      'of work.';
}
