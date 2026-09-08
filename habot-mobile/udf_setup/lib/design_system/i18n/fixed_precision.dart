/// AISS Step 140 -- GEN-00379
/// Setup Step (Action): "Define the End Document (ED) Anchor for Mobile
///                       Attribution"
/// Atomic Step: "Declare the Critical Data Element cac_aed_value with a
///               fixed-precision numeric data type."
/// Metric: Decimal Precision Accuracy -- Floor "2 decimals", Optimal
///         "4 decimals", Ceiling "6 decimals". Pass / Fail.
///
/// **"FIXED-PRECISION" IS THE REQUIREMENT, AND IT RULES OUT `double`.**
/// The row does not say "numeric", it says fixed-precision, and the reason is
/// that binary floating point cannot represent most decimal fractions. 0.1 +
/// 0.2 is 0.30000000000000004; a cost-per-acquisition summed over ten thousand
/// installs in a double is wrong by an amount nobody can predict and every
/// reconciliation will find. [HabotFixed] therefore holds an INTEGER of minor
/// units plus a declared scale. There is no double anywhere on the path.
///
/// THE THREE NUMBERS IN THE METRIC ARE THREE DIFFERENT THINGS, and reading
/// them as one range is the mistake this row invites:
///
///   Floor 2   -- what a person is shown. Money is displayed to two places.
///   Optimal 4 -- what is STORED. A customer-acquisition cost is a division;
///                rounding it to two places at storage time and then summing
///                ten thousand of them moves the total by real money.
///   Ceiling 6 -- the most any value in this system may carry. Beyond it the
///                extra digits are noise from an upstream division and
///                pretending otherwise is false precision.
///
/// So display precision and storage precision are separate, named, and
/// enforced separately. A single "decimals" constant would have collapsed
/// three decisions into one and silently picked the wrong one for two of them.
///
/// ROUNDING IS HALF AWAY FROM ZERO, AND SAID SO. Not banker's rounding: for a
/// figure a person will read as money, "round half up" is what they expect,
/// and a system that quietly turns 0.125 into 0.12 produces support tickets
/// nobody can reproduce. The choice is stated here rather than inherited from
/// whatever a library happened to do.
library;

/// Thrown when a value would carry more precision than the system permits.
class HabotPrecisionCeilingExceeded implements Exception {
  const HabotPrecisionCeilingExceeded(this.requested, this.ceiling);

  final int requested;
  final int ceiling;

  @override
  String toString() =>
      'A fixed-point value was asked for $requested decimal places, but the '
      'system ceiling is $ceiling (GEN-00379). Digits beyond the ceiling are '
      'noise from an upstream division, and carrying them is false precision '
      'that makes two systems disagree about a value they both computed '
      'correctly.';
}

/// An exact decimal: an integer of minor units and the scale it is held at.
///
/// Deliberately not a `double`. See the header.
class HabotFixed implements Comparable<HabotFixed> {
  const HabotFixed._(this.units, this.scale);

  /// Build a value at [scale] decimal places.
  factory HabotFixed(int units, int scale) {
    if (scale < 0 || scale > HabotPrecision.ceiling) {
      throw HabotPrecisionCeilingExceeded(scale, HabotPrecision.ceiling);
    }
    return HabotFixed._(units, scale);
  }

  /// Parse a decimal string exactly. Refuses anything that is not a plain
  /// decimal -- no exponents, no separators, no currency symbols. A parser
  /// that accepted "1e3" or "1,000" here would be guessing at money.
  factory HabotFixed.parse(String text, {required int scale}) {
    final String t = text.trim();
    if (!RegExp(r'^-?\d+(\.\d+)?$').hasMatch(t)) {
      throw FormatException('Not a plain decimal value', text);
    }
    final bool negative = t.startsWith('-');
    final String body = negative ? t.substring(1) : t;
    final int dot = body.indexOf('.');
    final String whole = dot == -1 ? body : body.substring(0, dot);
    final String frac = dot == -1 ? '' : body.substring(dot + 1);
    if (frac.length > HabotPrecision.ceiling) {
      throw HabotPrecisionCeilingExceeded(
        frac.length,
        HabotPrecision.ceiling,
      );
    }
    final String padded = frac.padRight(scale, '0');
    final String kept = padded.substring(0, scale);
    final int units = int.parse('$whole$kept');
    // Anything past the requested scale rounds rather than truncates.
    final bool roundsUp = padded.length > scale &&
        int.parse(padded[scale]) >= 5;
    final int rounded = roundsUp ? units + 1 : units;
    return HabotFixed(negative ? -rounded : rounded, scale);
  }

  /// The value in minor units at [scale].
  final int units;

  /// How many decimal places [units] is scaled by.
  final int scale;

  static int _pow10(int n) {
    int out = 1;
    for (int i = 0; i < n; i++) {
      out *= 10;
    }
    return out;
  }

  bool get isNegative => units < 0;
  bool get isZero => units == 0;

  /// Re-scale, rounding half away from zero. See the header for why not
  /// banker's rounding.
  HabotFixed rescaled(int toScale) {
    if (toScale == scale) {
      return this;
    }
    if (toScale > scale) {
      return HabotFixed(units * _pow10(toScale - scale), toScale);
    }
    final int divisor = _pow10(scale - toScale);
    final int magnitude = units.abs();
    int q = magnitude ~/ divisor;
    if ((magnitude % divisor) * 2 >= divisor) {
      q += 1;
    }
    return HabotFixed(isNegative ? -q : q, toScale);
  }

  HabotFixed operator +(HabotFixed other) {
    final int s = scale > other.scale ? scale : other.scale;
    return HabotFixed(rescaled(s).units + other.rescaled(s).units, s);
  }

  HabotFixed operator -(HabotFixed other) {
    final int s = scale > other.scale ? scale : other.scale;
    return HabotFixed(rescaled(s).units - other.rescaled(s).units, s);
  }

  /// Exact multiplication. The product's natural scale is the sum of the two
  /// scales, which is why [HabotPrecision.ceiling] exists: two four-place
  /// values multiply to eight places, and eight places of a currency figure
  /// is not more accurate, only longer.
  HabotFixed multipliedBy(HabotFixed other, {required int resultScale}) {
    final int naturalScale = scale + other.scale;
    final int product = units * other.units;
    // Rescale from the natural scale WITHOUT constructing an intermediate
    // that would breach the ceiling.
    if (resultScale >= naturalScale) {
      return HabotFixed(
        product * _pow10(resultScale - naturalScale),
        resultScale,
      );
    }
    final int divisor = _pow10(naturalScale - resultScale);
    final int magnitude = product.abs();
    int q = magnitude ~/ divisor;
    if ((magnitude % divisor) * 2 >= divisor) {
      q += 1;
    }
    return HabotFixed(product.isNegative ? -q : q, resultScale);
  }

  /// The plain decimal string, at this value's own scale. Locale formatting
  /// is Step 139's job, not this type's -- a value type that formats itself
  /// for a locale is a value type that has to be told the locale.
  String toPlainString() {
    final bool negative = isNegative;
    final String raw = units.abs().toString().padLeft(scale + 1, '0');
    if (scale == 0) {
      return negative ? '-$raw' : raw;
    }
    final String whole = raw.substring(0, raw.length - scale);
    final String frac = raw.substring(raw.length - scale);
    return '${negative ? '-' : ''}$whole.$frac';
  }

  @override
  int compareTo(HabotFixed other) {
    final int s = scale > other.scale ? scale : other.scale;
    return rescaled(s).units.compareTo(other.rescaled(s).units);
  }

  @override
  bool operator ==(Object other) =>
      other is HabotFixed && compareTo(other) == 0;

  @override
  int get hashCode => rescaled(HabotPrecision.ceiling).units.hashCode;

  @override
  String toString() => '${toPlainString()} (scale $scale)';
}

/// The declared Critical Data Element and the precision policy around it.
class HabotPrecision {
  const HabotPrecision._();

  /// The CDE this row names.
  static const String cdeName = 'cac_aed_value';

  /// Its description, for the data dictionary.
  static const String cdeDescription =
      'Customer acquisition cost, in AED, for one attributed mobile install. '
      'A quotient, therefore not exactly representable at display precision, '
      'therefore stored with more places than it is shown with.';

  /// The row's floor: what a person is shown.
  static const int displayScale = 2;

  /// The row's optimal: what is stored.
  static const int storageScale = 4;

  /// The row's ceiling: the most any value in this system may carry.
  static const int ceiling = 6;

  /// The declared type of the CDE.
  static const String storageType = 'NUMERIC(18, 4)';

  /// The BigQuery column type the warehouse half of this uses. NUMERIC, not
  /// FLOAT64: the same argument as in Dart, on the other side of the wire.
  static const String warehouseType = 'NUMERIC';

  /// Build a value of this CDE from an exact decimal string.
  static HabotFixed cacAedValue(String decimalText) =>
      HabotFixed.parse(decimalText, scale: storageScale);

  /// What a screen shows for it.
  static HabotFixed forDisplay(HabotFixed value) =>
      value.rescaled(displayScale);

  /// Whether a value is within the declared precision policy.
  static bool isWithinPolicy(HabotFixed value) =>
      value.scale >= displayScale && value.scale <= ceiling;

  /// The row's metric, computed over the policy's own three levels rather
  /// than asserted: display precision meets the floor, storage precision
  /// meets the optimal, and neither exceeds the ceiling.
  static Map<String, bool> get precisionChecks => <String, bool>{
        'display precision meets the floor (2 decimals)':
            displayScale >= 2,
        'storage precision meets the optimal (4 decimals)':
            storageScale == 4,
        'storage carries more places than display, so a stored value is not '
                'pre-rounded':
            storageScale > displayScale,
        'nothing exceeds the ceiling (6 decimals)':
            storageScale <= ceiling && displayScale <= ceiling,
        'the stored type is exact rather than floating point':
            storageType.startsWith('NUMERIC') &&
                warehouseType == 'NUMERIC',
      };

  static double get precisionAccuracy {
    final Iterable<bool> r = precisionChecks.values;
    return r.where((bool b) => b).length / r.length;
  }

  static const String noDoubleNote =
      'The row says FIXED-precision, not "numeric". Binary floating point '
      'cannot represent most decimal fractions: 0.1 + 0.2 is '
      '0.30000000000000004. A cost-per-acquisition summed over ten thousand '
      'installs in a double is wrong by an amount nobody can predict and '
      'every reconciliation will find. HabotFixed holds an integer of minor '
      'units and a declared scale; there is no double anywhere on this path.';

  static const String threeNumbersNote =
      'Floor 2, optimal 4 and ceiling 6 are three different decisions, not a '
      'range. Two is what a person is shown. Four is what is stored, because '
      'a customer-acquisition cost is a division and rounding it before '
      'summing ten thousand of them moves the total by real money. Six is the '
      'most any value may carry, beyond which the digits are noise from an '
      'upstream division. A single "decimals" constant would have collapsed '
      'the three and silently picked the wrong one for two of them.';

  static const String roundingNote =
      'Rounding is half away from zero, stated here rather than inherited. '
      'Not banker\'s rounding: for a figure a person reads as money, "round '
      'half up" is what they expect, and a system that quietly turns 0.125 '
      'into 0.12 produces support tickets nobody can reproduce.';
}
