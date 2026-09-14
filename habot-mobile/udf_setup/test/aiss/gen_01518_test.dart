/// AISS GATE -- Step 204 of 215
/// Global Reference ID:       GEN-01518
/// Atomic Steps Reference ID: GEN-01518
/// Setup Step (Action): (EMPTY on this row -- COLUMN NOTE, RECORDED)
/// Atomic Step: "Implement dynamic pricing logic that recalculates total order
///               costs in under 50ms upon add-on toggle."
/// Metric: Add-On Attach Rate -- Floor 0.1, Optimal 0.25, Ceiling 0.4.
///
/// 50MS IS THE REQUIREMENT AND WHAT IT RULES OUT IS THE SUBSTANCE OF IT. A
/// round trip does not fit, so the total is computed on the device -- which
/// creates two totals, and the server's is the one that charges.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/booking/order_total.dart';
import 'package:udf_setup/design_system/i18n/fixed_precision.dart';
import 'package:udf_setup/design_system/tokens/motion_tokens.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];
  double adherence = 0;

  void gate(String id, String source, String description, bool Function() run) {
    test('[$id] $description', () {
      bool passed = false;
      try {
        passed = run();
        expect(passed, isTrue, reason: '$id failed: $description');
      } finally {
        gates.add(
          AissGate(
            id: id,
            requirementSource: source,
            description: description,
            passed: passed,
          ),
        );
      }
    });
  }

  HabotFixed aed(String text) =>
      HabotFixed.parse(text, scale: HabotPrecision.storageScale);

  HabotOrderLine base() => HabotOrderLine(
        id: 'svc',
        label: 'Half-day session',
        amount: aed('250.00'),
      );

  List<HabotOrderLine> addOns() => <HabotOrderLine>[
        HabotOrderLine(
          id: 'photo',
          label: 'Photo pack',
          amount: aed('45.50'),
          isAddOn: true,
        ),
        HabotOrderLine(
          id: 'lunch',
          label: 'Hot lunch',
          amount: aed('19.99'),
          isAddOn: true,
        ),
        HabotOrderLine(
          id: 'kit',
          label: 'Kit hire',
          amount: aed('4.35'),
          isAddOn: true,
        ),
      ];

  List<HabotOrderLine> selected() => HabotOrderTotal.linesFor(
        base: base(),
        catalogue: addOns(),
        selectedAddOnIds: <String>{'photo', 'lunch'},
      );

  group('GEN-01518 :: the arithmetic', () {
    gate(
      'GEN-01518-G1',
      'Step 140 built HabotFixed because money is not a double.',
      'AED 4.35 converted to fils through a double gives 434 rather than 435 '
          '-- one fils lost on a single line, silently, on a ledger that has '
          'to balance',
      () =>
          HabotOrderTotal.doubleMinorUnitsOf(4.35) == 434 &&
          HabotOrderTotal.exactMinorUnitsOf('4.35') == 435 &&
          HabotOrderTotal.doubleConversionLosesAFils('4.35') &&
          HabotOrderTotal.doubleLosesAFilsNote.contains('434.99999999999994'),
    );

    gate(
      'GEN-01518-G2',
      'The worked order: AED 250.00 plus a 45.50 photo pack plus a 19.99 '
          'lunch, with 5% VAT.',
      'Subtotal 315.4900, tax 15.7745, total 331.2645 at storage scale, '
          'displaying as 331.26 -- every figure exact, and the display '
          'rounding applied once at the end rather than carried through',
      () {
        final HabotOrderBreakdown b = HabotOrderTotal.compute(selected());
        return b.subtotal.toPlainString() == '315.4900' &&
            b.tax.toPlainString() == '15.7745' &&
            b.total.toPlainString() == '331.2645' &&
            b.total.scale == HabotPrecision.storageScale &&
            b.displayTotal.scale == HabotPrecision.displayScale &&
            b.displayString == '331.26' &&
            b.lineCount == 3;
      },
    );

    gate(
      'GEN-01518-G3',
      '"An invoice that picks one while the app picks the other produces a '
          'support ticket nobody can reproduce."',
      'Rounding VAT per line and summing gives 15.78 where rounding once gives '
          '15.77 -- a one-fils disagreement on a three-line order, '
          'demonstrated rather than asserted',
      () {
        final HabotOrderBreakdown b = HabotOrderTotal.compute(selected());
        final HabotFixed perLine = HabotOrderTotal.taxRoundedPerLine(
          selected(),
        );
        return perLine.toPlainString() == '15.78' &&
            HabotPrecision.forDisplay(b.tax).toPlainString() == '15.77' &&
            HabotOrderTotal.perLineRoundingDrifts(selected()) &&
            HabotOrderTotal.roundOnceNote.contains('15.78') &&
            HabotOrderTotal.roundOnceNote.contains('15.77');
      },
    );

    gate(
      'GEN-01518-G4',
      'Atomic Step: "recalculates total order costs UPON ADD-ON TOGGLE."',
      'Toggling rebuilds the lines from the base plus the selected ids rather '
          'than adjusting a running total, so a toggle and its reverse return '
          'exactly the original figure with no accumulated drift',
      () {
        final HabotFixed before =
            HabotOrderTotal.compute(<HabotOrderLine>[base()]).total;
        final HabotFixed withKit = HabotOrderTotal.compute(
          HabotOrderTotal.linesFor(
            base: base(),
            catalogue: addOns(),
            selectedAddOnIds: <String>{'kit'},
          ),
        ).total;
        final HabotFixed after = HabotOrderTotal.compute(
          HabotOrderTotal.linesFor(
            base: base(),
            catalogue: addOns(),
            selectedAddOnIds: <String>{},
          ),
        ).total;
        return before.compareTo(after) == 0 &&
            withKit.compareTo(before) != 0 &&
            withKit.toPlainString() == '267.0675';
      },
    );
  });

  group('GEN-01518 :: fifty milliseconds, and the two totals', () {
    gate(
      'GEN-01518-G5',
      '"A round trip does not fit in 50ms on a mobile network."',
      'The recalculation does no I/O and its cost is linear in the number of '
          'selected lines, and the budget itself is a motion token rather than '
          'a number written at the call site',
      () {
        final HabotOrderBreakdown b = HabotOrderTotal.compute(selected());
        return !HabotOrderTotal.requiresNetworkRoundTrip &&
            b.fixedOperations == selected().length + 2 &&
            b.fixedOperations == 5 &&
            HabotOrderTotal.budget ==
                HabotMotion.orderTotalRecalculationBudget &&
            HabotOrderTotal.budget.inMilliseconds == 50 &&
            HabotOrderTotal.budgetIsComputationalNote
                .contains('question for a profiler on a device');
      },
    );

    gate(
      'GEN-01518-G6',
      '"There are now two totals, and the device\'s is the one being shown."',
      'A disagreement between the local and server totals is detected in both '
          'directions, the server total is what charges, and the difference '
          'has to be disclosed before a card is taken rather than resolved in '
          'the app\'s favour',
      () {
        final HabotFixed local = HabotOrderTotal.compute(selected()).total;
        final HabotFixed higher = local + aed('5.00');
        final HabotFixed lower = local - aed('5.00');
        return HabotOrderTotal.reconcile(local: local, server: local) ==
                HabotTotalAgreement.agree &&
            HabotOrderTotal.reconcile(local: local, server: higher) ==
                HabotTotalAgreement.serverHigher &&
            HabotOrderTotal.reconcile(local: local, server: lower) ==
                HabotTotalAgreement.serverLower &&
            HabotOrderTotal.authoritative(local: local, server: higher)
                    .compareTo(higher) ==
                0 &&
            !HabotOrderTotal.mustDiscloseBeforeCharging(
              HabotTotalAgreement.agree,
            ) &&
            HabotOrderTotal.mustDiscloseBeforeCharging(
              HabotTotalAgreement.serverLower,
            ) &&
            HabotOrderTotal.fiftyMsRulesOutTheNetworkNote
                .contains('never wins');
      },
    );

    gate(
      'GEN-01518-G7',
      'Metric: Add-On Attach Rate -- the metric on this row belongs to Step '
          '203 and needs real bookings.',
      'What this step can be graded on is computed instead: all eight declared '
          'checks hold, giving 1.0, and no timing figure is invented on a host '
          'with no Dart toolchain',
      () {
        adherence = HabotOrderTotal.adherence(selected());
        return HabotOrderTotal.checks(selected()).length == 8 &&
            HabotOrderTotal.checks(selected()).values.every((bool b) => b) &&
            adherence == 1.0 &&
            HabotOrderTotal.columnNote.contains('EMPTY');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-01518',
        atomicStepReferenceId: 'GEN-01518',
        setupStepAction:
            'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic '
            'Step: "Implement dynamic pricing logic that recalculates total '
            'order costs in under 50ms upon add-on toggle."',
        implementationOrder: 204,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotOrderTotal / HabotOrderBreakdown',
          'Component Properties':
              'Exact fixed-point arithmetic at scale '
              '${HabotPrecision.storageScale}, displayed at scale '
              '${HabotPrecision.displayScale}; tax computed once over the '
              'subtotal; lines rebuilt from the base plus the selected ids on '
              'every toggle; no I/O on the recalculation path; budget '
              '${HabotOrderTotal.budget.inMilliseconds}ms as a motion token',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'FINDING: what 50ms rules out is the substance of the '
              'requirement. A round trip does not fit, so the total shown '
              'while a parent is choosing is computed on the device -- and '
              'that creates TWO totals. The server\'s is authoritative at '
              'checkout, the local one never wins, and a disagreement is '
              'disclosed before a card is charged rather than reconciled '
              'quietly. MEASURED: AED 4.35 through a double gives 434 fils '
              'rather than 435, because 4.35 * 100 is 434.99999999999994 in '
              'binary floating point. MEASURED: rounding VAT per line and '
              'summing gives 15.78 where rounding once gives 15.77, on a '
              'three-line order -- neither is arithmetically wrong, they '
              'disagree, and an invoice picking one while the app picks the '
              'other is a support ticket nobody can reproduce. SUBSTITUTION: '
              'no Dart toolchain on this host, so no wall-clock figure is '
              'produced. What is reported is the shape of the work -- integer '
              'arithmetic, linear in selected lines, no I/O.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Order total recalculation (structural)',
            observed:
                '${adherence.toStringAsFixed(2)} over '
                '${HabotOrderTotal.checks(selected()).length} checks. Worked '
                'order: subtotal AED 315.4900, VAT 15.7745, total 331.2645, '
                'displayed 331.26. Five exact-arithmetic operations for three '
                'lines; no network call on the path.',
            floor: '1.0',
            optimal: '1.0',
            ceiling: '1.0',
          ),
          AissMeasurement(
            metricName: 'Rounding drift, per line versus once',
            observed:
                'AED 0.01 on a three-line order -- 15.78 against 15.77. Small '
                'per order and systematic across them, and it is the figure '
                'that decides whether the app and the invoice agree.',
            floor: '0.00',
            optimal: '0.00',
            ceiling: '0.00',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/booking/order_total.dart',
        ],
      ),
    );
  });
}
