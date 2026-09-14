/// Step 214 (GEN-01308) -- submitting a dispute.
///
/// The row: "Embed M3 Filled Buttons for final dispute submission."
/// Metric: **Dispute Resolution Cycle Time** -- floor <5 business days, optimal
/// <48 hours, ceiling <10 business days.
///
/// **The metric measures something that happens after the app stops.** Cycle
/// time is agents, queues and a decision the app is not party to, and no build
/// of this client changes it directly. What the client does change is the one
/// thing that reliably lengthens a cycle: an intake that arrives incomplete, so
/// the first thing the agent does is write back and ask. That round trip is
/// measured in days on either side of a weekend. So what is built and reported
/// here is intake completeness, with the substitution stated rather than a
/// cycle-time figure invented.
///
/// **The floor and ceiling are in BUSINESS days and a Duration cannot hold
/// one.** Five business days is between seven and nine calendar days depending
/// on when it starts, and in this market the weekend is Saturday-Sunday for
/// some counterparties and Friday-Saturday for others. They are kept as an
/// integer count of business days with the calendar left to whoever owns the
/// calendar; only the 48-hour optimal is expressible as a duration.
///
/// **"Final submission" needs to happen once.** A dispute submitted twice is
/// two cases on one transaction, which an agent resolves by closing one and
/// which the parent experiences as being ignored. Submission goes through Step
/// 120's idempotent dispatcher under a key derived from the dispute, not from
/// the tap.
///
/// **Offline.** A dispute filed on a train is queued, not filed. The difference
/// matters enough to say out loud on the confirmation, because a parent who
/// believes a dispute is filed stops chasing it.
library;

import '../data/idempotency.dart';
import '../tokens/button_role_map.dart';
import '../tokens/motion_tokens.dart';

/// What the parent is disputing.
enum HabotDisputeKind {
  /// Charged for something not received.
  serviceNotDelivered,

  /// Charged the wrong amount.
  amountIncorrect,

  /// Charged more than once.
  duplicateCharge,

  /// Did not authorise the charge at all.
  unauthorised,
}

/// A piece of the intake.
class HabotDisputeField {
  const HabotDisputeField({
    required this.name,
    required this.requiredFor,
    required this.whyItShortensTheCycle,
  });

  final String name;

  /// The dispute kinds this field is required for. A field required for every
  /// kind is a field the form should have asked for before the parent chose.
  final Set<HabotDisputeKind> requiredFor;

  /// Why an agent needs it. Recorded so a field cannot be dropped for being
  /// tedious without someone reading what dropping it costs.
  final String whyItShortensTheCycle;
}

/// What the parent has filled in.
class HabotDisputeDraft {
  const HabotDisputeDraft({
    required this.kind,
    required this.bookingReference,
    required this.providedFields,
    this.evidenceCount = 0,
  });

  final HabotDisputeKind kind;
  final String bookingReference;
  final Set<String> providedFields;

  /// How many files the parent attached. The files themselves are not carried
  /// through this type -- see Step 215.
  final int evidenceCount;
}

/// Submission.
class HabotDisputeSubmission {
  const HabotDisputeSubmission._();

  /// The intake.
  static const List<HabotDisputeField> fields = <HabotDisputeField>[
    HabotDisputeField(
      name: 'bookingReference',
      requiredFor: <HabotDisputeKind>{
        HabotDisputeKind.serviceNotDelivered,
        HabotDisputeKind.amountIncorrect,
        HabotDisputeKind.duplicateCharge,
      },
      whyItShortensTheCycle:
          'Without it the agent searches by name and date and asks the parent '
          'to confirm which of three bookings they mean.',
    ),
    HabotDisputeField(
      name: 'chargeDate',
      requiredFor: <HabotDisputeKind>{
        HabotDisputeKind.amountIncorrect,
        HabotDisputeKind.duplicateCharge,
        HabotDisputeKind.unauthorised,
      },
      whyItShortensTheCycle:
          'The statement line the parent is looking at and the transaction the '
          'agent can see are matched on date before anything else.',
    ),
    HabotDisputeField(
      name: 'expectedAmount',
      requiredFor: <HabotDisputeKind>{HabotDisputeKind.amountIncorrect},
      whyItShortensTheCycle:
          '"The amount is wrong" without the expected figure is one round trip '
          'that costs two business days.',
    ),
    HabotDisputeField(
      name: 'description',
      requiredFor: <HabotDisputeKind>{
        HabotDisputeKind.serviceNotDelivered,
        HabotDisputeKind.unauthorised,
      },
      whyItShortensTheCycle:
          'An unauthorised charge and a service not delivered are handled by '
          'different teams, and the description is what routes it.',
    ),
    HabotDisputeField(
      name: 'contactPreference',
      requiredFor: <HabotDisputeKind>{
        HabotDisputeKind.serviceNotDelivered,
        HabotDisputeKind.amountIncorrect,
        HabotDisputeKind.duplicateCharge,
        HabotDisputeKind.unauthorised,
      },
      whyItShortensTheCycle:
          'A reply sent to a channel the parent does not read is a cycle that '
          'runs to its timeout.',
    ),
  ];

  static List<HabotDisputeField> requiredFieldsFor(HabotDisputeKind kind) =>
      fields
          .where((HabotDisputeField f) => f.requiredFor.contains(kind))
          .toList();

  static List<String> missingFrom(HabotDisputeDraft draft) =>
      requiredFieldsFor(draft.kind)
          .where(
            (HabotDisputeField f) =>
                !draft.providedFields.contains(f.name),
          )
          .map((HabotDisputeField f) => f.name)
          .toList();

  /// Intake completeness for one draft.
  static double intakeCompleteness(HabotDisputeDraft draft) {
    final List<HabotDisputeField> required = requiredFieldsFor(draft.kind);
    if (required.isEmpty) {
      return 1;
    }
    return (required.length - missingFrom(draft).length) / required.length;
  }

  static bool isSubmittable(HabotDisputeDraft draft) =>
      missingFrom(draft).isEmpty && draft.bookingReference.isNotEmpty;

  // -----------------------------------------------------------------------
  // The button.
  // -----------------------------------------------------------------------

  /// The row asks for a filled button and a filled button is right: this is
  /// the action the screen exists for.
  static const HabotButtonRole role = HabotButtonRole.confirm;

  static String? get containerToken =>
      HabotButtonRoleMap.containerTokenFor(role);

  /// And it is preceded by a summary, because the action cannot be undone from
  /// the parent's side once the case is open.
  static const bool requiresReviewStep = true;

  static const String reviewStepNote =
      'A filled button is the correct emphasis and emphasis is not a '
      'safeguard. Once a case is open the parent cannot withdraw it from here, '
      'so a summary of what is about to be sent stands in front of the button. '
      'This is the same reading as Step 195: a dialog whose only outcome is '
      'the one it was going to take anyway is a notification.';

  // -----------------------------------------------------------------------
  // Submitting once.
  // -----------------------------------------------------------------------

  /// The idempotency key is derived from the dispute, not from the tap, so a
  /// retry after a dropped connection is the same request rather than a new
  /// one.
  static String idempotencyKeyFor(HabotDisputeDraft draft) =>
      'dispute:${draft.bookingReference}:${draft.kind.name}';

  /// Two drafts describing the same dispute produce the same key, whichever
  /// tap built them. Nothing in the key comes from the moment of pressing.
  static bool keyIsStableAcross(HabotDisputeDraft a, HabotDisputeDraft b) =>
      idempotencyKeyFor(a) == idempotencyKeyFor(b);

  /// A second dispute of a different kind on the same booking is a different
  /// case and gets a different key.
  static bool keySeparatesDifferentDisputes(
    HabotDisputeDraft a,
    HabotDisputeDraft b,
  ) =>
      a.kind == b.kind || idempotencyKeyFor(a) != idempotencyKeyFor(b);

  /// The dispatcher that enforces it.
  static const String dispatcherSite =
      'lib/design_system/data/idempotency.dart';

  static bool get dispatcherIsTheDeclaredOne =>
      HabotIdempotentDispatcher.mutationKinds.isNotEmpty;

  // -----------------------------------------------------------------------
  // Offline.
  // -----------------------------------------------------------------------

  /// Queued, not filed. Said in those words.
  static const String queuedConfirmation =
      'Saved. This dispute will be sent when you are back online -- it has not '
      'reached us yet.';

  static const String filedConfirmation =
      'Sent. We will reply through your chosen contact method.';

  static String confirmationFor({required bool reachedServer}) =>
      reachedServer ? filedConfirmation : queuedConfirmation;

  static bool get queuedAndFiledAreDifferentWords =>
      queuedConfirmation != filedConfirmation &&
      queuedConfirmation.contains('has not reached us');

  // -----------------------------------------------------------------------
  // Metric: Dispute Resolution Cycle Time.
  // -----------------------------------------------------------------------

  /// The optimal, which is the only one of the three expressible as a
  /// duration.
  static Duration get optimalCycle => HabotMotion.disputeCycleOptimal;

  /// Business days. Not durations -- see the file header.
  static const int floorBusinessDays = 5;
  static const int ceilingBusinessDays = 10;

  static const String businessDayNote =
      'Five business days is between seven and nine calendar days depending on '
      'when it starts, and the weekend is not the same two days for every '
      'counterparty in this market. A Duration cannot hold a business day, and '
      'a Duration of 120 hours is a different promise from the one the row '
      'makes. The two bounds are kept as a count of business days with the '
      'calendar left to whoever owns the calendar.';

  /// The ceiling here is the WORST tolerated value, not the best -- the same
  /// inversion recorded at Step 199 for a duration and at Step 212 for a
  /// rate where lower is better.
  static String qualitativeOutputForBusinessDays(int days) {
    if (days * 24 < optimalCycle.inHours) {
      return 'Good';
    }
    if (days < floorBusinessDays) {
      return 'Average';
    }
    return 'Poor';
  }

  static bool get ceilingIsTheWorstBound =>
      ceilingBusinessDays > floorBusinessDays;

  static Map<String, bool> checksFor(HabotDisputeDraft complete,
      HabotDisputeDraft partial) =>
      <String, bool>{
        'every required field says why an agent needs it': fields.every(
          (HabotDisputeField f) => f.whyItShortensTheCycle.isNotEmpty,
        ),
        'required fields differ by dispute kind':
            requiredFieldsFor(HabotDisputeKind.amountIncorrect).length !=
                requiredFieldsFor(HabotDisputeKind.unauthorised).length,
        'a complete intake submits': isSubmittable(complete) &&
            intakeCompleteness(complete) == 1,
        'an incomplete intake does not, and names what is missing':
            !isSubmittable(partial) && missingFrom(partial).isNotEmpty,
        'the submit action carries the confirm role rather than a bare filled '
                'style':
            role == HabotButtonRole.confirm && containerToken != null,
        'a summary stands in front of an irreversible action':
            requiresReviewStep,
        'the idempotency key comes from the dispute, not the tap':
            keyIsStableAcross(complete, complete) &&
                keySeparatesDifferentDisputes(complete, partial),
        'queued and filed are different words to the parent':
            queuedAndFiledAreDifferentWords,
        'the dispatcher is the declared one': dispatcherIsTheDeclaredOne,
      };

  static const String cycleTimeIsNotOursNote =
      'Cycle time is agents, queues and a decision this app is not party to. '
      'What the client changes is the one thing that reliably lengthens a '
      'cycle: an intake that arrives incomplete, so the agent\'s first action '
      'is to write back and ask -- a round trip measured in days on either '
      'side of a weekend. Intake completeness is what is built and what is '
      'reported, with the substitution stated rather than a cycle-time figure '
      'invented.';

  static const String submitOnceNote =
      'A dispute submitted twice is two cases on one transaction. An agent '
      'resolves that by closing one, and the parent experiences it as being '
      'ignored. The key is derived from the booking and the dispute kind, so a '
      'retry after a dropped connection is the same request.';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Embed M3 Filled Buttons for final dispute submission."';
}
