/// AISS GATE -- Step 140 of 155
/// Global Reference ID:       GEN-00379
/// Atomic Steps Reference ID: GEN-00379
/// Setup Step (Action): "Define the End Document (ED) Anchor for Mobile
///                       Attribution"
/// Atomic Step: "Declare the Critical Data Element cac_aed_value with a
///               fixed-precision numeric data type."
/// Metric: Decimal Precision Accuracy -- Floor "2 decimals", Optimal
///         "4 decimals", Ceiling "6 decimals". Pass / Fail.
///
/// THE THREE NUMBERS ARE THREE DECISIONS, NOT A RANGE: what is shown, what is
/// stored, and the most anything may carry. Reading them as one range is the
/// mistake the row invites.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/i18n/fixed_precision.dart';

import 'aiss_reporter.dart';

void main() {
  final List<AissGate> gates = <AissGate>[];

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

  group('GEN-00379 :: the CDE the row declares', () {
    gate(
      'GEN-00379-G1',
      'Atomic Step: "Declare the Critical Data Element CAC_AED_VALUE with a '
          'FIXED-PRECISION numeric data type."',
      'The CDE is declared by name, with a description, an exact storage type '
          'on both sides of the wire, and a constructor that produces the '
          'value at its declared scale',
      () {
        final HabotFixed v = HabotPrecision.cacAedValue('45.1250');
        return HabotPrecision.cdeName == 'cac_aed_value' &&
            HabotPrecision.cdeDescription.contains('quotient') &&
            HabotPrecision.storageType == 'NUMERIC(18, 4)' &&
            HabotPrecision.warehouseType == 'NUMERIC' &&
            v.scale == HabotPrecision.storageScale &&
            v.units == 451250 &&
            v.toPlainString() == '45.1250';
      },
    );

    gate(
      'GEN-00379-G2',
      'Metric: Floor 2 decimals, Optimal 4, Ceiling 6. Three different '
          'things: what a person sees, what is stored, and the most anything '
          'may carry.',
      'The three are separately named, the storage scale is strictly greater '
          'than the display scale so a stored value is not pre-rounded, and '
          'nothing exceeds the ceiling',
      () =>
          HabotPrecision.displayScale == 2 &&
          HabotPrecision.storageScale == 4 &&
          HabotPrecision.ceiling == 6 &&
          HabotPrecision.storageScale > HabotPrecision.displayScale &&
          HabotPrecision.storageScale <= HabotPrecision.ceiling &&
          HabotPrecision.precisionAccuracy == 1.0 &&
          HabotPrecision.precisionChecks.length == 5,
    );

    gate(
      'GEN-00379-G3',
      'Rounding at storage time loses money: a cost-per-acquisition is a '
          'division, and rounding it to two places before summing ten thousand '
          'of them moves the total.',
      'A value stored at four places and shown at two keeps the digits it was '
          'given, and the difference between the two views is visible rather '
          'than lost',
      () {
        final HabotFixed stored = HabotPrecision.cacAedValue('45.1250');
        final HabotFixed shown = HabotPrecision.forDisplay(stored);
        return stored.toPlainString() == '45.1250' &&
            shown.toPlainString() == '45.13' &&
            shown.scale == HabotPrecision.displayScale &&
            stored.scale == HabotPrecision.storageScale &&
            HabotPrecision.isWithinPolicy(stored) &&
            HabotPrecision.threeNumbersNote.contains('three different '
                'decisions, not a range');
      },
    );
  });

  group('GEN-00379 :: fixed-precision, actually', () {
    gate(
      'GEN-00379-G4',
      '"Fixed-precision" rules out double. 0.1 + 0.2 is 0.30000000000000004 '
          'in binary floating point.',
      'Exact addition of the values that break a double is exact here, and the '
          'reason a double is not used is recorded rather than assumed',
      () {
        final HabotFixed a = HabotPrecision.cacAedValue('0.1000');
        final HabotFixed b = HabotPrecision.cacAedValue('0.2000');
        final HabotFixed expected = HabotPrecision.cacAedValue('0.3000');
        // The same sum in a double, for contrast.
        final bool doubleIsWrong = (0.1 + 0.2) != 0.3;
        return (a + b) == expected &&
            (a + b).toPlainString() == '0.3000' &&
            doubleIsWrong &&
            HabotPrecision.noDoubleNote.contains('0.30000000000000004');
      },
    );

    gate(
      'GEN-00379-G5',
      'The ceiling has to be enforced, or it is a comment. Two four-place '
          'values multiply to eight places, and eight places of a currency '
          'figure is longer, not more accurate.',
      'A scale beyond the ceiling is refused at construction and at parse, '
          'with an exception that says why rather than an assertion failure',
      () {
        bool refusedConstruction = false;
        bool refusedParse = false;
        try {
          HabotFixed(1, HabotPrecision.ceiling + 1);
        } on HabotPrecisionCeilingExceeded catch (e) {
          refusedConstruction = e.ceiling == HabotPrecision.ceiling &&
              e.toString().contains('false precision');
        }
        try {
          HabotFixed.parse('1.12345678', scale: 4);
        } on HabotPrecisionCeilingExceeded {
          refusedParse = true;
        }
        return refusedConstruction && refusedParse;
      },
    );

    gate(
      'GEN-00379-G6',
      'A parser for money that accepts "1e3" or "1,000" is a parser that is '
          'guessing.',
      'Only a plain decimal is accepted; exponents, group separators and '
          'currency symbols are refused with a FormatException rather than '
          'silently reinterpreted',
      () {
        int refused = 0;
        for (final String bad in <String>[
          '1e3',
          '1,000.00',
          'AED 45.00',
          '45.00.25',
          '',
          ' ',
        ]) {
          try {
            HabotFixed.parse(bad, scale: 4);
          } on FormatException {
            refused++;
          }
        }
        return refused == 6 &&
            HabotFixed.parse('45', scale: 4).toPlainString() == '45.0000' &&
            HabotFixed.parse('-45.5', scale: 4).toPlainString() == '-45.5000';
      },
    );

    gate(
      'GEN-00379-G7',
      'Rounding half away from zero is a decision, and it is the one a person '
          'reading money expects. Banker\'s rounding would turn 0.125 into '
          '0.12 and produce support tickets nobody can reproduce.',
      'The rule holds in both directions and on both signs, and it is stated '
          'in the code rather than inherited',
      () =>
          HabotPrecision.cacAedValue('0.1250')
                  .rescaled(2)
                  .toPlainString() ==
              '0.13' &&
          HabotPrecision.cacAedValue('0.1249')
                  .rescaled(2)
                  .toPlainString() ==
              '0.12' &&
          HabotPrecision.cacAedValue('-0.1250')
                  .rescaled(2)
                  .toPlainString() ==
              '-0.13' &&
          HabotPrecision.roundingNote.contains('half away from zero'),
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00379',
        atomicStepReferenceId: 'GEN-00379',
        setupStepAction:
            'Define the End Document (ED) Anchor for Mobile Attribution',
        implementationOrder: 140,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name': 'HabotFixed / HabotPrecision',
          'Component Properties':
              'CDE ${HabotPrecision.cdeName}; display '
              '${HabotPrecision.displayScale} decimals, storage '
              '${HabotPrecision.storageScale}, ceiling '
              '${HabotPrecision.ceiling}; stored as '
              '${HabotPrecision.storageType}, warehoused as '
              '${HabotPrecision.warehouseType}',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Zero-dependency row. The three metric boundaries are read as '
              'three decisions rather than as one range; the reasoning is in '
              'HabotPrecision.threeNumbersNote.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Decimal Precision Accuracy',
            observed:
                '${(HabotPrecision.precisionAccuracy * 100).toStringAsFixed(0)}'
                '% over ${HabotPrecision.precisionChecks.length} checks. '
                'Display ${HabotPrecision.displayScale} places meets the '
                'floor, storage ${HabotPrecision.storageScale} meets the '
                'optimal, and nothing exceeds the ceiling of '
                '${HabotPrecision.ceiling}.',
            floor: '2 decimals',
            optimal: '4 decimals',
            ceiling: '6 decimals',
          ),
          const AissMeasurement(
            metricName: 'Money held in a double',
            observed:
                '0 code paths. The type holds an integer of minor units and a '
                'declared scale. The gate demonstrates the failure it avoids '
                'by evaluating 0.1 + 0.2 != 0.3 in a real double alongside the '
                'exact addition.',
            floor: '0',
            optimal: '0',
            ceiling: '0',
            higherIsBetter: false,
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/i18n/fixed_precision.dart',
        ],
      ),
    );
  });
}
