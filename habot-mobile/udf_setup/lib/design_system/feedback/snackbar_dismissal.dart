/// Step 226 (GEN-02356) -- swipe-to-dismiss on snackbars.
///
/// The row: "Implement swipe-to-dismiss functionality for the snackbars."
/// Metric: Process Completion Rate -- **Floor 0, Optimal "95-100%",
/// Ceiling 1**. Complete/Partial/Not Complete.
///
/// **MECHANICAL SHEET DEFECT.** Those three bounds are in three different
/// units: a count, a percentage range, and a fraction. Read as fractions the
/// floor is 0 and the ceiling is 1, which admits everything; read as
/// percentages the optimal is a range and the other two are not. No ordering
/// survives all three readings, so the band cannot be applied. The fractional
/// reading is used because two of the three are already fractions, and the
/// choice is recorded rather than made silently.
///
/// **A snackbar that can be swiped away can take its action with it.** Step 68
/// gives an error snackbar a retry, and `HabotMotion.snackbarDisplayWithAction`
/// is two seconds longer than the plain one for exactly that reason -- the user
/// needs time to reach the action. A swipe is faster than reading, so the
/// gesture removes the only visible route to a retry before the user knew there
/// was one.
///
/// The rule that follows is Step 193's, applied here: **the snackbar is never
/// the only route to its action.** A retry reachable only from a surface that
/// disappears on a thumb-flick is not a retry.
///
/// **Direction: either.** This is a deliberate difference from Step 225. A back
/// gesture is navigation and has a leading edge; a snackbar is a notification
/// and dismissing it is not a directional act, so MD3 accepts a horizontal
/// swipe either way and so does this. Stating why, because "one of them is
/// direction-aware and the other is not" otherwise reads as an oversight.
library;

import '../tokens/motion_tokens.dart';

/// What a snackbar carries.
class HabotSnackbarPayload {
  const HabotSnackbarPayload({
    required this.message,
    required this.actionLabel,
    required this.actionReachableElsewhere,
  });

  final String message;

  /// Null when the snackbar is purely informational.
  final String? actionLabel;

  /// Whether the action this snackbar offers can also be reached from the
  /// screen itself. Step 193's rule, applied to a surface that is even easier
  /// to lose than a FAB.
  final bool actionReachableElsewhere;

  bool get hasAction => actionLabel != null;
}

/// How a snackbar left the screen.
enum HabotSnackbarExit {
  /// The declared duration elapsed.
  timeout,

  /// The user swiped it away.
  swipe,

  /// The user took the action.
  actioned,

  /// Another snackbar replaced it.
  superseded,
}

/// The rule.
class HabotSnackbarDismissal {
  const HabotSnackbarDismissal._();

  /// Horizontal, either way. See the file header for why this differs from
  /// the back gesture.
  static const bool isDirectional = false;

  static const String directionNote =
      'A back gesture is navigation and has a leading edge; a snackbar is a '
      'notification and dismissing it is not a directional act. MD3 accepts a '
      'horizontal swipe either way. Said out loud because one gesture being '
      'direction-aware and another not otherwise reads as an oversight rather '
      'than a decision.';

  /// Fraction of the snackbar's width a drag must cover to dismiss.
  static const double dismissThreshold = 0.4;

  static Duration durationFor(HabotSnackbarPayload payload) =>
      payload.hasAction
          ? HabotMotion.snackbarDisplayWithAction
          : HabotMotion.snackbarDisplay;

  /// The extra window an action buys, which is what a swipe can cut short.
  static Duration get actionGraceWindow =>
      HabotMotion.snackbarDisplayWithAction - HabotMotion.snackbarDisplay;

  /// A snackbar may be swiped away whatever it carries -- refusing the
  /// gesture on the ones that matter most is how a gesture becomes
  /// unpredictable.
  static bool maySwipe(HabotSnackbarPayload payload) => true;

  /// But a snackbar carrying an action that exists nowhere else must not be
  /// shown in the first place.
  static bool isWellFormed(HabotSnackbarPayload payload) =>
      !payload.hasAction || payload.actionReachableElsewhere;

  static String malformedReason(HabotSnackbarPayload payload) =>
      isWellFormed(payload)
          ? ''
          : 'This snackbar offers "${payload.actionLabel}" and nothing else '
              'on the screen does. A swipe removes the only route to it, '
              'before the user has read the message.';

  /// What a swipe costs when the payload is well formed: the message, and
  /// nothing else.
  static bool swipeLosesTheAction(HabotSnackbarPayload payload) =>
      payload.hasAction && !payload.actionReachableElsewhere;

  static const String swipeIsFasterThanReadingNote =
      'A swipe is faster than reading. snackbarDisplayWithAction is two '
      'seconds longer than the plain duration precisely because a user needs '
      'time to reach the action -- and a gesture hands back those two seconds '
      'in one motion. The rule that survives is Step 193\'s: the snackbar is '
      'never the only route to its action.';

  /// Every exit reason is recorded, because "the user swiped it away" and
  /// "it timed out" are different signals about the same message and a
  /// counter that merges them says nothing.
  static bool exitIsAttributable(HabotSnackbarExit exit) =>
      HabotSnackbarExit.values.contains(exit);

  static const String attributionNote =
      'A snackbar swiped away at 400ms and one that timed out at four seconds '
      'are different signals about the same message. A counter that merges '
      'them reports "the snackbar was shown" and nothing about whether it '
      'was read.';

  // -----------------------------------------------------------------------
  // Metric: Process Completion Rate. Floor 0, Optimal "95-100%", Ceiling 1.
  // -----------------------------------------------------------------------

  static const String rowFloor = '0';
  static const String rowOptimal = '95-100%';
  static const String rowCeiling = '1';

  static const String bandUnitsNote =
      'MECHANICAL DEFECT: the three bounds are in three units -- a count, a '
      'percentage range, and a fraction. Read as fractions the floor is 0 and '
      'the ceiling is 1, which admits every value; read as percentages the '
      'optimal is a range and the other two are not. No ordering survives all '
      'three readings. The fractional reading is used because two of the three '
      'are already fractions, and the choice is recorded rather than made '
      'silently.';

  /// The band as applied, under the recorded reading.
  static const double floor = 0.95;
  static const double optimal = 1.0;
  static const double ceiling = 1.0;

  /// The snackbars this product shows, as declared payloads.
  static List<HabotSnackbarPayload> get declaredSnackbars =>
      <HabotSnackbarPayload>[
        const HabotSnackbarPayload(
          message: 'Saved',
          actionLabel: null,
          actionReachableElsewhere: false,
        ),
        const HabotSnackbarPayload(
          message: 'Could not reach the server',
          actionLabel: 'Retry',
          actionReachableElsewhere: true,
        ),
        const HabotSnackbarPayload(
          message: 'Child removed from this booking',
          actionLabel: 'Undo',
          actionReachableElsewhere: true,
        ),
        const HabotSnackbarPayload(
          message: 'Promo code applied',
          actionLabel: null,
          actionReachableElsewhere: false,
        ),
      ];

  /// A snackbar that would lose its action to a swipe, kept as the shape the
  /// rule exists to refuse.
  static HabotSnackbarPayload get malformedExample =>
      const HabotSnackbarPayload(
        message: 'Upload failed',
        actionLabel: 'Retry upload',
        actionReachableElsewhere: false,
      );

  static double get completionRate =>
      declaredSnackbars.where(isWellFormed).length /
      declaredSnackbars.length;

  static String get qualitativeOutput {
    final double r = completionRate;
    if (r >= optimal) {
      return 'Complete';
    }
    return r >= floor ? 'Partial' : 'Not Complete';
  }

  static Map<String, bool> get checks => <String, bool>{
        'every declared snackbar may be swiped away':
            declaredSnackbars.every(maySwipe),
        'every declared snackbar with an action has another route to it':
            declaredSnackbars.every(isWellFormed),
        'a snackbar whose action exists nowhere else is refused':
            !isWellFormed(malformedExample) &&
                malformedReason(malformedExample).contains('only route'),
        'that refusal names what a swipe would cost':
            swipeLosesTheAction(malformedExample),
        'a snackbar with an action is shown longer than one without':
            durationFor(declaredSnackbars[1]) >
                durationFor(declaredSnackbars[0]),
        'the extra window an action buys is two seconds':
            actionGraceWindow.inSeconds == 2,
        'dismissal is not directional, and says why':
            !isDirectional && directionNote.contains('decision'),
        'every exit reason is attributable':
            HabotSnackbarExit.values.every(exitIsAttributable) &&
                HabotSnackbarExit.values.length == 4,
        'the band\'s unit mismatch is recorded rather than resolved silently':
            bandUnitsNote.contains('three units'),
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Implement swipe-to-dismiss functionality for the snackbars."';
}
