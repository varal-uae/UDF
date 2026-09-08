/// AISS Step 110 -- GEN-01793
/// "Map native keyboard types to specific field requirements."
///
/// COLUMN NOTE, RECORDED: Setup Step (Action) and Setup Step Description are
/// the identical string on this row.
///
/// METRIC MISMATCH, RECORDED. The row carries a generic step-completion rate.
/// The requirement is specific and checkable, so that is what is gated.
///
/// WHY THIS IS LAST IN THE BATCH. It is the narrowest step and the most
/// dependent: it needs the 13 Critical Data Element rules from Step 16, the
/// masked field from Step 15, and the scaling work from Step 102. A numeric
/// keypad is only an accessibility win if the field it opens over is still
/// readable at 200% text -- otherwise it is a smaller target under a bigger
/// keyboard.
///
/// WHAT STEP 16 ALREADY OWNS, and is therefore NOT redeclared here:
/// `HabotFieldRule.keyboardType`. Every CDE already names its keyboard. This
/// step does not add a second mapping that could disagree with the first -- it
/// READS that one and adds the four properties a `TextInputType` does not
/// carry, each of which is an accessibility decision in its own right:
///
///   * `textInputAction`   -- what the bottom-right key says. "Next" on a
///                            field in the middle of a form and "Done" on the
///                            last one is the difference between a keyboard a
///                            screen-reader user can traverse and one that
///                            traps them at the bottom of the screen.
///   * `textCapitalization` -- an account number auto-capitalised is an
///                            account number the user has to fix.
///   * `autofillHints`     -- the single largest reduction in typing on a
///                            handset, and the one that most helps a user with
///                            a motor impairment.
///   * `autocorrect` / `enableSuggestions`
///                         -- autocorrect on a postal code produces a word.
///
/// COMPLETENESS IS ENFORCED, not hoped for: [HabotKeyboardMapping.isComplete]
/// is false the moment a CDE is added without an entry, and GEN-01793-G1 fails
/// the build on it. Same shape as the Step 16 rules and the Step 19 templates.
library;

import 'package:flutter/services.dart';

import '../a11y/text_fit.dart';
import '../a11y/text_scaling.dart';
import '../tokens/typography_tokens.dart';
import 'field_validation.dart';

/// The keyboard behaviour for one critical data element.
class HabotKeyboardProfile {
  const HabotKeyboardProfile({
    required this.cde,
    required this.capitalization,
    required this.autofillHints,
    required this.autocorrect,
    required this.enableSuggestions,
    this.obscure = false,
  });

  final HabotCde cde;
  final TextCapitalization capitalization;

  /// Platform autofill categories. Empty where nothing sensible applies --
  /// a wrong hint is worse than none, because it offers the user the wrong
  /// value with confidence.
  final List<String> autofillHints;

  final bool autocorrect;
  final bool enableSuggestions;

  /// Reserved for fields whose content must not be shoulder-surfed. None of
  /// the 13 CDEs is currently one; declared so adding one is a data change.
  final bool obscure;

  /// Read from Step 16 rather than restated. One definition.
  TextInputType get keyboardType => HabotFieldRules.of(cde).keyboardType;

  /// "Next" everywhere except the last field of a form, which the caller
  /// declares. A field that always says "Done" ends input on every tap.
  TextInputAction actionFor({required bool isLast}) =>
      isLast ? TextInputAction.done : TextInputAction.next;

  Map<String, Object?> toJson() => <String, Object?>{
    'cde': cde.name,
    'keyboard_type': keyboardType.toString(),
    'capitalization': capitalization.name,
    'autofill_hints': autofillHints,
    'autocorrect': autocorrect,
    'enable_suggestions': enableSuggestions,
    'obscure': obscure,
  };
}

/// The mapping, one entry per critical data element.
class HabotKeyboardMapping {
  const HabotKeyboardMapping._();

  static const Map<HabotCde, HabotKeyboardProfile> _profiles =
      <HabotCde, HabotKeyboardProfile>{
        HabotCde.freeText: HabotKeyboardProfile(
          cde: HabotCde.freeText,
          capitalization: TextCapitalization.sentences,
          autofillHints: <String>[],
          autocorrect: true,
          enableSuggestions: true,
        ),
        HabotCde.personName: HabotKeyboardProfile(
          cde: HabotCde.personName,
          capitalization: TextCapitalization.words,
          autofillHints: <String>[AutofillHints.name],
          // A surname is not a dictionary word. Autocorrect here renames people.
          autocorrect: false,
          enableSuggestions: false,
        ),
        HabotCde.emailAddress: HabotKeyboardProfile(
          cde: HabotCde.emailAddress,
          capitalization: TextCapitalization.none,
          autofillHints: <String>[AutofillHints.email],
          autocorrect: false,
          enableSuggestions: false,
        ),
        HabotCde.phoneNumber: HabotKeyboardProfile(
          cde: HabotCde.phoneNumber,
          capitalization: TextCapitalization.none,
          autofillHints: <String>[AutofillHints.telephoneNumber],
          autocorrect: false,
          enableSuggestions: false,
        ),
        HabotCde.postalCode: HabotKeyboardProfile(
          cde: HabotCde.postalCode,
          // Postal codes are upper case in every market this app serves, and
          // typing them in caps by hand on a phone is four extra taps.
          capitalization: TextCapitalization.characters,
          autofillHints: <String>[AutofillHints.postalCode],
          autocorrect: false,
          enableSuggestions: false,
        ),
        HabotCde.addressLine: HabotKeyboardProfile(
          cde: HabotCde.addressLine,
          capitalization: TextCapitalization.words,
          autofillHints: <String>[AutofillHints.streetAddressLine1],
          autocorrect: false,
          enableSuggestions: true,
        ),
        HabotCde.currencyAmount: HabotKeyboardProfile(
          cde: HabotCde.currencyAmount,
          capitalization: TextCapitalization.none,
          autofillHints: <String>[],
          autocorrect: false,
          enableSuggestions: false,
        ),
        HabotCde.quantity: HabotKeyboardProfile(
          cde: HabotCde.quantity,
          capitalization: TextCapitalization.none,
          autofillHints: <String>[],
          autocorrect: false,
          enableSuggestions: false,
        ),
        HabotCde.percentage: HabotKeyboardProfile(
          cde: HabotCde.percentage,
          capitalization: TextCapitalization.none,
          autofillHints: <String>[],
          autocorrect: false,
          enableSuggestions: false,
        ),
        HabotCde.dateIso: HabotKeyboardProfile(
          cde: HabotCde.dateIso,
          capitalization: TextCapitalization.none,
          autofillHints: <String>[],
          autocorrect: false,
          enableSuggestions: false,
        ),
        HabotCde.dateUs: HabotKeyboardProfile(
          cde: HabotCde.dateUs,
          capitalization: TextCapitalization.none,
          autofillHints: <String>[],
          autocorrect: false,
          enableSuggestions: false,
        ),
        HabotCde.timeOfDay: HabotKeyboardProfile(
          cde: HabotCde.timeOfDay,
          capitalization: TextCapitalization.none,
          autofillHints: <String>[],
          autocorrect: false,
          enableSuggestions: false,
        ),
        HabotCde.accountNumber: HabotKeyboardProfile(
          cde: HabotCde.accountNumber,
          capitalization: TextCapitalization.characters,
          autofillHints: <String>[],
          autocorrect: false,
          enableSuggestions: false,
        ),
      };

  static HabotKeyboardProfile of(HabotCde cde) => _profiles[cde]!;

  static Iterable<HabotKeyboardProfile> get all => _profiles.values;

  /// Every CDE is mapped. False the moment one is added without.
  static bool get isComplete => _profiles.length == HabotCde.values.length;

  static List<HabotCde> get missing => HabotCde.values
      .where((HabotCde c) => !_profiles.containsKey(c))
      .toList();

  /// A structured field must never be autocorrected. This is the rule that
  /// stops the table drifting back to platform defaults one entry at a time.
  static const Set<HabotCde> structured = <HabotCde>{
    HabotCde.emailAddress,
    HabotCde.phoneNumber,
    HabotCde.postalCode,
    HabotCde.currencyAmount,
    HabotCde.quantity,
    HabotCde.percentage,
    HabotCde.dateIso,
    HabotCde.dateUs,
    HabotCde.timeOfDay,
    HabotCde.accountNumber,
    HabotCde.personName,
  };

  static List<HabotCde> get structuredFieldsWithAutocorrect => structured
      .where((HabotCde c) => _profiles[c]?.autocorrect ?? false)
      .toList();

  /// THE STEP 102 TIE. A field label has to stay readable when the OS text
  /// scale is turned up, because that is exactly the user for whom the right
  /// keyboard matters most. This is the check the build order asks for, and it
  /// reuses the Step 102 audit rather than re-deriving it.
  static bool labelSurvivesMaxScale({
    double width = HabotTextFit.auditWidthDp,
    String label = 'Account number',
  }) => HabotTextScaleAudit.auditToken(
    HabotTypography.bodyLarge,
    width: width,
    text: label,
  ).every((HabotScaledFitResult r) => r.fits);
}
