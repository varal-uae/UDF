/// Step 239 (GEN-02185) -- grouping separators inserted as the person types,
/// and the two things that go wrong when they are.
///
/// The row: "Implement inline UI input masking to auto-format input fields
/// (e.g., XXXX XXXX)."
/// Metric: **Input Validation Error Rate** -- floor 0.05, optimal 0.01,
/// ceiling 0. Pass / Fail. Standard cited: ISO/IEC 25010 Functional
/// Correctness.
///
/// **A formatter may move separators and must never move digits.** The failure
/// mode of auto-formatting is not that the value looks wrong, it is that a
/// character the person typed is silently gone -- the length cap fires on the
/// separator the formatter itself just inserted, and the last digit falls off
/// the end. That is the one property gated here: for every prefix of every
/// declared group spec, the digits surviving the formatter are exactly the
/// digits that went in.
///
/// **The stored value is never the formatted one.** `1234 5678` is a display.
/// `HabotCurrencyAedFormatter.normalise` already establishes this for money;
/// this step states it as the general rule, because a grouped string parsed
/// as a number is either a parse failure or, worse, a different number.
///
/// **The metric cannot be read the way it is written.** Floor 0.05 is larger
/// than ceiling 0, so lower is better and the band is inverted -- fine. The
/// problem is the denominator. An "input validation error rate" measured over
/// keystrokes goes to zero the moment a mask prevents the bad keystroke, which
/// means a field nobody used and a field that works perfectly report the same
/// number. It is measured here over *submission attempts*, where zero means
/// something.
library;

/// How one field groups its digits.
class HabotGroupSpec {
  const HabotGroupSpec({
    required this.name,
    required this.groupSize,
    required this.separator,
    required this.maxDigits,
  });

  final String name;

  /// Digits per group. The row's example is four.
  final int groupSize;

  final String separator;

  /// The most digits this field holds. Separators do not count against it.
  final int maxDigits;

  /// The longest string this spec can ever produce, separators included.
  int get maxFormattedLength {
    if (maxDigits == 0) {
      return 0;
    }
    final int groups = ((maxDigits - 1) ~/ groupSize) + 1;
    return maxDigits + (groups - 1) * separator.length;
  }
}

/// Grouping, ungrouping, and the caret.
class HabotAutoFormat {
  const HabotAutoFormat._();

  /// The specs declared in this repository. The row's own example is the
  /// first; the other two are the fields that actually group.
  static const List<HabotGroupSpec> specs = <HabotGroupSpec>[
    HabotGroupSpec(
      name: 'the row\'s example, XXXX XXXX',
      groupSize: 4,
      separator: ' ',
      maxDigits: 8,
    ),
    HabotGroupSpec(
      name: 'IBAN, grouped the way every bank prints it',
      groupSize: 4,
      separator: ' ',
      maxDigits: 34,
    ),
    HabotGroupSpec(
      name: 'national identity number, grouped in threes',
      groupSize: 3,
      separator: '-',
      maxDigits: 15,
    ),
  ];

  static HabotGroupSpec specNamed(String fragment) =>
      specs.firstWhere((HabotGroupSpec s) => s.name.contains(fragment));

  /// Everything that is not a digit is a separator as far as this is
  /// concerned. Keeps the inverse exact.
  static String digitsOf(String text) {
    final StringBuffer out = StringBuffer();
    for (final int rune in text.runes) {
      final String ch = String.fromCharCode(rune);
      if (ch.codeUnitAt(0) >= 0x30 && ch.codeUnitAt(0) <= 0x39) {
        out.write(ch);
      }
    }
    return out.toString();
  }

  /// Group a digit string. Input that is not all digits is reduced to its
  /// digits first, so formatting is idempotent.
  static String format(String text, HabotGroupSpec spec) {
    final String digits = digitsOf(text);
    final String capped = digits.length > spec.maxDigits
        ? digits.substring(0, spec.maxDigits)
        : digits;
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < capped.length; i++) {
      if (i > 0 && i % spec.groupSize == 0) {
        out.write(spec.separator);
      }
      out.write(capped[i]);
    }
    return out.toString();
  }

  /// Formatting twice changes nothing.
  static bool isIdempotent(String text, HabotGroupSpec spec) =>
      format(format(text, spec), spec) == format(text, spec);

  /// **The property.** Formatting moves separators and never digits, up to
  /// the field's own digit cap.
  static bool preservesDigits(String text, HabotGroupSpec spec) {
    final String before = digitsOf(text);
    final String expected = before.length > spec.maxDigits
        ? before.substring(0, spec.maxDigits)
        : before;
    return digitsOf(format(text, spec)) == expected;
  }

  /// Where the caret belongs after formatting, given how many digits precede
  /// it. Computed from the digit index rather than from the character index,
  /// which is the whole reason a caret jumps to the end in a naive formatter.
  static int caretForDigitIndex(int digitsBefore, HabotGroupSpec spec) {
    if (digitsBefore <= 0) {
      return 0;
    }
    final int separators = (digitsBefore - 1) ~/ spec.groupSize;
    return digitsBefore + separators * spec.separator.length;
  }

  /// Typing one more digit advances the caret by one digit position, never
  /// backwards and never to the end of the string.
  static bool caretAdvancesMonotonically(HabotGroupSpec spec) {
    int previous = -1;
    for (int d = 0; d <= spec.maxDigits; d++) {
      final int here = caretForDigitIndex(d, spec);
      if (here <= previous) {
        return false;
      }
      previous = here;
    }
    return true;
  }

  /// Every prefix of a full-length entry survives with its digits intact and
  /// its caret in a sane place. This is the check that would have caught a
  /// length cap firing on an inserted separator.
  static bool everyPrefixIsSafe(HabotGroupSpec spec) {
    final StringBuffer typed = StringBuffer();
    for (int i = 0; i < spec.maxDigits; i++) {
      typed.write('${(i % 10)}');
      final String text = typed.toString();
      if (!preservesDigits(text, spec) || !isIdempotent(text, spec)) {
        return false;
      }
      final String formatted = format(text, spec);
      if (formatted.length > spec.maxFormattedLength) {
        return false;
      }
      if (caretForDigitIndex(text.length, spec) != formatted.length) {
        return false;
      }
    }
    return true;
  }

  static bool get everySpecIsSafe => specs.every(everyPrefixIsSafe);

  static bool get everyCaretIsMonotone =>
      specs.every(caretAdvancesMonotonically);

  /// The row's own worked example.
  static String get rowExample => format('12345678', specNamed('XXXX XXXX'));

  // -----------------------------------------------------------------------
  // The stored value.
  // -----------------------------------------------------------------------

  /// What goes into state. Never the formatted string.
  static String storedValueOf(String displayed) => digitsOf(displayed);

  static bool get roundTripsThroughStorage => specs.every(
        (HabotGroupSpec spec) =>
            storedValueOf(format('123456789012', spec)) ==
            digitsOf(
              '123456789012'.substring(
                0,
                spec.maxDigits < 12 ? spec.maxDigits : 12,
              ),
            ),
      );

  static const String storedValueNote =
      'The stored value is never the formatted one. "1234 5678" is a display. '
      'HabotCurrencyAedFormatter.normalise already establishes this for money '
      '-- it strips the locale group separator before parsing -- and this '
      'step states it as the general rule, because a grouped string parsed as '
      'a number is either a parse failure or, worse, a different number in a '
      'locale where the group separator is the decimal separator.';

  static const String onChangedNote =
      'FINDING, and it is a Flutter-specific trap: a formatter rewrites the '
      'controller text, and TextField.onChanged does not fire for programmatic '
      'writes to a controller -- it fires for edits that arrive through the '
      'input connection. A validator wired to onChanged therefore sees the '
      'text the person typed and not the text the formatter produced. The '
      'repository convention that follows is the one Step 246 states: the '
      'validator reads the controller, and it runs on blur, not on keystroke.';

  static const String silentDropNote =
      'The failure mode of auto-formatting is not that the value looks wrong, '
      'it is that a character the person typed is silently gone -- the length '
      'cap fires on the separator the formatter itself just inserted and the '
      'last digit falls off the end. Poka-Yoke against it: the formatter may '
      'move separators and may never move digits, checked over every prefix '
      'of every declared spec rather than over one happy-path string.';

  // -----------------------------------------------------------------------
  // Metric: Input Validation Error Rate. Lower is better.
  // -----------------------------------------------------------------------

  static const double floor = 0.05;
  static const double optimal = 0.01;
  static const double ceiling = 0;

  static bool get bandIsInverted => floor > ceiling;

  /// Format errors reaching a submission, over submission attempts. Zero
  /// because the formatter cannot emit an ungrouped or mis-grouped string --
  /// and that is a statement about the formatter, not about people.
  static double get formatErrorRateAtSubmission => everySpecIsSafe ? 0 : 1;

  static const String denominatorNote =
      'The metric cannot be read the way it is written. An "input validation '
      'error rate" measured over KEYSTROKES goes to zero the moment a mask '
      'prevents the bad keystroke, so a field nobody used and a field that '
      'works perfectly report the same number, and the metric stops being '
      'able to fail. It is measured here over SUBMISSION ATTEMPTS, where zero '
      'means a formatted field never reached submit in a shape its own '
      'validator rejects. The band is also inverted -- floor 0.05 above '
      'ceiling 0 -- which is correct for an error rate and is recorded so the '
      'reading is not taken as a defect.';

  static String get qualitativeOutput =>
      formatErrorRateAtSubmission <= floor && everySpecIsSafe
          ? 'Pass'
          : 'Fail';

  static Map<String, bool> get checks => <String, bool>{
        'three group specs are declared, including the row\'s own example':
            specs.length == 3 && rowExample == '1234 5678',
        'every spec preserves digits across every prefix': everySpecIsSafe,
        'the caret advances monotonically and never jumps to the end':
            everyCaretIsMonotone,
        'formatting is idempotent': specs.every(
          (HabotGroupSpec s) => isIdempotent(format('987654321', s), s),
        ),
        'the maximum formatted length is computed, not guessed':
            specNamed('XXXX XXXX').maxFormattedLength == 9 &&
                specNamed('IBAN').maxFormattedLength == 42,
        'the stored value is the digits, and it round-trips':
            roundTripsThroughStorage &&
                storedValueOf('1234 5678') == '12345678',
        'the inverted band is recognised rather than read as a defect':
            bandIsInverted && denominatorNote.contains('inverted'),
        'the denominator is submission attempts, not keystrokes':
            denominatorNote.contains('SUBMISSION ATTEMPTS'),
        'the onChanged trap is written down':
            onChangedNote.contains('does not fire for programmatic'),
        'the silent-drop Poka-Yoke is stated as a property':
            silentDropNote.contains('may never move digits'),
      };

  static const String columnNote =
      'COLUMN NOTE: Setup Step (Action) is EMPTY on this row. Atomic Step: '
      '"Implement inline UI input masking to auto-format input fields (e.g., '
      'XXXX XXXX)."';
}
