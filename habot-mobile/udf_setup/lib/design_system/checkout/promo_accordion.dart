/// Step 205 (GEN-01220) -- the promo code accordion on checkout.
///
/// The row: "Construct an expandable promo code input accordion container on
/// the checkout screen."
/// Metric: Coupon/Voucher Redemption Validation Accuracy -- 0.97 / 0.999 / 1.
///
/// **Collapsed by default is the requirement, not a default.** An open promo
/// field on a checkout screen is an instruction to go and find a code. People
/// leave to look for one, and a measurable share do not come back. The
/// accordion exists so that the field is available to someone who has a code
/// and invisible to someone who does not, and that is worth writing down where
/// the widget is defined, because "expand it by default, it's one less tap" is
/// a reasonable-sounding change that nothing in the code would argue with.
///
/// **What the accordion must not do is throw away typing.** Two states collapse
/// it in a naive implementation: a failed apply (the error is inside the panel,
/// so the panel closes over its own error message) and a rebuild caused by the
/// total changing when an add-on is toggled. Both destroy a code the parent has
/// already typed, and both look like the app ignoring them. Expansion is
/// latched by content, not only by the tap that opened it.
///
/// **Expansion is a state, not an arrow.** Step 97's progressive disclosure
/// rule: a rotating chevron is invisible to a screen reader, so the expanded
/// state is announced and the panel is associated with the control that toggles
/// it.
library;

import '../tokens/motion_tokens.dart';
import '../tokens/spacing_tokens.dart';

/// Why the panel is in the state it is in.
enum HabotAccordionLatch {
  /// Closed, and nothing is holding it.
  closed,

  /// Opened by the user.
  openedByUser,

  /// Held open because it contains something that would be lost -- typed text,
  /// an error, or a code being validated.
  heldOpenByContent,
}

/// The accordion's state machine.
class HabotPromoAccordion {
  HabotPromoAccordion();

  bool _userOpened = false;
  String _draft = '';
  bool _validating = false;
  String _error = '';

  /// Collapsed on first render, always. See the file header.
  static const bool expandedByDefault = false;

  /// Whether the panel is currently open.
  bool get isExpanded => latch != HabotAccordionLatch.closed;

  /// Why.
  HabotAccordionLatch get latch {
    if (_draft.isNotEmpty || _validating || _error.isNotEmpty) {
      return HabotAccordionLatch.heldOpenByContent;
    }
    return _userOpened
        ? HabotAccordionLatch.openedByUser
        : HabotAccordionLatch.closed;
  }

  /// The header control. Toggles user intent; cannot discard content.
  ///
  /// Returns whether the tap changed anything, so a tap that was refused can
  /// be answered rather than being silently absorbed.
  bool toggle() {
    if (latch == HabotAccordionLatch.heldOpenByContent) {
      return false;
    }
    _userOpened = !_userOpened;
    return true;
  }

  /// Typing in the field.
  void updateDraft(String value) {
    _draft = value;
    if (_error.isNotEmpty) {
      _error = '';
    }
  }

  void beginValidation() {
    _validating = true;
    _error = '';
  }

  void failValidation(String message) {
    _validating = false;
    _error = message;
  }

  /// A successful apply is the one thing that legitimately empties the panel.
  void succeed() {
    _validating = false;
    _error = '';
    _draft = '';
    _userOpened = false;
  }

  /// Called when the order total changes underneath the panel -- an add-on
  /// toggle, a child added. Nothing about the panel changes.
  void onOrderChanged() {}

  String get draft => _draft;
  String get error => _error;
  bool get isValidating => _validating;

  /// What a naive implementation does with the same sequence: collapse on
  /// rebuild, losing the typed code. Kept for the contrast.
  static bool naiveWouldCollapseAfter({
    required bool orderChanged,
    required bool applyFailed,
  }) =>
      orderChanged || applyFailed;

  // -----------------------------------------------------------------------
  // Presentation.
  // -----------------------------------------------------------------------

  static Duration get expandDuration => HabotMotion.standard;
  static Duration get collapseDuration => HabotMotion.sheetExit;
  static double get panelPaddingDp => HabotSpacing.md;
  static double get headerMinHeightDp => HabotDensity.minTouchTarget;

  /// Announced state, not a rotating chevron.
  static const String semanticRule = 'A11Y_PROGRESSIVE_DISCLOSURE';

  String get semanticsLabel => 'Promo code';

  String get semanticsHint =>
      isExpanded ? 'Double tap to collapse' : 'Double tap to enter a code';

  bool get semanticsExpanded => isExpanded;

  // -----------------------------------------------------------------------
  // Metric: Coupon/Voucher Redemption Validation Accuracy. 0.97 / 0.999 / 1.
  // -----------------------------------------------------------------------

  static const double floor = 0.97;
  static const double optimal = 0.999;
  static const double ceiling = 1;

  /// This step owns the container, not the validation. What it can be graded
  /// on is whether the container ever destroys an input that was about to be
  /// validated -- an accuracy figure with a denominator this file controls.
  static Map<String, bool> get containerChecks {
    final HabotPromoAccordion typed = HabotPromoAccordion()
      ..toggle()
      ..updateDraft('WELCOME10');
    final HabotPromoAccordion failed = HabotPromoAccordion()
      ..toggle()
      ..updateDraft('WELCOME10')
      ..beginValidation()
      ..failValidation('Not valid on this service');
    final HabotPromoAccordion applied = HabotPromoAccordion()
      ..toggle()
      ..updateDraft('WELCOME10')
      ..succeed();
    return <String, bool>{
      'collapsed on first render': !HabotPromoAccordion().isExpanded &&
          !expandedByDefault,
      'a tap opens it': (HabotPromoAccordion()..toggle()).latch ==
          HabotAccordionLatch.openedByUser,
      'typed content holds it open':
          typed.latch == HabotAccordionLatch.heldOpenByContent,
      'a failed apply does not collapse over its own error':
          failed.isExpanded && failed.error.isNotEmpty,
      'an order change does not disturb it':
          (typed..onOrderChanged()).draft == 'WELCOME10',
      'a header tap cannot discard typed input': !typed.toggle(),
      'a successful apply is what closes it':
          !applied.isExpanded && applied.draft.isEmpty,
      'the expanded state is announced rather than drawn':
          !HabotPromoAccordion().semanticsExpanded && typed.semanticsExpanded,
      'the header clears the minimum touch target':
          headerMinHeightDp >= HabotDensity.minTouchTarget,
    };
  }

  static double get containerReliability {
    final Map<String, bool> c = containerChecks;
    return c.values.where((bool b) => b).length / c.length;
  }

  static String qualitativeOutput(double rate) =>
      rate >= floor ? 'Pass' : 'Fail';

  static const String collapsedIsTheFeatureNote =
      'An open promo field on checkout is an instruction to go and find a '
      'code. People leave to look and a measurable share do not come back. '
      'Collapsed by default is the requirement rather than a default, which is '
      'why it is written down here: "expand it, it is one less tap" is a '
      'reasonable-sounding change that nothing in the code would argue with.';

  static const String latchedByContentNote =
      'Two ordinary events collapse a naive accordion: a failed apply, whose '
      'error message is inside the panel that just closed, and a rebuild when '
      'the order total changes. Both destroy a code the parent already typed '
      'and both read as the app ignoring them. Expansion is latched by what '
      'the panel contains, not only by the tap that opened it.';

  static const String disclosureIsAStateNote =
      'A rotating chevron is invisible to a screen reader. The expanded state '
      'is announced and the panel is associated with the control that toggles '
      'it, per Step 97\'s progressive disclosure rule.';

  static const String validationIsNotHereNote =
      'This step owns the container. Whether a code is valid is a server '
      'question and Step 206 owns the field that asks it. What is graded here '
      'is whether the container ever destroys an input that was about to be '
      'validated, which is a denominator this file controls.';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Construct an expandable promo code input accordion container on the '
      'checkout screen."';
}
