/// AISS: IS12-CSIVW-011-AS01-A01 -- "Setup character formatting filters across
/// text entry boxes."
/// AISS: IS02-CSIVW-005-AS01-A01 -- "Program dynamic inline error layouts to
/// activate when input fields fail validation checks."
/// AISS: BPTR-0160-A01 -- "Global Regex mapping per CDE applied to mobile text
/// fields."
///
/// Pure validation logic, no widgets. Kept separate so every rule is unit
/// testable without pumping a tree, and so the same rule drives both the
/// inline error text and the submit gate.
library;

import 'package:flutter/services.dart';

import 'input_mask.dart';

/// A Critical Data Element type. BPTR-0160 calls for a "Global Regex mapping
/// per CDE"; this enum plus [HabotFieldRules] is that mapping.
enum HabotCde {
  freeText,
  personName,
  emailAddress,
  phoneNumber,
  postalCode,
  addressLine,
  currencyAmount,
  quantity,
  percentage,
  dateIso,
  dateUs,
  timeOfDay,
  accountNumber,
}

/// The outcome of validating one field.
class FieldValidationResult {
  const FieldValidationResult._({
    required this.isValid,
    required this.message,
    this.isEmpty = false,
  });

  const FieldValidationResult.valid()
    : isValid = true,
      message = null,
      isEmpty = false;

  const FieldValidationResult.emptyRequired(String text)
    : isValid = false,
      message = text,
      isEmpty = true;

  const FieldValidationResult.invalid(String text)
    : isValid = false,
      message = text,
      isEmpty = false;

  final bool isValid;

  /// IS12-CSIVW-011 standard: "Display all text field validation messages using
  /// accessible text strings, never relying on color changes alone." The
  /// message is therefore never optional on a failure.
  final String? message;

  final bool isEmpty;
}

/// The rules for one CDE: what it accepts, how it is typed, what it looks like
/// empty, and what to say when it is wrong.
class HabotFieldRule {
  const HabotFieldRule({
    required this.cde,
    required this.mask,
    required this.pattern,
    required this.keyboardType,
    required this.errorMessage,
    this.placeholder,
    this.maxLength = HabotMask.defaultMaxLength,
    this.autocomplete = false,
  });

  final HabotCde cde;
  final HabotMaskKind mask;

  /// The full-value regex. [mask] filters keystrokes; this validates the
  /// finished string.
  final RegExp pattern;

  /// BPTR-0160 UX implementation: `inputmode="numeric"` -- contextual keyboard
  /// triggering for faster thumb typing.
  final TextInputType keyboardType;

  /// Plain language, no technical terms (REF-197 UX decision applies here too).
  final String errorMessage;

  /// BPTR-0160 UI decision: "Visual input masks (e.g., MM/DD/YYYY placeholders)
  /// inside the text field."
  final String? placeholder;

  final int maxLength;

  /// BPTR-0160 UX implementation: `autocomplete="off"` on sensitive fields.
  final bool autocomplete;

  List<TextInputFormatter> get formatters =>
      HabotMask.formattersFor(mask, maxLength: maxLength);

  FieldValidationResult validate(String value, {bool required = true}) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return required
          ? const FieldValidationResult.emptyRequired('This field is required.')
          : const FieldValidationResult.valid();
    }
    if (!pattern.hasMatch(trimmed)) {
      return FieldValidationResult.invalid(errorMessage);
    }
    return const FieldValidationResult.valid();
  }
}

/// The global CDE -> rule mapping.
class HabotFieldRules {
  const HabotFieldRules._();

  static final Map<HabotCde, HabotFieldRule> _rules =
      <HabotCde, HabotFieldRule>{
        HabotCde.freeText: HabotFieldRule(
          cde: HabotCde.freeText,
          mask: HabotMaskKind.freeText,
          pattern: RegExp(r'^[\x20-\x7E]{1,255}$'),
          keyboardType: TextInputType.multiline,
          errorMessage: 'Use standard letters, numbers and punctuation only.',
        ),
        HabotCde.personName: HabotFieldRule(
          cde: HabotCde.personName,
          mask: HabotMaskKind.text,
          pattern: RegExp(r"^[a-zA-Z][a-zA-Z .'\-]{0,79}$"),
          keyboardType: TextInputType.name,
          errorMessage: 'Enter a name using letters, spaces and hyphens.',
          maxLength: 80,
        ),
        HabotCde.emailAddress: HabotFieldRule(
          cde: HabotCde.emailAddress,
          mask: HabotMaskKind.freeText,
          pattern: RegExp(r'^[^@\s]+@[^@\s.]+\.[^@\s]{2,}$'),
          keyboardType: TextInputType.emailAddress,
          errorMessage: 'Enter an email address, like name@example.com.',
          placeholder: 'name@example.com',
          maxLength: 254,
        ),
        HabotCde.phoneNumber: HabotFieldRule(
          cde: HabotCde.phoneNumber,
          mask: HabotMaskKind.phone,
          pattern: RegExp(r'^\+?[0-9 \-()]{7,20}$'),
          keyboardType: TextInputType.phone,
          errorMessage: 'Enter a phone number with 7 to 20 digits.',
          placeholder: '+254 700 000000',
          maxLength: 20,
        ),
        HabotCde.postalCode: HabotFieldRule(
          cde: HabotCde.postalCode,
          mask: HabotMaskKind.alphanumeric,
          pattern: RegExp(r'^[a-zA-Z0-9 ]{3,10}$'),
          keyboardType: TextInputType.streetAddress,
          errorMessage: 'Enter a postal code of 3 to 10 characters.',
          maxLength: 10,
        ),
        HabotCde.addressLine: HabotFieldRule(
          cde: HabotCde.addressLine,
          mask: HabotMaskKind.text,
          pattern: RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9 .,\-/()]{2,99}$'),
          keyboardType: TextInputType.streetAddress,
          errorMessage: 'Enter a street address of at least 3 characters.',
          maxLength: 100,
        ),
        HabotCde.currencyAmount: HabotFieldRule(
          cde: HabotCde.currencyAmount,
          mask: HabotMaskKind.decimal,
          pattern: RegExp(r'^\d{1,12}(\.\d{1,2})?$'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          errorMessage: 'Enter an amount, with up to two decimal places.',
          placeholder: '0.00',
          maxLength: 15,
        ),
        HabotCde.quantity: HabotFieldRule(
          cde: HabotCde.quantity,
          mask: HabotMaskKind.numeric,
          pattern: RegExp(r'^\d{1,9}$'),
          keyboardType: TextInputType.number,
          errorMessage: 'Enter a whole number.',
          maxLength: 9,
        ),
        HabotCde.percentage: HabotFieldRule(
          cde: HabotCde.percentage,
          mask: HabotMaskKind.decimal,
          pattern: RegExp(r'^(100(\.0{1,2})?|\d{1,2}(\.\d{1,2})?)$'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          errorMessage: 'Enter a percentage between 0 and 100.',
          maxLength: 6,
        ),
        HabotCde.dateIso: HabotFieldRule(
          cde: HabotCde.dateIso,
          mask: HabotMaskKind.decimal,
          pattern: RegExp(r'^\d{4}-\d{2}-\d{2}$'),
          keyboardType: TextInputType.datetime,
          errorMessage: 'Enter a date as YYYY-MM-DD.',
          placeholder: 'YYYY-MM-DD',
          maxLength: 10,
        ),
        HabotCde.dateUs: HabotFieldRule(
          cde: HabotCde.dateUs,
          mask: HabotMaskKind.numeric,
          pattern: RegExp(r'^\d{2}/\d{2}/\d{4}$'),
          keyboardType: TextInputType.datetime,
          errorMessage: 'Enter a date as MM/DD/YYYY.',
          placeholder: 'MM/DD/YYYY',
          maxLength: 10,
        ),
        HabotCde.timeOfDay: HabotFieldRule(
          cde: HabotCde.timeOfDay,
          mask: HabotMaskKind.numeric,
          pattern: RegExp(r'^([01]\d|2[0-3]):[0-5]\d$'),
          keyboardType: TextInputType.datetime,
          errorMessage: 'Enter a 24-hour time as HH:MM.',
          placeholder: 'HH:MM',
          maxLength: 5,
        ),
        HabotCde.accountNumber: HabotFieldRule(
          cde: HabotCde.accountNumber,
          mask: HabotMaskKind.alphanumeric,
          pattern: RegExp(r'^[A-Za-z0-9]{6,34}$'),
          keyboardType: TextInputType.text,
          errorMessage: 'Enter an account number of 6 to 34 characters.',
          maxLength: 34,
        ),
      };

  static HabotFieldRule of(HabotCde cde) => _rules[cde]!;

  /// Completion measure for BPTR-0160 is `Invalid_Data_Type_Errors == 0`, which
  /// only holds if every CDE actually has a rule. Gated by BPTR-0160-G1.
  static bool get isComplete => _rules.length == HabotCde.values.length;

  static Iterable<HabotCde> get covered => _rules.keys;
}
