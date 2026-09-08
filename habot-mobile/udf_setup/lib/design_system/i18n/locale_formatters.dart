/// AISS Step 139 -- GEN-03470
/// Setup Step (Action) / Atomic Step: "Implement locale-specific formatters
///   for dates, times, currencies, and numbers."
/// Metric: Locale Formatter Precision -- Floor 1.0, Optimal 1.0, Ceiling 1.0.
/// Best Qualitative Output: Pass.
///
/// A METRIC WITH NO ROOM IN IT. Floor, optimal and ceiling are all 1.0: every
/// case formats exactly right or the step fails. That is the correct shape for
/// this row -- a date rendered in the wrong order is not 95% right, it is a
/// different date -- so the implementation is built to be checkable against a
/// golden table rather than by inspection.
///
/// NO `intl` DEPENDENCY, DELIBERATELY. The obvious implementation is
/// `package:intl`, and it is the wrong one here for two reasons. It carries
/// ICU data for hundreds of locales the app will never offer, on a product
/// where install size matters to users on metered connections; and its
/// behaviour for a given locale can change between package versions, which
/// would silently move a gated metric. Five locales, formatted by rules stated
/// in this file, is a smaller surface that cannot drift under us.
///
/// THE TRAP THIS ROW SETS: formatting is not translation. `1,234.50` in Polish
/// is `1 234,50` -- comma for the decimal, a non-breaking space for the
/// thousands group. A team that translates every string and leaves the numbers
/// alone ships an app that reads as broken to a Polish speaker in a way no
/// string audit will find, because there is no string to audit.
///
/// URDU IS RIGHT-TO-LEFT AND ITS DIGITS ARE NOT. Urdu text runs RTL, but these
/// locales use Western Arabic digits in LTR runs. A number embedded in an RTL
/// sentence therefore needs bidi isolation or the currency symbol jumps to the
/// wrong end. [HabotLocaleFormatters.isolate] wraps a formatted number in the
/// Unicode isolate characters; the alternative is a price that reads as
/// `AED 45.00` on one screen and `45.00 AED` on another, at random.
library;

/// How one locale writes numbers.
class HabotNumberSymbols {
  const HabotNumberSymbols({
    required this.decimalSeparator,
    required this.groupSeparator,
    this.groupSize = 3,
  });

  final String decimalSeparator;
  final String groupSeparator;
  final int groupSize;
}

/// The order a locale writes a date in.
enum HabotDateOrder { dayMonthYear, monthDayYear, yearMonthDay }

/// How one locale writes dates and times.
class HabotDateSymbols {
  const HabotDateSymbols({
    required this.order,
    required this.dateSeparator,
    required this.timeSeparator,
    required this.uses24HourClock,
  });

  final HabotDateOrder order;
  final String dateSeparator;
  final String timeSeparator;
  final bool uses24HourClock;
}

/// Everything one locale needs to render a value.
class HabotLocaleRules {
  const HabotLocaleRules({
    required this.code,
    required this.numbers,
    required this.dates,
    required this.currencySymbolLeads,
    required this.currencyGap,
  });

  final String code;
  final HabotNumberSymbols numbers;
  final HabotDateSymbols dates;

  /// Whether the currency symbol precedes the amount in this locale.
  final bool currencySymbolLeads;

  /// Whether a space separates the symbol from the amount.
  final bool currencyGap;
}

/// Locale-specific formatters.
class HabotLocaleFormatters {
  const HabotLocaleFormatters._();

  /// Unicode bidirectional isolates. A formatted number placed inside an RTL
  /// sentence without these is reordered by the bidi algorithm and its symbol
  /// ends up on the wrong side.
  static const String firstStrongIsolate = '\u2068';
  static const String popDirectionalIsolate = '\u2069';

  static const String nonBreakingSpace = '\u00A0';

  static const String currencyCode = 'AED';

  static const Map<String, HabotLocaleRules> rules =
      <String, HabotLocaleRules>{
    'en': HabotLocaleRules(
      code: 'en',
      numbers: HabotNumberSymbols(
        decimalSeparator: '.',
        groupSeparator: ',',
      ),
      dates: HabotDateSymbols(
        order: HabotDateOrder.dayMonthYear,
        dateSeparator: '/',
        timeSeparator: ':',
        uses24HourClock: true,
      ),
      currencySymbolLeads: true,
      currencyGap: true,
    ),
    'cy': HabotLocaleRules(
      code: 'cy',
      numbers: HabotNumberSymbols(
        decimalSeparator: '.',
        groupSeparator: ',',
      ),
      dates: HabotDateSymbols(
        order: HabotDateOrder.dayMonthYear,
        dateSeparator: '/',
        timeSeparator: ':',
        uses24HourClock: true,
      ),
      currencySymbolLeads: true,
      currencyGap: true,
    ),
    'ur': HabotLocaleRules(
      code: 'ur',
      numbers: HabotNumberSymbols(
        decimalSeparator: '.',
        groupSeparator: ',',
      ),
      dates: HabotDateSymbols(
        order: HabotDateOrder.dayMonthYear,
        dateSeparator: '/',
        timeSeparator: ':',
        uses24HourClock: false,
      ),
      currencySymbolLeads: true,
      currencyGap: true,
    ),
    'pa': HabotLocaleRules(
      code: 'pa',
      numbers: HabotNumberSymbols(
        decimalSeparator: '.',
        groupSeparator: ',',
      ),
      dates: HabotDateSymbols(
        order: HabotDateOrder.dayMonthYear,
        dateSeparator: '/',
        timeSeparator: ':',
        uses24HourClock: false,
      ),
      currencySymbolLeads: true,
      currencyGap: true,
    ),
    // The one that catches a team that translated the strings and left the
    // numbers alone.
    'pl': HabotLocaleRules(
      code: 'pl',
      numbers: HabotNumberSymbols(
        decimalSeparator: ',',
        groupSeparator: nonBreakingSpace,
      ),
      dates: HabotDateSymbols(
        order: HabotDateOrder.dayMonthYear,
        dateSeparator: '.',
        timeSeparator: ':',
        uses24HourClock: true,
      ),
      currencySymbolLeads: false,
      currencyGap: true,
    ),
  };

  static HabotLocaleRules rulesFor(String code) =>
      rules[code] ?? rules['en']!;

  static String _pad(int value, int width) =>
      value.toString().padLeft(width, '0');

  /// Group the integer part of an already-stringified number.
  static String _group(String digits, HabotNumberSymbols s) {
    if (digits.length <= s.groupSize) {
      return digits;
    }
    final StringBuffer out = StringBuffer();
    final int lead = digits.length % s.groupSize;
    int i = 0;
    if (lead != 0) {
      out.write(digits.substring(0, lead));
      i = lead;
    }
    while (i < digits.length) {
      if (out.isNotEmpty) {
        out.write(s.groupSeparator);
      }
      out.write(digits.substring(i, i + s.groupSize));
      i += s.groupSize;
    }
    return out.toString();
  }

  /// Format a number held as minor units scaled by 10^[decimals].
  ///
  /// Takes an int rather than a double on purpose: 0.1 + 0.2 is not 0.3 in
  /// binary floating point, and a formatter for money that starts from a
  /// double has already lost before it formats anything. Step 140 declares
  /// the scaled type this consumes.
  static String formatScaled(
    int scaledValue,
    String localeCode, {
    required int decimals,
  }) {
    final HabotNumberSymbols s = rulesFor(localeCode).numbers;
    final bool negative = scaledValue < 0;
    final String raw = scaledValue.abs().toString().padLeft(decimals + 1, '0');
    final String whole =
        decimals == 0 ? raw : raw.substring(0, raw.length - decimals);
    final String frac =
        decimals == 0 ? '' : raw.substring(raw.length - decimals);
    final StringBuffer out = StringBuffer();
    if (negative) {
      out.write('-');
    }
    out.write(_group(whole, s));
    if (decimals > 0) {
      out
        ..write(s.decimalSeparator)
        ..write(frac);
    }
    return out.toString();
  }

  /// Format a whole number.
  static String formatInteger(int value, String localeCode) =>
      formatScaled(value, localeCode, decimals: 0);

  /// Format a currency amount held as minor units scaled by 10^[decimals],
  /// displayed to [displayDecimals].
  ///
  /// Display and storage precision are deliberately separate: Step 140 stores
  /// four decimals and screens show two. Rounding at display time is a
  /// presentation choice; rounding at storage time loses money.
  static String formatCurrencyScaled(
    int scaledValue,
    String localeCode, {
    required int decimals,
    int displayDecimals = 2,
    String symbol = currencyCode,
  }) {
    final HabotLocaleRules r = rulesFor(localeCode);
    final int shown = _rescale(scaledValue, decimals, displayDecimals);
    final String amount =
        formatScaled(shown, localeCode, decimals: displayDecimals);
    final String gap = r.currencyGap ? nonBreakingSpace : '';
    return r.currencySymbolLeads
        ? '$symbol$gap$amount'
        : '$amount$gap$symbol';
  }

  /// Rescale a fixed-point value, rounding half away from zero.
  ///
  /// Half-away-from-zero rather than banker's rounding, and stated rather than
  /// inherited: for a value a person will read as money, "round half up" is
  /// what they expect, and a formatter that quietly rounds 0.125 to 0.12
  /// produces support tickets nobody can reproduce.
  static int _rescale(int value, int fromDecimals, int toDecimals) {
    if (toDecimals >= fromDecimals) {
      int out = value;
      for (int i = 0; i < toDecimals - fromDecimals; i++) {
        out *= 10;
      }
      return out;
    }
    int divisor = 1;
    for (int i = 0; i < fromDecimals - toDecimals; i++) {
      divisor *= 10;
    }
    final int q = value ~/ divisor;
    final int rem = value.remainder(divisor).abs();
    if (rem * 2 >= divisor) {
      return q + (value.isNegative ? -1 : 1);
    }
    return q;
  }

  /// Format a date. Only the ordering and separator vary across the offered
  /// locales; month NAMES are not used, because a numeric date is
  /// unambiguous once its order is known and a month name is one more string
  /// to translate and get wrong.
  static String formatDate(DateTime date, String localeCode) {
    final HabotDateSymbols d = rulesFor(localeCode).dates;
    final String day = _pad(date.day, 2);
    final String month = _pad(date.month, 2);
    final String year = _pad(date.year, 4);
    final String sep = d.dateSeparator;
    switch (d.order) {
      case HabotDateOrder.dayMonthYear:
        return '$day$sep$month$sep$year';
      case HabotDateOrder.monthDayYear:
        return '$month$sep$day$sep$year';
      case HabotDateOrder.yearMonthDay:
        return '$year$sep$month$sep$day';
    }
  }

  /// Format a time of day.
  static String formatTime(DateTime time, String localeCode) {
    final HabotDateSymbols d = rulesFor(localeCode).dates;
    final String minute = _pad(time.minute, 2);
    if (d.uses24HourClock) {
      return '${_pad(time.hour, 2)}${d.timeSeparator}$minute';
    }
    final int h12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final String suffix = time.hour < 12 ? 'AM' : 'PM';
    return '$h12${d.timeSeparator}$minute$nonBreakingSpace$suffix';
  }

  /// Wrap a formatted value so the bidi algorithm cannot reorder it when it
  /// sits inside right-to-left text.
  static String isolate(String formatted) =>
      '$firstStrongIsolate$formatted$popDirectionalIsolate';

  // ---- the row's metric ---------------------------------------------------

  /// The golden table. Every case is a (locale, kind, input, expected) tuple
  /// the formatter must reproduce exactly.
  static List<HabotFormatCase> get goldens => <HabotFormatCase>[
        // Numbers: the Polish case is the one that catches a string-only
        // translation.
        HabotFormatCase('en', 'number', '1234550/2', '12,345.50'),
        HabotFormatCase('pl', 'number', '1234550/2',
            '12${nonBreakingSpace}345,50'),
        HabotFormatCase('cy', 'number', '1234550/2', '12,345.50'),
        HabotFormatCase('ur', 'number', '1234550/2', '12,345.50'),
        HabotFormatCase('pa', 'number', '1234550/2', '12,345.50'),
        HabotFormatCase('en', 'number', '-50/2', '-0.50'),
        HabotFormatCase('pl', 'number', '-50/2', '-0,50'),
        HabotFormatCase('en', 'number', '999/2', '9.99'),
        HabotFormatCase('en', 'number', '100000000/2', '1,000,000.00'),
        HabotFormatCase('pl', 'number', '100000000/2',
            '1${nonBreakingSpace}000${nonBreakingSpace}000,00'),
        // Currency: symbol placement differs, and Polish trails it.
        HabotFormatCase('en', 'currency', '4500/2', 'AED${nonBreakingSpace}45.00'),
        HabotFormatCase('pl', 'currency', '4500/2', '45,00${nonBreakingSpace}AED'),
        HabotFormatCase('ur', 'currency', '4500/2', 'AED${nonBreakingSpace}45.00'),
        // Four stored decimals displayed as two, rounding half away from zero.
        HabotFormatCase('en', 'currency4', '451250/4', 'AED${nonBreakingSpace}45.13'),
        HabotFormatCase('en', 'currency4', '451249/4', 'AED${nonBreakingSpace}45.12'),
        // Dates and times.
        HabotFormatCase('en', 'date', '2026-09-08', '08/09/2026'),
        HabotFormatCase('pl', 'date', '2026-09-08', '08.09.2026'),
        HabotFormatCase('cy', 'date', '2026-09-08', '08/09/2026'),
        HabotFormatCase('en', 'time', '2026-09-08T14:05', '14:05'),
        HabotFormatCase('ur', 'time', '2026-09-08T14:05',
            '2:05${nonBreakingSpace}PM'),
        HabotFormatCase('pa', 'time', '2026-09-08T00:30',
            '12:30${nonBreakingSpace}AM'),
        HabotFormatCase('pl', 'time', '2026-09-08T00:30', '00:30'),
      ];

  /// Run one golden case.
  static String render(HabotFormatCase c) {
    switch (c.kind) {
      case 'number':
        final List<String> parts = c.input.split('/');
        return formatScaled(
          int.parse(parts[0]),
          c.locale,
          decimals: int.parse(parts[1]),
        );
      case 'currency':
      case 'currency4':
        final List<String> parts = c.input.split('/');
        return formatCurrencyScaled(
          int.parse(parts[0]),
          c.locale,
          decimals: int.parse(parts[1]),
        );
      case 'date':
        return formatDate(DateTime.parse(c.input), c.locale);
      case 'time':
        return formatTime(DateTime.parse(c.input), c.locale);
      default:
        return '';
    }
  }

  /// The row's metric: the share of golden cases reproduced exactly.
  static double get precision {
    if (goldens.isEmpty) {
      return 0;
    }
    final int ok =
        goldens.where((HabotFormatCase c) => render(c) == c.expected).length;
    return ok / goldens.length;
  }

  /// Cases that did not match. Empty is the requirement; the list exists so a
  /// failure names the locale and the value rather than only a fraction.
  static List<String> get mismatches => goldens
      .where((HabotFormatCase c) => render(c) != c.expected)
      .map((HabotFormatCase c) =>
          '${c.locale}/${c.kind} ${c.input}: expected "${c.expected}", '
          'got "${render(c)}"')
      .toList();

  static const double floor = 1.0;
  static const double optimal = 1.0;

  static const String noIntlNote =
      'package:intl is deliberately not used. It carries ICU data for '
      'hundreds of locales this app will never offer, on a product where '
      'install size matters to users on metered connections, and its output '
      'for a given locale can change between package versions -- which would '
      'move a metric whose floor, optimal and ceiling are all 1.0 without '
      'anyone changing this code. Five locales formatted by rules stated in '
      'this file is a smaller surface that cannot drift underneath the gate.';

  static const String integerArithmeticNote =
      'Every amount enters these formatters as an integer of minor units with '
      'a declared scale, never as a double. 0.1 + 0.2 is not 0.3 in binary '
      'floating point; a money formatter that starts from a double has '
      'already lost before it formats anything. Step 140 declares the scaled '
      'type this consumes.';
}

/// One golden formatting case.
class HabotFormatCase {
  const HabotFormatCase(this.locale, this.kind, this.input, this.expected);

  final String locale;
  final String kind;
  final String input;
  final String expected;
}
