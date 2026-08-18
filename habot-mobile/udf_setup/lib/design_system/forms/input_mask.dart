/// AISS: CSIVW-001-A01 -- "Implement strict client-side Input Masking on all
/// template text area entry portals."
///
/// Substep 1: "Embed an alphanumeric keystroke filter inside the core text area
///             component."
/// Substep 2: "Configure strict regular expression rules to block unauthorized
///             character sets."
/// Substep 3: "Physically reject text pasted from clipboard arrays that exceeds
///             defined field memory caps."
///
/// Poka-Yoke: "The text area physically drops any pasted input that contains
/// non-ASCII formatting profiles."
///
/// Everything here is a [TextInputFormatter], which Flutter applies *before*
/// the value reaches the controller. That is the "physically" in the spec:
/// a rejected character never exists in application state, it is not merely
/// flagged afterwards.
library;

import 'package:flutter/services.dart';

/// The character classes a field may accept.
enum HabotMaskKind {
  /// Letters and digits only. The default for template text areas.
  alphanumeric,

  /// Alphanumeric plus the punctuation ordinary prose needs.
  text,

  /// Digits only. Cost and quantity fields.
  numeric,

  /// Digits and a single decimal separator.
  decimal,

  /// Digits, spaces and the separators a phone number uses.
  phone,

  /// A permissive but still ASCII-bounded set, for free-text notes.
  freeText,
}

class HabotMask {
  const HabotMask._();

  /// Field memory cap (substep 3). Overridable per field, but never unbounded.
  static const int defaultMaxLength = 255;

  /// The printable ASCII range. Anything outside it is a "non-ASCII formatting
  /// profile" in the Poka-Yoke's terms -- smart quotes, non-breaking spaces,
  /// zero-width joiners, emoji.
  static final RegExp printableAscii = RegExp(r'^[\x20-\x7E]*$');

  static final Map<HabotMaskKind, RegExp> patterns = <HabotMaskKind, RegExp>{
    HabotMaskKind.alphanumeric: RegExp(r'[a-zA-Z0-9 ]'),
    HabotMaskKind.text: RegExp(r"[a-zA-Z0-9 .,'\-()/&]"),
    HabotMaskKind.numeric: RegExp(r'[0-9]'),
    HabotMaskKind.decimal: RegExp(r'[0-9.]'),
    HabotMaskKind.phone: RegExp(r'[0-9 +\-()]'),
    HabotMaskKind.freeText: RegExp(r'[\x20-\x7E]'),
  };

  static RegExp patternFor(HabotMaskKind kind) => patterns[kind]!;

  /// The formatter stack for [kind]. Order matters: sanitise first, then
  /// filter the character set, then cap the length.
  static List<TextInputFormatter> formattersFor(
    HabotMaskKind kind, {
    int maxLength = defaultMaxLength,
  }) {
    return <TextInputFormatter>[
      const AsciiOnlyFormatter(),
      PasteHygieneFormatter(maxLength: maxLength),
      FilteringTextInputFormatter.allow(patternFor(kind)),
      LengthLimitingTextInputFormatter(maxLength),
    ];
  }

  /// Pure predicate behind [AsciiOnlyFormatter] -- unit-testable without a
  /// widget tree.
  static bool isPrintableAscii(String value) => printableAscii.hasMatch(value);

  /// Pure predicate behind the character filter.
  static bool isAllowed(String value, HabotMaskKind kind) {
    final RegExp pattern = patternFor(kind);
    for (final int rune in value.runes) {
      if (!pattern.hasMatch(String.fromCharCode(rune))) {
        return false;
      }
    }
    return true;
  }

  /// Strips everything outside printable ASCII, plus the specific offenders
  /// clipboard text carries most often (curly quotes and dashes are mapped to
  /// their ASCII equivalents rather than deleted, because deleting them
  /// silently corrupts words).
  static String sanitise(String value) {
    const Map<String, String> transliterate = <String, String>{
      '\u2018': "'", // left single quote
      '\u2019': "'", // right single quote
      '\u201C': '"', // left double quote
      '\u201D': '"', // right double quote
      '\u2013': '-', // en dash
      '\u2014': '-', // em dash
      '\u2026': '...', // ellipsis
      '\u00A0': ' ', // non-breaking space
    };
    final StringBuffer out = StringBuffer();
    for (final int rune in value.runes) {
      final String ch = String.fromCharCode(rune);
      final String? mapped = transliterate[ch];
      if (mapped != null) {
        out.write(mapped);
        continue;
      }
      if (isPrintableAscii(ch)) {
        out.write(ch);
      }
      // Anything else is dropped.
    }
    return out.toString();
  }
}

/// Poka-Yoke: drops non-ASCII formatting profiles before they enter state.
class AsciiOnlyFormatter extends TextInputFormatter {
  const AsciiOnlyFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String cleaned = HabotMask.sanitise(newValue.text);
    if (cleaned == newValue.text) {
      return newValue;
    }
    final int offset = newValue.selection.baseOffset > cleaned.length
        ? cleaned.length
        : newValue.selection.baseOffset;
    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: offset < 0 ? 0 : offset),
    );
  }
}

/// Substep 3 + IS12-CSIVW-011 Poka-Yoke: "Strip out trailing white spaces and
/// weird symbols automatically from clipboard text when values are pasted",
/// and reject a paste that blows past the field's memory cap.
///
/// A paste is detected as an insertion of more than one character at once --
/// a human keystroke adds exactly one.
class PasteHygieneFormatter extends TextInputFormatter {
  const PasteHygieneFormatter({required this.maxLength});

  final int maxLength;

  static bool looksLikePaste(String oldText, String newText) =>
      newText.length - oldText.length > 1;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!looksLikePaste(oldValue.text, newValue.text)) {
      return newValue;
    }
    // Substep 3: a paste that exceeds the cap is rejected outright rather than
    // silently truncated -- a half-pasted account number is worse than none.
    if (newValue.text.length > maxLength) {
      return oldValue;
    }
    final String trimmed = HabotMask.sanitise(newValue.text).trimRight();
    if (trimmed == newValue.text) {
      return newValue;
    }
    return TextEditingValue(
      text: trimmed,
      selection: TextSelection.collapsed(offset: trimmed.length),
    );
  }
}
