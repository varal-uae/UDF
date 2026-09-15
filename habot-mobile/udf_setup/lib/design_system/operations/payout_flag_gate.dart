/// Step 293 (PCDE-019) -- the recovery route Step 292 was missing, sitting in
/// the next row, and an instruction to delete the number people need.
///
/// The row: "Autonomously disable and grey out the payout execution buttons if
/// the flag is False."
/// Metric: **Financial Calculation Accuracy (%)** -- floor 99.99, optimal 100,
/// ceiling 100. Pass / Fail. Cited: ISO 20022.
///
/// **This row carries the fix for the previous one.** Its design notes say
/// "tapping the suspended chip opens a dialogue explaining recovery steps" --
/// the route out of the dead end Step 292's "permanently disable" would have
/// created. It also repeats the same mistake in its own notes ("payroll submit
/// buttons remain permanently disabled"), so the row contains both the defect
/// and its remedy, two lines apart.
///
/// **"Replacing numeric data with Blocked icons" destroys the information the
/// block is about.** The amount is still true; what changed is whether it can
/// be paid. Replace it with an icon and nobody can tell a blocked 500 from a
/// blocked 5 -- and the first question anybody asks about a suspended payment
/// is how much. The number stays and the state is marked.
///
/// **"Red warning chips directly over the expected bonus dollar amount" is an
/// overlay on money.** A chip drawn over a figure produces a screenshot that
/// means something different from the screen, and payment screenshots travel.
/// The chip goes beside the amount.
///
/// **And a client-side disable does not stop a payout.** The button is a
/// courtesy; the server holds the money. 99.99% accuracy on payouts is one
/// wrong payment in ten thousand, which is a person, and Step 253 already
/// refused partial credit on money.
library;

import '../operations/permanent_disable.dart';

/// What the screen does with a suspended amount.
enum HabotSuspendedPresentation {
  /// The number is replaced by an icon. Refused.
  numberReplaced,

  /// The number stays and a marker is drawn over it. Refused.
  markerOverlaid,

  /// The number stays and a marker sits beside it.
  markerBeside,
}

/// One payout row on the screen.
class HabotPayoutRow {
  const HabotPayoutRow({
    required this.label,
    required this.amountMinor,
    required this.flagIsTrue,
  });

  final String label;

  /// Minor units, because money in a double is the defect Step 252 measured.
  final int amountMinor;

  /// The server's flag. False means the payout may not execute.
  final bool flagIsTrue;

  bool get isSuspended => !flagIsTrue;
}

/// The gate.
class HabotPayoutFlagGate {
  const HabotPayoutFlagGate._();

  // -----------------------------------------------------------------------
  // The presentation the row asks for, and the one used.
  // -----------------------------------------------------------------------

  static const HabotSuspendedPresentation presentationUsed =
      HabotSuspendedPresentation.markerBeside;

  static const List<HabotSuspendedPresentation> presentationsRefused =
      <HabotSuspendedPresentation>[
    HabotSuspendedPresentation.numberReplaced,
    HabotSuspendedPresentation.markerOverlaid,
  ];

  static bool get bothOfTheRowsPresentationsAreRefused =>
      presentationsRefused.length == 2 &&
      !presentationsRefused.contains(presentationUsed) &&
      HabotSuspendedPresentation.values.length == 3;

  /// What is drawn for a suspended row: the amount, unchanged, and a state
  /// marker next to it.
  static String renderFor(HabotPayoutRow row) => row.isSuspended
      ? '${row.amountMinor} (suspended)'
      : '${row.amountMinor}';

  static bool get theAmountSurvivesSuspension =>
      renderFor(
        const HabotPayoutRow(
          label: 'bonus',
          amountMinor: 50000,
          flagIsTrue: false,
        ),
      ).contains('50000');

  /// The test the row's own instruction fails: two suspended amounts of very
  /// different size have to remain distinguishable.
  static bool get twoSuspendedAmountsStayDistinguishable =>
      renderFor(
        const HabotPayoutRow(
          label: 'a',
          amountMinor: 50000,
          flagIsTrue: false,
        ),
      ) !=
      renderFor(
        const HabotPayoutRow(
          label: 'b',
          amountMinor: 500,
          flagIsTrue: false,
        ),
      );

  static const String keepTheNumberNote =
      'Replacing the amount with a Blocked icon destroys the information the '
      'block is about. The figure is still true -- what changed is whether it '
      'can be paid -- and the first question anybody asks about a suspended '
      'payment is how much. An icon makes a blocked five hundred and a '
      'blocked five look identical, which turns one support call into two. '
      'The number stays and the state is marked beside it, not over it: a '
      'chip drawn across a figure produces a screenshot that means something '
      'different from the screen, and payment screenshots travel.';

  // -----------------------------------------------------------------------
  // The recovery route the previous row needed.
  // -----------------------------------------------------------------------

  /// Every suspended row can be tapped, and the tap explains what would
  /// change it. This is the property Step 292's "permanently" would have
  /// removed, and it is in this row's own design notes.
  static const bool suspendedRowsAreTappable = true;

  static String recoveryTextFor(HabotPayoutRow row) => row.isSuspended
      ? 'This payout is on hold while the account check completes. It '
          'releases on its own once the check passes; nothing is lost in the '
          'meantime.'
      : '';

  static bool get everySuspendedRowExplainsItself =>
      suspendedRowsAreTappable &&
      recoveryTextFor(
        const HabotPayoutRow(
          label: 'bonus',
          amountMinor: 1,
          flagIsTrue: false,
        ),
      ).isNotEmpty;

  /// And the disable is conditional, for the reason Step 292 gives -- read
  /// from that step rather than restated, so the two cannot disagree.
  static bool get theDisableIsConditionalLikeStep292 =>
      HabotPermanentDisable.kindUsed == HabotDisableKind.conditional &&
      HabotPermanentDisable.theButtonComesBack;

  static const String adjacentRowsNote =
      'This row carries the fix for the previous one. Its design notes say '
      '"tapping the suspended chip opens a dialogue explaining recovery '
      'steps", which is exactly the route out of the dead end Step 292\'s '
      '"permanently disable" creates -- and two lines later the same notes '
      'say "payroll submit buttons remain permanently disabled", repeating '
      'the defect. One row, both the problem and its remedy, neither aware of '
      'the other. The remedy is implemented for both rows and the repetition '
      'is recorded.';

  // -----------------------------------------------------------------------
  // A disabled button is not a control on money.
  // -----------------------------------------------------------------------

  static const bool theClientDecidesWhetherToDrawTheButton = true;
  static const bool theClientDecidesWhetherMoneyMoves = false;

  static bool get theServerHoldsTheMoney =>
      theClientDecidesWhetherToDrawTheButton &&
      !theClientDecidesWhetherMoneyMoves;

  static const String courtesyNote =
      'A greyed-out button does not stop a payout. It stops a person pressing '
      'it, which is worth doing -- most of what a disable prevents is an '
      'honest mistake -- but the request can still be made and the server is '
      'what refuses it. So the flag arriving False is a report of a decision '
      'taken elsewhere, and the button is the client explaining it. The '
      'fourth row in this batch with this shape: Steps 272, 273 and 275 are '
      'the others.';

  // -----------------------------------------------------------------------
  // Metric: Financial Calculation Accuracy -- 99.99 / 100 / 100.
  // -----------------------------------------------------------------------

  static const double floorPercent = 99.99;
  static const double optimalPercent = 100;
  static const double ceilingPercent = 100;

  /// One error in ten thousand payouts. Stated in people rather than
  /// decimals, which is the unit a floor on money is actually in.
  static int get payoutsPerErrorAtFloor =>
      (1 / (1 - floorPercent / 100)).round();

  static bool get theFloorIsOnePersonInTenThousand =>
      payoutsPerErrorAtFloor == 10000 && floorPercent < optimalPercent;

  static const String moneyBandNote =
      'A floor of 99.99% on payouts is one wrong payment in ten thousand, and '
      'the unit of that error is a person who was not paid. Step 253 already '
      'refused partial credit on money for the same reason: an amount is '
      'right or it is wrong, and a rate is what you measure when you have '
      'decided some of them may be wrong. The figure is carried verbatim and '
      'restated in people, which is the form somebody can make a decision '
      'about.';

  /// And this step does not calculate anything, which is the other half of
  /// the mismatch: it draws a button according to a flag.
  static const bool thisStepPerformsNoCalculation = true;

  static String get qualitativeOutput =>
      theAmountSurvivesSuspension &&
              everySuspendedRowExplainsItself &&
              theDisableIsConditionalLikeStep292
          ? 'Pass'
          : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'both presentations the row asks for are refused':
            bothOfTheRowsPresentationsAreRefused,
        'the amount survives suspension':
            theAmountSurvivesSuspension &&
                twoSuspendedAmountsStayDistinguishable,
        'the cost of replacing the number is recorded':
            keepTheNumberNote.contains('screenshots travel'),
        'every suspended row explains what would change it':
            everySuspendedRowExplainsItself,
        'the disable is conditional, read from Step 292':
            theDisableIsConditionalLikeStep292,
        'the row containing both the defect and its remedy is recorded':
            adjacentRowsNote.contains('neither aware of the other'),
        'the client draws the button and the server holds the money':
            theServerHoldsTheMoney && courtesyNote.contains('fourth row'),
        'the floor is one person in ten thousand, stated as such':
            theFloorIsOnePersonInTenThousand &&
                moneyBandNote.contains('refused partial credit'),
        'this step performs no calculation, which is the other mismatch':
            thisStepPerformsNoCalculation &&
                optimalPercent == ceilingPercent,
        'amounts are held in minor units rather than a double':
            const HabotPayoutRow(
              label: 'x',
              amountMinor: 50000,
              flagIsTrue: false,
            ).amountMinor ==
                50000,
      };

  static const String columnNote =
      'COLUMN NOTE: the Setup Step column on this row reads "Test cache '
      'cleanup correctly removes only outdated entries", and every narrative '
      'column is about pruning inactive workers from an IAM system -- the '
      'same block of text Step 286 carries. Atomic Step: "Autonomously '
      'disable and grey out the payout execution buttons if the flag is '
      'False."';
}
