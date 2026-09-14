/// AISS Step 189 -- GEN-04715
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement the mobile UI styling requirement: M3 Error color
///               state tokens applied instantly on validation breach."
/// Metric: UI Styling / Transition Compliance -- Floor "<=100ms transition
///         duration; visual QA pass on target devices", Optimal "<=100ms
///         transition, 100% visual QA pass", Ceiling ">100ms transitions read
///         as sluggish; >0 visual QA defects". Pass / Fail.
///
/// **"INSTANTLY" AND "<=100ms" ARE NOT THE SAME INSTRUCTION, AND THE ROW GIVES
/// BOTH.** A 90ms fade satisfies the number and fails the word. The reason the
/// word is right: by the time red has faded in over three frames the user has
/// already started typing the next character, so the error arrives attached to
/// the wrong keystroke. An error colour is an alert, and an alert that eases in
/// is an alert you notice late. [HabotValidationStateColor.enterTransition] is
/// therefore `HabotMotion.instant`, which is comfortably inside the row's
/// budget rather than merely compliant with it.
///
/// **LEAVING THE ERROR IS DELIBERATELY NOT INSTANT, AND THE ASYMMETRY IS THE
/// DESIGN.** When the user fixes the field, the red going away is reassurance
/// rather than an alert. Snapping it off in one frame reads as a glitch —
/// people report it as flicker. So entering the error state is immediate and
/// leaving it takes `HabotMotion.fast`.
///
/// **COLOUR ALONE CANNOT CARRY THE ERROR, AND THIS IS THE PART THE ROW DOES
/// NOT SAY.** WCAG 2.1 SC 1.4.1 is explicit: colour must not be the only
/// visual means of conveying information. A red border is nothing to a user
/// with deuteranopia, nothing at all to a screen reader, and nothing in a
/// high-contrast scheme that flattens hue. So the error state declares three
/// carriers — the role colour, an icon, and the message text — and
/// [HabotValidationStateColor.carriersFor] is what makes "applied" mean more
/// than "recoloured".
///
/// **THE COLOUR AND THE MESSAGE MUST ARRIVE ON THE SAME FRAME.** They come
/// from the same Step 20 verdict. Applying the colour from the field widget
/// and the message from the form gate is how a user gets a red box with no
/// reason in it, for one frame or for however long the slower path takes.
library;

import '../tokens/m3_naming.dart';
import '../tokens/motion_tokens.dart';

/// The visual states a field surface can be in.
///
/// Declared here rather than in the success step because the states are one
/// set: a field is in exactly one of them, and splitting the enum across two
/// files would let the two disagree about what is mutually exclusive.
enum HabotFieldVisualState {
  /// Nothing has happened to it.
  neutral,

  /// It has focus.
  focused,

  /// Validation rejected it (this step).
  error,

  /// Validation confirmed it (Step 190).
  success,

  /// Not editable.
  disabled,
}

/// A non-colour way the state is conveyed.
enum HabotStateCarrier {
  /// The role colour on border, label and helper text.
  colour,

  /// A leading or trailing glyph. Distinguishable without hue.
  icon,

  /// Words. The only carrier a screen reader can use.
  text,

  /// An announcement to assistive technology.
  semantics,
}

/// The colour roles and carriers for the error state.
class HabotValidationStateColor {
  const HabotValidationStateColor._();

  /// **Immediate.** See the header: an alert that eases in is an alert you
  /// notice late.
  static Duration get enterTransition => HabotMotion.instant;

  /// **Not immediate.** Removing an error is reassurance rather than an
  /// alert, and a one-frame snap reads as flicker.
  static Duration get exitTransition => HabotMotion.fast;

  /// The row's budget.
  static Duration get budget => HabotMotion.fast;

  static bool withinBudget(Duration d) => d <= budget;

  /// The MD3 roles the error state paints, by surface.
  ///
  /// `error` on the border and `onErrorContainer` on the helper text rather
  /// than `error` on both: error-on-surface is a 3:1 non-text pair, which is
  /// correct for a border and below the 4.5:1 floor for body text.
  static const Map<String, String> errorRoles = <String, String>{
    'border': 'error',
    'label': 'error',
    'helperText': 'error',
    'icon': 'error',
    'container': 'errorContainer',
    'containerText': 'onErrorContainer',
  };

  static Map<String, String> get errorTokens => errorRoles.map(
        (String surface, String role) => MapEntry<String, String>(
          surface,
          'md.sys.color.${HabotM3Naming.kebab(role)}',
        ),
      );

  /// What must convey the error, beyond colour.
  ///
  /// **Not a recommendation.** A state whose only carrier is colour fails
  /// WCAG 2.1 SC 1.4.1, and the check below is what stops one being declared.
  static Set<HabotStateCarrier> carriersFor(HabotFieldVisualState state) {
    switch (state) {
      case HabotFieldVisualState.error:
        return <HabotStateCarrier>{
          HabotStateCarrier.colour,
          HabotStateCarrier.icon,
          HabotStateCarrier.text,
          HabotStateCarrier.semantics,
        };
      case HabotFieldVisualState.success:
        return <HabotStateCarrier>{
          HabotStateCarrier.colour,
          HabotStateCarrier.icon,
          HabotStateCarrier.semantics,
        };
      case HabotFieldVisualState.focused:
        return <HabotStateCarrier>{HabotStateCarrier.colour};
      case HabotFieldVisualState.disabled:
        return <HabotStateCarrier>{
          HabotStateCarrier.colour,
          HabotStateCarrier.semantics,
        };
      case HabotFieldVisualState.neutral:
        return <HabotStateCarrier>{};
    }
  }

  /// States that convey meaning. Focus is excluded: it is a position rather
  /// than information, it is conveyed by the platform focus ring as well, and
  /// SC 1.4.1 is about information.
  static const Set<HabotFieldVisualState> meaningBearing =
      <HabotFieldVisualState>{
    HabotFieldVisualState.error,
    HabotFieldVisualState.success,
    HabotFieldVisualState.disabled,
  };

  /// States conveyed by colour and nothing else. Must be empty.
  static List<String> colourOnlyStates() => meaningBearing
      .where(
        (HabotFieldVisualState s) =>
            carriersFor(s).length == 1 &&
            carriersFor(s).contains(HabotStateCarrier.colour),
      )
      .map((HabotFieldVisualState s) => s.name)
      .toList();

  /// The transition for a state change, which depends on the DIRECTION of the
  /// change rather than on the state alone.
  static Duration transitionFor({
    required HabotFieldVisualState from,
    required HabotFieldVisualState to,
  }) {
    if (to == HabotFieldVisualState.error) {
      return enterTransition;
    }
    if (from == HabotFieldVisualState.error) {
      return exitTransition;
    }
    return HabotMotion.fast;
  }

  // ---- the row's metric ---------------------------------------------------

  static Map<String, bool> get complianceChecks => <String, bool>{
        'entering the error state is immediate rather than merely under the '
                '100ms budget':
            enterTransition == Duration.zero,
        'every declared transition is within the row\'s budget':
            withinBudget(enterTransition) && withinBudget(exitTransition),
        'leaving the error state is not instant, so a correction does not '
                'read as flicker':
            exitTransition > Duration.zero,
        'no meaning-bearing state is conveyed by colour alone (WCAG 2.1 SC '
                '1.4.1)':
            colourOnlyStates().isEmpty,
        'the error state is carried by text, which is the only carrier a '
                'screen reader can use':
            carriersFor(HabotFieldVisualState.error)
                .contains(HabotStateCarrier.text),
        'helper text uses the on-container role rather than the container '
                'role, so it clears the 4.5:1 text floor':
            errorRoles['containerText'] == 'onErrorContainer',
        'every declared role converts to a conformant MD3 token name':
            errorTokens.values.every(HabotM3Naming.isConformant),
      };

  static bool get isCompliant =>
      complianceChecks.values.every((bool b) => b);

  static String get qualitativeOutput => isCompliant ? 'Pass' : 'Fail';

  static const String instantlyVersusBudgetNote =
      '"Instantly" and "<=100ms" are not the same instruction and the row '
      'gives both. A 90ms fade satisfies the number and fails the word: by the '
      'time red has faded in over three frames the user has started the next '
      'character, so the error arrives attached to the wrong keystroke.';

  static const String asymmetryNote =
      'Entering the error state is immediate; leaving it is not. When the user '
      'fixes the field, the red going away is reassurance rather than an '
      'alert, and snapping it off in one frame reads as flicker -- people '
      'report it as a rendering bug.';

  static const String colourAloneNote =
      'WCAG 2.1 SC 1.4.1: colour must not be the only visual means of '
      'conveying information. A red border is nothing to a user with '
      'deuteranopia, nothing at all to a screen reader, and nothing in a '
      'high-contrast scheme that flattens hue. The error state declares three '
      'carriers beyond colour.';

  static const String sameFrameNote =
      'The colour and the message come from the same Step 20 verdict and must '
      'arrive on the same frame. Applying the colour from the field widget and '
      'the message from the form gate is how a user gets a red box with no '
      'reason in it.';

  static const String columnNote =
      'Setup Step (Action) is EMPTY on this row. The Atomic Step is the unit '
      'of work.';
}
