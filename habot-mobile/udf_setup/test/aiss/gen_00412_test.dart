/// AISS GATE -- Step 141 of 155
/// Global Reference ID:       GEN-00412
/// Atomic Steps Reference ID: GEN-00412
/// Setup Step (Action): "Deconstruct Mobile Conversion Events into Smallest
///                       Reusable Byts"
/// Atomic Step: "Define the atomic function calculate_aed_conversion()."
/// Metric: Mathematical Calculation Accuracy -- Floor 1.0, Optimal 1.0,
///         Ceiling "N/A (100% target)". Pass / Fail.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:udf_setup/design_system/i18n/aed_conversion.dart';
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

  HabotConversionRate rate(String value) => HabotAedConversion.rateOf(
        'USD',
        value,
        source: 'gate fixture',
        asOf: DateTime.utc(2026, 9, 8),
      );

  group('GEN-00412 :: the function is right', () {
    gate(
      'GEN-00412-G1',
      'Metric: Mathematical Calculation Accuracy, floor and optimal both 1.0. '
          'There is no tolerance to hide in.',
      'Every golden case reproduces exactly, including a negative amount, a '
          'value smaller than the result scale, an identity rate and a rate '
          'carried at the full six-place ceiling',
      () =>
          HabotAedConversion.calculationAccuracy == 1.0 &&
          HabotAedConversion.calculationAccuracy >= HabotAedConversion.floor &&
          HabotAedConversion.mismatches.isEmpty &&
          HabotAedConversion.goldens.length >= 8,
    );

    gate(
      'GEN-00412-G2',
      'An exchange rate quoted to four places moves a large amount by more '
          'than the rounding it was meant to avoid.',
      'The rate is carried at the Step 140 ceiling and the result at the CDE '
          'storage scale -- not the display scale, which would bake a '
          'presentation decision into stored data',
      () =>
          HabotAedConversion.rateScale == HabotPrecision.ceiling &&
          HabotAedConversion.rateScale == 6 &&
          HabotAedConversion.resultScale == HabotPrecision.storageScale &&
          HabotAedConversion.resultScale == 4 &&
          HabotAedConversion.resultScale > HabotPrecision.displayScale,
    );

    gate(
      'GEN-00412-G3',
      'Rounding on the way out of a multiplication is where a conversion '
          'function usually goes wrong, because the product carries more '
          'places than either input.',
      'A product whose natural scale is ten rounds to four half away from '
          'zero, in both directions and on both signs',
      () {
        final HabotFixed up = HabotAedConversion.calculate(
          sourceAmount: HabotFixed.parse('0.0001', scale: 4),
          rate: rate('3.672500'),
        ).aedValue;
        final HabotFixed down = HabotAedConversion.calculate(
          sourceAmount: HabotFixed.parse('12.3456', scale: 4),
          rate: rate('0.272500'),
        ).aedValue;
        final HabotFixed negative = HabotAedConversion.calculate(
          sourceAmount: HabotFixed.parse('-50.0000', scale: 4),
          rate: rate('3.672500'),
        ).aedValue;
        return up.toPlainString() == '0.0004' &&
            down.toPlainString() == '3.3642' &&
            negative.toPlainString() == '-183.6250' &&
            negative.isNegative;
      },
    );
  });

  group('GEN-00412 :: the function is a record, not a number', () {
    gate(
      'GEN-00412-G4',
      'A converted figure without the rate that produced it cannot be '
          'audited, recomputed, or explained to a finance team six months '
          'later asking why two reports disagree.',
      'The result carries the amount, the rate, its scale, its source and its '
          'as-of time, and the warehouse row is built from exactly those '
          'fields under the CDE own name',
      () {
        final HabotConversionResult r = HabotAedConversion.calculate(
          sourceAmount: HabotFixed.parse('100.0000', scale: 4),
          rate: rate('3.672500'),
        );
        final Map<String, Object?> row = r.toRow();
        return row['source_currency'] == 'USD' &&
            row['source_amount'] == '100.0000' &&
            row['rate'] == '3.672500' &&
            row['rate_scale'] == HabotAedConversion.rateScale &&
            row['rate_source'] == 'gate fixture' &&
            row[HabotPrecision.cdeName] == '367.2500' &&
            row['value_scale'] == HabotAedConversion.resultScale &&
            (row['rate_as_of']! as String).startsWith('2026-09-08') &&
            HabotAedConversion.evidenceNote.contains(
              'the difference between a number and a record',
            );
      },
    );

    gate(
      'GEN-00412-G5',
      'Multiplying by a missing rate gives zero -- a valid-looking currency '
          'amount, and how a whole day of attribution silently reports as '
          'free.',
      'A zero rate and a negative rate are both refused with an exception that '
          'names the currency and the reason, rather than being applied',
      () {
        bool zeroRefused = false;
        bool negativeRefused = false;
        try {
          HabotAedConversion.calculate(
            sourceAmount: HabotFixed.parse('100.0000', scale: 4),
            rate: rate('0.000000'),
          );
        } on HabotRateUnavailable catch (e) {
          zeroRefused = e.reason.contains('zero') &&
              e.toString().contains('silently reports as free');
        }
        try {
          HabotAedConversion.calculate(
            sourceAmount: HabotFixed.parse('100.0000', scale: 4),
            rate: rate('-1.000000'),
          );
        } on HabotRateUnavailable catch (e) {
          negativeRefused = e.reason.contains('negative');
        }
        return zeroRefused && negativeRefused;
      },
    );

    gate(
      'GEN-00412-G6',
      'Round-tripping a converted value does NOT reliably return the '
          'original, and a function that claimed otherwise would send a '
          'reconciliation team chasing a discrepancy that is arithmetic '
          'rather than error.',
      'The residual is computed and reported: zero on a small amount, and '
          'genuinely non-zero on a large one -- so the function neither claims '
          'exactness nor exaggerates the error',
      () {
        final HabotFixed small = HabotAedConversion.roundTripResidual(
          sourceAmount: HabotFixed.parse('12.3456', scale: 4),
          rate: rate('3.672500'),
          inverseRate: rate('0.272294'),
        );
        final HabotFixed large = HabotAedConversion.roundTripResidual(
          sourceAmount: HabotFixed.parse('9999.9999', scale: 4),
          rate: rate('3.672500'),
          inverseRate: rate('0.272294'),
        );
        return small.scale == HabotAedConversion.resultScale &&
            small.isZero &&
            !large.isZero &&
            large.isNegative &&
            large.units.abs() < 1000 &&
            HabotAedConversion.roundTripNote.contains('That is not claimed');
      },
    );
  });

  tearDownAll(() {
    AissReporter.record(
      AissEvidence(
        globalReferenceId: 'GEN-00412',
        atomicStepReferenceId: 'GEN-00412',
        setupStepAction:
            'Deconstruct Mobile Conversion Events into Smallest Reusable Byts',
        implementationOrder: 141,
        assignedTeamMember: 'Fredrick',
        dataCollected: <String, String>{
          'Component Name':
              'HabotAedConversion / HabotConversionRate / '
              'HabotConversionResult',
          'Component Properties':
              'rate scale ${HabotAedConversion.rateScale}, result scale '
              '${HabotAedConversion.resultScale}, '
              '${HabotAedConversion.goldens.length} golden cases; a zero or '
              'negative rate is refused rather than applied',
          'Completion Status': 'Derived from gate outcomes',
          'Data Quality Note':
              'Zero-dependency row. Built on the Step 140 exact type; there is '
              'no double on the path.',
        },
        measurements: <AissMeasurement>[
          AissMeasurement(
            metricName: 'Mathematical Calculation Accuracy',
            observed:
                '${HabotAedConversion.calculationAccuracy.toStringAsFixed(2)} '
                'over ${HabotAedConversion.goldens.length} hand-computed '
                'cases, including a negative amount, a value smaller than the '
                'result scale, an identity rate and a six-place rate.',
            floor: '1.0',
            optimal: '1.0',
            ceiling: 'N/A (100% target)',
          ),
          const AissMeasurement(
            metricName: 'Round-trip residual',
            observed:
                'Computed and reported rather than claimed to be zero. A small '
                'amount happens to round-trip exactly; 9,999.9999 does not, '
                'because the forward rounding has already discarded '
                'information. roundTripResidual() gives a reconciliation the '
                'figure so it can account for the difference instead of '
                'chasing it.',
            floor: 'reported',
            optimal: 'reported',
            ceiling: 'reported',
          ),
        ],
        gates: gates,
        artefacts: const <String>[
          'lib/design_system/i18n/aed_conversion.dart',
        ],
      ),
    );
  });
}
