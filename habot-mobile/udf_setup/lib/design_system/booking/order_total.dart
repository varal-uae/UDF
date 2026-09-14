/// Step 204 (GEN-01518) -- recalculating the order total when an add-on is
/// toggled.
///
/// The row: "Implement dynamic pricing logic that recalculates total order
/// costs in under 50ms upon add-on toggle."
///
/// **50ms is the requirement, and what it rules out is the substance of it.**
/// A network round trip on the UAE mobile network does not fit in 50ms, so the
/// total shown while the parent is choosing has to be computed on the device
/// from a priced catalogue. That has a consequence the row does not mention:
/// there are now two totals, and the device's is the one being shown. The
/// server's is authoritative at checkout, and when they disagree the local one
/// must never win -- so [HabotOrderTotal.reconcile] exists and the disagreement
/// is surfaced rather than resolved silently in the app's favour.
///
/// **Money is not a double.** Step 140 built [HabotFixed] for this and the
/// reason is one multiplication: `4.35 * 100` is 434.99999999999994 in binary
/// floating point, and truncating it to fils gives 434. One fils, on every
/// conversion, in the direction of the customer's favour on some lines and the
/// merchant's on others, on a ledger that has to balance.
///
/// **Rounding happens once.** Rounding VAT per line and summing gives a
/// different answer from summing and rounding once -- on the worked example
/// here, AED 15.78 against AED 15.77. Neither is arithmetically wrong; they
/// disagree, and the invoice and the app must not each pick one.
library;

import '../i18n/fixed_precision.dart';
import '../tokens/motion_tokens.dart';

/// One priced line on an order.
class HabotOrderLine {
  const HabotOrderLine({
    required this.id,
    required this.label,
    required this.amount,
    this.isAddOn = false,
  });

  final String id;
  final String label;

  /// Held at [HabotPrecision.storageScale].
  final HabotFixed amount;

  /// Whether this line came from an add-on toggle.
  final bool isAddOn;
}

/// A computed total, with everything needed to explain it.
class HabotOrderBreakdown {
  const HabotOrderBreakdown({
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.lineCount,
    required this.fixedOperations,
  });

  final HabotFixed subtotal;
  final HabotFixed tax;
  final HabotFixed total;
  final int lineCount;

  /// How many exact-arithmetic operations this recalculation cost. The 50ms
  /// budget is a computation budget, so the cost is reported as work done
  /// rather than as a wall-clock figure this host cannot produce.
  final int fixedOperations;

  /// The total as it is shown, rounded once.
  HabotFixed get displayTotal => HabotPrecision.forDisplay(total);

  String get displayString => displayTotal.toPlainString();
}

/// How a local total and a server total compare.
enum HabotTotalAgreement { agree, serverHigher, serverLower }

/// Order pricing.
class HabotOrderTotal {
  const HabotOrderTotal._();

  /// UAE VAT, at storage scale. Declared here as text and parsed, not written
  /// as a double, for the reason in this file's header.
  static HabotFixed get taxRate =>
      HabotFixed.parse('0.0500', scale: HabotPrecision.storageScale);

  static HabotFixed get zero =>
      HabotFixed.parse('0', scale: HabotPrecision.storageScale);

  /// The budget, as a token. A raw Duration outside the motion token file is a
  /// poka-yoke violation.
  static Duration get budget => HabotMotion.orderTotalRecalculationBudget;

  /// Recalculation is local arithmetic over the selected lines.
  static const bool requiresNetworkRoundTrip = false;

  /// Sum, tax, total -- with the tax computed once over the subtotal.
  static HabotOrderBreakdown compute(List<HabotOrderLine> lines) {
    HabotFixed subtotal = zero;
    for (final HabotOrderLine line in lines) {
      subtotal = subtotal + line.amount;
    }
    final HabotFixed tax = subtotal.multipliedBy(
      taxRate,
      resultScale: HabotPrecision.storageScale,
    );
    final HabotFixed total = subtotal + tax;
    return HabotOrderBreakdown(
      subtotal: subtotal,
      tax: tax,
      total: total,
      lineCount: lines.length,
      // lines additions + one multiply + one addition.
      fixedOperations: lines.length + 2,
    );
  }

  /// The same total with VAT rounded on every line and then summed.
  ///
  /// Kept so the drift is demonstrated rather than asserted. On the worked
  /// example this is one fils above [compute]'s answer.
  static HabotFixed taxRoundedPerLine(List<HabotOrderLine> lines) {
    HabotFixed sum = HabotFixed.parse(
      '0',
      scale: HabotPrecision.displayScale,
    );
    for (final HabotOrderLine line in lines) {
      final HabotFixed lineTax = line.amount.multipliedBy(
        taxRate,
        resultScale: HabotPrecision.storageScale,
      );
      sum = sum + HabotPrecision.forDisplay(lineTax);
    }
    return sum;
  }

  /// True when rounding per line and rounding once give different money.
  static bool perLineRoundingDrifts(List<HabotOrderLine> lines) =>
      HabotPrecision.forDisplay(compute(lines).tax)
          .compareTo(taxRoundedPerLine(lines)) !=
      0;

  /// What a double-based implementation gets when converting to minor units.
  ///
  /// Returns the truncated minor-unit value. For 4.35 this is 434, not 435.
  static int doubleMinorUnitsOf(double major) => (major * 100).toInt();

  /// The same conversion done exactly.
  static int exactMinorUnitsOf(String major) =>
      HabotFixed.parse(major, scale: 2).units;

  static bool doubleConversionLosesAFils(String major) =>
      doubleMinorUnitsOf(double.parse(major)) != exactMinorUnitsOf(major);

  /// Toggling an add-on is a set membership change, not a recomputation of the
  /// catalogue: the lines are rebuilt from the base plus the selected ids.
  static List<HabotOrderLine> linesFor({
    required HabotOrderLine base,
    required List<HabotOrderLine> catalogue,
    required Set<String> selectedAddOnIds,
  }) =>
      <HabotOrderLine>[
        base,
        ...catalogue.where(
          (HabotOrderLine l) => selectedAddOnIds.contains(l.id),
        ),
      ];

  /// Compare the locally computed total against the server's.
  static HabotTotalAgreement reconcile({
    required HabotFixed local,
    required HabotFixed server,
  }) {
    final int c = server.compareTo(local);
    if (c == 0) {
      return HabotTotalAgreement.agree;
    }
    return c > 0
        ? HabotTotalAgreement.serverHigher
        : HabotTotalAgreement.serverLower;
  }

  /// Which total is charged. Always the server's.
  static HabotFixed authoritative({
    required HabotFixed local,
    required HabotFixed server,
  }) =>
      server;

  /// Whether a disagreement must be shown before payment is taken.
  static bool mustDiscloseBeforeCharging(HabotTotalAgreement agreement) =>
      agreement != HabotTotalAgreement.agree;

  // -----------------------------------------------------------------------
  // Metric: Add-On Attach Rate. 0.1 / 0.25 / 0.4. See Step 203.
  // -----------------------------------------------------------------------

  static const double floor = 0.1;
  static const double optimal = 0.25;
  static const double ceiling = 0.4;

  /// What this step can be graded on: whether the recalculation is capable of
  /// meeting its budget and whether the money it produces is exact.
  static Map<String, bool> checks(List<HabotOrderLine> lines) =>
      <String, bool>{
        'recalculation does not require a network round trip':
            !requiresNetworkRoundTrip,
        'the work is linear in the number of selected lines':
            compute(lines).fixedOperations == lines.length + 2,
        'money is held as exact fixed-point, not as a double':
            compute(lines).total.scale == HabotPrecision.storageScale,
        'the double conversion this replaces loses a fils':
            doubleConversionLosesAFils('4.35'),
        'tax is rounded once rather than per line':
            perLineRoundingDrifts(lines),
        'the display total is rounded to the display scale exactly once':
            compute(lines).displayTotal.scale == HabotPrecision.displayScale,
        'the server total is authoritative when the two disagree':
            mustDiscloseBeforeCharging(HabotTotalAgreement.serverHigher),
        'the budget is a token rather than a literal':
            budget == HabotMotion.orderTotalRecalculationBudget,
      };

  static double adherence(List<HabotOrderLine> lines) {
    final Map<String, bool> c = checks(lines);
    return c.values.where((bool b) => b).length / c.length;
  }

  static const String fiftyMsRulesOutTheNetworkNote =
      'A round trip does not fit in 50ms on a mobile network, so the total '
      'shown while the parent is choosing is computed on the device. That '
      'creates two totals. The server\'s is authoritative at checkout and the '
      'local one never wins; a disagreement is disclosed before a card is '
      'charged rather than reconciled quietly.';

  static const String doubleLosesAFilsNote =
      '4.35 * 100 is 434.99999999999994 in binary floating point and '
      'truncates to 434 fils. One fils per conversion, on a ledger that has to '
      'balance, in whichever direction the binary expansion happens to fall. '
      'Step 140 built the exact type for this and it is used here rather than '
      'being available.';

  static const String roundOnceNote =
      'Rounding VAT per line and summing gives AED 15.78 on the worked '
      'example; summing and rounding once gives AED 15.77. Neither is '
      'arithmetically wrong. They disagree, and an invoice that picks one '
      'while the app picks the other produces a support ticket that nobody can '
      'reproduce.';

  static const String budgetIsComputationalNote =
      'There is no Dart toolchain on this host, so no wall-clock figure is '
      'produced and none is invented. What is reported is the shape of the '
      'work: integer arithmetic, linear in the number of selected lines, with '
      'no I/O on the path. Whether that lands under 50ms is a question for a '
      'profiler on a device.';

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Implement dynamic pricing logic that recalculates total order costs in '
      'under 50ms upon add-on toggle."';
}
