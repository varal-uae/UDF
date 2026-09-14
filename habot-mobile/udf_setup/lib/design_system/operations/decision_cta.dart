/// Step 212 (GEN-01253) -- the operator's Approve / Reject actions.
///
/// The row: "Implement binary 'Approve' and 'Reject' decision CTA buttons for
/// operator overrides."
/// Metric: **Fraud Detection False-Positive Rate** -- floor <5%, optimal <1%,
/// ceiling <10%.
///
/// **The row's metric is an argument against the row's instruction.** A false
/// positive is a legitimate order rejected. A reviewer given two buttons and no
/// third option, looking at an order they are not sure about, has to pick
/// one -- and the incentive under review is always to reject, because an
/// approved
/// fraud is a loss with their name on it and a rejected customer is a support
/// ticket with nobody's. Binary is exactly the shape that manufactures false
/// positives. A third outcome that costs the reviewer nothing to choose is the
/// cheapest available reduction in the number this row is graded on.
///
/// So Approve and Reject are built as the row asks, and **Needs more
/// information** is built beside them, marked as beyond the row.
///
/// **Two buttons of equal weight is the other defect.** Reject is destructive
/// and irreversible in its effect on the customer; Approve releases money.
/// Step 188's role map already says a destructive action does not take the
/// primary container, and neither of these may be the default focus, because a
/// reviewer working a queue with a keyboard will eventually press return on the
/// wrong row.
library;

import '../i18n/localization_objective.dart';
import '../tokens/button_role_map.dart';

/// What a reviewer can decide.
enum HabotReviewOutcome {
  /// Release the order.
  approve,

  /// Refuse it.
  reject,

  /// Neither, yet -- the reviewer does not have enough to decide.
  needsInformation,
}

/// One action as it is presented.
class HabotDecisionAction {
  const HabotDecisionAction({
    required this.outcome,
    required this.label,
    required this.role,
    required this.isReversible,
    required this.requiresReasonCode,
    required this.namedInRow,
  });

  final HabotReviewOutcome outcome;
  final String label;

  /// The Step 188 role, which decides the colour and the variant.
  final HabotButtonRole role;

  /// Whether the decision can be taken back from inside the app.
  final bool isReversible;

  /// Whether Step 213's reason-code gate stands in front of it.
  final bool requiresReasonCode;

  /// Whether the row asked for this action.
  final bool namedInRow;
}

/// The decision bar.
class HabotDecisionCta {
  const HabotDecisionCta._();

  static const List<HabotDecisionAction> actions = <HabotDecisionAction>[
    HabotDecisionAction(
      outcome: HabotReviewOutcome.approve,
      label: 'Approve',
      role: HabotButtonRole.confirm,
      // Reversible within the window below, and only within it.
      isReversible: true,
      requiresReasonCode: false,
      namedInRow: true,
    ),
    HabotDecisionAction(
      outcome: HabotReviewOutcome.reject,
      label: 'Reject',
      role: HabotButtonRole.destructive,
      isReversible: false,
      requiresReasonCode: true,
      namedInRow: true,
    ),
    HabotDecisionAction(
      outcome: HabotReviewOutcome.needsInformation,
      label: 'Needs info',
      role: HabotButtonRole.secondary,
      isReversible: true,
      requiresReasonCode: false,
      namedInRow: false,
    ),
  ];

  static HabotDecisionAction actionFor(HabotReviewOutcome outcome) =>
      actions.firstWhere((HabotDecisionAction a) => a.outcome == outcome);

  /// Colour roles come from Step 188, so reject is not painted like approve.
  static String? containerTokenFor(HabotReviewOutcome outcome) =>
      HabotButtonRoleMap.containerTokenFor(actionFor(outcome).role);

  static bool get rejectIsNotColouredLikeApprove =>
      containerTokenFor(HabotReviewOutcome.reject) !=
      containerTokenFor(HabotReviewOutcome.approve);

  /// Neither destructive nor money-releasing action takes initial focus.
  ///
  /// A reviewer working a queue with a keyboard presses return on the wrong
  /// row eventually. What return does then should be nothing.
  static HabotReviewOutcome? get initiallyFocused => null;

  /// The approving action sits at the TRAILING edge in reading order, as at
  /// Steps 188 and 193 -- so it is on the right in English and the left in
  /// Urdu, and "the right-hand button" is not a stable description of it.
  static const HabotReviewOutcome outcomeAtTrailingEdge =
      HabotReviewOutcome.approve;

  /// Which screen side that lands on.
  static bool approveIsOnTheRight(HabotTextDirectionality direction) =>
      HabotButtonRoleMap.roleAtRight(direction) ==
      actionFor(outcomeAtTrailingEdge).role;

  static bool get sideOrderIsDirectionAware =>
      approveIsOnTheRight(HabotTextDirectionality.leftToRight) &&
      !approveIsOnTheRight(HabotTextDirectionality.rightToLeft);

  /// How long an approval can be taken back before the order is released.
  ///
  /// Expressed in the queue's own terms -- a number of subsequent decisions --
  /// rather than a wall clock, because a reviewer who realises their mistake
  /// realises it on the next order, not after a fixed interval.
  static const int approvalReversalWindowDecisions = 1;

  static bool get approvalIsReversible =>
      actionFor(HabotReviewOutcome.approve).isReversible &&
      approvalReversalWindowDecisions > 0;

  /// Rejection is not reversible from here, and that is deliberate: an
  /// un-rejection would release an order that a reason code has already been
  /// recorded against, which is a different decision and belongs to a
  /// different authority.
  static bool get rejectionIsNotReversibleInApp =>
      !actionFor(HabotReviewOutcome.reject).isReversible;

  // -----------------------------------------------------------------------
  // Metric: Fraud Detection False-Positive Rate. <5% / <1% / <10%.
  // -----------------------------------------------------------------------

  static const double floorRate = 0.05;
  static const double optimalRate = 0.01;
  static const double ceilingRate = 0.10;

  /// Lower is better here, which inverts the sheet's usual reading -- the same
  /// shape recorded at Step 199 for a duration metric.
  static const bool lowerIsBetter = true;

  static double falsePositiveRate({
    required int legitimateOrdersRejected,
    required int ordersRejected,
  }) =>
      ordersRejected == 0 ? 0 : legitimateOrdersRejected / ordersRejected;

  static String qualitativeOutput(double rate) {
    if (rate < optimalRate) {
      return 'Good';
    }
    if (rate < floorRate) {
      return 'Average';
    }
    return 'Poor';
  }

  /// The rate cannot be computed in the app at all: it needs to know which
  /// rejected orders were legitimate, which is knowledge that arrives weeks
  /// later through chargebacks and complaints.
  static const bool rateIsComputableInApp = false;

  static Map<String, bool> get checks => <String, bool>{
        'both actions the row names exist':
            actions.where((HabotDecisionAction a) => a.namedInRow).length == 2,
        'a third outcome exists so an unsure reviewer need not guess':
            actions.any(
          (HabotDecisionAction a) =>
              a.outcome == HabotReviewOutcome.needsInformation,
        ),
        'the third outcome is marked as beyond the row': !actionFor(
          HabotReviewOutcome.needsInformation,
        ).namedInRow,
        'reject is not coloured like approve': rejectIsNotColouredLikeApprove,
        'reject carries the destructive role':
            actionFor(HabotReviewOutcome.reject).role ==
                HabotButtonRole.destructive,
        'nothing is focused by default': initiallyFocused == null,
        'rejection is gated by a reason code':
            actionFor(HabotReviewOutcome.reject).requiresReasonCode,
        'approval can be taken back within the queue window':
            approvalIsReversible,
        'rejection is not silently reversible in the app':
            rejectionIsNotReversibleInApp,
        'the approving action is trailing rather than right-hand':
            sideOrderIsDirectionAware,
      };

  static double get adherence =>
      checks.values.where((bool b) => b).length / checks.length;

  static const String binaryManufacturesFalsePositivesNote =
      'A false positive is a legitimate order rejected. A reviewer with two '
      'buttons and an order they are unsure about has to pick one, and the '
      'incentive is always to reject: an approved fraud is a loss with their '
      'name on it, a rejected customer is a support ticket with nobody\'s. '
      'Binary is the shape that manufactures the number this row is graded '
      'on. A third outcome that costs nothing to choose is the cheapest '
      'available reduction in it.';

  static const String equalWeightNote =
      'Two buttons of equal size and weight make a destructive decision as '
      'easy as a benign one. Step 188\'s role map already says a destructive '
      'action does not take the primary container, and nothing takes initial '
      'focus, because a reviewer working a queue on a keyboard eventually '
      'presses return on the wrong row.';

  static const String rateIsNotOursNote =
      'The false-positive rate needs to know which rejected orders were '
      'legitimate. That arrives weeks later, through chargebacks and '
      'complaints, and is not knowable in the app at any point. No figure is '
      'produced; what is reported is the design property that moves it.';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Implement binary \'Approve\' and \'Reject\' decision CTA buttons for '
      'operator overrides."';
}
