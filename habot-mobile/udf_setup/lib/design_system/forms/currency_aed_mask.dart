/// AISS Step 142 -- GEN-00621
/// Setup Step (Action): "Implement Strict Mobile Input Masking (Poka-Yoke)
///                       for Data Entry"
/// Atomic Step: "Create CurrencyAEDMaskFormatter restricting input strictly to
///               numeric decimal formats."
/// Metric: Decimal Format Mask Match -- Floor "Numeric", Optimal "Numeric",
///         Ceiling "Numeric". Pass / Fail.
///
/// **THE TRAP: "STRICTLY NUMERIC DECIMAL" IS AMBIGUOUS ACROSS LOCALES, AND
/// THE OBVIOUS IMPLEMENTATION LOCKS OUT THE USERS THIS BATCH IS FOR.**
/// A formatter that accepts digits and a full stop is "strictly numeric
/// decimal" in English. A Polish keyboard's decimal key produces a COMMA
/// (Step 139: `pl` uses `,` for the decimal separator). So the obvious
/// implementation makes it impossible for a Polish speaker to type an amount
/// at all -- in the same release whose stated objective is "equitable access
/// for non-English speakers". The field would simply refuse their keypresses,
/// with no error, and look broken.
///
/// [HabotCurrencyAedFormatter] therefore lets the ACTIVE LOCALE decide which
/// character is the decimal point, and normalises it to `.` in the stored
/// value. Every other separator character is treated as a thousands separator
/// the user typed out of habit and dropped -- so `1,000.50` in English stores
/// as `1000.50` rather than as `1.000`, which is the same input read as a
/// value a thousand times smaller. What the user types follows the language
/// the app is already showing them; what the app stores is unambiguous.
///
/// IT REUSES THE STEP 44 MASK RATHER THAN DECLARING A SECOND ONE.
/// `HabotMaskKind.decimal` already exists and already means "digits and a
/// single decimal separator". A second definition of "decimal" would be the
/// drift these steps exist to prevent, so this formatter constrains that one
/// rather than replacing it: it adds the currency-specific rules the generic
/// mask cannot know -- at most [HabotPrecision.displayScale] places after the
/// separator, at most one separator, never a leading one, and no group
/// separators (a user typing `1,000` in English means one thousand, and
/// storing `1.000` because the comma was silently dropped would be wrong by a
/// factor of a thousand).
///
/// THE ".5" CASE IS ALLOWED WHILE TYPING AND NORMALISED ON COMMIT. Refusing a
/// leading separator would stop someone typing `.50`, which is a normal way to
/// enter fifty fils. It is accepted as input and normalised to `0.50` when the
/// field is read, rather than being rejected under the user's finger.
library;

import 'package:flutter/services.dart';

import '../i18n/fixed_precision.dart';
import '../i18n/locale_formatters.dart';
import 'input_mask.dart';

/// Restricts a text field to a currency amount, in the user's own locale.
class HabotCurrencyAedFormatter extends TextInputFormatter {
  HabotCurrencyAedFormatter({
    String Function()? activeLocale,
    this.maxIntegerDigits = defaultMaxIntegerDigits,
  }) : _activeLocale = activeLocale ?? (() => 'en');

  final String Function() _activeLocale;

  /// A currency field on this product holds an amount, not an account
  /// balance. Twelve integer digits is a trillion AED; beyond it the entry is
  /// a mis-key, not a value.
  final int maxIntegerDigits;

  static const int defaultMaxIntegerDigits = 12;

  /// Places after the separator a person may type. The DISPLAY scale, not the
  /// storage scale: a human enters money to two places, and Step 140's four
  /// stored places come from computation, not from typing.
  static int get maxDecimalDigits => HabotPrecision.displayScale;

  /// The mask this formatter constrains. Not a second definition of
  /// "decimal" -- the Step 44 one.
  static const HabotMaskKind baseMask = HabotMaskKind.decimal;

  /// The separator the active locale's keyboard produces.
  String get localeSeparator =>
      HabotLocaleFormatters.rulesFor(_activeLocale()).numbers.decimalSeparator;

  /// Every character that is a decimal separator in SOME offered locale. One
  /// of these is the decimal point in the active locale; the rest are group
  /// separators the user typed out of habit, and are dropped.
  static Set<String> get separatorCharacters => HabotLocaleFormatters.rules
      .values
      .map((HabotLocaleRules r) => r.numbers.decimalSeparator)
      .toSet();

  /// Characters that are never part of an amount but are commonly typed
  /// inside one: the thousands separators of the offered locales.
  static Set<String> get groupCharacters => HabotLocaleFormatters.rules
      .values
      .map((HabotLocaleRules r) => r.numbers.groupSeparator)
      .toSet();

  /// Filter a raw string down to what this field allows.
  ///
  /// Returns null when the candidate must be REJECTED outright rather than
  /// trimmed -- which is only the case for something no amount of trimming
  /// rescues.
  String? sanitise(String candidate) {
    final String separator = localeSeparator;
    final StringBuffer out = StringBuffer();
    bool seenSeparator = false;
    int integerDigits = 0;
    int decimalDigits = 0;

    for (int i = 0; i < candidate.length; i++) {
      final String ch = candidate[i];
      if (_isDigit(ch)) {
        if (seenSeparator) {
          if (decimalDigits >= maxDecimalDigits) {
            continue;
          }
          decimalDigits++;
        } else {
          if (integerDigits >= maxIntegerDigits) {
            continue;
          }
          integerDigits++;
        }
        out.write(ch);
        continue;
      }
      if (ch == separator) {
        if (seenSeparator) {
          // A SECOND decimal separator is dropped, not accepted: "45.00.25"
          // is a mis-key, and the first reading is the one to keep.
          continue;
        }
        seenSeparator = true;
        out.write('.');
        continue;
      }
      if (separatorCharacters.contains(ch) || groupCharacters.contains(ch)) {
        // A separator character that is NOT this locale's decimal point is a
        // group separator the user typed out of habit. Dropping it is the
        // only safe reading: keeping "1,000.50" as "1.000" would be wrong by
        // a factor of a thousand, and wrong quietly.
        continue;
      }
      // Letters, symbols, currency signs and spaces are dropped. There is no
      // input in this field for which they are meaningful.
    }
    return out.toString();
  }

  static bool _isDigit(String ch) {
    final int c = ch.codeUnitAt(0);
    return c >= 0x30 && c <= 0x39;
  }

  /// Normalise a field's text into a value the rest of the app can parse.
  /// `.50` becomes `0.50`; `12.` becomes `12`; an empty field becomes null.
  static String? normalise(String text) {
    if (text.isEmpty) {
      return null;
    }
    String t = text;
    if (t.startsWith('.')) {
      t = '0$t';
    }
    if (t.endsWith('.')) {
      t = t.substring(0, t.length - 1);
    }
    return t.isEmpty ? null : t;
  }

  /// The exact value a normalised field holds, at the CDE's storage scale.
  static HabotFixed? valueOf(String text) {
    final String? n = normalise(text);
    if (n == null) {
      return null;
    }
    return HabotFixed.parse(n, scale: HabotPrecision.storageScale);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String? cleaned = sanitise(newValue.text);
    if (cleaned == null) {
      return oldValue;
    }
    if (cleaned == newValue.text) {
      return newValue;
    }
    // Keep the caret where the user's edit left it, adjusted by whatever the
    // filter removed before it. A formatter that resets the caret to the end
    // makes correcting a typo in the middle of an amount impossible.
    final int removedBeforeCaret = newValue.selection.baseOffset < 0
        ? 0
        : _removedBefore(newValue.text, newValue.selection.baseOffset);
    final int offset =
        (newValue.selection.baseOffset - removedBeforeCaret).clamp(
      0,
      cleaned.length,
    );
    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
  }

  /// How many characters before the caret the filter removed. Computed by
  /// filtering the prefix rather than by walking the two strings in step,
  /// which is both exact and impossible to get subtly wrong.
  int _removedBefore(String raw, int caret) {
    final int upto = caret.clamp(0, raw.length);
    final String keptPrefix = sanitise(raw.substring(0, upto)) ?? '';
    return upto - keptPrefix.length;
  }

  // ---- the row's metric ---------------------------------------------------

  /// Cases the mask must handle, as (locale, typed, expected stored text).
  /// The Polish rows are the ones the obvious implementation fails.
  static const List<List<String>> maskCases = <List<String>>[
    <String>['en', '45.00', '45.00'],
    <String>['en', '45', '45'],
    <String>['en', '.5', '.5'],
    <String>['en', '45.999', '45.99'],
    <String>['en', '1,000.50', '1000.50'],
    <String>['en', 'AED 45.00', '45.00'],
    <String>['en', '45.00.25', '45.00'],
    <String>['en', 'abc', ''],
    <String>['en', '-45.00', '45.00'],
    <String>['pl', '45,00', '45.00'],
    <String>['pl', '1 234,56', '1234.56'],
    <String>['ur', '45.00', '45.00'],
    <String>['cy', '12.34', '12.34'],
  ];

  /// The row's metric: the share of cases the mask reduces exactly as stated.
  static double get maskMatchRate {
    if (maskCases.isEmpty) {
      return 0;
    }
    int ok = 0;
    for (final List<String> c in maskCases) {
      final HabotCurrencyAedFormatter f =
          HabotCurrencyAedFormatter(activeLocale: () => c[0]);
      if (f.sanitise(c[1]) == c[2]) {
        ok++;
      }
    }
    return ok / maskCases.length;
  }

  static List<String> get maskMismatches {
    final List<String> out = <String>[];
    for (final List<String> c in maskCases) {
      final HabotCurrencyAedFormatter f =
          HabotCurrencyAedFormatter(activeLocale: () => c[0]);
      final String? got = f.sanitise(c[1]);
      if (got != c[2]) {
        out.add('${c[0]} "${c[1]}": expected "${c[2]}", got "$got"');
      }
    }
    return out;
  }

  static const String localeSeparatorNote =
      'A formatter that accepts only "." is "strictly numeric decimal" in '
      'English and unusable in Polish, whose decimal key produces a comma. '
      'Shipping that in the same release whose objective is "equitable access '
      'for non-English speakers" would mean the amount field silently refused '
      'their keypresses. The ACTIVE LOCALE decides which character is the '
      'decimal point; it is normalised to "." in the stored value. The app '
      'language is that locale (Step 143), so the separator the field accepts '
      'is always the one the app is already using to display amounts -- '
      'rather than being guessed from the keyboard, which would mean deciding '
      'what someone meant by a comma.';

  static const String groupSeparatorNote =
      'A SECOND separator is dropped rather than accepted. Someone typing '
      '"1,000.50" in English means one thousand; keeping the comma and '
      'parsing "1.000" would be wrong by a factor of a thousand, and would be '
      'wrong quietly.';

  static const String reusesExistingMaskNote =
      'HabotMaskKind.decimal (Step 44) already means "digits and a single '
      'decimal separator". This formatter constrains that definition rather '
      'than declaring a second one, adding only what the generic mask cannot '
      'know: the currency display scale, the single-separator rule, and the '
      'locale separator set.';
}
