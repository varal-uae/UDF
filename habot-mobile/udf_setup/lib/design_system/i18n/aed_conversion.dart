/// AISS Step 141 -- GEN-00412
/// Setup Step (Action): "Deconstruct Mobile Conversion Events into Smallest
///                       Reusable Byts"
/// Atomic Step: "Define the atomic function calculate_aed_conversion()."
/// Metric: Mathematical Calculation Accuracy -- Floor 1.0, Optimal 1.0,
///         Ceiling "N/A (100% target)". Pass / Fail.
///
/// AN ACCURACY METRIC OF 1.0 MEANS THE FUNCTION IS EITHER RIGHT OR BROKEN.
/// There is no tolerance to hide in, so the function is built on the Step 140
/// exact type and checked against a golden table computed by hand.
///
/// **THE FUNCTION RETURNS ITS INPUTS, NOT JUST ITS ANSWER.** A converted
/// figure without the rate that produced it cannot be audited, cannot be
/// recomputed, and cannot be explained to a finance team six months later
/// asking why two reports disagree. [HabotConversionResult] carries the
/// amount, the rate, the rate's scale and its source alongside the result.
/// This is the difference between a number and a record.
///
/// A ZERO RATE IS REFUSED RATHER THAN APPLIED. Multiplying by a missing rate
/// gives zero, which is a valid-looking currency amount, which is how an
/// entire day of attribution silently reports as free. [HabotRateUnavailable]
/// makes the failure loud at the point it happens rather than quiet at the
/// point someone reads the dashboard.
///
/// ROUND-TRIP IS NOT CLAIMED. Converting to AED and back with the inverse
/// rate does not return the original value, and no amount of care makes it:
/// the forward rounding has already discarded information. The function does
/// not pretend otherwise, and [HabotAedConversion.roundTripResidual] reports
/// the residual so a reconciliation can account for it instead of chasing it.
library;

import 'fixed_precision.dart';

/// Thrown when a conversion is attempted with no usable rate.
class HabotRateUnavailable implements Exception {
  const HabotRateUnavailable(this.sourceCurrency, this.reason);

  final String sourceCurrency;
  final String reason;

  @override
  String toString() =>
      'No usable AED conversion rate for $sourceCurrency: $reason. The '
      'conversion is refused rather than applied, because multiplying by a '
      'missing rate produces zero -- a valid-looking currency amount, and how '
      'a whole day of attribution silently reports as free.';
}

/// One exchange rate, with everything needed to audit a figure derived
/// from it.
class HabotConversionRate {
  const HabotConversionRate({
    required this.sourceCurrency,
    required this.rate,
    required this.source,
    required this.asOf,
  });

  /// ISO code of the currency being converted FROM.
  final String sourceCurrency;

  /// AED per one unit of [sourceCurrency], held exactly.
  final HabotFixed rate;

  /// Where the rate came from. A rate with no provenance is a guess.
  final String source;

  final DateTime asOf;

  bool get isUsable => !rate.isZero && !rate.isNegative;
}

/// The result of one conversion, and the evidence for it.
class HabotConversionResult {
  const HabotConversionResult({
    required this.sourceAmount,
    required this.rate,
    required this.aedValue,
  });

  final HabotFixed sourceAmount;
  final HabotConversionRate rate;

  /// The value of the CDE `cac_aed_value`, at its declared storage scale.
  final HabotFixed aedValue;

  /// The record a warehouse row is built from. Every field needed to
  /// recompute the answer is present, which is what makes the figure
  /// auditable rather than merely stored.
  Map<String, Object?> toRow() => <String, Object?>{
        'source_currency': rate.sourceCurrency,
        'source_amount': sourceAmount.toPlainString(),
        'rate': rate.rate.toPlainString(),
        'rate_scale': rate.rate.scale,
        'rate_source': rate.source,
        'rate_as_of': rate.asOf.toUtc().toIso8601String(),
        HabotPrecision.cdeName: aedValue.toPlainString(),
        'value_scale': aedValue.scale,
      };
}

/// The atomic conversion function this row names.
class HabotAedConversion {
  const HabotAedConversion._();

  /// Exchange rates need more places than money does: a rate quoted to four
  /// places moves a large amount by more than the rounding it was meant to
  /// avoid. Six is the Step 140 ceiling, and rates are exactly the case that
  /// ceiling was set for.
  static const int rateScale = HabotPrecision.ceiling;

  /// The scale the result is produced at -- the CDE's storage scale, not its
  /// display scale. Rounding to display precision here would bake a
  /// presentation decision into stored data.
  static const int resultScale = HabotPrecision.storageScale;

  /// `calculate_aed_conversion()`.
  static HabotConversionResult calculate({
    required HabotFixed sourceAmount,
    required HabotConversionRate rate,
  }) {
    if (!rate.isUsable) {
      throw HabotRateUnavailable(
        rate.sourceCurrency,
        rate.rate.isZero ? 'the rate is zero' : 'the rate is negative',
      );
    }
    if (rate.rate.scale > HabotPrecision.ceiling) {
      throw HabotPrecisionCeilingExceeded(
        rate.rate.scale,
        HabotPrecision.ceiling,
      );
    }
    return HabotConversionResult(
      sourceAmount: sourceAmount,
      rate: rate,
      aedValue: sourceAmount.multipliedBy(
        rate.rate,
        resultScale: resultScale,
      ),
    );
  }

  /// Build a rate from a plain decimal string.
  static HabotConversionRate rateOf(
    String currency,
    String decimalRate, {
    required String source,
    required DateTime asOf,
  }) =>
      HabotConversionRate(
        sourceCurrency: currency,
        rate: HabotFixed.parse(decimalRate, scale: rateScale),
        source: source,
        asOf: asOf,
      );

  /// What converting to AED and back leaves behind. Reported, not hidden:
  /// the forward rounding has already discarded information, and a
  /// reconciliation that knows the residual can account for it instead of
  /// chasing it.
  static HabotFixed roundTripResidual({
    required HabotFixed sourceAmount,
    required HabotConversionRate rate,
    required HabotConversionRate inverseRate,
  }) {
    final HabotConversionResult forward =
        calculate(sourceAmount: sourceAmount, rate: rate);
    final HabotFixed back = forward.aedValue.multipliedBy(
      inverseRate.rate,
      resultScale: resultScale,
    );
    return back - sourceAmount;
  }

  // ---- the row's metric ---------------------------------------------------

  /// Golden cases, computed by hand. Each is
  /// (source amount, rate, expected AED value) as plain decimal strings.
  static const List<List<String>> goldens = <List<String>>[
    <String>['100.0000', '3.672500', '367.2500'],
    <String>['-50.0000', '3.672500', '-183.6250'],
    <String>['12.3456', '0.272500', '3.3642'],
    <String>['0.0001', '3.672500', '0.0004'],
    <String>['0.0000', '3.672500', '0.0000'],
    <String>['1.0000', '1.000000', '1.0000'],
    <String>['999999.9999', '1.000000', '999999.9999'],
    <String>['7.7777', '0.123456', '0.9602'],
  ];

  static HabotFixed _apply(String amount, String rate) => calculate(
        sourceAmount: HabotFixed.parse(
          amount,
          scale: HabotPrecision.storageScale,
        ),
        rate: HabotConversionRate(
          sourceCurrency: 'TST',
          rate: HabotFixed.parse(rate, scale: rateScale),
          source: 'golden table',
          asOf: DateTime.utc(2026),
        ),
      ).aedValue;

  /// The row's metric: the share of golden cases the function reproduces
  /// exactly. Floor, optimal and target are all 1.0.
  static double get calculationAccuracy {
    if (goldens.isEmpty) {
      return 0;
    }
    final int ok = goldens
        .where((List<String> g) => _apply(g[0], g[1]).toPlainString() == g[2])
        .length;
    return ok / goldens.length;
  }

  /// Golden cases that did not reproduce. Empty is the requirement.
  static List<String> get mismatches => goldens
      .where((List<String> g) => _apply(g[0], g[1]).toPlainString() != g[2])
      .map((List<String> g) =>
          '${g[0]} x ${g[1]}: expected ${g[2]}, got '
          '${_apply(g[0], g[1]).toPlainString()}')
      .toList();

  static const double floor = 1.0;
  static const double optimal = 1.0;

  static const String evidenceNote =
      'The function returns its inputs alongside its answer. A converted '
      'figure without the rate that produced it cannot be audited, cannot be '
      'recomputed, and cannot be explained to a finance team six months later '
      'asking why two reports disagree. toRow() carries the amount, the rate, '
      'the rate scale, the rate source and its as-of time, which is the '
      'difference between a number and a record.';

  static const String zeroRateNote =
      'A zero or negative rate is refused rather than applied. Multiplying by '
      'a missing rate gives zero -- a valid-looking currency amount, and '
      'exactly how a whole day of attribution silently reports as free. The '
      'failure is made loud where it happens rather than quiet where someone '
      'reads a dashboard.';

  static const String roundTripNote =
      'Converting to AED and back with the inverse rate does not return the '
      'original value, and no amount of care makes it: the forward rounding '
      'has already discarded information. That is not claimed. '
      'roundTripResidual() reports what is left over so a reconciliation can '
      'account for it rather than chase it.';
}
