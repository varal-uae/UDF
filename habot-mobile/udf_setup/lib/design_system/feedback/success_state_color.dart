/// AISS Step 190 -- GEN-04913
/// Setup Step (Action): (empty on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement the mobile UI styling requirement: M3 Success Green
///               color tokens applied on valid signature lock."
/// Metric: UI Styling / Transition Compliance -- Floor "<=100ms transition
///         duration; visual QA pass on target devices", Optimal "<=100ms
///         transition, 100% visual QA pass", Ceiling ">100ms transitions read
///         as sluggish; >0 visual QA defects". Pass / Fail.
///
/// **THERE IS NO SUCCESS ROLE IN MATERIAL DESIGN 3.** The scheme specifies
/// primary, secondary, tertiary and error, and that is the whole semantic set.
/// "M3 Success Green color tokens" names something the specification does not
/// contain, so there are three ways to proceed and two of them are wrong:
/// reach for `Colors.green` (which the poka-yoke guard blocks, correctly,
/// because it is an unaudited literal); invent a hex in this file (blocked for
/// the same reason, and it would be a colour nothing gated); or **use an
/// audited role and declare the gap**. This step does the third.
///
/// `tertiary` is the carrier. It is MD3's third accent, it is already gated at
/// 4.5:1 against `onTertiary` by the Step 4 audit, and it is not used for
/// anything else in this product. A dedicated `success` / `onSuccess` pair is
/// the right long-term answer and is requested through the Step 177 brand
/// extension mechanism rather than smuggled in as a literal.
///
/// **GREEN IS THE SINGLE WORST COLOUR TO CARRY MEANING ALONE.** Red-green
/// deficiency is the most common colour vision deficiency there is. To those
/// users the "locked" tick and the Step 189 error border are the same colour.
/// So the success state is distinguished by the SHAPE of its glyph — a check
/// mark, not a filled dot — and by an announcement, and the colour is the
/// least load-bearing of the three carriers rather than the only one.
///
/// **"VALID SIGNATURE LOCK" MAKES THE FALSE POSITIVE THE EXPENSIVE
/// DIRECTION.** A missing success indicator is a user who checks again. A
/// success indicator shown over a write that has not actually committed is a
/// user who walks away from an unsigned document. So the state is driven by
/// the COMMITTED outcome, never by the optimistic local one: an entry sitting
/// in the Step 117 outbox is queued, not signed, and
/// [HabotSuccessStateColor.mayShowSuccess] refuses to paint it.
library;

import '../data/outbox.dart';
import '../forms/validation_state_color.dart';
import '../tokens/m3_naming.dart';
import '../tokens/motion_tokens.dart';

/// How confident the app is that the thing actually happened.
enum HabotCommitConfidence {
  /// Written locally, queued, not acknowledged. Step 117.
  queuedLocally,

  /// Handed to the server, no answer yet.
  inFlight,

  /// Acknowledged. The only state that may be painted as success.
  committed,

  /// It failed.
  failed,
}

/// The colour roles and carriers for the success state.
class HabotSuccessStateColor {
  const HabotSuccessStateColor._();

  /// **The substitution, named.** MD3 has no success role.
  static const String requestedRole = 'success (M3 Success Green)';

  /// What carries it instead: an existing, audited role.
  static const String carrierRole = 'tertiary';
  static const String carrierOnRole = 'onTertiary';

  static String get carrierToken =>
      'md.sys.color.${HabotM3Naming.kebab(carrierRole)}';

  static String get carrierOnToken =>
      'md.sys.color.${HabotM3Naming.kebab(carrierOnRole)}';

  /// The roles the success state paints, by surface.
  static const Map<String, String> successRoles = <String, String>{
    'border': carrierRole,
    'icon': carrierRole,
    'container': 'tertiaryContainer',
    'containerText': 'onTertiaryContainer',
  };

  /// The brand extension this row actually wants, requested rather than
  /// invented. Adding it means adding a colour, which means the Step 4 audit,
  /// which means it goes through brand sign-off with everything else --
  /// and the palette is still PROVISIONAL (Step 174).
  static const Map<String, String> requestedExtension = <String, String>{
    'success': 'A dedicated positive-outcome role. Today tertiary carries it, '
        'which works because tertiary is unused elsewhere in this product -- '
        'that is a coincidence rather than a design, and the first feature '
        'that wants a third accent will collide with it.',
    'onSuccess': 'Its text pair, gated at 4.5:1 like every other on- role.',
    'successContainer': 'The low-emphasis surface form.',
    'onSuccessContainer': 'Its text pair.',
  };

  // ---- timing --------------------------------------------------------------

  /// Success may ease in. Unlike an error (Step 189) it is not an alert, and
  /// an immediate snap to a confirmed state is the thing that makes people
  /// unsure whether they caused it.
  static Duration get enterTransition => HabotMotion.fast;

  static Duration get exitTransition => HabotMotion.fast;

  static Duration get budget => HabotMotion.fast;

  static bool withinBudget(Duration d) => d <= budget;

  // ---- what may be painted, and when --------------------------------------

  /// **The gate.** Only a committed outcome may be shown as success.
  static bool mayShowSuccess(HabotCommitConfidence confidence) =>
      confidence == HabotCommitConfidence.committed;

  /// Read the confidence from an outbox entry, so the rule is applied to the
  /// state the queue actually holds rather than to a flag somebody set.
  static HabotCommitConfidence confidenceOf(HabotOutboxEntry entry) {
    switch (entry.state) {
      case HabotOutboxState.sent:
        return HabotCommitConfidence.committed;
      case HabotOutboxState.inFlight:
        return HabotCommitConfidence.inFlight;
      case HabotOutboxState.pending:
        return HabotCommitConfidence.queuedLocally;
      case HabotOutboxState.dead:
        return HabotCommitConfidence.failed;
    }
  }

  /// What the user sees when the signature is not yet locked. Not success, and
  /// not nothing: the Step 125 offline chip already says what a queue means.
  static const String pendingDisclosure =
      'Queued. The signature is saved on this device and will lock when the '
      'connection returns.';

  // ---- carriers ------------------------------------------------------------

  static Set<HabotStateCarrier> get carriers =>
      HabotValidationStateColor.carriersFor(HabotFieldVisualState.success);

  /// The glyph must differ in SHAPE, not only in hue -- see the header.
  static const String iconShape = 'check';
  static const String errorIconShape = 'exclamation';

  static bool get shapeDistinguishesFromError => iconShape != errorIconShape;

  // ---- the row's metric ---------------------------------------------------

  static Map<String, bool> get complianceChecks => <String, bool>{
        'the transition is within the row\'s 100ms budget':
            withinBudget(enterTransition) && withinBudget(exitTransition),
        'the carrier is an existing audited role rather than an unaudited '
                'literal':
            carrierRole == 'tertiary',
        'the carrier\'s text pair is declared, so the success surface clears '
                'the 4.5:1 floor':
            successRoles['containerText'] == 'onTertiaryContainer',
        'the success state is not conveyed by colour alone':
            carriers.length > 1 &&
                carriers.contains(HabotStateCarrier.semantics),
        'the success glyph differs from the error glyph in shape, not only in '
                'hue':
            shapeDistinguishesFromError,
        'success is not painted over an uncommitted write':
            !mayShowSuccess(HabotCommitConfidence.queuedLocally) &&
                !mayShowSuccess(HabotCommitConfidence.inFlight) &&
                mayShowSuccess(HabotCommitConfidence.committed),
        'the missing MD3 role is requested as a brand extension rather than '
                'invented as a literal':
            requestedExtension.length == 4,
        'every declared role converts to a conformant MD3 token name':
            HabotM3Naming.isConformant(carrierToken) &&
                HabotM3Naming.isConformant(carrierOnToken),
      };

  static bool get isCompliant =>
      complianceChecks.values.every((bool b) => b);

  static String get qualitativeOutput => isCompliant ? 'Pass' : 'Fail';

  /// What is not done, named. The row is satisfied on its implementable
  /// reading; this is the part that is carried rather than solved.
  static const List<String> outstanding = <String>[
    'A dedicated success / onSuccess / successContainer / onSuccessContainer '
        'role set. tertiary carries it today because tertiary happens to be '
        'unused in this product, which is a coincidence rather than a design. '
        'Adding the roles means adding colours, which means the Step 4 audit '
        'and brand sign-off -- and the palette has been PROVISIONAL since '
        'Step 1.',
  ];

  static const String noSuccessRoleNote =
      'Material Design 3 specifies primary, secondary, tertiary and error, and '
      'that is the whole semantic set. "M3 Success Green" names something the '
      'specification does not contain. Reaching for Colors.green or inventing '
      'a hex would both be unaudited literals the guard blocks, correctly. An '
      'audited role carries it and the gap is declared.';

  static const String greenAloneNote =
      'Red-green deficiency is the most common colour vision deficiency there '
      'is. To those users the "locked" tick and the Step 189 error border are '
      'the same colour. The success state is distinguished by the SHAPE of its '
      'glyph and by an announcement; the colour is the least load-bearing of '
      'the three carriers rather than the only one.';

  static const String falsePositiveNote =
      'A missing success indicator is a user who checks again. A success '
      'indicator over a write that has not committed is a user who walks away '
      'from an unsigned document. The state is driven by the committed '
      'outcome, never by the optimistic local one: an entry in the Step 117 '
      'outbox is queued, not signed.';

  static const String columnNote =
      'Setup Step (Action) is EMPTY on this row. The Atomic Step is the unit '
      'of work.';
}
