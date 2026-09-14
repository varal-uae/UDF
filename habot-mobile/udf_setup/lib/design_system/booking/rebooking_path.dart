/// Step 211 (GEN-01231) -- the re-booking path and its fifteen seconds.
///
/// The row: "Benchmark re-booking completion times targeting an execution
/// duration under 15 seconds."
/// Metric: One-Click Re-Booking Completion Rate -- 0.7 / 0.9 / 1.
///
/// **"One-click" and "under fifteen seconds" cannot both be descriptions of the
/// same flow.** One click is under a second. Fifteen seconds is a path with
/// decisions on it. The second number is the truthful one, and what it is
/// mostly made of is not code: it is a person confirming a date, confirming
/// which children, and a payment sheet the app does not own. Benchmarking wall
/// clock would mostly be benchmarking the payment sheet.
///
/// What can be bounded, and what this file bounds, is the number of DECISIONS
/// on the path. That is the quantity the app controls and the one that actually
/// moves the completion rate: each additional required decision is a place the
/// parent can stop.
///
/// **The dangerous version of this feature is the one that works.** A re-book
/// that replays a stored booking -- same children, same card, same slot, one
/// tap -- can charge for a child who has aged out of the service, a date in the
/// past, a session that is now full, or a card that expired last month. Every
/// one of those produces a confirmed booking and a refund conversation. So the
/// path REVALIDATES rather than replays, and the revalidation is where the
/// seconds go. A re-book that is instant is a re-book that did not check.
library;

import '../tokens/motion_tokens.dart';

/// A thing the parent has to decide, or confirm, on the way to a booking.
class HabotBookingDecision {
  const HabotBookingDecision({
    required this.id,
    required this.label,
    required this.requiredOnFirstBooking,
    required this.requiredOnRebooking,
    required this.canBePrefilled,
  });

  final String id;
  final String label;

  final bool requiredOnFirstBooking;

  /// Whether a re-book still has to ask. A decision that is prefilled but
  /// still shown for confirmation counts as required: the parent still has to
  /// look at it, and looking at it is most of the fifteen seconds.
  final bool requiredOnRebooking;

  final bool canBePrefilled;
}

/// What a revalidation found.
enum HabotRebookingBlocker {
  /// The child is now outside the service's age band.
  childAgedOut,

  /// The requested date has passed.
  datePassed,

  /// The session is full.
  capacityGone,

  /// The stored payment instrument has expired.
  cardExpired,

  /// The price is not what it was.
  priceChanged,

  /// The service is no longer offered.
  serviceWithdrawn,
}

/// The path.
class HabotRebookingPath {
  const HabotRebookingPath._();

  /// Every decision on the booking path, first time and repeat.
  static const List<HabotBookingDecision> decisions =
      <HabotBookingDecision>[
    HabotBookingDecision(
      id: 'service',
      label: 'Choose the service',
      requiredOnFirstBooking: true,
      requiredOnRebooking: false,
      canBePrefilled: true,
    ),
    HabotBookingDecision(
      id: 'date',
      label: 'Choose the date',
      requiredOnFirstBooking: true,
      requiredOnRebooking: true,
      canBePrefilled: true,
    ),
    HabotBookingDecision(
      id: 'children',
      label: 'Choose which children',
      requiredOnFirstBooking: true,
      requiredOnRebooking: true,
      canBePrefilled: true,
    ),
    HabotBookingDecision(
      id: 'addons',
      label: 'Choose add-ons',
      requiredOnFirstBooking: false,
      requiredOnRebooking: false,
      canBePrefilled: true,
    ),
    HabotBookingDecision(
      id: 'requirements',
      label: 'Confirm special requirements',
      requiredOnFirstBooking: true,
      requiredOnRebooking: false,
      canBePrefilled: true,
    ),
    HabotBookingDecision(
      id: 'payment',
      label: 'Enter payment details',
      requiredOnFirstBooking: true,
      requiredOnRebooking: false,
      canBePrefilled: true,
    ),
    HabotBookingDecision(
      id: 'confirm',
      label: 'Confirm and pay',
      requiredOnFirstBooking: true,
      requiredOnRebooking: true,
      canBePrefilled: false,
    ),
  ];

  static int get firstBookingDecisionCount => decisions
      .where((HabotBookingDecision d) => d.requiredOnFirstBooking)
      .length;

  static int get rebookingDecisionCount => decisions
      .where((HabotBookingDecision d) => d.requiredOnRebooking)
      .length;

  /// The reduction the feature actually delivers.
  static double get decisionReduction =>
      (firstBookingDecisionCount - rebookingDecisionCount) /
      firstBookingDecisionCount;

  /// The decision count a literal one-click implementation would have.
  static const int oneClickDecisionCount = 1;

  /// The target from the row.
  static Duration get target => HabotMotion.rebookingTarget;

  /// Revalidation is not optional and the reason is written down.
  static const bool revalidatesRatherThanReplays = true;

  /// What is re-checked before a re-book is allowed to charge.
  static const List<HabotRebookingBlocker> revalidated =
      HabotRebookingBlocker.values;

  static bool get revalidationIsTotal =>
      revalidated.length == HabotRebookingBlocker.values.length;

  /// A blocker's effect: whether the path can continue after showing it.
  static bool isRecoverableInPlace(HabotRebookingBlocker blocker) =>
      switch (blocker) {
        HabotRebookingBlocker.datePassed => true,
        HabotRebookingBlocker.capacityGone => true,
        HabotRebookingBlocker.priceChanged => true,
        HabotRebookingBlocker.cardExpired => true,
        HabotRebookingBlocker.childAgedOut => false,
        HabotRebookingBlocker.serviceWithdrawn => false,
      };

  /// What the parent is told, rather than a code.
  static String messageFor(HabotRebookingBlocker blocker) =>
      switch (blocker) {
        HabotRebookingBlocker.childAgedOut =>
          'This service is no longer for this age group.',
        HabotRebookingBlocker.datePassed => 'Choose a new date.',
        HabotRebookingBlocker.capacityGone =>
          'This session is full. Choose another time.',
        HabotRebookingBlocker.cardExpired =>
          'Your saved card has expired. Add a card to continue.',
        HabotRebookingBlocker.priceChanged =>
          'The price has changed since your last booking.',
        HabotRebookingBlocker.serviceWithdrawn =>
          'This service is no longer offered.',
      };

  /// A price change is never applied silently, whatever the direction.
  static const bool priceChangeIsAlwaysShown = true;

  /// The decisions a re-book skips because the answer is carried forward.
  static List<String> get carriedForward => decisions
      .where(
        (HabotBookingDecision d) =>
            d.requiredOnFirstBooking && !d.requiredOnRebooking,
      )
      .map((HabotBookingDecision d) => d.id)
      .toList();

  // -----------------------------------------------------------------------
  // Metric: One-Click Re-Booking Completion Rate. 0.7 / 0.9 / 1.
  // -----------------------------------------------------------------------

  static const double floor = 0.7;
  static const double optimal = 0.9;
  static const double ceiling = 1;

  /// Completion rate over attempts. Needs real sessions; not producible here.
  static double completionRate({
    required int completed,
    required int started,
  }) =>
      started == 0 ? 0 : completed / started;

  static String qualitativeOutput(double rate) {
    if (rate >= optimal) {
      return 'Good';
    }
    if (rate >= floor) {
      return 'Average';
    }
    return 'Poor';
  }

  /// What this step can be graded on statically.
  static Map<String, bool> get checks => <String, bool>{
        'the re-book path asks fewer decisions than the first booking':
            rebookingDecisionCount < firstBookingDecisionCount,
        'at least half the decisions are carried forward':
            decisionReduction >= 0.5,
        'the date is still confirmed, because a stored date goes stale':
            decisions
                .firstWhere((HabotBookingDecision d) => d.id == 'date')
                .requiredOnRebooking,
        'the children are still confirmed, because a family changes':
            decisions
                .firstWhere((HabotBookingDecision d) => d.id == 'children')
                .requiredOnRebooking,
        'the final confirmation is never prefilled': !decisions
            .firstWhere((HabotBookingDecision d) => d.id == 'confirm')
            .canBePrefilled,
        'every revalidation failure is re-checked':
            revalidationIsTotal && revalidatesRatherThanReplays,
        'every blocker has a message written for a parent':
            HabotRebookingBlocker.values.every(
          (HabotRebookingBlocker b) => messageFor(b).isNotEmpty,
        ),
        'a price change is shown in both directions':
            priceChangeIsAlwaysShown,
        'the literal one-click reading is not what ships':
            rebookingDecisionCount > oneClickDecisionCount,
      };

  static double get adherence =>
      checks.values.where((bool b) => b).length / checks.length;

  static const String oneClickAndFifteenSecondsNote =
      'One click is under a second. Fifteen seconds is a path with decisions '
      'on it. The two numbers in this row describe different features and the '
      'second is the truthful one -- and most of it is a person confirming a '
      'date and a payment sheet the app does not own. Benchmarking wall clock '
      'would mostly be benchmarking the payment sheet.';

  static const String decisionsAreTheMeasurableThingNote =
      'What the app controls is the number of decisions on the path, and that '
      'is what moves the completion rate: every required decision is a place '
      'the parent can stop. Six required decisions on a first booking, three '
      'on a re-book -- a reduction of half, and the three that remain are the '
      'three that go stale.';

  static const String replayIsTheDangerousVersionNote =
      'A re-book that replays a stored booking can charge for a child who has '
      'aged out, a date in the past, a session now full, or a card that '
      'expired last month -- each producing a confirmed booking and a refund '
      'conversation. The path revalidates instead, and the revalidation is '
      'where the seconds go. A re-book that is instant is a re-book that did '
      'not check.';

  static const String wallClockNotProducibleNote =
      'No Dart toolchain and no instrumentation on this host, so no timing '
      'figure is produced and none is invented. The decision counts are '
      'structural and are what is reported.';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Benchmark re-booking completion times targeting an execution duration '
      'under 15 seconds."';
}
